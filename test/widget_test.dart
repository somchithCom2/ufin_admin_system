// UFin Admin System Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/core.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/login_page.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost');
    FlutterSecureStorage.setMockInitialValues({});
  });
  group('Auth Tests', () {
    Future<void> pumpLogin(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await pumpLogin(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('Login page has username and password fields', (
      WidgetTester tester,
    ) async {
      await pumpLogin(tester);

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login validates empty fields before submitting', (
      WidgetTester tester,
    ) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '');
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Password visibility toggles', (WidgetTester tester) async {
      await pumpLogin(tester);

      EditableText password() => tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(EditableText),
        ),
      );
      expect(password().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(password().obscureText, isFalse);
    });
  });

  group('Splash Screen Tests', () {
    testWidgets('Splash screen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const SplashScreen()),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('UFin Admin'), findsOneWidget);
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
