import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

/// An account chosen in a [UserPickerField].
@immutable
class UserSelection {
  final int id;
  final String username;
  final String? fullName;
  final String? phone;

  const UserSelection({
    required this.id,
    required this.username,
    this.fullName,
    this.phone,
  });

  factory UserSelection.fromUser(AdminUser user) {
    final name = [
      user.firstName,
      user.lastName,
    ].where((part) => (part ?? '').trim().isNotEmpty).join(' ');
    return UserSelection(
      id: user.id,
      username: user.username,
      fullName: name.isEmpty ? null : name,
      phone: user.phone,
    );
  }

  @override
  bool operator ==(Object other) => other is UserSelection && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Form field that lets the admin search and pick an account instead of
/// typing its id. Only staff accounts are offered: they are the only kind
/// that can own a shop.
class UserPickerField extends FormField<UserSelection> {
  UserPickerField({
    super.key,
    super.initialValue,
    ValueChanged<UserSelection?>? onChanged,
    String label = 'Account',
    String? helperText,
    bool required = true,
    Set<int> excludeIds = const {},
    FormFieldValidator<UserSelection>? validator,
  }) : super(
         validator:
             validator ??
             (v) => required && v == null ? 'Please select an account' : null,
         builder: (field) => _UserPickerTile(
           field: field,
           label: label,
           helperText: helperText,
           clearable: !required,
           excludeIds: excludeIds,
           onChanged: onChanged,
         ),
       );
}

class _UserPickerTile extends StatelessWidget {
  final FormFieldState<UserSelection> field;
  final String label;
  final String? helperText;
  final bool clearable;
  final Set<int> excludeIds;
  final ValueChanged<UserSelection?>? onChanged;

  const _UserPickerTile({
    required this.field,
    required this.label,
    required this.helperText,
    required this.clearable,
    required this.excludeIds,
    required this.onChanged,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showUserPicker(
      context,
      selected: field.value,
      excludeIds: excludeIds,
    );
    if (picked == null) return;
    field.didChange(picked);
    onChanged?.call(picked);
  }

  void _clear() {
    field.didChange(null);
    onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final value = field.value;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: () => _open(context),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Search and select an account',
          helperText: helperText,
          helperMaxLines: 3,
          errorText: field.errorText,
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
          suffixIcon: clearable && value != null
              ? IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: _clear,
                )
              : const Icon(Icons.unfold_more_rounded),
        ),
        child: value == null
            ? null
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      value.fullName == null
                          ? value.username
                          : '${value.fullName} (${value.username})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${value.id}',
                    style: TextStyle(
                      color: context.colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Opens the account search sheet. Returns `null` when dismissed.
Future<UserSelection?> showUserPicker(
  BuildContext context, {
  UserSelection? selected,
  Set<int> excludeIds = const {},
}) {
  final sheet = _UserPickerSheet(selected: selected, excludeIds: excludeIds);
  final wide = MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  if (wide) {
    return showDialog<UserSelection>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: sheet,
        ),
      ),
    );
  }
  return showModalBottomSheet<UserSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(heightFactor: 0.85, child: sheet),
  );
}

class _UserPickerSheet extends ConsumerStatefulWidget {
  final UserSelection? selected;
  final Set<int> excludeIds;
  const _UserPickerSheet({this.selected, this.excludeIds = const {}});

  @override
  ConsumerState<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends ConsumerState<_UserPickerSheet> {
  static const _pageSize = 20;
  static const _debounce = Duration(milliseconds: 350);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounceTimer;

  final List<AdminUser> _users = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  /// Responses from an older query are dropped, so fast typing never shows
  /// results for a stale search term.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _load();
    }
  }

  void _onQueryChanged(String _) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => _load(reset: true));
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore || _error != null)) return;
    final generation = reset ? ++_generation : _generation;
    final page = reset ? 0 : _page + 1;
    final query = _search.text.trim();

    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _users.clear();
        _hasMore = true;
      }
    });

    try {
      final result = await ref
          .read(adminRepositoryProvider)
          .getUsers(
            page: page,
            size: _pageSize,
            search: query.isEmpty ? null : query,
            status: 'active',
            userType: 'STAFF',
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        _users.addAll(
          result.content.where(
            (u) => u.deletedAt == null && !widget.excludeIds.contains(u.id),
          ),
        );
        _page = page;
        _hasMore = !result.isLast && result.content.isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Select account', style: context.text.titleLarge),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _search,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onQueryChanged,
              onSubmitted: (_) {
                _debounceTimer?.cancel();
                _load(reset: true);
              },
              decoration: const InputDecoration(
                hintText: 'Search by username, name, phone or email',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          const Divider(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_users.isEmpty) {
      if (_loading) return const AppLoadingView();
      if (_error != null) {
        return AppErrorView(
          error: _error,
          title: "Couldn't load accounts",
          onRetry: () => _load(reset: true),
        );
      }
      return AppEmptyView(
        icon: Icons.person_search_outlined,
        title: 'No accounts found',
        message: _search.text.trim().isEmpty
            ? null
            : 'No active staff account matches "${_search.text.trim()}".',
      );
    }

    final footer = _loading
        ? const LoadMoreIndicator()
        : _error != null
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _error = null);
                  _load();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Load more failed · Retry'),
              ),
            ),
          )
        : null;

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _users.length + (footer == null ? 0 : 1),
      separatorBuilder: (_, _) => const Divider(indent: 72),
      itemBuilder: (context, i) {
        if (i == _users.length) return footer!;
        final user = _users[i];
        final selection = UserSelection.fromUser(user);
        final isSelected = widget.selected?.id == user.id;
        return ListTile(
          selected: isSelected,
          leading: IconBadge(
            icon: Icons.person_rounded,
            color: context.colors.primary,
            size: 40,
          ),
          title: Text(
            selection.fullName ?? user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              '#${user.id}',
              user.username,
              if ((user.phone ?? '').isNotEmpty) user.phone!,
              if (user.shops.isNotEmpty)
                '${user.shops.length} shop${user.shops.length == 1 ? '' : 's'}',
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: context.colors.primary)
              : null,
          onTap: () => Navigator.of(context).pop(selection),
        );
      },
    );
  }
}
