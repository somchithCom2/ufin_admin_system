import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/daily_sales_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class DailySalesPage extends ConsumerStatefulWidget {
  const DailySalesPage({super.key});

  @override
  ConsumerState<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends ConsumerState<DailySalesPage> {
  /// Platform (Laos) wall-clock times; 00:00 to 23:59 is the whole day.
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    startDate = DateTime(today.year, today.month, today.day);
    endDate = DateTime(today.year, today.month, today.day, 23, 59);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(dailySalesProvider.notifier)
          .loadDailySales(startDate: startDate, endDate: endDate);
    });
  }

  String _formatNumber(int number) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  /// The period on screen: its days, and its times when they narrow them.
  String _periodLabel() {
    final wholeDays =
        startDate.hour == 0 &&
        startDate.minute == 0 &&
        endDate.hour == 23 &&
        endDate.minute == 59;
    final format = DateFormat(wholeDays ? 'dd/MM/yyyy' : 'dd/MM/yyyy HH:mm');
    return '${format.format(startDate)} - ${format.format(endDate)}';
  }

  /// [time] on [day]'s date: a date picked keeps the time already set.
  static DateTime _at(DateTime day, TimeOfDay time) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);

  Widget _timeTile(
    BuildContext context,
    String title,
    DateTime value,
    ValueChanged<TimeOfDay> onPicked,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(DateFormat('HH:mm').format(value)),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value),
        );
        if (picked != null) onPicked(picked);
      },
    );
  }

  /// Net income per currency; a zero LAK line when there were no sales.
  Map<String, double> _netIncome(DailySalesData data) {
    final byCurrency = data.netIncomeByCurrency;
    return byCurrency.isEmpty ? const {'LAK': 0.0} : byCurrency;
  }

  void _showFilterModal() {
    final formatter = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.colors.outline,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Filter Daily Sales',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      // Date Pickers
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('Start Date'),
                              subtitle: Text(formatter.format(startDate)),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime(2020),
                                  lastDate: endDate,
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    startDate = _at(
                                      picked,
                                      TimeOfDay.fromDateTime(startDate),
                                    );
                                  });
                                }
                              },
                            ),
                            _timeTile(
                              context,
                              'Start Time',
                              startDate,
                              (time) => setModalState(
                                () => startDate = _at(startDate, time),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.colors.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: const Text('End Date'),
                              subtitle: Text(formatter.format(endDate)),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    endDate = _at(
                                      picked,
                                      TimeOfDay.fromDateTime(endDate),
                                    );
                                  });
                                }
                              },
                            ),
                            _timeTile(
                              context,
                              'End Time',
                              endDate,
                              (time) => setModalState(
                                () => endDate = _at(endDate, time),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (endDate.isBefore(startDate)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'End must not be before start',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                ref
                                    .read(dailySalesProvider.notifier)
                                    .loadDailySales(
                                      startDate: startDate,
                                      endDate: endDate,
                                    );
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('Search'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailySalesProvider);
    final shops = state.data?.shopSalesInOrder ?? const <ShopSalesData>[];

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Daily Sales Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter',
            onPressed: _showFilterModal,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(dailySalesProvider.notifier)
                .loadDailySales(startDate: startDate, endDate: endDate),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Active Filter Info
            if (state.data != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: context.status.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _periodLabel(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            // Sales Data
            Expanded(
              child: state.isLoading
                  ? const AppLoadingView()
                  : state.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: 48,
                            color: context.colors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(state.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(dailySalesProvider.notifier)
                                .loadDailySales(
                                  startDate: startDate,
                                  endDate: endDate,
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : state.data == null
                  ? const AppEmptyView(
                      icon: Icons.insights_outlined,
                      title: 'No data available',
                      message: 'There is nothing to show for this period.',
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Summary Stats
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // First Row: 2 columns
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryStatItem(
                                        title: 'Total Shops',
                                        value: _formatNumber(
                                          state.data!.totalShopsWithSales,
                                        ),
                                        icon: Icons.store,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _SummaryStatItem(
                                        title: 'Total Orders',
                                        value: _formatNumber(
                                          state.data!.totalOrders,
                                        ),
                                        icon: Icons.receipt,
                                      ),
                                    ),
                                  ],
                                ),
                                // Net income per currency: kip and baht
                                // are never added together.
                                for (final entry in _netIncome(
                                  state.data!,
                                ).entries) ...[
                                  const SizedBox(height: 12),
                                  _SummaryStatItem(
                                    title: 'Net Income (${entry.key})',
                                    value: MoneyFormat.format(
                                      entry.value,
                                      entry.key,
                                    ),
                                    icon: Icons.attach_money,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Shop List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: shops.length,
                            itemBuilder: (context, index) {
                              final shop = shops[index];
                              return _ShopSalesCard(shop: shop);
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryStatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: context.status.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopSalesCard extends StatelessWidget {
  final ShopSalesData shop;

  const _ShopSalesCard({required this.shop});

  String _formatCurrency(double amount) =>
      MoneyFormat.format(amount, shop.currency);

  String _formatNumber(int number) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // A shop that sold in two currencies has a card for each.
                    'ID: ${shop.shopId} · ${shop.currency}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.status.neutral,
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(shop.totalNetIncome),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.status.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricItem(
                label: 'Orders',
                value: _formatNumber(shop.totalOrders),
              ),
              _MetricItem(
                label: 'Items Sold',
                value: _formatNumber(shop.itemsSold),
              ),
              _MetricItem(
                label: 'Avg Order',
                value: _formatCurrency(shop.averageOrderValue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: context.status.neutral),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
