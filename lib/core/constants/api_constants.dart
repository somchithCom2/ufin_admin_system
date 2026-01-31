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

  // Users
  static const String adminUsers = '/admin/users';
  static String adminUserById(int id) => '/admin/users/$id';
  static String adminUserStatus(int id) => '/admin/users/$id/status';

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

  // Plans
  static const String adminPlans = '/admin/plans';
  static String adminPlanById(int id) => '/admin/plans/$id';
  static String adminPlanActivate(int id) => '/admin/plans/$id/activate';
  static String adminPlanDeactivate(int id) => '/admin/plans/$id/deactivate';

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
