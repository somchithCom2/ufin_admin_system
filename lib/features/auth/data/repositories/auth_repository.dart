import 'package:dio/dio.dart';
import 'package:ufin_admin_system/core/constants/api_constants.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/features/auth/data/models/login_request.dart';
import 'package:ufin_admin_system/features/auth/data/models/login_response.dart';
import 'package:ufin_admin_system/features/auth/data/models/session_response.dart';

/// Repository for handling authentication API calls
class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  /// Login with username and password
  /// Returns [LoginResponse] on success
  /// Throws [ApiException] on failure
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      // API returns wrapped response: {success: true, data: {...}}
      final responseData = response.data;
      if (responseData['success'] == true && responseData['data'] != null) {
        return LoginResponse.fromJson(responseData['data']);
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Login failed',
          statusCode: responseData['status'],
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Logout current user
  /// Throws [ApiException] on failure
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      // Ignore logout errors - we'll clear local storage anyway
      if (e.response?.statusCode != 401) {
        throw ApiException.fromDioException(e);
      }
    }
  }

  /// Get current session info
  /// Returns [SessionResponse] on success
  /// Throws [ApiException] on failure
  Future<SessionResponse> getSession() async {
    try {
      final response = await _dio.get(ApiConstants.session);
      return SessionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Refresh auth token
  /// Returns new token on success
  /// Throws [ApiException] on failure
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      return response.data['token'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
