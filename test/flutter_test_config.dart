import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/l10n/tr.dart';

/// The app opens in Lao, but most tests assert English strings, dates and
/// error messages. Every test starts in English; Lao rendering and the Lao
/// default are covered explicitly in test/l10n/lao_ui_test.dart.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() => AppLanguage.current = AppLanguage.en);
  await testMain();
}
