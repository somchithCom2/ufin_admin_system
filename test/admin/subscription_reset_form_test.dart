import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/constants/api_constants.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/subscription_reset_form.dart';

void main() {
  const free = AdminSubscription(
    id: 1,
    shopId: 5,
    shopName: 'Mekong Mart',
    status: 'expired',
    planCode: 'free',
  );
  const silver = AdminSubscription(
    id: 2,
    shopId: 5,
    shopName: 'Mekong Mart',
    status: 'active',
    planCode: 'silver',
  );

  Future<void> open(
    WidgetTester tester,
    AdminSubscription subscription,
    Future<void> Function(int? days, String? reason) save,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSubscriptionResetForm(
                context,
                subscription: subscription,
                save: save,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('left empty, a locked Free shop gets a full new trial', (
    tester,
  ) async {
    int? sent = -1;
    await open(tester, free, (days, reason) async => sent = days);

    expect(find.textContaining('full new trial'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(sent, isNull);
  });

  testWidgets('days left go to the server as entered', (tester) async {
    int? sent;
    await open(tester, free, (days, reason) async => sent = days);

    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(sent, 5);
  });

  testWidgets('0 on a paid plan says it ends the plan', (tester) async {
    await open(tester, silver, (days, reason) async {});

    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.pump();

    expect(find.textContaining('moves the shop to Free'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'End now'), findsOneWidget);
  });

  test('the repository calls the reset endpoint', () async {
    RequestOptions? seen;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            seen = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'success': true,
                  'data': {
                    'id': 1,
                    'shopId': 5,
                    'shopName': 'Shop',
                    'status': 'trial',
                  },
                },
              ),
            );
          },
        ),
      );

    await AdminRepository(
      dio: dio,
    ).resetSubscription(5, const ResetSubscriptionRequest(days: 0));

    expect(seen!.method, 'PUT');
    expect(seen!.path, ApiConstants.adminSubscriptionReset(5));
    expect(seen!.data, {'days': 0});
  });
}
