import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

/// One row in the command palette.
@immutable
class PaletteItem {
  final Tr title;
  final Tr? subtitle;
  final IconData icon;
  final VoidCallback onSelect;

  /// Actions are listed after pages when the query is empty.
  final bool isAction;

  const PaletteItem({
    required this.title,
    required this.icon,
    required this.onSelect,
    this.subtitle,
    this.isAction = false,
  });

  bool matches(String query) =>
      query.isEmpty ||
      title.matches(query) ||
      (subtitle?.matches(query) ?? false);
}

/// Opens the quick-jump palette. The chosen item runs after the dialog has
/// closed, so it can open its own dialogs or change the section safely.
Future<void> showCommandPalette(
  BuildContext context, {
  required List<PaletteItem> items,
}) async {
  final chosen = await showDialog<PaletteItem>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    builder: (_) => _CommandPalette(items: items),
  );
  chosen?.onSelect();
}

class _CommandPalette extends StatefulWidget {
  final List<PaletteItem> items;
  const _CommandPalette({required this.items});

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  static const _rowHeight = 48.0;

  final _query = TextEditingController();
  final _scroll = ScrollController();
  late final FocusNode _fieldFocus = FocusNode(onKeyEvent: _onKey);
  late List<PaletteItem> _results = widget.items;
  int _highlight = 0;

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  void _filter(String raw) {
    final q = raw.trim();
    setState(() {
      _results = [
        for (final i in widget.items)
          if (i.matches(q)) i,
      ];
      _highlight = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  // Handled on the field's own node: key events reach the focused node
  // first, so the text field never turns arrows into cursor moves.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _move(int delta) {
    if (_results.isEmpty) return;
    setState(() {
      _highlight = (_highlight + delta) % _results.length;
      if (_highlight < 0) _highlight += _results.length;
    });
    _revealHighlight();
  }

  void _revealHighlight() {
    if (!_scroll.hasClients) return;
    final top = _highlight * _rowHeight;
    final bottom = top + _rowHeight;
    final view = _scroll.position;
    if (top < view.pixels) {
      _scroll.jumpTo(top);
    } else if (bottom > view.pixels + view.viewportDimension) {
      _scroll.jumpTo(bottom - view.viewportDimension);
    }
  }

  void _choose(PaletteItem item) => Navigator.of(context).pop(item);

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final text = context.text;
    final size = MediaQuery.sizeOf(context);
    final isPhone = size.width < AppSpacing.tabletBreakpoint;

    return Dialog(
      alignment: isPhone ? Alignment.topCenter : const Alignment(0, -0.55),
      insetPadding: EdgeInsets.fromLTRB(16, isPhone ? 56 : 24, 16, 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: (size.height * 0.6).clamp(240, 480),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: TextField(
                controller: _query,
                focusNode: _fieldFocus,
                autofocus: true,
                textInputAction: TextInputAction.go,
                onChanged: _filter,
                onSubmitted: (_) {
                  if (_results.isNotEmpty) _choose(_results[_highlight]);
                },
                style: text.bodyLarge,
                decoration: InputDecoration(
                  hintText: context.tr(NavText.jumpHint),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: _results.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        context.tr(NavText.noMatches),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(6),
                      itemExtent: _rowHeight,
                      itemCount: _results.length,
                      itemBuilder: (context, i) => _PaletteRow(
                        item: _results[i],
                        highlighted: i == _highlight,
                        onTap: () => _choose(_results[i]),
                        onHover: () => setState(() => _highlight = i),
                      ),
                    ),
            ),
            if (!isPhone) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 10,
                ),
                child: Text(
                  context.tr(NavText.navigateHint),
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final PaletteItem item;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _PaletteRow({
    required this.item,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: Material(
        color: highlighted ? scheme.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 19,
                  color: highlighted ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    context.tr(item.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (item.subtitle != null)
                  Text(
                    context.tr(item.subtitle!),
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                if (highlighted) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.keyboard_return_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
