import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

// ========== Subscription Statistics ==========
class SubscriptionStatsState {
  final bool isLoading;
  final String? error;
  final AdminSubscriptionStats? stats;

  const SubscriptionStatsState({
    this.isLoading = false,
    this.error,
    this.stats,
  });

  SubscriptionStatsState copyWith({
    bool? isLoading,
    String? error,
    AdminSubscriptionStats? stats,
    bool clearError = false,
  }) {
    return SubscriptionStatsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      stats: stats ?? this.stats,
    );
  }
}

class SubscriptionStatsNotifier extends StateNotifier<SubscriptionStatsState> {
  final AdminRepository _repository;

  SubscriptionStatsNotifier(this._repository)
    : super(const SubscriptionStatsState());

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _repository.getSubscriptionStatistics();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    loadStatistics();
  }
}

final subscriptionStatsProvider =
    StateNotifierProvider<SubscriptionStatsNotifier, SubscriptionStatsState>((
      ref,
    ) {
      final repository = ref.watch(adminRepositoryProvider);
      return SubscriptionStatsNotifier(repository);
    });

// ========== Expiring Subscriptions ==========
class ExpiringSubscriptionsState {
  final bool isLoading;
  final String? error;
  final List<ExpiringSubscription> subscriptions;
  final int daysFilter;

  const ExpiringSubscriptionsState({
    this.isLoading = false,
    this.error,
    this.subscriptions = const [],
    this.daysFilter = 30,
  });

  ExpiringSubscriptionsState copyWith({
    bool? isLoading,
    String? error,
    List<ExpiringSubscription>? subscriptions,
    int? daysFilter,
    bool clearError = false,
  }) {
    return ExpiringSubscriptionsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      subscriptions: subscriptions ?? this.subscriptions,
      daysFilter: daysFilter ?? this.daysFilter,
    );
  }

  /// Get count of urgent (≤7 days) subscriptions
  int get urgentCount =>
      subscriptions.where((s) => s.daysUntilExpiry <= 7).length;

  /// Get count of critical (≤3 days) subscriptions
  int get criticalCount =>
      subscriptions.where((s) => s.daysUntilExpiry <= 3).length;
}

class ExpiringSubscriptionsNotifier
    extends StateNotifier<ExpiringSubscriptionsState> {
  final AdminRepository _repository;

  ExpiringSubscriptionsNotifier(this._repository)
    : super(const ExpiringSubscriptionsState());

  Future<void> loadExpiringSubscriptions({int? days}) async {
    final filterDays = days ?? state.daysFilter;
    state = state.copyWith(isLoading: true, clearError: true, daysFilter: days);
    try {
      final subscriptions = await _repository.getExpiringSubscriptions(
        days: filterDays,
      );
      state = state.copyWith(isLoading: false, subscriptions: subscriptions);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setDaysFilter(int days) {
    loadExpiringSubscriptions(days: days);
  }

  void refresh() {
    loadExpiringSubscriptions();
  }
}

final expiringSubscriptionsProvider =
    StateNotifierProvider<
      ExpiringSubscriptionsNotifier,
      ExpiringSubscriptionsState
    >((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return ExpiringSubscriptionsNotifier(repository);
    });

// ========== Revenue Report ==========
class RevenueReportState {
  final bool isLoading;
  final String? error;
  final AdminRevenueReport? report;
  final DateTime? startDate;
  final DateTime? endDate;
  final String groupBy;

  const RevenueReportState({
    this.isLoading = false,
    this.error,
    this.report,
    this.startDate,
    this.endDate,
    this.groupBy = 'day',
  });

  RevenueReportState copyWith({
    bool? isLoading,
    String? error,
    AdminRevenueReport? report,
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
    bool clearError = false,
  }) {
    return RevenueReportState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      report: report ?? this.report,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      groupBy: groupBy ?? this.groupBy,
    );
  }
}

class RevenueReportNotifier extends StateNotifier<RevenueReportState> {
  final AdminRepository _repository;

  RevenueReportNotifier(this._repository) : super(const RevenueReportState());

  Future<void> loadRevenueReport({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      startDate: startDate,
      endDate: endDate,
      groupBy: groupBy,
    );
    try {
      final report = await _repository.getRevenueReport(
        startDate: startDate ?? state.startDate,
        endDate: endDate ?? state.endDate,
        groupBy: groupBy ?? state.groupBy,
      );
      state = state.copyWith(isLoading: false, report: report);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    loadRevenueReport(startDate: startDate, endDate: endDate);
  }

  void setGroupBy(String groupBy) {
    loadRevenueReport(groupBy: groupBy);
  }

  void refresh() {
    loadRevenueReport();
  }
}

final revenueReportProvider =
    StateNotifierProvider<RevenueReportNotifier, RevenueReportState>((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return RevenueReportNotifier(repository);
    });
