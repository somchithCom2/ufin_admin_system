import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/daily_sales_provider.dart';

class DailySalesPage extends ConsumerStatefulWidget {
  const DailySalesPage({super.key});

  @override
  ConsumerState<DailySalesPage> createState() => _DailySalesPageState();
}

class _DailySalesPageState extends ConsumerState<DailySalesPage> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    startDate = today;
    endDate = today;

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

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
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
                            color: Colors.grey[300],
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
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
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
                                startDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
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
                                endDate = picked;
                              });
                            }
                          },
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
    final formatter = DateFormat('dd/MM/yyyy');

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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(dailySalesProvider.notifier)
                .loadDailySales(startDate: startDate, endDate: endDate),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active Filter Info
          if (state.data != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${formatter.format(startDate)} - ${formatter.format(endDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          // Sales Data
          Expanded(
            child: state.isLoading
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
                ? const Center(child: Text('No data available'))
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
                              const SizedBox(height: 12),
                              // Second Row: 1 or 2 columns
                              Row(
                                children: [
                                  Expanded(
                                    child: _SummaryStatItem(
                                      title: 'Net Income',
                                      value: _formatCurrency(
                                        state.data!.totalNetIncome,
                                      ),
                                      icon: Icons.attach_money,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Shop List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.data!.shopSales.length,
                          itemBuilder: (context, index) {
                            final shop = state.data!.shopSales[index];
                            return _ShopSalesCard(shop: shop);
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
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
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
  final dynamic shop;

  const _ShopSalesCard({required this.shop});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

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
        border: Border.all(color: Colors.grey[300]!),
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
                    'ID: ${shop.shopId}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                _formatCurrency(shop.totalNetIncome),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
