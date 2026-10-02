import 'package:flutter/material.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/constants/error_messages.dart';

export 'package:ufin_admin_system/config/theme/app_theme.dart'
    show AppSpacing, StatusColors, StatusColorsX;

/// Short theme accessors: `context.colors.primary`, `context.text.bodySmall`.
extension ThemeContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}

// ---------------------------------------------------------------------------
// Messages
// ---------------------------------------------------------------------------

/// Turns any thrown object into a short, user-facing sentence.
String friendlyError(Object? error) {
  if (error == null) return 'Something went wrong. Please try again.';
  var text = error.toString().trim();
  // Strip Dart's default exception prefixes ("Exception: ", "ApiException: ").
  text = text.replaceFirst(
    RegExp(r'^(\w*Exception|\w*Error|Bad state|Invalid argument\(s\)):\s*'),
    '',
  );
  if (text.isEmpty || text.startsWith('Instance of')) {
    return 'Something went wrong. Please try again.';
  }
  // Server HTML error pages are not readable to users.
  if (text.startsWith('<')) return 'Server error. Please try again later.';
  // The backend answers with bare ERR_ codes so the shop app can translate
  // them; this console was putting those codes straight in front of an admin.
  final mapped = ErrorMessages.lookup(text);
  if (mapped != null) return mapped;
  if (ErrorMessages.isCode(text)) {
    // Unknown code: still better than nothing, but make it readable.
    return text
        .substring(4)
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m[0]!.toUpperCase());
  }
  return text.length > 240 ? '${text.substring(0, 240)}…' : text;
}

enum FeedbackKind { success, error, info, warning }

/// Consistent floating snackbars. Replaces the previous one so rapid
/// actions never queue a backlog of stale messages.
abstract final class AppFeedback {
  static void success(BuildContext context, String message) =>
      show(context, message, kind: FeedbackKind.success);

  static void error(BuildContext context, Object? error) =>
      show(context, friendlyError(error), kind: FeedbackKind.error);

  static void info(BuildContext context, String message) =>
      show(context, message, kind: FeedbackKind.info);

  static void warning(BuildContext context, String message) =>
      show(context, message, kind: FeedbackKind.warning);

  static void show(
    BuildContext context,
    String message, {
    FeedbackKind kind = FeedbackKind.info,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    _showOn(messenger, Theme.of(context), message, kind, action);
  }

  /// For use after an `await`, with a messenger captured beforehand.
  static void showOn(
    ScaffoldMessengerState messenger,
    String message, {
    FeedbackKind kind = FeedbackKind.info,
  }) {
    if (!messenger.mounted) return;
    _showOn(messenger, Theme.of(messenger.context), message, kind, null);
  }

  static void _showOn(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    String message,
    FeedbackKind kind,
    SnackBarAction? action,
  ) {
    final scheme = theme.colorScheme;
    final status = theme.extension<StatusColors>() ?? StatusColors.light;

    final (IconData icon, Color accent) = switch (kind) {
      FeedbackKind.success => (Icons.check_circle_rounded, status.success),
      FeedbackKind.error => (Icons.error_rounded, scheme.error),
      FeedbackKind.warning => (Icons.warning_amber_rounded, status.warning),
      FeedbackKind.info => (Icons.info_rounded, status.info),
    };
    // Inverted surface so the snackbar stands out in both themes.
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    final fg = isDark ? const Color(0xFF0F172A) : Colors.white;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          duration: Duration(seconds: kind == FeedbackKind.error ? 5 : 3),
          action: action,
          content: Row(
            children: [
              Icon(icon, color: accent, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(message, style: TextStyle(color: fg)),
              ),
            ],
          ),
        ),
      );
  }
}

/// Shorthands on a captured messenger: `messenger.showSuccess('Saved')`.
extension AppFeedbackMessenger on ScaffoldMessengerState {
  void showSuccess(String message) =>
      AppFeedback.showOn(this, message, kind: FeedbackKind.success);
  void showError(Object? error) =>
      AppFeedback.showOn(this, friendlyError(error), kind: FeedbackKind.error);
  void showWarning(String message) =>
      AppFeedback.showOn(this, message, kind: FeedbackKind.warning);
}

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------

abstract final class AppDialogs {
  /// Standard confirmation. Returns `true` only when the user confirms.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  /// Confirmation with a free-text reason. Returns `null` when cancelled,
  /// otherwise the trimmed reason (possibly empty when [reasonRequired] is false).
  static Future<String?> confirmWithReason(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String reasonLabel = 'Reason',
    bool reasonRequired = false,
    bool destructive = false,
    IconData? icon,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: 'Cancel',
        destructive: destructive,
        icon: icon,
        reasonLabel: reasonLabel,
        reasonRequired: reasonRequired,
      ),
    );
  }
}

