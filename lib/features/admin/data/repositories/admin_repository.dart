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

  /// Reset user password (admin)
  Future<void> resetUserPassword(
    int id,
    ResetUserPasswordRequest request,
  ) async {
    try {
      await _dio.put(
        ApiConstants.adminUserResetPassword(id),
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get soft-deleted users (paginated, sorted by deletedAt DESC)
  Future<PaginatedResponse<AdminUser>> getDeletedUsers({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminUsersDeleted,
        queryParameters: {'page': page, 'size': size},
      );
      return _parsePaginatedResponse(response, AdminUser.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Restore a soft-deleted user
  Future<void> restoreUser(int id) async {
    try {
      await _dio.put(ApiConstants.adminUserRestore(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  /// Get products for a shop (paginated + infinite scroll)
  Future<PaginatedResponse<AdminProduct>> getProducts({
    required int shopId,
    required int empId,
    int page = 0,
    int size = 20,
    String? search,
    int? categoryId,
    bool? inStockOnly,
    bool? includeInactive,
    bool? includeDeleted,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'name',
    String sortDirection = 'asc',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.productsPaginated(shopId, empId),
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null) 'categoryId': categoryId,
          if (inStockOnly != null) 'inStockOnly': inStockOnly,
          if (includeInactive != null) 'include_inactive': includeInactive,
          if (includeDeleted != null) 'include_deleted': includeDeleted,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
        },
      );
      return _parsePaginatedResponse(response, AdminProduct.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get products for a shop (admin endpoint - no empId required)
  Future<PaginatedResponse<AdminProduct>> getAdminProductsByShop({
    required int shopId,
    int page = 0,
    int size = 20,
    String? search,
    int? categoryId,
    bool? inStockOnly,
    bool? includeInactive,
    bool? includeDeleted,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'name',
    String sortDirection = 'asc',
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminProductsByShop(shopId),
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null) 'categoryId': categoryId,
          if (inStockOnly != null) 'inStockOnly': inStockOnly,
          if (includeInactive != null) 'include_inactive': includeInactive,
          if (includeDeleted != null) 'include_deleted': includeDeleted,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
        },
      );
      return _parsePaginatedResponse(response, AdminProduct.fromJson);
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

  /// Get daily sales report
  Future<DailySalesData> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminDailySales,
        queryParameters: {
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
        },
      );
      final salesResponse = DailySalesResponse.fromJson(response.data);
      return salesResponse.data;
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

  /// Get subscription plan by ID (from subscriptions endpoint)
  Future<AdminPlan> getSubscriptionPlanById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.subscriptionPlanById(id));
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
  // SUBSCRIPTION UPGRADE REQUESTS
  // ============================================================

  /// List upgrade requests (paginated, filterable by status)
  Future<PaginatedResponse<UpgradeRequestDto>> getUpgradeRequests({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminUpgradeRequests,
        queryParameters: {
          'page': page,
          'size': size,
          if (status != null) 'status': status,
        },
      );
      return _parsePaginatedResponse(response, UpgradeRequestDto.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Approve an upgrade request
  Future<UpgradeRequestDto> approveUpgradeRequest(
    int requestId,
    ReviewUpgradeRequestBody body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminUpgradeRequestApprove(requestId),
        data: body.toJson(),
      );
      return _parseResponse(response, UpgradeRequestDto.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Reject an upgrade request
  Future<UpgradeRequestDto> rejectUpgradeRequest(
    int requestId,
    ReviewUpgradeRequestBody body,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminUpgradeRequestReject(requestId),
        data: body.toJson(),
      );
      return _parseResponse(response, UpgradeRequestDto.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // SHOP TYPES (BUSINESS TYPES)
  // ============================================================

  /// Get enabled shop types only (public endpoint)
  Future<List<ShopType>> getShopTypes() async {
    try {
      final response = await _dio.get(ApiConstants.businessTypes);
      return _parseListResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all shop types including disabled (admin endpoint)
  Future<List<ShopType>> getAllShopTypes() async {
    try {
      final response = await _dio.get(ApiConstants.businessTypesAdminAll);
      return _parseListResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get shop type by ID
  Future<ShopType> getShopTypeById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.businessTypeById(id));
      return _parseResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get shop type by code
  Future<ShopType> getShopTypeByCode(String code) async {
    try {
      final response = await _dio.get(ApiConstants.businessTypeByCode(code));
      return _parseResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get shop types with stats
  Future<List<ShopType>> getShopTypesWithStats() async {
    try {
      final response = await _dio.get(ApiConstants.businessTypeStats);
      return _parseListResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new shop type
  Future<ShopType> createShopType(CreateShopTypeRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.businessTypes,
        data: request.toJson(),
      );
      return _parseResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update shop type
  Future<ShopType> updateShopType(int id, UpdateShopTypeRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.businessTypeById(id),
        data: request.toJson(),
      );
      return _parseResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete shop type
  Future<void> deleteShopType(int id) async {
    try {
      await _dio.delete(ApiConstants.businessTypeById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Toggle shop type enabled/disabled
  Future<ShopType> toggleShopType(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.businessTypeToggle(id));
      return _parseResponse(response, ShopType.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // UNITS
  // ============================================================

  /// Get paginated list of units with optional filtering
  Future<UnitsPageResponse> getUnits({
    int page = 0,
    int size = 50,
    String? category,
    bool? isActive,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.units,
        queryParameters: {
          'page': page,
          'size': size,
          if (category != null) 'category': category,
          if (isActive != null) 'isActive': isActive,
        },
      );
      return _parseUnitsPageResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get unit by ID
  Future<Unit> getUnitById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.unitById(id));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get unit by code
  Future<Unit> getUnitByCode(String code) async {
    try {
      final response = await _dio.get(ApiConstants.unitByCode(code));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get units by category
  Future<List<Unit>> getUnitsByCategory(String category) async {
    try {
      final response = await _dio.get(ApiConstants.unitsByCategory(category));
      return _parseListResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Create new unit
  Future<Unit> createUnit(CreateUnitRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.units,
        data: request.toJson(),
      );
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update unit
  Future<Unit> updateUnit(int id, UpdateUnitRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.unitById(id),
        data: request.toJson(),
      );
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Activate unit (sets isActive=true, deletedAt=NULL)
  Future<Unit> activateUnit(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.unitActivate(id));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Deactivate unit (sets isActive=false, deletedAt=NULL - reversible)
  Future<Unit> deactivateUnit(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.unitDeactivate(id));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete unit permanently (sets isActive=false, deletedAt=now() - soft delete)
  Future<void> deleteUnit(int id) async {
    try {
      await _dio.delete(ApiConstants.unitById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Restore unit from delete (sets isActive=true, deletedAt=NULL)
  Future<Unit> restoreUnit(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.unitRestore(id));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Set unit as default for its category
  Future<Unit> setUnitDefault(int id) async {
    try {
      final response = await _dio.patch(ApiConstants.unitSetDefault(id));
      return _parseResponse(response, Unit.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ============================================================
  // APP RELEASES & MAINTENANCE MODE
  // ============================================================

  /// Create new app release
  Future<AppRelease> createAppRelease(CreateAppReleaseRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminAppReleases,
        data: request.toJson(),
      );

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return AppRelease.fromJson(data['data'] as Map<String, dynamic>);
      }
      return AppRelease.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get all app releases
  Future<List<AppRelease>> getAppReleases() async {
    try {
      final response = await _dio.get(ApiConstants.adminAppReleases);

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return (data as List)
          .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get app release by ID
  Future<AppRelease> getAppReleaseById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.adminAppReleaseById(id));

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return AppRelease.fromJson(data['data'] as Map<String, dynamic>);
      }
      return AppRelease.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get releases by platform
  Future<List<AppRelease>> getAppReleasesByPlatform(String platform) async {
    try {
      final response = await _dio.get(
        ApiConstants.adminAppReleaseByPlatform(platform),
      );

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return (data as List)
          .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get published releases only
  Future<List<AppRelease>> getPublishedAppReleases() async {
    try {
      final response = await _dio.get(ApiConstants.adminAppPublishedReleases);

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return (data as List)
          .map((e) => AppRelease.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update app release
  Future<AppRelease> updateAppRelease(
    int id,
    UpdateAppReleaseRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminAppReleaseById(id),
        data: request.toJson(),
      );

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return AppRelease.fromJson(data['data'] as Map<String, dynamic>);
      }
      return AppRelease.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Publish app release
  Future<AppRelease> publishAppRelease(int id) async {
    try {
      final response = await _dio.patch(
        ApiConstants.adminAppReleasePublish(id),
      );

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return AppRelease.fromJson(data['data'] as Map<String, dynamic>);
      }
      return AppRelease.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Unpublish app release
  Future<AppRelease> unpublishAppRelease(int id) async {
    try {
      final response = await _dio.patch(
        ApiConstants.adminAppReleaseUnpublish(id),
      );

      // Handle both wrapped and unwrapped responses
      final data = response.data;
      if (data is Map && data['success'] == true && data['data'] != null) {
        return AppRelease.fromJson(data['data'] as Map<String, dynamic>);
      }
      return AppRelease.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Delete app release
  Future<void> deleteAppRelease(int id) async {
    try {
      await _dio.delete(ApiConstants.adminAppReleaseById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Get system configuration
  Future<SystemConfiguration> getSystemConfiguration() async {
    try {
      final response = await _dio.get(ApiConstants.adminAppSystemConfig);

      // Response is returned directly, not wrapped
      return SystemConfiguration.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update maintenance mode
  Future<SystemConfiguration> updateMaintenanceMode(
    UpdateMaintenanceModeRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminAppMaintenanceMode,
        data: request.toJson(),
      );

      // Response is returned directly, not wrapped
      return SystemConfiguration.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Update system configuration
  Future<SystemConfiguration> updateSystemConfiguration(
    UpdateSystemConfigRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.adminAppSystemConfig,
        data: request.toJson(),
      );

      // Response is returned directly, not wrapped
      return SystemConfiguration.fromJson(response.data as Map<String, dynamic>);
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

      // Try 'content' first, then 'data' (for compatibility with different API formats)
      List<dynamic>? contentList =
          (data['content'] as List?) ?? (data['data'] as List?);

      final content = contentList
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // Handle page field which might be an object or int
      int pageNumber = 0;
      int totalPages = 1;
      int size = content.isNotEmpty ? content.length : 20;
      int totalElements = 0;

      if (data['page'] is Map) {
        // Page is an object with pagination details
        final pageObj = data['page'] as Map<String, dynamic>;
        pageNumber = pageObj['number'] as int? ?? 0;
        totalPages = pageObj['totalPages'] as int? ?? 1;
        size = pageObj['size'] as int? ?? size;
        totalElements = pageObj['totalElements'] as int? ?? 0;
      } else {
        // Page is a simple int (page number only)
        pageNumber = (data['page'] as int?) ?? 0;
      }

      // Use direct fields if available (for new API format)
      if (data['currentPage'] != null) {
        pageNumber = data['currentPage'] as int;
      }
      if (data['totalPages'] != null) {
        totalPages = data['totalPages'] as int;
      }
      if (data['pageSize'] != null) {
        size = data['pageSize'] as int;
      }
      if (data['totalElements'] != null) {
        totalElements = data['totalElements'] as int;
      }

      // Calculate isLast: if we got fewer items than page size, we're on last page
      final isLast = content.length < size;
      final isFirst = pageNumber == 0;

      return PaginatedResponse(
        content: content,
        page: pageNumber,
        size: size,
        totalElements: totalElements,
        totalPages: totalPages,
        isFirst: isFirst,
        isLast: isLast,
      );
    }
    throw ApiException(
      message: responseData['message'] ?? 'Request failed',
      statusCode: responseData['status'],
    );
  }

  /// Parse units page response with different envelope structure
  UnitsPageResponse _parseUnitsPageResponse(Response response) {
    final responseData = response.data;
    if (responseData['success'] == true && responseData['data'] != null) {
      final data = responseData['data'];

      // Check if data is a list directly (no nested 'data' key) or has 'data' key
      final unitsList = <Unit>[];
      int currentPage = 0;
      int totalPages = 1;
      int totalElements = 0;
      int pageSize = 50;
      bool hasNext = false;
      bool hasPrevious = false;

      if (data is List) {
        // Response is {success, data: [...]} - simple list
        unitsList.addAll(
          data
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return Unit.fromJson(e);
                } else if (e is Map) {
                  return Unit.fromJson(Map<String, dynamic>.from(e));
                }
                throw ApiException(
                  message: 'Invalid unit data format',
                  statusCode: 500,
                );
              })
              .toList(),
        );
        // For simple list responses without pagination metadata:
        // If we got 50 items (full page), assume there might be more
        // If we got less than 50, we're on the last page
        pageSize = 50;
        final itemCount = unitsList.length;
        totalElements = itemCount;
        hasNext = itemCount >= pageSize; // hasNext if we got a full page
        hasPrevious = false;
      } else if (data is Map) {
        // Response is {success, data: {data: [...], pagination fields...}}
        final nestedList = (data['data'] as List?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                return Unit.fromJson(e);
              } else if (e is Map) {
                return Unit.fromJson(Map<String, dynamic>.from(e));
              }
              throw ApiException(
                message: 'Invalid unit data format',
                statusCode: 500,
              );
            })
            .toList() ??
            [];
        unitsList.addAll(nestedList);

        currentPage = data['currentPage'] as int? ?? 0;
        totalPages = data['totalPages'] as int? ?? 1;
        totalElements = data['totalElements'] as int? ?? unitsList.length;
        pageSize = data['pageSize'] as int? ?? 50;
        hasNext = data['hasNext'] as bool? ?? false;
        hasPrevious = data['hasPrevious'] as bool? ?? false;
      }

      return UnitsPageResponse(
        data: unitsList,
        currentPage: currentPage,
        totalPages: totalPages,
        totalElements: totalElements,
        pageSize: pageSize,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
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
