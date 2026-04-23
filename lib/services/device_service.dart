import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
class DeviceService {
  final SharedPreferences _prefs;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static const String _guestModeKey = 'guest_mode';
  static const String _userDeviceKey = 'user_device_';

  DeviceService(this._prefs);

  Future<String> _getDeviceId() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? iosInfo.model;
    }
    return 'unknown_device';
  }

  Future<void> saveDeviceForUser(String userId) async {
    final deviceId = await _getDeviceId();
    await _prefs.setString('$_userDeviceKey$userId', deviceId);
  }

  Future<bool> validateDeviceForUser(String userId) async {
    final savedDeviceId = _prefs.getString('$_userDeviceKey$userId');
    if (savedDeviceId == null) return false;
    
    final currentDeviceId = await _getDeviceId();
    return savedDeviceId == currentDeviceId;
  }

  Future<void> saveGuestModeStatus(bool isGuest) async {
    await _prefs.setBool(_guestModeKey, isGuest);
  }

  Future<bool> getGuestModeStatus() async {
    return _prefs.getBool(_guestModeKey) ?? false;
  }

  Future<void> clearDeviceData() async {
    final keys = _prefs.getKeys();
    for (var key in keys) {
      if (key.startsWith(_userDeviceKey) || key == _guestModeKey) {
        await _prefs.remove(key);
      }
    }
  }
}