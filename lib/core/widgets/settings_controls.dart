import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/settings/app_settings.dart';
import 'package:ufin_admin_system/core/widgets/app_ui.dart';

extension ThemeModeX on ThemeMode {
  IconData get icon => switch (this) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  Tr get title => switch (this) {
    ThemeMode.system => SettingsText.themeSystem,
    ThemeMode.light => SettingsText.themeLight,
    ThemeMode.dark => SettingsText.themeDark,
  };

  /// system → light → dark → system.
  ThemeMode get next => switch (this) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  };
}

/// Flips between light and dark from whatever is on screen now, resolving
/// "system" against the current brightness so one press always changes it.
void toggleBrightness(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  ref
      .read(appSettingsProvider.notifier)
      .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
}

void toggleLanguage(WidgetRef ref) {
  final notifier = ref.read(appSettingsProvider.notifier);
  final current = ref.read(appSettingsProvider).language;
  notifier.setLanguage(
    current == AppLanguage.en ? AppLanguage.lo : AppLanguage.en,
  );
}

/// Icon button cycling system → light → dark.
class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appSettingsProvider.select((s) => s.themeMode));
    return IconButton(
      tooltip:
          '${context.tr(SettingsText.appearance)}: ${context.tr(mode.title)}',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(mode.icon, key: ValueKey(mode), size: 20),
      ),
      onPressed: () =>
          ref.read(appSettingsProvider.notifier).setThemeMode(mode.next),
    );
  }
}

/// Compact two-option language switch: `EN | ລາວ`.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appSettingsProvider.select((s) => s.language));
    final scheme = context.colors;
    return Semantics(
      label: context.tr(SettingsText.language),
      child: Container(
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final l in AppLanguage.values)
              _LanguageChip(
                label: l == AppLanguage.en ? 'EN' : l.nativeName,
                selected: l == language,
                onTap: () =>
                    ref.read(appSettingsProvider.notifier).setLanguage(l),
              ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? scheme.surface : Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm - 2),
          side: selected
              ? BorderSide(color: scheme.outlineVariant)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: selected ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm - 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Appearance and language settings, laid out for a dialog or a sheet.
class AppSettingsPanel extends ConsumerWidget {
  const AppSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final text = context.text;
    final scheme = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.tr(SettingsText.appearance), style: text.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: [
            for (final m in ThemeMode.values)
              ButtonSegment(
                value: m,
                icon: Icon(m.icon, size: 18),
                label: Text(context.tr(m.title)),
              ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (s) => notifier.setThemeMode(s.first),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          context.tr(SettingsText.appearanceHint),
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(context.tr(SettingsText.language), style: text.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final l in AppLanguage.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _LanguageOption(
              language: l,
              selected: l == settings.language,
              onTap: () => notifier.setLanguage(l),
            ),
          ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  language.locale.languageCode.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  language.nativeName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens settings as a bottom sheet on phones and a dialog elsewhere.
Future<void> showAppSettings(BuildContext context) {
  final isPhone =
      MediaQuery.sizeOf(context).width < AppSpacing.tabletBreakpoint;
  if (isPhone) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ctx.tr(SettingsText.settings), style: ctx.text.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            const AppSettingsPanel(),
          ],
        ),
      ),
    );
  }
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(ctx.tr(SettingsText.settings))),
          IconButton(
            tooltip: ctx.tr(CommonText.close),
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
      content: const SizedBox(width: 400, child: AppSettingsPanel()),
    ),
  );
}
