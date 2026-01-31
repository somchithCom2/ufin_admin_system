import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/payments_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  String? _statusFilter;
  String? _paymentMethodFilter;
  DateTimeRange? _dateRange;

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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(paymentsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),

          // Summary
          if (!state.isLoading && state.payments.isNotEmpty)
            _buildSummary(state),

          // Content
          Expanded(
            child: state.isLoading && state.payments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(state.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.read(paymentsProvider.notifier).refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : state.payments.isEmpty
                ? const Center(child: Text('No payments found'))
                : _buildPaymentsList(state),
          ),

          // Pagination
          if (state.totalPages > 1) _buildPagination(state),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordPaymentDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Status filter
          FilterChip(
            label: Text(_statusFilter ?? 'Status'),
            selected: _statusFilter != null,
            onSelected: (_) => _showStatusFilter(),
          ),

          // Payment method filter
          FilterChip(
            label: Text(_paymentMethodFilter ?? 'Method'),
            selected: _paymentMethodFilter != null,
            onSelected: (_) => _showPaymentMethodFilter(),
          ),

          // Date range filter
          FilterChip(
            label: Text(
              _dateRange != null
                  ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                  : 'Date Range',
            ),
            selected: _dateRange != null,
            onSelected: (_) => _showDateRangePicker(),
          ),

          // Clear filters
          if (_statusFilter != null ||
              _paymentMethodFilter != null ||
              _dateRange != null)
            ActionChip(
              label: const Text('Clear'),
              avatar: const Icon(Icons.clear, size: 16),
              onPressed: () {
                setState(() {
                  _statusFilter = null;
                  _paymentMethodFilter = null;
                  _dateRange = null;
                });
                ref.read(paymentsProvider.notifier).clearFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(PaymentsState state) {
    final totalAmount = state.payments.fold<double>(
      0,
      (sum, p) => sum + (p.status == 'completed' ? p.amount : 0),
    );
    final completedCount = state.payments
        .where((p) => p.status == 'completed')
        .length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${state.totalElements}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Total', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          Column(
            children: [
              Text(
                '$completedCount',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text('Completed', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          Column(
            children: [
              Text(
                NumberFormat.currency(
                  symbol: '₭',
                  decimalDigits: 0,
                ).format(totalAmount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text('Revenue', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(PaymentsState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: state.payments.length,
      itemBuilder: (context, index) {
        final payment = state.payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(AdminPayment payment) {
    final statusColor = _getStatusColor(payment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getPaymentMethodIcon(payment.paymentMethod),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.shopName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'MMM d, yyyy HH:mm',
                          ).format(payment.paymentDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            payment.paymentMethodDisplay,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            payment.statusDisplay,
                            style: TextStyle(fontSize: 10, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: payment.currency == 'LAK' ? '₭' : '\$',
                      decimalDigits: 0,
                    ).format(payment.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: statusColor,
                    ),
                  ),
                  if (payment.referenceNumber != null)
                    Text(
                      '#${payment.referenceNumber}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                ],
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
        color: Colors.white,
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

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All Statuses'),
            onTap: () {
              setState(() => _statusFilter = null);
              ref.read(paymentsProvider.notifier).setStatusFilter(null);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: const Text('Completed'),
            onTap: () {
              setState(() => _statusFilter = 'completed');
              ref.read(paymentsProvider.notifier).setStatusFilter('completed');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.pending, color: Colors.orange),
            title: const Text('Pending'),
            onTap: () {
              setState(() => _statusFilter = 'pending');
              ref.read(paymentsProvider.notifier).setStatusFilter('pending');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.error, color: Colors.red),
            title: const Text('Failed'),
            onTap: () {
              setState(() => _statusFilter = 'failed');
              ref.read(paymentsProvider.notifier).setStatusFilter('failed');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.undo, color: Colors.purple),
            title: const Text('Refunded'),
            onTap: () {
              setState(() => _statusFilter = 'refunded');
              ref.read(paymentsProvider.notifier).setStatusFilter('refunded');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showPaymentMethodFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('All Methods'),
            onTap: () {
              setState(() => _paymentMethodFilter = null);
              ref.read(paymentsProvider.notifier).setPaymentMethodFilter(null);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Cash'),
            onTap: () {
              setState(() => _paymentMethodFilter = 'cash');
              ref
                  .read(paymentsProvider.notifier)
                  .setPaymentMethodFilter('cash');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Bank Transfer'),
            onTap: () {
              setState(() => _paymentMethodFilter = 'bank_transfer');
              ref
                  .read(paymentsProvider.notifier)
                  .setPaymentMethodFilter('bank_transfer');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('QR Code'),
            onTap: () {
              setState(() => _paymentMethodFilter = 'qr_code');
              ref
                  .read(paymentsProvider.notifier)
                  .setPaymentMethodFilter('qr_code');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Card'),
            onTap: () {
              setState(() => _paymentMethodFilter = 'card');
              ref
                  .read(paymentsProvider.notifier)
                  .setPaymentMethodFilter('card');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      ref
          .read(paymentsProvider.notifier)
          .setDateRangeFilter(picked.start, picked.end);
    }
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
                          style: TextStyle(color: Colors.grey[600]),
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
                      style: TextStyle(color: Colors.grey[600]),
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
                          foregroundColor: Colors.red,
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
                          backgroundColor: Colors.green,
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
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
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

  void _showRecordPaymentDialog() {
    final formKey = GlobalKey<FormState>();
    final shopIdController = TextEditingController();
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    String paymentMethod = 'cash';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: shopIdController,
                    decoration: const InputDecoration(labelText: 'Shop ID'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₭ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(
                        value: 'bank_transfer',
                        child: Text('Bank Transfer'),
                      ),
                      DropdownMenuItem(
                        value: 'qr_code',
                        child: Text('QR Code'),
                      ),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                    ],
                    onChanged: (v) => setState(() => paymentMethod = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Reference (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() == true) {
                  final request = RecordPaymentRequest(
                    amount: double.parse(amountController.text),
                    paymentMethod: paymentMethod,
                    referenceNumber: referenceController.text.isNotEmpty
                        ? referenceController.text
                        : null,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  );
                  Navigator.pop(context);
                  final result = await ref
                      .read(paymentsProvider.notifier)
                      .recordPayment(int.parse(shopIdController.text), request);
                  if (result != null && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment recorded')),
                    );
                  }
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePaymentStatus(AdminPayment payment, String status) async {
    Navigator.pop(context);
    final result = await ref
        .read(paymentsProvider.notifier)
        .updatePaymentStatus(
          payment.id,
          UpdatePaymentStatusRequest(status: status),
        );
    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment marked as $status')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
