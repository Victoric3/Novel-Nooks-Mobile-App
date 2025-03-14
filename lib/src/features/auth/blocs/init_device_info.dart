import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:novelnooks/src/common/common.dart';
import 'package:http/http.dart' as http;
import 'package:novelnooks/src/common/services/firebase_messaging_service.dart';

class DeviceInfoService {
  String ipAddress = '';
  String? deviceInfo;
  String? anonymousId;

  Future<void> initDeviceInfo() async {
    try {
      // Get IP Address
      final ipResponse = await http.get(Uri.parse('https://api.ipify.org'));
      if (ipResponse.statusCode == 200) {
        ipAddress = ipResponse.body;
      }

      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceType = '';
      String os = '';
      String uniqueIdentifier = '';

      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceType = 'Android';
        os = 'Android ${build.version.release}';
        uniqueIdentifier = '${build.id}-${build.manufacturer}-${build.model}';
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceType = 'iOS';
        os = '${data.systemName} ${data.systemVersion}';
        uniqueIdentifier = data.identifierForVendor ?? 
            '${data.name}-${data.model}-${data.utsname.machine}';
      }

      // Initialize Firebase Messaging
      final messagingService = await FirebaseMessagingService.create();
      final fcmToken = messagingService.fcmToken;

      final Map<String, dynamic> deviceData = {
        'deviceType': deviceType,
        'os': os,
        'appVersion': appVersion,
        'uniqueIdentifier': uniqueIdentifier,
        'fcmToken': fcmToken,
        'ipAddress': ipAddress,
      };

      deviceInfo = jsonEncode(deviceData);

    } catch (e) {
      print('Device info error: $e');
      throw Exception('Failed to get device info: $e');
    }
  }
}
