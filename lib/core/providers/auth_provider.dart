import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/core/services/secure_storage_service.dart';
import 'package:ufin_admin_system/features/auth/data/models/login_request.dart';
import 'package:ufin_admin_system/features/auth/data/repositories/auth_repository.dart';

// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth State
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthState {
  final bool isAuthenticated;
  final bool isInitializing;
  final String? token;
  final int? userId;
  final String? username;
  final String? role;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isInitializing = true,
    this.token,
    this.userId,
    this.username,
    this.role,
    this.isLoading = false,
    this.error,
  });

  /// Check if user is admin (ADMIN or SYSTEM_ADMIN)
  bool get isAdmin {
    final r = role?.toUpperCase();
    return r == 'ADMIN' || r == 'SYSTEM_ADMIN';
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isInitializing,
    String? token,
    int? userId,
    String? username,
    String? role,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Clear error
  AuthState clearError() {
    return copyWith(clearError: true);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // First check if we have a valid session (not expired)
      final hasValidSession = await SecureStorageService.hasValidSession();

      if (!hasValidSession) {
        // Session expired or no session - clear and show login
        await SecureStorageService.clearAll();
        state = state.copyWith(isInitializing: false);
        return;
      }

      final token = await SecureStorageService.getToken();
      final userId = await SecureStorageService.getUserId();
      final username = await SecureStorageService.getUserEmail();
      final role = await SecureStorageService.getRole();

      if (token != null && userId != null && role != null) {
        // Validate that user is admin (ADMIN or SYSTEM_ADMIN)
        final roleUpper = role.toUpperCase();
        if (roleUpper == 'ADMIN' || roleUpper == 'SYSTEM_ADMIN') {
          // Optionally verify session with server
          try {
            final session = await _repository.getSession();
            if (session.isAdmin) {
              state = state.copyWith(
                isAuthenticated: true,
                isInitializing: false,
                token: token,
                userId: session.userId,
                username: session.username,
                role: session.role,
              );
            } else {
              await _clearAndLogout(
                'Access denied. Admin privileges required.',
              );
            }
          } catch (e) {
            // If session check fails, use stored data (offline mode)
            state = state.copyWith(
              isAuthenticated: true,
              isInitializing: false,
              token: token,
              userId: int.tryParse(userId),
              username: username,
              role: role,
            );
          }
        } else {
          await _clearAndLogout('Access denied. Admin privileges required.');
        }
      } else {
        state = state.copyWith(isInitializing: false);
      }
    } catch (e) {
      state = state.copyWith(isInitializing: false, error: e.toString());
    }
  }

  Future<void> _clearAndLogout(String? errorMessage) async {
    await SecureStorageService.clearAll();
    DioClient.reset();
    state = AuthState(isInitializing: false, error: errorMessage);
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = LoginRequest(username: username, password: password);
      final response = await _repository.login(request);

      // Validate admin role
      if (!response.isAdmin) {
        state = state.copyWith(
          isLoading: false,
          error: 'Access denied. Admin privileges required.',
        );
        return;
      }

      // Save to secure storage
      await SecureStorageService.saveToken(response.token);
      await SecureStorageService.saveUser(
        response.userId.toString(),
        response.username,
      );
      await SecureStorageService.saveRole(response.role);

      state = state.copyWith(
        isAuthenticated: true,
        token: response.token,
        userId: response.userId,
        username: response.username,
        role: response.role,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);

      // Call logout API (ignore errors)
      try {
        await _repository.logout();
      } catch (_) {}

      // Clear local storage and reset
      await SecureStorageService.clearAll();
      DioClient.reset();
      state = const AuthState(isInitializing: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.clearError();
  }

  /// Refresh session from storage
  Future<void> refreshSession() async {
    await _initializeAuth();
  }
}
