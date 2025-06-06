import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/router/app_router.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';

class FeaturedBookOverlay extends StatefulWidget {
  final EbookModel book;
  final VoidCallback onDismiss;

  const FeaturedBookOverlay({
    Key? key,
    required this.book,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<FeaturedBookOverlay> createState() => _FeaturedBookOverlayState();
}

class _FeaturedBookOverlayState extends State<FeaturedBookOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    
    // Show the overlay after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showOverlay = true;
          _controller.forward();
        });
      }
    });
  }

  void _hideOverlay() {
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showOverlay = false;
        });
        widget.onDismiss();
      }
    });
  }

  void _navigateToBook(BuildContext context) {
    // First hide the overlay
    _hideOverlay();
    
    // Then navigate to the book detail screen
    context.router.push(
      EbookDetailRoute(
        id: widget.book.id,
        slug: widget.book.slug,
        ebook: widget.book,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      bottom: 80,
      right: 16,
      child: ScaleTransition(
        scale: _animation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToBook(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Featured banner
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Book cover
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: widget.book.image != null && widget.book.image!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.book.image!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                    child: Icon(
                                      MdiIcons.bookOpenPageVariant,
                                      size: 48,
                                      color: isDark ? Colors.white24 : Colors.black12,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  child: Icon(
                                    MdiIcons.bookOpenPageVariant,
                                    size: 48,
                                    color: isDark ? Colors.white24 : Colors.black12,
                                  ),
                                ),
                        ),
                        
                        // Featured badge banner
                        Positioned(
                          top: 12,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade600,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'FEATURED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Close button
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: _hideOverlay,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Book info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'By ${widget.book.author}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Call to action button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: Colors.red.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.book.likeCount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  MdiIcons.bookOpenPageVariant,
                                  size: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.book.contentCount} ch',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Read Now',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
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
          ),
        ),
      ),
    );
  }
}