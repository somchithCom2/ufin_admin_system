import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

// ========== Daily Sales ==========
class DailySalesState {
  final bool isLoading;
  final String? error;
  final DailySalesData? data;

  const DailySalesState({this.isLoading = false, this.error, this.data});

  DailySalesState copyWith({
    bool? isLoading,
    String? error,
    DailySalesData? data,
    bool clearError = false,
  }) {
    return DailySalesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      data: data ?? this.data,
    );
  }
}

class DailySalesNotifier extends StateNotifier<DailySalesState> {
  final AdminRepository _repository;

  DailySalesNotifier(this._repository) : super(const DailySalesState());

  Future<void> loadDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.getDailySales(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(isLoading: false, data: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    if (state.data != null) {
      loadDailySales(
        startDate: state.data!.date.subtract(const Duration(days: 1)),
        endDate: state.data!.date,
      );
    }
  }
}

final dailySalesProvider =
    StateNotifierProvider<DailySalesNotifier, DailySalesState>((ref) {
      final repository = ref.watch(adminRepositoryProvider);
      return DailySalesNotifier(repository);
    });
