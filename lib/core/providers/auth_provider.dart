import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/services/secure_storage_service.dart';

// Auth State
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? userId;
  final String? email;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.userId,
    this.email,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? userId,
    String? email,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await SecureStorageService.getToken();
      final userId = await SecureStorageService.getUserId();
      final email = await SecureStorageService.getUserEmail();

      if (token != null && userId != null) {
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          userId: userId,
          email: email,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement actual login API call
      // For now, mock implementation
      await Future.delayed(const Duration(seconds: 2));

      const token = 'mock_token_12345';
      const userId = 'user_123';

      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUser(userId, email);

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId,
        email: email,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await SecureStorageService.clearAll();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement actual register API call
      await Future.delayed(const Duration(seconds: 2));

      const token = 'mock_token_12345';
      const userId = 'user_123';

      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUser(userId, email);

      state = state.copyWith(
        isAuthenticated: true,
        token: token,
        userId: userId,
        email: email,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
