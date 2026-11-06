import 'package:ufin_admin_system/l10n/tr.dart';

/// Words and sentences reused across many screens.
abstract final class CommonText {
  // Actions
  static const save = Tr('Save', 'ບັນທຶກ');
  static const saveChanges = Tr('Save changes', 'ບັນທຶກການປ່ຽນແປງ');
  static const cancel = Tr('Cancel', 'ຍົກເລີກ');
  static const confirm = Tr('Confirm', 'ຢືນຢັນ');
  static const close = Tr('Close', 'ປິດ');
  static const delete = Tr('Delete', 'ລຶບ');
  static const edit = Tr('Edit', 'ແກ້ໄຂ');
  static const create = Tr('Create', 'ສ້າງ');
  static const add = Tr('Add', 'ເພີ່ມ');
  static const back = Tr('Back', 'ກັບຄືນ');
  static const next = Tr('Next', 'ຕໍ່ໄປ');
  static const done = Tr('Done', 'ສຳເລັດ');
  static const apply = Tr('Apply', 'ນຳໃຊ້');
  static const reset = Tr('Reset', 'ຣີເຊັດ');
  static const refresh = Tr('Refresh', 'ໂຫຼດຄືນ');
  static const retry = Tr('Try again', 'ລອງໃໝ່');
  static const clear = Tr('Clear', 'ລ້າງ');
  static const clearAllFilters = Tr(
    'Clear all filters',
    'ລ້າງຕົວກັ່ນຕອງທັງໝົດ',
  );
  static const search = Tr('Search', 'ຄົ້ນຫາ');
  static const searchHint = Tr('Search…', 'ຄົ້ນຫາ…');
  static const filter = Tr('Filter', 'ກັ່ນຕອງ');
  static const filters = Tr('Filters', 'ຕົວກັ່ນຕອງ');
  static const viewAll = Tr('View all', 'ເບິ່ງທັງໝົດ');
  static const view = Tr('View', 'ເບິ່ງ');
  static const open = Tr('Open', 'ເປີດ');
  static const copy = Tr('Copy', 'ສຳເນົາ');
  static const copied = Tr('Copied', 'ສຳເນົາແລ້ວ');
  static const more = Tr('More', 'ເພີ່ມເຕີມ');
  static const moreActions = Tr('More actions', 'ຄຳສັ່ງເພີ່ມເຕີມ');
  static const select = Tr('Select', 'ເລືອກ');
  static const change = Tr('Change', 'ປ່ຽນ');
  static const remove = Tr('Remove', 'ເອົາອອກ');
  static const approve = Tr('Approve', 'ອະນຸມັດ');
  static const reject = Tr('Reject', 'ປະຕິເສດ');
  static const enable = Tr('Enable', 'ເປີດໃຊ້');
  static const disable = Tr('Disable', 'ປິດໃຊ້');
  static const loadMore = Tr('Load more', 'ໂຫຼດເພີ່ມ');
  static const report = Tr('Report', 'ລາຍງານ');
  static const details = Tr('Details', 'ລາຍລະອຽດ');
  static const history = Tr('History', 'ປະຫວັດ');
  static const all = Tr('All', 'ທັງໝົດ');
  static const none = Tr('None', 'ບໍ່ມີ');
  static const yes = Tr('Yes', 'ແມ່ນ');
  static const no = Tr('No', 'ບໍ່');
  static const on = Tr('On', 'ເປີດ');
  static const off = Tr('Off', 'ປິດ');
  static const optional = Tr('optional', 'ບໍ່ບັງຄັບ');
  static const required = Tr('Required', 'ຈຳເປັນຕ້ອງໃສ່');
  static const unknown = Tr('Unknown', 'ບໍ່ຮູ້');
  static const notSet = Tr('Not set', 'ບໍ່ໄດ້ກຳນົດ');

