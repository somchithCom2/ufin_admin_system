import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class PlansText {
  static const deactivatePlan = Tr('Deactivate plan?', 'ປິດໃຊ້ແພັກເກດບໍ?');
  static Tr willNoLongerBeOffered(Object? a0) => Tr(
    '"$a0" will no longer be offered to shops. Existing subscriptions are not affected.',
    '"$a0" ຈະບໍ່ຖືກສະເໜີໃຫ້ຮ້ານຄ້າອີກ. ການສະໝັກໃຊ້ທີ່ມີຢູ່ແລ້ວບໍ່ໄດ້ຮັບຜົນກະທົບ.',
  );
  static const deactivate = Tr('Deactivate', 'ປິດໃຊ້');
  static Tr couldNotUpdate(Object? a0, Object? a1) =>
      Tr('Could not update "$a0": $a1', 'ບໍ່ສາມາດອັບເດດ "$a0": $a1');
  static const addPlan = Tr('Add Plan', 'ເພີ່ມແພັກເກດ');
  static const noPlansYet = Tr('No plans yet', 'ຍັງບໍ່ມີແພັກເກດ');
  static const createAPlanToStart = Tr(
    'Create a plan to start offering subscriptions.',
    'ສ້າງແພັກເກດເພື່ອເລີ່ມໃຫ້ບໍລິການການສະໝັກໃຊ້.',
  );
  static const monthly = Tr('Monthly', 'ລາຍເດືອນ');
  static const yearly = Tr('Yearly', 'ລາຍປີ');
  static const employees = Tr('Employees', 'ພະນັກງານ');
  static const products = Tr('Products', 'ສິນຄ້າ');
  static const ordersMo = Tr('Orders/mo', 'ອໍເດີ/ເດືອນ');
  static Tr active(Object? a0) => Tr('Active: $a0', 'ເປີດໃຊ້: $a0');
  static Tr total(Object? a0) => Tr('Total: $a0', 'ທັງໝົດ: $a0');
  static Tr daysTrial(Object? a0) => Tr('$a0 days trial', 'ທົດລອງ $a0 ມື້');
}
