import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/payments_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

/// Worst-case rows: long names, huge amounts, every optional pill.
class _Repo extends AdminRepository {
  _Repo() : super(dio: Dio());

  /// Filters from the most recent getPayments call.
  ({
    String? status,
    String? method,
    int? shopId,
    DateTime? start,
    DateTime? end,
  })?
  last;

  @override
  Future<PaginatedResponse<AdminShop>> getShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async => const PaginatedResponse(
    content: [AdminShop(id: 7, name: 'Mekong Mart', status: 'active')],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isFirst: true,
    isLast: true,
  );

  @override
  Future<PaginatedResponse<AdminPayment>> getPayments({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentMethod,
    int? shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    last = (
      status: status,
      method: paymentMethod,
      shopId: shopId,
      start: startDate,
      end: endDate,
    );
    final day = DateTime(2026, 9, 1, 14, 30);
    AdminPayment p(int id, String status, {DateTime? applied}) => AdminPayment(
      id: id,
      shopId: 1,
      shopName: 'Vientiane Central Coffee House & Bakery (Branch 2)',
      amount: 987654321000,
      currency: 'LAK',
      paymentMethod: 'bank_transfer',
      status: status,
      referenceNumber: 'INV-1758612345678-AB12',
      paymentDate: day,
      createdAt: day,
      appliedAt: applied,
      billingPeriodEnd: applied?.add(const Duration(days: 30)),
    );
    return PaginatedResponse(
      content: [
        p(1, 'completed'),
        p(2, 'completed', applied: day),
        p(3, 'refunded'),
      ],
      page: 0,
      size: size,
      totalElements: 1234567,
      totalPages: 3,
      isFirst: true,
      isLast: false,
    );
  }
}

Finder _menuItem(String text) => find.widgetWithText(MenuItemButton, text);

void main() {
  testWidgets('payment list fits a small phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(_Repo())],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const PaymentsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Payments'), findsWidgets);
    expect(find.text('Applied → 1 Oct 2026'), findsOneWidget);
  });

  Future<_Repo> pumpPage(
    WidgetTester tester, {
    Size size = const Size(420, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PaymentsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('status and method menus filter and show readable values', (
    tester,
  ) async {
    final repo = await pumpPage(tester);

    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Completed'));
    await tester.pumpAndSettle();
    expect(repo.last!.status, 'completed');

    await tester.tap(find.text('Method'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Bank transfer'));
    await tester.pumpAndSettle();
    expect(repo.last!.method, 'bank_transfer');
    expect(repo.last!.status, 'completed', reason: 'filters combine');

    // Active chips show values, not raw codes, and offer Clear all.
    expect(find.text('bank_transfer'), findsNothing);
    expect(find.byTooltip('Clear all filters'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear Status filter'));
    await tester.pumpAndSettle();
    expect(repo.last!.status, isNull);
    expect(repo.last!.method, 'bank_transfer');
    expect(find.byTooltip('Clear all filters'), findsNothing);
  });

  testWidgets('date preset "Today" sends a single-day range', (tester) async {
    final repo = await pumpPage(tester);
    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Today'));
    await tester.pumpAndSettle();

    final today = DateUtils.dateOnly(DateTime.now());
    expect(repo.last!.start, today);
    expect(repo.last!.end, today);
    // The chip names the preset instead of repeating the dates.
    expect(find.text('Today'), findsOneWidget);
    // Active filters move to the front so they can't scroll out of view.
    expect(
      tester.getRect(find.text('Today')).left,
      lessThan(tester.getRect(find.text('Shop')).left),
    );
  });

  testWidgets('shop filter uses the searchable picker', (tester) async {
    final repo = await pumpPage(tester);
    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekong Mart'));
    await tester.pumpAndSettle();

    expect(repo.last!.shopId, 7);
    expect(find.text('Mekong Mart'), findsOneWidget);

    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();
    await tester.tap(_menuItem('Pending'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear all filters'));
    await tester.pumpAndSettle();
    expect(repo.last!.shopId, isNull);
    expect(repo.last!.status, isNull);
    expect(find.text('Shop'), findsOneWidget);
  });
}
