import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class SubsText {
  static const free = Tr('Free', 'ຟຣີ');
  static const allHistory = Tr('All History', 'ປະຫວັດທັງໝົດ');
  static const createSubscription = Tr(
    'Create Subscription',
    'ສ້າງການສະໝັກໃຊ້',
  );
  static const shopPhoneEmailOwnerOr = Tr(
    'Shop, phone, email, owner or ID…',
    'ຮ້ານ, ເບີໂທ, ອີເມວ, ເຈົ້າຂອງ ຫຼື ໄອດີ…',
  );
  static const active = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const trial = Tr('Trial', 'ທົດລອງ');
  static const expired = Tr('Expired', 'ໝົດອາຍຸ');
  static const cancelled = Tr('Cancelled', 'ຍົກເລີກແລ້ວ');
  static const n1Subscription = Tr('1 subscription', '1 ການສະໝັກໃຊ້');
  static Tr subscriptions(Object? a0) =>
      Tr('$a0 subscriptions', '$a0 ການສະໝັກໃຊ້');
  static const noSubscriptionsFound = Tr(
    'No subscriptions found',
    'ບໍ່ພົບການສະໝັກໃຊ້',
  );
  static const searchAllPlans = Tr('Search all plans', 'ຄົ້ນຫາທຸກແພັກເກດ');
  static const noPlan = Tr('No Plan', 'ບໍ່ມີແພັກເກດ');
  static const price = Tr('Price', 'ລາຄາ');
  static const employees = Tr('Employees', 'ພະນັກງານ');
  static const products = Tr('Products', 'ສິນຄ້າ');
  static Tr expiredDaysAgo(Object? a0) =>
      Tr('Expired $a0 days ago', 'ໝົດອາຍຸແລ້ວ $a0 ມື້');
  static Tr expiresInDays(Object? a0) =>
      Tr('Expires in $a0 days', 'ຈະໝົດອາຍຸໃນ $a0 ມື້');
  static Tr expires(Object? a0) => Tr('Expires: $a0', 'ໝົດອາຍຸ: $a0');
  static const enabledFromAdminConsole = Tr(
    'Enabled from admin console',
    'ເປີດຈາກລະບົບຜູ້ດູແລ',
  );
  static const disabledFromAdminConsole = Tr(
    'Disabled from admin console',
    'ປິດຈາກລະບົບຜູ້ດູແລ',
  );
  static const autoRenewIsOn = Tr(
    'Auto-renew is on',
    'ການຕໍ່ອາຍຸອັດຕະໂນມັດເປີດຢູ່',
  );
  static const autoRenewIsOff = Tr(
    'Auto-renew is off',
    'ການຕໍ່ອາຍຸອັດຕະໂນມັດປິດຢູ່',
  );
  static const lifetimeNeverExpires = Tr(
    'Lifetime · never expires',
    'ຕະຫຼອດຊີບ · ບໍ່ມີວັນໝົດອາຍຸ',
  );
  static const noExpiryDate = Tr('No expiry date', 'ບໍ່ມີວັນໝົດອາຍຸ');
  static Tr expired2(Object? a0) => Tr('Expired $a0', 'ໝົດອາຍຸ $a0');
  static const noPlan2 = Tr('No plan', 'ບໍ່ມີແພັກເກດ');
  static const reactivate = Tr('Reactivate', 'ເປີດໃຊ້ຄືນ');
  static const extend = Tr('Extend', 'ຂະຫຍາຍ');
  static const changePlan = Tr('Change plan', 'ປ່ຽນແພັກເກດ');
  static const reduce = Tr('Reduce', 'ຫຼຸດ');
  static const cancelSubscription = Tr(
    'Cancel subscription',
    'ຍົກເລີກການສະໝັກໃຊ້',
  );
  static const shopId = Tr('Shop ID', 'ໄອດີຮ້ານ');
  static const ownerEmail = Tr('Owner email', 'ອີເມວເຈົ້າຂອງ');
  static const planCode = Tr('Plan code', 'ລະຫັດແພັກເກດ');
  static const pricePaid = Tr('Price paid', 'ລາຄາທີ່ຈ່າຍ');
  static const billingCycle = Tr('Billing cycle', 'ຮອບການຮຽກເກັບເງິນ');
  static const started = Tr('Started', 'ເລີ່ມ');
  static const expires2 = Tr('Expires', 'ໝົດອາຍຸ');
  static const trialEnds = Tr('Trial ends', 'ທົດລອງໝົດ');
  static const cancelled2 = Tr('Cancelled', 'ຍົກເລີກແລ້ວ');
  static const renewal = Tr('Renewal', 'ການຕໍ່ອາຍຸ');
  static const nextBillingDate = Tr('Next billing date', 'ວັນຮຽກເກັບເງິນຖັດໄປ');
  static const aLifetimeSubscriptionNeverExpires = Tr(
    'A lifetime subscription never expires and is never renewed.',
    'ແພັກເກດຕະຫຼອດຊີບບໍ່ມີວັນໝົດອາຍຸ ແລະ ບໍ່ມີການຕໍ່ອາຍຸ.',
  );
  static const autoRenew = Tr('Auto-renew', 'ຕໍ່ອາຍຸອັດຕະໂນມັດ');
  static const rollsForwardAutomaticallyWhenThe = Tr(
    'Rolls forward automatically when the next period is paid for.',
    'ຈະຕໍ່ໄປອັດຕະໂນມັດເມື່ອມີການຈ່າຍງວດຖັດໄປ.',
  );
  static const willNotRollForwardThe = Tr(
    'Will not roll forward; the shop drops to the Free plan at expiry.',
    'ຈະບໍ່ຕໍ່ອາຍຸ; ຮ້ານຈະກັບໄປໃຊ້ແພັກເກດຟຣີເມື່ອໝົດອາຍຸ.',
  );
  static const reactivateTheSubscriptionBeforeChanging = Tr(
    'Reactivate the subscription before changing auto-renew.',
    'ເປີດໃຊ້ການສະໝັກໃຊ້ຄືນກ່ອນປ່ຽນການຕໍ່ອາຍຸອັດຕະໂນມັດ.',
  );
  static const thisIsAPaidPlan = Tr(
    'This is a paid plan. It only renews if a completed payment '
        'covering the next period is recorded in Payments, or if you '
        'extend it manually.',
    'ນີ້ແມ່ນແພັກເກດແບບເສຍເງິນ. ຈະຕໍ່ອາຍຸກໍ່ຕໍ່ເມື່ອມີການບັນທຶກການຊຳລະທີ່ສຳເລັດສຳລັບງວດຖັດໄປໃນໜ້າການຊຳລະເງິນ ຫຼື ທ່ານຂະຫຍາຍເອງ.',
  );
  static const usage = Tr('Usage', 'ການນຳໃຊ້');
  static const employees2 = Tr('Employees', 'ພະນັກງານ');
  static const products2 = Tr('Products', 'ສິນຄ້າ');
  static Tr unlimited(Object? a0) => Tr('$a0 · unlimited', '$a0 · ບໍ່ຈຳກັດ');
  static Tr of(Object? a0, Object? a1) => Tr('$a0 of $a1', '$a0 ຈາກ $a1');
  static Tr extendedBy(Object? a0, Object? a1) =>
      Tr('Extended by $a0 $a1', 'ຂະຫຍາຍ $a0 ມື້');
  static const subscriptionReset = Tr(
    'Subscription reset',
    'ຣີເຊັດການສະໝັກໃຊ້ແລ້ວ',
  );
  static Tr reducedBy(Object? a0, Object? a1) =>
      Tr('Reduced by $a0 $a1', 'ຫຼຸດ $a0 ມື້');
  static const createSubscription2 = Tr(
    'Create Subscription',
    'ສ້າງການສະໝັກໃຊ້',
  );
  static const cancelSubscription2 = Tr(
    'Cancel Subscription',
    'ຍົກເລີກການສະໝັກໃຊ້',
  );
  static const reactivateSubscription = Tr(
    'Reactivate Subscription',
    'ເປີດໃຊ້ການສະໝັກໃຊ້ຄືນ',
  );
  static const retryLoadingPlans = Tr(
    'Retry loading plans',
    'ລອງໂຫຼດແພັກເກດໃໝ່',
  );
  static const selectAnActivePlan = Tr(
    'Select an active plan',
    'ເລືອກແພັກເກດທີ່ເປີດໃຊ້',
  );
  static const billingCycle2 = Tr('Billing Cycle', 'ຮອບການຮຽກເກັບເງິນ');
  static const monthly = Tr('Monthly', 'ລາຍເດືອນ');
  static const yearly = Tr('Yearly', 'ລາຍປີ');
  static const lifetime = Tr('Lifetime', 'ຕະຫຼອດຊີບ');
  static Tr oneOffPriceNeverExpires(Object? a0, Object? a1) => Tr(
    'One-off price: $a0 $a1 '
        '— never expires and is never renewed.',
    'ລາຄາຄັ້ງດຽວ: $a0 $a1 — ບໍ່ມີວັນໝົດອາຍຸ ແລະ ບໍ່ມີການຕໍ່ອາຍຸ.',
  );
  static Tr planPrice(Object? a0, Object? a1) =>
      Tr('Plan price: $a0 $a1', 'ລາຄາແພັກເກດ: $a0 $a1');
  static Tr startWithTrialDays(Object? a0) =>
      Tr('Start with $a0 trial days', 'ເລີ່ມດ້ວຍທົດລອງ $a0 ມື້');
  static const thisChangesSubscriptionAccessA = Tr(
    'This changes subscription access. A lifetime '
        'subscription never expires and never renews.',
    'ການປ່ຽນນີ້ມີຜົນຕໍ່ສິດການໃຊ້ງານ. ແພັກເກດຕະຫຼອດຊີບບໍ່ມີວັນໝົດອາຍຸ ແລະ ບໍ່ມີການຕໍ່ອາຍຸ.',
  );
  static const thisChangesSubscriptionAccessAuto = Tr(
    'This changes subscription access. Auto-renew only '
        'rolls the period forward once a matching payment '
        'is recorded in Payments — record it there.',
    'ການປ່ຽນນີ້ມີຜົນຕໍ່ສິດການໃຊ້ງານ. ການຕໍ່ອາຍຸອັດຕະໂນມັດຈະຕໍ່ງວດກໍ່ຕໍ່ເມື່ອມີການບັນທຶກການຊຳລະທີ່ກົງກັນໃນໜ້າການຊຳລະເງິນ — ໃຫ້ບັນທຶກຢູ່ບ່ອນນັ້ນ.',
  );
  static const cancelImmediately = Tr('Cancel immediately', 'ຍົກເລີກທັນທີ');
  static const thePaidPlanEndsNow = Tr(
    'The paid plan ends now and the shop drops to the '
        'Free plan. It keeps working under Free limits '
        'rather than being locked out.',
    'ແພັກເກດແບບເສຍເງິນຈະສິ້ນສຸດດຽວນີ້ ແລະ ຮ້ານຈະກັບໄປໃຊ້ແພັກເກດຟຣີ. ຮ້ານຍັງໃຊ້ງານໄດ້ພາຍໃຕ້ຂີດຈຳກັດຂອງຟຣີ ບໍ່ຖືກລັອກ.',
  );
  static const accessContinuesUntilTheCurrent = Tr(
    'Access continues until the current billing period '
        'ends; auto-renew is switched off.',
    'ໃຊ້ງານໄດ້ຈົນໝົດງວດປັດຈຸບັນ; ການຕໍ່ອາຍຸອັດຕະໂນມັດຈະຖືກປິດ.',
  );
  static const aCancellationReasonIsRequired = Tr(
    'A cancellation reason is required',
    'ຕ້ອງໃສ່ເຫດຜົນການຍົກເລີກ',
  );
  static const free2 = Tr('Free', 'ຟຣີ');
  static const changePlan2 = Tr('Change Plan', 'ປ່ຽນແພັກເກດ');
  static const noPlansAvailable = Tr(
    'No plans available',
    'ບໍ່ມີແພັກເກດໃຫ້ເລືອກ',
  );
  static const currentPlan = Tr('Current plan', 'ແພັກເກດປັດຈຸບັນ');
  static const noPlan3 = Tr('No plan', 'ບໍ່ມີແພັກເກດ');
  static Tr paid(Object? a0, Object? a1, Object? a2) =>
      Tr('$a0 · $a1 paid$a2', '$a0 · ຈ່າຍແລ້ວ $a1$a2');
  static const chooseANewPlan = Tr('Choose a new plan', 'ເລືອກແພັກເກດໃໝ່');
  static const monthly2 = Tr('Monthly', 'ລາຍເດືອນ');
  static const yearly2 = Tr('Yearly', 'ລາຍປີ');
  static const current = Tr('Current', 'ປັດຈຸບັນ');
  static const employees3 = Tr('employees', 'ພະນັກງານ');
  static const products3 = Tr('products', 'ສິນຄ້າ');
  static const ordersMonth = Tr('orders / month', 'ອໍເດີ / ເດືອນ');
  static Tr unlimited2(Object? a0) => Tr('Unlimited $a0', '$a0 ບໍ່ຈຳກັດ');
  static Tr saves(Object? a0) => Tr('Saves $a0%', 'ປະຢັດ $a0%');
  static Tr to(Object? a0, Object? a1, Object? a2) =>
      Tr('$a0 to $a1 · $a2', '$a0 ຫາ $a1 · $a2');
  static Tr plan(Object? a0) => Tr('$a0 plan', '$a0 ແພັກເກດ');
  static Tr appliesImmediatelyANewPeriod(Object? a0) => Tr(
    'Applies immediately. A new $a0 '
        'period starts today and the subscription becomes active.',
    'ມີຜົນທັນທີ. ງວດ$a0ໃໝ່ເລີ່ມມື້ນີ້ ແລະ ການສະໝັກໃຊ້ຈະເປີດໃຊ້ງານ.',
  );
  static const upgrade = Tr('Upgrade', 'ອັບເກຣດ');
  static const downgrade = Tr('Downgrade', 'ດາວເກຣດ');
  static Tr plan2(Object? a0) => Tr('$a0 plan?', '$a0 ແພັກເກດບໍ?');
  static Tr movesFromToAt(
    Object a0,
    Object a1,
    Object a2,
    Object a3,
    Object a4,
  ) => Tr(
    '$a0 moves from '
        '$a1 to $a2 '
        'at $a3. $a4',
    '$a0 ຈະຍ້າຍຈາກ $a1 ໄປ $a2 ລາຄາ $a3. $a4',
  );
  static Tr upgradedTo(Object? a0) =>
      Tr('Upgraded to $a0', 'ອັບເກຣດເປັນ $a0 ແລ້ວ');
  static Tr downgradedTo(Object? a0) =>
      Tr('Downgraded to $a0', 'ດາວເກຣດເປັນ $a0 ແລ້ວ');
  static Tr planChangedTo(Object? a0) =>
      Tr('Plan changed to $a0', 'ປ່ຽນແພັກເກດເປັນ $a0 ແລ້ວ');
  static Tr failedToChangePlan(Object? a0) =>
      Tr('Failed to change plan: $a0', 'ປ່ຽນແພັກເກດບໍ່ສຳເລັດ: $a0');
  static const subscriptionHistory = Tr(
    'Subscription History',
    'ປະຫວັດການສະໝັກໃຊ້',
  );
  static Tr totalRecords(Object? a0) =>
      Tr('$a0 total records', 'ທັງໝົດ $a0 ລາຍການ');
  static Tr pageOf(Object? a0, Object? a1) =>
      Tr('Page $a0 of $a1', 'ໜ້າ $a0 ຈາກ $a1');
  static const noHistoryFound = Tr('No history found', 'ບໍ່ພົບປະຫວັດ');
  static const noChangesHaveBeenMade = Tr(
    'No changes have been made to this subscription yet',
    'ຍັງບໍ່ມີການປ່ຽນແປງການສະໝັກໃຊ້ນີ້',
  );
  static const noSubscriptionChangesRecorded = Tr(
    'No subscription changes recorded',
    'ບໍ່ມີການບັນທຶກການປ່ຽນແປງການສະໝັກໃຊ້',
  );
  static const enterAWholeNumberOf = Tr(
    'Enter a whole number of days',
    'ໃສ່ຈຳນວນມື້ເປັນຈຳນວນເຕັມ',
  );
  static Tr enter1ToDays(Object? a0) =>
      Tr('Enter 1 to $a0 days', 'ໃສ່ 1 ຫາ $a0 ມື້');
  static const reduceSubscription = Tr(
    'Reduce subscription',
    'ຫຼຸດການສະໝັກໃຊ້',
  );
  static const extendSubscription = Tr(
    'Extend subscription',
    'ຂະຫຍາຍການສະໝັກໃຊ້',
  );
  static const reduce2 = Tr('Reduce', 'ຫຼຸດ');
  static const extend2 = Tr('Extend', 'ຂະຫຍາຍ');
  static const period = Tr('Period', 'ໄລຍະເວລາ');
  static const movesTheExpiryDateEarlier = Tr(
    'Moves the expiry date earlier. It cannot move before today.',
    'ເລື່ອນວັນໝົດອາຍຸໃຫ້ໄວຂຶ້ນ. ບໍ່ສາມາດເລື່ອນກ່ອນມື້ນີ້.',
  );
  static const movesTheExpiryDateLater = Tr(
    'Moves the expiry date later. No payment is recorded.',
    'ເລື່ອນວັນໝົດອາຍຸອອກໄປ. ບໍ່ມີການບັນທຶກການຊຳລະ.',
  );
  static const daysToRemove = Tr('Days to remove', 'ຈຳນວນມື້ທີ່ຫຼຸດ');
  static const daysToAdd = Tr('Days to add', 'ຈຳນວນມື້ທີ່ເພີ່ມ');
  static const days = Tr('days', 'ມື້');
  static const reasonOptional = Tr('Reason (optional)', 'ເຫດຜົນ (ບໍ່ບັງຄັບ)');
  static const endsTheTrialNowThe = Tr(
    'Ends the trial now. The shop cannot open new bills until it picks '
        'a plan.',
    'ສິ້ນສຸດການທົດລອງດຽວນີ້. ຮ້ານຈະເປີດບິນໃໝ່ບໍ່ໄດ້ຈົນກວ່າຈະເລືອກແພັກເກດ.',
  );
  static const leaveEmptyForAFull = Tr(
    'Leave empty for a full new trial, or enter the days left. 0 ends '
        'it now. No payment is recorded.',
    'ປ່ອຍວ່າງເພື່ອເລີ່ມທົດລອງໃໝ່ເຕັມ, ຫຼື ໃສ່ຈຳນວນມື້ທີ່ເຫຼືອ. 0 ຄືສິ້ນສຸດດຽວນີ້. ບໍ່ມີການບັນທຶກການຊຳລະ.',
  );
  static const endsThisPaidPlanNow = Tr(
    'Ends this paid plan now and moves the shop to Free, where it cannot '
        'open new bills. A reset will not bring the plan back.',
    'ສິ້ນສຸດແພັກເກດແບບເສຍເງິນນີ້ດຽວນີ້ ແລະ ຍ້າຍຮ້ານໄປໃຊ້ຟຣີ ເຊິ່ງເປີດບິນໃໝ່ບໍ່ໄດ້. ການຣີເຊັດຈະບໍ່ເອົາແພັກເກດຄືນມາ.',
  );
  static const leaveEmptyForANew = Tr(
    'Leave empty for a new billing period, or enter the days left. 0 '
        'ends it now. No payment is recorded.',
    'ປ່ອຍວ່າງເພື່ອເລີ່ມງວດໃໝ່, ຫຼື ໃສ່ຈຳນວນມື້ທີ່ເຫຼືອ. 0 ຄືສິ້ນສຸດດຽວນີ້. ບໍ່ມີການບັນທຶກການຊຳລະ.',
  );
  static const enterAWholeNumberOf2 = Tr(
    'Enter a whole number of days',
    'ໃສ່ຈຳນວນມື້ເປັນຈຳນວນເຕັມ',
  );
  static Tr enter0ToDays(Object? a0) =>
      Tr('Enter 0 to $a0 days', 'ໃສ່ 0 ຫາ $a0 ມື້');
  static const resetSubscription = Tr(
    'Reset subscription',
    'ຣີເຊັດການສະໝັກໃຊ້',
  );
  static const endNow = Tr('End now', 'ສິ້ນສຸດດຽວນີ້');
  static const period2 = Tr('Period', 'ໄລຍະເວລາ');
  static const daysLeftOptional = Tr(
    'Days left (optional)',
    'ມື້ທີ່ເຫຼືອ (ບໍ່ບັງຄັບ)',
  );
  static const days2 = Tr('days', 'ມື້');
  static const reasonOptional2 = Tr('Reason (optional)', 'ເຫດຜົນ (ບໍ່ບັງຄັບ)');
}
