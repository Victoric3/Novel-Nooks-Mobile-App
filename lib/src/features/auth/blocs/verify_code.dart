import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/constants/dio_config.dart';
import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:eulaiq/src/features/auth/blocs/init_device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyCode {
  String? _token;
  double? _latitude;
  double? _longitude;
  String _ipAddress = '';
  String _deviceType = '';
  String _os = '';
  String _uniqueIdentifier = '';
  final String _appVersion = appVersion;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  // Collect form data
  Future<void> collectFormData(data) async {
    _token = data['token'] as String?;
  }

  // Verify unusual sign-in
  Future<void> verifyUnUsualsignIn(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;
    setMessages(ref); // Clear previous messages

    try {
      await _deviceInfoService.initDeviceInfo();
      _latitude = _deviceInfoService.latitude;
      _longitude = _deviceInfoService.longitude;
      _ipAddress = _deviceInfoService.ipAddress;
      _deviceType = _deviceInfoService.deviceType;
      _os = _deviceInfoService.os;
      _uniqueIdentifier = _deviceInfoService.uniqueIdentifier;

      final response = await DioConfig.dio?.patch('/user/unUsualSignIn', data: {
        'token': _token,
        'location': {
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'ipAddress': _ipAddress,
        'deviceInfo': {
          'deviceType': _deviceType,
          'os': _os,
          'appVersion': _appVersion,
          'uniqueIdentifier': _uniqueIdentifier,
        },
      });

      final responseData = response?.data;
      if (response?.statusCode == 200) {
        ref.read(loadingProvider.notifier).state = false;
        setMessages(ref, successMessage: responseData['message']);
        // context.router.replace(const HomeRoute());
      }
    } on DioException catch (error) {
      ref.read(loadingProvider.notifier).state = false;
      setMessages(ref, errorMessage: '${error.response?.data['errorMessage']}');
      if (error.response?.statusCode == 500) {
        setMessages(ref, errorMessage: 'Please ensure that your internet connection is stable');
      }
    }
  }

  // Resend verification token
  Future<void> resendverificationtoken(BuildContext context, WidgetRef ref) async {
    final email = 'ref.watch(email)';
    try {
      final response = await DioConfig.dio?.post('/user/resendVerificationToken', data: {
        'email': email,
      });
      final responseData = response?.data;
      if (response?.statusCode == 200) {
        setMessages(ref, successMessage: responseData['message']);
      }
    } on DioException catch (error) {
      setMessages(ref, errorMessage: '${error.response?.data['errorMessage']}');
      if (error.response?.statusCode == 500) {
        setMessages(ref, errorMessage: 'Please ensure that your internet connection is stable');
      }
    }
  }

  // Confirm email
  Future<void> confirmEmail(BuildContext context, WidgetRef ref) async {
    try {
      final response = await DioConfig.dio?.patch('/user/confirmEmailAndSignUp', data: {
        'token': _token,
      });
      final responseData = response?.data;
      if (response?.statusCode == 200) {
        setMessages(ref, successMessage: '${responseData['message']}, finish creating your account');
        context.router.replace(SignUpRoute());
      }
    } on DioException catch (error) {
      setMessages(ref, errorMessage: '${error.response?.data['errorMessage']}');
      if (error.response?.statusCode == 500) {
        setMessages(ref, errorMessage: 'Please ensure that your internet connection is stable');
      }
    }
  }
}
