import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

const _unchangedFilter = Object();

// ========== Payments ==========
class PaymentsState {
  final bool isLoading;
  final String? error;
  final List<AdminPayment> payments;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final String? statusFilter;
  final String? paymentMethodFilter;
  final int? shopIdFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;

  const PaymentsState({
    this.isLoading = false,
    this.error,
    this.payments = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.statusFilter,
    this.paymentMethodFilter,
    this.shopIdFilter,
    this.startDateFilter,
    this.endDateFilter,
  });

  PaymentsState copyWith({
    bool? isLoading,
    String? error,
    List<AdminPayment>? payments,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    Object? statusFilter = _unchangedFilter,
    Object? paymentMethodFilter = _unchangedFilter,
    Object? shopIdFilter = _unchangedFilter,
    Object? startDateFilter = _unchangedFilter,
    Object? endDateFilter = _unchangedFilter,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      payments: payments ?? this.payments,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      statusFilter: clearFilters
          ? null
          : (identical(statusFilter, _unchangedFilter)
                ? this.statusFilter
                : statusFilter as String?),
      paymentMethodFilter: clearFilters
          ? null
          : (identical(paymentMethodFilter, _unchangedFilter)
                ? this.paymentMethodFilter
                : paymentMethodFilter as String?),
      shopIdFilter: clearFilters
          ? null
          : (identical(shopIdFilter, _unchangedFilter)
                ? this.shopIdFilter
                : shopIdFilter as int?),
      startDateFilter: clearFilters
          ? null
          : (identical(startDateFilter, _unchangedFilter)
                ? this.startDateFilter
                : startDateFilter as DateTime?),
      endDateFilter: clearFilters
          ? null
          : (identical(endDateFilter, _unchangedFilter)
                ? this.endDateFilter
                : endDateFilter as DateTime?),
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final AdminRepository _repository;
  int _generation = 0;

  PaymentsNotifier(this._repository) : super(const PaymentsState());

  Future<void> loadPayments({
    int page = 0,
    int size = 20,
    String? status,
    String? paymentMethod,
    int? shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final generation = ++_generation;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      statusFilter: status ?? state.statusFilter,
      paymentMethodFilter: paymentMethod ?? state.paymentMethodFilter,
      shopIdFilter: shopId ?? state.shopIdFilter,
      startDateFilter: startDate ?? state.startDateFilter,
      endDateFilter: endDate ?? state.endDateFilter,
    );
    try {
      final response = await _repository.getPayments(
        page: page,
        size: size,
        status: status ?? state.statusFilter,
        paymentMethod: paymentMethod ?? state.paymentMethodFilter,
        shopId: shopId ?? state.shopIdFilter,
        startDate: startDate ?? state.startDateFilter,
        endDate: endDate ?? state.endDateFilter,
      );
      if (!mounted || generation != _generation) return;
      state = state.copyWith(
        isLoading: false,
        payments: response.content,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
      );
    } catch (e) {
      if (!mounted || generation != _generation) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.currentPage < state.totalPages - 1) {
      await loadPayments(page: state.currentPage + 1);
    }
  }

  Future<void> loadPreviousPage() async {
    if (state.currentPage > 0) {
      await loadPayments(page: state.currentPage - 1);
    }
  }

  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status);
    loadPayments(page: 0);
  }

  void setPaymentMethodFilter(String? paymentMethod) {
    state = state.copyWith(paymentMethodFilter: paymentMethod);
    loadPayments(page: 0);
  }

  void setShopFilter(int? shopId) {
    state = state.copyWith(shopIdFilter: shopId);
    loadPayments(page: 0);
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDateFilter: startDate, endDateFilter: endDate);
    loadPayments(page: 0);
  }

  void clearFilters() {
    state = state.copyWith(clearFilters: true);
    loadPayments(page: 0);
  }

  Future<AdminPayment> recordPayment(
    int shopId,
    RecordPaymentRequest request,
  ) async {
    try {
      final payment = await _repository.recordPayment(shopId, request);
      loadPayments(); // Refresh list
      return payment;
    } catch (_) {
      // Leave list state intact; the caller reports the failure.
      rethrow;
    }
  }

  Future<AdminPayment> updatePaymentStatus(
    int paymentId,
    UpdatePaymentStatusRequest request,
  ) async {
    try {
      final payment = await _repository.updatePaymentStatus(paymentId, request);
      await loadPayments(page: 0);
      return payment;
    } catch (_) {
      // Leave list state intact; the caller reports the failure.
      rethrow;
    }
  }

  void refresh() {
    loadPayments(page: state.currentPage);
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentsState>(
  (ref) {
    final repository = ref.watch(adminRepositoryProvider);
    return PaymentsNotifier(repository);
  },
);

// ========== Single Payment Detail ==========
final paymentDetailProvider = FutureProvider.family<AdminPayment, int>((
  ref,
  paymentId,
) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getPaymentById(paymentId);
});
