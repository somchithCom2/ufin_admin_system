import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/core.dart';
import 'package:ufin_admin_system/core/settings/app_settings.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/auth/presentation/pages/login_page.dart';

PaginatedResponse<T> _page<T>(List<T> rows, {int total = 0}) =>
    PaginatedResponse(
      content: rows,
      page: 0,
      size: rows.length,
      totalElements: total,
      totalPages: 1,
      isFirst: true,
      isLast: true,
    );

/// Answers the calls the shell, dashboard and work queue make on start.
class _Repository implements AdminRepository {
  @override
  Future<AdminDashboardStats> getDashboardStats() async =>
      AdminDashboardStats.fromJson({
        'totalShops': 120,
        'activeShops': 100,
        'totalUsers': 300,
        'activeUsers': 250,
        'totalSubscriptions': 110,
        'activeSubscriptions': 90,
      });

  @override
  Future<PaginatedResponse<UpgradeRequestDto>> getUpgradeRequests({
    int page = 0,
    int size = 20,
    String? status,
  }) async => _page(const [], total: 2);

  @override
  Future<List<AdminSubscription>> getExpiringAdminSubscriptions({
    int days = 7,
  }) async => const [
    AdminSubscription(
      id: 1,
      shopId: 1,
      shopName: 'ຮ້ານມີໄຊ',
      planName: 'Free',
      status: 'trial',
      daysUntilExpiry: 1,
    ),
  ];

  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
    String? planCode,
    bool paid = false,
    String? search,
  }) async => _page(const [], total: 4);

  @override
  Future<List<AdminPlan>> getPlans() async => const [
    AdminPlan(id: 1, code: 'free', name: 'Free'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignedIn extends StateNotifier<AuthState> implements AuthNotifier {
  _SignedIn()
    : super(const AuthState(isAuthenticated: true, username: 'somchith'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The app's real localization and theme wiring, driven by settings.
class _Host extends ConsumerWidget {
  final Widget home;
  const _Host(this.home);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appSettingsProvider);
    return MaterialApp(
      theme: AppTheme.of(Brightness.light, s.language),
      darkTheme: AppTheme.of(Brightness.dark, s.language),
      themeMode: s.themeMode,
      locale: s.language.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }
}

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=http://localhost');
    FlutterSecureStorage.setMockInitialValues({});
  });
  tearDown(() => AppLanguage.current = AppLanguage.en);

  Future<void> pumpShell(
    WidgetTester tester, {
    required double width,
    Map<String, Object> prefs = const {'ui.language': 'lo'},
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final p = await _prefs(prefs);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          adminRepositoryProvider.overrideWithValue(_Repository()),
          authStateProvider.overrideWith((ref) => _SignedIn()),
        ],
        child: const _Host(AdminShell()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Translations', () {
    test('Tr resolves per language and matches either', () {
      const t = Tr('Shops', 'ຮ້ານຄ້າ');
      expect(t.get(AppLanguage.en), 'Shops');
      expect(t.get(AppLanguage.lo), 'ຮ້ານຄ້າ');
      expect(t.matches('shop'), isTrue);
      expect(t.matches('ຮ້ານ'), isTrue);
      expect(t.matches('plan'), isFalse);
    });

    test('backend error codes read in the active language', () {
      expect(
        ErrorMessages.lookup('ERR_SHOP_NOT_FOUND', AppLanguage.en),
        'Shop not found.',
      );
      expect(
        ErrorMessages.lookup('ERR_SHOP_NOT_FOUND', AppLanguage.lo),
        'ບໍ່ພົບຮ້ານ.',
      );
      AppLanguage.current = AppLanguage.lo;
      expect(friendlyError('ERR_SHOP_NOT_FOUND'), 'ບໍ່ພົບຮ້ານ.');
      expect(friendlyError(null), CommonText.somethingWrong.lo);
    });

    test('raw backend statuses get a translated label', () {
      expect(StatusText.lookup('EXPIRING_SOON')?.lo, 'ໃກ້ໝົດອາຍຸ');
      expect(StatusText.lookup('grace-period')?.en, 'Grace period');
      expect(StatusText.lookup('something_new'), isNull);
    });
  });

  group('Settings', () {
    test('restores saved theme, language and sidebar', () async {
      final p = await _prefs({
        'ui.themeMode': 'dark',
        'ui.language': 'lo',
        'ui.sidebarCollapsed': true,
      });
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(p)],
      );
      addTearDown(c.dispose);
      final s = c.read(appSettingsProvider);
      expect(s.themeMode, ThemeMode.dark);
      expect(s.language, AppLanguage.lo);
      expect(s.sidebarCollapsed, isTrue);
      expect(AppLanguage.current, AppLanguage.lo);
    });

    test('first launch opens in Lao and writes nothing', () async {
      final p = await _prefs({});
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(p)],
      );
      addTearDown(c.dispose);
      final s = c.read(appSettingsProvider);
      expect(s.language, AppLanguage.lo);
      expect(s.themeMode, ThemeMode.system);
      expect(AppLanguage.current, AppLanguage.lo);
      expect(p.getKeys(), isEmpty);
    });

    test('persists changes and ignores unknown stored values', () async {
      final p = await _prefs({'ui.themeMode': 'sepia', 'ui.language': 'xx'});
      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(p)],
      );
      addTearDown(c.dispose);
      final s = c.read(appSettingsProvider);
      expect(s.themeMode, ThemeMode.system);
      expect(s.language, AppLanguage.lo);

      c.read(appSettingsProvider.notifier)
        ..setThemeMode(ThemeMode.light)
        ..setLanguage(AppLanguage.en)
        ..toggleSidebar();
      expect(p.getString('ui.themeMode'), 'light');
      expect(p.getString('ui.language'), 'en');
      expect(p.getBool('ui.sidebarCollapsed'), isTrue);
      expect(AppLanguage.current, AppLanguage.en);

      // A fresh start (next launch) reads the saved choice back.
      final next = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(p)],
      );
      addTearDown(next.dispose);
      expect(next.read(appSettingsProvider).language, AppLanguage.en);
      expect(next.read(appSettingsProvider).sidebarCollapsed, isTrue);
    });

    test('works without a preferences store', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(appSettingsProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(c.read(appSettingsProvider).themeMode, ThemeMode.dark);
    });
  });

  group('Lao UI', () {
    testWidgets('login renders in Lao and switches back to English', (
      tester,
    ) async {
      final p = await _prefs({'ui.language': 'lo'});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(p)],
          child: const _Host(LoginPage()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ຍິນດີຕ້ອນຮັບກັບຄືນ'), findsOneWidget);
      expect(find.text('ເຂົ້າສູ່ລະບົບ'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(p.getString('ui.language'), 'en');
    });

    for (final width in [360.0, 900.0, 1280.0]) {
      testWidgets('shell fits at ${width.toInt()} px in Lao', (tester) async {
        await pumpShell(tester, width: width);
        // Overflow is reported as a framework exception and fails here.
        expect(tester.takeException(), isNull);
        expect(find.text('ພາບລວມ'), findsWidgets);
      });
    }

    testWidgets('phone: bottom bar, More sheet and section switch', (
      tester,
    ) async {
      await pumpShell(tester, width: 390);
      expect(find.byType(NavigationBar), findsOneWidget);

      // Short tab label; the word also appears elsewhere on the dashboard.
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('ອື່ນໆ'),
        ),
      );
      await tester.pumpAndSettle();
      // Every section is reachable from the sheet, grouped as in the sidebar.
      expect(find.text('ສະຖິຕິ'), findsOneWidget);
      expect(find.text('ການເງິນ'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('ສະຖິຕິ'));
      await tester.pumpAndSettle();
      // The section behind "More" now names the last tab.
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('ສະຖິຕິ'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('desktop: sidebar collapses and remembers it', (tester) async {
      // No saved preferences: the shell opens in Lao.
      await pumpShell(tester, width: 1280, prefs: const {});
      expect(find.text('ຄົ້ນຫາ ຫຼື ໄປທີ່…'), findsOneWidget);

      await tester.tap(find.byTooltip('ຫຍໍ້ແຖບຂ້າງ'));
      await tester.pumpAndSettle();
      expect(find.text('ຄົ້ນຫາ ຫຼື ໄປທີ່…'), findsNothing);
      final saved = await SharedPreferences.getInstance();
      expect(saved.getBool('ui.sidebarCollapsed'), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark theme renders the shell', (tester) async {
      await pumpShell(
        tester,
        width: 1280,
        prefs: const {'ui.themeMode': 'dark', 'ui.language': 'lo'},
      );
      final context = tester.element(find.byType(AdminShell));
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(tester.takeException(), isNull);
    });
  });
}
