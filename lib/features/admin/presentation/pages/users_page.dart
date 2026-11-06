import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
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
        title: Text(context.tr(NavText.users)),
        actions: [
          IconButton(
            tooltip: context.tr(CommonText.refresh),
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
                      hintText: context.tr(UserText.searchUsers),
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
                      PopupMenuItem(
                        value: 'clear',
                        child: Text(context.tr(UserText.clearFilters)),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          context.tr(CommonText.status),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status:active',
                        child: Text(context.tr(UserText.active)),
                      ),
                      PopupMenuItem(
                        value: 'status:suspended',
                        child: Text(context.tr(UserText.suspended)),
                      ),
                      PopupMenuItem(
                        value: 'status:deleted',
                        child: Text(context.tr(UserText.deleted)),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        enabled: false,
                        child: Text(
                          context.tr(CommonText.type),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'type:CLIENT',
                        child: Text(context.tr(UserText.shopOwner)),
                      ),
                      PopupMenuItem(
                        value: 'type:STAFF',
                        child: Text(context.tr(UserText.employee)),
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
                  ? AppEmptyView(
                      icon: Icons.people_outline_rounded,
                      title: context.tr(UserText.noUsersFound),
                      message: context.tr(UserText.tryADifferentSearchOr),
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
              PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text(context.tr(UserText.viewDetails)),
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
                      Text(context.tr(UserText.suspend)),
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
                      Text(context.tr(UserText.activate)),
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
                      Text(context.tr(CommonText.delete)),
                    ],
                  ),
                ),
              if (!isDeleted && _unverifiedChannels(user).isNotEmpty)
                PopupMenuItem(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.verified_user, color: context.status.success),
                      SizedBox(width: 8),
                      Text(context.tr(UserText.markVerified)),
                    ],
                  ),
                ),
              if (!isDeleted && user.userType != 'ADMIN')
                PopupMenuItem(
                  value: 'username',
                  child: Row(
                    children: [
                      Icon(Icons.badge_outlined, color: context.status.info),
                      const SizedBox(width: 8),
                      Text(context.tr(UserText.changeUsername)),
                    ],
                  ),
                ),
              if (!isDeleted)
                PopupMenuItem(
                  value: 'reset_password',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset_rounded),
                      SizedBox(width: 8),
                      Text(context.tr(UserText.resetPassword)),
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
      case 'verify':
        _showMarkVerifiedDialog(user);
        break;
      case 'username':
        _showChangeUsernameDialog(user);
        break;
      case 'reset_password':
        _showResetPasswordDialog(user);
        break;
    }
  }

  /// Same rule as registration on the backend (UsernamePolicy).
  static final _usernamePattern = RegExp(r'^[A-Za-z0-9._-]{3,50}$');

  void _showChangeUsernameDialog(AdminUser user) {
    final usernameController = TextEditingController(text: user.username);
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr(UserText.changeUsername)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr(UserText.currentTheUserIsSigned(user.username))),
              const SizedBox(height: 16),
              TextFormField(
                controller: usernameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.tr(UserText.newUsername),
                  helperText: context.tr(UserText.lettersDigits350No),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) {
                    return context.tr(UserText.usernameIsRequired);
                  }
                  if (name == user.username) {
                    return context.tr(UserText.enterADifferentUsername);
                  }
                  if (name.length < 3 || name.length > 50) {
                    return context.tr(UserText.mustBe3To50);
                  }
                  if (!_usernamePattern.hasMatch(name)) {
                    return context.tr(UserText.onlyEnglishLettersDigits);
                  }
                  // Sign-in refuses "--", so the backend does too.
                  if (name.contains('--')) {
                    return context.tr(UserText.noTwoDashesInA);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: context.tr(UserText.reasonOptional),
                  hintText: context.tr(UserText.eGOldUsernameHad),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr(CommonText.cancel)),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final messenger = ScaffoldMessenger.of(this.context);
              final username = usernameController.text.trim();
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              try {
                await ref
                    .read(usersProvider.notifier)
                    .changeUsername(user.id, username, reason);
                messenger.showSuccess(
                  UserText.isNowTellThemTo(user.username, username).current,
                );
              } catch (e) {
                messenger.showError(
                  UserText.failedToChangeUsername(friendlyError(e)).current,
                );
              }
            },
            child: Text(context.tr(CommonText.change)),
          ),
        ],
      ),
    );
  }

  /// Contacts the user has but has not verified, phone first: owners in Laos
  /// are far more likely to be stuck waiting for an OTP than an email.
  List<String> _unverifiedChannels(AdminUser user) => [
    if ((user.phone ?? '').trim().isNotEmpty && !user.phoneVerified) 'phone',
    if ((user.email ?? '').trim().isNotEmpty && !user.emailVerified) 'email',
  ];

  void _showMarkVerifiedDialog(AdminUser user) {
    final channels = _unverifiedChannels(user);
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var channel = channels.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr(UserText.markVerified)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(UserText.useThisWhenNeverReceived(user.username)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in channels)
                      ChoiceChip(
                        label: Text(
                          option == 'phone'
                              ? context.tr(UserText.phone(user.phone))
                              : context.tr(UserText.email(user.email)),
                        ),
                        selected: channel == option,
                        onSelected: (_) =>
                            setDialogState(() => channel = option),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: context.tr(UserText.howDidYouConfirmIt),
                    hintText: context.tr(UserText.eGCalledBackOn),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? context.tr(UserText.reasonIsRequired)
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr(CommonText.cancel)),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final messenger = ScaffoldMessenger.of(this.context);
                final reason = reasonController.text.trim();
                Navigator.pop(context);
                try {
                  await ref
                      .read(usersProvider.notifier)
                      .markUserVerified(user.id, channel, reason);
                  messenger.showSuccess(
                    channel == 'phone'
                        ? UserText.phoneMarkedVerified(user.username).current
                        : UserText.emailMarkedVerified(user.username).current,
                  );
                } catch (e) {
                  messenger.showError(
                    UserText.failedToMarkVerified(friendlyError(e)).current,
                  );
                }
              },
              child: Text(context.tr(UserText.markVerified)),
            ),
          ],
        ),
      ),
    );
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
              _buildDetailSection(context.tr(UserText.contactInformation), [
                _buildDetailRow(
                  context.tr(CommonText.email),
                  user.email ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(CommonText.phone),
                  user.phone ?? 'N/A',
                ),
                _buildDetailRow(
                  context.tr(UserText.emailVerified),
                  user.emailVerified
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
                _buildDetailRow(
                  context.tr(UserText.phoneVerified),
                  user.phoneVerified
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(UserText.accountStatus), [
                _buildDetailRow(
                  context.tr(CommonText.status),
                  user.status.toUpperCase(),
                ),
                _buildDetailRow(
                  context.tr(UserText.deleted2),
                  user.status.toLowerCase() == 'deleted'
                      ? context.tr(CommonText.yes)
                      : context.tr(CommonText.no),
                ),
              ]),
              const SizedBox(height: 16),
              _buildDetailSection(context.tr(UserText.activity), [
                _buildDetailRow(
                  context.tr(UserText.lastLogin),
                  user.lastLogin?.toString().split('.')[0] ??
                      context.tr(UserText.never),
                ),
                _buildDetailRow(
                  context.tr(CommonText.created),
                  user.createdAt?.toString().split(' ')[0] ?? 'N/A',
                ),
              ]),
              if (user.shops.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailSection(
                  context.tr(UserText.shops(user.shops.length)),
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
          title: Text(context.tr(UserText.resetPassword)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.tr(UserText.setANewPasswordFor(user.username))),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: context.tr(UserText.newPassword),
                    suffixIcon: IconButton(
                      tooltip: obscure
                          ? context.tr(AuthText.showPassword)
                          : context.tr(AuthText.hidePassword),
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr(UserText.passwordIsRequired);
                    }
                    if (value.length < 8) {
                      return context.tr(UserText.passwordMustBeAtLeast);
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
              child: Text(context.tr(CommonText.cancel)),
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
                    UserText.passwordResetFor(user.username).current,
                  );
                } catch (e) {
                  messenger.showError(
                    UserText.failedToResetPassword(friendlyError(e)).current,
                  );
                }
              },
              child: Text(context.tr(CommonText.reset)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStatusDialog(AdminUser user, String newStatus) async {
    final (title, verb, icon) = switch (newStatus) {
      'suspended' => (
        context.tr(UserText.suspendUser),
        context.tr(UserText.suspend),
        Icons.block_rounded,
      ),
      'deleted' => (
        context.tr(UserText.deleteUser),
        context.tr(CommonText.delete),
        Icons.delete_outline_rounded,
      ),
      _ => (
        context.tr(UserText.activateUser),
        context.tr(UserText.activate),
        Icons.check_circle_outline_rounded,
      ),
    };
    final destructive = newStatus != 'active';
    final reason = await AppDialogs.confirmWithReason(
      context,
      title: title,
      message: newStatus == 'deleted'
          ? context.tr(UserText.willLoseAccessImmediatelyYou(user.username))
          : newStatus == 'suspended'
          ? context.tr(UserText.willBeSignedOutAnd(user.username))
          : context.tr(UserText.willRegainAccessToTheir(user.username)),
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
      messenger.showSuccess(switch (newStatus) {
        'suspended' => UserText.hasBeenSuspended(user.username).current,
        'deleted' => UserText.hasBeenDeleted(user.username).current,
        _ => UserText.hasBeenActivated(user.username).current,
      });
    } catch (e) {
      messenger.showError(
        UserText.couldNotUpdate(user.username, friendlyError(e)).current,
      );
    }
  }
}
