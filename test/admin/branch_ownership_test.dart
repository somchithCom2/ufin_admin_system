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

const _ownershipResult = {
  'success': true,
  'data': {
    'shop': {
      'id': 5,
      'name': 'Noy Mart Dongdok',
      'status': 'active',
      'parentShopId': 2,
      'parentShopName': 'Noy Mart',
      'ownerId': 11,
      'ownerUsername': 'noy',
    },
    'staffToReview': [
      {
        'employeeId': 40,
        'userId': 12,
        'username': 'old_owner',
        'fullName': 'Somphone K',
        'roleName': 'SHOP_OWNER',
        'previousOwner': true,
      },
    ],
  },
};

/// Admin console side of branch groups: the requests it sends and the
/// screens that send them.
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

    test('linking sends every flag and reads the staff to review', () async {
      responseBody = _ownershipResult;
      final result = await repository.linkAsBranch(
        5,
        const LinkBranchRequest(
          parentShopId: 2,
          transferOwnership: true,
          confirmShopName: 'Noy Mart Dongdok',
          reason: 'one group',
        ),
      );

      expect(requests.single.method, 'PUT');
      expect(requests.single.path, '/admin/shops/5/link-to-parent');
      expect(requests.single.data, {
        'parentShopId': 2,
        'transferOwnership': true,
        'revokePreviousOwnerAccess': false,
        'ignorePlanCheck': false,
        'confirmShopName': 'Noy Mart Dongdok',
        'reason': 'one group',
      });
      expect(result.shop.isBranch, isTrue);
      expect(result.staffToReview.single.previousOwner, isTrue);
      expect(result.staffToReview.single.displayName, 'Somphone K');
    });

    test('unlinking without a new owner leaves the owner out', () async {
      responseBody = _ownershipResult;
      await repository.unlinkBranch(
        5,
        const UnlinkBranchRequest(confirmShopName: 'X', reason: 'sold'),
      );

      expect(requests.single.path, '/admin/shops/5/unlink-from-parent');
      expect((requests.single.data as Map).containsKey('ownerUserId'), isFalse);
    });

    test('changing the owner uses the owner endpoint', () async {
      responseBody = _ownershipResult;
      await repository.changeShopOwner(
        5,
        const ChangeOwnerRequest(
          newOwnerUserId: 30,
          confirmShopName: 'X',
          reason: 'sold',
        ),
      );

      expect(requests.single.path, '/admin/shops/5/owner');
      expect(requests.single.data['newOwnerUserId'], 30);
      expect(requests.single.data['revokePreviousOwnerAccess'], isTrue);
    });

    test('branches and owner history parse as lists', () async {
      responseBody = {
        'success': true,
        'data': [
          {'id': 6, 'name': 'Branch', 'status': 'active', 'parentShopId': 2},
        ],
      };
      final branches = await repository.getBranches(2);
      expect(requests.last.path, '/admin/shops/2/branches');
      expect(branches.single.isBranch, isTrue);

      responseBody = {
        'success': true,
        'data': [
          {
            'fromOwnerId': 12,
            'toOwnerId': 11,
            'source': 'link',
            'reason': 'one group',
            'performedById': 1,
            'createdAt': '2026-10-20T10:00:00',
          },
        ],
      };
      final history = await repository.getOwnerHistory(5);
      expect(requests.last.path, '/admin/shops/5/owner-history');
      expect(history.single.sourceLabel, 'Linked into a branch group');
      expect(history.single.createdAt, DateTime(2026, 10, 20, 10));
    });

    test('a refusal carries its code for the console to explain', () async {
      responseBody = {
        'success': false,
        'message': 'ERR_SHOP_HAS_PAID_SUBSCRIPTION',
      };
      await expectLater(
        repository.linkAsBranch(
          5,
          const LinkBranchRequest(
            parentShopId: 2,
            confirmShopName: 'X',
            reason: 'r',
          ),
        ),
        throwsA(
          isA<ApiException>().having(
            friendlyError,
            'friendly text',
            contains('paid time left'),
          ),
        ),
      );
    });
  });

  group('shops page', () {
    testWidgets('a branch offers unlink, a top-level shop link and owner', (
      tester,
    ) async {
      final repo = _ShopsRepo();
      await _openShops(tester, repo);

      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      expect(find.text('Link as branch…'), findsOneWidget);
      expect(find.text('Change owner…'), findsOneWidget);
      expect(find.text('Unlink branch…'), findsNothing);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      expect(find.text('Unlink branch…'), findsOneWidget);
      expect(find.text('Link as branch…'), findsNothing);
      expect(find.text('Change owner…'), findsNothing);
    });

    testWidgets('change owner refuses a mistyped shop name without sending', (
      tester,
    ) async {
      final repo = _ShopsRepo();
      await _openChangeOwner(tester, repo);

      await _pickNewOwner(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Type the shop name to confirm'),
        'Noy Mart 2',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Reason'),
        'sold',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change owner'));
      await tester.pumpAndSettle();

      expect(find.text('Does not match "Noy Mart"'), findsOneWidget);
      expect(repo.changeRequests, isEmpty);
    });

    testWidgets('change owner sends the request and lists staff to review', (
      tester,
    ) async {
      final repo = _ShopsRepo();
      await _openChangeOwner(tester, repo);

      await _pickNewOwner(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Type the shop name to confirm'),
        ' Noy Mart ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Reason'),
        'shop sold',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change owner'));
      await tester.pumpAndSettle();

      final sent = repo.changeRequests.single;
      expect(sent.$1, 2);
      expect(sent.$2.newOwnerUserId, 30);
      expect(sent.$2.confirmShopName, 'Noy Mart');
      expect(sent.$2.reason, 'shop sold');
      expect(sent.$2.revokePreviousOwnerAccess, isTrue);
      expect(find.text('Owner changed'), findsOneWidget);
      expect(find.text('Staff to review'), findsOneWidget);
      expect(find.text('Somphone K'), findsOneWidget);
    });

    testWidgets("a branch shows its main shop's plan, never its own free", (
      tester,
    ) async {
      await _openShops(tester, _ShopsRepo());

      expect(find.text('Plan of Noy Mart'), findsOneWidget);
      expect(find.text('free'), findsNothing);
    });

    test('every refusal the ownership tools can send reads as a sentence', () {
      for (final code in const [
        'ERR_SHOP_HAS_PAID_SUBSCRIPTION',
        'ERR_SHOP_OWNER_MISMATCH',
        'ERR_PARENT_PLAN_LACKS_MULTI_SHOP',
        'ERR_SHOP_NAME_CONFIRMATION_MISMATCH',
        'ERR_CONCURRENT_MODIFICATION',
        'ERR_INTERNAL_SERVER_ERROR',
        'ERR_ROLE_NOT_FOUND',
        'ERR_USER_ALREADY_OWNER',
        'ERR_INVALID_SHOP_OWNER',
      ]) {
        final text = friendlyError(ApiException(message: code));
        expect(text, isNot(contains('ERR_')), reason: code);
        expect(text, endsWith('.'), reason: code);
      }
    });

    test('changing a branch subscription explains where its plan lives', () {
      expect(
        friendlyError(ApiException(message: 'ERR_SHOP_IS_BRANCH')),
        contains("main shop's subscription"),
      );
    });

    testWidgets('every ownership form fits a phone screen', (tester) async {
      final repo = _ShopsRepo();
      await _openShops(tester, repo, size: const Size(390, 844));

      for (final (card, action, title) in [
        (0, 'Link as branch…', 'Link as branch'),
        (0, 'Change owner…', 'Change owner'),
        (1, 'Unlink branch…', 'Unlink from branch group'),
      ]) {
        await tester.tap(find.byIcon(Icons.more_vert).at(card));
        await tester.pumpAndSettle();
        await tester.tap(find.text(action));
        await tester.pumpAndSettle();
        expect(find.text(title), findsWidgets);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Close').first);
        await tester.pumpAndSettle();
      }
    });
  });
}

