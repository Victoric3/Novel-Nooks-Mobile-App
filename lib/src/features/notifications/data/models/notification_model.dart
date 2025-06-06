import 'package:equatable/equatable.dart';

enum NotificationType {
  info,
  warning,
  error,
  success,
}

enum NotificationStatus {
  sent,
  delivered,
  failed,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationStatus status;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseNotificationType(json['type']),
      status: _parseNotificationStatus(json['status']),
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'warning':
        return NotificationType.warning;
      case 'error':
        return NotificationType.error;
      case 'success':
        return NotificationType.success;
      case 'info':
      default:
        return NotificationType.info;
    }
  }

  static NotificationStatus _parseNotificationStatus(String? status) {
    switch (status) {
      case 'delivered':
        return NotificationStatus.delivered;
      case 'failed':
        return NotificationStatus.failed;
      case 'sent':
      default:
        return NotificationStatus.sent;
    }
  }

  @override
  List<Object?> get props => [id, title, body, type, status, read, createdAt, data];

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationStatus? status,
    bool? read,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      status: status ?? this.status,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}