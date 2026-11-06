import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

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
        title: Text(context.tr(NavText.deletedUsers)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(deletedUsersProvider.notifier).loadDeletedUsers(),
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: context.colors.error.withValues(alpha: 0.08),
              child: Row(
                children: [
                  Icon(
                    Icons.delete_sweep_outlined,
                    size: 18,
                    color: context.colors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr(UserText.showingSoftDeletedAccountsSorted),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.error,
                      ),
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
                      state.users.length == 1
                          ? context.tr(UserText.n1DeletedUser)
                          : context.tr(
                              UserText.deletedUsers(state.users.length),
                            ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (state.totalPages > 1) ...[
                      const SizedBox(width: 6),
                      Text(
                        context.tr(
                          UserText.pageOf(
                            state.currentPage + 1,
                            state.totalPages,
                          ),
                        ),
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
                  ? const AppLoadingView()
                  : state.error != null
                  ? _buildErrorView(state.error!)
                  : state.users.isEmpty
                  ? _buildEmptyView()
                  : _buildUserList(state.users),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: context.colors.outline),
          const SizedBox(height: 16),
          Text(
            context.tr(UserText.noDeletedUsers),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(UserText.softDeletedAccountsWillAppear),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return AppErrorView(
      error: error,
      onRetry: () => ref.read(deletedUsersProvider.notifier).loadDeletedUsers(),
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
        : (user.updatedAt != null
              ? _formatDate(user.updatedAt!)
              : context.tr(CommonText.unknown));

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
                backgroundColor: context.colors.error.withValues(alpha: 0.1),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.username.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: context.colors.error,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTypeChip(user.userType),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: context.colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr(UserText.deleted3(deletedAtLabel)),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.onSurfaceVariant,
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
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text(context.tr(UserText.viewDetails2)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'restore',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: context.status.success),
                        SizedBox(width: 8),
                        Text(context.tr(UserText.restore)),
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

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return context.tr(UserText.today);
    if (diff.inDays == 1) return context.tr(UserText.yesterday);
    if (diff.inDays < 7) return context.tr(UserText.daysAgo(diff.inDays));
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
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: context.colors.error.withValues(
                      alpha: 0.1,
                    ),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.username.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              color: context.colors.error,
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
                            color: context.colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'DELETED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.colors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailSection(context.tr(UserText.contactInformation2), [
                _buildDetailRow(
                  context.tr(CommonText.email),
                  user.email ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.phone),
                  user.phone ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(UserText.emailVerified2),
                  user.emailVerified
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
                _buildDetailRow(
                  context.tr(UserText.phoneVerified2),
                  user.phoneVerified
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(NavText.account), [
                _buildDetailRow(
                  context.tr(CommonText.type),
                  user.userType.replaceAll('_', ' '),
                ),
                _buildDetailRow(
                  context.tr(CommonText.created),
                  user.createdAt != null
                      ? user.createdAt!.toIso8601String().split('T')[0]
                      : 'N/A',
                ),
                _buildDetailRow(
                  context.tr(UserText.deletedAt),
                  user.deletedAt != null
                      ? user.deletedAt!
                            .toIso8601String()
                            .replaceFirst('T', ' ')
                            .split('.')[0]
                      : 'N/A',
                ),
                _buildDetailRow(
                  context.tr(UserText.lastLogin2),
                  user.lastLogin
                          ?.toIso8601String()
                          .replaceFirst('T', ' ')
                          .split('.')[0] ??
                      context.tr(UserText.never2),
                ),
              ]),
              if (user.shops.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  context.tr(UserText.shops3(user.shops.length)),
                  user.shops
                      .map((s) => _buildDetailRow(s.shopName, s.role))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.status.success,
                  ),
                  icon: const Icon(Icons.restore),
                  label: Text(context.tr(UserText.restoreUser)),
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
          Text(label, style: TextStyle(color: context.colors.onSurfaceVariant)),
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

  Future<void> _confirmRestore(AdminUser user) async {
    final ok = await AppDialogs.confirm(
      context,
      title: context.tr(UserText.restore2(user.username)),
      message: context.tr(UserText.theAccountBecomesActiveAgain),
      confirmLabel: context.tr(UserText.restore),
      icon: Icons.restore_rounded,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(deletedUsersProvider.notifier).restoreUser(user.id);
      messenger.showSuccess(UserText.hasBeenRestored(user.username).current);
    } catch (e) {
      messenger.showError(
        UserText.failedToRestoreUser(friendlyError(e)).current,
      );
    }
  }
}
