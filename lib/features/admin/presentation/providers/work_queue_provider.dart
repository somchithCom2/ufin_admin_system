import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

/// What is waiting on an admin: requests to review, plans about to end and
/// shops that have lapsed onto Free.
///
/// Each part loads on its own, so one failing endpoint leaves the others on
/// screen; a part that failed is `null`.
class WorkQueue {
  /// Days ahead the expiring list looks. Matches the dashboard's "expiring
  /// soon" count and the warning the shop app shows its owner.
  static const expiringWithinDays = 7;

  final int? pendingRequests;

  /// The oldest pending requests, the ones to review first.
  final List<UpgradeRequestDto> pendingPreview;

  /// Active and trial subscriptions ending within [expiringWithinDays],
  /// soonest first.
  final List<AdminSubscription>? expiring;

  /// Subscriptions whose trial or paid plan ended; the backend moves these to
  /// Free with status `expired`.
  final int? lapsed;

  /// Whether Free withholds new bills (its `sales` feature is false). When it
  /// does, a lapsed shop cannot sell until a plan is paid. `null` when the
  /// plans could not be read.
  final bool? freeWithholdsSales;

  const WorkQueue({
    this.pendingRequests,
    this.pendingPreview = const [],
    this.expiring,
    this.lapsed,
    this.freeWithholdsSales,
  });

  List<AdminSubscription> get trialsEnding =>
      (expiring ?? const []).where((s) => s.isTrial).toList(growable: false);

  List<AdminSubscription> get paidExpiring =>
      (expiring ?? const []).where((s) => !s.isTrial).toList(growable: false);

  /// True when some part could not be loaded.
  bool get isPartial =>
      pendingRequests == null || expiring == null || lapsed == null;

  /// True when every part loaded and none has anything in it.
  bool get isClear =>
      !isPartial && pendingRequests == 0 && expiring!.isEmpty && lapsed == 0;
}

class WorkQueueState {
  final bool isLoading;
  final WorkQueue? queue;

  const WorkQueueState({this.isLoading = false, this.queue});
}

class WorkQueueNotifier extends StateNotifier<WorkQueueState> {
  final AdminRepository _repository;

  /// Refreshes asked for without `force` within this window are skipped, so
  /// flicking between sections does not re-read the queue every time.
  static const _minInterval = Duration(seconds: 30);

  DateTime? _loadedAt;
  Future<void>? _inFlight;
  bool _again = false;

  WorkQueueNotifier(this._repository) : super(const WorkQueueState()) {
    refresh(force: true);
  }

  /// Reloads the queue. Without [force], a load in the last 30 seconds is
  /// reused. A refresh asked for while one is running runs once more after it,
  /// so a change made mid-load is not missed.
  Future<void> refresh({bool force = false}) {
    final loadedAt = _loadedAt;
    if (!force &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) < _minInterval) {
      return Future.value();
    }
    if (_inFlight != null) {
      _again = true;
      return _inFlight!;
    }
    return _inFlight = _load().whenComplete(() {
      _inFlight = null;
      if (_again && mounted) {
        _again = false;
        refresh(force: true);
      }
    });
  }

  Future<void> _load() async {
    state = WorkQueueState(isLoading: true, queue: state.queue);
    final results = await Future.wait<Object?>([
      _attempt(
        () =>
            _repository.getUpgradeRequests(page: 0, size: 3, status: 'PENDING'),
      ),
      _attempt(
        () => _repository.getExpiringAdminSubscriptions(
          days: WorkQueue.expiringWithinDays,
        ),
      ),
      _attempt(
        () => _repository.getSubscriptions(page: 0, size: 1, status: 'expired'),
      ),
      _attempt(_repository.getPlans),
    ]);
    if (!mounted) return;

    final requests = results[0] as PaginatedResponse<UpgradeRequestDto>?;
    final expiring = (results[1] as List<AdminSubscription>?)?.toList()
      ?..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    final lapsed = results[2] as PaginatedResponse<AdminSubscription>?;
    final plans = results[3] as List<AdminPlan>?;

    _loadedAt = DateTime.now();
    state = WorkQueueState(
      queue: WorkQueue(
        pendingRequests: requests?.totalElements,
        pendingPreview: requests?.content ?? const [],
        expiring: expiring,
        lapsed: lapsed?.totalElements,
        freeWithholdsSales: plans == null ? null : _freeWithholdsSales(plans),
      ),
    );
  }

  static Future<T?> _attempt<T>(Future<T> Function() load) async {
    try {
      return await load();
    } catch (_) {
      return null;
    }
  }

  /// Mirrors the backend: only an explicit `"sales": false` withholds selling.
  static bool? _freeWithholdsSales(List<AdminPlan> plans) {
    for (final plan in plans) {
      if (plan.code.toLowerCase() == 'free') {
        return plan.features['sales'] == false;
      }
    }
    return null;
  }
}

final workQueueProvider =
    StateNotifierProvider<WorkQueueNotifier, WorkQueueState>((ref) {
      final notifier = WorkQueueNotifier(ref.watch(adminRepositoryProvider));
      // A request approved or rejected changes what is pending.
      ref.listen(
        upgradeRequestsProvider.select((s) => s.requests),
        (_, _) => notifier.refresh(force: true),
      );
      // Every subscription action ends by reloading the list's first page; a
      // finished reload is the moment the queue may have changed.
      ref.listen(subscriptionsProvider.select((s) => s.isLoading), (
        was,
        isLoading,
      ) {
        if (was == true && !isLoading) notifier.refresh(force: true);
      });
      return notifier;
    });
