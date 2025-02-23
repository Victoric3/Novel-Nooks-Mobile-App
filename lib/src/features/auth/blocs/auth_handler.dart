import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/constants/dio_config.dart';
import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:eulaiq/src/features/auth/blocs/init_device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInState extends ChangeNotifier {
  final emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  String _email = '';
  String _password = '';
  String _firstname = '';
  String _lastname = '';
  String birthdate = '';
  final List<String> interests = [];
  double? _latitude;
  double? _longitude;
  String _ipAddress = '';
  String _deviceType = '';
  String _os = '';
  String _uniqueIdentifier = '';
  bool _passwordVisible = false;

  bool get passwordVisibility => _passwordVisible;
  bool _continue = false;
  bool get continueButtonEnabled => _continue;

  final String _appVersion = appVersion;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void validateForm(String value, String fieldName) {
    if (fieldName == 'email') {
      _email = value;
    } else if (fieldName == 'password') {
      _password = value;
    }

    final bool isValidEmail = emailRegExp.hasMatch(_email);
    final bool isValidPassword = _password.isNotEmpty;

    _continue = isValidEmail && isValidPassword;
    notifyListeners();
  }

  void collectFormData(String value, String fieldName) {
    if (fieldName == 'firstname') {
      _firstname = value;
    } else if (fieldName == 'lastname') {
      _lastname = value;
    } else if(fieldName == 'birthdate'){
      birthdate = value;
    } else if(fieldName == "interests"){
      interests.add(value);
    }
    _continue = _firstname.isNotEmpty && _lastname.isNotEmpty;
    notifyListeners();
  }

  Future<void> signIn(BuildContext context, WidgetRef ref) async {
    try {
      ref.read(loadingProvider.notifier).state = true;
      ref.read(errorProvider.notifier).state = null;
      ref.read(successProvider.notifier).state = null;
      ref.read(statusProvider.notifier).state = null;
      ref.read(email.notifier).state = _email;
      ref.read(statusCodeProvider.notifier).state = null;

      await _deviceInfoService.initDeviceInfo();
      _latitude = _deviceInfoService.latitude;
      _longitude = _deviceInfoService.longitude;
      _ipAddress = _deviceInfoService.ipAddress;
      _deviceType = _deviceInfoService.deviceType;
      _os = _deviceInfoService.os;
      _uniqueIdentifier = _deviceInfoService.uniqueIdentifier;

      final response = await DioConfig.dio?.post('/user/login', data: {
        'identity': _email.trim(),
        'password': _password.trim(),
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
        setMessages(ref, successMessage: responseData['message'] as String?);
        ref.read(statusCodeProvider.notifier).state = 200;
        // ignore: use_build_context_synchronously
        // context.router.replaceAll([const HomeRoute()]);
      }
    } on DioException catch (error) {
      print("Dio error: $error");
      print("Response data: ${error.response?.data}");
      print("Status code: ${error.response?.statusCode}");
      ref.read(loadingProvider.notifier).state = false;

      if (error.response?.statusCode == 401 &&
          error.response?.data['status'] == "temporary user") {
        // ignore: use_build_context_synchronously
        context.router.push(SignUpRoute());
      } else if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 404) {
        ref.read(statusCodeProvider.notifier).state =
            error.response?.statusCode;
        ref.read(statusProvider.notifier).state =
            error.response?.data['status'] as String?;
        setMessages(ref,
            errorMessage: error.response?.data['errorMessage'] as String?);
        // ignore: use_build_context_synchronously
        context.router.push(const ConfirmationCodeInputRoute());
      } else if (error.response?.statusCode == 500) {
        setMessages(ref,
            errorMessage:
                'Please ensure that your internet connection is stable');
      }
    }
  }

  Future<void> signUp(BuildContext context, WidgetRef ref) async {
    ref.read(loadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;
    ref.read(successProvider.notifier).state = null;
    try {
      final response = await DioConfig.dio?.post(
        '/user/register',
        data: {
          'firstname': _firstname,
          'lastname': _lastname,
          'birthdate': birthdate,
          'interests': interests,
          'email': _email,
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
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseData = response?.data;

      if (response?.statusCode == 200) {
        ref.read(loadingProvider.notifier).state = false;
        setMessages(ref, successMessage: responseData['message'] as String?);
        // ignore: use_build_context_synchronously
        // context.router.replaceAll([const HomeRoute()]);
      }
    } on DioException catch (error) {
      ref.read(loadingProvider.notifier).state = false;
      setMessages(ref,
          errorMessage: error.response?.data['errorMessage'] as String?);
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 404) {
        ref.read(statusCodeProvider.notifier).state =
            error.response?.statusCode;
        ref.read(statusProvider.notifier).state =
            error.response?.data['status'] as String?;
        // ignore: use_build_context_synchronously
        context.router.push(const ConfirmationCodeInputRoute());
      } else if (error.response?.statusCode == 500) {
        setMessages(ref,
            errorMessage:
                'Please ensure that your internet connection is stable');
      }
    }
  }
}

// Define the provider
final signInProvider = ChangeNotifierProvider<SignInState>((ref) {
  return SignInState();
});
