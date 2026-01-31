import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ufin_admin_system/core/constants/api_constants.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Repository for admin API calls
class AdminRepository {
  final Dio _dio;

  AdminRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  // ============================================================
  // DASHBOARD
  // ============================================================

  /// Get dashboard statistics
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _dio.get(ApiConstants.adminDashboard);
      return _parseResponse(response, AdminDashboardStats.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // SHOPS
  // ============================================================

  /// Get all shops (paginated)
  Future<PaginatedResponse<AdminShop>> getShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminShops,
        queryParameters: {
          'page': page,
          'size': size,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
        },
      );
      return _parsePaginatedResponse(response, AdminShop.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get shop by ID
  Future<AdminShop> getShopById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.adminShopById(id));
      return _parseResponse(response, AdminShop.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update shop status
  Future<AdminShop> updateShopStatus(
    int id,
    UpdateShopStatusRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminShopStatus(id),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminShop.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Soft delete shop
  Future<void> deleteShop(int id) async {
    try {
      await _dio.delete(ApiConstants.adminShopById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // USERS
  // ============================================================

  /// Get all users (paginated)
  Future<PaginatedResponse<AdminUser>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? userType,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminUsers,
        queryParameters: {
          'page': page,
          'size': size,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          if (userType != null) 'userType': userType,
        },
      );
      return _parsePaginatedResponse(response, AdminUser.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get user by ID
  Future<AdminUser> getUserById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.adminUserById(id));
      return _parseResponse(response, AdminUser.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update user status
  Future<AdminUser> updateUserStatus(
    int id,
    UpdateUserStatusRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminUserStatus(id),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminUser.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // SUBSCRIPTIONS
  // ============================================================

  /// Get all subscriptions (paginated)
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminSubscriptions,
        queryParameters: {
          'page': page,
          'size': size,
          if (status != null) 'status': status,
        },
      );
      return _parsePaginatedResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get subscription by shop ID
  Future<AdminSubscription> getSubscriptionByShop(int shopId) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminSubscriptionByShop(shopId),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Extend subscription
  Future<AdminSubscription> extendSubscription(
    int shopId,
    ExtendSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminSubscriptionExtend(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Reduce subscription days
  Future<AdminSubscription> reduceSubscription(
    int shopId,
    ExtendSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminSubscriptionReduce(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Upgrade subscription to new plan
  Future<AdminSubscription> upgradeSubscription(
    int shopId,
    String planCode, {
    String? billingCycle,
  }) async {
    try {
      final queryParams = {
        if (billingCycle != null) 'billingCycle': billingCycle,
      };
      debugPrint('⬆️ Upgrade Request:');
      debugPrint(
        '   URL: ${ApiConstants.adminSubscriptionUpgrade(shopId, planCode)}',
      );
      debugPrint('   Query Params: $queryParams');
      final response = await _dio.put(
        ApiConstants.adminSubscriptionUpgrade(shopId, planCode),
        queryParameters: queryParams,
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Downgrade subscription to new plan
  Future<AdminSubscription> downgradeSubscription(
    int shopId,
    String newPlanCode, {
    String? reason,
    String? billingCycle,
  }) async {
    try {
      final queryParams = {
        if (reason != null) 'reason': reason,
        if (billingCycle != null) 'billingCycle': billingCycle,
      };
      debugPrint('⬇️ Downgrade Request:');
      debugPrint(
        '   URL: ${ApiConstants.adminSubscriptionDowngrade(shopId, newPlanCode)}',
      );
      debugPrint('   Query Params: $queryParams');
      final response = await _dio.put(
        ApiConstants.adminSubscriptionDowngrade(shopId, newPlanCode),
        queryParameters: queryParams,
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Change plan (auto-detects upgrade/downgrade)
  Future<AdminSubscription> changePlan(
    int shopId,
    ChangePlanRequest request,
  ) async {
    try {
      debugPrint('🔄 ChangePlan Request: ${request.toJson()}');
      final response = await _dio.put(
        ApiConstants.adminSubscriptionChangePlan(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all subscription history (paginated)
  Future<PaginatedResponse<SubscriptionHistory>> getSubscriptionHistory({
    int page = 0,
    int size = 20,
    int? shopId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminSubscriptionHistory,
        queryParameters: {
          'page': page,
          'size': size,
          if (shopId != null) 'shopId': shopId,
        },
      );
      return _parsePaginatedResponse(response, SubscriptionHistory.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get subscription history for specific shop
  Future<List<SubscriptionHistory>> getShopSubscriptionHistory(
    int shopId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminSubscriptionShopHistory(shopId),
      );
      return _parseListResponse(response, SubscriptionHistory.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create subscription for a shop
  Future<AdminSubscription> createSubscription(
    int shopId,
    CreateSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminSubscriptionCreate(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Cancel subscription
  Future<AdminSubscription> cancelSubscription(
    int shopId,
    CancelSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminSubscriptionCancel(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Reactivate subscription
  Future<AdminSubscription> reactivateSubscription(
    int shopId,
    ReactivateSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminSubscriptionReactivate(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get subscription statistics
  Future<AdminSubscriptionStats> getSubscriptionStatistics() async {
    try {
      final response = await _dio.get(ApiConstants.adminSubscriptionStatistics);
      return _parseResponse(response, AdminSubscriptionStats.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get expiring subscriptions
  Future<List<ExpiringSubscription>> getExpiringSubscriptions({
    int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminSubscriptionExpiring,
        queryParameters: {'days': days},
      );
      return _parseListResponse(response, ExpiringSubscription.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // PAYMENTS
  // ============================================================

  /// Get all payments (paginated)
  Future<PaginatedResponse<AdminPayment>> getPayments({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentMethod,
    int? shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminPayments,
        queryParameters: {
          'page': page,
          'size': size,
          if (status != null) 'status': status,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
          if (shopId != null) 'shopId': shopId,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
        },
      );
      return _parsePaginatedResponse(response, AdminPayment.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get payment by ID
  Future<AdminPayment> getPaymentById(int paymentId) async {
    try {
      final response = await _dio.get(ApiConstants.adminPaymentById(paymentId));
      return _parseResponse(response, AdminPayment.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Record manual payment for a shop
  Future<AdminPayment> recordPayment(
    int shopId,
    RecordPaymentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminPaymentRecord(shopId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminPayment.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update payment status
  Future<AdminPayment> updatePaymentStatus(
    int paymentId,
    UpdatePaymentStatusRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminPaymentStatus(paymentId),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminPayment.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // REPORTS
  // ============================================================

  /// Get revenue report
  Future<AdminRevenueReport> getRevenueReport({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy, // 'day', 'week', 'month'
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminRevenueReport,
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (groupBy != null) 'groupBy': groupBy,
        },
      );
      return _parseResponse(response, AdminRevenueReport.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // PLANS
  // ============================================================

  /// Get all plans
  Future<List<AdminPlan>> getPlans() async {
    try {
      final response = await _dio.get(ApiConstants.adminPlans);
      return _parseListResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get plan by ID
  Future<AdminPlan> getPlanById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.adminPlanById(id));
      return _parseResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new plan
  Future<AdminPlan> createPlan(CreatePlanRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminPlans,
        data: request.toJson(),
      );
      return _parseResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update plan
  Future<AdminPlan> updatePlan(int id, UpdatePlanRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminPlanById(id),
        data: request.toJson(),
      );
      return _parseResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Activate plan
  Future<AdminPlan> activatePlan(int id) async {
    try {
      final response = await _dio.put(ApiConstants.adminPlanActivate(id));
      return _parseResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Deactivate plan
  Future<AdminPlan> deactivatePlan(int id) async {
    try {
      final response = await _dio.put(ApiConstants.adminPlanDeactivate(id));
      return _parseResponse(response, AdminPlan.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Parse wrapped API response: {success: true, data: {...}}
  T _parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final responseData = response.data;
    if (responseData['success'] == true && responseData['data'] != null) {
      return fromJson(responseData['data'] as Map<String, dynamic>);
    }
    throw ApiException(
      message: responseData['message'] ?? 'Request failed',
      statusCode: responseData['status'],
    );
  }

  /// Parse wrapped list response: {success: true, data: [...]}
  List<T> _parseListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final responseData = response.data;
    if (responseData['success'] == true && responseData['data'] != null) {
      return (responseData['data'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      message: responseData['message'] ?? 'Request failed',
      statusCode: responseData['status'],
    );
  }

  /// Parse paginated response
  PaginatedResponse<T> _parsePaginatedResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final responseData = response.data;
    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'];
      final content =
          (data['content'] as List?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return PaginatedResponse(
        content: content,
        page: data['number'] as int? ?? 0,
        size: data['size'] as int? ?? 20,
        totalElements: data['totalElements'] as int? ?? 0,
        totalPages: data['totalPages'] as int? ?? 0,
        isFirst: data['first'] as bool? ?? true,
        isLast: data['last'] as bool? ?? true,
      );
    }
    throw ApiException(
      message: responseData['message'] ?? 'Request failed',
      statusCode: responseData['status'],
    );
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool isFirst;
  final bool isLast;

  const PaginatedResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.isFirst,
    required this.isLast,
  });

  bool get hasNext => !isLast;
  bool get hasPrevious => !isFirst;
}
