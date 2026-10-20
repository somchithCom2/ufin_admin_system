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

    // --- Reports ---
    'ERR_INVALID_CURRENCY': 'Unknown currency code.',
    'ERR_INVALID_DATE_RANGE':
        'The start date must be before the end date, within 10 years.',

    // --- Shops & general ---
    'ERR_SHOP_NOT_FOUND': 'Shop not found.',
    'ERR_SHOP_DELETED': 'This shop has been deleted.',
    'ERR_SHOP_NOT_DELETED': 'This shop is not deleted.',
    'ERR_SHOP_DELETED_USE_RESTORE':
        'This shop is deleted. Restore it instead of changing its status.',
    'ERR_SHOP_OWNER_DELETED':
        "The shop's owner account is deleted. Restore the owner first.",
    'ERR_PARENT_SHOP_DELETED':
        'This branch belongs to a shop that is still deleted. Restore that shop first.',
    'ERR_SHOP_NAME_ALREADY_EXISTS':
        'The owner already has another shop with this name. Ask them to rename it first.',
    'ERR_INVALID_SHOP_STATUS': 'Unknown shop status.',

    // --- Branch groups and ownership (link, unlink, change owner) ---
    'ERR_SHOP_IS_BRANCH':
        "This is a branch: it runs on its main shop's plan. Change the main shop's subscription instead.",
    'ERR_SHOP_HAS_BRANCHES':
        'This shop has live branches. Unlink or delete its branches first.',
    'ERR_SHOP_ALREADY_A_BRANCH':
        'This shop is already a branch. Unlink it first.',
    'ERR_SHOP_IS_A_BRANCH': "A branch's owner is its group's. Unlink it first.",
    'ERR_SHOP_NOT_A_BRANCH': 'This shop is not a branch.',
    'ERR_PARENT_IS_A_BRANCH':
        'The main shop is itself a branch. Groups are one level deep: pick its main shop.',
    'ERR_SHOP_CANNOT_BE_OWN_PARENT': 'A shop cannot be its own main shop.',
    'ERR_PARENT_SHOP_ID_REQUIRED': 'Choose the main shop.',
    'ERR_PARENT_SHOP_NOT_FOUND': 'Main shop not found.',
    'ERR_PARENT_SHOP_OWNER_DELETED':
        "The main shop's owner account is deleted. Restore it first.",
    'ERR_PARENT_PLAN_LACKS_MULTI_SHOP':
        "The main shop's plan has no branches. Upgrade it, or link anyway for an agreed deal.",
    'ERR_SHOP_OWNER_MISMATCH':
        'The two shops have different owners. Turn on moving it to the main shop\'s owner.',
    'ERR_SHOP_HAS_PAID_SUBSCRIPTION':
        "This shop has paid time left on its own plan. Refund or carry it over, then link.",
    'ERR_SHOP_NAME_CONFIRMATION_REQUIRED': 'Type the shop name to confirm.',
    'ERR_SHOP_NAME_CONFIRMATION_MISMATCH':
        'The name typed does not match the shop. Check you picked the right shop.',
    'ERR_REASON_REQUIRED': 'Enter a reason.',
    'ERR_REASON_TOO_LONG': 'The reason is too long (500 characters at most).',
    'ERR_OWNER_USER_ID_REQUIRED': 'Choose the new owner.',
    'ERR_USER_ALREADY_OWNER': 'That account already owns this shop.',
    'ERR_USER_DELETED': 'That account is deleted.',
    'ERR_INVALID_SHOP_OWNER':
        'Only a shop staff account can own a shop, not a customer or admin account.',

    // --- Users ---
    'ERR_USER_NOT_FOUND': 'User not found.',
    'ERR_ACCOUNT_DELETED_USE_RESTORE':
        'This account is deleted. Restore it first.',
    'ERR_USER_EMAIL_MISSING': 'This user has no email address.',
    'ERR_USER_PHONE_MISSING': 'This user has no phone number.',
    'ERR_INVALID_VERIFICATION_CHANNEL': 'Choose email or phone to verify.',
    'ERR_USERNAME_REQUIRED': 'Enter a username.',
    'ERR_USERNAME_INVALID_LENGTH': 'A username is 3 to 50 characters.',
    'ERR_USERNAME_INVALID_CHARACTERS':
        'Use only English letters, digits, dot, underscore and dash. No spaces or "--".',
    'ERR_USERNAME_ALREADY_IN_USE':
        'Another account already uses that username (ignoring capitals).',
    'ERR_ADMIN_ACCOUNT_PROTECTED': 'Admin accounts cannot be changed here.',
    'ERR_UNAUTHORIZED': 'You are not allowed to do that.',
    'ERR_NOT_AUTHORIZED': 'You are not allowed to do that.',
    'ERR_UNEXPECTED': 'Something went wrong. Please try again.',
    'ERR_INTERNAL_SERVER_ERROR':
        'Something went wrong on the server. Please try again.',
    'ERR_CONCURRENT_MODIFICATION':
        'Someone changed this at the same time. Refresh and try again.',
    'ERR_ROLE_NOT_FOUND':
        'The shop owner role is missing on the server. Nothing was changed; contact a developer.',
  };

  /// The readable text for [code], or `null` when the code is unknown.
  static String? lookup(String code) => _messages[code.trim()];

  /// True when [text] looks like one of the backend's bare error codes.
  static bool isCode(String text) =>
      RegExp(r'^ERR_[A-Z0-9_]+$').hasMatch(text.trim());
}
