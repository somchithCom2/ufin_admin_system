import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIcons catalog', () {
    test('names are unique and point into assets/icons', () {
      final assets = AppIcons.values.map((i) => i.asset).toList();
      expect(assets.toSet().length, assets.length);
      for (final asset in assets) {
        expect(asset, startsWith('assets/icons/'));
        expect(asset, endsWith('.svg'));
      }
    });

    test('every asset file is in the catalog and vice versa', () {
      final onDisk = Directory('assets/icons')
          .listSync()
          .whereType<File>()
          .map((f) => f.path.replaceAll(r'\', '/'))
          .where((p) => p.endsWith('.svg'))
          .toSet();
      final declared = AppIcons.values.map((i) => i.asset).toSet();
      expect(declared.difference(onDisk), isEmpty, reason: 'missing files');
      expect(onDisk.difference(declared), isEmpty, reason: 'orphan files');
    });

    test('every SVG is a single-colour stroke icon on the shared grid', () {
      for (final icon in AppIcons.values) {
        final svgText = File(icon.asset).readAsStringSync();
        expect(
          svgText,
          contains('viewBox="1.125 1.125 21.75 21.75"'),
          reason: icon.asset,
        );
        expect(svgText, contains('stroke-width="1.75"'), reason: icon.asset);
        expect(svgText, contains('fill="none"'), reason: icon.asset);
      }
    });

    test('every SVG parses through the bundle', () async {
      for (final icon in AppIcons.values) {
        final bytes = await SvgAssetLoader(icon.asset).loadBytes(null);
        expect(bytes.lengthInBytes, greaterThan(0), reason: icon.asset);
      }
    });

    test('precacheAppIcons completes without reporting errors', () async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      try {
        await precacheAppIcons();
      } finally {
        FlutterError.onError = previous;
      }
      expect(errors, isEmpty);
    });

    test('lib/ no longer draws Material Icons', () {
      final offenders = <String>[];
      final pattern = RegExp(r'(?<![\w])Icons\.\w+');
      for (final file in Directory('lib').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (pattern.hasMatch(lines[i])) {
            offenders.add('${file.path}:${i + 1}');
          }
        }
      }
      expect(offenders, isEmpty, reason: 'use AppIcons instead of Icons');
    });
  });

  group('AppIcon', () {
    Widget host(Widget child, {IconThemeData? theme}) => Directionality(
      textDirection: TextDirection.ltr,
      child: IconTheme(
        data: theme ?? const IconThemeData(),
        child: Center(child: child),
      ),
    );

    SvgPicture picture(WidgetTester tester) =>
        tester.widget<SvgPicture>(find.byType(SvgPicture));

    testWidgets('takes size and colour from IconTheme like Icon', (
      tester,
    ) async {
      const color = Color(0xFF3355AA);
      await tester.pumpWidget(
        host(
          const AppIcon(AppIcons.search),
          theme: const IconThemeData(size: 30, color: color),
        ),
      );
      expect(tester.getSize(find.byType(AppIcon)), const Size.square(30));
      expect(picture(tester).width, 30 * AppIcon.glyphScale);
      expect(
        picture(tester).colorFilter,
        const ColorFilter.mode(color, BlendMode.srcIn),
      );
    });

    testWidgets('explicit size and colour win over the theme', (tester) async {
      const color = Color(0xFFAA0000);
      await tester.pumpWidget(
        host(
          const AppIcon(AppIcons.search, size: 18, color: color),
          theme: const IconThemeData(size: 30, color: Color(0xFF000000)),
        ),
      );
      expect(tester.getSize(find.byType(AppIcon)), const Size.square(18));
      expect(
        picture(tester).colorFilter,
        const ColorFilter.mode(color, BlendMode.srcIn),
      );
    });

    testWidgets('applies IconTheme opacity, as disabled buttons set it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const AppIcon(AppIcons.search),
          theme: const IconThemeData(color: Color(0xFF000000), opacity: 0.5),
        ),
      );
      final filter = picture(tester).colorFilter;
      expect(
        filter,
        ColorFilter.mode(
          const Color(0xFF000000).withValues(alpha: 0.5),
          BlendMode.srcIn,
        ),
      );
    });

    testWidgets('a null icon keeps its slot and draws nothing', (tester) async {
      await tester.pumpWidget(host(const AppIcon(null, size: 22)));
      expect(tester.getSize(find.byType(AppIcon)), const Size.square(22));
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('semantic label is exposed only when given', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const AppIcon(AppIcons.search, semanticLabel: 'Search')),
      );
      expect(find.bySemanticsLabel('Search'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('IconButton tints it with its foreground colour', (
      tester,
    ) async {
      const fg = Color(0xFF00AA55);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              color: fg,
              onPressed: () {},
              icon: const AppIcon(AppIcons.edit),
            ),
          ),
        ),
      );
      expect(
        picture(tester).colorFilter,
        const ColorFilter.mode(fg, BlendMode.srcIn),
      );
    });
  });
}
