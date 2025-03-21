import 'dart:async';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/auth/providers/user_provider.dart';
import 'package:novelnooks/src/features/comments/data/models/comment_model.dart';
import 'package:novelnooks/src/features/comments/presentation/providers/comment_provider.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/library/presentation/providers/ebook_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/features/reader/services/reader_service.dart';
import 'package:timeago/timeago.dart' as timeago;

// Import the StarRating widget
import 'package:novelnooks/src/common/widgets/star_rating.dart';

// Add these imports
import 'package:novelnooks/src/common/widgets/notification_card.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';

// Add the imports at the top of your file
import 'package:novelnooks/src/features/comments/presentation/ui/widgets/comment_section.dart';

@RoutePage()
class EbookDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String? slug;
  final EbookModel ebook;

  const EbookDetailScreen({
    Key? key,
    required this.id,
    this.slug,
    required this.ebook, // Add this parameter
  }) : super(key: key);

  @override
  ConsumerState<EbookDetailScreen> createState() => _EbookDetailScreenState();
}

class _EbookDetailScreenState extends ConsumerState<EbookDetailScreen> {
  Timer? _statusCheckTimer;
  bool _hasCleanedUp = false;
  bool _isSummaryExpanded = false; // Initially collapsed

  @override
  void initState() {
    super.initState();

    // If we have the ebook from navigation, use it immediately
    Future.microtask(() {
      ref.read(ebookDetailProvider.notifier).setCurrentEbook(widget.ebook);
    });

    // Load comments in background
    Future.microtask(() {
      ref.read(commentsProvider(widget.id).notifier).fetchComments();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  // Use this method before navigating away
  void cleanupBeforeNavigation() {
    if (!_hasCleanedUp && mounted) {
      _hasCleanedUp = true;
      ref.read(ebookDetailProvider.notifier).clearEbookDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // CHANGE: Use watch instead of read to react to state changes
    final ebookState = ref.watch(ebookDetailProvider);
    final ebook = ebookState.ebook;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [AppColors.darkBg, AppColors.darkBg.withOpacity(0.9)]
                    : [
                      Colors.white,
                      AppColors.neutralLightGray.withOpacity(0.1),
                    ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              ebook != null
                  ? _buildDetailView(isDark, ebook)
                  : Center(
                    child: CircularProgressIndicator(
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    ),
                  ),
        ),
      ),
    );
  }

  // Update the _buildDetailView method to make it scrollable
  Widget _buildDetailView(bool isDark, EbookModel ebook) {
    return Stack(
      children: [
        CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Ensure it's scrollable
          slivers: [
            // App bar with book cover and back button
            SliverPersistentHeader(
              delegate: _EbookDetailHeaderDelegate(
                ebook: ebook,
                isDark: isDark,
                onBackPressed: cleanupBeforeNavigation, // Pass the callback
              ),
              pinned: true,
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and author info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ebook.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Published ${timeago.format(ebook.createdAt)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reading list button
                        _buildBookmarkButton(isDark, ebook, ref),

                        const SizedBox(width: 8),
                        // Like button
                        _buildLikeButton(isDark, ebook),
                      ],
                    ),

                    // ADD THE READ BUTTON HERE
                    const SizedBox(height: 24),
                    _buildReadButton(isDark, ebook),

                    const SizedBox(height: 16),

                    // Add rating component
                    _buildRatingComponent(isDark, ebook),

                    const SizedBox(height: 16),

                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ebook.tags
                              .map((tag) => _buildTag(isDark, tag))
                              .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    if (ebook.summary != null && ebook.summary!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedCrossFade(
                            firstChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ebook.summary!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _isSummaryExpanded = true,
                                      ),
                                  child: Text(
                                    'Read more',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? AppColors.neonCyan
                                              : AppColors.brandDeepGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ebook.summary!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _isSummaryExpanded = false,
                                      ),
                                  child: Text(
                                    'Show less',
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? AppColors.neonCyan
                                              : AppColors.brandDeepGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState:
                                _isSummaryExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Add comment preview section
                    _buildCommentPreview(isDark),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Add padding at the bottom to prevent overflow
            const SliverToBoxAdapter(
              child: SizedBox(height: 40), // Extra padding at the bottom
            ),
          ],
        ),

        // Add floating comment button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showComments(context, isDark),
            backgroundColor:
                isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
            child: Icon(
              MdiIcons.commentOutline,
              color: isDark ? Colors.black87 : Colors.white,
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  // Update the _buildLikeButton method for better UI feedback
  Widget _buildLikeButton(bool isDark, EbookModel ebook) {
    final isLiked = ebook.isLikedByCurrentUser ?? false;

    return Column(
      children: [
        InkWell(
          onTap: () => ref.read(ebookDetailProvider.notifier).toggleLike(),
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isLiked
                      ? (isDark
                          ? Colors.red.withOpacity(0.2)
                          : Colors.red.withOpacity(0.1))
                      : (isDark ? Colors.black26 : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isLiked
                        ? Colors.red
                        : isDark
                        ? AppColors.neonCyan.withOpacity(0.2)
                        : AppColors.brandDeepGold.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isLiked), // Key for proper animation
                color:
                    isLiked
                        ? Colors.red
                        : isDark
                        ? AppColors.neonCyan
                        : AppColors.brandDeepGold,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            '${ebook.likeCount}',
            key: ValueKey<int>(ebook.likeCount), // Key for proper animation
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color:
                  isLiked
                      ? Colors.red.shade700
                      : isDark
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Update the _buildRatingComponent for better interaction
  Widget _buildRatingComponent(bool isDark, EbookModel ebook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            // Animated rating value
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                '${ebook.averageRating.toStringAsFixed(1)} (${ebook.ratingCount})',
                key: ValueKey<String>(
                  '${ebook.averageRating}${ebook.ratingCount}',
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StarRating(
          rating: ebook.userRating?.toDouble() ?? 0.0,
          size: 32,
          color: isDark ? Colors.amber : Colors.amber.shade700,
          unratedColor: isDark ? Colors.white30 : Colors.black26,
          allowHalfStar: false, // Full stars only for rating input
          onRatingChanged: (rating) {
            // Haptic feedback for rating
            HapticFeedback.lightImpact();

            // Show subtle notification instead of snackbar
            NotificationService().showNotification(
              message: 'Rated $rating stars',
              type: NotificationType.success,
              duration: const Duration(seconds: 1),
            );

            // Call the rating function
            ref.read(ebookDetailProvider.notifier).rateEbook(rating);
          },
        ),
        const SizedBox(height: 4),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: ebook.userRating != null ? 0.0 : 1.0,
          child: Text(
            'Tap to rate',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
        if (ebook.userRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                Text(
                  'Your rating: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                Text(
                  '${ebook.userRating}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber : Colors.amber.shade800,
                  ),
                ),
                const Text(' '),
                Icon(
                  Icons.star,
                  size: 12,
                  color: isDark ? Colors.amber : Colors.amber.shade800,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTag(bool isDark, String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark
                ? AppColors.neonCyan.withOpacity(0.1)
                : AppColors.brandDeepGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? AppColors.neonCyan.withOpacity(0.3)
                  : AppColors.brandDeepGold.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
      ),
    );
  }

  // Inside _EbookDetailScreenState class, add this method at the end
  void _showComments(BuildContext context, bool isDark) {
    // Pre-load comments if not already loaded
    if (ref.read(commentsProvider(widget.id)).comments.isEmpty &&
        !ref.read(commentsProvider(widget.id)).isLoading) {
      ref.read(commentsProvider(widget.id).notifier).fetchComments();
    }

    // Create a scrim color with proper opacity like TikTok
    final scrimColor = Colors.black.withOpacity(0.5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      barrierColor: scrimColor,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: CommentSection(
              storyId: widget.id,
              backgroundColor: isDark ? AppColors.darkBg : Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Add this method to _EbookDetailScreenState class
  void _openReader(BuildContext context, bool isDark, EbookModel ebook) {
    ref.read(ebookDetailProvider.notifier);
    
    // If book is free or user is premium, open directly
    if (ebook.free || ref.read(userProvider).valueOrNull?.isPremium == true) {
      context.router.push(
        ReaderRoute(
          storyId: ebook.id,
          title: ebook.title,
          isFree: ebook.free,
          contentCount: ebook.contentCount,
          pricePerChapter: ebook.prizePerChapter.toDouble(),
          completed: ebook.completed,
        ),
      );
      return;
    }
    
    // Check if user has enough coins
    final userCoins = ref.read(userProvider).valueOrNull?.coins ?? 0;
    final totalCost = ebook.contentCount * ebook.prizePerChapter.toDouble();
    
    if (userCoins >= totalCost) {
      // Show payment confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text('This will cost $totalCost coins. Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Open in preview mode
                context.router.push(
                  ReaderRoute(
                    storyId: ebook.id,
                    title: ebook.title,
                    isFree: false,
                    contentCount: ebook.contentCount,
                    pricePerChapter: ebook.prizePerChapter.toDouble(),
                    completed: ebook.completed,
                  ),
                );
              },
              child: const Text('Preview Only'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Process payment and open reader
                final readerService = ref.read(readerServiceProvider);
                final success = await readerService.processStoryPayment(
                  ebook.id,
                  totalCost,
                );
                
                if (success) {
                  // Update user coins
                  ref.read(userProvider.notifier).refreshUser();
                  
                  // Open reader with full access
                  context.router.push(
                    ReaderRoute(
                      storyId: ebook.id,
                      title: ebook.title,
                      isFree: true, // Treat as free after purchase
                      contentCount: ebook.contentCount,
                      pricePerChapter: ebook.prizePerChapter.toDouble(),
                      completed: ebook.completed,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment failed. Please try again or add more coins.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Purchase'),
            ),
          ],
        ),
      );
    } else {
      // Not enough coins, open in preview mode
      context.router.push(
        ReaderRoute(
          storyId: ebook.id,
          title: ebook.title,
          isFree: false,
          contentCount: ebook.contentCount,
          pricePerChapter: ebook.prizePerChapter.toDouble(),
          completed: ebook.completed,
        ),
      );
    }
  }

// Add this new method for the read button
Widget _buildReadButton(bool isDark, EbookModel ebook) {
  // Determine button text based on free status and user premium status
  final userIsPremium = ref.watch(userProvider).valueOrNull?.isPremium ?? false;
  final userCoins = ref.watch(userProvider).valueOrNull?.coins ?? 0;
  final totalCost = ebook.contentCount * ebook.prizePerChapter.toDouble();
  final canAfford = userCoins >= totalCost;
  
  String buttonText = 'Read';
  if (!ebook.free && !userIsPremium) {
    buttonText = canAfford ? 'Read (${totalCost.toStringAsFixed(0)} coins)' : 'Preview';
  }
  
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: (isDark ? AppColors.neonCyan : AppColors.brandDeepGold).withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      gradient: LinearGradient(
        colors: isDark
            ? [AppColors.neonCyan, AppColors.neonCyan.withOpacity(0.8)]
            : [AppColors.brandDeepGold, AppColors.brandWarmOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openReader(context, isDark, ebook),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                MdiIcons.bookOpenPageVariant,
                color: isDark ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                buttonText,
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // If story has chapters, show chapter count
              if (ebook.contentCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ebook.contentCount} ch',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
  // Add this method to _EbookDetailScreenState class
  Widget _buildCommentPreview(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch comments for this story
        final commentsState = ref.watch(commentsProvider(widget.id));

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? AppColors.neonCyan.withOpacity(0.2)
                      : AppColors.brandDeepGold.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with comment count and view all button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Comment icon
                    Icon(
                      MdiIcons.commentOutline,
                      size: 20,
                      color:
                          isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                    ),
                    const SizedBox(width: 8),

                    // Comment count
                    Text(
                      '${commentsState.pagination.totalComments} Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const Spacer(),

                    // View all button
                    TextButton(
                      onPressed: () => _showComments(context, isDark),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View all',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? AppColors.neonCyan
                                      : AppColors.brandDeepGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color:
                                isDark
                                    ? AppColors.neonCyan
                                    : AppColors.brandDeepGold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),

              // Comment preview content
              _buildCommentPreviewContent(isDark, commentsState),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build the comment preview content
  Widget _buildCommentPreviewContent(bool isDark, CommentsState state) {
    // Show basic comment UI immediately regardless of loading state
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always show comment entry field
          InkWell(
            onTap: () => _showComments(context, isDark),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        isDark ? Colors.white24 : Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add a comment...',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // If comments are loaded, show them
          if (!state.isLoading && state.comments.isNotEmpty)
            ...state.comments
                .take(2)
                .map((comment) => _buildCommentPreviewItem(isDark, comment)),
        ],
      ),
    );
  }

  // Helper method to build a single comment preview
  Widget _buildCommentPreviewItem(bool isDark, CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
            backgroundImage:
                comment.author['photo'] != null
                    ? CachedNetworkImageProvider(comment.author['photo'])
                    : null,
            child:
                comment.author['photo'] == null
                    ? Text(
                      (comment.author['username'] as String).isNotEmpty
                          ? (comment.author['username'] as String)[0]
                              .toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    )
                    : null,
          ),

          const SizedBox(width: 12),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author and timestamp
                Row(
                  children: [
                    Text(
                      comment.author['username'] ?? 'Unknown User',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Comment text (limited to 2 lines)
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Like count and reply count
                Row(
                  children: [
                    // Like count
                    Row(
                      children: [
                        Icon(
                          comment.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color:
                              comment.isLikedByCurrentUser
                                  ? Colors.red
                                  : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${comment.likeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),

                    if (comment.replies.isNotEmpty) ...[
                      const SizedBox(width: 16),

                      // Reply count
                      Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 14,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.replies.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Update the _showComments method to trigger comment loading if needed
}

class _EbookDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  final EbookModel ebook;
  final bool isDark;
  final double maxHeight = 300.0;
  final double minHeight = 80.0;
  final VoidCallback onBackPressed; // Add this line to accept a callback

  _EbookDetailHeaderDelegate({
    required this.ebook,
    required this.isDark,
    required this.onBackPressed, // Add this parameter
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = shrinkOffset / (maxHeight - minHeight);
    final showTitle = progress > 0.5;

    return Container(
      height: maxHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cover image background
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: (1 - progress).clamp(
                0.0,
                1.0,
              ), // Clamp between 0.0 and 1.0
              child:
                  ebook.image != null && ebook.image!.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: ebook.image!,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color:
                                  isDark ? Colors.grey[850] : Colors.grey[200],
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color:
                                  isDark ? Colors.grey[850] : Colors.grey[200],
                              child: Icon(
                                MdiIcons.bookOpenPageVariant,
                                size: 80,
                                color: isDark ? Colors.white24 : Colors.black12,
                              ),
                            ),
                      )
                      : Container(
                        color: isDark ? Colors.grey[850] : Colors.grey[200],
                        child: Icon(
                          MdiIcons.bookOpenPageVariant,
                          size: 80,
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
            ),
          ),

          // Gradient overlay for better text visibility
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? AppColors.darkBg.withOpacity(
                          progress < 0.5 ? 0.8 : 1.0,
                        )
                        : Colors.white.withOpacity(progress < 0.5 ? 0.8 : 1.0),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        onBackPressed();
                        context.router.pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Title in header when scrolled
          if (showTitle)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 60,
              right: 16,
              child: Text(
                ebook.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

Widget _buildBookmarkButton(bool isDark, EbookModel ebook, WidgetRef ref) {
  final isInReadingList = ebook.isInReadingList ?? false;

  return Column(
    children: [
      InkWell(
        onTap: () => ref.read(ebookDetailProvider.notifier).toggleReadingList(),
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isInReadingList
                    ? (isDark
                        ? AppColors.neonCyan.withOpacity(0.2)
                        : AppColors.brandDeepGold.withOpacity(0.1))
                    : (isDark ? Colors.black26 : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isInReadingList
                      ? isDark
                          ? AppColors.neonCyan
                          : AppColors.brandDeepGold
                      : isDark
                      ? AppColors.neonCyan.withOpacity(0.2)
                      : AppColors.brandDeepGold.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isInReadingList
                  ? MdiIcons.bookmarkCheck
                  : MdiIcons.bookmarkOutline,
              key: ValueKey<bool>(isInReadingList),
              color:
                  isInReadingList
                      ? isDark
                          ? AppColors.neonCyan
                          : AppColors.brandDeepGold
                      : isDark
                      ? AppColors.neonCyan
                      : AppColors.brandDeepGold,
              size: 24,
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
    ],
  );
}
