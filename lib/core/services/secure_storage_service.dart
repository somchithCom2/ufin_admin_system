import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Auth tokens
  static const userTokenKey = 'user_auth_token';
  static const refreshTokenKey = 'refresh_token';

  // User data
  static const userIdKey = 'user_id';
  static const userEmailKey = 'user_email';
  static const userRoleKey = 'user_role';

  // Session expiry
  static const loginTimestampKey = 'login_timestamp';
  static const sessionDurationHours = 24;

  // Token methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: userTokenKey, value: token);
    // Save login timestamp
    await _storage.write(
      key: loginTimestampKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
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

  // User methods
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

  // Role methods
  static Future<void> saveRole(String role) async {
    await _storage.write(key: userRoleKey, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: userRoleKey);
  }

  // Session expiry methods
  static Future<bool> isSessionValid() async {
    final timestampStr = await _storage.read(key: loginTimestampKey);
    if (timestampStr == null) return false;

    final loginTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestampStr),
    );
    final now = DateTime.now();
    final difference = now.difference(loginTime);

    return difference.inHours < sessionDurationHours;
  }

  // Clear methods
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

  // Check if user is logged in with valid session
  static Future<bool> hasValidSession() async {
    final token = await getToken();
    final userId = await getUserId();
    final role = await getRole();
    final isValid = await isSessionValid();
    return token != null && userId != null && role != null && isValid;
  }
}