  // Fields
  static const status = Tr('Status', 'ສະຖານະ');
  static const name = Tr('Name', 'ຊື່');
  static const description = Tr('Description', 'ຄຳອະທິບາຍ');
  static const code = Tr('Code', 'ລະຫັດ');
  static const type = Tr('Type', 'ປະເພດ');
  static const amount = Tr('Amount', 'ຈຳນວນເງິນ');
  static const currency = Tr('Currency', 'ສະກຸນເງິນ');
  static const date = Tr('Date', 'ວັນທີ');
  static const created = Tr('Created', 'ສ້າງເມື່ອ');
  static const updated = Tr('Updated', 'ອັບເດດເມື່ອ');
  static const email = Tr('Email', 'ອີເມວ');
  static const phone = Tr('Phone', 'ເບີໂທ');
  static const owner = Tr('Owner', 'ເຈົ້າຂອງ');
  static const shop = Tr('Shop', 'ຮ້ານ');
  static const plan = Tr('Plan', 'ແພັກເກດ');
  static const notes = Tr('Notes', 'ໝາຍເຫດ');
  static const reason = Tr('Reason', 'ເຫດຜົນ');
  static const days = Tr('Days', 'ມື້');
  static const total = Tr('Total', 'ລວມ');
  static const id = Tr('ID', 'ໄອດີ');
  static const address = Tr('Address', 'ທີ່ຢູ່');
  static const version = Tr('Version', 'ເວີຊັນ');
  static const platform = Tr('Platform', 'ແພລັດຟອມ');

  // Periods
  static const today = Tr('Today', 'ມື້ນີ້');
  static const yesterday = Tr('Yesterday', 'ມື້ວານ');
  static const thisWeek = Tr('This week', 'ອາທິດນີ້');
  static const thisMonth = Tr('This month', 'ເດືອນນີ້');
  static const thisYear = Tr('This year', 'ປີນີ້');
  static const justNow = Tr('Just now', 'ຫາກໍ່ນີ້');
  static Tr minutesAgo(int n) => Tr('${n}m ago', '$n ນາທີກ່ອນ');
  static Tr hoursAgo(int n) => Tr('${n}h ago', '$n ຊົ່ວໂມງກ່ອນ');
  static Tr daysAgo(int n) => Tr('${n}d ago', '$n ມື້ກ່ອນ');
  static Tr dayCount(int n) => Tr(n == 1 ? '1 day' : '$n days', '$n ມື້');

  // States
  static const loading = Tr('Loading…', 'ກຳລັງໂຫຼດ…');
  static const saving = Tr('Saving…', 'ກຳລັງບັນທຶກ…');
  static const couldNotLoad = Tr("Couldn't load data", 'ບໍ່ສາມາດໂຫຼດຂໍ້ມູນໄດ້');
  static const noResults = Tr('No results', 'ບໍ່ພົບຜົນລັບ');
  static const noResultsHint = Tr(
    'Try a different search or clear the filters.',
    'ລອງຄົ້ນຫາຄຳອື່ນ ຫຼື ລ້າງຕົວກັ່ນຕອງ.',
  );
  static const nothingHere = Tr('Nothing here yet', 'ຍັງບໍ່ມີຂໍ້ມູນ');
  static const somethingWrong = Tr(
    'Something went wrong. Please try again.',
    'ເກີດຂໍ້ຜິດພາດ. ກະລຸນາລອງໃໝ່.',
  );
  static const serverError = Tr(
    'Server error. Please try again later.',
    'ເຊີບເວີຂັດຂ້ອງ. ກະລຸນາລອງໃໝ່ພາຍຫຼັງ.',
  );
  static const enterReason = Tr('Please enter a reason', 'ກະລຸນາໃສ່ເຫດຜົນ');
  static Tr optionalField(String label) =>
      Tr('$label (optional)', '$label (ບໍ່ບັງຄັບ)');
  static Tr showingCount(int shown, int total) =>
      Tr('Showing $shown of $total', 'ສະແດງ $shown ຈາກ $total');
}

