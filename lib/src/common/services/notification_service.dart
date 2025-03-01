import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eulaiq/src/common/widgets/notification_card.dart';

class NotificationService extends ChangeNotifier {
  final List<NotificationCard> _notifications = [];
  List<NotificationCard> get notifications => _notifications;

  void showNotification({
    required String message,
    required NotificationType type,
    Duration? duration,
  }) {
    // Create a reference holder
    NotificationCard? notificationRef;
    
    void dismissNotification() {
      if (notificationRef != null) {
        _notifications.remove(notificationRef);
        notifyListeners();
      }
    }

    // Create the notification with the dismiss callback
    final notification = NotificationCard(
      message: message,
      type: type,
      duration: duration ?? const Duration(seconds: 4),
      onDismiss: dismissNotification,
    );

    // Assign the reference
    notificationRef = notification;
    
    // Add to notifications list
    _notifications.add(notification);
    notifyListeners();
  }
}

final notificationServiceProvider = ChangeNotifierProvider((ref) {
  return NotificationService();
});