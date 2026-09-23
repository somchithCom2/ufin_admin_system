import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/payments_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class _EmptyPaymentsRepo extends AdminRepository {
  _EmptyPaymentsRepo() : super(dio: Dio());

  final searches = <String?>[];
  int? recordedShopId;

  static const _shops = [
    AdminShop(id: 7, name: 'Mekong Mart', status: 'active'),
    AdminShop(id: 9, name: 'Pakse Electronics', status: 'suspended'),
  ];

  @override
  Future<PaginatedResponse<AdminShop>> getShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async {
    searches.add(search);
    final hits = _shops
        .where(
          (s) =>
              search == null ||
              s.name.toLowerCase().contains(search.toLowerCase()),
        )
        .toList();
    return PaginatedResponse(
      content: hits,
      page: 0,
      size: size,
      totalElements: hits.length,
      totalPages: 1,
      isFirst: true,
      isLast: true,
    );
  }

  @override
  Future<AdminPayment> recordPayment(
    int shopId,
    RecordPaymentRequest request,
  ) async {
    recordedShopId = shopId;
    return AdminPayment(
      id: 1,
      shopId: shopId,
      shopName: 'Mekong Mart',
      amount: request.amount,
      currency: 'LAK',
      paymentMethod: request.paymentMethod,
      status: 'completed',
      paymentDate: DateTime(2026, 9, 23),
      createdAt: DateTime(2026, 9, 23),
    );
  }

  @override
  Future<PaginatedResponse<AdminPayment>> getPayments({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentMethod,
    int? shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => const PaginatedResponse(
    content: [],
    page: 0,
    size: 20,
    totalElements: 0,
    totalPages: 0,
    isFirst: true,
    isLast: true,
  );
}

void main() {
  Future<_EmptyPaymentsRepo> openForm(WidgetTester tester) async {
    final repo = _EmptyPaymentsRepo();
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
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    return repo;
  }

  testWidgets('cancelling the record payment form does not throw', (
    tester,
  ) async {
    await openForm(tester);
    await tester.enterText(find.byType(TextFormField).first, '12');

    await tester.tap(find.text('Cancel'));
    // Pump through the close animation, where disposed controllers used to throw.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('invalid input keeps the form open with messages', (
    tester,
  ) async {
    await openForm(tester);
    await tester.tap(find.text('Record'));
    await tester.pump();

    expect(find.text('Please select a shop'), findsOneWidget);
    expect(
      find.text('Enter a positive amount with at most 2 decimals'),
      findsOneWidget,
    );
  });

  testWidgets('shop is chosen from a searchable list, not typed', (
    tester,
  ) async {
    final repo = await openForm(tester);

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();
    expect(find.text('Select shop'), findsOneWidget);
    expect(find.text('Mekong Mart'), findsOneWidget);
    expect(find.text('Pakse Electronics'), findsOneWidget);

    // Debounced search filters server-side.
    await tester.enterText(
      find.widgetWithText(TextField, 'Search by shop name, owner or phone'),
      'pakse',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(repo.searches.last, 'pakse');
    expect(find.text('Mekong Mart'), findsNothing);

    // Clear and pick.
    await tester.enterText(
      find.widgetWithText(TextField, 'Search by shop name, owner or phone'),
      '',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mekong Mart'));
    await tester.pumpAndSettle();

    expect(find.text('Select shop'), findsNothing);
    expect(find.text('#7'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '1500');
    await tester.tap(find.text('Record'));
    await tester.pumpAndSettle();

    expect(repo.recordedShopId, 7);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Payment recorded for "Mekong Mart"'), findsOneWidget);
  });
}