/// Labels for the raw status values the backend sends.
abstract final class StatusText {
  static const Map<String, Tr> _known = {
    'active': Tr('Active', 'ເປີດໃຊ້ງານ'),
    'inactive': Tr('Inactive', 'ບໍ່ເຄື່ອນໄຫວ'),
    'pending': Tr('Pending', 'ລໍຖ້າ'),
    'approved': Tr('Approved', 'ອະນຸມັດແລ້ວ'),
    'rejected': Tr('Rejected', 'ຖືກປະຕິເສດ'),
    'paid': Tr('Paid', 'ຊຳລະແລ້ວ'),
    'unpaid': Tr('Unpaid', 'ຍັງບໍ່ຊຳລະ'),
    'completed': Tr('Completed', 'ສຳເລັດ'),
    'success': Tr('Success', 'ສຳເລັດ'),
    'succeeded': Tr('Succeeded', 'ສຳເລັດ'),
    'failed': Tr('Failed', 'ລົ້ມເຫຼວ'),
    'cancelled': Tr('Cancelled', 'ຍົກເລີກແລ້ວ'),
    'canceled': Tr('Cancelled', 'ຍົກເລີກແລ້ວ'),
    'expired': Tr('Expired', 'ໝົດອາຍຸ'),
    'expiring': Tr('Expiring', 'ໃກ້ໝົດອາຍຸ'),
    'expiring_soon': Tr('Expiring soon', 'ໃກ້ໝົດອາຍຸ'),
    'trial': Tr('Trial', 'ທົດລອງ'),
    'trialing': Tr('Trial', 'ທົດລອງ'),
    'suspended': Tr('Suspended', 'ຖືກລະງັບ'),
    'blocked': Tr('Blocked', 'ຖືກບລັອກ'),
    'banned': Tr('Banned', 'ຖືກຫ້າມ'),
    'deleted': Tr('Deleted', 'ຖືກລຶບ'),
    'refunded': Tr('Refunded', 'ຄືນເງິນແລ້ວ'),
    'overdue': Tr('Overdue', 'ເກີນກຳນົດ'),
    'processing': Tr('Processing', 'ກຳລັງດຳເນີນການ'),
    'grace': Tr('Grace period', 'ໄລຍະຜ່ອນຜັນ'),
    'grace_period': Tr('Grace period', 'ໄລຍະຜ່ອນຜັນ'),
    'waiting': Tr('Waiting', 'ລໍຖ້າ'),
    'draft': Tr('Draft', 'ສະບັບຮ່າງ'),
    'review': Tr('In review', 'ກຳລັງກວດສອບ'),
    'in_review': Tr('In review', 'ກຳລັງກວດສອບ'),
    'published': Tr('Published', 'ເຜີຍແຜ່ແລ້ວ'),
    'unpublished': Tr('Unpublished', 'ຍັງບໍ່ເຜີຍແຜ່'),
    'archived': Tr('Archived', 'ເກັບໄວ້'),
    'verified': Tr('Verified', 'ຢືນຢັນແລ້ວ'),
    'enabled': Tr('Enabled', 'ເປີດໃຊ້'),
    'disabled': Tr('Disabled', 'ປິດໃຊ້'),
    'confirmed': Tr('Confirmed', 'ຢືນຢັນແລ້ວ'),
    'error': Tr('Error', 'ຜິດພາດ'),
    'free': Tr('Free', 'ຟຣີ'),
    'monthly': Tr('Monthly', 'ລາຍເດືອນ'),
    'yearly': Tr('Yearly', 'ລາຍປີ'),
    'lifetime': Tr('Lifetime', 'ຕະຫຼອດຊີບ'),
    'unknown': Tr('Unknown', 'ບໍ່ຮູ້'),
  };

  /// Translated label for a backend status, or `null` when unknown.
  static Tr? lookup(String? raw) =>
      _known[(raw ?? '').trim().toLowerCase().replaceAll(
        RegExp(r'[\s-]'),
        '_',
      )];
}
