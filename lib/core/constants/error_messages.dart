/// Readable text for the stable `ERR_*` codes the backend returns.
///
/// Every service on the backend throws a bare code rather than a sentence,
/// because the shop-facing Flutter app translates by code. The admin console is
/// English-only, but it was showing those raw codes straight to the operator —
/// an admin cancelling a subscription would see `ERR_NO_ACTIVE_SUBSCRIPTION` in
/// a snackbar. Anything not listed here falls through unchanged, so a new code
/// is still readable, just not polished.
abstract final class ErrorMessages {
  static const Map<String, String> _messages = {
    // --- Subscription lifecycle ---
    'ERR_NO_ACTIVE_SUBSCRIPTION':
        'This shop has no active subscription to change.',
    'ERR_NO_SUBSCRIPTION_FOUND': 'This shop has no subscription record.',
    'ERR_ACTIVE_SUBSCRIPTION_EXISTS':
        'This shop already has a live subscription.',
    'ERR_NO_INACTIVE_SUBSCRIPTION_FOUND':
        'There is no expired or cancelled subscription to reactivate.',
    'ERR_SUBSCRIPTION_NOT_FOUND': 'Subscription not found.',
    'ERR_SUBSCRIPTION_EXPIRED': 'This subscription has expired.',
    'ERR_CANNOT_REDUCE_BELOW_CURRENT_DATE':
        'That would move the expiry date into the past.',
    'ERR_LIFETIME_SUBSCRIPTION':
        'A lifetime subscription is never renewed, so it cannot auto-renew.',
    'ERR_INVALID_BILLING_CYCLE':
        'Billing cycle must be monthly, yearly or lifetime.',
    'ERR_AUTO_RENEW_REQUIRED': 'Choose whether auto-renew should be on or off.',

    // --- Approval flow (shop-side self-service is restricted) ---
    'ERR_UPGRADE_REQUIRES_APPROVAL':
        'A paid plan cannot be self-assigned; it needs admin approval.',
    'ERR_RENEWAL_REQUIRES_APPROVAL':
        'Renewing a paid plan needs admin approval.',
    'ERR_PENDING_UPGRADE_EXISTS':
        'This shop already has an upgrade request awaiting review.',
    'ERR_REQUEST_NOT_PENDING': 'This request has already been reviewed.',
    'ERR_UPGRADE_REQUEST_NOT_FOUND': 'Upgrade request not found.',
    'ERR_ALREADY_ON_PLAN': 'The shop is already on that plan and cycle.',

    // --- Plans ---
    'ERR_PLAN_NOT_FOUND': 'Plan not found.',
    'ERR_PLAN_NOT_ACTIVE': 'That plan is not active and cannot be assigned.',
    'ERR_PLAN_CODE_EXISTS': 'A plan with that code already exists.',
    'ERR_INVALID_PLAN_FEATURES': 'The plan features are not valid JSON.',
    'ERR_TRIAL_DAYS_REQUIRED':
        'A plan offering a trial needs at least one trial day.',
    'ERR_PLAN_LIMIT_EXCEEDED': 'The shop is over its plan limits.',

    // --- Payments ---
    'ERR_PAYMENT_DATE_IN_FUTURE': 'A payment cannot be dated in the future.',
    'ERR_PAYMENT_ALREADY_RECORDED':
        'A payment with that transaction ID is already recorded.',
    'ERR_INVOICE_NUMBER_EXISTS': 'That invoice number is already in use.',
    'ERR_PAYMENT_NOT_FOUND': 'Payment not found.',

    // --- Shops & general ---
    'ERR_SHOP_NOT_FOUND': 'Shop not found.',
    'ERR_SHOP_DELETED': 'This shop has been deleted.',
    'ERR_UNAUTHORIZED': 'You are not allowed to do that.',
    'ERR_NOT_AUTHORIZED': 'You are not allowed to do that.',
    'ERR_UNEXPECTED': 'Something went wrong. Please try again.',
  };

  /// The readable text for [code], or `null` when the code is unknown.
  static String? lookup(String code) => _messages[code.trim()];

  /// True when [text] looks like one of the backend's bare error codes.
  static bool isCode(String text) =>
      RegExp(r'^ERR_[A-Z0-9_]+$').hasMatch(text.trim());
}
