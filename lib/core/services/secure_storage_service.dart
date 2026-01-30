import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Auth tokens
  static const userTokenKey = 'user_auth_token';
  static const refreshTokenKey = 'refresh_token';

  // User data
  static const userIdKey = 'user_id';
  static const userEmailKey = 'user_email';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: userTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: userTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  static Future<void> saveUser(String userId, String email) async {
    await _storage.write(key: userIdKey, value: userId);
    await _storage.write(key: userEmailKey, value: email);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: userIdKey);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: userEmailKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }
}
