import 'package:auto_route/auto_route.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/reader/presentation/providers/ebook_sections_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../../common/widgets/notification_card.dart';

// Reader settings
class ReaderSettings {
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final Color textColor;
  final Color backgroundColor;
  final double brightness;
  final bool isDarkMode;
  final Color pageColor;
  final String? backgroundTexture;
  final double pageMargin;

  const ReaderSettings({
    this.fontSize = 18.0,
    this.fontFamily = 'Merriweather',
    this.lineHeight = 1.5,
    this.textColor = Colors.black87,
    this.backgroundColor = Colors.white,
    this.brightness = 1.0,
    this.isDarkMode = false,
    this.pageColor = Colors.white,
    this.backgroundTexture,
    this.pageMargin = 16.0,
  });

  ReaderSettings copyWith({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    Color? textColor,
    Color? backgroundColor,
    double? brightness,
    bool? isDarkMode,
    Color? pageColor,
    String? backgroundTexture,
    double? pageMargin,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      brightness: brightness ?? this.brightness,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      pageColor: pageColor ?? this.pageColor,
      backgroundTexture: backgroundTexture ?? this.backgroundTexture,
      pageMargin: pageMargin ?? this.pageMargin,
    );
  }
}

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  final Ref _ref;

  ReaderSettingsNotifier(this._ref)
    : super(
        ReaderSettings(
          isDarkMode:
              _ref.read(currentAppThemeNotifierProvider).valueOrNull ==
              CurrentAppTheme.dark,
        ),
      ) {
    _updateColorsForTheme();

    _ref.listen(currentAppThemeNotifierProvider, (previous, next) {
      if (next.valueOrNull != null &&
          next.valueOrNull != (previous?.valueOrNull)) {
        final isDarkMode = next.valueOrNull == CurrentAppTheme.dark;
        if (state.isDarkMode != isDarkMode) {
          state = state.copyWith(isDarkMode: isDarkMode);
          _updateColorsForTheme();
        }
      }
    });
  }

  void _updateColorsForTheme() {
    if (state.isDarkMode) {
      state = state.copyWith(
        textColor: Colors.white.withOpacity(0.95),
        backgroundColor: const Color(0xFF121212),
        pageColor: const Color(0xFF1A1A1A),
      );
    } else {
      state = state.copyWith(
        textColor: Colors.black.withOpacity(0.85),
        backgroundColor: const Color(0xFFF5F5F5),
        pageColor: Colors.white,
      );
    }
  }

  void updateFontSize(double size) {
    state = state.copyWith(fontSize: size);
  }

  void updateFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void updateLineHeight(double height) {
    state = state.copyWith(lineHeight: height);
  }

  void updatePageColor(Color color) {
    state = state.copyWith(pageColor: color);
  }

  void updatePageMargin(double margin) {
    state = state.copyWith(pageMargin: margin);
  }
}

final readerSettingsProvider =
    StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
      return ReaderSettingsNotifier(ref);
    });

final currentSectionIndexProvider = StateProvider<int>((ref) => 0);

@RoutePage()
class EbookReaderScreen extends ConsumerStatefulWidget {
  final String ebookId;

  const EbookReaderScreen({Key? key, required this.ebookId}) : super(key: key);

  @override
  ConsumerState<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends ConsumerState<EbookReaderScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  double _downloadProgress = 0.0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;

  bool _isFullScreen = false;
  bool _showControls = true;
  bool _showTableOfContents = false;
  bool _showSettings = false;
  late PageController _pageController;

