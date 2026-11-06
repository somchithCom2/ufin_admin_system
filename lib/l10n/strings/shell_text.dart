import 'package:ufin_admin_system/l10n/tr.dart';

/// Navigation, shell chrome, settings and sign-in.
abstract final class NavText {
  static const appName = Tr('UFin Admin', 'UFin Admin');
  static const tagline = Tr('Control center', 'ສູນຄວບຄຸມ');

  // Sections
  static const dashboard = Tr('Dashboard', 'ພາບລວມ');
  static const shops = Tr('Shops', 'ຮ້ານຄ້າ');
  static const users = Tr('Users', 'ຜູ້ໃຊ້');
  static const shopTypes = Tr('Shop Types', 'ປະເພດຮ້ານ');
  static const units = Tr('Units', 'ຫົວໜ່ວຍ');
  static const deletedUsers = Tr('Deleted Users', 'ຜູ້ໃຊ້ທີ່ຖືກລຶບ');
  static const subscriptions = Tr('Subscriptions', 'ການສະໝັກໃຊ້');
  static const plans = Tr('Plans', 'ແພັກເກດ');
  static const upgradeRequests = Tr('Upgrade Requests', 'ຄຳຂໍອັບເກຣດ');
  static const statistics = Tr('Statistics', 'ສະຖິຕິ');
  static const payments = Tr('Payments', 'ການຊຳລະເງິນ');
  static const revenue = Tr('Revenue Report', 'ລາຍງານລາຍຮັບ');
  static const dailySales = Tr('Daily Sales', 'ຍອດຂາຍລາຍວັນ');
  static const appReleases = Tr('App Releases', 'ເວີຊັນແອັບ');
  static const systemConfig = Tr('System Config', 'ຕັ້ງຄ່າລະບົບ');

  // Groups
  static const groupManagement = Tr('Management', 'ການຈັດການ');
  static const groupSubscriptions = Tr('Subscriptions', 'ການສະໝັກໃຊ້');
  static const groupFinance = Tr('Finance', 'ການເງິນ');
  static const groupSystem = Tr('System', 'ລະບົບ');

  // Chrome
  static const menu = Tr('Menu', 'ເມນູ');
  static const menuAttention = Tr(
    'Menu · items need attention',
    'ເມນູ · ມີລາຍການຕ້ອງດຳເນີນການ',
  );
  static const more = Tr('More', 'ເພີ່ມເຕີມ');
  static const allSections = Tr('All sections', 'ທຸກໝວດ');
  static const collapseSidebar = Tr('Collapse sidebar', 'ຫຍໍ້ແຖບຂ້າງ');
  static const expandSidebar = Tr('Expand sidebar', 'ຂະຫຍາຍແຖບຂ້າງ');
  static const jumpTo = Tr('Search or jump to…', 'ຄົ້ນຫາ ຫຼື ໄປທີ່…');
  static const jumpHint = Tr(
    'Type a page name or an action',
    'ພິມຊື່ໜ້າ ຫຼື ຄຳສັ່ງ',
  );
  static const pages = Tr('Pages', 'ໜ້າ');
  static const actions = Tr('Actions', 'ຄຳສັ່ງ');
  static const noMatches = Tr('No matches', 'ບໍ່ພົບລາຍການ');
  static const navigateHint = Tr(
    'Arrow keys to move · Enter to open · Esc to close',
    'ປຸ່ມລູກສອນ ເລື່ອນ · Enter ເປີດ · Esc ປິດ',
  );
  static Tr waiting(int n) => Tr('$n waiting', 'ລໍຖ້າ $n');
  static Tr expiringSoon(int n) => Tr('$n expiring soon', 'ໃກ້ໝົດອາຍຸ $n');

  // Account
  static const admin = Tr('Admin', 'ຜູ້ດູແລ');
  static const administrator = Tr('Administrator', 'ຜູ້ດູແລລະບົບ');
  static const account = Tr('Account', 'ບັນຊີ');
  static const signOut = Tr('Sign out', 'ອອກຈາກລະບົບ');
  static const signOutTitle = Tr('Sign out?', 'ອອກຈາກລະບົບບໍ?');
  static const signOutMessage = Tr(
    'You will need to sign in again to access the admin console.',
    'ທ່ານຈະຕ້ອງເຂົ້າສູ່ລະບົບໃໝ່ເພື່ອໃຊ້ງານລະບົບຜູ້ດູແລ.',
  );
}

