import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';

// Admin Repository Provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// ========== Dashboard ==========
class DashboardState {
  final bool isLoading;
  final String? error;
  final AdminDashboardStats? stats;

  const DashboardState({this.isLoading = false, this.error, this.stats});

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    AdminDashboardStats? stats,
    bool clearError = false,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      stats: stats ?? this.stats,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AdminRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _repository.getDashboardStats();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    loadDashboard();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return DashboardNotifier(repository);
    });

// ========== Shops ==========
class ShopsState {
  final bool isLoading;
  final String? error;
  final List<AdminShop> shops;
  final int currentPage;
  final int totalPages;

  const ShopsState({
    this.isLoading = false,
    this.error,
    this.shops = const [],
    this.currentPage = 0,
    this.totalPages = 0,
  });

  ShopsState copyWith({
    bool? isLoading,
    String? error,
    List<AdminShop>? shops,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) {
    return ShopsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      shops: shops ?? this.shops,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class ShopsNotifier extends StateNotifier<ShopsState> {
  final AdminRepository _repository;

  ShopsNotifier(this._repository) : super(const ShopsState());

  Future<void> loadShops({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getShops(
        page: page,
        size: size,
        search: search,
        status: status,
      );
      state = state.copyWith(
        isLoading: false,
        shops: result.content,
        currentPage: result.page,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateShopStatus(
    int shopId,
    String status,
    String? reason,
  ) async {
    try {
      final request = UpdateShopStatusRequest(status: status, reason: reason);
      await _repository.updateShopStatus(shopId, request);
      loadShops(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final shopsProvider = StateNotifierProvider<ShopsNotifier, ShopsState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return ShopsNotifier(repository);
});

// ========== Users ==========
class UsersState {
  final bool isLoading;
  final String? error;
  final List<AdminUser> users;
  final int currentPage;
  final int totalPages;

  const UsersState({
    this.isLoading = false,
    this.error,
    this.users = const [],
    this.currentPage = 0,
    this.totalPages = 0,
  });

  UsersState copyWith({
    bool? isLoading,
    String? error,
    List<AdminUser>? users,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      users: users ?? this.users,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final AdminRepository _repository;

  UsersNotifier(this._repository) : super(const UsersState());

  Future<void> loadUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? userType,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getUsers(
        page: page,
        size: size,
        search: search,
        status: status,
        userType: userType,
      );
      state = state.copyWith(
        isLoading: false,
        users: result.content,
        currentPage: result.page,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserStatus(
    int userId,
    String status,
    String? reason,
  ) async {
    try {
      final request = UpdateUserStatusRequest(status: status, reason: reason);
      await _repository.updateUserStatus(userId, request);
      loadUsers(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return UsersNotifier(repository);
});

// ========== Subscriptions ==========
class SubscriptionsState {
  final bool isLoading;
  final String? error;
  final List<AdminSubscription> subscriptions;
  final int currentPage;
  final int totalPages;

  const SubscriptionsState({
    this.isLoading = false,
    this.error,
    this.subscriptions = const [],
    this.currentPage = 0,
    this.totalPages = 0,
  });

  SubscriptionsState copyWith({
    bool? isLoading,
    String? error,
    List<AdminSubscription>? subscriptions,
    int? currentPage,
    int? totalPages,
    bool clearError = false,
  }) {
    return SubscriptionsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      subscriptions: subscriptions ?? this.subscriptions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  final AdminRepository _repository;

  SubscriptionsNotifier(this._repository) : super(const SubscriptionsState());

  Future<void> loadSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getSubscriptions(
        page: page,
        size: size,
        status: status,
      );
      state = state.copyWith(
        isLoading: false,
        subscriptions: result.content,
        currentPage: result.page,
        totalPages: result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> extendSubscription(
    int shopId, {
    int? days,
    String? billingCycle,
    String? reason,
  }) async {
    try {
      final request = ExtendSubscriptionRequest(
        days: days,
        billingCycle: billingCycle,
        reason: reason,
      );
      await _repository.extendSubscription(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reduceSubscription(
    int shopId, {
    int? days,
    String? billingCycle,
    String? reason,
  }) async {
    try {
      final request = ExtendSubscriptionRequest(
        days: days,
        billingCycle: billingCycle,
        reason: reason,
      );
      await _repository.reduceSubscription(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> upgradeSubscription(
    int shopId,
    String planCode, {
    String? billingCycle,
  }) async {
    try {
      await _repository.upgradeSubscription(
        shopId,
        planCode,
        billingCycle: billingCycle,
      );
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> downgradeSubscription(
    int shopId,
    String newPlanCode, {
    String? reason,
    String? billingCycle,
  }) async {
    try {
      await _repository.downgradeSubscription(
        shopId,
        newPlanCode,
        reason: reason,
        billingCycle: billingCycle,
      );
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> changePlan(
    int shopId,
    String newPlanCode, {
    String? billingCycle,
    String? reason,
    bool? prorated,
    bool? immediate,
  }) async {
    try {
      final request = ChangePlanRequest(
        newPlanCode: newPlanCode,
        billingCycle: billingCycle,
        reason: reason,
        prorated: prorated,
        immediate: immediate,
      );
      await _repository.changePlan(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createSubscription(
    int shopId, {
    required String planCode,
    required String billingCycle,
    int? trialDays,
    String? notes,
  }) async {
    try {
      final request = CreateSubscriptionRequest(
        planCode: planCode,
        billingCycle: billingCycle,
        trialDays: trialDays,
        notes: notes,
      );
      await _repository.createSubscription(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> cancelSubscription(
    int shopId, {
    required String reason,
    bool immediate = false,
    String? notes,
  }) async {
    try {
      final request = CancelSubscriptionRequest(
        reason: reason,
        immediate: immediate,
        notes: notes,
      );
      await _repository.cancelSubscription(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> reactivateSubscription(
    int shopId, {
    String? planCode,
    String? billingCycle,
    String? notes,
  }) async {
    try {
      final request = ReactivateSubscriptionRequest(
        planCode: planCode,
        billingCycle: billingCycle,
        notes: notes,
      );
      await _repository.reactivateSubscription(shopId, request);
      loadSubscriptions(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final subscriptionsProvider =
    StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return SubscriptionsNotifier(repository);
    });

// ========== Subscription History ==========
class SubscriptionHistoryState {
  final bool isLoading;
  final String? error;
  final List<SubscriptionHistory> history;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;

  const SubscriptionHistoryState({
    this.isLoading = false,
    this.error,
    this.history = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalCount = 0,
    this.pageSize = 20,
  });

  bool get hasMore => currentPage < totalPages - 1;

  SubscriptionHistoryState copyWith({
    bool? isLoading,
    String? error,
    List<SubscriptionHistory>? history,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    int? pageSize,
    bool clearError = false,
  }) {
    return SubscriptionHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      history: history ?? this.history,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class SubscriptionHistoryNotifier
    extends StateNotifier<SubscriptionHistoryState> {
  final AdminRepository _repository;

  SubscriptionHistoryNotifier(this._repository)
    : super(const SubscriptionHistoryState());

  Future<void> loadHistory({int page = 0, int size = 20}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getSubscriptionHistory(
        page: page,
        size: size,
      );
      state = state.copyWith(
        isLoading: false,
        history: result.content,
        currentPage: result.page,
        totalPages: result.totalPages,
        totalCount: result.totalElements,
        pageSize: size,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getSubscriptionHistory(
        page: nextPage,
        size: state.pageSize,
      );
      state = state.copyWith(
        isLoading: false,
        history: [...state.history, ...result.content],
        currentPage: result.page,
        totalPages: result.totalPages,
        totalCount: result.totalElements,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadShopHistory(int shopId) async {
    state = state.copyWith(isLoading: true, clearError: true, history: []);
    try {
      final historyList = await _repository.getShopSubscriptionHistory(shopId);
      state = state.copyWith(
        isLoading: false,
        history: historyList,
        totalCount: historyList.length,
        currentPage: 0,
        totalPages: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final subscriptionHistoryProvider =
    StateNotifierProvider<
      SubscriptionHistoryNotifier,
      SubscriptionHistoryState
    >((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return SubscriptionHistoryNotifier(repository);
    });

// ========== Plans ==========
class PlansState {
  final bool isLoading;
  final String? error;
  final List<AdminPlan> plans;

  const PlansState({this.isLoading = false, this.error, this.plans = const []});

  PlansState copyWith({
    bool? isLoading,
    String? error,
    List<AdminPlan>? plans,
    bool clearError = false,
  }) {
    return PlansState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      plans: plans ?? this.plans,
    );
  }
}

class PlansNotifier extends StateNotifier<PlansState> {
  final AdminRepository _repository;

  PlansNotifier(this._repository) : super(const PlansState());

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final plans = await _repository.getPlans();
      state = state.copyWith(isLoading: false, plans: plans);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> activatePlan(int planId) async {
    try {
      await _repository.activatePlan(planId);
      loadPlans(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deactivatePlan(int planId) async {
    try {
      await _repository.deactivatePlan(planId);
      loadPlans(); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final plansProvider = StateNotifierProvider<PlansNotifier, PlansState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return PlansNotifier(repository);
});
