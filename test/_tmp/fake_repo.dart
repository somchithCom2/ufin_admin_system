import 'package:dio/dio.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';

PaginatedResponse<T> _page<T>(List<T> rows) => PaginatedResponse(
  content: rows,
  page: 0,
  size: 20,
  totalElements: rows.length,
  totalPages: 1,
  isFirst: true,
  isLast: true,
);

const _now = '2026-11-05T10:30:00';

class FakeRepo extends AdminRepository {
  FakeRepo() : super(dio: Dio());

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
  Future<List<AdminSubscription>> getExpiringAdminSubscriptions({
    int days = 7,
  }) async => const [];

  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
    String? planCode,
    bool paid = false,
    String? search,
  }) async => _page([
    for (final (i, n) in ['Mekong Mart', 'Home Coffee', 'Vientiane Pharmacy'].indexed)
      AdminSubscription(
        id: i + 1,
        shopId: i + 1,
        shopName: n,
        planId: 2,
        planCode: 'pro',
        planName: 'PRO',
        status: i == 2 ? 'trial' : 'active',
        billingCycle: 'monthly',
        daysUntilExpiry: 12 + i,
      ),
  ]);

  @override
  Future<List<AdminPlan>> getPlans() async => const [
    AdminPlan(id: 1, code: 'free', name: 'Free'),
    AdminPlan(id: 2, code: 'pro', name: 'PRO', priceMonthly: 100000, priceYearly: 960000),
  ];

  @override
  Future<PaginatedResponse<AdminShop>> getShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async => _page([
    for (final (i, n) in ['Mekong Mart', 'Home Coffee', 'Vientiane Pharmacy', 'Lao Fashion House'].indexed)
      AdminShop.fromJson({
        'id': i + 1,
        'name': n,
        'businessType': {'en': ['Retail', 'Cafe', 'Pharmacy', 'Fashion'][i]},
        'status': i == 3 ? 'SUSPENDED' : 'ACTIVE',
        'currency': 'LAK',
        'ownerUsername': 'owner$i',
        'ownerPhone': '020 5555 000$i',
        'subscriptionPlan': i.isEven ? 'PRO' : 'Free',
        'subscriptionStatus': 'ACTIVE',
        'employeeCount': i + 2,
        'productCount': 40 * (i + 1),
        'createdAt': _now,
      }),
  ]);

  @override
  Future<PaginatedResponse<AdminUser>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? userType,
  }) async => _page([
    for (final (i, n) in ['somchith', 'noy', 'khamla', 'vanh'].indexed)
      AdminUser.fromJson({
        'id': i + 1,
        'username': n,
        'email': '$n@example.com',
        'phone': '020 5555 100$i',
        'firstName': n,
        'userType': i == 0 ? 'ADMIN' : 'OWNER',
        'status': 'ACTIVE',
        'emailVerified': i.isEven,
        'createdAt': _now,
        'lastLogin': _now,
        'shops': [
          {'shopId': 1, 'shopName': 'Mekong Mart', 'role': 'OWNER'},
        ],
      }),
  ]);

  @override
  Future<PaginatedResponse<AdminUser>> getDeletedUsers({
    int page = 0,
    int size = 20,
  }) async => _page([
    AdminUser.fromJson({
      'id': 9,
      'username': 'old_user',
      'email': 'old@example.com',
      'userType': 'OWNER',
      'status': 'DELETED',
      'createdAt': _now,
      'deletedAt': _now,
    }),
  ]);

  @override
  Future<PaginatedResponse<AdminPayment>> getPayments({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentMethod,
    int? shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async => _page([
    for (var i = 0; i < 4; i++)
      AdminPayment.fromJson({
        'id': i + 1,
        'shopId': 1,
        'shopName': 'Mekong Mart',
        'amount': 100000 * (i + 1),
        'currency': 'LAK',
        'paymentMethod': i.isEven ? 'BANK_TRANSFER' : 'CASH',
        'status': i == 1 ? 'PENDING' : 'COMPLETED',
        'paymentDate': _now,
        'createdAt': _now,
      }),
  ]);

  @override
  Future<PaginatedResponse<UpgradeRequestDto>> getUpgradeRequests({
    int page = 0,
    int size = 20,
    String? status,
  }) async => _page([
    UpgradeRequestDto.fromJson({
      'id': 1,
      'shopId': 1,
      'shopName': 'Mekong Mart',
      'fromPlanCode': 'free',
      'fromPlanName': 'Free',
      'toPlanCode': 'pro',
      'toPlanName': 'PRO',
      'billingCycle': 'MONTHLY',
      'status': 'PENDING',
      'requestedByUsername': 'owner0',
      'createdAt': _now,
    }),
  ]);

  @override
  Future<List<AppRelease>> getAppReleases() async => [
    for (final (i, p) in ['android', 'ios', 'windows'].indexed)
      AppRelease.fromJson({
        'id': i + 1,
        'version_name': '2.1.${i + 1}',
        'version_code': 20 + i,
        'platform': p,
        'title': 'Faster checkout',
        'changelog': 'Bug fixes',
        'is_published': i != 2,
        'download_url': 'https://example.com',
        'released_at': _now,
        'created_at': _now,
        'updated_at': _now,
      }),
  ];

  List<ShopType> get _types => [
    for (final (i, c) in ['retail', 'cafe', 'restaurant', 'pharmacy'].indexed)
      ShopType.fromJson({
        'id': i + 1,
        'code': c,
        'name': {'en': c[0].toUpperCase() + c.substring(1), 'lo': c},
        'enabled': true,
        'totalShops': 10 * (i + 1),
        'activeShops': 8 * (i + 1),
      }),
  ];

  @override
  Future<List<ShopType>> getAllShopTypes() async => _types;

  @override
  Future<List<ShopType>> getShopTypesWithStats() async => _types;

  @override
  Future<UnitsPageResponse> getUnits({
    int page = 0,
    int size = 50,
    String? category,
    bool? isActive,
  }) async => UnitsPageResponse(
    data: [
      for (final (i, c) in ['piece', 'weight', 'volume', 'length'].indexed)
        Unit.fromJson({
          'id': i + 1,
          'code': c,
          'name': {'en': c, 'lo': c},
          'abbreviation': c.substring(0, 2),
          'category': c,
          'isActive': true,
          'isDefault': i == 0,
        }),
    ],
    currentPage: 0,
    totalPages: 1,
    totalElements: 4,
    pageSize: 50,
    hasNext: false,
    hasPrevious: false,
  );
}
