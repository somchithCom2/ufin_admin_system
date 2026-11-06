import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscriptions_list_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/upgrade_requests_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/work_queue_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/work_queue_card.dart';

PaginatedResponse<T> _page<T>(List<T> rows, {int? total}) => PaginatedResponse(
  content: rows,
  page: 0,
  size: rows.length,
  totalElements: total ?? rows.length,
  totalPages: 1,
  isFirst: true,
  isLast: true,
);

UpgradeRequestDto _request(int id, String shop, String plan) =>
    UpgradeRequestDto(
      id: id,
      shopId: id,
      shopName: shop,
      fromPlanCode: 'free',
      fromPlanName: const {'en': 'Free'},
      toPlanCode: plan.toLowerCase(),
      toPlanName: {'en': plan},
      billingCycle: 'monthly',
      status: 'PENDING',
      requestedByUsername: 'owner',
      createdAt: DateTime(2026, 11, 1),
      updatedAt: DateTime(2026, 11, 1),
    );

class _Repository implements AdminRepository {
  int pending = 3;
  List<AdminSubscription> expiring = const [
    AdminSubscription(
      id: 2,
      shopId: 2,
      shopName: 'Noy Cafe',
      planName: 'Silver',
      status: 'active',
      autoRenew: true,
      daysUntilExpiry: 5,
    ),
    AdminSubscription(
      id: 1,
      shopId: 1,
      shopName: 'Mekong Mart',
      planName: 'Free',
      status: 'trial',
      daysUntilExpiry: 1,
    ),
  ];
  int lapsed = 12;
  bool expiringFails = false;
  bool freeSells = false;
  final List<String?> subscriptionStatuses = [];

  @override
  Future<PaginatedResponse<UpgradeRequestDto>> getUpgradeRequests({
    int page = 0,
    int size = 20,
    String? status,
  }) async => _page([
    if (pending > 0) _request(1, 'Lao Bakery', 'Gold'),
  ], total: pending);

