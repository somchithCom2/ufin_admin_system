import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/payments_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
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
        leading: buildAdminMenuButton(context),
        title: const Text('Payments'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
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
                  ? const AppEmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No payments found',
                      message: 'Try changing the filters.',
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
        child: const Icon(Icons.add),
      ),
    );
  }

  static const _statuses = {
    'completed': ('Completed', Icons.check_circle_outline_rounded),
    'pending': ('Pending', Icons.schedule_rounded),
    'failed': ('Failed', Icons.error_outline_rounded),
    'refunded': ('Refunded', Icons.undo_rounded),
  };

  static const _methods = {
    'cash': ('Cash', Icons.payments_outlined),
    'bank_transfer': ('Bank transfer', Icons.account_balance_outlined),
    'qr_code': ('QR code', Icons.qr_code_2_rounded),
    'card': ('Card', Icons.credit_card_rounded),
  };

  /// Date presets, each resolving to an inclusive (start, end) day range.
  static List<(String, DateTimeRange Function(DateTime today))>
  get _datePresets => [
    ('Today', (t) => DateTimeRange(start: t, end: t)),
    (
      'Last 7 days',
      (t) => DateTimeRange(start: t.subtract(const Duration(days: 6)), end: t),
    ),
    (
      'This month',
      (t) => DateTimeRange(start: DateTime(t.year, t.month), end: t),
    ),
    (
      'Last month',
      (t) => DateTimeRange(
        start: DateTime(t.year, t.month - 1),
        end: DateTime(t.year, t.month, 0),
      ),
    ),
  ];

  String? _dateLabelFor(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    for (final (label, range) in _datePresets) {
      final r = range(today);
      if (DateUtils.isSameDay(r.start, start) &&
          DateUtils.isSameDay(r.end, end)) {
        return label;
      }
    }
    final sameYear = start.year == end.year && start.year == today.year;
    final f = DateFormat(sameYear ? 'd MMM' : 'd MMM y');
    return DateUtils.isSameDay(start, end)
        ? f.format(start)
        : '${f.format(start)} – ${f.format(end)}';
  }

  /// Active filters move to the front so they're never scrolled out of view.
  static List<Widget> _activeFirst(List<Widget> chips) {
    bool isActive(Widget w) =>
        (w is _FilterButton && w.value != null) ||
        (w is _FilterMenu && w.value != null);
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

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // Phones drop the chip icons so all four filters fit on screen.
          final compact = c.maxWidth < 600;
          return Row(
            children: [
              Expanded(
                // Fade the right edge so overflowing chips read as scrollable.
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [Colors.black, Colors.black, Colors.transparent],
                    stops: [0, 0.92, 1],
                  ).createShader(rect),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Row(
                      children: _activeFirst([
                        _FilterButton(
                          key: const ValueKey('shop'),
                          compact: compact,
                          icon: Icons.storefront_outlined,
                          label: 'Shop',
                          value: state.shopIdFilter == null
                              ? null
                              : (_shopFilter?.name ??
                                    'Shop #${state.shopIdFilter}'),
                          onTap: _pickShop,
                          onClear: () {
                            setState(() => _shopFilter = null);
                            notifier.setShopFilter(null);
                          },
                        ),
                        _FilterMenu(
                          key: const ValueKey('status'),
                          compact: compact,
                          icon: Icons.flag_outlined,
                          label: 'Status',
                          value:
                              _statuses[state.statusFilter]?.$1 ??
                              state.statusFilter,
                          options: [
                            for (final e in _statuses.entries)
                              (
                                e.value.$1,
                                e.value.$2,
                                e.key == state.statusFilter,
                                () => notifier.setStatusFilter(e.key),
                              ),
                          ],
                          onClear: () => notifier.setStatusFilter(null),
                        ),
                        _FilterMenu(
                          key: const ValueKey('method'),
                          compact: compact,
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Method',
                          value:
                              _methods[state.paymentMethodFilter]?.$1 ??
                              state.paymentMethodFilter,
                          options: [
                            for (final e in _methods.entries)
                              (
                                e.value.$1,
                                e.value.$2,
                                e.key == state.paymentMethodFilter,
                                () => notifier.setPaymentMethodFilter(e.key),
                              ),
                          ],
                          onClear: () => notifier.setPaymentMethodFilter(null),
                        ),
                        _FilterMenu(
                          key: const ValueKey('date'),
                          compact: compact,
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: dateLabel,
                          options: [
                            for (final (label, range) in _datePresets)
                              (
                                label,
                                Icons.event_outlined,
                                label == dateLabel,
                                () {
                                  final r = range(today);
                                  notifier.setDateRangeFilter(r.start, r.end);
                                },
                              ),
                            (
                              'Custom range…',
                              Icons.date_range_outlined,
                              false,
                              () => _pickCustomRange(state),
                            ),
                          ],
                          onClear: () =>
                              notifier.setDateRangeFilter(null, null),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              // Pinned so it stays reachable however far the chips scroll.
              if (activeCount >= 2)
                IconButton(
                  tooltip: 'Clear all filters',
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 20),
                  onPressed: _clearAll,
                ),
            ],
          );
        },
      ),
    );
  }

  /// One-line totals shown as the list header; scrolls away with the list.
  Widget _buildSummary(PaymentsState state) {
    final completed = state.payments.where((p) => p.status == 'completed');
    final revenue = completed.fold<double>(0, (sum, p) => sum + p.amount);
    final muted = context.colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
      child: Row(
        children: [
          Expanded(
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
                    text: state.totalElements == 1 ? ' payment' : ' payments',
                  ),
                  if (state.totalPages > 1)
                    TextSpan(
                      text:
                          ' · page ${state.currentPage + 1}/${state.totalPages}',
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
              message: 'Completed on this page (${completed.length})',
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  NumberFormat.currency(
                    symbol: '₭ ',
                    decimalDigits: 0,
                  ).format(revenue),
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 88),
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
    final amount = NumberFormat.currency(
      symbol: payment.currency == 'LAK' ? '₭ ' : '\$',
      decimalDigits: 0,
    ).format(payment.amount);

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
                color: statusColor,
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
                        DateFormat(
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
                            label: 'Funds next renewal',
                            color: context.status.info,
                          )
                        else if (payment.appliedAt != null)
                          _Pill(
                            label: payment.billingPeriodEnd != null
                                ? 'Applied → ${DateFormat('d MMM y').format(payment.billingPeriodEnd!)}'
                                : 'Applied',
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: state.currentPage > 0
                ? () => ref.read(paymentsProvider.notifier).loadPreviousPage()
                : null,
          ),
          Text(
            'Page ${state.currentPage + 1} of ${state.totalPages}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
                    child: Icon(
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
                          'Payment #${payment.id}',
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
                      NumberFormat.currency(
                        symbol: payment.currency == 'LAK' ? '₭' : '\$',
                        decimalDigits: 0,
                      ).format(payment.amount),
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
                'Payment Date',
                DateFormat('MMM d, yyyy HH:mm').format(payment.paymentDate),
              ),
              if (payment.transactionId != null)
                _buildDetailRow('Transaction ID', payment.transactionId!),
              if (payment.referenceNumber != null)
                _buildDetailRow('Reference', payment.referenceNumber!),
              if (payment.description != null)
                _buildDetailRow('Description', payment.description!),
              if (payment.notes != null)
                _buildDetailRow('Notes', payment.notes!),
              if (payment.processedBy != null)
                _buildDetailRow('Processed By', payment.processedBy!),
              _buildDetailRow(
                'Created',
                DateFormat('MMM d, yyyy HH:mm').format(payment.createdAt),
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
                        child: const Text('Mark Failed'),
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
                        child: const Text('Mark Completed'),
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
        'Payment #${payment.id} marked as ${humanize(status).toLowerCase()}',
      );
    } catch (e) {
      messenger.showError(
        'Could not update payment #${payment.id}: ${friendlyError(e)}',
      );
    }
  }

  Color _getStatusColor(String status) {
    return StatusTone.fromStatus(status).foreground(context);
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      case 'qr_code':
        return Icons.qr_code;
      case 'card':
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.payment;
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
      helpText: 'Date payment was received',
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
          'Payment recorded for "${_shop!.name}", but the server dated it '
          '${_dateLabel(savedDay)} instead of ${_dateLabel(_paymentDate)}. '
          'The backend needs updating to accept past dates.',
        );
      } else {
        messenger.showSuccess(
          'Payment recorded for "${_shop!.name}" on ${_dateLabel(_paymentDate)}',
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
      icon: Icons.payments_outlined,
      title: 'Record payment',
      subtitle: 'Log money received from a shop',
      submitLabel: 'Save payment',
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormSection(
          title: 'Payment',
          children: [
            ShopPickerField(
              enabled: !_saving,
              onChanged: (shop) => _shop = shop,
            ),
            FormRow(
              children: [
                TextFormField(
                  controller: _amount,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
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
                        ? 'Enter a positive amount with at most 2 decimals'
                        : null;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Method'),
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
                  labelText: 'Payment date',
                  prefixIcon: const Icon(Icons.event_outlined, size: 20),
                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                  helperText: backdated ? 'Back-dated record' : null,
                ),
                child: Text(_dateLabel(_paymentDate)),
              ),
            ),
          ],
        ),
        FormSection(
          title: 'Reference',
          hint: 'Optional. Helps match this payment to a bank statement.',
          children: [
            TextFormField(
              controller: _reference,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Transaction reference',
              ),
            ),
            TextFormField(
              controller: _notes,
              maxLength: 4000,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes',
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
    ? 'Today, ${DateFormat('d MMM y').format(d)}'
    : DateFormat('EEE, d MMM y').format(d);

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

/// Filter chip: shows the label, or the active value with a clear button.
class _FilterButton extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterButton({
    super.key,
    this.compact = false,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final active = value != null;
    final fg = active ? scheme.primary : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: active ? scheme.primary.withValues(alpha: 0.10) : scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: active
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: active ? 4 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact) ...[
                  Icon(
                    icon,
                    size: 16,
                    color: active ? fg : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    value ?? label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
                if (active)
                  IconButton(
                    tooltip: 'Clear $label filter',
                    visualDensity: VisualDensity.compact,
                    iconSize: 16,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close_rounded, color: fg),
                    onPressed: onClear,
                  )
                else ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// [_FilterButton] that opens a dropdown menu of options anchored to it.
class _FilterMenu extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final String? value;
  final List<(String, IconData, bool, VoidCallback)> options;
  final VoidCallback onClear;

  const _FilterMenu({
    super.key,
    this.compact = false,
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      menuChildren: [
        for (final (text, optionIcon, selected, onSelect) in options)
          MenuItemButton(
            leadingIcon: Icon(optionIcon, size: 18),
            trailingIcon: selected
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: context.colors.primary,
                  )
                : null,
            onPressed: onSelect,
            child: Text(text),
          ),
      ],
      builder: (context, controller, _) => _FilterButton(
        compact: compact,
        icon: icon,
        label: label,
        value: value,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        onClear: onClear,
      ),
    );
  }
}