class _ShopsRepo extends AdminRepository {
  _ShopsRepo() : super(dio: Dio());

  final changeRequests = <(int, ChangeOwnerRequest)>[];

  static const _shops = [
    AdminShop(
      id: 2,
      name: 'Noy Mart',
      status: 'active',
      ownerId: 12,
      ownerUsername: 'old_owner',
    ),
    AdminShop(
      id: 5,
      name: 'Noy Mart Dongdok',
      status: 'active',
      parentShopId: 2,
      parentShopName: 'Noy Mart',
      ownerId: 12,
      ownerUsername: 'old_owner',
      // A branch's own plan column always reads free.
      subscriptionPlan: 'free',
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
  Future<PaginatedResponse<AdminUser>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? userType,
  }) async => const PaginatedResponse(
    content: [
      AdminUser(
        id: 30,
        username: 'new_owner',
        firstName: 'Kham',
        userType: 'STAFF',
        status: 'active',
      ),
    ],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isFirst: true,
    isLast: true,
  );

  @override
  Future<ShopOwnershipResult> changeShopOwner(
    int shopId,
    ChangeOwnerRequest request,
  ) async {
    changeRequests.add((shopId, request));
    return ShopOwnershipResult.fromJson(
      _ownershipResult['data']! as Map<String, dynamic>,
    );
  }
}

Future<void> _openShops(
  WidgetTester tester,
  _ShopsRepo repo, {
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

Future<void> _openChangeOwner(WidgetTester tester, _ShopsRepo repo) async {
  await _openShops(tester, repo);
  await tester.tap(find.byIcon(Icons.more_vert).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Change owner…'));
  await tester.pumpAndSettle();
}

Future<void> _pickNewOwner(WidgetTester tester) async {
  await tester.tap(find.text('Search and select an account'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Kham'));
  await tester.pumpAndSettle();
}
