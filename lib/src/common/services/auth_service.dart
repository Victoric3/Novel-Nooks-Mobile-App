import 'package:auto_route/auto_route.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/providers/cookie_jar_provider.dart';
import 'package:eulaiq/src/common/services/notification_service.dart';
import 'package:eulaiq/src/common/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final CookieJar cookieJar;

  AuthService(this.cookieJar);

  Future<bool> isAuthenticated() async {
    try {
      // Check for auth cookies across all endpoints that might set them
      final cookies = await cookieJar.loadForRequest(Uri.parse("$baseURL/$serverVersion"));
      return cookies.any((cookie) {
        if (cookie.name != 'token') return false;
        
        // Check if cookie has expired
        final expiryDate = cookie.expires;
        if (expiryDate == null) return false;
        
        return DateTime.now().isBefore(expiryDate);
      });
    } catch (e) {
      return false;
    }
  }

  Future<void> handleSessionExpired(WidgetRef ref, BuildContext context) async {
    final notificationService = ref.read(notificationServiceProvider);
    await clearAuth();
    
    notificationService.showNotification(
      message: 'Your session has expired. Please sign in again.',
      type: NotificationType.warning,
      duration: const Duration(seconds: 4),
    );

    if (context.mounted) {
      context.router.replaceAll([const IntroRoute()]);
    }
  }

  Future<void> clearAuth() async {
    await cookieJar.deleteAll();
  }
}

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final cookieJar = await ref.watch(cookieJarProvider);
  return AuthService(cookieJar);
});