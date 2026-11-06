import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';

/// `find.byAppIcon(AppIcons.moreVertical)`: the [AppIcon] counterpart of
/// `find.byIcon`.
extension AppIconFinders on CommonFinders {
  Finder byAppIcon(AppIconData icon, {bool skipOffstage = true}) =>
      byWidgetPredicate(
        (widget) => widget is AppIcon && widget.icon == icon,
        description: 'AppIcon(${icon.asset})',
        skipOffstage: skipOffstage,
      );
}
