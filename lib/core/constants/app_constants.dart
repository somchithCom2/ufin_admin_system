import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  AppConstants._();

  // App Configuration from .env
  static String get appName => dotenv.env['APP_NAME'] ?? 'UFin Admin System';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // Security Configuration
  static bool get enableSecureStorage =>
      dotenv.env['ENABLE_SECURE_STORAGE']?.toLowerCase() == 'true';
  static String get secureStorageKey =>
      dotenv.env['SECURE_STORAGE_KEY'] ?? 'ufin_secure_key';
  static String get userTokenStorageKey =>
      dotenv.env['USER_TOKEN_STORAGE_KEY'] ?? 'user_auth_token';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts (in milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Cache
  static const int cacheMaxAge = 7; // days
  static const int cacheMaxSize = 100; // MB

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  // File
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'txt',
  ];
}