class _ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final IconData? icon;
  final String? reasonLabel;
  final bool reasonRequired;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
    this.icon,
    this.reasonLabel,
    this.reasonRequired = false,
  });

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final _reason = TextEditingController();
  String? _reasonError;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.reasonLabel == null) {
      Navigator.of(context).pop(true);
      return;
    }
    final text = _reason.text.trim();
    if (widget.reasonRequired && text.isEmpty) {
      setState(() => _reasonError = 'Please enter a reason');
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = widget.destructive ? scheme.error : scheme.primary;
    final hasReason = widget.reasonLabel != null;

    return AlertDialog(
      icon: widget.icon == null
          ? null
          : IconBadge(icon: widget.icon!, color: accent, size: 44),
      title: Text(widget.title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.message,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
            if (hasReason) ...[
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _reason,
                autofocus: true,
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (_reasonError != null) {
                    setState(() => _reasonError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: widget.reasonRequired
                      ? widget.reasonLabel
                      : '${widget.reasonLabel} (optional)',
                  errorText: _reasonError,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State views
// ---------------------------------------------------------------------------

class AppLoadingView extends StatelessWidget {
  final String? message;
  const AppLoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Centered icon + title + message + optional action. Used for empty and
/// error states so every page looks and reads the same.
class AppMessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Color? color;
  final Widget? action;

  const AppMessageView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.color,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scrollable so RefreshIndicator works and small heights don't overflow.
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 0,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconBadge(
                        icon: icon,
                        color: color ?? scheme.onSurfaceVariant,
                        size: 56,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      if (message != null && message!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs + 2),
                        Text(
                          message!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (action != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        action!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final String title;

  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title = "Couldn't load data",
  });

  @override
  Widget build(BuildContext context) {
    return AppMessageView(
      icon: Icons.cloud_off_rounded,
      color: Theme.of(context).colorScheme.error,
      title: title,
      message: friendlyError(error),
      action: onRetry == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const AppEmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppMessageView(
      icon: icon,
      title: title,
      message: message,
      action: action,
    );
  }
}

/// Small spinner row shown at the bottom of paginated lists.
class LoadMoreIndicator extends StatelessWidget {
  const LoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Tinted rounded square holding an icon.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Semantic tone for badges and accents.
enum StatusTone {
  success,
  warning,
  danger,
  info,
  neutral,
  primary;

  /// Maps common backend status strings to a tone.
  static StatusTone fromStatus(String? status) {
    final s = (status ?? '').toLowerCase().replaceAll(RegExp(r'[\s-]'), '_');
    const success = {
      'active',
      'approved',
      'paid',
      'completed',
      'success',
      'succeeded',
      'published',
      'verified',
      'enabled',
      'confirmed',
    };
    const warning = {
      'pending',
      'trial',
      'expiring',
      'expiring_soon',
      'processing',
      'grace',
      'grace_period',
      'waiting',
      'draft',
      'review',
      'in_review',
    };
    const danger = {
      'suspended',
      'rejected',
      'failed',
      'cancelled',
      'canceled',
      'blocked',
      'deleted',
      'banned',
      'error',
      'refunded',
      'overdue',
      'disabled',
    };
    const neutral = {'expired', 'inactive', 'unpublished', 'archived'};
    const info = {'trial', 'trialing'};
    if (info.contains(s)) return StatusTone.info;
    if (success.contains(s)) return StatusTone.success;
    if (warning.contains(s)) return StatusTone.warning;
    if (danger.contains(s)) return StatusTone.danger;
    if (neutral.contains(s)) return StatusTone.neutral;
    return StatusTone.info;
  }

  Color foreground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = context.status;
    return switch (this) {
      StatusTone.success => status.success,
      StatusTone.warning => status.warning,
      StatusTone.danger => scheme.error,
      StatusTone.info => status.info,
      StatusTone.neutral => status.neutral,
      StatusTone.primary => scheme.primary,
    };
  }
}

/// Compact pill showing a status label, colored by [tone].
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.icon,
  });

  /// Derives the tone from a raw backend status and title-cases the label.
  factory StatusBadge.fromStatus(String? status, {Key? key}) {
    return StatusBadge(
      key: key,
      label: humanize(status ?? 'Unknown'),
      tone: StatusTone.fromStatus(status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = tone.foreground(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// `"EXPIRING_SOON"` → `"Expiring soon"`.
String humanize(String raw) {
  final s = raw.replaceAll('_', ' ').trim().toLowerCase();
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

/// Headline metric tile used on dashboards and reports.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? caption;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = color ?? scheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconBadge(icon: icon, color: accent, size: 34),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays out [children] in a responsive grid: 1–4 columns depending on width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 220,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth).floor().clamp(
          1,
          4,
        );
        final effectiveColumns = columns == 1 && constraints.maxWidth >= 300
            ? 2
            : columns;
        final itemWidth =
            (constraints.maxWidth - spacing * (effectiveColumns - 1)) /
            effectiveColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

/// Titled card grouping related content.
class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md + 2,
                AppSpacing.sm,
                AppSpacing.md + 2,
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: scheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: textTheme.titleMedium),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          if (title != null) const Divider(),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Label/value row for detail panels.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? valueWidget;
  final IconData? icon;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWidget,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  valueWidget ??
                  SelectableText(
                    value,
                    textAlign: TextAlign.right,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uppercase caption separating groups of content.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Search field with a clear button; submits on enter.
class AppSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSubmitted;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Search…',
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  @override
  void initState() {
    super.initState();
    _hadText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
      _hadText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  // Only rebuild when the clear button's visibility flips.
  late bool _hadText;
  void _onChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hadText) setState(() => _hadText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: widget.controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  widget.controller.clear();
                  widget.onSubmitted('');
                },
              ),
      ),
    );
  }
}

/// Caps content width on very wide screens, centered horizontally.
///
/// Passes tight constraints (full available height when bounded) so wrapped
/// page bodies lay out exactly as they would without the wrapper.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppSpacing.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Same tree at every width so resizing never remounts the body.
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: constraints.maxWidth < maxWidth
                ? constraints.maxWidth
                : maxWidth,
            height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// Circular initial avatar.
class InitialAvatar extends StatelessWidget {
  final String? name;
  final double radius;
  const InitialAvatar({super.key, required this.name, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trimmed = name?.trim() ?? '';
    final initial = trimmed.isEmpty ? 'A' : trimmed[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.85,
        ),
      ),
    );
  }
}
