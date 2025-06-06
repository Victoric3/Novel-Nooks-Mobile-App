import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:novelnooks/src/features/reader/providers/reader_provider.dart';
import 'package:novelnooks/src/features/reader/services/reader_service.dart';

@RoutePage()
class ReaderScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String title;
  final bool isFree;
  final int contentCount;
  final double pricePerChapter;
  final bool completed;

  const ReaderScreen({
    Key? key,
    required this.storyId,
    required this.title,
    required this.isFree,
    required this.contentCount,
    required this.pricePerChapter,
    required this.completed,
  }) : super(key: key);

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late EpubController _epubController;
  bool _hasShownPaymentModal = false;
  String? _lastCfi;
  EpubFlow _currentFlow = EpubFlow.paginated;
  double _fontSize = 16.0;
  bool _showUI = true;
  bool _isDarkMode = false;
  double _currentProgress = 0.0;
  List<EpubChapter> _chapters = [];
  String _currentFontFamily = 'Default';
  double _lineHeight = 1.5;
  double _margin = 16.0;

  final List<String> _fontFamilies = [
    'Default',
    'Georgia',
    'Times New Roman',
    'Roboto',
    'OpenSans',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _epubController = EpubController();
    _isDarkMode =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    Future.microtask(() {
      ref
          .read(readerProvider.notifier)
          .loadEpub(
            widget.storyId,
            widget.title,
            widget.isFree,
            widget.contentCount,
            widget.pricePerChapter,
            widget.completed,
          );
    });
    _loadLastPosition();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final state = ref.read(readerProvider);
      if (state.epubFilePath != null && !state.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastCfi != null) {
            try {
              final cfi = _parseInitialCfi(_lastCfi);
              if (cfi != null) {
                _epubController.display(cfi: cfi);
                print('Restored position: $cfi');
              }
            } catch (e) {
              print('Error restoring position: $e');
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLastPosition() async {
    final position = await ref
        .read(readerServiceProvider)
        .getLastReadingPosition(widget.storyId);
    if (position != null) {
      setState(() {
        _lastCfi = position;
      });
    }
  }

  String? _parseInitialCfi(String? savedLocation) {
    if (savedLocation == null) return null;
    try {
      final locationData = jsonDecode(savedLocation);
      return locationData['startCfi'];
    } catch (e) {
      print('Error parsing saved location: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider);

    if (state.previewMode &&
        !_hasShownPaymentModal &&
        !state.isLoading &&
        state.epubFilePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPaymentModal(context);
        _hasShownPaymentModal = true;
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      drawer: _buildTableOfContentsDrawer(),
      appBar:
          _showUI
              ? AppBar(
                title: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => context.router.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.list,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => _showReaderSettings(context),
                  ),
                ],
              )
              : null,
      body: Stack(
        children: [
          // Conditional widget: loading, error, or EpubViewer with padding
          state.isLoading
              ? _buildLoadingView(state.downloadProgress)
              : state.errorMessage != null
              ? _buildErrorView(state.errorMessage!)
              : state.epubFilePath == null
              ? Center(
                child: Text(
                  'No content available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
              : Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Increased padding to prevent text overflow
                child: EpubViewer(
                  epubController: _epubController,
                  epubSource: EpubSource.fromFile(File(state.epubFilePath!)),
                  initialCfi: _parseInitialCfi(_lastCfi),
                  displaySettings: EpubDisplaySettings(
                    flow: _currentFlow,
                    snap: true,
                    theme: _isDarkMode ? EpubTheme.dark() : EpubTheme.light(),
                  ),
                  onEpubLoaded: () {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      final chapters = _epubController.getChapters();
                      if (chapters.isNotEmpty) {
                        setState(() => _chapters = chapters);
                        if (_lastCfi == null && chapters.length > 1) {
                          final startIndex =
                              chapters[0].title.toLowerCase().contains('cover')
                                  ? 1
                                  : 0;
                          if (startIndex < chapters.length) {
                            _epubController.display(
                              cfi: chapters[startIndex].href,
                            );
                          }
                        }
                      }
                    });
                  },
                  onChaptersLoaded:
                      (chapters) => setState(() => _chapters = chapters),
                  onRelocated: (location) {
                    setState(() => _currentProgress = location.progress);
                    final locationData = {
                      'startCfi': location.startCfi,
                      'endCfi': location.endCfi,
                      'progress': location.progress,
                    };
                    ref
                        .read(readerServiceProvider)
                        .saveReadingPosition(
                          widget.storyId,
                          jsonEncode(locationData),
                        );
                  },
                  onTextSelected:
                      (selection) => _showTextSelectionMenu(context, selection),
                ),
              ),
          // Progress indicator at the bottom
          if (!state.isLoading &&
              state.errorMessage == null &&
              state.epubFilePath != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: _currentProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
                minHeight: 2,
              ),
            ),
          // Double-tap GestureDetector to toggle UI
          Positioned.fill(
            child: GestureDetector(
              onDoubleTap: () {
                print('Double tap detected');
                setState(() {
                  _showUI = !_showUI;
                });
              },
              behavior:
                  HitTestBehavior
                      .translucent, // Allows swipes to pass through to EpubViewer
            ),
          ),
          // Bottom navigation bar when UI is shown
          if (_showUI &&
              !state.isLoading &&
              state.errorMessage == null &&
              state.epubFilePath != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, -2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          print(
                            'Previous button pressed',
                          ); // Debug print to confirm tap
                          _epubController.prev();
                        },
                      ),
                      Text(
                        '${(_currentProgress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          print(
                            'Next button pressed',
                          ); // Debug print to confirm tap
                          _epubController.next();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Tap areas to show UI when hidden
          if (!_showUI)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showUI = true);
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
          if (!_showUI)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 50,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showUI = true);
                },
                behavior: HitTestBehavior.translucent,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTableOfContentsDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table of Contents',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _currentProgress,
                  backgroundColor: Theme.of(context).dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_currentProgress * 100).toInt()}% read',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    chapter.title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onTap: () {
                    _epubController.display(cfi: chapter.href);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTextSelectionMenu(
    BuildContext context,
    EpubTextSelection selection,
  ) {
    try {
      final selectionText = selection.toString();
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu(
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromCenter(
            center: MediaQuery.of(context).size.center(Offset.zero),
            width: 100,
            height: 100,
          ),
          Offset.zero & overlay.size,
        ),
        items: [
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.highlight),
              title: const Text('Highlight'),
              onTap: () {
                try {
                  _epubController.addHighlight(
                    cfi: selectionText,
                    color: Colors.yellow,
                    opacity: 0.5,
                  );
                } catch (e) {
                  print('Error highlighting: $e');
                }
                Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    } catch (e) {
      print('Error showing text selection menu: $e');
    }
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text(
                          'Dark Mode',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: Switch(
                          value: _isDarkMode,
                          onChanged: (value) {
                            setModalState(() => _isDarkMode = value);
                            setState(() => _isDarkMode = value);
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Reading Mode',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: DropdownButton<EpubFlow>(
                          value: _currentFlow,
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _currentFlow = value);
                              setState(() => _currentFlow = value);
                              _epubController.setFlow(flow: value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: EpubFlow.paginated,
                              child: Text('Paginated'),
                            ),
                            DropdownMenuItem(
                              value: EpubFlow.scrolled,
                              child: Text('Scrolled'),
                            ),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Font Size',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          label: _fontSize.round().toString(),
                          onChanged: (value) {
                            setModalState(() => _fontSize = value);
                            setState(() => _fontSize = value);
                            _epubController.setFontSize(
                              fontSize: value,
                            ); // Note: Enable if supported by package
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Font Family',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: DropdownButton<String>(
                          value: _currentFontFamily,
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _currentFontFamily = value);
                              setState(() => _currentFontFamily = value);
                              // Note: Add font family support if package allows in future
                            }
                          },
                          items:
                              _fontFamilies.map((font) {
                                return DropdownMenuItem(
                                  value: font,
                                  child: Text(font),
                                );
                              }).toList(),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Line Height',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Slider(
                          value: _lineHeight,
                          min: 1.0,
                          max: 2.0,
                          divisions: 10,
                          label: _lineHeight.toStringAsFixed(1),
                          onChanged: (value) {
                            setModalState(() => _lineHeight = value);
                            setState(() => _lineHeight = value);
                            // Note: Add line height support if package allows in future
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Margin',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Slider(
                          value: _margin,
                          min: 0,
                          max: 32,
                          divisions: 16,
                          label: _margin.round().toString(),
                          onChanged: (value) {
                            setModalState(() => _margin = value);
                            setState(() => _margin = value);
                            // Note: Add margin support if package allows in future
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildLoadingView(double progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading eBook...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (progress > 0)
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading eBook',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                () => ref
                    .read(readerProvider.notifier)
                    .loadEpub(
                      widget.storyId,
                      widget.title,
                      widget.isFree,
                      widget.contentCount,
                      widget.pricePerChapter,
                      widget.completed,
                    ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showPaymentModal(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Payment Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: Text(
              'This story requires ${widget.contentCount} chapters at \$${widget.pricePerChapter} each.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement payment logic here
                  Navigator.pop(context);
                },
                child: const Text('Pay'),
              ),
            ],
          ),
    );
  }
}
