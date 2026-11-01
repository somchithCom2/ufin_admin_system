import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscriptions_list_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

typedef _Query = ({
  String? status,
  String? planCode,
  bool paid,
  String? search,
});

class _Repository implements AdminRepository {
  final List<_Query> queries = [];
  List<AdminSubscription> rows = const [
    AdminSubscription(
      id: 1,
      shopId: 1,
      shopName: 'Noy Cafe',
      planName: 'Silver',
      status: 'active',
    ),
  ];

  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
    String? planCode,
    bool paid = false,
    String? search,
  }) async {
    queries.add((
      status: status,
      planCode: planCode,
      paid: paid,
      search: search,
    ));
    return PaginatedResponse(
      content: rows,
      page: 0,
      size: 20,
      totalElements: rows.length,
      totalPages: 1,
      isFirst: true,
      isLast: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Repository repository;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SubscriptionsListPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() => repository = _Repository());

  testWidgets('opens on paying shops, with a count, and fits a phone', (
    tester,
  ) async {
    await open(tester);

    expect(tester.takeException(), isNull);
    expect(repository.queries.single.paid, isTrue);
    expect(find.text('Noy Cafe'), findsOneWidget);
    expect(find.text('1 subscription'), findsOneWidget);
  });

  testWidgets('plan and status filters combine with the search', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), ' noy ');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(repository.queries.last.search, 'noy');
    expect(repository.queries.last.paid, isTrue);

    await tester.tap(find.text('Free'));
    await tester.pumpAndSettle();
    expect(repository.queries.last.planCode, 'free');
    expect(repository.queries.last.paid, isFalse);
    expect(repository.queries.last.search, 'noy');

    await tester.ensureVisible(find.text('Expired'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expired'));
    await tester.pumpAndSettle();
    expect(repository.queries.last.status, 'expired');
    expect(repository.queries.last.planCode, 'free');

    await tester.tap(find.text('All plans'));
    await tester.pumpAndSettle();
    expect(repository.queries.last.planCode, isNull);
    expect(repository.queries.last.paid, isFalse);
  });

  testWidgets('a search with no paid match can widen to all plans', (
    tester,
  ) async {
    repository.rows = const [];
    await open(tester);

    await tester.enterText(find.byType(TextField), 'trial shop');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Search all plans'));
    await tester.pumpAndSettle();

    expect(repository.queries.last.paid, isFalse);
    expect(repository.queries.last.search, 'trial shop');
  });

  testWidgets('refresh after an action keeps the filters', (tester) async {
    await open(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SubscriptionsListPage)),
    );

    await tester.tap(find.text('Free'));
    await tester.pumpAndSettle();
    await container.read(subscriptionsProvider.notifier).refresh();

    expect(repository.queries.last.planCode, 'free');
  });
}
