import 'package:intl/intl.dart';
import 'package:ufin_admin_system/l10n/tr.dart';

/// `DateFormat` in the active language, cached per pattern and language.
///
/// Month and weekday names follow [AppLanguage.current]; screens rebuild on
/// a language switch, so formatting at build time always matches the UI.
abstract final class AppDateFormat {
  static final Map<(String, AppLanguage), DateFormat> _cache = {};

  static DateFormat of(String pattern) {
    final language = AppLanguage.current;
    return _cache.putIfAbsent(
      (pattern, language),
      () => DateFormat(pattern, switch (language) {
        AppLanguage.en => 'en_US',
        AppLanguage.lo => 'lo',
      }),
    );
  }
}