  Map<String, bool> _expandedHeadings = {};
  bool _isActionButtonsExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(keepPage: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionsState = ref.read(sectionsProvider(widget.ebookId));
      if (!sectionsState.isLoading && sectionsState.ebook == null) {
        ref.read(sectionsProvider(widget.ebookId).notifier).fetchSections();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDark =
          ref.read(currentAppThemeNotifierProvider).valueOrNull ==
          CurrentAppTheme.dark;
      if (ref.read(readerSettingsProvider).isDarkMode != isDark) {
        ref.read(readerSettingsProvider.notifier)._updateColorsForTheme();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleTableOfContents() {
    setState(() {
      _showTableOfContents = !_showTableOfContents;
      _showSettings = false;

      if (_showTableOfContents && _expandedHeadings.isEmpty) {
        final ebook = ref.read(sectionsProvider(widget.ebookId)).ebook;
        if (ebook?.contentTitles != null) {
          for (final title in ebook!.contentTitles!) {
            if (title['type'] == 'head') {
              _expandedHeadings[title['title']] = true;
            }
          }
        }
      }
    });
  }

  void _toggleSettings() {
    setState(() {
      _showSettings = !_showSettings;
      _showTableOfContents = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final sectionsState = ref.watch(sectionsProvider(widget.ebookId));
    final currentSettings = ref.watch(readerSettingsProvider);
    final currentSectionIndex = ref.watch(currentSectionIndexProvider);
    final isDark = currentSettings.isDarkMode;

    _downloadProgress = sectionsState.progress;
    _downloadedBytes = sectionsState.downloadedBytes;

    if (_downloadProgress > 0 && _downloadedBytes > 0) {
      _totalBytes = (_downloadedBytes / _downloadProgress).round();
    }

    return Scaffold(
      backgroundColor: currentSettings.backgroundColor,
      appBar:
          (!_isFullScreen && _showControls)
              ? AppBar(
                backgroundColor: isDark ? AppColors.darkBg : Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.router.popForced(),
                ),
                title: Text(
                  sectionsState.ebook?.title ?? widget.ebookId,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: currentSettings.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                actions: [
                  if (sectionsState.isCached)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        ref
                            .read(sectionsProvider(widget.ebookId).notifier)
                            .fetchSections();
                      },
                      tooltip: 'Refresh Content',
                    ),
                  IconButton(
                    icon: Icon(MdiIcons.bookOpenPageVariant),
                    color:
                        _showTableOfContents
                            ? (isDark
                                ? AppColors.neonCyan
                                : AppColors.brandDeepGold)
                            : null,
                    onPressed: _toggleTableOfContents,
                    tooltip: 'Table of Contents',
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.cog),
                    color:
                        _showSettings
                            ? (isDark
                                ? AppColors.neonCyan
                                : AppColors.brandDeepGold)
                            : null,
                    onPressed: _toggleSettings,
                    tooltip: 'Reader Settings',
                  ),
                  IconButton(
                    icon: Icon(
                      _isFullScreen
                          ? MdiIcons.fullscreenExit
                          : MdiIcons.fullscreen,
                    ),
                    onPressed: _toggleFullScreen,
                    tooltip: _isFullScreen ? 'Exit Fullscreen' : 'Fullscreen',
                  ),
                ],
              )
              : null,
      body: Builder(
        builder: (context) {
          if (sectionsState.isLoading && !sectionsState.isCached) {
            return _buildLoadingIndicator(
              isDark,
              sectionsState.progress,
              sectionsState.downloadedBytes,
            );
          }

          if (sectionsState.errorMessage != null && !sectionsState.isCached) {
            return _buildErrorView(sectionsState.errorMessage!, isDark);
          }

          final ebook = sectionsState.ebook;
          if (ebook == null ||
              ebook.sections == null ||
              ebook.sections!.isEmpty) {
            return _buildNoContentView(isDark);
          }

          return Stack(
            children: [
              GestureDetector(
                onTap: _toggleControls,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: ebook.sections!.length,
                  onPageChanged: (index) {
                    ref.read(currentSectionIndexProvider.notifier).state =
                        index;
                  },
                  itemBuilder: (context, index) {
                    final section = ebook.sections![index];
                    final fileUrl = ebook.fileUrl;
                    return _buildSectionView(section, currentSettings, fileUrl);
                  },
                ),
              ),
              if (_showTableOfContents)
                _buildTableOfContents(ebook, currentSectionIndex, isDark),
              if (_showSettings) _buildSettingsPanel(isDark),
              if (_showControls && !_isFullScreen)
                _buildBottomNavigationBar(ebook, currentSectionIndex, isDark),
              if (_showControls)
                _buildNavigationArrows(ebook, currentSectionIndex),
              if (_showControls && !_isFullScreen) _buildActionButtons(isDark),
              if (sectionsState.isLoading && sectionsState.isCached)
                Positioned(
                  top: 60,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Updating...',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(
    bool isDark,
    double progress,
    int downloadedBytes,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 6,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                ),
              ),
              const Icon(
                Icons.auto_stories,
                size: 30,
                color: AppColors.brandDeepGold,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Loading enhanced reader...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (progress > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% • ${_formatBytes(downloadedBytes)}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            if (_totalBytes > 0)
              Text(
                'of ${_formatBytes(_totalBytes)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MdiIcons.alertCircleOutline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load enhanced reader content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(sectionsProvider(widget.ebookId).notifier)
                    .fetchSections();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContentView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.bookAlert,
              size: 64,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
            const SizedBox(height: 16),
            Text(
              'No readable content available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This ebook does not have any processed sections. Try viewing the PDF version instead.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.router.popForced(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOfContents(
    EbookModel ebook,
    int currentIndex,
    bool isDark,
  ) {
    final List<Map<String, dynamic>> headings = [];
    final Map<String, List<Map<String, dynamic>>> subheadings = {};

    if (ebook.contentTitles != null && ebook.contentTitles!.isNotEmpty) {
      for (final title in ebook.contentTitles!) {
        if (title['type'] == 'head') {
          headings.add(title);
          subheadings[title['title']] = [];
        } else if (title['type'] == 'sub') {
          if (headings.isNotEmpty) {
            final parentHeading = headings.last['title'];
            subheadings[parentHeading]?.add(title);
          }
        }
      }
    }

    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Text(
                    'Contents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleTableOfContents,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  ebook.contentTitles != null && ebook.contentTitles!.isNotEmpty
                      ? _buildHierarchicalContents(
                        headings,
                        subheadings,
                        ebook,
                        currentIndex,
                        isDark,
                      )
                      : _buildFlatContents(ebook, currentIndex, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchicalContents(
    List<Map<String, dynamic>> headings,
    Map<String, List<Map<String, dynamic>>> subheadings,
    EbookModel ebook,
    int currentIndex,
    bool isDark,
  ) {
    return ListView.builder(
      itemCount: headings.length,
      itemBuilder: (context, headingIndex) {
        final heading = headings[headingIndex];
        final headingTitle = heading['title'];
        final int sectionIndex = ebook.sections!.indexWhere(
          (section) => section['title'] == headingTitle,
        );
        final bool isHeadingActive = sectionIndex == currentIndex;
        final subs = subheadings[headingTitle] ?? [];
        final bool isExpanded = _expandedHeadings[headingTitle] ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (sectionIndex >= 0) {
                  _navigateToSection(sectionIndex);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 24),
                    if (subs.isNotEmpty)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedHeadings[headingTitle] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      )
                    else
                      SizedBox(width: 34),
                    Expanded(
                      child: Text(
                        headingTitle,
                        style: TextStyle(
                          color:
                              isHeadingActive
                                  ? (isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold)
                                  : (isDark ? Colors.white : Colors.black87),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isHeadingActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Icon(
                          Icons.bookmark,
                          color:
                              isDark
                                  ? AppColors.neonCyan
                                  : AppColors.brandDeepGold,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded && subs.isNotEmpty)
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: isExpanded ? subs.length * 40.0 : 0.0,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: subs.length,
                  itemBuilder: (context, i) {
                    final sub = subs[i];
                    final subTitle = sub['title'];
                    final int subSectionIndex = ebook.sections!.indexWhere(
                      (section) => section['title'] == subTitle,
                    );
                    final bool isSubActive = subSectionIndex == currentIndex;

                    return ListTile(
                      title: Text(
                        subTitle,
                        style: TextStyle(
                          color:
                              isSubActive
                                  ? (isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold)
                                  : (isDark ? Colors.white70 : Colors.black54),
                          fontWeight:
                              isSubActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      leading:
                          isSubActive
                              ? Icon(
                                Icons.bookmark,
                                color:
                                    isDark
                                        ? AppColors.neonCyan
                                        : AppColors.brandDeepGold,
                                size: 18,
                              )
                              : null,
                      contentPadding: const EdgeInsets.only(
                        left: 48,
                        right: 24,
                        top: 2,
                        bottom: 2,
                      ),
                      dense: true,
                      onTap:
                          subSectionIndex >= 0
                              ? () => _navigateToSection(subSectionIndex)
                              : null,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFlatContents(EbookModel ebook, int currentIndex, bool isDark) {
    return ListView.builder(
      itemCount: ebook.sections?.length ?? 0,
      itemBuilder: (context, index) {
        final section = ebook.sections![index];
        final title = section['title'] ?? 'Section ${index + 1}';
        final isActive = index == currentIndex;

        return ListTile(
          title: Text(
            title,
            style: TextStyle(
              color:
                  isActive
                      ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                      : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          leading:
              isActive
                  ? Icon(
                    Icons.bookmark,
                    color:
                        isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                  )
                  : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 4,
          ),
          dense: true,
          onTap: () => _navigateToSection(index),
        );
      },
    );
  }

  Widget _buildSettingsPanel(bool isDark) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reading Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSettings,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              'Font Size',
              Icon(
                MdiIcons.formatSize,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(readerSettingsProvider);
                  return Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: settings.fontSize,
                          min: 12,
                          max: 28,
                          divisions: 8,
                          onChanged: (value) {
                            ref
                                .read(readerSettingsProvider.notifier)
                                .updateFontSize(value);
                          },
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 22)),
                    ],
                  );
                },
              ),
            ),
            _buildSettingsSection(
              'Font',
              Icon(
                MdiIcons.formatFont,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(readerSettingsProvider);
                  return DropdownButton<String>(
                    value: settings.fontFamily,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(readerSettingsProvider.notifier)
                            .updateFontFamily(value);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'Merriweather',
                        child: Text('Merriweather'),
                      ),
                      DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                      DropdownMenuItem(
                        value: 'OpenSans',
                        child: Text('OpenSans'),
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildSettingsSection(
              'Line Height',
              Icon(
                MdiIcons.formatLineSpacing,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(readerSettingsProvider);
                  return Slider(
                    value: settings.lineHeight,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    onChanged: (value) {
                      ref
                          .read(readerSettingsProvider.notifier)
                          .updateLineHeight(value);
                    },
                  );
                },
              ),
            ),
            if (!isDark)
              _buildSettingsSection(
                'Page Style',
                Icon(
                  MdiIcons.bookOpenPageVariant,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        _buildPageColorOption(Colors.white, isDark),
                        const SizedBox(width: 8),
                        _buildPageColorOption(const Color(0xFFF8F1E3), isDark),
                        const SizedBox(width: 8),
                        _buildPageColorOption(const Color(0xFFE8F4F8), isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Page Margin',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: ref.watch(readerSettingsProvider).pageMargin,
                            min: 8.0,
                            max: 32.0,
                            divisions: 6,
                            onChanged: (value) {
                              ref
                                  .read(readerSettingsProvider.notifier)
                                  .updatePageMargin(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, Widget icon, Widget controls) {
    final isDark = ref.watch(readerSettingsProvider).isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20,
      ), // Note: 'custom' should be a named parameter like 'bottom'
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          controls,
        ],
      ),
    );
  }

  Widget _buildPageColorOption(Color color, bool isDark) {
    final currentPageColor = ref.watch(readerSettingsProvider).pageColor;
    final isSelected = color.value == currentPageColor.value;

    return InkWell(
      onTap: () {
        ref.read(readerSettingsProvider.notifier).updatePageColor(color);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? (isDark ? AppColors.neonCyan : AppColors.brandDeepGold)
                    : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    EbookModel ebook,
    int currentIndex,
    bool isDark,
  ) {
    final sectionCount = ebook.sections?.length ?? 0;
    final progress = sectionCount > 0 ? (currentIndex + 1) / sectionCount : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Section ${currentIndex + 1} of $sectionCount',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      color:
                          currentIndex > 0
                              ? (isDark ? Colors.white70 : Colors.black54)
                              : (isDark ? Colors.white30 : Colors.black26),
                      onPressed:
                          currentIndex > 0
                              ? () => _navigateToSection(currentIndex - 1)
                              : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      color:
                          currentIndex < sectionCount - 1
                              ? (isDark ? Colors.white70 : Colors.black54)
                              : (isDark ? Colors.white30 : Colors.black26),
                      onPressed:
                          currentIndex < sectionCount - 1
                              ? () => _navigateToSection(currentIndex + 1)
                              : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrows(EbookModel ebook, int currentIndex) {
    final sectionCount = ebook.sections?.length ?? 0;

    return Stack(
      children: [
        if (currentIndex > 0)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: GestureDetector(
                  onTap: () => _navigateToSection(currentIndex - 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        if (currentIndex < sectionCount - 1)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => _navigateToSection(currentIndex + 1),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final settings = ref.watch(readerSettingsProvider);
    final isDark = settings.isDarkMode;
    final buttonColor = isDark ? AppColors.neonCyan : AppColors.brandDeepGold;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: buttonColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: buttonColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSection(int sectionIndex) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        sectionIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (_showTableOfContents) {
      setState(() {
        _showTableOfContents = false;
      });
    }
  }

  Widget _buildActionButtons(bool isDark) {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "mainFab",
            mini: true,
            backgroundColor:
                isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            onPressed: () {
              setState(() {
                _isActionButtonsExpanded = !_isActionButtonsExpanded;
              });
            },
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              turns: _isActionButtonsExpanded ? 0.125 : 0,
              child: Icon(
                _isActionButtonsExpanded ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isActionButtonsExpanded ? 180 : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 12),
                  if (_isActionButtonsExpanded) ...[
                    _buildActionButton(
                      icon: Icons.headphones,
                      label: 'Generate Audio',
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                      onTap: () => _generateAudio(),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.quiz_outlined,
                      label: 'Create Questions',
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                      onTap: () => _createQuestions(),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.summarize_outlined,
                      label: 'Create Summary',
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                      onTap: () => _createSummary(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _generateAudio() {
    NotificationService().showNotification(
      message: 'Audio generation started for this section',
      type: NotificationType.info,
      duration: const Duration(seconds: 3),
    );
  }

  void _createQuestions() {
    NotificationService().showNotification(
      message: 'Question generation started for this section',
      type: NotificationType.info,
      duration: const Duration(seconds: 3),
    );
  }

  void _createSummary() {
    NotificationService().showNotification(
      message: 'Summary generation started for this section',
      type: NotificationType.info,
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildSectionView(
    Map<String, dynamic> section,
    ReaderSettings settings,
    String? fileUrl,
  ) {
    final String content = section['content'] ?? 'No content available';

    return Container(
      color: settings.backgroundColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Html(
            data: content,
            style: {
              "body": Style(
                fontFamily: settings.fontFamily,
                fontSize: FontSize(settings.fontSize),
                lineHeight: LineHeight(settings.lineHeight),
                color: settings.textColor,
                padding: HtmlPaddings.zero,
                margin: Margins.zero,
              ),
              "p": Style(margin: Margins.only(bottom: 12.0)),
              "h1, h2, h3, h4, h5": Style(
                fontWeight: FontWeight.bold,
                margin: Margins.only(top: 24.0, bottom: 12.0),
                color: settings.textColor,
              ),
              "img": Style(
                margin: Margins.only(top: 16.0, bottom: 16.0),
                alignment: Alignment.center,
              ),
              "a": Style(
                color:
                    settings.isDarkMode
                        ? AppColors.neonCyan
                        : AppColors.brandDeepGold,
              ),
              "table": Style(
                backgroundColor:
                    settings.isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                border: Border.all(color: settings.textColor.withOpacity(0.3)),
                alignment: Alignment.center,
              ),
              ".figure-reference": Style(
                margin: Margins.only(top: 24.0, bottom: 24.0),
                border: Border.all(
                  color: AppColors.brandDeepGold.withOpacity(0.5),
                ),
              ),
              ".figure-description": Style(
                fontSize: FontSize(settings.fontSize),
                margin: Margins.only(top: 12.0),
                fontWeight: FontWeight.w400,
              ),
            },
            extensions: [
              TagWrapExtension(
                tagsToWrap: {'caption'},
                builder:
                    (child) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: child,
                    ),
              ),
              CustomTableHtmlExtension(),
              TagWrapExtension(
                tagsToWrap: {'table'},
                builder:
                    (child) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: child,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}

class CustomTableHtmlExtension extends TableHtmlExtension {
  @override
  InlineSpan build(ExtensionContext context) {
    final defaultSpan = super.build(context);
    return WidgetSpan(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                context.buildContext != null
                    ? MediaQuery.of(context.buildContext!).size.width
                    : 800,
          ),
          child: defaultSpan is WidgetSpan ? defaultSpan.child : Container(),
        ),
      ),
    );
  }
}


