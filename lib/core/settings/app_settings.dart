import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufin_admin_system/l10n/tr.dart';

/// User interface preferences. Not secret, so they live in shared
/// preferences rather than secure storage, which is wiped on sign-out.
@immutable
class AppSettings {
  final ThemeMode themeMode;
  final AppLanguage language;

  /// Desktop sidebar shows icons only.
  final bool sidebarCollapsed;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.en,
    this.sidebarCollapsed = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? sidebarCollapsed,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.language == language &&
      other.sidebarCollapsed == sidebarCollapsed;

  @override
  int get hashCode => Object.hash(themeMode, language, sidebarCollapsed);
}

/// Loaded once in `main` and injected with an override. Left `null` in tests
/// and previews, where settings then live in memory only.
final sharedPreferencesProvider = Provider<SharedPreferences?>((_) => null);

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _themeKey = 'ui.themeMode';
  static const _languageKey = 'ui.language';
  static const _sidebarKey = 'ui.sidebarCollapsed';
  static final _log = Logger();

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final storedTheme = prefs?.getString(_themeKey);
    final storedLanguage = prefs?.getString(_languageKey);
    final settings = AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == storedTheme,
        orElse: () => ThemeMode.system,
      ),
      // First launch follows the device: a Lao phone opens in Lao.
      language: AppLanguage.fromCode(
        storedLanguage ?? PlatformDispatcher.instance.locale.languageCode,
      ),
      sidebarCollapsed: prefs?.getBool(_sidebarKey) ?? false,
    );
    AppLanguage.current = settings.language;
    return settings;
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == state.themeMode) return;
    state = state.copyWith(themeMode: mode);
    _persist(() => _prefs?.setString(_themeKey, mode.name));
  }

  void setLanguage(AppLanguage language) {
    if (language == state.language) return;
    AppLanguage.current = language;
    state = state.copyWith(language: language);
    _persist(() => _prefs?.setString(_languageKey, language.name));
  }

  void toggleSidebar() {
    final collapsed = !state.sidebarCollapsed;
    state = state.copyWith(sidebarCollapsed: collapsed);
    _persist(() => _prefs?.setBool(_sidebarKey, collapsed));
  }

  /// The state change already applied; a failed write only loses the
  /// preference on next launch, so it is logged rather than surfaced.
  void _persist(Future<bool>? Function() write) {
    final future = write();
    future?.catchError((Object e) {
      _log.w('Could not save UI preference', error: e);
      return false;
    });
  }
}
