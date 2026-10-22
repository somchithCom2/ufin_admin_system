import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/change_plan_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/revenue_report_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/statistics_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/subscription_days_form.dart';

const _yearly = AdminSubscription(
  id: 1,
  shopId: 5,
  shopName: 'Mekong Mart',
  planId: 1,
  planCode: 'free',
  planName: 'Free',
  status: 'active',
  billingCycle: 'yearly',
);

class _Repository extends AdminRepository {
  _Repository() : super(dio: Dio());

  ChangePlanRequest? changed;
  int? changedShop;
  int? fetchedShop;

  @override
  Future<List<AdminPlan>> getPlans() async => const [
    AdminPlan(id: 1, code: 'free', name: 'Free', maxEmployees: 1),
    AdminPlan(
      id: 2,
      code: 'pro',
      name: 'Pro',
      priceMonthly: 100000,
      priceYearly: 960000,
      maxProducts: 0,
    ),
  ];

  @override
  Future<AdminSubscription> changePlan(
    int shopId,
    ChangePlanRequest request,
  ) async {
    changedShop = shopId;
    changed = request;
    return _yearly;
  }

  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
  }) async => const PaginatedResponse(
    content: [_yearly],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isFirst: true,
    isLast: true,
  );

  @override
  Future<AdminSubscriptionStats> getSubscriptionStatistics() async =>
      AdminSubscriptionStats.fromJson({});

  @override
  Future<List<ExpiringSubscription>> getExpiringSubscriptions({
    int days = 30,
  }) async => [
    ExpiringSubscription(
      id: 1,
      shopId: 5,
      shopName: 'Mekong Mart',
      planCode: 'free',
      planName: 'Free',
      status: 'active',
      endDate: DateTime.now().add(const Duration(days: 2)),
      daysUntilExpiry: 2,
    ),
  ];

  @override
  Future<AdminRevenueReport> getRevenueReport({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
    String? currency,
  }) async => AdminRevenueReport.fromJson({
    'startDate': '2026-09-22',
    'endDate': '2026-10-22',
    'currency': 'LAK',
    'availableCurrencies': ['LAK', 'USD'],
    'totalRevenue': 12500000,
    'totalTransactions': 40,
    'successfulTransactions': 38,
    'failedTransactions': 2,
    'revenueByPeriod': [
      for (var d = 1; d <= 31; d++)
        {
          'period': '2026-10-${d.toString().padLeft(2, '0')}',
          'revenue': d * 10000,
          'transactionCount': 1,
        },
    ],
    'revenueByPlan': {'Diamond business plan': 9000000, 'PRO': 3500000},
    'paymentCountByPlan': {'Diamond business plan': 10, 'PRO': 28},
    'revenueByPaymentMethod': {'bank_transfer': 12000000, 'cash': 500000},
  });

  @override
  Future<AdminSubscription> getSubscriptionByShop(int shopId) async {
    fetchedShop = shopId;
    return _yearly;
  }
}

Widget _app(Widget home, [AdminRepository? repository]) => ProviderScope(
  overrides: [
    adminRepositoryProvider.overrideWithValue(repository ?? _Repository()),
  ],
  child: MaterialApp(home: home),
);

void main() {
  group('Extend / reduce form', () {
    Future<List<(int, String?)>> open(
      WidgetTester tester, {
      required bool reduce,
      Object? failWith,
    }) async {
      final saved = <(int, String?)>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSubscriptionDaysForm(
                  context,
                  reduce: reduce,
                  shopName: 'Mekong Mart',
                  save: (days, reason) async {
                    if (failWith != null) throw failWith;
                    saved.add((days, reason));
                  },
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      return saved;
    }

    Finder days(String label) => find.widgetWithText(TextFormField, label);

    testWidgets('refuses zero and out-of-range days instead of guessing', (
      tester,
    ) async {
      final saved = await open(tester, reduce: false);
      await tester.enterText(days('Days to add'), '0');
      await tester.tap(find.widgetWithText(FilledButton, 'Extend'));
      await tester.pumpAndSettle();
      expect(find.text('Enter 1 to 3650 days'), findsOneWidget);

      await tester.enterText(days('Days to add'), '');
      await tester.tap(find.widgetWithText(FilledButton, 'Extend'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a whole number of days'), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(days('Days to add'), '45');
      await tester.tap(find.widgetWithText(FilledButton, 'Extend'));
      await tester.pumpAndSettle();
      expect(saved, [(45, null)]);
      expect(find.text('Extend subscription'), findsNothing);
    });

    testWidgets('reduce needs a reason, shown in the form', (tester) async {
      final saved = await open(tester, reduce: true);
      await tester.tap(find.widgetWithText(FilledButton, 'Reduce'));
      await tester.pumpAndSettle();
      expect(find.text('Reason is required'), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Reason'),
        'Refund',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Reduce'));
      await tester.pumpAndSettle();
      expect(saved, [(7, 'Refund')]);
    });

    testWidgets('a failed save keeps the form open with the reason', (
      tester,
    ) async {
      await open(
        tester,
        reduce: false,
        failWith: Exception('ERR_NO_ACTIVE_SUBSCRIPTION'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Extend'));
      await tester.pumpAndSettle();
      expect(find.text('Extend subscription'), findsOneWidget);
      expect(find.textContaining('subscription'), findsWidgets);
    });
  });

  group('Change plan', () {
    testWidgets('starts on the yearly cycle and prices plans for it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const ChangePlanPage(subscription: _yearly)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('${MoneyFormat.format(960000, 'LAK')} / year'),
        findsOneWidget,
      );
      expect(find.text('Saves 20%'), findsOneWidget);
      // Null is unlimited; zero is a real limit.
      expect(find.text('1 employees · Unlimited products'), findsOneWidget);
      expect(find.text('Unlimited employees · 0 products'), findsOneWidget);
    });

    testWidgets('says the change applies now and sends the chosen cycle', (
      tester,
    ) async {
      final repository = _Repository();
      await tester.pumpWidget(
        _app(const ChangePlanPage(subscription: _yearly), repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pro'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Applies immediately'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Upgrade plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Upgrade'));
      await tester.pumpAndSettle();

      expect(repository.changedShop, 5);
      expect(repository.changed?.newPlanCode, 'pro');
      expect(repository.changed?.billingCycle, 'annual');
    });
  });

  testWidgets('an expiring subscription opens its detail page', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(const StatisticsPage(), repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expiring'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekong Mart'));
    await tester.pumpAndSettle();

    expect(repository.fetchedShop, 5);
    expect(find.byType(SubscriptionDetailPage), findsOneWidget);
  });

  group('Layout fits phone and desktop widths', () {
    final pages = <String, Widget>{
      'change plan': const ChangePlanPage(subscription: _yearly),
      'subscription detail': const SubscriptionDetailPage(
        subscription: _yearly,
      ),
      'statistics': const StatisticsPage(),
      'revenue report': const RevenueReportPage(),
    };
    for (final width in [360.0, 1280.0]) {
      for (final MapEntry(key: name, value: page) in pages.entries) {
        testWidgets('$name at ${width.toInt()} px', (tester) async {
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(_app(page));
          await tester.pumpAndSettle();
          // Overflow is reported as a framework exception and fails here.
          expect(tester.takeException(), isNull);
        });
      }
    }
    testWidgets('statistics expiring tab at 360 px', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_app(const StatisticsPage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expiring'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
