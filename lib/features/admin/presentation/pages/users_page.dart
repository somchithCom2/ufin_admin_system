import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final _searchController = TextEditingController();
  String? _statusFilter;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(usersProvider.notifier).loadUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      ref.read(usersProvider.notifier).loadUsers(search: value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String?>(
                  icon: Badge(
                    isLabelVisible:
                        _statusFilter != null || _typeFilter != null,
                    child: const Icon(Icons.filter_list),
                  ),
                  onSelected: (value) {
                    if (value?.startsWith('status:') == true) {
                      setState(() => _statusFilter = value?.substring(7));
                    } else if (value?.startsWith('type:') == true) {
                      setState(() => _typeFilter = value?.substring(5));
                    } else {
                      setState(() {
                        _statusFilter = null;
                        _typeFilter = null;
                      });
                    }
                    ref
                        .read(usersProvider.notifier)
                        .loadUsers(
                          search: _searchController.text,
                          status: _statusFilter,
                          userType: _typeFilter,
                        );
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: null,
                      child: Text('Clear Filters'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status:active',
                      child: Text('  Active'),
                    ),
                    const PopupMenuItem(
                      value: 'status:suspended',
                      child: Text('  Suspended'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      enabled: false,
                      child: Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'type:SHOP_OWNER',
                      child: Text('  Shop Owner'),
                    ),
                    const PopupMenuItem(
                      value: 'type:EMPLOYEE',
                      child: Text('  Employee'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // User List
          Expanded(
            child: usersState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : usersState.error != null
                ? _buildErrorView(usersState.error!)
                : usersState.users.isEmpty
                ? const Center(child: Text('No users found'))
                : _buildUserList(usersState.users),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(error),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(usersProvider.notifier).loadUsers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<AdminUser> users) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(usersProvider.notifier).loadUsers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(user.status).withValues(alpha: 0.1),
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  user.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: _getStatusColor(user.status)),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}'),
            Row(
              children: [
                _buildStatusChip(user.status),
                const SizedBox(width: 8),
                _buildTypeChip(user.userType),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleUserAction(user, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (user.status != 'suspended')
              const PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Suspend'),
                  ],
                ),
              ),
            if (user.status == 'suspended')
              const PopupMenuItem(
                value: 'activate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Activate'),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'suspended':
        return Colors.orange;
      case 'banned':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleUserAction(AdminUser user, String action) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'suspend':
        _showStatusDialog(user, 'suspended');
        break;
      case 'activate':
        _showStatusDialog(user, 'active');
        break;
    }
  }

  void _showUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getStatusColor(
                      user.status,
                    ).withValues(alpha: 0.1),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: _getStatusColor(user.status),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('@${user.username}'),
                        Row(
                          children: [
                            _buildStatusChip(user.status),
                            const SizedBox(width: 8),
                            _buildTypeChip(user.userType),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection('Contact Information', [
                _buildDetailRow('Email', user.email ?? 'N/A'),
                _buildDetailRow('Phone', user.phone ?? 'N/A'),
                _buildDetailRow(
                  'Email Verified',
                  user.emailVerified ? 'Yes' : 'No',
                ),
                _buildDetailRow(
                  'Phone Verified',
                  user.phoneVerified ? 'Yes' : 'No',
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection('Activity', [
                _buildDetailRow(
                  'Last Login',
                  user.lastLogin?.toString().split('.')[0] ?? 'Never',
                ),
                _buildDetailRow(
                  'Created',
                  user.createdAt?.toString().split(' ')[0] ?? 'N/A',
                ),
              ]),
              if (user.shops.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Shops (${user.shops.length})',
                  user.shops
                      .map((shop) => _buildDetailRow(shop.shopName, shop.role))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showStatusDialog(AdminUser user, String newStatus) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus == 'suspended' ? 'Suspend User' : 'Activate User',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to ${newStatus == 'suspended' ? 'suspend' : 'activate'} "${user.username}"?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(usersProvider.notifier)
                  .updateUserStatus(
                    user.id,
                    newStatus,
                    reasonController.text.isNotEmpty
                        ? reasonController.text
                        : null,
                  );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
