import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/admin_shell.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final _searchController = TextEditingController();
  late ScrollController _scrollController;
  String? _statusFilter;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(usersProvider.notifier)
          .loadUsers(
            search: _searchController.text,
            status: _statusFilter,
            userType: _typeFilter,
          );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      final state = ref.read(usersProvider);
      if (!state.isLoadingMore && state.hasNext) {
        ref.read(usersProvider.notifier).loadMoreUsers();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref
                .read(usersProvider.notifier)
                .loadUsers(
                  search: _searchController.text,
                  status: _statusFilter,
                  userType: _typeFilter,
                ),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Search and Filter
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      controller: _searchController,
                      hintText: 'Search users…',
                      onSubmitted: (value) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(0);
                        }
                        ref
                            .read(usersProvider.notifier)
                            .loadUsers(
                              search: value,
                              status: _statusFilter,
                              userType: _typeFilter,
                            );
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
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
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
                        value: 'clear',
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
                      const PopupMenuItem(
                        value: 'status:deleted',
                        child: Text('  Deleted'),
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
                        value: 'type:CLIENT',
                        child: Text('  Shop Owner'),
                      ),
                      const PopupMenuItem(
                        value: 'type:STAFF',
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
                  ? const AppLoadingView()
                  : usersState.error != null && usersState.users.isEmpty
                  ? _buildErrorView(usersState.error!)
                  : usersState.users.isEmpty
                  ? const AppEmptyView(
                      icon: Icons.people_outline_rounded,
                      title: 'No users found',
                      message: 'Try a different search or filter.',
                    )
                  : _buildUserList(usersState.users),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref
          .read(usersProvider.notifier)
          .loadUsers(
            search: _searchController.text,
            status: _statusFilter,
            userType: _typeFilter,
          ),
    );
  }

  Widget _buildUserList(List<AdminUser> users) {
    final usersState = ref.watch(usersProvider);
    final hasMore = usersState.hasNext;

    return RefreshIndicator(
      onRefresh: () async {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        await ref
            .read(usersProvider.notifier)
            .loadUsers(
              search: _searchController.text,
              status: _statusFilter,
              userType: _typeFilter,
            );
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: hasMore ? users.length + 1 : users.length,
        itemBuilder: (context, index) {
          if (index == users.length && hasMore) {
            return const LoadMoreIndicator();
          }
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    final isDeleted = user.status.toLowerCase() == 'deleted';
    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(
              user.status,
            ).withValues(alpha: 0.1),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    (user.username.isEmpty
                        ? '?'
                        : user.username.substring(0, 1).toUpperCase()),
                    style: TextStyle(color: _getStatusColor(user.status)),
                  )
                : null,
          ),
          title: Text(
            user.fullName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isDeleted ? TextDecoration.lineThrough : null,
            ),
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
              if (!isDeleted &&
                  user.userType != 'ADMIN' &&
                  user.status != 'suspended')
                PopupMenuItem(
                  value: 'suspend',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: context.status.warning),
                      SizedBox(width: 8),
                      Text('Suspend'),
                    ],
                  ),
                ),
              if (!isDeleted && user.status != 'active')
                PopupMenuItem(
                  value: 'activate',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: context.status.success),
                      SizedBox(width: 8),
                      Text('Activate'),
                    ],
                  ),
                ),
              if (!isDeleted && user.userType != 'ADMIN')
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: context.colors.error),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              if (!isDeleted)
                const PopupMenuItem(
                  value: 'reset_password',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Reset Password'),
                    ],
                  ),
                ),
            ],
          ),
          onTap: () => _showUserDetails(user),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return StatusBadge.fromStatus(status);
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.status.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: context.status.info,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return StatusTone.fromStatus(status).foreground(context);
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
      case 'delete':
        _showStatusDialog(user, 'deleted');
        break;
      case 'reset_password':
        _showResetPasswordDialog(user);
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
                    color: context.colors.outline,
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
                            (user.username.isEmpty
                                ? '?'
                                : user.username.substring(0, 1).toUpperCase()),
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
              _buildDetailSection('Account Status', [
                _buildDetailRow('Status', user.status.toUpperCase()),
                _buildDetailRow(
                  'Deleted',
                  user.status.toLowerCase() == 'deleted' ? 'Yes' : 'No',
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
          Text(label, style: TextStyle(color: context.colors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(AdminUser user) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Set a new password for "${user.username}"'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final messenger = ScaffoldMessenger.of(this.context);
                final password = passwordController.text;
                Navigator.pop(context);
                try {
                  await ref
                      .read(usersProvider.notifier)
                      .resetUserPassword(user.id, password);
                  messenger.showSuccess(
                    'Password reset for "${user.username}"',
                  );
                } catch (e) {
                  messenger.showError(
                    'Failed to reset password: ${friendlyError(e)}',
                  );
                }
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(AdminUser user, String newStatus) async {
    final (title, verb, pastTense, icon) = switch (newStatus) {
      'suspended' => (
        'Suspend user',
        'Suspend',
        'suspended',
        Icons.block_rounded,
      ),
      'deleted' => (
        'Delete user',
        'Delete',
        'deleted',
        Icons.delete_outline_rounded,
      ),
      _ => (
        'Activate user',
        'Activate',
        'activated',
        Icons.check_circle_outline_rounded,
      ),
    };
    final destructive = newStatus != 'active';
    final reason = await AppDialogs.confirmWithReason(
      context,
      title: title,
      message: newStatus == 'deleted'
          ? '"${user.username}" will lose access immediately. You can restore the account later from Deleted Users.'
          : newStatus == 'suspended'
          ? '"${user.username}" will be signed out and unable to log in until reactivated.'
          : '"${user.username}" will regain access to their account.',
      confirmLabel: verb,
      destructive: destructive,
      icon: icon,
    );
    if (reason == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(usersProvider.notifier)
          .updateUserStatus(user.id, newStatus, reason.isEmpty ? null : reason);
      messenger.showSuccess('"${user.username}" has been $pastTense');
    } catch (e) {
      messenger.showError(
        'Could not update "${user.username}": ${friendlyError(e)}',
      );
    }
  }
}
