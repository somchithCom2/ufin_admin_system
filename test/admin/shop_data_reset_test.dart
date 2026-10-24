import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/shops_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

Map<String, dynamic> _reset({required bool done}) => {
  'shopId': 7,
  'shopName': 'Test Café',
  'done': done,
  'rows': {
    'kitchen_order_items': 0,
    'transaction_items': 1200,
    'transaction_payments': 300,
    'transactions': 290,
    'customers': 4,
    'product_variants': 0,
    'products': 85,
    'categories': 9,
  },
  'totalRows': 1888,
  'files': 40,
  'filesFailed': done ? 2 : 0,
};

/// Admin console side of the shop data reset: the requests it sends, what it
/// shows before and after, and that a mistyped name sends nothing.
void main() {
  group('repository contract', () {
    late Dio dio;
    late AdminRepository repository;
    final requests = <RequestOptions>[];
    dynamic responseBody;

    setUp(() {
      requests.clear();
      dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              requests.add(options);
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: responseBody,
                ),
              );
            },
          ),
        );
      repository = AdminRepository(dio: dio);
    });
    tearDown(() => dio.close());

    test('preview is a GET that changes nothing', () async {
      responseBody = {'success': true, 'data': _reset(done: false)};
      final preview = await repository.previewShopDataReset(7);

      expect(requests.single.method, 'GET');
      expect(requests.single.path, '/admin/shops/7/data-reset/preview');
      expect(preview.done, isFalse);
      expect(preview.totalRows, 1888);
      expect(preview.rows['products'], 85);
    });

    test('reset posts the typed name and reason', () async {
      responseBody = {'success': true, 'data': _reset(done: true)};
      final result = await repository.resetShopData(
        7,
        const ResetShopDataRequest(
          confirmShopName: 'Test Café',
          reason: 'keyed wrong',
        ),
      );

      expect(requests.single.method, 'POST');
      expect(requests.single.path, '/admin/shops/7/data-reset');
      expect(requests.single.data, {
        'confirmShopName': 'Test Café',
        'reason': 'keyed wrong',
      });
      expect(result.done, isTrue);
    });

    test('a conflict reads as a sentence that says nothing was removed', () {
      final text = friendlyError(
        ApiException(message: 'ERR_SHOP_DATA_RESET_CONFLICT'),
      );
      expect(text, isNot(contains('ERR_')));
      expect(text, contains('Nothing was removed'));
    });
  });

  test('files are optional, and a shop with only pictures is not empty', () {
    final unreachable = ShopDataReset.fromJson({
      'shopId': 7,
      'rows': {'products': 0},
      'totalRows': 0,
    });
    expect(unreachable.files, isNull);
    expect(unreachable.filesFailed, 0);
    expect(unreachable.isEmpty, isTrue);
    expect(
      ShopDataReset.fromJson({
        'shopId': 7,
        'rows': {'products': 0},
        'totalRows': 0,
        'files': 3,
      }).isEmpty,
      isFalse,
    );
  });

  test('summary names what an operator knows and folds the rest', () {
    final reset = ShopDataReset.fromJson(_reset(done: false));
    expect(reset.summary, [
      ('Categories', 9),
      ('Products', 85),
      ('Orders', 290),
      ('Customers', 4),
      ('Linked records', 1500),
    ]);
    expect(
      ShopDataReset.fromJson({
        'shopId': 7,
        'rows': {'products': 0},
        'totalRows': 0,
      }).summary,
      isEmpty,
    );
  });

  group('shops page', () {
    testWidgets('a live shop offers reset, a deleted one does not', (
      tester,
    ) async {
      await _openShops(tester, _ResetRepo());

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      expect(find.text('Reset data…'), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      expect(find.text('Reset data…'), findsNothing);
    });

    testWidgets('the form shows what will go before anything is sent', (
      tester,
    ) async {
      final repo = _ResetRepo();
      await _openReset(tester, repo);

      expect(repo.previews, [7]);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('Linked records'), findsOneWidget);
      expect(find.text('1,888'), findsOneWidget);
      expect(find.text('Pictures in storage'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(repo.resets, isEmpty);
    });

    testWidgets('a mistyped shop name sends nothing', (tester) async {
      final repo = _ResetRepo();
      await _openReset(tester, repo);

      await _fill(tester, name: 'Test Cafe', reason: 'keyed wrong');
      expect(find.text('Does not match "Test Café"'), findsOneWidget);
      expect(repo.resets, isEmpty);
    });

    testWidgets('a confirmed reset is sent and its counts shown', (
      tester,
    ) async {
      final repo = _ResetRepo();
      await _openReset(tester, repo);

      await _fill(tester, name: ' Test Café ', reason: 'products keyed wrong');

      final sent = repo.resets.single;
      expect(sent.$1, 7);
      expect(sent.$2.confirmShopName, 'Test Café');
      expect(sent.$2.reason, 'products keyed wrong');
      expect(find.text('Shop data reset'), findsOneWidget);
      expect(
        find.text('"Test Café" is empty and ready to be keyed in again.'),
        findsOneWidget,
      );
      expect(
        find.text(
          '2 pictures could not be deleted from storage. Nothing shows them '
          'any more.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a refused reset keeps the form open with the reason', (
      tester,
    ) async {
      final repo = _ResetRepo()..refuseWith = 'ERR_SHOP_DATA_RESET_CONFLICT';
      await _openReset(tester, repo);

      await _fill(tester, name: 'Test Café', reason: 'keyed wrong');

      expect(find.textContaining('Nothing was removed'), findsOneWidget);
      expect(find.text('Shop data reset'), findsNothing);
    });

    testWidgets('the form fits a phone screen', (tester) async {
      await _openReset(tester, _ResetRepo(), size: const Size(390, 844));
      expect(find.text('Reset shop data'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}

class _ResetRepo extends AdminRepository {
  _ResetRepo() : super(dio: Dio());

  final previews = <int>[];
  final resets = <(int, ResetShopDataRequest)>[];
  String? refuseWith;

  static final _shops = [
    const AdminShop(id: 7, name: 'Test Café', status: 'active'),
    AdminShop(
      id: 8,
      name: 'Closed Shop',
      status: 'inactive',
      deletedAt: DateTime(2026, 10, 1),
    ),
  ];

  @override
  Future<PaginatedResponse<AdminShop>> getShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async => PaginatedResponse(
    content: _shops,
    page: 0,
    size: 20,
    totalElements: _shops.length,
    totalPages: 1,
    isFirst: true,
    isLast: true,
  );

  @override
  Future<ShopDataReset> previewShopDataReset(int shopId) async {
    previews.add(shopId);
    return ShopDataReset.fromJson(_reset(done: false));
  }

  @override
  Future<ShopDataReset> resetShopData(
    int shopId,
    ResetShopDataRequest request,
  ) async {
    if (refuseWith != null) throw ApiException(message: refuseWith!);
    resets.add((shopId, request));
    return ShopDataReset.fromJson(_reset(done: true));
  }
}

Future<void> _openShops(
  WidgetTester tester,
  _ResetRepo repo, {
  Size size = const Size(1280, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [adminRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.lightTheme, home: const ShopsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openReset(
  WidgetTester tester,
  _ResetRepo repo, {
  Size size = const Size(1280, 1000),
}) async {
  await _openShops(tester, repo, size: size);
  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reset data…'));
  await tester.pumpAndSettle();
}

Future<void> _fill(
  WidgetTester tester, {
  required String name,
  required String reason,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Type the shop name to confirm'),
    name,
  );
  await tester.enterText(find.widgetWithText(TextFormField, 'Reason'), reason);
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Reset data'));
  await tester.tap(find.widgetWithText(FilledButton, 'Reset data'));
  await tester.pumpAndSettle();
}
