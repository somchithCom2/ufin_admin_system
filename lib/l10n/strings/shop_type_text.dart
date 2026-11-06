import 'package:ufin_admin_system/l10n/tr.dart';

/// Shop types and units of measure.
abstract final class ShopTypeText {
  static const created = Tr('Shop type created', 'ສ້າງປະເພດຮ້ານແລ້ວ');
  static const updated = Tr('Shop type updated', 'ອັບເດດປະເພດຮ້ານແລ້ວ');
  static const unitCreated = Tr('Unit created', 'ສ້າງຫົວໜ່ວຍແລ້ວ');
  static const unitUpdated = Tr('Unit updated', 'ອັບເດດຫົວໜ່ວຍແລ້ວ');
  static const addType = Tr('Add Type', 'ເພີ່ມປະເພດ');
  static const noShopTypesYet = Tr('No shop types yet', 'ຍັງບໍ່ມີປະເພດຮ້ານ');
  static const addAShopTypeTo = Tr(
    'Add a shop type to categorize shops.',
    'ເພີ່ມປະເພດຮ້ານເພື່ອຈັດໝວດໝູ່ຮ້ານຄ້າ.',
  );
  static const viewDetails = Tr('View Details', 'ເບິ່ງລາຍລະອຽດ');
  static const enabled = Tr('Enabled', 'ເປີດໃຊ້');
  static const disabled = Tr('Disabled', 'ປິດໃຊ້');
  static const shopCountUnavailable = Tr(
    'Shop count unavailable',
    'ບໍ່ມີຂໍ້ມູນຈຳນວນຮ້ານ',
  );
  static const n1Shop = Tr('1 shop', '1 ຮ້ານ');
  static Tr shops(Object? a0) => Tr('$a0 shops', '$a0 ຮ້ານ');
  static Tr disable(Object? a0) => Tr('Disable "$a0"?', 'ປິດໃຊ້ "$a0" ບໍ?');
  static const newShopsCanNoLonger = Tr(
    'New shops can no longer choose this type. Shops already using '
        'it keep it.',
    'ຮ້ານໃໝ່ຈະເລືອກປະເພດນີ້ບໍ່ໄດ້ອີກ. ຮ້ານທີ່ໃຊ້ຢູ່ແລ້ວຍັງໃຊ້ຕໍ່ໄດ້.',
  );
  static Tr couldNotUpdateShopType(Object? a0) =>
      Tr('Could not update shop type: $a0', 'ບໍ່ສາມາດອັບເດດປະເພດຮ້ານ: $a0');
  static const information = Tr('Information', 'ຂໍ້ມູນ');
  static const features = Tr('Features', 'ຄຸນສົມບັດ');
  static const noFeaturesDefined = Tr('No features defined', 'ບໍ່ມີຄຸນສົມບັດ');
  static const active = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const inactive = Tr('Inactive', 'ບໍ່ເຄື່ອນໄຫວ');
  static const suspended = Tr('Suspended', 'ຖືກລະງັບ');
  static const unavailable = Tr('Unavailable', 'ບໍ່ມີຂໍ້ມູນ');
  static const timestamps = Tr('Timestamps', 'ເວລາບັນທຶກ');
  static Tr delete(Object? a0) => Tr('Delete "$a0"?', 'ລຶບ "$a0" ບໍ?');
  static const thisCannotBeUndone = Tr(
    'This cannot be undone.',
    'ບໍ່ສາມາດຍົກເລີກໄດ້.',
  );
  static const shopTypeDeleted = Tr('Shop type deleted', 'ລຶບປະເພດຮ້ານແລ້ວ');
  static Tr couldNotDeleteShopType(Object? a0) => Tr(
    'Could not delete shop type: '
        '$a0',
    'ບໍ່ສາມາດລຶບປະເພດຮ້ານ: $a0',
  );
  static const editShopType = Tr('Edit shop type', 'ແກ້ໄຂປະເພດຮ້ານ');
  static const newShopType = Tr('New shop type', 'ປະເພດຮ້ານໃໝ່');
  static const groupShopsByTheKind = Tr(
    'Group shops by the kind of business they run',
    'ຈັດກຸ່ມຮ້ານຕາມປະເພດທຸລະກິດ',
  );
  static const createShopType = Tr('Create shop type', 'ສ້າງປະເພດຮ້ານ');
  static const basics = Tr('Basics', 'ຂໍ້ມູນພື້ນຖານ');
  static const lettersNumbersAnd = Tr(
    'Letters, numbers and _',
    'ຕົວອັກສອນ, ຕົວເລກ ແລະ _',
  );
  static const english = Tr('English', 'ອັງກິດ');
  static const englishName = Tr('English name', 'ຊື່ພາສາອັງກິດ');
  static const laoOptional = Tr('Lao (optional)', 'ລາວ (ບໍ່ບັງຄັບ)');
  static const optionalShownToOwnersWhen = Tr(
    'Optional. Shown to owners when they pick a shop type.',
    'ບໍ່ບັງຄັບ. ສະແດງໃຫ້ເຈົ້າຂອງເຫັນເມື່ອເລືອກປະເພດຮ້ານ.',
  );
  static const lao = Tr('Lao', 'ລາວ');
  static const addUnit = Tr('Add Unit', 'ເພີ່ມຫົວໜ່ວຍ');
  static const noUnitsFound = Tr('No units found', 'ບໍ່ພົບຫົວໜ່ວຍ');
  static const tryADifferentFilterOr = Tr(
    'Try a different filter or add a new unit.',
    'ລອງກັ່ນຕອງແບບອື່ນ ຫຼື ເພີ່ມຫົວໜ່ວຍໃໝ່.',
  );
  static const active2 = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const inactive2 = Tr('Inactive', 'ບໍ່ເຄື່ອນໄຫວ');
  static Tr code(Object? a0) => Tr('Code: $a0', 'ລະຫັດ: $a0');
  static const defaultText = Tr('DEFAULT', 'ຄ່າເລີ່ມຕົ້ນ');
  static const viewDetails2 = Tr('View Details', 'ເບິ່ງລາຍລະອຽດ');
  static const deactivate = Tr('Deactivate', 'ປິດໃຊ້');
  static const activate = Tr('Activate', 'ເປີດໃຊ້');
  static const setAsDefault = Tr('Set as Default', 'ຕັ້ງເປັນຄ່າເລີ່ມຕົ້ນ');
  static const information2 = Tr('Information', 'ຂໍ້ມູນ');
  static const abbreviation = Tr('Abbreviation', 'ຕົວຫຍໍ້');
  static const category = Tr('Category', 'ໝວດໝູ່');
  static const displayOrder = Tr('Display Order', 'ລຳດັບການສະແດງ');
  static const multilingualNames = Tr('Multilingual Names', 'ຊື່ຫຼາຍພາສາ');
  static const defaultText2 = Tr('Default', 'ຄ່າເລີ່ມຕົ້ນ');
  static const timestamps2 = Tr('Timestamps', 'ເວລາບັນທຶກ');
  static Tr activate2(Object? a0) => Tr('Activate "$a0"?', 'ເປີດໃຊ້ "$a0" ບໍ?');
  static const theUnitBecomesAvailableFor = Tr(
    'The unit becomes available for use immediately.',
    'ຫົວໜ່ວຍຈະໃຊ້ໄດ້ທັນທີ.',
  );
  static const unitActivated = Tr('Unit activated', 'ເປີດໃຊ້ຫົວໜ່ວຍແລ້ວ');
  static const couldNotActivateUnit = Tr(
    'Could not activate unit',
    'ບໍ່ສາມາດເປີດໃຊ້ຫົວໜ່ວຍ',
  );
  static Tr deactivate2(Object? a0) =>
      Tr('Deactivate "$a0"?', 'ປິດໃຊ້ "$a0" ບໍ?');
  static const theUnitCanNoLonger = Tr(
    'The unit can no longer be used. You can activate it again later.',
    'ຫົວໜ່ວຍຈະໃຊ້ບໍ່ໄດ້ອີກ. ທ່ານເປີດໃຊ້ຄືນໄດ້ພາຍຫຼັງ.',
  );
  static const unitDeactivated = Tr('Unit deactivated', 'ປິດໃຊ້ຫົວໜ່ວຍແລ້ວ');
  static const couldNotDeactivateUnit = Tr(
    'Could not deactivate unit',
    'ບໍ່ສາມາດປິດໃຊ້ຫົວໜ່ວຍ',
  );
  static Tr delete2(Object? a0) => Tr('Delete "$a0"?', 'ລຶບ "$a0" ບໍ?');
  static const theUnitIsRemovedFrom = Tr(
    'The unit is removed from every list. It cannot be restored from '
        'this console.',
    'ຫົວໜ່ວຍຈະຖືກເອົາອອກຈາກທຸກລາຍການ. ກູ້ຄືນຈາກລະບົບນີ້ບໍ່ໄດ້.',
  );
  static const unitDeleted = Tr('Unit deleted', 'ລຶບຫົວໜ່ວຍແລ້ວ');
  static const couldNotDeleteUnit = Tr(
    'Could not delete unit',
    'ບໍ່ສາມາດລຶບຫົວໜ່ວຍ',
  );
  static const setAsDefault2 = Tr('Set as default?', 'ຕັ້ງເປັນຄ່າເລີ່ມຕົ້ນບໍ?');
  static Tr becomesTheDefaultUnitFor(Object? a0, Object? a1) => Tr(
    '"$a0" becomes the default unit for the '
        '$a1 category, replacing the current default.',
    '"$a0" ຈະເປັນຫົວໜ່ວຍເລີ່ມຕົ້ນຂອງໝວດ $a1 ແທນອັນປັດຈຸບັນ.',
  );
  static const setAsDefault3 = Tr('Set as default', 'ຕັ້ງເປັນຄ່າເລີ່ມຕົ້ນ');
  static const unitSetAsDefault = Tr(
    'Unit set as default',
    'ຕັ້ງຫົວໜ່ວຍເປັນຄ່າເລີ່ມຕົ້ນແລ້ວ',
  );
  static const failedToSetDefaultUnit = Tr(
    'Failed to set default unit',
    'ຕັ້ງຫົວໜ່ວຍເລີ່ມຕົ້ນບໍ່ສຳເລັດ',
  );
  static const thai = Tr('Thai', 'ໄທ');
  static const vietnamese = Tr('Vietnamese', 'ຫວຽດນາມ');
  static const chinese = Tr('Chinese', 'ຈີນ');
  static const editUnit = Tr('Edit unit', 'ແກ້ໄຂຫົວໜ່ວຍ');
  static const newUnit = Tr('New unit', 'ຫົວໜ່ວຍໃໝ່');
  static const aUnitOfMeasureShops = Tr(
    'A unit of measure shops can sell products in',
    'ຫົວໜ່ວຍວັດແທກທີ່ຮ້ານໃຊ້ຂາຍສິນຄ້າ',
  );
  static const createUnit = Tr('Create unit', 'ສ້າງຫົວໜ່ວຍ');
  static const basics2 = Tr('Basics', 'ຂໍ້ມູນພື້ນຖານ');
  static const abbreviation2 = Tr('Abbreviation', 'ຕົວຫຍໍ້');
  static const category2 = Tr('Category', 'ໝວດໝູ່');
  static const chooseACategory = Tr('Choose a category', 'ເລືອກໝວດໝູ່');
  static const sortOrder = Tr('Sort order', 'ລຳດັບການຮຽງ');
  static const english2 = Tr('English', 'ອັງກິດ');
  static const englishName2 = Tr('English name', 'ຊື່ພາສາອັງກິດ');
  static const lao2 = Tr('Lao', 'ລາວ');
  static const moreLanguages = Tr('More languages', 'ພາສາອື່ນໆ');
  static const thaiVietnameseChinese = Tr(
    'Thai, Vietnamese, Chinese',
    'ໄທ, ຫວຽດນາມ, ຈີນ',
  );
  static const descriptionOptional = Tr(
    'Description (optional)',
    'ຄຳອະທິບາຍ (ບໍ່ບັງຄັບ)',
  );
  static const active3 = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const shopsCanPickThisUnit = Tr(
    'Shops can pick this unit for products',
    'ຮ້ານສາມາດເລືອກຫົວໜ່ວຍນີ້ໃຫ້ສິນຄ້າ',
  );
  static const defaultUnit = Tr('Default unit', 'ຫົວໜ່ວຍເລີ່ມຕົ້ນ');
  static const preSelectedWhenCreatingNew = Tr(
    'Pre-selected when creating new products',
    'ເລືອກໄວ້ລ່ວງໜ້າເມື່ອສ້າງສິນຄ້າໃໝ່',
  );
}
