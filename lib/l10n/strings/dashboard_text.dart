import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class DashText {
  static const goodMorning = Tr('Good morning', 'ສະບາຍດີຕອນເຊົ້າ');
  static const goodAfternoon = Tr('Good afternoon', 'ສະບາຍດີຕອນບ່າຍ');
  static const goodEvening = Tr('Good evening', 'ສະບາຍດີຕອນແລງ');
  static Tr overview(String date) => Tr(
    "Here's what's happening across UFin today · $date",
    'ສະຫຼຸບສິ່ງທີ່ເກີດຂຶ້ນໃນ UFin ມື້ນີ້ · $date',
  );
  static const loading = Tr('Loading dashboard…', 'ກຳລັງໂຫຼດພາບລວມ…');
  static const noData = Tr('No data yet', 'ຍັງບໍ່ມີຂໍ້ມູນ');
  static const noDataHint = Tr(
    'Dashboard metrics will appear once shops start using UFin.',
    'ຕົວເລກຈະສະແດງເມື່ອຮ້ານຄ້າເລີ່ມໃຊ້ UFin.',
  );
  static const totalShops = Tr('Total shops', 'ຮ້ານທັງໝົດ');
  static const totalUsers = Tr('Total users', 'ຜູ້ໃຊ້ທັງໝົດ');
  static const monthlyRevenue = Tr('Monthly revenue', 'ລາຍຮັບເດືອນນີ້');
  static Tr nActive(String n) => Tr('$n active', 'ເປີດໃຊ້ $n');
  static Tr nPayments(String n) => Tr('$n payments', '$n ການຊຳລະ');
  static const recentActivity = Tr('Recent activity', 'ກິດຈະກຳລ່າສຸດ');
  static const revenue = Tr('Revenue', 'ລາຍຮັບ');
  static const paymentsThisMonth = Tr('Payments this month', 'ການຊຳລະເດືອນນີ້');
  static const byPlan = Tr('Subscriptions by plan', 'ການສະໝັກໃຊ້ແຍກຕາມແພັກເກດ');
  static const newToday = Tr('New today', 'ໃໝ່ມື້ນີ້');
  static const newThisWeek = Tr('New this week', 'ໃໝ່ອາທິດນີ້');
  static const newThisMonth = Tr('New this month', 'ໃໝ່ເດືອນນີ້');
  static const other = Tr('Other', 'ອື່ນໆ');

  // Work queue
  static const needsAttention = Tr('Needs attention', 'ຕ້ອງດຳເນີນການ');
  static const allClear = Tr(
    'Nothing needs you right now',
    'ຕອນນີ້ບໍ່ມີຫຍັງຕ້ອງເຮັດ',
  );
  static const allClearHint = Tr(
    'No upgrade requests waiting, no plans ending this week and no '
        'lapsed shops.',
    'ບໍ່ມີຄຳຂໍອັບເກຣດລໍຖ້າ, ບໍ່ມີແພັກເກດໝົດອາທິດນີ້ ແລະ ບໍ່ມີຮ້ານທີ່ໝົດອາຍຸ.',
  );
  static Tr requestsWaiting(int n) => Tr(
    '$n upgrade request${n == 1 ? '' : 's'} waiting for review',
    'ຄຳຂໍອັບເກຣດ $n ລາຍການ ລໍຖ້າກວດສອບ',
  );
  static Tr trialsEnding(int n) => Tr(
    '$n trial${n == 1 ? '' : 's'} ending within 7 days',
    'ທົດລອງ $n ຮ້ານ ຈະໝົດພາຍໃນ 7 ມື້',
  );
  static Tr plansEnding(int n) => Tr(
    '$n plan${n == 1 ? '' : 's'} ending within 7 days',
    'ແພັກເກດ $n ລາຍການ ຈະໝົດພາຍໃນ 7 ມື້',
  );
  static Tr shopsLapsed(int n) => Tr(
    '$n shop${n == 1 ? '' : 's'} lapsed to Free',
    'ຮ້ານ $n ຮ້ານ ກັບໄປໃຊ້ແພັກເກດຟຣີ',
  );
  static const review = Tr('Review', 'ກວດສອບ');
  static const trialEndsLocks = Tr(
    'When a trial ends the shop moves to Free and cannot open new bills '
        'until a plan is paid.',
    'ເມື່ອໝົດທົດລອງ ຮ້ານຈະກັບໄປໃຊ້ຟຣີ ແລະ ເປີດບິນໃໝ່ບໍ່ໄດ້ຈົນກວ່າຈະຈ່າຍແພັກເກດ.',
  );
  static const trialEnds = Tr(
    'When a trial ends the shop moves to Free.',
    'ເມື່ອໝົດທົດລອງ ຮ້ານຈະກັບໄປໃຊ້ແພັກເກດຟຣີ.',
  );
  static const paidRenewal = Tr(
    'Renews only once a payment for the next period is recorded or the plan '
        'is extended; otherwise the shop drops to Free.',
    'ຈະຕໍ່ອາຍຸເມື່ອມີການບັນທຶກການຊຳລະງວດຖັດໄປ ຫຼື ຂະຫຍາຍແພັກເກດເທົ່ານັ້ນ; '
        'ຖ້າບໍ່ດັ່ງນັ້ນ ຮ້ານຈະກັບໄປໃຊ້ຟຣີ.',
  );
  static const lapsedLocks = Tr(
    'Trial or plan ended. They cannot open new bills until a plan is paid.',
    'ທົດລອງ ຫຼື ແພັກເກດໝົດແລ້ວ. ເປີດບິນໃໝ່ບໍ່ໄດ້ຈົນກວ່າຈະຈ່າຍແພັກເກດ.',
  );
  static const lapsed = Tr(
    'Trial or plan ended.',
    'ທົດລອງ ຫຼື ແພັກເກດໝົດແລ້ວ.',
  );
  static Tr couldNotLoad(String parts) =>
      Tr("Couldn't load $parts.", 'ບໍ່ສາມາດໂຫຼດ $parts ໄດ້.');
  static const partRequests = Tr('upgrade requests', 'ຄຳຂໍອັບເກຣດ');
  static const partExpiring = Tr('expiring plans', 'ແພັກເກດໃກ້ໝົດອາຍຸ');
  static const partLapsed = Tr('lapsed shops', 'ຮ້ານທີ່ໝົດອາຍຸ');
  static const retry = Tr('Retry', 'ລອງໃໝ່');
  static Tr andMore(String names, int n) =>
      Tr('$names and $n more', '$names ແລະ ອີກ $n');
  static const seeAll = Tr('See all', 'ເບິ່ງທັງໝົດ');
  static Tr seeAllMore(int n) =>
      Tr('See all · $n more', 'ເບິ່ງທັງໝົດ · ອີກ $n');
  static const endsToday = Tr('Ends today', 'ໝົດມື້ນີ້');
  static const endsTomorrow = Tr('Ends tomorrow', 'ໝົດມື້ອື່ນ');
  static Tr daysLeft(int n) => Tr('$n days left', 'ເຫຼືອ $n ມື້');
  static const autoRenewOn = Tr('auto-renew on', 'ຕໍ່ອາຍຸອັດຕະໂນມັດ');
}
