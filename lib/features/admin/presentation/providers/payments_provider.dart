import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

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
    String? statusFilter,
    String? paymentMethodFilter,
    int? shopIdFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
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
      statusFilter: clearFilters ? null : (statusFilter ?? this.statusFilter),
      paymentMethodFilter: clearFilters
          ? null
          : (paymentMethodFilter ?? this.paymentMethodFilter),
      shopIdFilter: clearFilters ? null : (shopIdFilter ?? this.shopIdFilter),
      startDateFilter: clearFilters
          ? null
          : (startDateFilter ?? this.startDateFilter),
      endDateFilter: clearFilters
          ? null
          : (endDateFilter ?? this.endDateFilter),
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final AdminRepository _repository;

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
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      statusFilter: status,
      paymentMethodFilter: paymentMethod,
      shopIdFilter: shopId,
      startDateFilter: startDate,
      endDateFilter: endDate,
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
      state = state.copyWith(
        isLoading: false,
        payments: response.content,
        currentPage: response.page,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
      );
    } catch (e) {
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
    loadPayments(page: 0, status: status);
  }

  void setPaymentMethodFilter(String? paymentMethod) {
    loadPayments(page: 0, paymentMethod: paymentMethod);
  }

  void setDateRangeFilter(DateTime? startDate, DateTime? endDate) {
    loadPayments(page: 0, startDate: startDate, endDate: endDate);
  }

  void clearFilters() {
    state = state.copyWith(clearFilters: true);
    loadPayments(page: 0);
  }

  Future<AdminPayment?> recordPayment(
    int shopId,
    RecordPaymentRequest request,
  ) async {
    try {
      final payment = await _repository.recordPayment(shopId, request);
      loadPayments(); // Refresh list
      return payment;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<AdminPayment?> updatePaymentStatus(
    int paymentId,
    UpdatePaymentStatusRequest request,
  ) async {
    try {
      final payment = await _repository.updatePaymentStatus(paymentId, request);
      // Update the payment in the list
      final updatedPayments = state.payments.map((p) {
        return p.id == paymentId ? payment : p;
      }).toList();
      state = state.copyWith(payments: updatedPayments);
      return payment;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
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
