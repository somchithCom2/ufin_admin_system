import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/constants/api_constants.dart';
import 'package:ufin_admin_system/core/services/dio_client.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

/// Cover for the console's side of the payment-funded renewal model: the admin
/// has to be able to see whether a recorded payment will actually carry the
/// shop forward, and the bare `ERR_` codes the backend returns must not reach
/// the operator unread.
void main() {
  Map<String, dynamic> paymentJson({
    String? appliedAt,
    String status = 'completed',
    String? billingPeriodEnd,
  }) => {
    'id': 1,
    'shopId': 5,
    'shopName': 'Mekong Mart',
    'amount': 200000,
    'currency': 'LAK',
    'paymentMethod': 'cash',
    'status': status,
    'paidAt': '2026-09-01T10:00:00',
    'createdAt': '2026-09-01T10:00:00',
    if (appliedAt != null) 'appliedAt': appliedAt,
    if (billingPeriodEnd != null) 'billingPeriodEnd': billingPeriodEnd,
  };

  group('AdminPayment funding state', () {
    test('an unspent completed payment funds the next renewal', () {
      final payment = AdminPayment.fromJson(paymentJson());

      expect(payment.appliedAt, isNull);
      expect(payment.isAvailableForRenewal, isTrue);
    });

    test('a spent payment cannot fund another renewal', () {
      final payment = AdminPayment.fromJson(
        paymentJson(
          appliedAt: '2026-10-01T00:00:00',
          billingPeriodEnd: '2026-11-01T00:00:00',
        ),
      );

      expect(payment.isAvailableForRenewal, isFalse);
      expect(payment.billingPeriodEnd, DateTime(2026, 11, 1));
    });

    test('a pending payment funds nothing', () {
      final payment = AdminPayment.fromJson(paymentJson(status: 'pending'));

      expect(payment.isAvailableForRenewal, isFalse);
    });

    test('an older backend without appliedAt still parses', () {
      final json = paymentJson()..remove('appliedAt');

      expect(AdminPayment.fromJson(json).appliedAt, isNull);
    });
  });

  group('UpdateAutoRenewRequest', () {
    test('sends the flag and drops a blank reason', () {
      expect(const UpdateAutoRenewRequest(autoRenew: true).toJson(), {
        'autoRenew': true,
      });
      expect(
        const UpdateAutoRenewRequest(autoRenew: false, reason: '  ').toJson(),
        {'autoRenew': false},
      );
      expect(
        const UpdateAutoRenewRequest(
          autoRenew: false,
          reason: ' Shop asked ',
        ).toJson(),
        {'autoRenew': false, 'reason': 'Shop asked'},
      );
    });

    test('targets the auto-renew endpoint for the shop', () {
      expect(
        ApiConstants.adminSubscriptionAutoRenew(7),
        '/admin/subscriptions/shop/7/auto-renew',
      );
    });
  });

  group('error codes are readable', () {
    test('known subscription codes become sentences', () {
      expect(
        friendlyError(ApiException(message: 'ERR_NO_ACTIVE_SUBSCRIPTION')),
        'This shop has no active subscription to change.',
      );
      expect(
        friendlyError(ApiException(message: 'ERR_LIFETIME_SUBSCRIPTION')),
        'A lifetime subscription is never renewed, so it cannot auto-renew.',
      );
      expect(
        friendlyError(ApiException(message: 'ERR_UPGRADE_REQUIRES_APPROVAL')),
        'A paid plan cannot be self-assigned; it needs admin approval.',
      );
    });

    test('an unmapped code is still readable rather than shouted', () {
      expect(
        friendlyError(ApiException(message: 'ERR_SOME_NEW_THING')),
        'Some new thing',
      );
    });

    test('ordinary messages are left alone', () {
      expect(
        friendlyError(ApiException(message: 'Plan code already exists')),
        'Plan code already exists',
      );
    });
  });

  group('SubscriptionHistory labels', () {
    SubscriptionHistory history(String action) => SubscriptionHistory.fromJson({
      'id': 1,
      'shopId': 5,
      'action': action,
      'createdAt': '2026-09-01T10:00:00',
    });

    test('the new auto-renew actions have labels', () {
      expect(history('auto_renew_enabled').actionDisplayText, 'Auto-renew On');
      expect(
        history('auto_renew_disabled').actionDisplayText,
        'Auto-renew Off',
      );
    });

    test('previously unlabelled backend actions read properly', () {
      expect(history('trial_ended').actionDisplayText, 'Trial Ended');
      expect(history('payment_received').actionDisplayText, 'Payment Received');
      expect(history('expired').actionDisplayText, 'Expired');
    });
  });
}
