import 'package:flutter/material.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';

/// The strip under a list page's AppBar: search plus filter chips.
///
/// Wide (≥ [wideBreakpoint]): search and chips share one row, so filters
/// cost a single 40px line instead of a stack of rows. Narrow: search on top,
/// then one left-aligned chip row that scrolls sideways and fades only at an
/// edge that actually has more chips behind it. Chips never wrap and never
/// centre, whatever their count or language.
class FilterBar extends StatelessWidget {
  final Widget? search;
  final List<Widget> filters;

  /// Shown pinned at the end of the chip row; pass it only when there is
  /// something to clear (pages typically do so from two active filters).
  final VoidCallback? onClearAll;

  static const double wideBreakpoint = 720;
  static const double _gutter = 16;

  const FilterBar({
    super.key,
    this.search,
    this.filters = const [],
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final clearAll = onClearAll == null
        ? null
        : IconButton(
            tooltip: context.tr(CommonText.clearAllFilters),
            visualDensity: VisualDensity.compact,
            icon: const AppIcon(AppIcons.filterX, size: 20),
            onPressed: onClearAll,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideBreakpoint;
        final search = this.search;
        final chips = filters.isEmpty
            ? null
            : _ChipStrip(
                // Wide rows already start after the search box.
                padding: EdgeInsets.symmetric(horizontal: wide ? 0 : _gutter),
                children: filters,
              );

        if (wide) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 4, _gutter - 4, 12),
            child: Row(
              children: [
                if (search != null)
                  SizedBox(
                    width: (constraints.maxWidth * 0.4).clamp(280.0, 440.0),
                    child: search,
                  ),
                if (search != null && chips != null) const SizedBox(width: 12),
                Expanded(child: chips ?? const SizedBox.shrink()),
                ?clearAll,
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (search != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _gutter),
                  child: search,
                ),
              if (search != null && chips != null) const SizedBox(height: 10),
              if (chips != null)
                Row(
                  children: [
                    Expanded(child: chips),
                    if (clearAll != null) ...[
                      clearAll,
                      const SizedBox(width: _gutter - 8),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Horizontally scrolling chip row that fades an edge only while more chips
/// sit behind it, so a row that fits is drawn plainly (and cheaply).
class _ChipStrip extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const _ChipStrip({required this.children, required this.padding});

  @override
  State<_ChipStrip> createState() => _ChipStripState();
}

class _ChipStripState extends State<_ChipStrip> {
  final _controller = ScrollController();
  bool _fadeStart = false;
  bool _fadeEnd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync([ScrollMetrics? metrics]) {
    if (!mounted) return;
    final m = metrics ?? (_controller.hasClients ? _controller.position : null);
    if (m == null || !m.hasContentDimensions) return;
    final start = m.extentBefore > 0.5;
    final end = m.extentAfter > 0.5;
    if (start != _fadeStart || end != _fadeEnd) {
      setState(() {
        _fadeStart = start;
        _fadeEnd = end;
      });
    }
  }

  bool _onMetrics(ScrollMetricsNotification n) {
    if (n.metrics.axis == Axis.horizontal) _sync(n.metrics);
    return false;
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.horizontal) _sync(n.metrics);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget strip = SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      child: Row(spacing: 8, children: widget.children),
    );
    if (_fadeStart || _fadeEnd) {
      strip = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          final edge = (24 / rect.width).clamp(0.0, 0.5);
          return LinearGradient(
            colors: [
              _fadeStart ? Colors.transparent : Colors.black,
              Colors.black,
              Colors.black,
              _fadeEnd ? Colors.transparent : Colors.black,
            ],
            stops: [0, edge, 1 - edge, 1],
          ).createShader(rect);
        },
        child: strip,
      );
    }
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: strip,
      ),
    );
  }
}

/// Filter chip: the filter's [label] while unset; its [value] once set,
/// highlighted, with a clear button when [onClear] is given.
class FilterButton extends StatelessWidget {
  final AppIconData? icon;
  final String label;
  final String? value;

