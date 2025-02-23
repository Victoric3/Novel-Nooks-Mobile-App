import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  double? latitude;
  double? longitude;
  String ipAddress = '';
  String deviceType = '';
  String os = '';
  String uniqueIdentifier = '';

  Future<void> initDeviceInfo() async {
    try {
        
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceType = 'Android';
        os = 'Android ${build.version.release}';
        uniqueIdentifier = '${build.id}-${build.manufacturer}-${build.model}';
        
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceType = 'iOS';
        os = '${data.systemName} ${data.systemVersion}';
        uniqueIdentifier = data.identifierForVendor ?? '${data.name}-${data.model}-${data.utsname.machine}';
      }

      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            ipAddress = addr.address;
            break;
          }
        }
        if (ipAddress.isNotEmpty) break;
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to get device info: $e');
    }
  }
}
