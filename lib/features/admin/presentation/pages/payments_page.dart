import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/payments_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_picker.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  /// Only for the chip label; the filter itself lives in the provider.
  ShopSelection? _shopFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentsProvider.notifier).loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(NavText.payments)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const AppIcon(AppIcons.refresh),
            onPressed: () => ref.read(paymentsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Filters
            _buildFilters(),

            // Content
            Expanded(
              child: state.isLoading && state.payments.isEmpty
                  ? const AppLoadingView()
                  : state.error != null && state.payments.isEmpty
                  ? AppErrorView(
                      error: state.error,
                      onRetry: () =>
                          ref.read(paymentsProvider.notifier).refresh(),
                    )
                  : state.payments.isEmpty
                  ? AppEmptyView(
                      icon: AppIcons.receipt,
                      title: context.tr(FinText.noPaymentsFound),
                      message: context.tr(FinText.tryChangingTheFilters),
                    )
                  : _buildPaymentsList(state),
            ),

            // Pagination
            if (state.totalPages > 1) _buildPagination(state),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordPaymentDialog(),
        child: const AppIcon(AppIcons.add),
      ),
    );
  }

  static const _statuses = {
    'completed': (Tr('Completed', 'ສຳເລັດ'), AppIcons.checkCircle),
    'pending': (Tr('Pending', 'ລໍຖ້າ'), AppIcons.clock),
    'failed': (Tr('Failed', 'ລົ້ມເຫຼວ'), AppIcons.errorCircle),
    'refunded': (Tr('Refunded', 'ຄືນເງິນແລ້ວ'), AppIcons.undo),
  };

  static const _methods = {
    'cash': (Tr('Cash', 'ເງິນສົດ'), AppIcons.money),
    'bank_transfer': (Tr('Bank transfer', 'ໂອນຜ່ານທະນາຄານ'), AppIcons.bank),
    'qr_code': (Tr('QR code', 'ຄິວອາໂຄດ'), AppIcons.qrCode),
    'card': (Tr('Card', 'ບັດ'), AppIcons.card),
  };

  /// Date presets, each resolving to an inclusive (start, end) day range.
  static List<(Tr, DateTimeRange Function(DateTime today))> get _datePresets =>
      [
        (CommonText.today, (t) => DateTimeRange(start: t, end: t)),
        (
          const Tr('Last 7 days', '7 ມື້ຜ່ານມາ'),
          (t) =>
              DateTimeRange(start: t.subtract(const Duration(days: 6)), end: t),
        ),
        (
          CommonText.thisMonth,
          (t) => DateTimeRange(start: DateTime(t.year, t.month), end: t),
        ),
        (
          const Tr('Last month', 'ເດືອນແລ້ວ'),
          (t) => DateTimeRange(
            start: DateTime(t.year, t.month - 1),
            end: DateTime(t.year, t.month, 0),
          ),
        ),
      ];

  String? _trOrNull(Tr? t) => t == null ? null : context.tr(t);

  String? _dateLabelFor(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    for (final (label, range) in _datePresets) {
      final r = range(today);
      if (DateUtils.isSameDay(r.start, start) &&
          DateUtils.isSameDay(r.end, end)) {
        return context.tr(label);
      }
    }
    final sameYear = start.year == end.year && start.year == today.year;
    final f = DateFormat(sameYear ? 'd MMM' : 'd MMM y', context.localeName);
    return DateUtils.isSameDay(start, end)
        ? f.format(start)
        : '${f.format(start)} – ${f.format(end)}';
  }

  /// Active filters move to the front so they're never scrolled out of view.
  static List<Widget> _activeFirst(List<Widget> chips) {
    bool isActive(Widget w) =>
        (w is FilterButton && w.value != null) ||
        (w is FilterMenu && w.value != null);
    return [...chips.where(isActive), ...chips.where((w) => !isActive(w))];
  }

  Future<void> _pickShop() async {
    final picked = await showShopPicker(context, selected: _shopFilter);
    if (picked == null || !mounted) return;
    setState(() => _shopFilter = picked);
    ref.read(paymentsProvider.notifier).setShopFilter(picked.id);
  }

  Future<void> _pickCustomRange(PaymentsState state) async {
    final start = state.startDateFilter;
    final end = state.endDateFilter;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: start != null && end != null
          ? DateTimeRange(start: start, end: end)
          : null,
    );
    if (picked != null && mounted) {
      ref
          .read(paymentsProvider.notifier)
          .setDateRangeFilter(picked.start, picked.end);
    }
  }

  void _clearAll() {
    setState(() => _shopFilter = null);
    ref.read(paymentsProvider.notifier).clearFilters();
  }

  Widget _buildFilters() {
    final state = ref.watch(paymentsProvider);
    final notifier = ref.read(paymentsProvider.notifier);
    final today = DateUtils.dateOnly(DateTime.now());
    final dateLabel = _dateLabelFor(state.startDateFilter, state.endDateFilter);
    final activeCount = [
      state.shopIdFilter,
      state.statusFilter,
      state.paymentMethodFilter,
      state.startDateFilter,
    ].where((f) => f != null).length;

    return FilterBar(
      filters: _activeFirst([
        FilterButton(
          key: const ValueKey('shop'),
          icon: AppIcons.shop,
          label: context.tr(CommonText.shop),
          value: state.shopIdFilter == null
              ? null
              : (_shopFilter?.name ??
                    context.tr(FinText.shop(state.shopIdFilter))),
          onTap: _pickShop,
          onClear: () {
            setState(() => _shopFilter = null);
            notifier.setShopFilter(null);
          },
        ),
        FilterMenu(
          key: const ValueKey('status'),
          icon: AppIcons.flag,
          label: context.tr(CommonText.status),
          value:
              _trOrNull(_statuses[state.statusFilter]?.$1) ??
              state.statusFilter,
          entries: [
            for (final e in _statuses.entries)
              FilterMenuEntry(
                label: context.tr(e.value.$1),
                icon: e.value.$2,
                selected: e.key == state.statusFilter,
                onSelected: () => notifier.setStatusFilter(e.key),
              ),
          ],
          onClear: () => notifier.setStatusFilter(null),
        ),
        FilterMenu(
          key: const ValueKey('method'),
          icon: AppIcons.wallet,
          label: context.tr(FinText.method),
          value:
              _trOrNull(_methods[state.paymentMethodFilter]?.$1) ??
              state.paymentMethodFilter,
          entries: [
            for (final e in _methods.entries)
              FilterMenuEntry(
                label: context.tr(e.value.$1),
                icon: e.value.$2,
                selected: e.key == state.paymentMethodFilter,
                onSelected: () => notifier.setPaymentMethodFilter(e.key),
              ),
          ],
          onClear: () => notifier.setPaymentMethodFilter(null),
        ),
        FilterMenu(
          key: const ValueKey('date'),
          icon: AppIcons.calendar,
          label: context.tr(CommonText.date),
          value: dateLabel,
          entries: [
            for (final (label, range) in _datePresets)
              FilterMenuEntry(
                label: context.tr(label),
                icon: AppIcons.calendar,
                selected: context.tr(label) == dateLabel,
                onSelected: () {
                  final r = range(today);
                  notifier.setDateRangeFilter(r.start, r.end);
                },
              ),
            FilterMenuEntry(
              label: context.tr(FinText.customRange),
              icon: AppIcons.calendarRange,
              selected: false,
              onSelected: () => _pickCustomRange(state),
            ),
          ],
          onClear: () => notifier.setDateRangeFilter(null, null),
        ),
      ]),
      // Pinned so it stays reachable however far the chips scroll.
      onClearAll: activeCount >= 2 ? _clearAll : null,
    );
  }

  /// One-line totals shown as the list header; scrolls away with the list.
  Widget _buildSummary(PaymentsState state) {
    final completed = state.payments.where((p) => p.status == 'completed');
    // Per currency: kip and baht payments are never added together.
    final revenue = <String, double>{};
    for (final p in completed) {
      revenue.update(p.currency, (v) => v + p.amount, ifAbsent: () => p.amount);
    }
    final revenueText = revenue.isEmpty
        ? MoneyFormat.format(0, 'LAK')
        : MoneyFormat.ordered(
            revenue.keys,
          ).map((c) => MoneyFormat.format(revenue[c]!, c)).join(' · ');
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
      // Both sides flexible + spaceBetween: the total sits flush right instead
      // of at the start of its half of the row.
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: NumberFormat.decimalPattern().format(
                      state.totalElements,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: state.totalElements == 1
                        ? context.tr(FinText.payment)
                        : context.tr(FinText.payments),
                  ),
                  if (state.totalPages > 1)
                    TextSpan(
                      text: context.tr(
                        FinText.page(state.currentPage + 1, state.totalPages),
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Tooltip(
              message: context.tr(
                FinText.completedOnThisPage(completed.length),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  revenueText,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: context.status.success,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(PaymentsState state) {
    return RefreshIndicator(
      onRefresh: () async => ref.read(paymentsProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // Bottom space keeps the last card clear of the "+" button.
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        itemCount: state.payments.length + 1,
        itemBuilder: (context, index) => index == 0
            ? _buildSummary(state)
            : _buildPaymentCard(state.payments[index - 1]),
      ),
    );
  }

  Widget _buildPaymentCard(AdminPayment payment) {
    final statusColor = _getStatusColor(payment.status);
    final muted = context.colors.onSurfaceVariant;
    final amount = MoneyFormat.format(payment.amount, payment.currency);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(
                icon: _getPaymentMethodIcon(payment.paymentMethod),
                color: muted,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and amount share one line; the name truncates
                    // first so the amount is always readable.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            payment.shopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              amount,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        AppDateFormat.of(
                          'd MMM y, HH:mm',
                        ).format(payment.paymentDate),
                        if (payment.referenceNumber != null)
                          '#${payment.referenceNumber}',
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 8),
                    // Pills wrap onto a second line on narrow screens.
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusBadge.fromStatus(payment.status),
                        _Pill(
                          label: payment.paymentMethodDisplay,
                          color: muted,
                        ),
                        // Whether this money has been spent on a period yet: a
                        // completed payment funds exactly one auto-renewal, so
                        // "unapplied" is what will carry the shop forward next.
                        if (payment.isAvailableForRenewal)
                          _Pill(
                            label: context.tr(FinText.fundsNextRenewal),
                            color: context.status.info,
                          )
                        else if (payment.appliedAt != null)
                          _Pill(
                            label: payment.billingPeriodEnd != null
                                ? context.tr(
                                    FinText.applied(
                                      AppDateFormat.of(
                                        'd MMM y',
                                      ).format(payment.billingPeriodEnd!),
                                    ),
                                  )
                                : context.tr(FinText.applied2),
                            color: muted,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination(PaymentsState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: context.tr(FinText.previousPage),
            icon: const AppIcon(AppIcons.chevronLeft),
            onPressed: state.currentPage > 0
                ? () => ref.read(paymentsProvider.notifier).loadPreviousPage()
                : null,
          ),
          Text(
            context.tr(FinText.pageOf(state.currentPage + 1, state.totalPages)),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          IconButton(
            tooltip: context.tr(FinText.nextPage),
            icon: const AppIcon(AppIcons.chevronRight),
            onPressed: state.currentPage < state.totalPages - 1
                ? () => ref.read(paymentsProvider.notifier).loadNextPage()
                : null,
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(AdminPayment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        payment.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      _getPaymentMethodIcon(payment.paymentMethod),
                      color: _getStatusColor(payment.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.shopName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.tr(FinText.payment2(payment.id)),
                          style: TextStyle(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        payment.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      payment.statusDisplay,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(payment.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Amount
              Center(
                child: Column(
                  children: [
                    Text(
                      MoneyFormat.format(payment.amount, payment.currency),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(payment.status),
                      ),
                    ),
                    Text(
                      payment.paymentMethodDisplay,
                      style: TextStyle(color: context.colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow(
                context.tr(FinText.paymentDate),
                AppDateFormat.of(
                  'MMM d, yyyy HH:mm',
                ).format(payment.paymentDate),
              ),
              if (payment.transactionId != null)
                _buildDetailRow(
                  context.tr(FinText.transactionId),
                  payment.transactionId!,
                ),
              if (payment.referenceNumber != null)
                _buildDetailRow(
                  context.tr(FinText.reference),
                  payment.referenceNumber!,
                ),
              if (payment.description != null)
                _buildDetailRow(
                  context.tr(CommonText.description),
                  payment.description!,
                ),
              if (payment.notes != null)
                _buildDetailRow(context.tr(CommonText.notes), payment.notes!),
              if (payment.processedBy != null)
                _buildDetailRow(
                  context.tr(FinText.processedBy),
                  payment.processedBy!,
                ),
              _buildDetailRow(
                context.tr(CommonText.created),
                AppDateFormat.of('MMM d, yyyy HH:mm').format(payment.createdAt),
              ),

              const SizedBox(height: 24),

              // Actions
              if (payment.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updatePaymentStatus(payment, 'failed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.error,
                        ),
                        child: Text(context.tr(FinText.markFailed)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _updatePaymentStatus(payment, 'completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.status.success,
                        ),
                        child: Text(context.tr(FinText.markCompleted)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: context.colors.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordPaymentDialog() {
    // The dialog owns its controllers, so they're disposed only after the
    // route (including its close animation) is gone.
    return showAppFormModal<void>(
      context,
      builder: (_) => const _RecordPaymentDialog(),
    );
  }

  Future<void> _updatePaymentStatus(AdminPayment payment, String status) async {
    Navigator.pop(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(paymentsProvider.notifier)
          .updatePaymentStatus(
            payment.id,
            UpdatePaymentStatusRequest(status: status),
          );
      messenger.showSuccess(
        FinText.paymentMarkedAs(
          payment.id,
          humanize(status).toLowerCase(),
        ).current,
      );
    } catch (e) {
      messenger.showError(
        FinText.couldNotUpdatePayment(payment.id, friendlyError(e)).current,
      );
    }
  }

  Color _getStatusColor(String status) {
    return StatusTone.fromStatus(status).foreground(context);
  }

  AppIconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppIcons.money;
      case 'bank_transfer':
        return AppIcons.bank;
      case 'qr_code':
        return AppIcons.qrCode;
      case 'card':
      case 'credit_card':
        return AppIcons.card;
      default:
        return AppIcons.card;
    }
  }
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  const _RecordPaymentDialog();

  @override
  ConsumerState<_RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  ShopSelection? _shop;
  String _paymentMethod = 'cash';
  DateTime _paymentDate = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      // Payments can't be received in the future.
      lastDate: today,
      helpText: context.tr(FinText.datePaymentWasReceived),
    );
    if (picked != null && mounted) setState(() => _paymentDate = picked);
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final reference = _reference.text.trim();
    final notes = _notes.text.trim();
    final request = RecordPaymentRequest(
      amount: double.parse(_amount.text.trim()),
      paymentDate: _paymentDate,
      paymentMethod: _paymentMethod,
      transactionId: reference.isEmpty ? null : reference,
      notes: notes.isEmpty ? null : notes,
    );
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await ref
          .read(paymentsProvider.notifier)
          .recordPayment(_shop!.id, request);
      navigator.pop();
      final savedDay = DateUtils.dateOnly(saved.paymentDate.toLocal());
      final backdated = _paymentDate.isBefore(
        DateUtils.dateOnly(DateTime.now()),
      );
      // Only back-dated records are checked: for "today" the server stamps its
      // own clock (UTC), which can legitimately fall on the previous day.
      if (backdated && !DateUtils.isSameDay(savedDay, _paymentDate)) {
        // The server ignored the requested date (an older backend without
        // back-dating support). Say so instead of silently storing it wrong.
        messenger.showWarning(
          FinText.paymentRecordedForButThe(
            _shop!.name,
            _dateLabel(savedDay),
            _dateLabel(_paymentDate),
          ).current,
        );
      } else {
        messenger.showSuccess(
          FinText.paymentRecordedForOn(
            _shop!.name,
            _dateLabel(_paymentDate),
          ).current,
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Keep the dialog open so the admin can fix the input.
      setState(() {
        _saving = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backdated = !DateUtils.isSameDay(_paymentDate, DateTime.now());
    return AppFormModal(
      formKey: _formKey,
      icon: AppIcons.money,
      title: context.tr(FinText.recordPayment),
      subtitle: context.tr(FinText.logMoneyReceivedFromA),
      submitLabel: context.tr(FinText.savePayment),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: context.tr(FinText.payment3),
          children: [
            ShopPickerField(
              enabled: !_saving,
              onChanged: (shop) => _shop = shop,
            ),
            FormRow(
              children: [
                TextFormField(
                  controller: _amount,
                  decoration: InputDecoration(
                    labelText: context.tr(CommonText.amount),
                    prefixText: '₭ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    final amount = double.tryParse(text);
                    return amount == null ||
                            !amount.isFinite ||
                            amount <= 0 ||
                            amount >= 10000000000000 ||
                            !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)
                        ? context.tr(FinText.enterAPositiveAmountWith)
                        : null;
                  },
                ),
                DropdownButtonFormField<String>(
                  icon: const AppIcon(AppIcons.chevronDown, size: 20),
                  initialValue: _paymentMethod,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.tr(FinText.method),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(
                      value: 'bank_transfer',
                      child: Text('Bank transfer'),
                    ),
                    DropdownMenuItem(value: 'qr_code', child: Text('QR code')),
                    DropdownMenuItem(value: 'card', child: Text('Card')),
                  ],
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
              ],
            ),
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              onTap: _saving ? null : _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: context.tr(FinText.paymentDate2),
                  prefixIcon: const AppIcon(AppIcons.calendar, size: 20),
                  suffixIcon: const AppIcon(AppIcons.chevronDown),
                  helperText: backdated
                      ? context.tr(FinText.backDatedRecord)
                      : null,
                ),
                child: Text(_dateLabel(_paymentDate)),
              ),
            ),
          ],
        ),
        FormSection(
          title: context.tr(FinText.reference),
          hint: context.tr(FinText.optionalHelpsMatchThisPayment),
          children: [
            TextFormField(
              controller: _reference,
              maxLength: 255,
              decoration: InputDecoration(
                labelText: context.tr(FinText.transactionReference),
              ),
            ),
            TextFormField(
              controller: _notes,
              maxLength: 4000,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr(CommonText.notes),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _dateLabel(DateTime d) => DateUtils.isSameDay(d, DateTime.now())
    ? FinText.today(AppDateFormat.of('d MMM y').format(d)).current
    : AppDateFormat.of('EEE, d MMM y').format(d);

/// Small neutral label used for secondary payment facts.
class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}
