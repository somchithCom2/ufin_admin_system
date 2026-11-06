import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class PlanEditText {
  static Tr enterAWholeNumberFrom(Object? a0) => Tr(
    'Enter a whole number from $a0 to 2147483647',
    'ໃສ່ຈຳນວນເຕັມຈາກ $a0 ຫາ 2147483647',
  );
  static const enterANonnegativePriceWith = Tr(
    'Enter a nonnegative price with at most 2 decimals',
    'ໃສ່ລາຄາທີ່ບໍ່ຕິດລົບ ທົດສະນິຍົມບໍ່ເກີນ 2 ຕຳແໜ່ງ',
  );
  static const planCreatedSuccessfully = Tr(
    'Plan created successfully',
    'ສ້າງແພັກເກດສຳເລັດ',
  );
  static const planUpdatedSuccessfully = Tr(
    'Plan updated successfully',
    'ອັບເດດແພັກເກດສຳເລັດ',
  );
  static const createPlan = Tr('Create Plan', 'ສ້າງແພັກເກດ');
  static const editPlan = Tr('Edit Plan', 'ແກ້ໄຂແພັກເກດ');
  static const planCode = Tr('Plan Code *', 'ລະຫັດແພັກເກດ *');
  static const useLettersNumbersUnderscoresOr = Tr(
    'Use letters, numbers, underscores or hyphens',
    'ໃຊ້ຕົວອັກສອນ, ຕົວເລກ, _ ຫຼື -',
  );
  static Tr planName(Object? a0) => Tr('Plan Name ($a0)', 'ຊື່ແພັກເກດ ($a0)');
  static const enterANameInAt = Tr(
    'Enter a name in at least one language',
    'ໃສ່ຊື່ຢ່າງໜ້ອຍໜຶ່ງພາສາ',
  );
  static Tr description(Object? a0) =>
      Tr('Description ($a0)', 'ຄຳອະທິບາຍ ($a0)');
  static const enterA3LetterCurrency = Tr(
    'Enter a 3-letter currency code',
    'ໃສ່ລະຫັດສະກຸນເງິນ 3 ຕົວອັກສອນ',
  );
  static const monthlyPrice = Tr('Monthly Price', 'ລາຄາລາຍເດືອນ');
  static const yearlyPrice = Tr('Yearly Price', 'ລາຄາລາຍປີ');
  static const limitsLeaveEmptyForUnlimited = Tr(
    'Limits (leave empty for unlimited)',
    'ຂີດຈຳກັດ (ປ່ອຍວ່າງ = ບໍ່ຈຳກັດ)',
  );
  static const displayOrder = Tr('Display Order', 'ລຳດັບການສະແດງ');
  static const badgeText = Tr('Badge Text', 'ຂໍ້ຄວາມປ້າຍ');
  static const trialAvailable = Tr('Trial Available', 'ມີທົດລອງ');
  static const trialDays = Tr('Trial Days', 'ຈຳນວນມື້ທົດລອງ');
  static const copyFeaturesFromAnExisting = Tr(
    'Copy features from an existing plan',
    'ສຳເນົາຄຸນສົມບັດຈາກແພັກເກດທີ່ມີ',
  );
  static const active = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const featureFlags = Tr('Feature Flags', 'ຄຸນສົມບັດທີ່ເປີດໃຊ້');
  static const supportTierSettings = Tr(
    'Support & Tier Settings',
    'ການຊ່ວຍເຫຼືອ ແລະ ລະດັບ',
  );
  static const unlimited = Tr('Unlimited', 'ບໍ່ຈຳກັດ');
  static const deactivatePlan = Tr('Deactivate plan?', 'ປິດໃຊ້ແພັກເກດບໍ?');
  static Tr willNoLongerBeOffered(Object? a0) => Tr(
    '"$a0" will no longer be offered to shops. Existing subscriptions are not affected.',
    '"$a0" ຈະບໍ່ຖືກສະເໜີໃຫ້ຮ້ານຄ້າອີກ. ການສະໝັກໃຊ້ທີ່ມີຢູ່ແລ້ວບໍ່ໄດ້ຮັບຜົນກະທົບ.',
  );
  static const deactivate = Tr('Deactivate', 'ປິດໃຊ້');
  static Tr couldNotUpdate(Object? a0, Object? a1) =>
      Tr('Could not update "$a0": $a1', 'ບໍ່ສາມາດອັບເດດ "$a0": $a1');
  static const planDetails = Tr('Plan Details', 'ລາຍລະອຽດແພັກເກດ');
  static const planNotFound = Tr('Plan not found', 'ບໍ່ພົບແພັກເກດ');
  static const itMayHaveBeenDeleted = Tr(
    'It may have been deleted or the link is invalid.',
    'ອາດຖືກລຶບແລ້ວ ຫຼື ລິ້ງບໍ່ຖືກຕ້ອງ.',
  );
  static const pricing = Tr('Pricing', 'ລາຄາ');
  static const monthly = Tr('Monthly', 'ລາຍເດືອນ');
  static const yearly = Tr('Yearly', 'ລາຍປີ');
  static const limits = Tr('Limits', 'ຂີດຈຳກັດ');
  static const maxEmployees = Tr('Max Employees', 'ພະນັກງານສູງສຸດ');
  static const unlimited2 = Tr('Unlimited', 'ບໍ່ຈຳກັດ');
  static const maxProducts = Tr('Max Products', 'ສິນຄ້າສູງສຸດ');
  static const maxOrdersMonth = Tr('Max Orders/Month', 'ອໍເດີສູງສຸດ/ເດືອນ');
  static const storage = Tr('Storage', 'ບ່ອນເກັບຂໍ້ມູນ');
  static Tr mb(Object? a0) => Tr('$a0 MB', '$a0 MB');
  static const trial = Tr('Trial', 'ທົດລອງ');
  static const trialAvailable2 = Tr('Trial Available', 'ມີທົດລອງ');
  static const trialDays2 = Tr('Trial Days', 'ຈຳນວນມື້ທົດລອງ');
  static const activeSubscriptions = Tr(
    'Active Subscriptions',
    'ການສະໝັກໃຊ້ທີ່ເປີດຢູ່',
  );
  static const totalSubscriptions = Tr(
    'Total Subscriptions',
    'ການສະໝັກໃຊ້ທັງໝົດ',
  );
  static const displayOrder2 = Tr('Display Order', 'ລຳດັບການສະແດງ');
  static const features = Tr('Features', 'ຄຸນສົມບັດ');
}
