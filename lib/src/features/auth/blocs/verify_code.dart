import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:novelnooks/src/common/providers/device_info_provider.dart';
import 'package:novelnooks/src/common/services/notification_service.dart';
import 'package:novelnooks/src/common/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:novelnooks/src/common/constants/dio_config.dart';
import 'package:novelnooks/src/common/constants/global_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum VerificationType {
  signUp,
  unUsualSignIn,
  resetPassword,
  forgotPassword
}

final verifyCodeProvider = ChangeNotifierProvider((ref) => VerifyCode());

class VerifyCode extends ChangeNotifier {
  String _verificationToken = '';
  bool _isResending = false;
  late VerificationType _verificationType;
  String _newPassword = '';
  String _confirmPassword = '';
  bool _passwordVisible = false;
  
  bool get isResending => _isResending;
  VerificationType get verificationType => _verificationType;
  bool get passwordVisible => _passwordVisible;

  void setVerificationType(VerificationType type) {
    _verificationType = type;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void updatePassword(String password) {
    _newPassword = password;
    notifyListeners();
  }

  void updateConfirmPassword(String password) {
    _confirmPassword = password;
    notifyListeners();
  }

  Future<void> verifyCode(BuildContext context, WidgetRef ref) async {
    switch (_verificationType) {
      case VerificationType.signUp:
        await confirmEmailAndSignUp(context, ref);
        break;
      case VerificationType.unUsualSignIn:
        await unUsualSignIn(context, ref);
        break;
      case VerificationType.resetPassword:
        await resetPassword(context, ref);
        break;
      case VerificationType.forgotPassword:
        await forgotPassword(_verificationToken, ref, context);
        break;
    }
  }

  Future<void> confirmEmailAndSignUp(BuildContext context, WidgetRef ref) async {
    try {
      final deviceInfo = ref.read(deviceInfoProvider);
      final notificationService = ref.read(notificationServiceProvider);
      ref.read(loadingProvider.notifier).state = true;
      
      final response = await DioConfig.dio?.patch(
        '/user/confirmEmailAndSignUp',
        data: {
          'token': _verificationToken,
          'deviceInfo': deviceInfo.deviceInfo,
        },
      );

      if (response?.statusCode == 200) {
        notificationService.showNotification(
          message: response?.data['message'] as String? ?? 'Email verified successfully',
          type: NotificationType.success,
          duration: const Duration(seconds: 3),
        );
        
        if (context.mounted) {
          context.router.replace(const SplashRoute());
        }
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(notificationServiceProvider).showNotification(
        message: 'Verification failed. Please try again.',
        type: NotificationType.error,
      );
    }
  }

  Future<void> unUsualSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final deviceInfo = ref.read(deviceInfoProvider);
      
      final response = await DioConfig.dio?.patch(
        '/user/unUsualSignIn',
        data: {
          'token': _verificationToken,
          'ipAddress': deviceInfo.ipAddress,
          'device': deviceInfo.deviceInfo,
        },
      );

      if (response?.statusCode == 200) {
        final token = response?.data['token'] as String?;
        if (token != null) {
          await ref.read(sharedPreferencesProvider).setString('token', token);
          if (context.mounted) {
            context.router.replace(const SplashRoute());
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendVerificationToken(String email, WidgetRef ref) async {
    try {
      _isResending = true;
      notifyListeners();

      final response = await DioConfig.dio?.post(
        '/user/resendVerificationToken',
        data: {'email': email},
      );

      _isResending = false;
      notifyListeners();

      if (response?.statusCode == 200) {
        ref.read(notificationServiceProvider).showNotification(
          message: 'Verification code resent successfully',
          type: NotificationType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _isResending = false;
      notifyListeners();
      ref.read(notificationServiceProvider).showNotification(
        message: 'Failed to resend verification code',
        type: NotificationType.error,
      );
    }
  }

 Future<void> forgotPassword(String email, WidgetRef ref, BuildContext context) async {
  try {
    ref.read(loadingProvider.notifier).state = true;
    final notificationService = ref.read(notificationServiceProvider);

    final response = await DioConfig.dio?.post(
      '/user/forgotpassword',
      data: {'email': email},
    );

    ref.read(loadingProvider.notifier).state = false;

    if (response?.statusCode == 200) {
      notificationService.showNotification(
        message: response?.data['message'] as String? ?? 'Reset link sent to your email',
        type: NotificationType.success,
        duration: const Duration(seconds: 3),
      );

      // Store email for verification
      ref.read(emailProvider.notifier).state = email;

      if (context.mounted) {
        context.router.push(
          VerificationCodeRoute(
            verificationType: VerificationType.resetPassword,
          ),
        );
      }
    }
  } catch (e) {
    ref.read(loadingProvider.notifier).state = false;
    ref.read(notificationServiceProvider).showNotification(
      message: 'Failed to send reset link',
      type: NotificationType.error,
    );
  }
}
  
  Future<void> resetPassword(BuildContext context, WidgetRef ref) async {
  try {
    if (_verificationToken.isEmpty) {
      ref.read(notificationServiceProvider).showNotification(
        message: 'Please enter the verification code',
        type: NotificationType.error,
      );
      return;
    }

    if (_newPassword.isEmpty || _confirmPassword.isEmpty) {
      ref.read(notificationServiceProvider).showNotification(
        message: 'Please enter both passwords',
        type: NotificationType.error,
      );
      return;
    }

    if (_newPassword != _confirmPassword) {
      ref.read(notificationServiceProvider).showNotification(
        message: 'Passwords do not match',
        type: NotificationType.error,
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    
    final response = await DioConfig.dio?.put(
      '/user/resetpassword',
      data: {
        'resetPasswordToken': _verificationToken,
        'newPassword': _newPassword,
      },
    );

    ref.read(loadingProvider.notifier).state = false;

    if (response?.statusCode == 200) {
      ref.read(notificationServiceProvider).showNotification(
        message: response?.data['message'] as String? ?? 'Password reset successful',
        type: NotificationType.success,
        duration: const Duration(seconds: 3),
      );

      if (context.mounted) {
        ref.read(email.notifier).state = '';
        context.router.replace(SignInRoute());
      }
    }
  } on DioException catch (error) {
    ref.read(loadingProvider.notifier).state = false;
    final notificationService = ref.read(notificationServiceProvider);

    if (error.response?.statusCode == 400) {
      final errorMessage = error.response?.data['errorMessage'] as String?;
      switch (errorMessage) {
        case 'Please provide a valid token':
          notificationService.showNotification(
            message: 'Invalid verification code',
            type: NotificationType.error,
          );
          break;
        case 'Invalid token or Session Expired':
          notificationService.showNotification(
            message: 'Verification code expired. Please request a new one',
            type: NotificationType.error,
          );
          break;
        case 'Please use a password you haven\'t used before':
          notificationService.showNotification(
            message: errorMessage ?? 'Password reset failed',
            type: NotificationType.error,
          );
          break;
        default:
          notificationService.showNotification(
            message: errorMessage ?? 'Password reset failed',
            type: NotificationType.error,
          );
      }
    } else {
      notificationService.showNotification(
        message: 'An error occurred. Please try again.',
        type: NotificationType.error,
      );
    }
  } catch (e) {
    ref.read(loadingProvider.notifier).state = false;
    ref.read(notificationServiceProvider).showNotification(
      message: 'An unexpected error occurred',
      type: NotificationType.error,
    );
  }
}

  void updateToken(String token) {
    _verificationToken = token;
    notifyListeners();
  }
}
