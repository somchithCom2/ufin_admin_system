import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/edit_plan_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class PlanRepository extends AdminRepository {
  PlanRepository() : super(dio: Dio());
  CreatePlanRequest? created;
  UpdatePlanRequest? updated;
  bool fail = false;
  final plan = AdminPlan.fromJson({
    'id': 4,
    'code': 'PRO',
    'name': {'en': 'Pro', 'lo': 'ພຣໍ'},
    'priceMonthly': 12.25,
    'priceYearly': 120.50,
    'maxEmployees': 5,
  });
  @override
  Future<List<AdminPlan>> getPlans() async => [plan];
  @override
  Future<AdminPlan> getPlanById(int id) async => plan;
  @override
  Future<AdminPlan> createPlan(CreatePlanRequest request) async {
    if (fail) throw ApiException(message: 'Duplicate plan code');
    created = request;
    return plan;
  }

  @override
  Future<AdminPlan> updatePlan(int id, UpdatePlanRequest request) async {
    updated = request;
    return plan;
  }
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  Future<void> open(
    WidgetTester tester,
    PlanRepository repository, {
    bool edit = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        EditPlanPage(plan: edit ? repository.plan : null),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('creates a free plan with localized names', (tester) async {
    final repository = PlanRepository();
    await open(tester, repository);
    await tester.enterText(field('Plan Code *'), 'FREE');
    await tester.enterText(field('Plan Name (en)'), 'Free');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.created?.name, {'en': 'Free'});
    expect(repository.created?.priceMonthly, 0);
    expect(repository.created?.maxEmployees, null);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets(
    'editing preserves decimals and translations and clears a limit',
    (tester) async {
      final repository = PlanRepository();
      await open(tester, repository, edit: true);
      await tester.ensureVisible(field('Max Employees'));
      await tester.enterText(field('Max Employees'), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.updated?.name?['lo'], 'ພຣໍ');
      expect(repository.updated?.priceMonthly, 12.25);
      expect(repository.updated?.priceYearly, 120.50);
      expect(repository.updated?.toJson().containsKey('maxEmployees'), true);
      expect(repository.updated?.toJson()['maxEmployees'], null);
    },
  );

  testWidgets('invalid offscreen prices prevent save and errors retain input', (
    tester,
  ) async {
    final repository = PlanRepository();
    await open(tester, repository);
    await tester.enterText(field('Plan Code *'), 'PRO');
    await tester.enterText(field('Plan Name (en)'), 'Pro');
    await tester.ensureVisible(field('Monthly Price'));
    await tester.enterText(field('Monthly Price'), 'NaN');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(repository.created, null);
    await tester.enterText(field('Monthly Price'), '12.25');
    repository.fail = true;
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Create Plan'), findsOneWidget);
    expect(find.text('Duplicate plan code'), findsOneWidget);
    expect(find.text('12.25'), findsOneWidget);
  });
}
