import 'package:ufin_admin_system/l10n/tr.dart';

abstract final class ModelText {
  static const cash = Tr('Cash', 'ເງິນສົດ');
  static const bankTransfer = Tr('Bank Transfer', 'ໂອນຜ່ານທະນາຄານ');
  static const card = Tr('Card', 'ບັດ');
  static const creditCard = Tr('Credit Card', 'ບັດເຄຣດິດ');
  static const linkedIntoABranchGroup = Tr(
    'Linked into a branch group',
    'ເຊື່ອມເຂົ້າກຸ່ມສາຂາ',
  );
  static const unlinkedFromABranchGroup = Tr(
    'Unlinked from a branch group',
    'ຍົກເລີກການເຊື່ອມຈາກກຸ່ມສາຂາ',
  );
  static const ownerChanged = Tr('Owner changed', 'ປ່ຽນເຈົ້າຂອງ');
  static const enterAWholeNumber = Tr('Enter a whole number', 'ໃສ່ຈຳນວນເຕັມ');
  static Tr planOf(Object? a0) => Tr('Plan of $a0', 'ແພັກເກດຂອງ $a0');
  static const categories = Tr('Categories', 'ໝວດໝູ່');
  static const products = Tr('Products', 'ສິນຄ້າ');
  static const variants = Tr('Variants', 'ຕົວເລືອກສິນຄ້າ');
  static const orders = Tr('Orders', 'ອໍເດີ');
  static const customers = Tr('Customers', 'ລູກຄ້າ');
  static const debts = Tr('Debts', 'ໜີ້');
  static const stockMovements = Tr('Stock movements', 'ການເຄື່ອນໄຫວສະຕັອກ');
  static const stockBatches = Tr('Stock batches', 'ລັອດສະຕັອກ');
  static const purchaseOrders = Tr('Purchase orders', 'ໃບສັ່ງຊື້');
  static const expenses = Tr('Expenses', 'ລາຍຈ່າຍ');
  static const suppliers = Tr('Suppliers', 'ຜູ້ສະໜອງ');
  static const discounts = Tr('Discounts', 'ສ່ວນຫຼຸດ');
  static const linkedRecords = Tr('Linked records', 'ລາຍການທີ່ເຊື່ອມໂຍງ');
  static const upgraded = Tr('Upgraded', 'ອັບເກຣດ');
  static const downgraded = Tr('Downgraded', 'ດາວເກຣດ');
  static const renewed = Tr('Renewed', 'ຕໍ່ອາຍຸ');
  static const cancelled = Tr('Cancelled', 'ຍົກເລີກ');
  static const extended = Tr('Extended', 'ຂະຫຍາຍ');
  static const planChanged = Tr('Plan Changed', 'ປ່ຽນແພັກເກດ');
  static const expired = Tr('Expired', 'ໝົດອາຍຸ');
  static const reactivated = Tr('Reactivated', 'ເປີດໃຊ້ຄືນ');
  static const trialStarted = Tr('Trial Started', 'ເລີ່ມທົດລອງ');
  static const trialEnded = Tr('Trial Ended', 'ໝົດທົດລອງ');
  static const paymentReceived = Tr('Payment Received', 'ໄດ້ຮັບການຊຳລະ');
  static const paymentFailed = Tr('Payment Failed', 'ການຊຳລະລົ້ມເຫຼວ');
  static const suspended = Tr('Suspended', 'ຖືກລະງັບ');
  static const unsuspended = Tr('Unsuspended', 'ຍົກເລີກການລະງັບ');
  static const autoRenewOn = Tr('Auto-renew On', 'ເປີດຕໍ່ອາຍຸອັດຕະໂນມັດ');
  static const autoRenewOff = Tr('Auto-renew Off', 'ປິດຕໍ່ອາຍຸອັດຕະໂນມັດ');
  static const completed = Tr('Completed', 'ສຳເລັດ');
  static const pending = Tr('Pending', 'ລໍຖ້າ');
  static const failed = Tr('Failed', 'ລົ້ມເຫຼວ');
  static const refunded = Tr('Refunded', 'ຄືນເງິນແລ້ວ');
  static const cash2 = Tr('Cash', 'ເງິນສົດ');
  static const bankTransfer2 = Tr('Bank Transfer', 'ໂອນຜ່ານທະນາຄານ');
  static const card2 = Tr('Card', 'ບັດ');
  static const creditCard2 = Tr('Credit Card', 'ບັດເຄຣດິດ');
}
