import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ufin_admin_system/core/constants/api_constants.dart';
import 'package:ufin_admin_system/core/services/secure_storage_service.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.timeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.timeout),
        sendTimeout: Duration(milliseconds: ApiConstants.timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Reset the Dio instance (useful after logout)
  static void reset() {
    _dio = null;
  }
}

/// Interceptor to add auth token to requests
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login endpoint
    if (!options.path.contains('/login')) {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Token expired, clear storage
      SecureStorageService.clearAll();
    }
    handler.next(err);
  }
}

/// Logging interceptor for debug mode
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint('│ 🌐 REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint('└─────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint(
      '│ ✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
    );
    debugPrint('│ Data: ${response.data}');
    debugPrint('└─────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌─────────────────────────────────────────────────────────');
    debugPrint(
      '│ ❌ ERROR: ${err.response?.statusCode} ${err.requestOptions.uri}',
    );
    debugPrint('│ Message: ${err.message}');
    debugPrint('│ Response: ${err.response?.data}');
    debugPrint('└─────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.badResponse:
        message =
            _parseErrorMessage(error.response?.data) ??
            'Server error occurred. Please try again.';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'An unexpected error occurred. Please try again.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  static String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['msg'] as String?;
    }
    return null;
  }

  @override
  String toString() => message;
}
