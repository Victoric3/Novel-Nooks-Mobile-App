import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/common/theme/app_theme.dart';
import 'package:novelnooks/src/features/library/data/models/ebook_model.dart';
import 'package:novelnooks/src/features/notifications/data/models/notification_model.dart';
import 'package:novelnooks/src/features/notifications/presentation/providers/notification_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

@RoutePage()
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        elevation: 0.5,
        actions: [
          if (state.notifications.any((n) => !n.read))
            IconButton(
              icon: Icon(
                MdiIcons.checkAll,
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
              onPressed: () {
                _showMarkAllAsReadDialog(context);
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              ),
            )
          : state.hasError
              ? _buildErrorState(context, state.errorMessage ?? 'Failed to fetch notifications')
              : _buildNotificationList(context, state.notifications),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.red[300] : Colors.red,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(notificationsProvider.notifier).fetchNotifications();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, List<NotificationModel> notifications) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.bellOffOutline,
              size: 64,
              color: isDark ? Colors.white30 : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll receive notifications about activity\nrelated to your account and books',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsProvider.notifier).fetchNotifications();
      },
      color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark ? Colors.white12 : Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(context, notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: isDark ? AppColors.neonCyan.withOpacity(0.2) : AppColors.brandDeepGold.withOpacity(0.1),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          notification.read ? MdiIcons.bellOffOutline : MdiIcons.bellCheck,
          color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
        ),
      ),
      confirmDismiss: (direction) async {
        if (notification.read) {
          // Already read, nothing to do
          return false;
        }
        // Mark as read when swiped
        await ref.read(notificationsProvider.notifier).markAsRead(notification.id);
        return false; // Don't actually dismiss the item
      },
      child: InkWell(
        onTap: () {
          _handleNotificationTap(notification);
        },
        child: Container(
          color: !notification.read
              ? (isDark ? AppColors.neonCyan.withOpacity(0.05) : AppColors.brandDeepGold.withOpacity(0.05))
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type, isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!notification.read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
                          ),
                        ),
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, bool isDark) {
    IconData icon;
    Color color;
    
    switch (type) {
      case NotificationType.warning:
        icon = MdiIcons.alertCircleOutline;
        color = Colors.orange;
        break;
      case NotificationType.error:
        icon = MdiIcons.alertOutline;
        color = Colors.red;
        break;
      case NotificationType.success:
        icon = MdiIcons.checkCircleOutline;
        color = Colors.green;
        break;
      case NotificationType.info:
      icon = MdiIcons.informationOutline;
        color = isDark ? AppColors.neonCyan : AppColors.brandDeepGold;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(
        icon,
        size: 24,
        color: color,
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
  // Mark notification as read if not already
  if (!notification.read) {
    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
  }
  
  // If there's data in the notification, handle navigation
  if (notification.data != null) {
    final data = notification.data!;
    final route = data['route'] as String?;
    
    switch (route) {
      case 'book_detail':
        final storyId = data['storyId'] as String?;
        
        if (storyId != null) {
          _fetchAndNavigateToEbook(storyId);
        }
        break;
        
      case 'view_profile':
        // Navigate to profile screen
        context.router.push(const MeRoute());
        break;
        
      case 'view_security':
        // Navigate to security settings in Me screen
        context.router.push(const MeRoute());
        break;
        
      default:
        // Just stay on notifications page for other types
        break;
    }
  }
}

  Future<void> _fetchAndNavigateToEbook(String storyId) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        color: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
      ),
    ),
  );
  
  try {
    // Use Dio directly to fetch the ebook data
    final response = await DioConfig.dio!.get('/ebook/$storyId');
    
    // Pop loading dialog
    Navigator.pop(context);
    
    if (response.statusCode == 200 && response.data['success'] == true) {
      // Convert response data to EbookModel
      final ebookData = response.data['data'];
      
      final ebook = EbookModel(
        id: ebookData['_id'],
        title: ebookData['title'],
        author: ebookData['author']['username'] ?? '',
        authorId: ebookData['author']['_id'],
        summary: ebookData['summary'],
        image: ebookData['image'],
        createdAt: DateTime.parse(ebookData['createdAt']),
        updatedAt: DateTime.parse(ebookData['updatedAt']),
        completed: ebookData['completed'] ? true : false,
        likeCount: ebookData['likeCount'] ?? 0,
        commentCount: ebookData['commentCount'] ?? 0,
        ratingCount: ebookData['ratingCount'] ?? 0,
        averageRating: ebookData['averageRating']?.toDouble() ?? 0.0,
        contentCount: ebookData['contentCount'] ?? 0,
        isLikedByCurrentUser: ebookData['likeStatus'] ?? false,
        isInReadingList: ebookData['isInReadingList'] ?? false,
        tags: List<String>.from(ebookData['tags'] ?? []),
      );
      
      // Navigate to book detail with the fetched data
      context.router.push(EbookDetailRoute(id: storyId, ebook: ebook));
    } else {
      // Show error if the response is not successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load book details: ${response.data['message'] ?? 'Unknown error'}')),
      );
    }
  } catch (error) {
    // Pop loading dialog
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${error.toString()}')),
    );
  }
}

  void _showMarkAllAsReadDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        title: Text(
          'Mark all as read?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'This will mark all your notifications as read.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.neonCyan : AppColors.brandDeepGold,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );
  }
}