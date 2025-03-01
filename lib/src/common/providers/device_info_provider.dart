import 'package:eulaiq/src/features/auth/blocs/init_device_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceInfoProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService();
});