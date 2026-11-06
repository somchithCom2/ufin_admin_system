import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics_compat.dart'
    show RenderingStrategy;

part 'app_icons.g.dart';

/// A line icon drawn from an SVG asset. The typed counterpart of [IconData]:
/// widgets take an [AppIconData], never a bare asset path, so a typo is a
/// compile error and every icon comes from [AppIcons].
@immutable
final class AppIconData {
  final String asset;
  const AppIconData(this.asset);

  @override
  bool operator ==(Object other) =>
      other is AppIconData && other.asset == asset;

  @override
  int get hashCode => asset.hashCode;

  @override
  String toString() => 'AppIconData($asset)';
}

/// Drop-in replacement for [Icon] that draws an [AppIconData].
///
/// Size and colour fall back to the ambient [IconTheme] exactly as [Icon]
/// does, so buttons, nav bars, list tiles, chips and inputs still tint it for
/// hover, selected and disabled states.
///
/// [size] is the layout slot, as for [Icon]. The SVGs fill their viewBox
/// edge to edge while Material glyphs sit inside a padded 24-unit grid, so the
/// glyph is drawn at [glyphScale] of the slot: a 24px slot draws a 20px glyph,
/// the same visual weight as a Material icon, with an identical layout.
/// A null [icon] keeps the empty slot, as `Icon(null)` does.
class AppIcon extends StatelessWidget {
  final AppIconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  static const double glyphScale = 20 / 24;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final box = size ?? iconTheme.size ?? 24.0;
    var tint = color ?? iconTheme.color;
    final opacity = iconTheme.opacity ?? 1.0;
    if (tint != null && opacity != 1.0) {
      tint = tint.withValues(alpha: tint.a * opacity);
    }
    final glyph = box * glyphScale;
    final icon = this.icon;
    if (icon == null) return SizedBox.square(dimension: box);

    Widget result = SizedBox.square(
      dimension: box,
      child: Center(
        child: SvgPicture.asset(
          icon.asset,
          width: glyph,
          height: glyph,
          colorFilter: tint == null
              ? null
              : ColorFilter.mode(tint, BlendMode.srcIn),
          excludeFromSemantics: true,
          // Rasterised once per size and cached: long lists of rows with
          // icons stay cheap to repaint on low-end devices.
          renderingStrategy: RenderingStrategy.raster,
        ),
      ),
    );
    if (semanticLabel != null) {
      result = Semantics(label: semanticLabel, child: result);
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('icon', icon?.asset))
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null));
  }
}

/// Decodes every icon into flutter_svg's cache so screens never paint an
/// empty slot while an SVG loads. Safe to call without awaiting; a broken
/// asset is reported, never thrown, because a missing glyph must not stop
/// the console from starting.
Future<void> precacheAppIcons() async {
  await Future.wait(
    AppIcons.values.map((icon) async {
      final loader = SvgAssetLoader(icon.asset);
      try {
        await svg.cache.putIfAbsent(
          loader.cacheKey(null),
          () => loader.loadBytes(null),
        );
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'app_icons',
            context: ErrorDescription('precaching ${icon.asset}'),
          ),
        );
      }
    }),
  );
}
