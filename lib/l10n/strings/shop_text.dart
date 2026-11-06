import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class ShopText {
  static const namePhoneEmailOwnerOr = Tr(
    'Name, phone, email, owner or ID…',
    'ຊື່, ເບີໂທ, ອີເມວ, ເຈົ້າຂອງ ຫຼື ໄອດີ…',
  );
  static const active = Tr('Active', 'ເປີດໃຊ້ງານ');
  static const suspended = Tr('Suspended', 'ຖືກລະງັບ');
  static const inactive = Tr('Inactive', 'ບໍ່ເຄື່ອນໄຫວ');
  static const deleted = Tr('Deleted', 'ຖືກລຶບ');
  static const noShopsFound = Tr('No shops found', 'ບໍ່ພົບຮ້ານ');
  static const tryADifferentSearchOr = Tr(
    'Try a different search or filter.',
    'ລອງຄົ້ນຫາ ຫຼື ກັ່ນຕອງແບບອື່ນ.',
  );
  static Tr owner(Object? a0) => Tr('Owner: $a0', 'ເຈົ້າຂອງ: $a0');
  static Tr branchOf(Object? a0) => Tr('Branch of: $a0', 'ສາຂາຂອງ: $a0');
  static const viewDetails = Tr('View Details', 'ເບິ່ງລາຍລະອຽດ');
  static const restore = Tr('Restore', 'ກູ້ຄືນ');
  static const viewProducts = Tr('View Products', 'ເບິ່ງສິນຄ້າ');
  static const suspend = Tr('Suspend', 'ລະງັບ');
  static const activate = Tr('Activate', 'ເປີດໃຊ້');
  static const branches = Tr('Branches', 'ສາຂາ');
  static const linkAsBranch = Tr('Link as branch…', 'ເຊື່ອມເປັນສາຂາ…');
  static const unlinkBranch = Tr('Unlink branch…', 'ຍົກເລີກການເຊື່ອມສາຂາ…');
  static const changeOwner = Tr('Change owner…', 'ປ່ຽນເຈົ້າຂອງ…');
  static const ownerHistory = Tr('Owner history', 'ປະຫວັດເຈົ້າຂອງ');
  static const resetData = Tr('Reset data…', 'ຣີເຊັດຂໍ້ມູນ…');
  static const deleteShop = Tr('Delete shop…', 'ລຶບຮ້ານ…');
  static const linkedAsABranch = Tr('Linked as a branch', 'ເຊື່ອມເປັນສາຂາແລ້ວ');
  static const unlinkedFromTheGroup = Tr(
    'Unlinked from the group',
    'ຍົກເລີກການເຊື່ອມຈາກກຸ່ມແລ້ວ',
  );
  static const ownerChanged = Tr('Owner changed', 'ປ່ຽນເຈົ້າຂອງແລ້ວ');
  static const shopInformation = Tr('Shop Information', 'ຂໍ້ມູນຮ້ານ');
  static const businessName = Tr('Business Name', 'ຊື່ທຸລະກິດ');
  static const businessType = Tr('Business Type', 'ປະເພດທຸລະກິດ');
  static const branchOf2 = Tr('Branch of', 'ສາຂາຂອງ');
  static const deletedOn = Tr('Deleted on', 'ລຶບເມື່ອ');
  static const subscription = Tr('Subscription', 'ການສະໝັກໃຊ້');
  static const expires = Tr('Expires', 'ໝົດອາຍຸ');
  static const sameAsMainShop = Tr('Same as main shop', 'ຄືກັບຮ້ານຫຼັກ');
  static const employees = Tr('Employees', 'ພະນັກງານ');
  static const products = Tr('Products', 'ສິນຄ້າ');
  static const restoreShop = Tr('Restore Shop', 'ກູ້ຄືນຮ້ານ');
  static Tr viewProducts2(Object? a0) =>
      Tr('View Products ($a0)', 'ເບິ່ງສິນຄ້າ ($a0)');
  static const restoreShop2 = Tr('Restore shop', 'ກູ້ຄືນຮ້ານ');
  static Tr willBeActiveAgainWith(Object? a0) => Tr(
    '"$a0" will be active again with all its products, staff '
        'and sales history. Its owner and staff can sign in to it right away.',
    '"$a0" ຈະເປີດໃຊ້ຄືນພ້ອມສິນຄ້າ, ພະນັກງານ ແລະ ປະຫວັດການຂາຍທັງໝົດ. ເຈົ້າຂອງ ແລະ ພະນັກງານເຂົ້າສູ່ລະບົບໄດ້ທັນທີ.',
  );
  static Tr hasBeenRestored(Object? a0) =>
      Tr('"$a0" has been restored', 'ກູ້ຄືນ "$a0" ແລ້ວ');
  static Tr couldNotRestore(Object? a0, Object? a1) =>
      Tr('Could not restore "$a0": $a1', 'ບໍ່ສາມາດກູ້ຄືນ "$a0": $a1');
  static const deleteShop2 = Tr('Delete shop', 'ລຶບຮ້ານ');
  static Tr willBeClosedItsOwner(Object? a0) => Tr(
    '"$a0" will be closed: its owner and staff can no longer '
        'use it. Its products, staff and sales history are kept, and you '
        'can restore it from the Deleted filter.',
    '"$a0" ຈະຖືກປິດ: ເຈົ້າຂອງ ແລະ ພະນັກງານຈະໃຊ້ບໍ່ໄດ້ອີກ. ສິນຄ້າ, ພະນັກງານ ແລະ ປະຫວັດການຂາຍຍັງເກັບໄວ້ ແລະ ທ່ານກູ້ຄືນໄດ້ຈາກຕົວກັ່ນຕອງ "ຖືກລຶບ".',
  );
  static Tr hasBeenDeleted(Object? a0) =>
      Tr('"$a0" has been deleted', 'ລຶບ "$a0" ແລ້ວ');
  static Tr couldNotDelete(Object? a0, Object? a1) =>
      Tr('Could not delete "$a0": $a1', 'ບໍ່ສາມາດລຶບ "$a0": $a1');
  static const suspendShop = Tr('Suspend shop', 'ລະງັບຮ້ານ');
  static const activateShop = Tr('Activate shop', 'ເປີດໃຊ້ຮ້ານ');
  static Tr andItsStaffWillBe(Object? a0) => Tr(
    '"$a0" and its staff will be blocked from using UFin until reactivated.',
    '"$a0" ແລະ ພະນັກງານຈະຖືກບລັອກບໍ່ໃຫ້ໃຊ້ UFin ຈົນກວ່າຈະເປີດໃຊ້ຄືນ.',
  );
  static Tr andItsStaffWillRegain(Object? a0) => Tr(
    '"$a0" and its staff will regain access to UFin.',
    '"$a0" ແລະ ພະນັກງານຈະກັບມາໃຊ້ UFin ໄດ້.',
  );
  static Tr hasBeenSuspended(Object? a0) =>
      Tr('"$a0" has been suspended', 'ລະງັບ "$a0" ແລ້ວ');
  static Tr hasBeenActivated(Object? a0) =>
      Tr('"$a0" has been activated', 'ເປີດໃຊ້ "$a0" ແລ້ວ');
  static Tr couldNotUpdate(Object? a0, Object? a1) =>
      Tr('Could not update "$a0": $a1', 'ບໍ່ສາມາດອັບເດດ "$a0": $a1');
  static const typeTheShopNameTo = Tr(
    'Type the shop name to confirm',
    'ພິມຊື່ຮ້ານເພື່ອຢືນຢັນ',
  );
  static Tr exactly(Object? a0) => Tr('Exactly "$a0"', 'ໃຫ້ຕົງກັບ "$a0"');
  static const typeTheShopName = Tr('Type the shop name', 'ພິມຊື່ຮ້ານ');
  static Tr doesNotMatch(Object? a0) =>
      Tr('Does not match "$a0"', 'ບໍ່ກົງກັບ "$a0"');
  static const keptInTheShopS = Tr(
    'Kept in the shop\'s owner history',
    'ເກັບໄວ້ໃນປະຫວັດເຈົ້າຂອງຮ້ານ',
  );
  static const theMainShopHasAnother = Tr(
    'The main shop has another owner. Turn on "Move to the main '
        'shop\'s owner" to link it.',
    'ຮ້ານຫຼັກມີເຈົ້າຂອງອື່ນ. ເປີດ "ຍ້າຍໄປຫາເຈົ້າຂອງຮ້ານຫຼັກ" ເພື່ອເຊື່ອມ.',
  );
  static const linkAsBranch2 = Tr('Link as branch', 'ເຊື່ອມເປັນສາຂາ');
  static const forACustomerWhoOpened = Tr(
    'For a customer who opened a second shop on its own account and now '
        'wants one group. The shop keeps its products, sales, customers and '
        'staff, and runs on the main shop\'s plan from now on. Its own plan '
        'ends; paid time left on it blocks this until it is refunded or '
        'carried over.',
    'ສຳລັບລູກຄ້າທີ່ເປີດຮ້ານທີສອງໃນບັນຊີແຍກ ແລະ ຕ້ອງການລວມເປັນກຸ່ມດຽວ. ຮ້ານຈະເກັບສິນຄ້າ, ການຂາຍ, ລູກຄ້າ ແລະ ພະນັກງານໄວ້ ແລະ ໃຊ້ແພັກເກດຂອງຮ້ານຫຼັກຕັ້ງແຕ່ນີ້. ແພັກເກດເດີມຈະສິ້ນສຸດ; ຖ້າຍັງມີເວລາທີ່ຈ່າຍແລ້ວເຫຼືອ ຈະເຊື່ອມບໍ່ໄດ້ຈົນກວ່າຈະຄືນເງິນ ຫຼື ໂອນຍ້າຍ.',
  );
  static const mainShop = Tr('Main shop', 'ຮ້ານຫຼັກ');
  static const theShopThatHoldsThe = Tr(
    'The shop that holds the plan. It cannot be a branch itself.',
    'ຮ້ານທີ່ຖືແພັກເກດ. ບໍ່ສາມາດເປັນສາຂາເອງ.',
  );
  static const pleaseSelectTheMainShop = Tr(
    'Please select the main shop',
    'ກະລຸນາເລືອກຮ້ານຫຼັກ',
  );
  static const chooseADifferentShop = Tr(
    'Choose a different shop',
    'ເລືອກຮ້ານອື່ນ',
  );
  static const moveToTheMainShop = Tr(
    "Move to the main shop's owner",
    'ຍ້າຍໄປຫາເຈົ້າຂອງຮ້ານຫຼັກ',
  );
  static Tr ownedByNowItWill(Object? a0, Object? a1) => Tr(
    'Owned by $a0 now; '
        'it will belong to $a1, '
        'so one login sees the whole group.',
    'ປັດຈຸບັນເປັນຂອງ $a0; ຈະເປັນຂອງ $a1 ເພື່ອໃຫ້ບັນຊີດຽວເຫັນທັງກຸ່ມ.',
  );
  static const switchOffThePreviousOwner = Tr(
    "Switch off the previous owner's access",
    'ປິດສິດເຂົ້າເຖິງຂອງເຈົ້າຂອງເກົ່າ',
  );
  static const offByDefaultTillsMay = Tr(
    'Off by default: tills may still be signed in with the old '
        'account. The new owner can switch it off later in Staff. '
        'Turning it on signs them out on every device.',
    'ປິດໄວ້ເປັນຄ່າເລີ່ມຕົ້ນ: ເຄື່ອງຂາຍອາດຍັງເຂົ້າສູ່ລະບົບດ້ວຍບັນຊີເກົ່າ. ເຈົ້າຂອງໃໝ່ປິດໄດ້ພາຍຫຼັງໃນໜ້າພະນັກງານ. ຖ້າເປີດ ຈະອອກຈາກລະບົບໃນທຸກອຸປະກອນ.',
  );
  static const linkEvenIfThePlan = Tr(
    'Link even if the plan has no branches',
    'ເຊື່ອມເຖິງວ່າແພັກເກດບໍ່ຮອງຮັບສາຂາ',
  );
  static const onlyForADealAgreed = Tr(
    'Only for a deal agreed outside the price list. Without '
        'branches on its plan the group\'s branches are read-only. '
        'Noted in subscription history.',
    'ສະເພາະຂໍ້ຕົກລົງນອກລາຍການລາຄາ. ຖ້າແພັກເກດບໍ່ຮອງຮັບສາຂາ ສາຂາໃນກຸ່ມຈະອ່ານໄດ້ຢ່າງດຽວ. ບັນທຶກໄວ້ໃນປະຫວັດການສະໝັກໃຊ້.',
  );
  static const eGOwnerAskedTo = Tr(
    'e.g. owner asked to merge their two shops',
    'ເຊັ່ນ: ເຈົ້າຂອງຂໍລວມສອງຮ້ານ',
  );
  static const unlinkFromBranchGroup = Tr(
    'Unlink from branch group',
    'ຍົກເລີກການເຊື່ອມຈາກກຸ່ມສາຂາ',
  );
  static Tr branchOf3(Object? a0, Object? a1) =>
      Tr('$a0 · branch of $a1', '$a0 · ສາຂາຂອງ $a1');
  static const unlink = Tr('Unlink', 'ຍົກເລີກການເຊື່ອມ');
  static const theShopBecomesASeparate = Tr(
    'The shop becomes a separate shop on the Free plan, as a newly '
        'registered one. It keeps its products, sales, customers and staff. '
        'It stops sharing the group\'s plan, stock transfers and reports.',
    'ຮ້ານຈະເປັນຮ້ານແຍກທີ່ໃຊ້ແພັກເກດຟຣີ ຄືຮ້ານລົງທະບຽນໃໝ່. ຍັງເກັບສິນຄ້າ, ການຂາຍ, ລູກຄ້າ ແລະ ພະນັກງານ. ຈະບໍ່ໃຊ້ແພັກເກດ, ການໂອນສະຕັອກ ແລະ ລາຍງານຮ່ວມກັບກຸ່ມອີກ.',
  );
  static const leaveEmptyToKeepIt = Tr(
    'Leave empty to keep it with the group\'s owner.',
    'ປ່ອຍວ່າງເພື່ອໃຫ້ຢູ່ກັບເຈົ້າຂອງກຸ່ມ.',
  );
  static const handToAnotherAccountOptional = Tr(
    'Hand to another account (optional)',
    'ມອບໃຫ້ບັນຊີອື່ນ (ບໍ່ບັງຄັບ)',
  );
  static const switchOffTheGroupOwner = Tr(
    "Switch off the group owner's access",
    'ປິດສິດເຂົ້າເຖິງຂອງເຈົ້າຂອງກຸ່ມ',
  );
  static const onByDefaultOnceHanded = Tr(
    'On by default: once handed back it is another business. '
        'Signs them out on every device.',
    'ເປີດໄວ້ເປັນຄ່າເລີ່ມຕົ້ນ: ເມື່ອມອບຄືນແລ້ວແມ່ນທຸລະກິດອື່ນ. ຈະອອກຈາກລະບົບໃນທຸກອຸປະກອນ.',
  );
  static const eGBranchSoldTo = Tr(
    'e.g. branch sold to its manager',
    'ເຊັ່ນ: ຂາຍສາຂາໃຫ້ຜູ້ຈັດການ',
  );
  static const changeOwner2 = Tr('Change owner', 'ປ່ຽນເຈົ້າຂອງ');
  static Tr ownedBy(Object? a0, Object? a1) =>
      Tr('$a0 · owned by $a1', '$a0 · ເປັນຂອງ $a1');
  static const handsTheShopToAnother = Tr(
    'Hands the shop to another account. The plan, its expiry, the data '
        'and the staff stay as they are. A shop with branches moves as a '
        'group or not at all, so unlink its branches first.',
    'ມອບຮ້ານໃຫ້ບັນຊີອື່ນ. ແພັກເກດ, ວັນໝົດອາຍຸ, ຂໍ້ມູນ ແລະ ພະນັກງານຍັງຄືເກົ່າ. ຮ້ານທີ່ມີສາຂາຕ້ອງຍ້າຍທັງກຸ່ມ ຈຶ່ງຕ້ອງຍົກເລີກການເຊື່ອມສາຂາກ່ອນ.',
  );
  static const newOwner = Tr('New owner', 'ເຈົ້າຂອງໃໝ່');
  static const onByDefaultSignsThem = Tr(
    'On by default. Signs them out on every device, including '
        'other shops they still own.',
    'ເປີດໄວ້ເປັນຄ່າເລີ່ມຕົ້ນ. ຈະອອກຈາກລະບົບໃນທຸກອຸປະກອນ ລວມທັງຮ້ານອື່ນທີ່ຍັງເປັນເຈົ້າຂອງ.',
  );
  static const eGShopSoldId = Tr(
    'e.g. shop sold; ID checked in person',
    'ເຊັ່ນ: ຂາຍຮ້ານ; ກວດບັດປະຈຳຕົວແລ້ວ',
  );
  static Tr isOwnedByAsA(Object? a0, Object? a1, Object? a2) => Tr(
    '"$a0" is owned by $a1, as a branch of $a2.',
    '"$a0" ເປັນຂອງ $a1 ໃນຖານະສາຂາຂອງ $a2.',
  );
  static Tr isOwnedBy(Object? a0, Object? a1) =>
      Tr('"$a0" is owned by $a1.', '"$a0" ເປັນຂອງ $a1.');
  static const staffToReview = Tr('Staff to review', 'ພະນັກງານທີ່ຄວນກວດສອບ');
  static const stillActiveHereAndTied = Tr(
    'Still active here and tied to the previous owner. Nobody was '
        'removed. The shop\'s owner can switch them off in Staff.',
    'ຍັງເປີດໃຊ້ຢູ່ ແລະ ຂຶ້ນກັບເຈົ້າຂອງເກົ່າ. ບໍ່ມີໃຜຖືກເອົາອອກ. ເຈົ້າຂອງຮ້ານປິດໄດ້ໃນໜ້າພະນັກງານ.',
  );
  static const previousOwner = Tr('previous owner', 'ເຈົ້າຂອງເກົ່າ');
  static const branches2 = Tr('Branches', 'ສາຂາ');
  static const couldnTLoadBranches = Tr(
    "Couldn't load branches",
    'ບໍ່ສາມາດໂຫຼດສາຂາ',
  );
  static const noBranches = Tr('No branches', 'ບໍ່ມີສາຂາ');
  static const linkAnExistingShopWith = Tr(
    'Link an existing shop with "Link as branch" on it.',
    'ເຊື່ອມຮ້ານທີ່ມີຢູ່ດ້ວຍ "ເຊື່ອມເປັນສາຂາ" ຢູ່ຮ້ານນັ້ນ.',
  );
  static Tr staff(Object? a0) => Tr('$a0 staff', 'ພະນັກງານ $a0');
  static Tr products2(Object? a0) => Tr('$a0 products', 'ສິນຄ້າ $a0');
  static const ownerHistory2 = Tr('Owner history', 'ປະຫວັດເຈົ້າຂອງ');
  static const couldnTLoadOwnerHistory = Tr(
    "Couldn't load owner history",
    'ບໍ່ສາມາດໂຫຼດປະຫວັດເຈົ້າຂອງ',
  );
  static const noOwnerChanges = Tr('No owner changes', 'ບໍ່ມີການປ່ຽນເຈົ້າຂອງ');
  static const thisShopHasKeptThe = Tr(
    'This shop has kept the owner it was registered with.',
    'ຮ້ານນີ້ຍັງເປັນຂອງເຈົ້າຂອງທີ່ລົງທະບຽນໄວ້.',
  );
  static Tr by(Object? a0) => Tr('by $a0', 'ໂດຍ $a0');
  static const shopDataReset = Tr('Shop data reset', 'ຣີເຊັດຂໍ້ມູນຮ້ານແລ້ວ');
  static Tr hadNothingToRemove(Object? a0) =>
      Tr('"$a0" had nothing to remove.', '"$a0" ບໍ່ມີຂໍ້ມູນໃຫ້ລຶບ.');
  static Tr isEmptyAndReadyTo(Object? a0) => Tr(
    '"$a0" is empty and ready to be keyed in again.',
    '"$a0" ວ່າງແລ້ວ ພ້ອມໃສ່ຂໍ້ມູນໃໝ່.',
  );
  static const totalRecords = Tr('Total records', 'ລາຍການທັງໝົດ');
  static const picturesInStorage = Tr('Pictures in storage', 'ຮູບໃນບ່ອນເກັບ');
  static const storageCouldNotBeReached = Tr(
    'Storage could not be reached, so its pictures were left '
        'there. Nothing shows them any more.',
    'ເຊື່ອມຕໍ່ບ່ອນເກັບບໍ່ໄດ້ ຈຶ່ງປະຮູບໄວ້. ບໍ່ມີບ່ອນໃດສະແດງຮູບເຫຼົ່ານັ້ນອີກ.',
  );
  static const picturesInStorageCouldNot = Tr(
    'Pictures in storage could not be counted now. The reset '
        'still deletes them.',
    'ນັບຮູບໃນບ່ອນເກັບບໍ່ໄດ້ຕອນນີ້. ການຣີເຊັດຍັງຈະລຶບຮູບ.',
  );
  static Tr picturesCouldNotBeDeleted(Object? a0) => Tr(
    '$a0 pictures could not be '
        'deleted from storage. Nothing shows them any more.',
    'ລຶບຮູບ $a0 ຮູບອອກຈາກບ່ອນເກັບບໍ່ໄດ້. ບໍ່ມີບ່ອນໃດສະແດງຮູບເຫຼົ່ານັ້ນອີກ.',
  );
  static const resetShopData = Tr('Reset shop data', 'ຣີເຊັດຂໍ້ມູນຮ້ານ');
  static const resetData2 = Tr('Reset data', 'ຣີເຊັດຂໍ້ມູນ');
  static const deletesTheRecordsBelowFor = Tr(
    'Deletes the records below for good, so the shop can be keyed in '
        'again from scratch. This cannot be undone and is not the same as '
        'Delete shop. Use it for a test shop, or one whose products went '
        'in wrong.',
    'ລຶບລາຍການລຸ່ມນີ້ຖາວອນ ເພື່ອໃຫ້ຮ້ານໃສ່ຂໍ້ມູນໃໝ່ຕັ້ງແຕ່ຕົ້ນ. ຍົກເລີກບໍ່ໄດ້ ແລະ ບໍ່ຄືກັບການລຶບຮ້ານ. ໃຊ້ສຳລັບຮ້ານທົດສອບ ຫຼື ຮ້ານທີ່ໃສ່ສິນຄ້າຜິດ.',
  );
  static const willBeRemoved = Tr('Will be removed', 'ຈະຖືກລຶບ');
  static Tr couldNotCountTheRecords(Object? a0) => Tr(
    'Could not count the records: '
        '$a0',
    'ບໍ່ສາມາດນັບລາຍການ: $a0',
  );
  static const retry = Tr('Retry', 'ລອງໃໝ່');
  static Tr recordsOfAnotherShopAre(Object? a0) => Tr(
    '$a0 records of '
        "another shop are tied to this shop's data, so the reset "
        'is refused: it would delete them too. Ask a developer to '
        'look at the shop before resetting it.',
    'ມີ $a0 ລາຍການຂອງຮ້ານອື່ນເຊື່ອມກັບຂໍ້ມູນຮ້ານນີ້ ຈຶ່ງບໍ່ອະນຸຍາດໃຫ້ຣີເຊັດ: ຈະລຶບລາຍການເຫຼົ່ານັ້ນນຳ. ໃຫ້ນັກພັດທະນາກວດສອບກ່ອນຣີເຊັດ.',
  );
  static const nothingToRemoveTheShop = Tr(
    'Nothing to remove: the shop has no products, sales or '
        'customers.',
    'ບໍ່ມີຫຍັງໃຫ້ລຶບ: ຮ້ານບໍ່ມີສິນຄ້າ, ການຂາຍ ຫຼື ລູກຄ້າ.',
  );
  static const staysAsItIs = Tr('Stays as it is', 'ຄົງໄວ້ຄືເກົ່າ');
  static const theShopAndItsSettings = Tr(
    'The shop and its settings, receipt settings, staff and roles, '
        'payment methods, bank accounts, exchange rates, restaurant '
        'areas and tables, expense categories, the subscription and '
        'its payments, the shop logo and bank QR codes. Branches are not '
        "touched, and pictures a branch still shows are kept.",
    'ຮ້ານ ແລະ ການຕັ້ງຄ່າ, ການຕັ້ງຄ່າໃບບິນ, ພະນັກງານ ແລະ ບົດບາດ, ວິທີຊຳລະ, ບັນຊີທະນາຄານ, ອັດຕາແລກປ່ຽນ, ພື້ນທີ່ ແລະ ໂຕະຮ້ານອາຫານ, ໝວດລາຍຈ່າຍ, ການສະໝັກໃຊ້ ແລະ ການຊຳລະ, ໂລໂກ້ຮ້ານ ແລະ QR ທະນາຄານ. ສາຂາບໍ່ໄດ້ຮັບຜົນກະທົບ ແລະ ຮູບທີ່ສາຂາຍັງໃຊ້ຈະເກັບໄວ້.',
  );
  static const haveTheShopSTills = Tr(
    "Have the shop's tills send their offline sales first. A sale still "
        'waiting on a till is refused once its products are gone.',
    'ໃຫ້ເຄື່ອງຂາຍຂອງຮ້ານສົ່ງການຂາຍອອບລາຍກ່ອນ. ການຂາຍທີ່ຍັງຄ້າງຢູ່ເຄື່ອງຈະຖືກປະຕິເສດເມື່ອສິນຄ້າຖືກລຶບ.',
  );
  static const eGTestShopProducts = Tr(
    'e.g. test shop, products keyed in wrong',
    'ເຊັ່ນ: ຮ້ານທົດສອບ, ໃສ່ສິນຄ້າຜິດ',
  );
  static const keptInTheShopS2 = Tr(
    "Kept in the shop's audit log",
    'ເກັບໄວ້ໃນບັນທຶກການກວດສອບຂອງຮ້ານ',
  );
  static Tr products3(Object? a0) => Tr('$a0 — Products', '$a0 — ສິນຄ້າ');
  static const searchProducts = Tr('Search products…', 'ຄົ້ນຫາສິນຄ້າ…');
  static const allProducts = Tr('All Products', 'ສິນຄ້າທັງໝົດ');
  static const inStockOnly = Tr('In Stock Only', 'ສະເພາະທີ່ມີໃນສະຕັອກ');
  static const n1ProductLoaded = Tr('1 product loaded', 'ໂຫຼດສິນຄ້າ 1 ລາຍການ');
  static Tr productsLoaded(Object? a0) =>
      Tr('$a0 products loaded', 'ໂຫຼດສິນຄ້າ $a0 ລາຍການ');
  static const moreAvailable = Tr('• more available', '• ຍັງມີອີກ');
  static const noProductsFound = Tr('No products found', 'ບໍ່ພົບສິນຄ້າ');
  static const thisShopHasNoProducts = Tr(
    'This shop has no products matching the filters.',
    'ຮ້ານນີ້ບໍ່ມີສິນຄ້າທີ່ກົງກັບຕົວກັ່ນຕອງ.',
  );
  static Tr sku(Object? a0) => Tr('SKU: $a0', 'SKU: $a0');
  static const outOfStock = Tr('Out of Stock', 'ໝົດສະຕັອກ');
  static Tr qty(Object? a0) => Tr('Qty: $a0', 'ຈຳນວນ: $a0');
  static const inactive2 = Tr('Inactive', 'ບໍ່ເຄື່ອນໄຫວ');
  static const pleaseSelectAShop = Tr(
    'Please select a shop',
    'ກະລຸນາເລືອກຮ້ານ',
  );
  static const searchAndSelectAShop = Tr(
    'Search and select a shop',
    'ຄົ້ນຫາ ແລະ ເລືອກຮ້ານ',
  );
  static const shopCannotBeChangedHere = Tr(
    'Shop cannot be changed here',
    'ປ່ຽນຮ້ານຢູ່ບ່ອນນີ້ບໍ່ໄດ້',
  );
  static const selectShop = Tr('Select shop', 'ເລືອກຮ້ານ');
  static const searchByShopNameOwner = Tr(
    'Search by shop name, owner or phone',
    'ຄົ້ນຫາຕາມຊື່ຮ້ານ, ເຈົ້າຂອງ ຫຼື ເບີໂທ',
  );
  static const couldnTLoadShops = Tr("Couldn't load shops", 'ບໍ່ສາມາດໂຫຼດຮ້ານ');
  static const noShopsFound2 = Tr('No shops found', 'ບໍ່ພົບຮ້ານ');
  static Tr noShopMatches(Object? a0) =>
      Tr('No shop matches "$a0".', 'ບໍ່ມີຮ້ານທີ່ກົງກັບ "$a0".');
  static const loadMoreFailedRetry = Tr(
    'Load more failed · Retry',
    'ໂຫຼດເພີ່ມບໍ່ສຳເລັດ · ລອງໃໝ່',
  );
}
