import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:ufin_admin_system/l10n/tr.dart';

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
    success: Color(0xFF16A34A),
    onSuccessContainer: Color(0xFF14532D),
    successContainer: Color(0xFFEAF8EF),
    warning: Color(0xFFD97706),
    onWarningContainer: Color(0xFF78350F),
    warningContainer: Color(0xFFFEF5E4),
    info: Color(0xFF0284C7),
    onInfoContainer: Color(0xFF0C4A6E),
    infoContainer: Color(0xFFE8F4FB),
    neutral: Color(0xFF71717A),
    neutralContainer: Color(0xFFF1F1F3),
  );

  static const dark = StatusColors(
    success: Color(0xFF4ADE80),
    onSuccessContainer: Color(0xFFBBF7D0),
    successContainer: Color(0xFF10261A),
    warning: Color(0xFFFBBF24),
    onWarningContainer: Color(0xFFFDE68A),
    warningContainer: Color(0xFF2C2108),
    info: Color(0xFF38BDF8),
    onInfoContainer: Color(0xFFBAE6FD),
    infoContainer: Color(0xFF0B2432),
    neutral: Color(0xFFA1A1AA),
    neutralContainer: Color(0xFF202027),
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
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return StatusColors(
      success: l(success, other.success),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      successContainer: l(successContainer, other.successContainer),
      warning: l(warning, other.warning),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      warningContainer: l(warningContainer, other.warningContainer),
      info: l(info, other.info),
      onInfoContainer: l(onInfoContainer, other.onInfoContainer),
      infoContainer: l(infoContainer, other.infoContainer),
      neutral: l(neutral, other.neutral),
      neutralContainer: l(neutralContainer, other.neutralContainer),
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
  static const double radiusLg = 18;

  /// Width at which the sidebar replaces the bottom navigation bar.
  static const double tabletBreakpoint = 800;

  /// Width at which the sidebar can show labels instead of icons only.
  static const double desktopBreakpoint = 1100;

  /// Max width for page content on very wide screens.
  static const double maxContentWidth = 1280;

  static const double sidebarWidth = 252;
  static const double railWidth = 72;
}

/// Raw palette. Every color in the UI resolves to one of these through the
/// [ColorScheme] or [StatusColors]; pages never hard-code hex values.
abstract final class _Palette {
  // Brand: a single indigo accent on neutral zinc surfaces.
  static const brand = Color(0xFF4F46E5);
  static const brandDark = Color(0xFF8B8DF8);

  static const light = (
    background: Color(0xFFF6F6F7),
    surface: Color(0xFFFFFFFF),
    containerLow: Color(0xFFFAFAFB),
    container: Color(0xFFF3F3F5),
    containerHigh: Color(0xFFECECEF),
    containerHighest: Color(0xFFE4E4E8),
    onSurface: Color(0xFF18181B),
    onSurfaceVariant: Color(0xFF6B6B74),
    outline: Color(0xFFD4D4DA),
    outlineVariant: Color(0xFFE8E8EC),
    primaryContainer: Color(0xFFEEEEFF),
    onPrimaryContainer: Color(0xFF2E2A84),
    error: Color(0xFFDC2626),
    errorContainer: Color(0xFFFDEEEE),
    onErrorContainer: Color(0xFF7F1D1D),
    inverse: Color(0xFF1F1F23),
    onInverse: Color(0xFFF7F7F8),
  );

  static const dark = (
    background: Color(0xFF0C0C0F),
    surface: Color(0xFF141418),
    containerLow: Color(0xFF17171C),
    container: Color(0xFF1C1C22),
    containerHigh: Color(0xFF24242B),
    containerHighest: Color(0xFF2D2D35),
    onSurface: Color(0xFFECECEF),
    onSurfaceVariant: Color(0xFFA1A1AA),
    outline: Color(0xFF3F3F48),
    outlineVariant: Color(0xFF26262D),
    primaryContainer: Color(0xFF26245A),
    onPrimaryContainer: Color(0xFFE0E1FF),
    error: Color(0xFFF87171),
    errorContainer: Color(0xFF341517),
    onErrorContainer: Color(0xFFFECACA),
    inverse: Color(0xFFECECEF),
    onInverse: Color(0xFF141418),
  );
}

class AppTheme {
  static const seedColor = _Palette.brand;

  /// Bundled Lao face; used as a fallback so Latin text keeps the platform
  /// font while Lao glyphs (including shop names in English mode) render
  /// with consistent metrics on every OS.
  static const laoFontFamily = 'NotoSansLao';

  static final ThemeData lightTheme = _build(Brightness.light, AppLanguage.en);
  static final ThemeData darkTheme = _build(Brightness.dark, AppLanguage.en);

  static final Map<(Brightness, AppLanguage), ThemeData> _cache = {
    (Brightness.light, AppLanguage.en): lightTheme,
    (Brightness.dark, AppLanguage.en): darkTheme,
  };

  /// Cached per brightness and language: the root rebuilds on every auth
  /// and settings change, and building ThemeData is not free.
  static ThemeData of(Brightness brightness, AppLanguage language) => _cache
      .putIfAbsent((brightness, language), () => _build(brightness, language));

  static ThemeData _build(Brightness brightness, AppLanguage language) {
    final isDark = brightness == Brightness.dark;
    final p = isDark ? _Palette.dark : _Palette.light;
    final primary = isDark ? _Palette.brandDark : _Palette.brand;

    final scheme =
        ColorScheme.fromSeed(
          seedColor: _Palette.brand,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: isDark ? const Color(0xFF15134A) : Colors.white,
          primaryContainer: p.primaryContainer,
          onPrimaryContainer: p.onPrimaryContainer,
          secondary: p.onSurfaceVariant,
          onSecondary: p.surface,
          secondaryContainer: p.containerHigh,
          onSecondaryContainer: p.onSurface,
          surface: p.surface,
          onSurface: p.onSurface,
          onSurfaceVariant: p.onSurfaceVariant,
          surfaceContainerLowest: p.background,
          surfaceContainerLow: p.containerLow,
          surfaceContainer: p.container,
          surfaceContainerHigh: p.containerHigh,
          surfaceContainerHighest: p.containerHighest,
          surfaceTint: Colors.transparent,
          outline: p.outline,
          outlineVariant: p.outlineVariant,
          error: p.error,
          onError: isDark ? const Color(0xFF2B0B0B) : Colors.white,
          errorContainer: p.errorContainer,
          onErrorContainer: p.onErrorContainer,
          inverseSurface: p.inverse,
          onInverseSurface: p.onInverse,
          inversePrimary: isDark ? _Palette.brand : _Palette.brandDark,
          shadow: Colors.black,
          scrim: Colors.black,
        );

    final radiusSm = BorderRadius.circular(AppSpacing.radiusSm);
    final radiusMd = BorderRadius.circular(AppSpacing.radiusMd);
    final radiusLg = BorderRadius.circular(AppSpacing.radiusLg);
    final hairline = BorderSide(color: scheme.outlineVariant);
    final textTheme = _textTheme(brightness, language, scheme);

    // AppBar blends into the page and lifts onto a surface once content
    // scrolls under it: chrome only appears when it carries information.
    final appBarColor = WidgetStateColor.resolveWith(
      (states) => states.contains(WidgetState.scrolledUnder)
          ? scheme.surface
          : p.background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamilyFallback: const [laoFontFamily],
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkRipple.splashFactory,
      hoverColor: scheme.onSurface.withValues(alpha: 0.04),
      focusColor: scheme.primary.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 60,
        titleSpacing: AppSpacing.lg,
        backgroundColor: appBarColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 22),
        actionsIconTheme: IconThemeData(
          color: scheme.onSurfaceVariant,
          size: 22,
        ),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radiusMd, side: hairline),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusSm),
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minVerticalPadding: 10,
        titleTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.container : p.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radiusSm,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
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
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surface,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 1,
        highlightElevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        checkmarkColor: scheme.onPrimaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusSm),
          side: BorderSide(color: scheme.outline),
          backgroundColor: scheme.surface,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          textStyle: textTheme.labelMedium,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: scheme.outline, width: 1.5),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusLg, side: hairline),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        dragHandleSize: const Size(36, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg + 4),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: radiusMd, side: hairline),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(6),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radiusMd, side: hairline),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: p.inverse,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.onInverse),
        actionTextColor: isDark ? _Palette.brand : _Palette.brandDark,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: p.inverse,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: p.onInverse),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: scheme.outlineVariant,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 22,
            color: s.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => textTheme.labelSmall?.copyWith(
            fontSize: 11.5,
            letterSpacing: 0,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: Colors.transparent,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(3),
        thumbColor: WidgetStatePropertyAll(
          scheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
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
      badgeTheme: BadgeThemeData(
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      ),
    );
  }

  static TextTheme _textTheme(
    Brightness brightness,
    AppLanguage language,
    ColorScheme scheme,
  ) {
    // Lao stacks vowels and tone marks above and below the baseline; extra
    // line height keeps multi-line Lao from colliding. Latin keeps the
    // tighter platform default.
    final isLao = language == AppLanguage.lo;
    final body = isLao ? 1.55 : null;
    final title = isLao ? 1.45 : null;
    // Negative tracking suits Latin display type but breaks Lao clusters.
    double track(double latin) => isLao ? 0 : latin;

    final base = ThemeData(brightness: brightness).textTheme;
    return base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: track(-0.6),
            height: title,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: track(-0.5),
            height: title,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: track(-0.3),
            height: title,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: track(-0.2),
            height: title,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: track(-0.1),
            height: title,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: title,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 15,
            letterSpacing: 0,
            height: body,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 14,
            letterSpacing: 0,
            height: body,
          ),
          bodySmall: base.bodySmall?.copyWith(
            fontSize: 12.5,
            letterSpacing: 0,
            height: body,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: track(0.4),
          ),
        )
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
          fontFamilyFallback: const [laoFontFamily],
        );
  }
}