abstract final class SettingsText {
  static const settings = Tr('Settings', 'ການຕັ້ງຄ່າ');
  static const appearance = Tr('Appearance', 'ຮູບແບບການສະແດງ');
  static const appearanceHint = Tr(
    'System follows your device setting.',
    'ຕາມລະບົບ ຈະປ່ຽນຕາມການຕັ້ງຄ່າອຸປະກອນຂອງທ່ານ.',
  );
  static const themeSystem = Tr('System', 'ຕາມລະບົບ');
  static const themeLight = Tr('Light', 'ແຈ້ງ');
  static const themeDark = Tr('Dark', 'ມືດ');
  static const language = Tr('Language', 'ພາສາ');
  static const toggleTheme = Tr('Toggle light / dark', 'ສະຫຼັບ ແຈ້ງ / ມືດ');
  static const switchLanguage = Tr(
    'Switch language (English / ລາວ)',
    'ປ່ຽນພາສາ (English / ລາວ)',
  );
}

abstract final class AuthText {
  static const welcome = Tr('Welcome back', 'ຍິນດີຕ້ອນຮັບກັບຄືນ');
  static const subtitle = Tr(
    'Sign in to the UFin admin console',
    'ເຂົ້າສູ່ລະບົບຜູ້ດູແລ UFin',
  );
  static const username = Tr('Username', 'ຊື່ຜູ້ໃຊ້');
  static const usernameHint = Tr('Enter your username', 'ໃສ່ຊື່ຜູ້ໃຊ້ຂອງທ່ານ');
  static const usernameRequired = Tr(
    'Please enter your username',
    'ກະລຸນາໃສ່ຊື່ຜູ້ໃຊ້',
  );
  static const password = Tr('Password', 'ລະຫັດຜ່ານ');
  static const passwordHint = Tr('Enter your password', 'ໃສ່ລະຫັດຜ່ານຂອງທ່ານ');
  static const passwordRequired = Tr(
    'Please enter your password',
    'ກະລຸນາໃສ່ລະຫັດຜ່ານ',
  );
  static const showPassword = Tr('Show password', 'ສະແດງລະຫັດຜ່ານ');
  static const hidePassword = Tr('Hide password', 'ເຊື່ອງລະຫັດຜ່ານ');
  static const signIn = Tr('Sign in', 'ເຂົ້າສູ່ລະບົບ');
  static const signingIn = Tr('Signing in…', 'ກຳລັງເຂົ້າສູ່ລະບົບ…');
  static const restricted = Tr(
    'Restricted to administrator accounts',
    'ສະເພາະບັນຊີຜູ້ດູແລລະບົບເທົ່ານັ້ນ',
  );
  static const restoring = Tr(
    'Restoring your session…',
    'ກຳລັງກູ້ຄືນເຊດຊັນຂອງທ່ານ…',
  );
  static const unauthorized = Tr(
    'Unauthorized. Please login.',
    'ບໍ່ມີສິດເຂົ້າເຖິງ. ກະລຸນາເຂົ້າສູ່ລະບົບ.',
  );
  static const heroTitle = Tr(
    'Run every UFin shop from one place.',
    'ຈັດການທຸກຮ້ານ UFin ຈາກບ່ອນດຽວ.',
  );
  static const heroBody = Tr(
    'Shops, subscriptions, payments and releases — with a work queue that '
        'shows what needs you today.',
    'ຮ້ານຄ້າ, ການສະໝັກໃຊ້, ການຊຳລະເງິນ ແລະ ເວີຊັນແອັບ — ພ້ອມລາຍການວຽກທີ່ສະແດງ'
        'ສິ່ງທີ່ຕ້ອງເຮັດມື້ນີ້.',
  );
  static const heroPoint1 = Tr(
    'Approve upgrades and renewals',
    'ອະນຸມັດການອັບເກຣດ ແລະ ຕໍ່ອາຍຸ',
  );
  static const heroPoint2 = Tr(
    'Track revenue per currency',
    'ຕິດຕາມລາຍຮັບແຍກຕາມສະກຸນເງິນ',
  );
  static const heroPoint3 = Tr(
    'Ship app releases safely',
    'ອອກເວີຊັນແອັບຢ່າງປອດໄພ',
  );
}
