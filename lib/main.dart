import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufin_admin_system/config/routes/app_routes.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/core.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/settings/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Decode the SVG icons while the startup reads below run, so the first
  // screen paints them without an empty-slot flash. Never blocks startup.
  unawaited(precacheAppIcons());

  // Independent startup reads run together.
  final results = await Future.wait<Object?>([
    dotenv.load(fileName: '.env'),
    // Lao and English date symbols for `DateFormat(pattern, locale)`.
    initializeDateFormatting(),
    _loadPreferences(),
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          results[2] as SharedPreferences?,
        ),
      ],
      child: const UfinAdminApp(),
    ),
  );
}

/// Preferences are a convenience: if the platform store is unavailable the
/// app still starts, with settings kept in memory for the session.
Future<SharedPreferences?> _loadPreferences() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    Logger().w('Preferences unavailable; using defaults', error: e);
    return null;
  }
}

class UfinAdminApp extends ConsumerWidget {
  const UfinAdminApp({super.key});

  static const _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final router = ref.watch(goRouterProvider);
    final settings = ref.watch(appSettingsProvider);
    final language = settings.language;
    final light = AppTheme.of(Brightness.light, language);
    final dark = AppTheme.of(Brightness.dark, language);

    // Show splash screen while initializing
    if (authState.isInitializing) {
      return MaterialApp(
        title: 'UFin Admin',
        theme: light,
        darkTheme: dark,
        themeMode: settings.themeMode,
        locale: language.locale,
        supportedLocales: AppLanguage.supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'UFin Admin',
      theme: light,
      darkTheme: dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 220),
      locale: language.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: _localizationsDelegates,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
