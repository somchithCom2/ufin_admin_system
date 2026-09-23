import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/subscription_action_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class LifecycleRepository extends AdminRepository {
  LifecycleRepository() : super(dio: Dio());
  CreateSubscriptionRequest? created;
  CancelSubscriptionRequest? cancelled;
  final subscription = const AdminSubscription(
    id: 1,
    shopId: 5,
    shopName: 'Shop',
    status: 'active',
  );
  @override
  Future<List<AdminPlan>> getPlans() async => [
    const AdminPlan(
      id: 2,
      code: 'PRO',
      name: 'Pro',
      isTrialAvailable: true,
      trialDays: 7,
    ),
  ];
  @override
  Future<AdminSubscription> createSubscription(
    int shopId,
    CreateSubscriptionRequest request,
  ) async {
    created = request;
    return subscription;
  }

  @override
  Future<AdminSubscription> cancelSubscription(
    int shopId,
    CancelSubscriptionRequest request,
  ) async {
    cancelled = request;
    return subscription;
  }

  @override
  Future<AdminDashboardStats> getDashboardStats() async =>
      AdminDashboardStats.fromJson({});
  @override
  Future<PaginatedResponse<AdminSubscription>> getSubscriptions({
    int page = 0,
    int size = 20,
    String? status,
  }) async => PaginatedResponse(
    content: [subscription],
    page: 0,
    size: 20,
    totalElements: 1,
    totalPages: 1,
    isFirst: true,
    isLast: true,
  );
}

void main() {
  Future<void> open(
    WidgetTester tester,
    LifecycleRepository repository,
    SubscriptionAction action,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<AdminSubscription>(
                    builder: (_) => SubscriptionActionPage(
                      action: action,
                      subscription: action == SubscriptionAction.create
                          ? null
                          : repository.subscription,
                    ),
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

  testWidgets(
    'create subscription submits plan trial flag and valid billing cycle',
    (tester) async {
      final repository = LifecycleRepository();
      await open(tester, repository, SubscriptionAction.create);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Shop ID'),
        '5',
      );
      await tester.tap(find.text('Start with 7 trial days'));
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create Subscription'),
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Create Subscription'),
      );
      await tester.pumpAndSettle();
      expect(repository.created?.planCode, 'PRO');
      expect(repository.created?.startAsTrial, true);
      expect(repository.created?.billingCycle, 'monthly');
    },
  );
  testWidgets('cancellation requires a reason and sends immediateEffect', (
    tester,
  ) async {
    final repository = LifecycleRepository();
    await open(tester, repository, SubscriptionAction.cancel);
    final button = find.widgetWithText(FilledButton, 'Cancel Subscription');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repository.cancelled, null);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reason'),
      'Owner request',
    );
    await tester.ensureVisible(find.text('Cancel immediately'));
    await tester.tap(find.text('Cancel immediately'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repository.cancelled?.toJson()['immediateEffect'], true);
    expect(repository.cancelled?.reason, 'Owner request');
  });
}
