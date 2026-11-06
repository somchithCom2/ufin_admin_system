import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class FinText {
  static const noPaymentsFound = Tr('No payments found', 'ບໍ່ພົບການຊຳລະເງິນ');
  static const tryChangingTheFilters = Tr(
    'Try changing the filters.',
    'ລອງປ່ຽນຕົວກັ່ນຕອງ.',
  );
  static const failed = Tr('Failed', 'ລົ້ມເຫຼວ');
  static Tr shop(Object? a0) => Tr('Shop #$a0', 'ຮ້ານ #$a0');
  static const method = Tr('Method', 'ວິທີຊຳລະ');
  static const customRange = Tr('Custom range…', 'ກຳນົດຊ່ວງເອງ…');
  static const payment = Tr(' payment', ' ລາຍການ');
  static const payments = Tr(' payments', ' ລາຍການ');
  static Tr page(Object? a0, Object? a1) =>
      Tr(' · page $a0/$a1', ' · ໜ້າ $a0/$a1');
  static Tr completedOnThisPage(Object? a0) =>
      Tr('Completed on this page ($a0)', 'ສຳເລັດໃນໜ້ານີ້ ($a0)');
  static const fundsNextRenewal = Tr(
    'Funds next renewal',
    'ໃຊ້ສຳລັບການຕໍ່ອາຍຸຄັ້ງຕໍ່ໄປ',
  );
  static Tr applied(Object? a0) => Tr('Applied → $a0', 'ນຳໃຊ້ແລ້ວ → $a0');
  static const applied2 = Tr('Applied', 'ນຳໃຊ້ແລ້ວ');
  static const previousPage = Tr('Previous page', 'ໜ້າກ່ອນ');
  static Tr pageOf(Object? a0, Object? a1) =>
      Tr('Page $a0 of $a1', 'ໜ້າ $a0 ຈາກ $a1');
  static const nextPage = Tr('Next page', 'ໜ້າຖັດໄປ');
  static Tr payment2(Object? a0) => Tr('Payment #$a0', 'ການຊຳລະ #$a0');
  static const paymentDate = Tr('Payment Date', 'ວັນທີຊຳລະ');
  static const transactionId = Tr('Transaction ID', 'ລະຫັດທຸລະກຳ');
  static const reference = Tr('Reference', 'ເລກອ້າງອີງ');
  static const processedBy = Tr('Processed By', 'ດຳເນີນການໂດຍ');
  static const markFailed = Tr('Mark Failed', 'ໝາຍວ່າລົ້ມເຫຼວ');
  static const markCompleted = Tr('Mark Completed', 'ໝາຍວ່າສຳເລັດ');
  static Tr paymentMarkedAs(Object? a0, Object? a1) =>
      Tr('Payment #$a0 marked as $a1', 'ໝາຍການຊຳລະ #$a0 ເປັນ $a1 ແລ້ວ');
  static Tr couldNotUpdatePayment(Object? a0, Object? a1) => Tr(
    'Could not update payment #$a0: $a1',
    'ບໍ່ສາມາດອັບເດດການຊຳລະ #$a0: $a1',
  );
  static const datePaymentWasReceived = Tr(
    'Date payment was received',
    'ວັນທີໄດ້ຮັບເງິນ',
  );
  static Tr paymentRecordedForButThe(Object? a0, Object? a1, Object? a2) => Tr(
    'Payment recorded for "$a0", but the server dated it '
        '$a1 instead of $a2. '
        'The backend needs updating to accept past dates.',
    'ບັນທຶກການຊຳລະຂອງ "$a0" ແລ້ວ ແຕ່ເຊີບເວີລົງວັນທີ $a1 ແທນ $a2. ຕ້ອງອັບເດດລະບົບຫຼັງບ້ານໃຫ້ຮັບວັນທີຍ້ອນຫຼັງ.',
  );
  static Tr paymentRecordedForOn(Object? a0, Object? a1) => Tr(
    'Payment recorded for "$a0" on $a1',
    'ບັນທຶກການຊຳລະຂອງ "$a0" ວັນທີ $a1 ແລ້ວ',
  );
  static const recordPayment = Tr('Record payment', 'ບັນທຶກການຊຳລະ');
  static const logMoneyReceivedFromA = Tr(
    'Log money received from a shop',
    'ບັນທຶກເງິນທີ່ໄດ້ຮັບຈາກຮ້ານ',
  );
  static const savePayment = Tr('Save payment', 'ບັນທຶກການຊຳລະ');
  static const payment3 = Tr('Payment', 'ການຊຳລະ');
  static const enterAPositiveAmountWith = Tr(
    'Enter a positive amount with at most 2 decimals',
    'ໃສ່ຈຳນວນເງິນເປັນບວກ ທົດສະນິຍົມບໍ່ເກີນ 2 ຕຳແໜ່ງ',
  );
  static const paymentDate2 = Tr('Payment date', 'ວັນທີຊຳລະ');
  static const backDatedRecord = Tr('Back-dated record', 'ບັນທຶກຍ້ອນຫຼັງ');
  static const optionalHelpsMatchThisPayment = Tr(
    'Optional. Helps match this payment to a bank statement.',
    'ບໍ່ບັງຄັບ. ຊ່ວຍໃຫ້ກົງກັບລາຍການເດີນບັນຊີທະນາຄານ.',
  );
  static const transactionReference = Tr(
    'Transaction reference',
    'ເລກອ້າງອີງທຸລະກຳ',
  );
  static Tr today(Object? a0) => Tr('Today, $a0', 'ມື້ນີ້, $a0');
  static const noDataAvailable = Tr('No data available', 'ບໍ່ມີຂໍ້ມູນ');
  static const thereIsNothingToShow = Tr(
    'There is nothing to show for this period.',
    'ບໍ່ມີຂໍ້ມູນສຳລັບໄລຍະນີ້.',
  );
  static const selectDates = Tr('Select dates', 'ເລືອກວັນທີ');
  static const week = Tr('Week', 'ອາທິດ');
  static const month = Tr('Month', 'ເດືອນ');
  static Tr totalRevenue(Object? a0) =>
      Tr('Total revenue · $a0', 'ລາຍຮັບທັງໝົດ · $a0');
  static const other = Tr('Other', 'ອື່ນໆ');
  static const transactions = Tr('Transactions', 'ທຸລະກຳ');
  static const successRate = Tr('Success rate', 'ອັດຕາສຳເລັດ');
  static Tr successful(Object? a0) => Tr('$a0 successful', 'ສຳເລັດ $a0');
  static const failed2 = Tr('Failed', 'ລົ້ມເຫຼວ');
  static const averageTransaction = Tr(
    'Average transaction',
    'ສະເລ່ຍຕໍ່ທຸລະກຳ',
  );
  static const revenueByPeriod = Tr('Revenue by period', 'ລາຍຮັບຕາມໄລຍະ');
  static const revenueByCurrentPlan = Tr(
    'Revenue by current plan',
    'ລາຍຮັບຕາມແພັກເກດປັດຈຸບັນ',
  );
  static Tr payments2(Object? a0) => Tr('$a0 payments', '$a0 ການຊຳລະ');
  static const revenueByPaymentMethod = Tr(
    'Revenue by payment method',
    'ລາຍຮັບຕາມວິທີຊຳລະ',
  );
  static Tr transactions2(Object? a0) => Tr('$a0 transactions', '$a0 ທຸລະກຳ');
  static Tr transactions3(Object? a0, Object? a1, Object? a2) => Tr(
    '$a0: $a1'
        ' · $a2 transactions',
    '$a0: $a1 · $a2 ທຸລະກຳ',
  );
  static const filterDailySales = Tr(
    'Filter Daily Sales',
    'ກັ່ນຕອງຍອດຂາຍລາຍວັນ',
  );
  static const startDate = Tr('Start Date', 'ວັນທີເລີ່ມ');
  static const startTime = Tr('Start Time', 'ເວລາເລີ່ມ');
  static const endDate = Tr('End Date', 'ວັນທີສິ້ນສຸດ');
  static const endTime = Tr('End Time', 'ເວລາສິ້ນສຸດ');
  static const endMustNotBeBefore = Tr(
    'End must not be before start.',
    'ເວລາສິ້ນສຸດຕ້ອງບໍ່ກ່ອນເວລາເລີ່ມ.',
  );
  static const dailySalesSummary = Tr(
    'Daily Sales Summary',
    'ສະຫຼຸບຍອດຂາຍລາຍວັນ',
  );
  static const noDataAvailable2 = Tr('No data available', 'ບໍ່ມີຂໍ້ມູນ');
  static const thereIsNothingToShow2 = Tr(
    'There is nothing to show for this period.',
    'ບໍ່ມີຂໍ້ມູນສຳລັບໄລຍະນີ້.',
  );
  static const totalShops = Tr('Total Shops', 'ຮ້ານທັງໝົດ');
  static const totalOrders = Tr('Total Orders', 'ອໍເດີທັງໝົດ');
  static Tr netIncome(Object? a0) =>
      Tr('Net Income ($a0)', 'ລາຍຮັບສຸດທິ ($a0)');
  static Tr id(Object? a0, Object? a1) =>
      Tr('ID: $a0 · $a1', 'ໄອດີ: $a0 · $a1');
  static const orders = Tr('Orders', 'ອໍເດີ');
  static const itemsSold = Tr('Items Sold', 'ສິນຄ້າທີ່ຂາຍ');
  static const avgOrder = Tr('Avg Order', 'ສະເລ່ຍຕໍ່ອໍເດີ');
  static const overview = Tr('Overview', 'ພາບລວມ');
  static const expiring = Tr('Expiring', 'ໃກ້ໝົດອາຍຸ');
  static const noDataAvailable3 = Tr('No data available', 'ບໍ່ມີຂໍ້ມູນ');
  static const thereIsNothingToShow3 = Tr(
    'There is nothing to show for this period.',
    'ບໍ່ມີຂໍ້ມູນສຳລັບໄລຍະນີ້.',
  );
  static const active = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const trial = Tr('Trial', 'ທົດລອງ');
  static const expiringSoon = Tr('Expiring soon', 'ໃກ້ໝົດອາຍຸ');
  static const within30Days = Tr('Within 30 days', 'ພາຍໃນ 30 ມື້');
  static const expired = Tr('Expired', 'ໝົດອາຍຸ');
  static const cancelled = Tr('Cancelled', 'ຍົກເລີກແລ້ວ');
  static const revenue = Tr('Revenue', 'ລາຍຮັບ');
  static const totalRevenue2 = Tr('Total revenue', 'ລາຍຮັບທັງໝົດ');
  static const monthlyRecurringMrr = Tr(
    'Monthly recurring (MRR)',
    'ລາຍຮັບປະຈຳເດືອນ (MRR)',
  );
  static const averagePerPayingShopArpu = Tr(
    'Average per paying shop (ARPU)',
    'ສະເລ່ຍຕໍ່ຮ້ານທີ່ຈ່າຍ (ARPU)',
  );
  static const activeAndTrialByPlan = Tr(
    'Active and trial by plan',
    'ເປີດໃຊ້ ແລະ ທົດລອງ ຕາມແພັກເກດ',
  );
  static const byStatus = Tr('By status', 'ຕາມສະຖານະ');
  static const n7Days = Tr('7 days', '7 ມື້');
  static const n14Days = Tr('14 days', '14 ມື້');
  static const n30Days = Tr('30 days', '30 ມື້');
  static Tr expiringWithin7DaysWithin(Object? a0, Object? a1, Object? a2) => Tr(
    '$a0 expiring · '
        '$a1 within 7 days · '
        '$a2 within 3 days',
    'ໃກ້ໝົດ $a0 · $a1 ພາຍໃນ 7 ມື້ · $a2 ພາຍໃນ 3 ມື້',
  );
  static const nothingExpiring = Tr(
    'Nothing expiring',
    'ບໍ່ມີລາຍການໃກ້ໝົດອາຍຸ',
  );
  static Tr noSubscriptionExpiresInThe(Object? a0) => Tr(
    'No subscription expires in the next $a0 days.',
    'ບໍ່ມີການສະໝັກໃຊ້ໃດໝົດອາຍຸໃນ $a0 ມື້ຂ້າງໜ້າ.',
  );
  static Tr requestApproved(Object? a0) =>
      Tr('Request #$a0 approved', 'ອະນຸມັດຄຳຂໍ #$a0 ແລ້ວ');
  static Tr requestRejected(Object? a0) =>
      Tr('Request #$a0 rejected', 'ປະຕິເສດຄຳຂໍ #$a0 ແລ້ວ');
  static Tr couldNotApproveRequest(Object? a0, Object? a1) => Tr(
    'Could not approve request #$a0: $a1',
    'ບໍ່ສາມາດອະນຸມັດຄຳຂໍ #$a0: $a1',
  );
  static Tr couldNotRejectRequest(Object? a0, Object? a1) =>
      Tr('Could not reject request #$a0: $a1', 'ບໍ່ສາມາດປະຕິເສດຄຳຂໍ #$a0: $a1');
  static const noUpgradeRequests = Tr(
    'No upgrade requests',
    'ບໍ່ມີຄຳຂໍອັບເກຣດ',
  );
  static const requestsFromShopsWantingTo = Tr(
    'Requests from shops wanting to change plans will appear here.',
    'ຄຳຂໍຈາກຮ້ານທີ່ຕ້ອງການປ່ຽນແພັກເກດຈະສະແດງຢູ່ນີ້.',
  );
  static const previousPage2 = Tr('Previous page', 'ໜ້າກ່ອນ');
  static Tr pageOf2(Object? a0, Object? a1) =>
      Tr('Page $a0 of $a1', 'ໜ້າ $a0 ຈາກ $a1');
  static const nextPage2 = Tr('Next page', 'ໜ້າຖັດໄປ');
  static const approveRequest = Tr('Approve request?', 'ອະນຸມັດຄຳຂໍບໍ?');
  static const rejectRequest = Tr('Reject request?', 'ປະຕິເສດຄຳຂໍບໍ?');
  static Tr movesFromTo(Object? a0, Object? a1, Object? a2, Object? a3) => Tr(
    '$a0 moves from $a1 to $a2 '
        '($a3).',
    '$a0 ຈະຍ້າຍຈາກ $a1 ໄປ $a2 ($a3).',
  );
  static Tr staysOnTheShopSees(Object? a0, Object? a1) => Tr(
    '$a0 stays on $a1. The shop sees your note.',
    '$a0 ຍັງໃຊ້ $a1 ຕໍ່. ຮ້ານຈະເຫັນບັນທຶກຂອງທ່ານ.',
  );
  static const reviewNote = Tr('Review note', 'ບັນທຶກການກວດສອບ');
  static Tr requestedBy(Object? a0) => Tr('Requested by $a0', 'ຂໍໂດຍ $a0');
  static Tr reviewedBy(Object? a0) => Tr('Reviewed by $a0', 'ກວດສອບໂດຍ $a0');
  static Tr reviewedByOn(Object? a0, Object? a1) =>
      Tr('Reviewed by $a0 on $a1', 'ກວດສອບໂດຍ $a0 ວັນທີ $a1');
}
