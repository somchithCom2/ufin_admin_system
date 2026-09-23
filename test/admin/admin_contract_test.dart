import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';

void main() {
  late Dio dio;
  late AdminRepository repository;
  final requests = <RequestOptions>[];
  dynamic responseBody;
  setUp(() {
    requests.clear();
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: responseBody,
            ),
          );
        },
      ),
    );
    repository = AdminRepository(dio: dio);
  });
  tearDown(() => dio.close());

  test(
    'Spring pages retain page number, size and full last-page flag',
    () async {
      responseBody = {
        'success': true,
        'data': {
          'content': [
            {'id': 3},
            {'id': 4},
          ],
          'number': 1,
          'size': 2,
          'totalElements': 4,
          'totalPages': 2,
          'first': false,
          'last': true,
        },
      };
      final result = await repository.getUsers(page: 1, size: 2);
      expect(result.page, 1);
      expect(result.size, 2);
      expect(result.hasNext, false);
      expect(result.isFirst, false);
    },
  );

  test('supports PagedModel metadata and empty pages', () async {
    responseBody = {
      'success': true,
      'data': {
        'content': [],
        'page': {'number': 0, 'size': 20, 'totalElements': 0, 'totalPages': 0},
      },
    };
    final result = await repository.getUsers();
    expect(result.content, isEmpty);
    expect(result.hasNext, false);
  });

  test('supports product pagination DTO and explicit hasNext', () async {
    responseBody = {
      'success': true,
      'data': {
        'data': [
          {'id': 1},
        ],
        'currentPage': 2,
        'pageSize': 1,
        'totalElements': 3,
        'totalPages': 3,
        'hasNext': false,
        'hasPrevious': true,
      },
    };
    final result = await repository.getUsers();
    expect(result.page, 2);
    expect(result.hasNext, false);
  });

  test(
    'activation accepts empty success and rejects failure envelopes',
    () async {
      responseBody = {'success': true};
      await repository.activatePlan(9);
      expect(requests.single.method, 'PUT');
      expect(requests.single.path, '/admin/plans/9/activate');
      responseBody = {'success': false, 'message': 'denied'};
      await expectLater(
        repository.deactivatePlan(9),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test('user deletion uses DELETE and validates success', () async {
    responseBody = {'success': true};
    await repository.deleteUser(5);
    expect(requests.single.method, 'DELETE');
    expect(requests.single.path, '/admin/users/5');
  });

  test('malformed pages are errors instead of empty results', () async {
    responseBody = {'success': true, 'data': {}};
    await expectLater(repository.getUsers(), throwsA(isA<ApiException>()));
  });

  test('plan updates retain translations and explicitly clear limits', () {
    final plan = AdminPlan.fromJson({
      'id': 1,
      'name': {'en': 'Pro', 'lo': 'ພຣໍ'},
      'description': {'lo': 'ທົດສອບ'},
    });
    final request = UpdatePlanRequest(
      name: plan.localizedNames,
      description: plan.localizedDescriptions,
      replaceLimits: true,
      maxProducts: 20,
    );
    expect(request.toJson()['name'], {'en': 'Pro', 'lo': 'ພຣໍ'});
    expect(request.toJson().containsKey('maxEmployees'), true);
    expect(request.toJson()['maxEmployees'], null);
    expect(
      const UpdatePlanRequest(
        isActive: false,
      ).toJson().containsKey('maxEmployees'),
      false,
    );
  });

  test(
    'payments read paidAt with createdAt fallback and invoice reference',
    () {
      final json = <String, dynamic>{
        'id': 1,
        'shopId': 2,
        'amount': 10.25,
        'createdAt': '2026-09-01T10:00:00',
        'paidAt': '2026-09-02T10:00:00',
        'invoiceNumber': 'INV-1',
      };
      expect(AdminPayment.fromJson(json).paymentDate.day, 2);
      expect(AdminPayment.fromJson(json).referenceNumber, 'INV-1');
      json['paidAt'] = null;
      expect(AdminPayment.fromJson(json).paymentDate.day, 1);
    },
  );

  test('payment date filters include the complete selected end day', () async {
    responseBody = {
      'success': true,
      'data': {
        'content': [],
        'number': 0,
        'size': 20,
        'totalElements': 0,
        'totalPages': 0,
      },
    };
    await repository.getPayments(
      endDate: DateTime(2026, 9, 30),
      paymentMethod: 'cash',
    );
    expect(
      requests.single.queryParameters['endDate'],
      '2026-10-01T00:00:00.000',
    );
    expect(requests.single.queryParameters['paymentMethod'], 'cash');
  });

  test('expiring subscriptions parse backend localized names and expiry', () {
    final value = ExpiringSubscription.fromJson({
      'id': 1,
      'shopId': 2,
      'planName': {'lo': 'ພຣໍ'},
      'expiresAt': '2026-10-01T00:00:00',
      'daysUntilExpiry': 8,
    });
    expect(value.planName, 'ພຣໍ');
    expect(value.endDate.month, 10);
    expect(value.daysUntilExpiry, 8);
  });

  test('revenue maps backend counts and groups daily data by week', () {
    final report = AdminRevenueReport.fromJson({
      'startDate': '2026-09-01',
      'endDate': '2026-09-30',
      'totalRevenue': 30,
      'paymentCount': 3,
      'successfulPayments': 2,
      'failedPayments': 1,
      'revenueByPlan': {'PRO': 30},
      'paymentCountByPlan': {'PRO': 2},
      'revenueByPaymentMethod': {'cash': 30},
      'paymentCountByMethod': {'cash': 2},
      'dailyRevenue': [
        {'date': '2026-09-01', 'revenue': 10, 'paymentCount': 1},
        {'date': '2026-09-02', 'revenue': 20, 'paymentCount': 1},
      ],
    }, groupBy: 'week');
    expect(report.totalTransactions, 3);
    expect(report.averageTransactionValue, 15);
    expect(report.revenueByPeriod.single.period, '2026-08-31');
    expect(report.revenueByPeriod.single.revenue, 30);
    expect(report.revenueByPlan.single.percentage, 100);
    expect(report.revenueByPaymentMethod.single.transactionCount, 2);
  });

  test('subscription lifecycle requests match backend field names', () {
    expect(
      const CreateSubscriptionRequest(
        planCode: 'PRO',
        billingCycle: 'yearly',
        startAsTrial: true,
      ).toJson(),
      {'planCode': 'PRO', 'billingCycle': 'yearly', 'startAsTrial': true},
    );
    expect(
      const CancelSubscriptionRequest(
        reason: 'Requested',
        immediate: true,
      ).toJson(),
      {'reason': 'Requested', 'immediateEffect': true},
    );
    expect(
      const ReactivateSubscriptionRequest(billingCycle: 'monthly').toJson(),
      {'billingCycle': 'monthly'},
    );
  });
}
