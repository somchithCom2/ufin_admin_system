import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/core.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/settings/app_settings.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'fake_repo.dart';

class _SignedIn extends StateNotifier<AuthState> implements AuthNotifier {
  _SignedIn() : super(const AuthState(isAuthenticated: true, username: 'somchith'));
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Host extends ConsumerWidget {
  const _Host();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(Brightness.light, s.language),
      darkTheme: AppTheme.of(Brightness.dark, s.language),
      themeMode: s.themeMode,
      locale: s.language.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: const AdminShell(),
    );
  }
}

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
  }
  await loader.load();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await _font('Roboto', ['/System/Library/Fonts/Supplemental/Arial.ttf', '/System/Library/Fonts/Supplemental/Arial Bold.ttf']);
    await _font('NotoSansLao', ['assets/fonts/NotoSansLao-Regular.ttf', 'assets/fonts/NotoSansLao-SemiBold.ttf']);
  });
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost');
    FlutterSecureStorage.setMockInitialValues({});
  });
  final only = Platform.environment['SHOT_ONLY'];
  final lang = Platform.environment['SHOT_LANG'] ?? 'en';
  for (final section in AdminSection.values) {
    if (only != null && !only.split(',').contains(section.name)) continue;
    for (final (tag, width) in [('phone', 390.0), ('desktop', 1280.0)]) {
      testWidgets('${section.name} $tag', (tester) async {
        tester.view.physicalSize = Size(width * 2, 860 * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({'ui.language': lang, 'ui.themeMode': 'light'});
        final p = await SharedPreferences.getInstance();
        await tester.pumpWidget(ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(p),
            adminRepositoryProvider.overrideWithValue(FakeRepo()),
            authStateProvider.overrideWith((ref) => _SignedIn()),
            adminSectionProvider.overrideWith((ref) => section),
          ],
          child: const _Host(),
        ));
        await tester.pumpAndSettle();
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() async {
            await precacheAppIcons();
            await Future<void>.delayed(const Duration(milliseconds: 200));
          });
          await tester.pump();
        }
        await tester.pumpAndSettle();
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(Uri.file('/private/tmp/claude-501/-Users-somchithdouangboupha-Ufin-ufin-admin-system/8fd8559a-ca9b-4779-a4f1-c7fa31878e23/scratchpad/pages/${section.name}_${tag}_$lang.png')));
      });
    }
  }
}
