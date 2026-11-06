import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class SysText {
  static const systemConfiguration = Tr(
    'System Configuration',
    'ການຕັ້ງຄ່າລະບົບ',
  );
  static const failedToLoadConfiguration = Tr(
    'Failed to load configuration',
    'ໂຫຼດການຕັ້ງຄ່າບໍ່ສຳເລັດ',
  );
  static const forceUpdateRequired = Tr(
    'Force Update Required',
    'ຕ້ອງອັບເດດແບບບັງຄັບ',
  );
  static const allUsersMustUpdateTo = Tr(
    'All users must update to the latest version',
    'ຜູ້ໃຊ້ທຸກຄົນຕ້ອງອັບເດດເປັນເວີຊັນລ່າສຸດ',
  );
  static const maintenanceMode = Tr('Maintenance Mode', 'ໂໝດບຳລຸງຮັກສາ');
  static const statusActive = Tr('Status: ACTIVE', 'ສະຖານະ: ເປີດຢູ່');
  static const statusInactive = Tr('Status: INACTIVE', 'ສະຖານະ: ປິດຢູ່');
  static const noTitleProvided = Tr('No title provided', 'ບໍ່ມີຫົວຂໍ້');
  static const noMessageProvided = Tr('No message provided', 'ບໍ່ມີຂໍ້ຄວາມ');
  static Tr expectedCompletion(Object? a0) =>
      Tr('Expected completion: $a0', 'ຄາດວ່າຈະສຳເລັດ: $a0');
  static const newUserVerification = Tr(
    'New User Verification',
    'ການຢືນຢັນຜູ້ໃຊ້ໃໝ່',
  );
  static const statusEnforced = Tr('Status: ENFORCED', 'ສະຖານະ: ບັງຄັບໃຊ້');
  static const statusNotEnforced = Tr(
    'Status: NOT ENFORCED',
    'ສະຖານະ: ບໍ່ບັງຄັບ',
  );
  static const newlyRegisteredShopOwnersMust = Tr(
    'Newly registered shop owners must verify their '
        'email or phone before they can log in. Existing '
        'accounts are never affected. Turn off to unblock '
        'everyone at once if email/OTP delivery breaks.',
    'ເຈົ້າຂອງຮ້ານທີ່ລົງທະບຽນໃໝ່ຕ້ອງຢືນຢັນອີເມວ ຫຼື ເບີໂທກ່ອນເຂົ້າສູ່ລະບົບ. ບັນຊີທີ່ມີຢູ່ແລ້ວບໍ່ໄດ້ຮັບຜົນກະທົບ. ປິດເພື່ອປົດບລັອກທຸກຄົນທັນທີ ຖ້າການສົ່ງອີເມວ/OTP ມີບັນຫາ.',
  );
  static const minimumVersionRequirements = Tr(
    'Minimum Version Requirements',
    'ເວີຊັນຕ່ຳສຸດທີ່ຕ້ອງການ',
  );
  static const updateVersions = Tr('Update Versions', 'ອັບເດດເວີຊັນ');
  static const updateStatus = Tr('Update Status', 'ສະຖານະການອັບເດດ');
  static const updateAvailable = Tr('Update Available', 'ມີອັບເດດ');
  static const yes = Tr('✅ Yes', '✅ ມີ');
  static const no = Tr('❌ No', '❌ ບໍ່ມີ');
  static const yes2 = Tr('⚠️ Yes', '⚠️ ແມ່ນ');
  static const no2 = Tr('✅ No', '✅ ບໍ່');
  static const configurationInfo = Tr('Configuration Info', 'ຂໍ້ມູນການຕັ້ງຄ່າ');
  static const lastUpdated = Tr('Last Updated', 'ອັບເດດລ່າສຸດ');
  static const updatedBy = Tr('Updated By', 'ອັບເດດໂດຍ');
  static Tr minVersion(Object? a0) =>
      Tr('Min version: $a0', 'ເວີຊັນຕ່ຳສຸດ: $a0');
  static const disableMaintenanceMode = Tr(
    'Disable Maintenance Mode',
    'ປິດໂໝດບຳລຸງຮັກສາ',
  );
  static const enableMaintenanceMode = Tr(
    'Enable Maintenance Mode',
    'ເປີດໂໝດບຳລຸງຮັກສາ',
  );
  static const maintenanceTitle = Tr(
    'Maintenance Title',
    'ຫົວຂໍ້ການບຳລຸງຮັກສາ',
  );
  static const systemMaintenance = Tr('System Maintenance', 'ບຳລຸງຮັກສາລະບົບ');
  static const maintenanceMessage = Tr(
    'Maintenance Message',
    'ຂໍ້ຄວາມການບຳລຸງຮັກສາ',
  );
  static const weArePerformingUpdatesExpected = Tr(
    'We are performing updates. Expected time...',
    'ພວກເຮົາກຳລັງອັບເດດລະບົບ. ເວລາທີ່ຄາດໄວ້...',
  );
  static const expectedCompletionTime = Tr(
    'Expected Completion Time',
    'ເວລາທີ່ຄາດວ່າຈະສຳເລັດ',
  );
  static const maintenanceModeEnabled = Tr(
    'Maintenance mode enabled',
    'ເປີດໂໝດບຳລຸງຮັກສາແລ້ວ',
  );
  static const maintenanceModeDisabled = Tr(
    'Maintenance mode disabled',
    'ປິດໂໝດບຳລຸງຮັກສາແລ້ວ',
  );
  static const enforceNewUserVerification = Tr(
    'Enforce New User Verification',
    'ບັງຄັບການຢືນຢັນຜູ້ໃຊ້ໃໝ່',
  );
  static const stopEnforcingNewUserVerification = Tr(
    'Stop Enforcing New User Verification',
    'ຢຸດບັງຄັບການຢືນຢັນຜູ້ໃຊ້ໃໝ່',
  );
  static const newShopOwnersWhoHave = Tr(
    'New shop owners who have not verified their email or phone '
        'will be blocked at login until they do. Make sure email/OTP '
        'delivery is working first.',
    'ເຈົ້າຂອງຮ້ານໃໝ່ທີ່ຍັງບໍ່ຢືນຢັນອີເມວ ຫຼື ເບີໂທ ຈະຖືກບລັອກຕອນເຂົ້າສູ່ລະບົບຈົນກວ່າຈະຢືນຢັນ. ກວດໃຫ້ແນ່ໃຈວ່າການສົ່ງອີເມວ/OTP ເຮັດວຽກກ່ອນ.',
  );
  static const unverifiedNewShopOwnersWill = Tr(
    'Unverified new shop owners will be able to log in again '
        'immediately.',
    'ເຈົ້າຂອງຮ້ານໃໝ່ທີ່ຍັງບໍ່ຢືນຢັນຈະເຂົ້າສູ່ລະບົບໄດ້ທັນທີ.',
  );
  static const enforce = Tr('Enforce', 'ບັງຄັບໃຊ້');
  static const stopEnforcing = Tr('Stop Enforcing', 'ຢຸດບັງຄັບ');
  static const newUserVerificationEnforced = Tr(
    'New user verification enforced',
    'ບັງຄັບການຢືນຢັນຜູ້ໃຊ້ໃໝ່ແລ້ວ',
  );
  static const newUserVerificationNoLonger = Tr(
    'New user verification no longer enforced',
    'ຢຸດບັງຄັບການຢືນຢັນຜູ້ໃຊ້ໃໝ່ແລ້ວ',
  );
  static const updateVersionRequirements = Tr(
    'Update Version Requirements',
    'ອັບເດດເວີຊັນທີ່ຕ້ອງການ',
  );
  static const minimumAndroidVersion = Tr(
    'Minimum Android Version',
    'ເວີຊັນ Android ຕ່ຳສຸດ',
  );
  static const minimumIosVersion = Tr(
    'Minimum iOS Version',
    'ເວີຊັນ iOS ຕ່ຳສຸດ',
  );
  static const minimumWindowsVersion = Tr(
    'Minimum Windows Version',
    'ເວີຊັນ Windows ຕ່ຳສຸດ',
  );
  static const minimumMacosVersion = Tr(
    'Minimum macOS Version',
    'ເວີຊັນ macOS ຕ່ຳສຸດ',
  );
  static const minimumWebVersion = Tr(
    'Minimum Web Version',
    'ເວີຊັນ Web ຕ່ຳສຸດ',
  );
  static const versionRequirementsUpdatedSuccessfully = Tr(
    'Version requirements updated successfully',
    'ອັບເດດເວີຊັນທີ່ຕ້ອງການສຳເລັດ',
  );
  static const update = Tr('Update', 'ອັບເດດ');
}
