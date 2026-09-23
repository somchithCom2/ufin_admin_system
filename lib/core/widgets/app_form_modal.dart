import 'package:flutter/material.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';

/// Opens a create/edit form: a centered dialog on wide screens, a tall
/// bottom sheet on phones. [builder] should return an [AppFormModal].
Future<T?> showAppFormModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final wide = MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  if (wide) {
    return showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          child: builder(ctx),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    // Unsaved input shouldn't vanish on a stray swipe.
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) =>
        FractionallySizedBox(heightFactor: 0.94, child: builder(ctx)),
  );
}

/// Standard layout for create/edit forms: header, scrollable grouped body,
/// pinned footer with Cancel + primary action and an inline error banner.
class AppFormModal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String submitLabel;
  final VoidCallback onSubmit;
  final bool saving;
  final String? error;

  const AppFormModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.formKey,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
    this.saving = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final textTheme = context.text;
    // Dialogs already lift above the keyboard; bottom sheets need it here.
    final inSheet = ModalRoute.of(context) is ModalBottomSheetRoute;
    final keyboard = inSheet ? MediaQuery.viewInsetsOf(context).bottom : 0.0;

    return PopScope(
      canPop: !saving,
      child: Material(
        color: scheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
              child: Row(
                children: [
                  IconBadge(icon: icon, color: scheme.primary, size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: textTheme.titleLarge),
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
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: saving ? null : () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Body
            Flexible(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: AbsorbPointer(
                    absorbing: saving,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            const Divider(),
            AnimatedPadding(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.only(bottom: keyboard),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null) ...[
                      _ErrorBanner(message: error!),
                      const SizedBox(height: 12),
                    ],
                    LayoutBuilder(
                      builder: (context, c) {
                        final cancel = OutlinedButton(
                          onPressed: saving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        );
                        final submit = FilledButton(
                          onPressed: saving ? null : onSubmit,
                          child: saving
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Flexible(
                                      child: Text(
                                        'Saving…',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  submitLabel,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        );
                        // Phones: equal-width buttons that always fit.
                        if (c.maxWidth < 420) {
                          return Row(
                            children: [
                              Expanded(child: cancel),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: submit),
                            ],
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            cancel,
                            const SizedBox(width: 12),
                            Flexible(child: submit),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titled group of fields inside an [AppFormModal].
class FormSection extends StatelessWidget {
  final String title;
  final String? hint;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    this.hint,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: context.text.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint!,
              style: context.text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            child,
          ],
        ],
      ),
    );
  }
}

/// Places fields side by side when there is room, stacked otherwise.
class FormRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flex;

  const FormRow({super.key, required this.children, this.flex});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 440) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const SizedBox(height: 14),
                child,
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(flex: flex?[i] ?? 1, child: child),
            ],
          ],
        );
      },
    );
  }
}

/// Bordered on/off row with a title and explanation, for form settings.
class FormSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const FormSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        side: BorderSide(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.only(left: 14, right: 8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
      ),
    );
  }
}

/// Validator helpers shared by admin forms.
abstract final class FormValidators {
  static FormFieldValidator<String> required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null;

  static String? optionalInt(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    return int.tryParse(t) == null ? 'Enter a whole number' : null;
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
