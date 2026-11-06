import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class UserText {
  static const searchUsers = Tr('Search users…', 'ຄົ້ນຫາຜູ້ໃຊ້…');
  static const clearFilters = Tr('Clear Filters', 'ລ້າງຕົວກັ່ນຕອງ');
  static const active = Tr('  Active', '  ເປີດໃຊ້ງານ');
  static const suspended = Tr('  Suspended', '  ຖືກລະງັບ');
  static const deleted = Tr('  Deleted', '  ຖືກລຶບ');
  static const shopOwner = Tr('  Shop Owner', '  ເຈົ້າຂອງຮ້ານ');
  static const employee = Tr('  Employee', '  ພະນັກງານ');
  static const noUsersFound = Tr('No users found', 'ບໍ່ພົບຜູ້ໃຊ້');
  static const tryADifferentSearchOr = Tr(
    'Try a different search or filter.',
    'ລອງຄົ້ນຫາ ຫຼື ກັ່ນຕອງແບບອື່ນ.',
  );
  static const viewDetails = Tr('View Details', 'ເບິ່ງລາຍລະອຽດ');
  static const suspend = Tr('Suspend', 'ລະງັບ');
  static const activate = Tr('Activate', 'ເປີດໃຊ້');
  static const markVerified = Tr('Mark Verified', 'ໝາຍວ່າຢືນຢັນແລ້ວ');
  static const changeUsername = Tr('Change Username', 'ປ່ຽນຊື່ຜູ້ໃຊ້');
  static const resetPassword = Tr('Reset Password', 'ຣີເຊັດລະຫັດຜ່ານ');
  static Tr currentTheUserIsSigned(Object? a0) => Tr(
    'Current: "$a0". The user is signed out on every '
        'device and must sign in with the new username. Email and '
        'phone sign-in keep working.',
    'ປັດຈຸບັນ: "$a0". ຜູ້ໃຊ້ຈະອອກຈາກລະບົບໃນທຸກອຸປະກອນ ແລະ ຕ້ອງເຂົ້າດ້ວຍຊື່ຜູ້ໃຊ້ໃໝ່. ການເຂົ້າດ້ວຍອີເມວ ແລະ ເບີໂທຍັງໃຊ້ໄດ້.',
  );
  static const newUsername = Tr('New username', 'ຊື່ຜູ້ໃຊ້ໃໝ່');
  static const lettersDigits350No = Tr(
    'Letters, digits, . _ -  (3-50, no spaces)',
    'ຕົວອັກສອນ, ຕົວເລກ, . _ -  (3-50, ບໍ່ມີຍະຫວ່າງ)',
  );
  static const usernameIsRequired = Tr(
    'Username is required',
    'ຕ້ອງໃສ່ຊື່ຜູ້ໃຊ້',
  );
  static const enterADifferentUsername = Tr(
    'Enter a different username',
    'ໃສ່ຊື່ຜູ້ໃຊ້ອື່ນ',
  );
  static const mustBe3To50 = Tr(
    'Must be 3 to 50 characters',
    'ຕ້ອງມີ 3 ຫາ 50 ຕົວອັກສອນ',
  );
  static const onlyEnglishLettersDigits = Tr(
    'Only English letters, digits, . _ -',
    'ສະເພາະຕົວອັກສອນອັງກິດ, ຕົວເລກ, . _ -',
  );
  static const noTwoDashesInA = Tr(
    'No two dashes in a row',
    'ຫ້າມມີ - ສອງຕົວຕິດກັນ',
  );
  static const reasonOptional = Tr('Reason (optional)', 'ເຫດຜົນ (ບໍ່ບັງຄັບ)');
  static const eGOldUsernameHad = Tr(
    'e.g. old username had spaces',
    'ເຊັ່ນ: ຊື່ຜູ້ໃຊ້ເກົ່າມີຍະຫວ່າງ',
  );
  static Tr isNowTellThemTo(Object? a0, Object? a1) => Tr(
    '"$a0" is now "$a1". Tell them to sign in again.',
    '"$a0" ປ່ຽນເປັນ "$a1" ແລ້ວ. ແຈ້ງໃຫ້ເຂົ້າສູ່ລະບົບໃໝ່.',
  );
  static Tr failedToChangeUsername(Object? a0) =>
      Tr('Failed to change username: $a0', 'ປ່ຽນຊື່ຜູ້ໃຊ້ບໍ່ສຳເລັດ: $a0');
  static Tr useThisWhenNeverReceived(Object? a0) => Tr(
    'Use this when "$a0" never received their '
        'verification code. Only do it after confirming the contact '
        'belongs to the person asking.',
    'ໃຊ້ເມື່ອ "$a0" ບໍ່ໄດ້ຮັບລະຫັດຢືນຢັນ. ເຮັດສະເພາະຫຼັງຈາກຢືນຢັນວ່າຂໍ້ມູນຕິດຕໍ່ເປັນຂອງຜູ້ທີ່ຮ້ອງຂໍແທ້.',
  );
  static Tr phone(Object? a0) => Tr('Phone: $a0', 'ເບີໂທ: $a0');
  static Tr email(Object? a0) => Tr('Email: $a0', 'ອີເມວ: $a0');
  static const howDidYouConfirmIt = Tr(
    'How did you confirm it is them?',
    'ທ່ານຢືນຢັນຕົວຕົນແນວໃດ?',
  );
  static const eGCalledBackOn = Tr(
    'e.g. called back on the registered number',
    'ເຊັ່ນ: ໂທກັບຫາເບີທີ່ລົງທະບຽນ',
  );
  static const reasonIsRequired = Tr('Reason is required', 'ຕ້ອງໃສ່ເຫດຜົນ');
  static Tr phoneMarkedVerified(Object? a0) =>
      Tr('"$a0" phone marked verified', 'ໝາຍເບີໂທຂອງ "$a0" ວ່າຢືນຢັນແລ້ວ');
  static Tr emailMarkedVerified(Object? a0) =>
      Tr('"$a0" email marked verified', 'ໝາຍອີເມວຂອງ "$a0" ວ່າຢືນຢັນແລ້ວ');
  static Tr failedToMarkVerified(Object? a0) =>
      Tr('Failed to mark verified: $a0', 'ໝາຍວ່າຢືນຢັນບໍ່ສຳເລັດ: $a0');
  static const contactInformation = Tr('Contact Information', 'ຂໍ້ມູນຕິດຕໍ່');
  static const emailVerified = Tr('Email Verified', 'ຢືນຢັນອີເມວແລ້ວ');
  static const phoneVerified = Tr('Phone Verified', 'ຢືນຢັນເບີໂທແລ້ວ');
  static const accountStatus = Tr('Account Status', 'ສະຖານະບັນຊີ');
  static const deleted2 = Tr('Deleted', 'ຖືກລຶບ');
  static const activity = Tr('Activity', 'ກິດຈະກຳ');
  static const lastLogin = Tr('Last Login', 'ເຂົ້າສູ່ລະບົບລ່າສຸດ');
  static const never = Tr('Never', 'ບໍ່ເຄີຍ');
  static Tr shops(Object? a0) => Tr('Shops ($a0)', 'ຮ້ານ ($a0)');
  static Tr setANewPasswordFor(Object? a0) =>
      Tr('Set a new password for "$a0"', 'ຕັ້ງລະຫັດຜ່ານໃໝ່ໃຫ້ "$a0"');
  static const newPassword = Tr('New Password', 'ລະຫັດຜ່ານໃໝ່');
  static const passwordIsRequired = Tr(
    'Password is required',
    'ຕ້ອງໃສ່ລະຫັດຜ່ານ',
  );
  static const passwordMustBeAtLeast = Tr(
    'Password must be at least 8 characters',
    'ລະຫັດຜ່ານຕ້ອງມີຢ່າງໜ້ອຍ 8 ຕົວອັກສອນ',
  );
  static Tr passwordResetFor(Object? a0) =>
      Tr('Password reset for "$a0"', 'ຣີເຊັດລະຫັດຜ່ານໃຫ້ "$a0" ແລ້ວ');
  static Tr failedToResetPassword(Object? a0) =>
      Tr('Failed to reset password: $a0', 'ຣີເຊັດລະຫັດຜ່ານບໍ່ສຳເລັດ: $a0');
  static const suspendUser = Tr('Suspend user', 'ລະງັບຜູ້ໃຊ້');
  static const deleteUser = Tr('Delete user', 'ລຶບຜູ້ໃຊ້');
  static const activateUser = Tr('Activate user', 'ເປີດໃຊ້ຜູ້ໃຊ້');
  static Tr willLoseAccessImmediatelyYou(Object? a0) => Tr(
    '"$a0" will lose access immediately. You can restore the account later from Deleted Users.',
    '"$a0" ຈະເສຍສິດເຂົ້າເຖິງທັນທີ. ທ່ານກູ້ຄືນບັນຊີໄດ້ພາຍຫຼັງຈາກໜ້າຜູ້ໃຊ້ທີ່ຖືກລຶບ.',
  );
  static Tr willBeSignedOutAnd(Object? a0) => Tr(
    '"$a0" will be signed out and unable to log in until reactivated.',
    '"$a0" ຈະອອກຈາກລະບົບ ແລະ ເຂົ້າບໍ່ໄດ້ຈົນກວ່າຈະເປີດໃຊ້ຄືນ.',
  );
  static Tr willRegainAccessToTheir(Object? a0) => Tr(
    '"$a0" will regain access to their account.',
    '"$a0" ຈະກັບມາເຂົ້າບັນຊີໄດ້.',
  );
  static Tr hasBeenSuspended(Object? a0) =>
      Tr('"$a0" has been suspended', 'ລະງັບ "$a0" ແລ້ວ');
  static Tr hasBeenDeleted(Object? a0) =>
      Tr('"$a0" has been deleted', 'ລຶບ "$a0" ແລ້ວ');
  static Tr hasBeenActivated(Object? a0) =>
      Tr('"$a0" has been activated', 'ເປີດໃຊ້ "$a0" ແລ້ວ');
  static Tr couldNotUpdate(Object? a0, Object? a1) =>
      Tr('Could not update "$a0": $a1', 'ບໍ່ສາມາດອັບເດດ "$a0": $a1');
  static const pleaseSelectAnAccount = Tr(
    'Please select an account',
    'ກະລຸນາເລືອກບັນຊີ',
  );
  static const searchAndSelectAnAccount = Tr(
    'Search and select an account',
    'ຄົ້ນຫາ ແລະ ເລືອກບັນຊີ',
  );
  static const selectAccount = Tr('Select account', 'ເລືອກບັນຊີ');
  static const searchByUsernameNamePhone = Tr(
    'Search by username, name, phone or email',
    'ຄົ້ນຫາຕາມຊື່ຜູ້ໃຊ້, ຊື່, ເບີໂທ ຫຼື ອີເມວ',
  );
  static const couldnTLoadAccounts = Tr(
    "Couldn't load accounts",
    'ບໍ່ສາມາດໂຫຼດບັນຊີ',
  );
  static const noAccountsFound = Tr('No accounts found', 'ບໍ່ພົບບັນຊີ');
  static Tr noActiveStaffAccountMatches(Object? a0) => Tr(
    'No active staff account matches "$a0".',
    'ບໍ່ມີບັນຊີພະນັກງານທີ່ເປີດໃຊ້ກົງກັບ "$a0".',
  );
  static const loadMoreFailedRetry = Tr(
    'Load more failed · Retry',
    'ໂຫຼດເພີ່ມບໍ່ສຳເລັດ · ລອງໃໝ່',
  );
  static const n1Shop = Tr('1 shop', '1 ຮ້ານ');
  static Tr shops2(Object? a0) => Tr('$a0 shops', '$a0 ຮ້ານ');
  static const showingSoftDeletedAccountsSorted = Tr(
    'Showing soft-deleted accounts sorted by most recently deleted.',
    'ສະແດງບັນຊີທີ່ຖືກລຶບ ຮຽງຕາມວັນລຶບລ່າສຸດ.',
  );
  static const n1DeletedUser = Tr('1 deleted user', 'ຜູ້ໃຊ້ຖືກລຶບ 1 ຄົນ');
  static Tr deletedUsers(Object? a0) =>
      Tr('$a0 deleted users', 'ຜູ້ໃຊ້ຖືກລຶບ $a0 ຄົນ');
  static Tr pageOf(Object? a0, Object? a1) =>
      Tr('· page $a0 of $a1', '· ໜ້າ $a0 ຈາກ $a1');
  static const noDeletedUsers = Tr('No deleted users', 'ບໍ່ມີຜູ້ໃຊ້ທີ່ຖືກລຶບ');
  static const softDeletedAccountsWillAppear = Tr(
    'Soft-deleted accounts will appear here.',
    'ບັນຊີທີ່ຖືກລຶບຈະສະແດງຢູ່ນີ້.',
  );
  static Tr deleted3(Object? a0) => Tr('Deleted $a0', 'ລຶບ $a0');
  static const viewDetails2 = Tr('View Details', 'ເບິ່ງລາຍລະອຽດ');
  static const restore = Tr('Restore', 'ກູ້ຄືນ');
  static const today = Tr('today', 'ມື້ນີ້');
  static const yesterday = Tr('yesterday', 'ມື້ວານ');
  static Tr daysAgo(Object? a0) => Tr('$a0 days ago', '$a0 ມື້ກ່ອນ');
  static const contactInformation2 = Tr('Contact Information', 'ຂໍ້ມູນຕິດຕໍ່');
  static const emailVerified2 = Tr('Email Verified', 'ຢືນຢັນອີເມວແລ້ວ');
  static const phoneVerified2 = Tr('Phone Verified', 'ຢືນຢັນເບີໂທແລ້ວ');
  static const deletedAt = Tr('Deleted At', 'ລຶບເມື່ອ');
  static const lastLogin2 = Tr('Last Login', 'ເຂົ້າສູ່ລະບົບລ່າສຸດ');
  static const never2 = Tr('Never', 'ບໍ່ເຄີຍ');
  static Tr shops3(Object? a0) => Tr('Shops ($a0)', 'ຮ້ານ ($a0)');
  static const restoreUser = Tr('Restore User', 'ກູ້ຄືນຜູ້ໃຊ້');
  static Tr restore2(Object? a0) => Tr('Restore "$a0"?', 'ກູ້ຄືນ "$a0" ບໍ?');
  static const theAccountBecomesActiveAgain = Tr(
    'The account becomes active again and can sign in.',
    'ບັນຊີຈະເປີດໃຊ້ຄືນ ແລະ ເຂົ້າສູ່ລະບົບໄດ້.',
  );
  static Tr hasBeenRestored(Object? a0) =>
      Tr('"$a0" has been restored.', 'ກູ້ຄືນ "$a0" ແລ້ວ.');
  static Tr failedToRestoreUser(Object? a0) =>
      Tr('Failed to restore user: $a0', 'ກູ້ຄືນຜູ້ໃຊ້ບໍ່ສຳເລັດ: $a0');
}
