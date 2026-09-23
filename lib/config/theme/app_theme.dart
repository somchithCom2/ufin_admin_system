import 'package:flutter/material.dart';

/// Semantic status colors that adapt to light/dark mode.
///
/// Access via `context.status` (see [StatusColorsX]).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color success;
  final Color onSuccessContainer;
  final Color successContainer;
  final Color warning;
  final Color onWarningContainer;
  final Color warningContainer;
  final Color info;
  final Color onInfoContainer;
  final Color infoContainer;
  final Color neutral;
  final Color neutralContainer;

  const StatusColors({
    required this.success,
    required this.onSuccessContainer,
    required this.successContainer,
    required this.warning,
    required this.onWarningContainer,
    required this.warningContainer,
    required this.info,
    required this.onInfoContainer,
    required this.infoContainer,
    required this.neutral,
    required this.neutralContainer,
  });

  static const light = StatusColors(
    success: Color(0xFF15803D),
    onSuccessContainer: Color(0xFF14532D),
    successContainer: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    onWarningContainer: Color(0xFF78350F),
    warningContainer: Color(0xFFFEF3C7),
    info: Color(0xFF1D4ED8),
    onInfoContainer: Color(0xFF1E3A8A),
    infoContainer: Color(0xFFDBEAFE),
    neutral: Color(0xFF64748B),
    neutralContainer: Color(0xFFF1F5F9),
  );

  static const dark = StatusColors(
    success: Color(0xFF4ADE80),
    onSuccessContainer: Color(0xFFBBF7D0),
    successContainer: Color(0xFF14532D),
    warning: Color(0xFFFBBF24),
    onWarningContainer: Color(0xFFFDE68A),
    warningContainer: Color(0xFF78350F),
    info: Color(0xFF60A5FA),
    onInfoContainer: Color(0xFFBFDBFE),
    infoContainer: Color(0xFF1E3A8A),
    neutral: Color(0xFF94A3B8),
    neutralContainer: Color(0xFF1E293B),
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? onSuccessContainer,
    Color? successContainer,
    Color? warning,
    Color? onWarningContainer,
    Color? warningContainer,
    Color? info,
    Color? onInfoContainer,
    Color? infoContainer,
    Color? neutral,
    Color? neutralContainer,
  }) {
    return StatusColors(
      success: success ?? this.success,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      infoContainer: infoContainer ?? this.infoContainer,
      neutral: neutral ?? this.neutral,
      neutralContainer: neutralContainer ?? this.neutralContainer,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      neutralContainer: Color.lerp(
        neutralContainer,
        other.neutralContainer,
        t,
      )!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get status =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}

/// Spacing, radius and breakpoint tokens shared across the admin UI.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;

  /// Width at which the persistent sidebar replaces the drawer.
  static const double tabletBreakpoint = 800;

  /// Width at which the sidebar shows labels instead of icons only.
  static const double desktopBreakpoint = 1100;

  /// Max width for page content on very wide screens.
  static const double maxContentWidth = 1280;
}

class AppTheme {
  static const seedColor = Color(0xFF2563EB);

  // Built once: the root widget rebuilds on every auth state change.
  static final ThemeData lightTheme = _build(Brightness.light);
  static final ThemeData darkTheme = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final seeded = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    // Neutral slate surfaces read cleaner than the tinted M3 defaults.
    final scheme = seeded.copyWith(
      primary: isDark ? const Color(0xFF7AA2FF) : seedColor,
      surface: isDark ? const Color(0xFF0F172A) : Colors.white,
      surfaceContainerLowest: isDark
          ? const Color(0xFF0B1120)
          : const Color(0xFFF6F7FB),
      surfaceContainerLow: isDark
          ? const Color(0xFF131C31)
          : const Color(0xFFF8FAFC),
      surfaceContainer: isDark
          ? const Color(0xFF172036)
          : const Color(0xFFF1F5F9),
      surfaceContainerHigh: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFE9EEF5),
      surfaceContainerHighest: isDark
          ? const Color(0xFF273449)
          : const Color(0xFFE2E8F0),
      onSurface: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
      onSurfaceVariant: isDark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B),
      outline: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      outlineVariant: isDark
          ? const Color(0xFF1F2A3D)
          : const Color(0xFFE5E9F0),
    );

    final radiusSm = BorderRadius.circular(AppSpacing.radiusSm);
    final radiusMd = BorderRadius.circular(AppSpacing.radiusMd);
    final radiusLg = BorderRadius.circular(AppSpacing.radiusLg);
    final outlineSide = BorderSide(color: scheme.outlineVariant);

    // Merge onto base styles so font family/metrics are preserved.
    final base = ThemeData(brightness: brightness).textTheme;
    final textTheme = base
        .copyWith(
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      visualDensity: VisualDensity.standard,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        shape: Border(bottom: outlineSide),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMd,
          side: outlineSide,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        iconColor: scheme.onSurfaceVariant,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainer : scheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 40),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg + 4),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 3,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMd,
          side: outlineSide,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          fontSize: 12,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: scheme.outlineVariant,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: textTheme.labelLarge,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: scheme.onSurfaceVariant,
      ),
    );
  }
}
