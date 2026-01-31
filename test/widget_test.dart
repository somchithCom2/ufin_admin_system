// UFin Admin System Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/core.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/login_page.dart';

void main() {
  group('Auth Tests', () {
    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())),
      );

      // Verify login page elements
      expect(find.text('UFin Admin System'), findsOneWidget);
      expect(find.text('Login'), findsWidgets); // AppBar title and/or button
      expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
    });

    testWidgets('Login page has email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginPage())),
      );

      // Verify text fields exist
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
  });

  group('Splash Screen Tests', () {
    testWidgets('Splash screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      // Verify splash screen elements
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      expect(find.text('UFin Admin System'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AuthState Tests', () {
    test('AuthState initial values', () {
      const state = AuthState();

      expect(state.isAuthenticated, false);
      expect(state.isInitializing, true);
      expect(state.isLoading, false);
      expect(state.token, null);
      expect(state.userId, null);
      expect(state.username, null);
      expect(state.role, null);
      expect(state.error, null);
    });

    test('AuthState copyWith works correctly', () {
      const state = AuthState();
      final newState = state.copyWith(
        isAuthenticated: true,
        token: 'test_token',
        userId: 1,
        username: 'admin',
        role: 'ADMIN',
      );

      expect(newState.isAuthenticated, true);
      expect(newState.token, 'test_token');
      expect(newState.userId, 1);
      expect(newState.username, 'admin');
      expect(newState.role, 'ADMIN');
    });

    test('AuthState isAdmin getter works', () {
      const adminState = AuthState(role: 'ADMIN');
      const userState = AuthState(role: 'USER');
      const lowercaseState = AuthState(role: 'admin');

      expect(adminState.isAdmin, true);
      expect(userState.isAdmin, false);
      expect(lowercaseState.isAdmin, true);
    });

    test('AuthState clearError works', () {
      const state = AuthState(error: 'Some error');
      final clearedState = state.clearError();

      expect(clearedState.error, null);
    });
  });
}