  /// Defaults to `value != null`. Pass it for filters that always have a
  /// value (e.g. a plan scope) to highlight only non-default choices.
  final bool? highlighted;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  /// Chips drop their leading icon below this width so more of them fit.
  static const double compactBelow = 600;

  const FilterButton({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
    this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final active = highlighted ?? value != null;
    final clearable = value != null && onClear != null;
    final fg = active ? scheme.primary : scheme.onSurface;
    final compact = MediaQuery.sizeOf(context).width < compactBelow;
    final icon = this.icon;

    return Semantics(
      button: true,
      label: value == null ? label : '$label: $value',
      excludeSemantics: !clearable,
      child: Material(
        color: active ? scheme.primary.withValues(alpha: 0.10) : scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: active
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: clearable ? 4 : 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null && !compact) ...[
                    AppIcon(
                      icon,
                      size: 16,
                      color: active ? fg : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                  ],
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(
                      value ?? label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ),
                  if (clearable)
                    IconButton(
                      tooltip: context.tr(CommonText.clearFilter(label)),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                      icon: AppIcon(AppIcons.close, size: 16, color: fg),
                      onPressed: onClear,
                    )
                  else ...[
                    const SizedBox(width: 2),
                    AppIcon(
                      AppIcons.chevronDown,
                      size: 18,
                      color: active ? fg : scheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One-tap choice chip for quick options shown side by side (e.g. Today,
/// Yesterday): same height and colours as [FilterButton], no menu.
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppIconData? icon;

  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final fg = selected ? scheme.primary : scheme.onSurface;
    final icon = this.icon;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    AppIcon(
                      icon,
                      size: 16,
                      color: selected ? fg : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of a [FilterMenu].
class FilterMenuEntry {
  final String label;
  final AppIconData? icon;
  final bool selected;
  final VoidCallback onSelected;

  const FilterMenuEntry({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });
}

/// [FilterButton] that opens a menu anchored under it. Use it directly when
/// entries are actions (e.g. "Custom range…"); otherwise prefer
/// [FilterSelect].
class FilterMenu extends StatelessWidget {
  final AppIconData? icon;
  final String label;
  final String? value;
  final bool? highlighted;
  final List<FilterMenuEntry> entries;
  final VoidCallback? onClear;

  const FilterMenu({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.entries,
    this.onClear,
    this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final check = AppIcon(
      AppIcons.check,
      size: 18,
      color: context.colors.primary,
    );
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      menuChildren: [
        for (final e in entries)
          MenuItemButton(
            leadingIcon: e.icon == null ? null : AppIcon(e.icon, size: 18),
            trailingIcon: e.selected ? check : null,
            onPressed: e.onSelected,
            child: Text(e.label),
          ),
      ],
      builder: (context, controller, _) => FilterButton(
        icon: icon,
        label: label,
        value: value,
        highlighted: highlighted,
        onClear: onClear,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// A choice for [FilterSelect].
class FilterOption<T> {
  final T value;
  final String label;
  final AppIconData? icon;

  const FilterOption(this.value, this.label, {this.icon});
}

/// Single-choice filter as one chip: "Status ▾" until chosen, then
/// "Active ×". With [allLabel] the menu starts with an "All" entry and the
/// chip can be cleared back to `null`; without it a value is always set.
class FilterSelect<T> extends StatelessWidget {
  final AppIconData? icon;
  final String label;
  final T? value;
  final List<FilterOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? allLabel;
  final bool? highlighted;

  const FilterSelect({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.allLabel,
    this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    String? current;
    for (final o in options) {
      if (o.value == value) current = o.label;
    }
    final allLabel = this.allLabel;
    return FilterMenu(
      icon: icon,
      label: label,
      value: value == null ? null : current,
      highlighted: highlighted,
      onClear: allLabel == null ? null : () => onChanged(null),
      entries: [
        if (allLabel != null)
          FilterMenuEntry(
            label: allLabel,
            selected: value == null,
            onSelected: () => onChanged(null),
          ),
        for (final o in options)
          FilterMenuEntry(
            label: o.label,
            icon: o.icon,
            selected: o.value == value,
            onSelected: () => onChanged(o.value),
          ),
      ],
    );
  }
}
