import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/features/notifications/data/models/notification_model.dart';
import 'package:novelnooks/src/features/notifications/data/repositories/notification_repository.dart';

// State for notifications
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final int unreadCount;

  NotificationsState({
    required this.notifications,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.unreadCount,
  });

  factory NotificationsState.initial() => NotificationsState(
        notifications: [],
        isLoading: false,
        hasError: false,
        unreadCount: 0,
      );

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notifier for notifications
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationRepository _repository;

  NotificationsNotifier(this._repository) : super(NotificationsState.initial()) {
    // Load initial unread count when created
    refreshUnreadCount();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final notifications = await _repository.getNotificationHistory();
      final unreadCount = notifications.where((n) => !n.read).length;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Silently fail but keep the current count
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update the notification in state
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(read: true);
          }
          return notification;
        }).toList();

        // Update unread count
        final newUnreadCount = updatedNotifications.where((n) => !n.read).length;
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      }
    } catch (e) {
      // Handle error but don't update state
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _repository.markAllNotificationsAsRead();
      
      if (success) {
        // Mark all notifications as read
        final updatedNotifications = state.notifications.map((notification) {
          return notification.copyWith(read: true);
        }).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      // Handle error but don't update state
    }
  }

  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    
    try {
      final success = await _repository.markMultipleNotificationsAsRead(notificationIds);
      
      if (success) {
        // Update the notifications in state
        final updatedNotifications = state.notifications.map((notification) {
          if (notificationIds.contains(notification.id)) {
            return notification.copyWith(read: true);
          }
          return notification;
        }).toList();

        // Update unread count
        final newUnreadCount = updatedNotifications.where((n) => !n.read).length;
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      }
    } catch (e) {
      // Handle error but don't update state
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository);
});

// Simple provider to expose just the unread count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});