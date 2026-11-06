import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class ReleaseText {
  static const newRelease = Tr('New release', 'ເວີຊັນໃໝ່');
  static const noReleasesYet = Tr('No releases yet', 'ຍັງບໍ່ມີເວີຊັນ');
  static Tr noReleasesYet2(Object? a0) =>
      Tr('No $a0 releases yet', 'ຍັງບໍ່ມີເວີຊັນ $a0');
  static const createAReleaseThenPublish = Tr(
    'Create a release, then publish it to offer the '
        'update to shops.',
    'ສ້າງເວີຊັນ ແລ້ວເຜີຍແຜ່ເພື່ອໃຫ້ຮ້ານຄ້າອັບເດດ.',
  );
  static Tr all(Object? a0) => Tr('All · $a0', 'ທັງໝົດ · $a0');
  static Tr build(Object? a0, Object? a1, Object? a2) => Tr(
    '$a0 · build $a1'
        ' · $a2',
    '$a0 · ບິວ $a1 · $a2',
  );
  static const mandatory = Tr('Mandatory', 'ບັງຄັບ');
  static const unpublish = Tr('Unpublish', 'ຍົກເລີກການເຜີຍແຜ່');
  static const publish = Tr('Publish', 'ເຜີຍແຜ່');
  static const editNotes = Tr('Edit notes', 'ແກ້ໄຂບັນທຶກ');
  static const newVersionFromThis = Tr(
    'New version from this',
    'ສ້າງເວີຊັນໃໝ່ຈາກອັນນີ້',
  );
  static const copyToAnotherPlatform = Tr(
    'Copy to another platform',
    'ສຳເນົາໄປແພລັດຟອມອື່ນ',
  );
  static const releaseNotes = Tr('Release notes', 'ບັນທຶກການອັບເດດ');
  static const copyNotes = Tr('Copy notes', 'ສຳເນົາບັນທຶກ');
  static const editNotes2 = Tr('Edit notes', 'ແກ້ໄຂບັນທຶກ');
  static const newVersionFromThis2 = Tr(
    'New version from this',
    'ສ້າງເວີຊັນໃໝ່ຈາກອັນນີ້',
  );
  static const copyToAnotherPlatform2 = Tr(
    'Copy to another platform',
    'ສຳເນົາໄປແພລັດຟອມອື່ນ',
  );
  static const mandatory2 = Tr('Mandatory', 'ບັງຄັບ');
  static const liveShopsOnAnOlder = Tr(
    'Live: shops on an older version must update.',
    'ເຜີຍແຜ່ແລ້ວ: ຮ້ານທີ່ໃຊ້ເວີຊັນເກົ່າຕ້ອງອັບເດດ.',
  );
  static const liveShopsOnAnOlder2 = Tr(
    'Live: shops on an older version are offered '
        'this update.',
    'ເຜີຍແຜ່ແລ້ວ: ຮ້ານທີ່ໃຊ້ເວີຊັນເກົ່າຈະໄດ້ຮັບການແນະນຳໃຫ້ອັບເດດ.',
  );
  static const draftNoShopSeesIt = Tr(
    'Draft: no shop sees it until it is published.',
    'ສະບັບຮ່າງ: ບໍ່ມີຮ້ານໃດເຫັນຈົນກວ່າຈະເຜີຍແຜ່.',
  );
  static const unpublish2 = Tr('Unpublish', 'ຍົກເລີກການເຜີຍແຜ່');
  static const publish2 = Tr('Publish', 'ເຜີຍແຜ່');
  static const whatSNew = Tr("What's new", 'ມີຫຍັງໃໝ່');
  static const shopsSeeThisExactlyAs = Tr(
    'Shops see this exactly as written',
    'ຮ້ານຄ້າຈະເຫັນຕາມທີ່ຂຽນໄວ້ທຸກຢ່າງ',
  );
  static const releaseNotes2 = Tr('Release notes', 'ບັນທຶກການອັບເດດ');
  static const build2 = Tr('Build', 'ບິວ');
  static const buildNumber = Tr('Build number', 'ເລກບິວ');
  static const downloadLink = Tr('Download link', 'ລິ້ງດາວໂຫຼດ');
  static const released = Tr('Released', 'ອອກເມື່ອ');
  static const lastEdited = Tr('Last edited', 'ແກ້ໄຂລ່າສຸດ');
  static const platformVersionAndBuildCannot = Tr(
    'Platform, version and build cannot be changed after a '
        'release is made. To fix them, use "New version from this" '
        'or "Copy to another platform", then delete this one.',
    'ແພລັດຟອມ, ເວີຊັນ ແລະ ບິວ ປ່ຽນບໍ່ໄດ້ຫຼັງສ້າງແລ້ວ. ຖ້າຕ້ອງການແກ້ ໃຫ້ໃຊ້ "ສ້າງເວີຊັນໃໝ່ຈາກອັນນີ້" ຫຼື "ສຳເນົາໄປແພລັດຟອມອື່ນ" ແລ້ວລຶບອັນນີ້ອອກ.',
  );
  static Tr copy(Object? a0) => Tr('Copy $a0', 'ສຳເນົາ $a0');
  static Tr publishV(Object? a0) => Tr('Publish v$a0?', 'ເຜີຍແຜ່ v$a0 ບໍ?');
  static Tr everyShopOnAnOlder(Object? a0) => Tr(
    'Every $a0 shop on an older version will be required to '
        'update before using the app.',
    'ທຸກຮ້ານ $a0 ທີ່ໃຊ້ເວີຊັນເກົ່າ ຈະຕ້ອງອັບເດດກ່ອນໃຊ້ແອັບ.',
  );
  static Tr everyShopOnAnOlder2(Object? a0) => Tr(
    'Every $a0 shop on an older version will be offered this '
        'update.',
    'ທຸກຮ້ານ $a0 ທີ່ໃຊ້ເວີຊັນເກົ່າ ຈະໄດ້ຮັບການແນະນຳໃຫ້ອັບເດດນີ້.',
  );
  static const publish3 = Tr('Publish', 'ເຜີຍແຜ່');
  static Tr vPublished(Object? a0) => Tr('v$a0 published', 'ເຜີຍແຜ່ v$a0 ແລ້ວ');
  static Tr unpublishV(Object? a0) =>
      Tr('Unpublish v$a0?', 'ຍົກເລີກການເຜີຍແຜ່ v$a0 ບໍ?');
  static const shopsWillStopBeingOffered = Tr(
    'Shops will stop being offered this update. Shops that already '
        'installed it are not affected.',
    'ຮ້ານຄ້າຈະບໍ່ໄດ້ຮັບການແນະນຳອັບເດດນີ້ອີກ. ຮ້ານທີ່ຕິດຕັ້ງແລ້ວບໍ່ໄດ້ຮັບຜົນກະທົບ.',
  );
  static const unpublish3 = Tr('Unpublish', 'ຍົກເລີກການເຜີຍແຜ່');
  static Tr vUnpublished(Object? a0) =>
      Tr('v$a0 unpublished', 'ຍົກເລີກການເຜີຍແຜ່ v$a0 ແລ້ວ');
  static Tr deleteV(Object? a0) => Tr('Delete v$a0?', 'ລຶບ v$a0 ບໍ?');
  static const thisReleaseIsLiveDeleting = Tr(
    'This release is live. Deleting it stops shops being offered it, '
        'and it is removed permanently.',
    'ເວີຊັນນີ້ເຜີຍແຜ່ຢູ່. ການລຶບຈະເຮັດໃຫ້ຮ້ານບໍ່ໄດ້ຮັບການແນະນຳອີກ ແລະ ຈະຖືກລຶບຖາວອນ.',
  );
  static const thisDraftIsRemovedPermanently = Tr(
    'This draft is removed permanently.',
    'ສະບັບຮ່າງນີ້ຈະຖືກລຶບຖາວອນ.',
  );
  static Tr vDeleted(Object? a0) => Tr('v$a0 deleted', 'ລຶບ v$a0 ແລ້ວ');
  static const releaseUpdated = Tr('Release updated', 'ອັບເດດເວີຊັນແລ້ວ');
  static const releaseSavedAsDraft = Tr(
    'Release saved as draft',
    'ບັນທຶກເວີຊັນເປັນສະບັບຮ່າງແລ້ວ',
  );
  static Tr vSavedAsDraft(Object? a0, Object? a1) =>
      Tr('$a0 v$a1 saved as draft', 'ບັນທຶກ $a0 v$a1 ເປັນສະບັບຮ່າງແລ້ວ');
  static Tr copied(Object? a0) => Tr('$a0 copied', 'ສຳເນົາ $a0 ແລ້ວ');
  static const downloadUrlIsRequired = Tr(
    'Download URL is required',
    'ຕ້ອງໃສ່ລິ້ງດາວໂຫຼດ',
  );
  static const enterAFullHttpS = Tr(
    'Enter a full http(s) link',
    'ໃສ່ລິ້ງ http(s) ໃຫ້ຄົບຖ້ວນ',
  );
  static const versionNameIsRequired = Tr(
    'Version name is required',
    'ຕ້ອງໃສ່ຊື່ເວີຊັນ',
  );
  static Tr alreadyHasV(Object? a0, Object? a1) =>
      Tr('$a0 already has v$a1', '$a0 ມີ v$a1 ແລ້ວ');
  static const enterAPositiveBuildNumber = Tr(
    'Enter a positive build number',
    'ໃສ່ເລກບິວທີ່ເປັນຈຳນວນບວກ',
  );
  static Tr buildIsV(Object? a0, Object? a1, Object? a2) =>
      Tr('$a0 build $a1 is v$a2', '$a0 ບິວ $a1 ແມ່ນ v$a2');
  static const editRelease = Tr('Edit release', 'ແກ້ໄຂເວີຊັນ');
  static Tr copyVToAnotherPlatform(Object? a0) =>
      Tr('Copy v$a0 to another platform', 'ສຳເນົາ v$a0 ໄປແພລັດຟອມອື່ນ');
  static Tr notesAndSettingsCopiedFrom(Object? a0) => Tr(
    'Notes and settings copied from $a0. '
        'Saved as a draft.',
    'ສຳເນົາບັນທຶກ ແລະ ການຕັ້ງຄ່າຈາກ $a0. ບັນທຶກເປັນສະບັບຮ່າງ.',
  );
  static Tr newVersionFromV(Object? a0) =>
      Tr('New version from v$a0', 'ເວີຊັນໃໝ່ຈາກ v$a0');
  static Tr notesAndSettingsCopiedFrom2(Object? a0, Object? a1) => Tr(
    'Notes and settings copied from $a0 '
        'v$a1. Saved as a draft.',
    'ສຳເນົາບັນທຶກ ແລະ ການຕັ້ງຄ່າຈາກ $a0 v$a1. ບັນທຶກເປັນສະບັບຮ່າງ.',
  );
  static const newRelease2 = Tr('New release', 'ເວີຊັນໃໝ່');
  static const savedAsADraftPublish = Tr(
    'Saved as a draft. Publish it when ready.',
    'ບັນທຶກເປັນສະບັບຮ່າງ. ເຜີຍແຜ່ເມື່ອພ້ອມ.',
  );
  static const createRelease = Tr('Create release', 'ສ້າງເວີຊັນ');
  static Tr vBuild(Object? a0, Object? a1, Object? a2) => Tr(
    '$a0 · '
        'v$a1 · build $a2',
    '$a0 · v$a1 · ບິວ $a2',
  );
  static const platformVersionAndBuildCannot2 = Tr(
    'Platform, version and build cannot change once a release is '
        'made. To fix them, use "New version from this" or "Copy to '
        'another platform" on the release, then delete this one.',
    'ແພລັດຟອມ, ເວີຊັນ ແລະ ບິວ ປ່ຽນບໍ່ໄດ້ຫຼັງສ້າງແລ້ວ. ຖ້າຕ້ອງການແກ້ ໃຫ້ໃຊ້ "ສ້າງເວີຊັນໃໝ່ຈາກອັນນີ້" ຫຼື "ສຳເນົາໄປແພລັດຟອມອື່ນ" ແລ້ວລຶບອັນນີ້ອອກ.',
  );
  static const versionName = Tr('Version name', 'ຊື່ເວີຊັນ');
  static const versionCode = Tr('Version code', 'ລະຫັດເວີຊັນ');
  static Tr buildNumberNextFor(Object? a0) => Tr(
    'Build number · next for '
        '$a0',
    'ເລກບິວ · ຖັດໄປສຳລັບ $a0',
  );
  static const buildNumber2 = Tr('Build number', 'ເລກບິວ');
  static const releaseNotes3 = Tr('Release notes', 'ບັນທຶກການອັບເດດ');
  static const title = Tr('Title', 'ຫົວຂໍ້');
  static const fasterCheckoutAndBugFixes = Tr(
    'Faster checkout and bug fixes',
    'ຊຳລະເງິນໄວຂຶ້ນ ແລະ ແກ້ໄຂບັກ',
  );
  static const whatSNew2 = Tr("What's new", 'ມີຫຍັງໃໝ່');
  static const newReceiptLayoutNFixed = Tr(
    '• New receipt layout\n• Fixed printer disconnects',
    '• ຮູບແບບໃບບິນໃໝ່\\n• ແກ້ໄຂບັນຫາເຄື່ອງພິມຫຼຸດການເຊື່ອມຕໍ່',
  );
  static const shopsSeeThisExactlyAs2 = Tr(
    'Shops see this exactly as typed. One change per line.',
    'ຮ້ານຄ້າຈະເຫັນຕາມທີ່ພິມທຸກຢ່າງ. ໜຶ່ງການປ່ຽນແປງຕໍ່ແຖວ.',
  );
  static const changelog = Tr('Changelog', 'ລາຍການປ່ຽນແປງ');
  static const distribution = Tr('Distribution', 'ການແຈກຢາຍ');
  static const downloadUrl = Tr('Download URL', 'ລິ້ງດາວໂຫຼດ');
  static Tr copiedFromCheckItPoints(Object? a0, Object? a1) => Tr(
    'Copied from $a0: '
        'check it points to the $a1 '
        'store',
    'ສຳເນົາຈາກ $a0: ກວດເບິ່ງວ່າລິ້ງໄປຫາຮ້ານແອັບ $a1',
  );
  static Tr fromTheNewestRelease(Object? a0) =>
      Tr('From the newest $a0 release', 'ຈາກເວີຊັນ $a0 ລ່າສຸດ');
  static const mandatoryUpdate = Tr('Mandatory update', 'ອັບເດດແບບບັງຄັບ');
  static const usersMustUpdateBeforeThey = Tr(
    'Users must update before they can keep using the app',
    'ຜູ້ໃຊ້ຕ້ອງອັບເດດກ່ອນຈຶ່ງຈະໃຊ້ແອັບຕໍ່ໄດ້',
  );
}
