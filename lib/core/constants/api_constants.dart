import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // Base URL from .env
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiPath => dotenv.env['API_PATH'] ?? '';
  static int get timeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Storage
  static String get bucketPrivateName =>
      dotenv.env['BUCKET_PRIVATE_NAME'] ?? '';
  static String get bucketPublicName => dotenv.env['BUCKET_PUBLIC_NAME'] ?? '';
  static String get bucketPublicBaseUrl =>
      dotenv.env['BUCKET_PUBLIC_BASE_URL'] ?? '';

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String session = '/auth/session';

  // ============================================================
  // ADMIN ENDPOINTS
  // ============================================================
  static const String admin = '/admin';

  // Dashboard
  static const String adminDashboard = '/admin/dashboard';

  // Shops
  static const String adminShops = '/admin/shops';
  static String adminShopById(int id) => '/admin/shops/$id';
  static String adminShopStatus(int id) => '/admin/shops/$id/status';
  static String adminShopRestore(int id) => '/admin/shops/$id/restore';

  // Users
  static const String adminUsers = '/admin/users';
  static const String adminUsersDeleted = '/admin/users/deleted';
  static String adminUserById(int id) => '/admin/users/$id';
  static String adminUserStatus(int id) => '/admin/users/$id/status';
  static String adminUserResetPassword(int id) =>
      '/admin/users/$id/reset-password';
  static String adminUserRestore(int id) => '/admin/users/$id/restore';
  static String adminUserVerify(int id) => '/admin/users/$id/verify';

  // Products
  static String productsPaginated(int shopId, int empId) =>
      '/products/$shopId/$empId/paginated';
  static String adminProductsByShop(int shopId) => '/admin/products/$shopId';

  // Subscriptions
  static const String adminSubscriptions = '/admin/subscriptions';
  static String adminSubscriptionByShop(int shopId) =>
      '/admin/subscriptions/shop/$shopId';
  static String adminSubscriptionCreate(int shopId) =>
      '/admin/subscriptions/shop/$shopId/create';
  static String adminSubscriptionCancel(int shopId) =>
      '/admin/subscriptions/shop/$shopId/cancel';
  static String adminSubscriptionReactivate(int shopId) =>
      '/admin/subscriptions/shop/$shopId/reactivate';
  static String adminSubscriptionExtend(int shopId) =>
      '/admin/subscriptions/shop/$shopId/extend';
  static String adminSubscriptionReduce(int shopId) =>
      '/admin/subscriptions/shop/$shopId/reduce';
  static String adminSubscriptionUpgrade(int shopId, String plan) =>
      '/admin/subscriptions/shop/$shopId/upgrade/$plan';
  static String adminSubscriptionDowngrade(int shopId, String newPlanCode) =>
      '/admin/subscriptions/shop/$shopId/downgrade/$newPlanCode';
  static String adminSubscriptionChangePlan(int shopId) =>
      '/admin/subscriptions/shop/$shopId/change-plan';
  static String adminSubscriptionAutoRenew(int shopId) =>
      '/admin/subscriptions/shop/$shopId/auto-renew';
  static const String adminSubscriptionHistory = '/admin/subscriptions/history';
  static String adminSubscriptionShopHistory(int shopId) =>
      '/admin/subscriptions/shop/$shopId/history';
  static const String adminSubscriptionStatistics =
      '/admin/subscriptions/statistics';
  static const String adminSubscriptionExpiring =
      '/admin/subscriptions/expiring';

  // Payments
  static const String adminPayments = '/admin/payments';
  static String adminPaymentById(int paymentId) => '/admin/payments/$paymentId';
  static String adminPaymentRecord(int shopId) =>
      '/admin/payments/shop/$shopId/record';
  static String adminPaymentStatus(int paymentId) =>
      '/admin/payments/$paymentId/status';

  // Reports
  static const String adminRevenueReport = '/admin/reports/revenue';
  static const String adminDailySales = '/admin/reports/daily-sales';

  // Plans
  static const String adminPlans = '/admin/plans';
  static String adminPlanById(int id) => '/admin/plans/$id';
  static String adminPlanActivate(int id) => '/admin/plans/$id/activate';
  static String adminPlanDeactivate(int id) => '/admin/plans/$id/deactivate';

  // Subscription Upgrade Requests (admin)
  static const String adminUpgradeRequests =
      '/admin/subscriptions/upgrade-requests';
  static String adminUpgradeRequestApprove(int requestId) =>
      '/admin/subscriptions/upgrade-requests/$requestId/approve';
  static String adminUpgradeRequestReject(int requestId) =>
      '/admin/subscriptions/upgrade-requests/$requestId/reject';

  // Shop Types (Business Types)
  static const String businessTypes = '/business-types';
  static const String businessTypesAdminAll = '/business-types/admin/all';
  static String businessTypeById(int id) => '/business-types/$id';
  static String businessTypeByCode(String code) => '/business-types/code/$code';
  static String businessTypeToggle(int id) => '/business-types/$id/toggle';
  static const String businessTypeStats = '/business-types/stats';

  // Units
  static const String units = '/units';
  static String unitById(int id) => '/units/$id';
  static String unitByCode(String code) => '/units/code/$code';
  static String unitsByCategory(String category) => '/units/category/$category';
  static String unitActivate(int id) => '/units/$id/activate';
  static String unitDeactivate(int id) => '/units/$id/deactivate';
  static String unitRestore(int id) => '/units/$id/restore';
  static String unitSetDefault(int id) => '/units/$id/set-default';

  // Subscription Plans (public endpoints)
  static const String subscriptionPlans = '/subscriptions/plans';
  static String subscriptionPlanById(int id) => '/subscriptions/plans/id/$id';
  static String subscriptionPlanByCode(String code) =>
      '/subscriptions/plans/$code';

  // App Releases & Maintenance Mode
  static const String adminAppReleases = '/admin/app/releases';
  static String adminAppReleaseById(int id) => '/admin/app/releases/$id';
  static String adminAppReleaseByPlatform(String platform) =>
      '/admin/app/releases/platform/$platform';
  static const String adminAppPublishedReleases =
      '/admin/app/releases/published';
  static String adminAppReleasePublish(int id) =>
      '/admin/app/releases/$id/publish';
  static String adminAppReleaseUnpublish(int id) =>
      '/admin/app/releases/$id/unpublish';
  static const String adminAppSystemConfig = '/admin/app/system-config';
  static const String adminAppMaintenanceMode = '/admin/app/maintenance-mode';

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
