import 'package:cookie_jar/cookie_jar.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/providers/cookie_jar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final CookieJar cookieJar;
  final SharedPreferences prefs;

  AuthService(this.cookieJar, this.prefs);

  Future<bool> isAuthenticated() async {
    // Check for auth token in SharedPreferences
    final token = prefs.getString('auth_token');
    if (token != null) return true;

    // Check for auth cookies
    final cookies = await cookieJar.loadForRequest(Uri.parse('https://api.eulaiq.com'));
    return cookies.any((cookie) {
      if (cookie.name != 'auth_cookie') return false;
      
      // Check if cookie has expired
      final expiryDate = cookie.expires;
      if (expiryDate == null) return false;
      
      return DateTime.now().isBefore(expiryDate);
    });
  }

  Future<void> clearAuth() async {
    await prefs.remove('auth_token');
    await cookieJar.deleteAll();
  }
}

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final cookieJar = await ref.watch(cookieJarProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(cookieJar, prefs);
});