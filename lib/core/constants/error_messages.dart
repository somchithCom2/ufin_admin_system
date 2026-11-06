import 'package:ufin_admin_system/l10n/tr.dart';

/// Readable text for the stable `ERR_*` codes the backend returns.
///
/// Every service on the backend throws a bare code rather than a sentence,
/// because client apps translate by code. Anything not listed here falls
/// through unchanged, so a new code is still readable, just not polished.
abstract final class ErrorMessages {
  static const Map<String, Tr> _messages = {
    // --- Subscription lifecycle ---
    'ERR_NO_ACTIVE_SUBSCRIPTION': Tr(
      'This shop has no active subscription to change.',
      'ຮ້ານນີ້ບໍ່ມີການສະໝັກໃຊ້ທີ່ເປີດຢູ່ໃຫ້ປ່ຽນ.',
    ),
    'ERR_NO_SUBSCRIPTION_FOUND': Tr(
      'This shop has no subscription record.',
      'ຮ້ານນີ້ບໍ່ມີຂໍ້ມູນການສະໝັກໃຊ້.',
    ),
    'ERR_ACTIVE_SUBSCRIPTION_EXISTS': Tr(
      'This shop already has a live subscription.',
      'ຮ້ານນີ້ມີການສະໝັກໃຊ້ທີ່ເປີດຢູ່ແລ້ວ.',
    ),
    'ERR_NO_INACTIVE_SUBSCRIPTION_FOUND': Tr(
      'There is no expired or cancelled subscription to reactivate.',
      'ບໍ່ມີການສະໝັກໃຊ້ທີ່ໝົດອາຍຸ ຫຼື ຖືກຍົກເລີກ ໃຫ້ເປີດຄືນ.',
    ),
    'ERR_SUBSCRIPTION_NOT_FOUND': Tr(
      'Subscription not found.',
      'ບໍ່ພົບການສະໝັກໃຊ້.',
    ),
    'ERR_SUBSCRIPTION_EXPIRED': Tr(
      'This subscription has expired.',
      'ການສະໝັກໃຊ້ນີ້ໝົດອາຍຸແລ້ວ.',
    ),
    'ERR_CANNOT_REDUCE_BELOW_CURRENT_DATE': Tr(
      'That would move the expiry date into the past.',
      'ການປ່ຽນນີ້ຈະເຮັດໃຫ້ວັນໝົດອາຍຸຢູ່ໃນອະດີດ.',
    ),
    'ERR_INVALID_DAYS': Tr(
      'Days must be 0 or more.',
      'ຈຳນວນມື້ຕ້ອງເປັນ 0 ຂຶ້ນໄປ.',
    ),
    'ERR_LIFETIME_SUBSCRIPTION': Tr(
      'A lifetime subscription is never renewed, so it cannot auto-renew.',
      'ແພັກເກດຕະຫຼອດຊີບບໍ່ມີການຕໍ່ອາຍຸ ຈຶ່ງບໍ່ສາມາດຕໍ່ອັດຕະໂນມັດໄດ້.',
    ),
    'ERR_INVALID_BILLING_CYCLE': Tr(
      'Billing cycle must be monthly, yearly or lifetime.',
      'ຮອບການຮຽກເກັບເງິນຕ້ອງເປັນ ລາຍເດືອນ, ລາຍປີ ຫຼື ຕະຫຼອດຊີບ.',
    ),
    'ERR_AUTO_RENEW_REQUIRED': Tr(
      'Choose whether auto-renew should be on or off.',
      'ເລືອກວ່າຈະເປີດ ຫຼື ປິດການຕໍ່ອາຍຸອັດຕະໂນມັດ.',
    ),
    'ERR_FREE_PLAN_NEEDS_TRIAL': Tr(
      'Free cannot sell without a trial, so its trial must stay on.',
      'ແພັກເກດຟຣີຂາຍບໍ່ໄດ້ຖ້າບໍ່ມີທົດລອງ ຈຶ່ງຕ້ອງເປີດທົດລອງໄວ້.',
    ),

    // --- Approval flow ---
    'ERR_UPGRADE_REQUIRES_APPROVAL': Tr(
      'A paid plan cannot be self-assigned; it needs admin approval.',
      'ແພັກເກດແບບເສຍເງິນຕ້ອງໄດ້ຮັບການອະນຸມັດຈາກຜູ້ດູແລ.',
    ),
    'ERR_RENEWAL_REQUIRES_APPROVAL': Tr(
      'Renewing a paid plan needs admin approval.',
      'ການຕໍ່ອາຍຸແພັກເກດແບບເສຍເງິນຕ້ອງໄດ້ຮັບການອະນຸມັດຈາກຜູ້ດູແລ.',
    ),
    'ERR_PENDING_UPGRADE_EXISTS': Tr(
      'This shop already has an upgrade request awaiting review.',
      'ຮ້ານນີ້ມີຄຳຂໍອັບເກຣດທີ່ລໍຖ້າກວດສອບຢູ່ແລ້ວ.',
    ),
    'ERR_REQUEST_NOT_PENDING': Tr(
      'This request has already been reviewed.',
      'ຄຳຂໍນີ້ໄດ້ຮັບການກວດສອບແລ້ວ.',
    ),
    'ERR_UPGRADE_REQUEST_NOT_FOUND': Tr(
      'Upgrade request not found.',
      'ບໍ່ພົບຄຳຂໍອັບເກຣດ.',
    ),
    'ERR_ALREADY_ON_PLAN': Tr(
      'The shop is already on that plan and cycle.',
      'ຮ້ານນີ້ໃຊ້ແພັກເກດ ແລະ ຮອບນີ້ຢູ່ແລ້ວ.',
    ),

    // --- Plans ---
    'ERR_PLAN_NOT_FOUND': Tr('Plan not found.', 'ບໍ່ພົບແພັກເກດ.'),
    'ERR_PLAN_NOT_ACTIVE': Tr(
      'That plan is not active and cannot be assigned.',
      'ແພັກເກດນີ້ບໍ່ໄດ້ເປີດໃຊ້ ຈຶ່ງກຳນົດໃຫ້ບໍ່ໄດ້.',
    ),
    'ERR_PLAN_CODE_EXISTS': Tr(
      'A plan with that code already exists.',
      'ມີແພັກເກດທີ່ໃຊ້ລະຫັດນີ້ແລ້ວ.',
    ),
    'ERR_INVALID_PLAN_FEATURES': Tr(
      'The plan features are not valid JSON.',
      'ຄຸນສົມບັດແພັກເກດບໍ່ແມ່ນ JSON ທີ່ຖືກຕ້ອງ.',
    ),
    'ERR_TRIAL_DAYS_REQUIRED': Tr(
      'A plan offering a trial needs at least one trial day.',
      'ແພັກເກດທີ່ມີທົດລອງຕ້ອງມີຢ່າງໜ້ອຍ 1 ມື້ທົດລອງ.',
    ),
    'ERR_PLAN_LIMIT_EXCEEDED': Tr(
      'The shop is over its plan limits.',
      'ຮ້ານນີ້ໃຊ້ເກີນຂີດຈຳກັດຂອງແພັກເກດ.',
    ),

    // --- Payments ---
    'ERR_PAYMENT_DATE_IN_FUTURE': Tr(
      'A payment cannot be dated in the future.',
      'ວັນທີຊຳລະເງິນບໍ່ສາມາດເປັນວັນໃນອະນາຄົດ.',
    ),
    'ERR_PAYMENT_ALREADY_RECORDED': Tr(
      'A payment with that transaction ID is already recorded.',
      'ມີການບັນທຶກການຊຳລະທີ່ໃຊ້ລະຫັດທຸລະກຳນີ້ແລ້ວ.',
    ),
    'ERR_INVOICE_NUMBER_EXISTS': Tr(
      'That invoice number is already in use.',
      'ເລກໃບແຈ້ງໜີ້ນີ້ຖືກໃຊ້ແລ້ວ.',
    ),
    'ERR_PAYMENT_NOT_FOUND': Tr('Payment not found.', 'ບໍ່ພົບການຊຳລະເງິນ.'),

    // --- Reports ---
    'ERR_INVALID_CURRENCY': Tr(
      'Unknown currency code.',
      'ລະຫັດສະກຸນເງິນບໍ່ຖືກຕ້ອງ.',
    ),
    'ERR_INVALID_DATE_RANGE': Tr(
      'The start date must be before the end date, within 10 years.',
      'ວັນເລີ່ມຕ້ອງກ່ອນວັນສິ້ນສຸດ ແລະ ຫ່າງກັນບໍ່ເກີນ 10 ປີ.',
    ),

    // --- Shops & general ---
    'ERR_SHOP_NOT_FOUND': Tr('Shop not found.', 'ບໍ່ພົບຮ້ານ.'),
    'ERR_SHOP_DELETED': Tr('This shop has been deleted.', 'ຮ້ານນີ້ຖືກລຶບແລ້ວ.'),
    'ERR_SHOP_NOT_DELETED': Tr(
      'This shop is not deleted.',
      'ຮ້ານນີ້ບໍ່ໄດ້ຖືກລຶບ.',
    ),
    'ERR_SHOP_DELETED_USE_RESTORE': Tr(
      'This shop is deleted. Restore it instead of changing its status.',
      'ຮ້ານນີ້ຖືກລຶບແລ້ວ. ໃຫ້ກູ້ຄືນແທນການປ່ຽນສະຖານະ.',
    ),
    'ERR_SHOP_OWNER_DELETED': Tr(
      "The shop's owner account is deleted. Restore the owner first.",
      'ບັນຊີເຈົ້າຂອງຮ້ານຖືກລຶບແລ້ວ. ໃຫ້ກູ້ຄືນເຈົ້າຂອງກ່ອນ.',
    ),
    'ERR_PARENT_SHOP_DELETED': Tr(
      'This branch belongs to a shop that is still deleted. Restore that shop first.',
      'ສາຂານີ້ຂຶ້ນກັບຮ້ານທີ່ຍັງຖືກລຶບຢູ່. ໃຫ້ກູ້ຄືນຮ້ານນັ້ນກ່ອນ.',
    ),
    'ERR_SHOP_NAME_ALREADY_EXISTS': Tr(
      'The owner already has another shop with this name. Ask them to rename it first.',
      'ເຈົ້າຂອງມີຮ້ານອື່ນທີ່ໃຊ້ຊື່ນີ້ແລ້ວ. ໃຫ້ເຂົາເຈົ້າປ່ຽນຊື່ກ່ອນ.',
    ),
    'ERR_INVALID_SHOP_STATUS': Tr(
      'Unknown shop status.',
      'ສະຖານະຮ້ານບໍ່ຖືກຕ້ອງ.',
    ),
    'ERR_SHOP_DATA_SHARED_WITH_ANOTHER_SHOP': Tr(
      "Records of another shop are tied to this shop's data, so nothing was removed. Ask a developer to look at the shop.",
      'ມີຂໍ້ມູນຂອງຮ້ານອື່ນເຊື່ອມກັບຂໍ້ມູນຮ້ານນີ້ ຈຶ່ງບໍ່ໄດ້ລຶບຫຍັງ. ກະລຸນາແຈ້ງນັກພັດທະນາໃຫ້ກວດສອບ.',
    ),
    'ERR_SHOP_DATA_RESET_CONFLICT': Tr(
      'The shop changed while resetting, maybe a till just sent a sale. Nothing was removed. Try again.',
      'ຮ້ານມີການປ່ຽນແປງລະຫວ່າງຣີເຊັດ (ອາດມີການຂາຍເຂົ້າມາ). ບໍ່ໄດ້ລຶບຫຍັງ. ກະລຸນາລອງໃໝ່.',
    ),

    // --- Branch groups and ownership ---
    'ERR_SHOP_IS_BRANCH': Tr(
      "This is a branch: it runs on its main shop's plan. Change the main shop's subscription instead.",
      'ນີ້ແມ່ນສາຂາ: ໃຊ້ແພັກເກດຂອງຮ້ານຫຼັກ. ໃຫ້ປ່ຽນການສະໝັກໃຊ້ຂອງຮ້ານຫຼັກແທນ.',
    ),
    'ERR_SHOP_HAS_BRANCHES': Tr(
      'This shop has live branches. Unlink or delete its branches first.',
      'ຮ້ານນີ້ມີສາຂາທີ່ເປີດຢູ່. ໃຫ້ຍົກເລີກການເຊື່ອມ ຫຼື ລຶບສາຂາກ່ອນ.',
    ),
    'ERR_SHOP_ALREADY_A_BRANCH': Tr(
      'This shop is already a branch. Unlink it first.',
      'ຮ້ານນີ້ເປັນສາຂາຢູ່ແລ້ວ. ໃຫ້ຍົກເລີກການເຊື່ອມກ່ອນ.',
    ),
    'ERR_SHOP_IS_A_BRANCH': Tr(
      "A branch's owner is its group's. Unlink it first.",
      'ເຈົ້າຂອງສາຂາແມ່ນເຈົ້າຂອງກຸ່ມ. ໃຫ້ຍົກເລີກການເຊື່ອມກ່ອນ.',
    ),
    'ERR_SHOP_NOT_A_BRANCH': Tr(
      'This shop is not a branch.',
      'ຮ້ານນີ້ບໍ່ແມ່ນສາຂາ.',
    ),
    'ERR_PARENT_IS_A_BRANCH': Tr(
      'The main shop is itself a branch. Groups are one level deep: pick its main shop.',
      'ຮ້ານຫຼັກທີ່ເລືອກເປັນສາຂາຢູ່ແລ້ວ. ກຸ່ມມີໄດ້ຊັ້ນດຽວ: ໃຫ້ເລືອກຮ້ານຫຼັກຂອງມັນ.',
    ),
    'ERR_SHOP_CANNOT_BE_OWN_PARENT': Tr(
      'A shop cannot be its own main shop.',
      'ຮ້ານບໍ່ສາມາດເປັນຮ້ານຫຼັກຂອງຕົນເອງ.',
    ),
    'ERR_PARENT_SHOP_ID_REQUIRED': Tr(
      'Choose the main shop.',
      'ເລືອກຮ້ານຫຼັກ.',
    ),
    'ERR_PARENT_SHOP_NOT_FOUND': Tr('Main shop not found.', 'ບໍ່ພົບຮ້ານຫຼັກ.'),
    'ERR_PARENT_SHOP_OWNER_DELETED': Tr(
      "The main shop's owner account is deleted. Restore it first.",
      'ບັນຊີເຈົ້າຂອງຮ້ານຫຼັກຖືກລຶບແລ້ວ. ໃຫ້ກູ້ຄືນກ່ອນ.',
    ),
    'ERR_PARENT_PLAN_LACKS_MULTI_SHOP': Tr(
      "The main shop's plan has no branches. Upgrade it, or link anyway for an agreed deal.",
      'ແພັກເກດຂອງຮ້ານຫຼັກບໍ່ຮອງຮັບສາຂາ. ໃຫ້ອັບເກຣດ ຫຼື ເຊື່ອມຕາມຂໍ້ຕົກລົງ.',
    ),
    'ERR_SHOP_OWNER_MISMATCH': Tr(
      "The two shops have different owners. Turn on moving it to the main shop's owner.",
      'ສອງຮ້ານມີເຈົ້າຂອງຕ່າງກັນ. ໃຫ້ເປີດການຍ້າຍໄປຫາເຈົ້າຂອງຮ້ານຫຼັກ.',
    ),
    'ERR_SHOP_HAS_PAID_SUBSCRIPTION': Tr(
      'This shop has paid time left on its own plan. Refund or carry it over, then link.',
      'ຮ້ານນີ້ຍັງມີເວລາທີ່ຈ່າຍແລ້ວເຫຼືອຢູ່. ໃຫ້ຄືນເງິນ ຫຼື ໂອນຍ້າຍກ່ອນ ແລ້ວຈຶ່ງເຊື່ອມ.',
    ),
    'ERR_SHOP_NAME_CONFIRMATION_REQUIRED': Tr(
      'Type the shop name to confirm.',
      'ພິມຊື່ຮ້ານເພື່ອຢືນຢັນ.',
    ),
    'ERR_SHOP_NAME_CONFIRMATION_MISMATCH': Tr(
      'The name typed does not match the shop. Check you picked the right shop.',
      'ຊື່ທີ່ພິມບໍ່ກົງກັບຮ້ານ. ກວດເບິ່ງວ່າເລືອກຮ້ານຖືກບໍ່.',
    ),
    'ERR_REASON_REQUIRED': Tr('Enter a reason.', 'ໃສ່ເຫດຜົນ.'),
    'ERR_REASON_TOO_LONG': Tr(
      'The reason is too long (500 characters at most).',
      'ເຫດຜົນຍາວເກີນໄປ (ສູງສຸດ 500 ຕົວອັກສອນ).',
    ),
    'ERR_OWNER_USER_ID_REQUIRED': Tr(
      'Choose the new owner.',
      'ເລືອກເຈົ້າຂອງໃໝ່.',
    ),
    'ERR_USER_ALREADY_OWNER': Tr(
      'That account already owns this shop.',
      'ບັນຊີນີ້ເປັນເຈົ້າຂອງຮ້ານນີ້ຢູ່ແລ້ວ.',
    ),
    'ERR_USER_DELETED': Tr('That account is deleted.', 'ບັນຊີນີ້ຖືກລຶບແລ້ວ.'),
    'ERR_INVALID_SHOP_OWNER': Tr(
      'Only a shop staff account can own a shop, not a customer or admin account.',
      'ມີແຕ່ບັນຊີພະນັກງານຮ້ານທີ່ເປັນເຈົ້າຂອງຮ້ານໄດ້ ບໍ່ແມ່ນບັນຊີລູກຄ້າ ຫຼື ຜູ້ດູແລ.',
    ),

    // --- Users ---
    'ERR_USER_NOT_FOUND': Tr('User not found.', 'ບໍ່ພົບຜູ້ໃຊ້.'),
    'ERR_ACCOUNT_DELETED_USE_RESTORE': Tr(
      'This account is deleted. Restore it first.',
      'ບັນຊີນີ້ຖືກລຶບແລ້ວ. ໃຫ້ກູ້ຄືນກ່ອນ.',
    ),
    'ERR_USER_EMAIL_MISSING': Tr(
      'This user has no email address.',
      'ຜູ້ໃຊ້ນີ້ບໍ່ມີອີເມວ.',
    ),
    'ERR_USER_PHONE_MISSING': Tr(
      'This user has no phone number.',
      'ຜູ້ໃຊ້ນີ້ບໍ່ມີເບີໂທ.',
    ),
    'ERR_INVALID_VERIFICATION_CHANNEL': Tr(
      'Choose email or phone to verify.',
      'ເລືອກອີເມວ ຫຼື ເບີໂທເພື່ອຢືນຢັນ.',
    ),
    'ERR_USERNAME_REQUIRED': Tr('Enter a username.', 'ໃສ່ຊື່ຜູ້ໃຊ້.'),
    'ERR_USERNAME_INVALID_LENGTH': Tr(
      'A username is 3 to 50 characters.',
      'ຊື່ຜູ້ໃຊ້ຕ້ອງມີ 3 ຫາ 50 ຕົວອັກສອນ.',
    ),
    'ERR_USERNAME_INVALID_CHARACTERS': Tr(
      'Use only English letters, digits, dot, underscore and dash. No spaces or "--".',
      'ໃຊ້ໄດ້ສະເພາະຕົວອັກສອນອັງກິດ, ຕົວເລກ, ຈຸດ, _ ແລະ -. ຫ້າມມີຍະຫວ່າງ ຫຼື "--".',
    ),
    'ERR_USERNAME_ALREADY_IN_USE': Tr(
      'Another account already uses that username (ignoring capitals).',
      'ມີບັນຊີອື່ນໃຊ້ຊື່ຜູ້ໃຊ້ນີ້ແລ້ວ (ບໍ່ນັບໂຕໃຫຍ່-ໂຕນ້ອຍ).',
    ),
    'ERR_ADMIN_ACCOUNT_PROTECTED': Tr(
      'Admin accounts cannot be changed here.',
      'ບໍ່ສາມາດແກ້ໄຂບັນຊີຜູ້ດູແລຢູ່ບ່ອນນີ້.',
    ),
    'ERR_UNAUTHORIZED': Tr(
      'You are not allowed to do that.',
      'ທ່ານບໍ່ມີສິດເຮັດແບບນີ້.',
    ),
    'ERR_NOT_AUTHORIZED': Tr(
      'You are not allowed to do that.',
      'ທ່ານບໍ່ມີສິດເຮັດແບບນີ້.',
    ),
    'ERR_UNEXPECTED': Tr(
      'Something went wrong. Please try again.',
      'ເກີດຂໍ້ຜິດພາດ. ກະລຸນາລອງໃໝ່.',
    ),
    'ERR_INTERNAL_SERVER_ERROR': Tr(
      'Something went wrong on the server. Please try again.',
      'ເຊີບເວີເກີດຂໍ້ຜິດພາດ. ກະລຸນາລອງໃໝ່.',
    ),
    'ERR_CONCURRENT_MODIFICATION': Tr(
      'Someone changed this at the same time. Refresh and try again.',
      'ມີຄົນແກ້ໄຂຂໍ້ມູນນີ້ພ້ອມກັນ. ກະລຸນາໂຫຼດຄືນ ແລ້ວລອງໃໝ່.',
    ),
    'ERR_ROLE_NOT_FOUND': Tr(
      'The shop owner role is missing on the server. Nothing was changed; contact a developer.',
      'ບໍ່ພົບບົດບາດເຈົ້າຂອງຮ້ານໃນເຊີບເວີ. ບໍ່ມີຫຍັງປ່ຽນແປງ; ກະລຸນາຕິດຕໍ່ນັກພັດທະນາ.',
    ),
  };

  /// The readable text for [code] in [language] (default: the active one),
  /// or `null` when the code is unknown.
  static String? lookup(String code, [AppLanguage? language]) =>
      _messages[code.trim()]?.get(language ?? AppLanguage.current);

  /// True when [text] looks like one of the backend's bare error codes.
  static bool isCode(String text) =>
      RegExp(r'^ERR_[A-Z0-9_]+$').hasMatch(text.trim());
}
