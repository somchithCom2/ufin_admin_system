import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/providers/auth_provider.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final authState = ref.watch(authStateProvider);
    final currencyFormat = NumberFormat.currency(
      symbol: '₭ ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                authState.username?.substring(0, 1).toUpperCase() ?? 'A',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authStateProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.username ?? 'Admin',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      authState.role ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
          ? _buildErrorView(dashboardState.error!)
          : dashboardState.stats == null
          ? const Center(child: Text('No data available'))
          : _buildDashboard(dashboardState.stats!, currencyFormat),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    AdminDashboardStats stats,
    NumberFormat currencyFormat,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardProvider.notifier).loadDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s what\'s happening with your platform today.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Quick Stats Row
            _buildSectionTitle('Overview'),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Shops',
                  stats.totalShops.toString(),
                  Icons.storefront,
                  Colors.blue,
                  subtitle: '${stats.activeShops} active',
                ),
                _buildStatCard(
                  'Total Users',
                  stats.totalUsers.toString(),
                  Icons.people,
                  Colors.green,
                  subtitle: '${stats.activeUsers} active',
                ),
                _buildStatCard(
                  'Subscriptions',
                  stats.totalSubscriptions.toString(),
                  Icons.card_membership,
                  Colors.orange,
                  subtitle: '${stats.activeSubscriptions} active',
                ),
                _buildStatCard(
                  'Expiring Soon',
                  stats.expiringSoon.toString(),
                  Icons.warning_amber,
                  Colors.red,
                  subtitle: 'Within 7 days',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Shop Stats
            _buildSectionTitle('Shop Statistics'),
            const SizedBox(height: 12),
            _buildInfoCard(
              children: [
                _buildInfoRow('New Today', stats.newShopsToday.toString()),
                _buildInfoRow(
                  'New This Week',
                  stats.newShopsThisWeek.toString(),
                ),
                _buildInfoRow(
                  'New This Month',
                  stats.newShopsThisMonth.toString(),
                ),
                const Divider(),
                _buildInfoRow(
                  'Active Shops',
                  stats.activeShops.toString(),
                  color: Colors.green,
                ),
                _buildInfoRow(
                  'Suspended Shops',
                  stats.suspendedShops.toString(),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Subscription Stats
            _buildSectionTitle('Subscription Overview'),
            const SizedBox(height: 12),
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  'Active',
                  stats.activeSubscriptions.toString(),
                  color: Colors.green,
                ),
                _buildInfoRow(
                  'Trial',
                  stats.trialSubscriptions.toString(),
                  color: Colors.blue,
                ),
                _buildInfoRow(
                  'Expired',
                  stats.expiredSubscriptions.toString(),
                  color: Colors.grey,
                ),
                _buildInfoRow(
                  'Expiring Soon',
                  stats.expiringSoon.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue Stats
            _buildSectionTitle('Revenue'),
            const SizedBox(height: 12),
            _buildInfoCard(
              children: [
                _buildInfoRow(
                  'This Month',
                  currencyFormat.format(stats.totalRevenueThisMonth),
                  color: Colors.green,
                ),
                _buildInfoRow(
                  'This Year',
                  currencyFormat.format(stats.totalRevenueThisYear),
                ),
                _buildInfoRow(
                  'Payments This Month',
                  stats.totalPaymentsThisMonth.toString(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Plan Distribution
            if (stats.subscriptionsByPlan.isNotEmpty) ...[
              _buildSectionTitle('Subscriptions by Plan'),
              const SizedBox(height: 12),
              _buildInfoCard(
                children: stats.subscriptionsByPlan.entries
                    .map((e) => _buildInfoRow(e.key, e.value.toString()))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Recent Activity
            if (stats.recentActivities.isNotEmpty) ...[
              _buildSectionTitle('Recent Activity'),
              const SizedBox(height: 12),
              ...stats.recentActivities
                  .take(10)
                  .map((activity) => _buildActivityItem(activity)),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    IconData icon;
    Color color;

    switch (activity.type.toUpperCase()) {
      case 'SHOP_CREATED':
        icon = Icons.add_business;
        color = Colors.green;
        break;
      case 'SUBSCRIPTION_UPGRADED':
        icon = Icons.upgrade;
        color = Colors.blue;
        break;
      case 'PAYMENT_RECEIVED':
        icon = Icons.payment;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(activity.description),
        subtitle: activity.shopName != null ? Text(activity.shopName!) : null,
        trailing: Text(
          _formatTimestamp(activity.timestamp),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (_) {
      return timestamp;
    }
  }
}