  @override
  Future<List<AdminSubscription>> getExpiringAdminSubscriptions({
    int days = 7,
  }) async {
    if (expiringFails) throw Exception('ERR_INTERNAL_SERVER_ERROR');
    return expiring;
  }

  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
    String? planCode,
    bool paid = false,
    String? search,
  }) async {
    subscriptionStatuses.add(status);
    return _page(const [], total: status == 'expired' ? lapsed : 0);
  }

  @override
  Future<List<AdminPlan>> getPlans() async => [
    AdminPlan(
      id: 1,
      code: 'free',
      name: 'Free',
      features: {'sales': freeSells},
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignedIn extends StateNotifier<AuthState> implements AuthNotifier {
  _SignedIn()
    : super(const AuthState(isAuthenticated: true, username: 'admin'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Repository repository;
  setUp(() => repository = _Repository());

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [adminRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('work queue', () {
    test('splits trials from paid plans, soonest first', () async {
      final c = container();
      await c.read(workQueueProvider.notifier).refresh(force: true);
      final q = c.read(workQueueProvider).queue!;

      expect(q.pendingRequests, 3);
      expect(q.expiring!.map((s) => s.shopName), ['Mekong Mart', 'Noy Cafe']);
      expect(q.trialsEnding.single.shopName, 'Mekong Mart');
      expect(q.paidExpiring.single.shopName, 'Noy Cafe');
      expect(q.lapsed, 12);
      expect(q.freeWithholdsSales, isTrue);
      expect(q.isClear, isFalse);
    });

    test('a failing part leaves the others and is reported', () async {
      repository.expiringFails = true;
      final c = container();
      await c.read(workQueueProvider.notifier).refresh(force: true);
      final q = c.read(workQueueProvider).queue!;

      expect(q.expiring, isNull);
      expect(q.isPartial, isTrue);
      expect(q.isClear, isFalse);
      expect(q.pendingRequests, 3);
      expect(q.lapsed, 12);
    });

    test('a free plan that sells does not lock lapsed shops', () async {
      repository.freeSells = true;
      final c = container();
      await c.read(workQueueProvider.notifier).refresh(force: true);
      expect(c.read(workQueueProvider).queue!.freeWithholdsSales, isFalse);
    });
  });

  Future<ProviderContainer> pumpCard(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = container();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: WorkQueueCard())),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return c;
  }

  testWidgets('lists what needs attention and fits a phone', (tester) async {
    await pumpCard(tester);

    expect(find.text('3 upgrade requests waiting for review'), findsOneWidget);
    expect(find.text('Lao Bakery → Gold and 2 more'), findsOneWidget);
    expect(find.text('1 trial ending within 7 days'), findsOneWidget);
    expect(find.text('Ends tomorrow'), findsOneWidget);
    expect(find.text('1 plan ending within 7 days'), findsOneWidget);
    expect(find.text('Silver · auto-renew on'), findsOneWidget);
    expect(find.text('12 shops lapsed to Free'), findsOneWidget);
    expect(
      find.textContaining('cannot open new bills until a plan is paid'),
      findsNWidgets(2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Review opens Upgrade Requests on Pending', (tester) async {
    final c = await pumpCard(tester);
    // The shell keeps the section alive in the app; here the test does.
    c.listen(adminSectionProvider, (_, _) {});
    await tester.tap(find.widgetWithText(FilledButton, 'Review'));
    await tester.pump();

    expect(c.read(adminSectionProvider), AdminSection.upgradeRequests);
    expect(c.read(upgradeRequestsShowPendingProvider), isTrue);
  });

  testWidgets('lapsed shops open Subscriptions on Expired, all plans', (
    tester,
  ) async {
    final c = await pumpCard(tester);
    c.listen(adminSectionProvider, (_, _) {});
    await tester.tap(find.widgetWithText(FilledButton, 'View'));
    await tester.pump();

    expect(c.read(adminSectionProvider), AdminSection.subscriptions);
    expect(c.read(subscriptionsListPresetProvider), (
      status: 'expired',
      plan: SubscriptionPlanFilter.all,
    ));
  });

  testWidgets('says so when nothing is waiting', (tester) async {
    repository
      ..pending = 0
      ..expiring = const []
      ..lapsed = 0;
    await pumpCard(tester);

    expect(find.text('Nothing needs you right now'), findsOneWidget);
  });

  testWidgets('a failed part offers a retry', (tester) async {
    repository.expiringFails = true;
    await pumpCard(tester);

    expect(find.text("Couldn't load expiring plans."), findsOneWidget);
    repository.expiringFails = false;
    await tester.tap(find.widgetWithText(TextButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load expiring plans."), findsNothing);
    expect(find.text('1 trial ending within 7 days'), findsOneWidget);
  });

  testWidgets('the subscriptions list opens with a preset and clears it', (
    tester,
  ) async {
    final c = container();
    c.read(subscriptionsListPresetProvider.notifier).state = (
      status: 'expired',
      plan: SubscriptionPlanFilter.all,
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: SubscriptionsListPage()),
      ),
    );
    await tester.pumpAndSettle();

    // The page's own load, not the default "Paid, any status".
    expect(repository.subscriptionStatuses.last, 'expired');
    expect(c.read(subscriptionsListPresetProvider), isNull);
    // The status chip names the preset's filter.
    expect(find.widgetWithText(FilterButton, 'Expired'), findsOneWidget);
  });

  testWidgets('the sidebar counts requests and expiring plans', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminRepositoryProvider.overrideWithValue(repository),
          authStateProvider.overrideWith((ref) => _SignedIn()),
        ],
        child: const MaterialApp(home: AdminShell()),
      ),
    );
    await tester.pumpAndSettle();

    // The nav tiles say their counts to screen readers too.
    expect(
      find.bySemanticsLabel(RegExp(r'^Upgrade Requests, 3 waiting')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Subscriptions, 2 expiring soon')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp(r'^Plans')), findsOneWidget);
    semantics.dispose();
  });
}
