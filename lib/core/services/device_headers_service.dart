import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceHeadersService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceHeaders() async {
    try {
      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();
      final deviceType = Platform.isAndroid ? 'Android' : 'iOS';
      final osVersion = await _getOsVersion();

      return {
        'X-Device-ID': deviceId,
        'X-Device-Name': deviceName,
        'X-Device-Type': deviceType,
        'X-OS-Version': osVersion,
      };
    } catch (e) {
      return {
        'X-Device-ID': 'unknown',
        'X-Device-Name': 'unknown',
        'X-Device-Type': Platform.isAndroid ? 'Android' : 'iOS',
        'X-OS-Version': 'unknown',
      };
    }
  }

  static Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
    } catch (e) {
      return 'unknown';
    }
    return 'unknown';
  }

  static Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      return 'unknown';
    }
    return 'unknown';
  }

  static Future<String> _getOsVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.systemVersion;
      }
    } catch (e) {
      return 'unknown';
    }
    return 'unknown';
  }
}
