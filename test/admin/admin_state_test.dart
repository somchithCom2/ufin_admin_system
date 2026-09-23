import 'dart:async';
import 'package:ufin_admin_system/features/admin/presentation/providers/payments_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class PendingUsersRepository extends AdminRepository {
  PendingUsersRepository() : super(dio: Dio());
  final pending = <Completer<PaginatedResponse<AdminUser>>>[];
  final sizes = <int>[];
  @override
  Future<PaginatedResponse<AdminUser>> getUsers({
    int page = 0,
    int size = 20,
    String? search,
    String? status,
    String? userType,
  }) {
    final completer = Completer<PaginatedResponse<AdminUser>>();
    pending.add(completer);
    sizes.add(size);
    return completer.future;
  }
}

PaginatedResponse<AdminUser> page(int id, {bool last = true}) =>
    PaginatedResponse(
      content: [
        AdminUser(
          id: id,
          username: '$id',
          userType: 'CLIENT',
          status: 'active',
        ),
      ],
      page: 0,
      size: 2,
      totalElements: last ? 1 : 4,
      totalPages: last ? 1 : 2,
      isFirst: true,
      isLast: last,
    );
void main() {
  test(
    'individual payment filters can be cleared without clearing other filters',
    () {
      final state = PaymentsState(
        statusFilter: 'completed',
        paymentMethodFilter: 'cash',
        startDateFilter: DateTime(2026, 9, 1),
      );
      final changed = state.copyWith(statusFilter: null);
      expect(changed.statusFilter, null);
      expect(changed.paymentMethodFilter, 'cash');
      expect(changed.startDateFilter, DateTime(2026, 9, 1));
      expect(
        changed.copyWith(paymentMethodFilter: null).paymentMethodFilter,
        null,
      );
    },
  );

  test('newer search wins when old response arrives later', () async {
    final repository = PendingUsersRepository();
    final notifier = UsersNotifier(repository);
    final old = notifier.loadUsers(search: 'old');
    final newer = notifier.loadUsers(search: 'new');
    repository.pending[1].complete(page(2));
    await newer;
    repository.pending[0].complete(page(1));
    await old;
    expect(notifier.state.users.single.id, 2);
    notifier.dispose();
  });
  test(
    'refresh discards an in-flight append and retains requested page size',
    () async {
      final repository = PendingUsersRepository();
      final notifier = UsersNotifier(repository);
      final initial = notifier.loadUsers(size: 2);
      repository.pending[0].complete(page(1, last: false));
      await initial;
      final append = notifier.loadMoreUsers();
      final refresh = notifier.loadUsers(search: 'new', size: 2);
      repository.pending[2].complete(page(3));
      await refresh;
      repository.pending[1].complete(page(2));
      await append;
      expect(notifier.state.users.map((u) => u.id), [3]);
      expect(repository.sizes, [2, 2, 2]);
      notifier.dispose();
    },
  );
}
