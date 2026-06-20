import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';

class DeletedUsersPage extends ConsumerStatefulWidget {
  const DeletedUsersPage({super.key});

  @override
  ConsumerState<DeletedUsersPage> createState() => _DeletedUsersPageState();
}

class _DeletedUsersPageState extends ConsumerState<DeletedUsersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deletedUsersProvider.notifier).loadDeletedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deletedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: buildAdminMenuButton(context),
        title: const Text('Deleted Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(deletedUsersProvider.notifier).loadDeletedUsers(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.red.withValues(alpha: 0.08),
            child: Row(
              children: [
                Icon(
                  Icons.delete_sweep_outlined,
                  size: 18,
                  color: Colors.red[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing soft-deleted accounts sorted by most recently deleted.',
                    style: TextStyle(fontSize: 13, color: Colors.red[800]),
                  ),
                ),
              ],
            ),
          ),
          // Count badge
          if (!state.isLoading && state.error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Text(
                    '${state.users.length} deleted user${state.users.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (state.totalPages > 1) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· page ${state.currentPage + 1} of ${state.totalPages}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Content
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? _buildErrorView(state.error!)
                : state.users.isEmpty
                ? _buildEmptyView()
                : _buildUserList(state.users),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No deleted users',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Soft-deleted accounts will appear here.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
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
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                ref.read(deletedUsersProvider.notifier).loadDeletedUsers(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<AdminUser> users) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(deletedUsersProvider.notifier).loadDeletedUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: users.length,
        itemBuilder: (context, index) => _buildUserCard(users[index]),
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    final deletedAtLabel = user.deletedAt != null
        ? _formatDate(user.deletedAt!)
        : (user.updatedAt != null ? _formatDate(user.updatedAt!) : 'Unknown');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showUserDetails(user),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeChip(user.userType),
                        const SizedBox(width: 6),
                        Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Deleted $deletedAtLabel',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                onSelected: (action) {
                  if (action == 'restore') _confirmRestore(user);
                  if (action == 'details') _showUserDetails(user);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'restore',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Restore'),
                      ],
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _showUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.red,
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                        Text('@${user.username}'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DELETED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
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
              _buildDetailSection('Account', [
                _buildDetailRow('Type', user.userType.replaceAll('_', ' ')),
                _buildDetailRow(
                  'Created',
                  user.createdAt != null
                      ? user.createdAt!.toIso8601String().split('T')[0]
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Deleted At',
                  user.deletedAt != null
                      ? user.deletedAt!
                            .toIso8601String()
                            .replaceFirst('T', ' ')
                            .split('.')[0]
                      : 'N/A',
                ),
                _buildDetailRow(
                  'Last Login',
                  user.lastLogin
                          ?.toIso8601String()
                          .replaceFirst('T', ' ')
                          .split('.')[0] ??
                      'Never',
                ),
              ]),
              if (user.shops.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  'Shops (${user.shops.length})',
                  user.shops
                      .map((s) => _buildDetailRow(s.shopName, s.role))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.restore),
                  label: const Text('Restore User'),
                  onPressed: () {
                    Navigator.pop(context);
                    _confirmRestore(user);
                  },
                ),
              ),
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
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore User'),
        content: Text(
          'Restore "${user.username}" to an active account?\n\nTheir status will be set back to active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(this.context);
              Navigator.pop(context);
              try {
                await ref
                    .read(deletedUsersProvider.notifier)
                    .restoreUser(user.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('"${user.username}" has been restored.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (_) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to restore user. Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
