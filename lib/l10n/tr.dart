import 'package:flutter/widgets.dart';

/// Languages the console ships in. Order is the order shown in pickers.
enum AppLanguage {
  en(Locale('en'), 'English'),
  lo(Locale('lo'), 'ລາວ');

  final Locale locale;

  /// The language's own name; never translated so users can always find it.
  final String nativeName;

  const AppLanguage(this.locale, this.nativeName);

  /// The console's language until the user picks another: first launch,
  /// a missing or unreadable preference, or an unsupported locale.
  static const AppLanguage fallback = lo;

  static AppLanguage fromCode(String? code) => switch (code) {
    'en' => en,
    'lo' => lo,
    _ => fallback,
  };

  /// Mirror of the active language for code with no [BuildContext]
  /// (providers, error mapping). Kept in sync by the settings notifier.
  /// Widgets must use `context.language` so they rebuild on change.
  static AppLanguage current = fallback;

  static List<Locale> get supportedLocales => [
    for (final l in values) l.locale,
  ];
}

/// One user-facing string in every supported language.
///
/// Both languages are required positional arguments, so a missing
/// translation is a compile error rather than a silent English fallback.
@immutable
final class Tr {
  final String en;
  final String lo;

  const Tr(this.en, this.lo);

  String get(AppLanguage language) => switch (language) {
    AppLanguage.en => en,
    AppLanguage.lo => lo,
  };

  /// Resolves against the widget tree's locale and subscribes to changes.
  String of(BuildContext context) => get(context.language);

  /// Resolves against [AppLanguage.current]; for non-widget code only.
  String get current => get(AppLanguage.current);

  /// True when [query] occurs in either language (case-insensitive).
  bool matches(String query) {
    final q = query.toLowerCase();
    return en.toLowerCase().contains(q) || lo.contains(q);
  }

  @override
  String toString() => en;
}

extension L10nContextX on BuildContext {
  /// The active language. Depends on [Localizations], so the caller
  /// rebuilds when the user switches language.
  AppLanguage get language =>
      AppLanguage.fromCode(Localizations.maybeLocaleOf(this)?.languageCode);

  String tr(Tr text) => text.get(language);

  /// Locale name for `intl` formatters, e.g. `DateFormat('d MMM', ctx.localeName)`.
  /// English uses `en_US`, whose symbols intl bundles without initialization.
  String get localeName => switch (language) {
    AppLanguage.en => 'en_US',
    AppLanguage.lo => 'lo',
  };
}
