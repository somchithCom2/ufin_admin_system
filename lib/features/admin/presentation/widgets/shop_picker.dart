import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

/// A shop chosen in a [ShopPickerField]. Kept minimal so callers that only
/// know an id and name (e.g. an existing subscription) can pre-fill it.
@immutable
class ShopSelection {
  final int id;
  final String name;
  final String? owner;
  final String? status;

  const ShopSelection({
    required this.id,
    required this.name,
    this.owner,
    this.status,
  });

  factory ShopSelection.fromShop(AdminShop shop) => ShopSelection(
    id: shop.id,
    name: shop.name,
    owner: shop.ownerUsername,
    status: shop.status,
  );

  @override
  bool operator ==(Object other) => other is ShopSelection && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Form field that lets the admin search and pick a shop instead of typing
/// its numeric id. Validates as "required" by default.
class ShopPickerField extends FormField<ShopSelection> {
  ShopPickerField({
    super.key,
    super.initialValue,
    ValueChanged<ShopSelection>? onChanged,
    bool locked = false,
    bool enabled = true,
    String? label,
    FormFieldValidator<ShopSelection>? validator,
  }) : super(
         enabled: enabled && !locked,
         validator:
             validator ??
             (v) => v == null ? ShopText.pleaseSelectAShop.current : null,
         builder: (field) => _ShopPickerTile(
           field: field,
           label: label ?? field.context.tr(CommonText.shop),
           locked: locked,
           onChanged: onChanged,
         ),
       );
}

class _ShopPickerTile extends StatelessWidget {
  final FormFieldState<ShopSelection> field;
  final String label;
  final bool locked;
  final ValueChanged<ShopSelection>? onChanged;

  const _ShopPickerTile({
    required this.field,
    required this.label,
    required this.locked,
    required this.onChanged,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showShopPicker(context, selected: field.value);
    if (picked == null) return;
    field.didChange(picked);
    onChanged?.call(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = field.value;
    final enabled = field.widget.enabled;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: enabled ? () => _open(context) : null,
      child: InputDecorator(
        isEmpty: value == null,
        isFocused: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: context.tr(ShopText.searchAndSelectAShop),
          errorText: field.errorText,
          enabled: enabled || locked,
          prefixIcon: const AppIcon(AppIcons.shop, size: 20),
          suffixIcon: locked
              ? Tooltip(
                  message: context.tr(ShopText.shopCannotBeChangedHere),
                  child: AppIcon(AppIcons.lock, size: 18),
                )
              : const AppIcon(AppIcons.chevronsUpDown),
        ),
        child: value == null
            ? null
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      value.name,
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

/// Opens the shop search sheet. Returns `null` when dismissed.
Future<ShopSelection?> showShopPicker(
  BuildContext context, {
  ShopSelection? selected,
}) {
  final wide = MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  if (wide) {
    return showDialog<ShopSelection>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: _ShopPickerSheet(selected: selected),
        ),
      ),
    );
  }
  return showModalBottomSheet<ShopSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _ShopPickerSheet(selected: selected),
    ),
  );
}

class _ShopPickerSheet extends ConsumerStatefulWidget {
  final ShopSelection? selected;
  const _ShopPickerSheet({this.selected});

  @override
  ConsumerState<_ShopPickerSheet> createState() => _ShopPickerSheetState();
}

class _ShopPickerSheetState extends ConsumerState<_ShopPickerSheet> {
  static const _pageSize = 20;
  static const _debounce = Duration(milliseconds: 350);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounceTimer;

  final List<AdminShop> _shops = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  /// Incremented per query; responses from older queries are discarded so
  /// fast typing can never show results for a stale search term.
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
        _shops.clear();
        _hasMore = true;
      }
    });

    try {
      final result = await ref
          .read(adminRepositoryProvider)
          .getShops(
            page: page,
            size: _pageSize,
            search: query.isEmpty ? null : query,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        _shops.addAll(result.content);
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
    final textTheme = context.text;
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
                  child: Text(
                    context.tr(ShopText.selectShop),
                    style: textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: context.tr(CommonText.close),
                  icon: const AppIcon(AppIcons.close),
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
              decoration: InputDecoration(
                hintText: context.tr(ShopText.searchByShopNameOwner),
                prefixIcon: AppIcon(AppIcons.search, size: 20),
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
    if (_shops.isEmpty) {
      if (_loading) return const AppLoadingView();
      if (_error != null) {
        return AppErrorView(
          error: _error,
          title: context.tr(ShopText.couldnTLoadShops),
          onRetry: () => _load(reset: true),
        );
      }
      return AppEmptyView(
        icon: AppIcons.shop,
        title: context.tr(ShopText.noShopsFound2),
        message: _search.text.trim().isEmpty
            ? null
            : context.tr(ShopText.noShopMatches(_search.text.trim())),
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
                icon: const AppIcon(AppIcons.refresh, size: 18),
                label: Text(context.tr(ShopText.loadMoreFailedRetry)),
              ),
            ),
          )
        : null;

    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _shops.length + (footer == null ? 0 : 1),
      separatorBuilder: (_, _) => const Divider(indent: 72),
      itemBuilder: (context, i) {
        if (i == _shops.length) return footer!;
        final shop = _shops[i];
        final isSelected = widget.selected?.id == shop.id;
        final tone = StatusTone.fromStatus(shop.status);
        return ListTile(
          selected: isSelected,
          leading: IconBadge(
            icon: AppIcons.shop,
            color: tone.foreground(context),
            size: 40,
          ),
          title: Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            [
              '#${shop.id}',
              if (shop.ownerUsername != null) shop.ownerUsername!,
              if (shop.planLabel != null) shop.planLabel!,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isSelected
              ? AppIcon(AppIcons.checkCircle, color: context.colors.primary)
              : StatusBadge.fromStatus(shop.status),
          onTap: () => Navigator.of(context).pop(ShopSelection.fromShop(shop)),
        );
      },
    );
  }
}
