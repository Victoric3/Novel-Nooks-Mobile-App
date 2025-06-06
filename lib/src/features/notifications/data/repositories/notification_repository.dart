import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/features/notifications/data/models/notification_model.dart';

class NotificationRepository {
  // Remove direct dependency on Dio instance
  NotificationRepository();

  Future<List<NotificationModel>> getNotificationHistory() async {
    try {
      // Use DioConfig.dio? pattern instead of direct _dio
      final response = await DioConfig.dio?.get('/notification/history');
      
      if (response?.statusCode == 200) {
        final List<dynamic> data = response?.data['data'] ?? [];
        return data.map((item) => NotificationModel.fromJson(item)).toList();
      }
      
      throw Exception('Failed to fetch notifications');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await DioConfig.dio?.patch('/notification/read/$notificationId');
      return response?.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await DioConfig.dio?.patch('/notification/read-all');
      return response?.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<bool> markMultipleNotificationsAsRead(List<String> notificationIds) async {
    try {
      final response = await DioConfig.dio?.patch(
        '/notification/read-multiple',
        data: {'notificationIds': notificationIds},
      );
      return response?.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark multiple notifications as read: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await DioConfig.dio?.get('/notification/unread-count');
      
      if (response?.statusCode == 200) {
        return response?.data['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      // Silently fail but return 0
      return 0;
    }
  }
}

// Update the provider to create the repository without passing Dio
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});