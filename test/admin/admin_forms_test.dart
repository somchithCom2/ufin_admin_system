import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_type_form.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/unit_form.dart';

/// Pumps a host and opens a form via [open]; returns the pending result.
Future<Future<bool>> _open(
  WidgetTester tester,
  Future<bool> Function(BuildContext) open, {
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  late BuildContext ctx;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );
  final result = open(ctx);
  await tester.pumpAndSettle();
  return result;
}

Finder _field(String label) => find.widgetWithText(TextFormField, label).first;

String _text(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(of: _field(label), matching: find.byType(EditableText)),
    )
    .controller
    .text;

void main() {
  group('Shop type form', () {
    testWidgets('shows inline errors and does not save when empty', (
      tester,
    ) async {
      var saves = 0;
      await _open(
        tester,
        (c) => showShopTypeForm(c, save: (_, _) async => saves++),
      );

      await tester.tap(find.text('Create shop type'));
      await tester.pumpAndSettle();

      expect(find.text('Code is required'), findsOneWidget);
      expect(find.text('English name is required'), findsOneWidget);
      expect(saves, 0);
    });

    testWidgets('create sends upper-cased code, both names and icon', (
      tester,
    ) async {
      CreateShopTypeRequest? sent;
      final result = await _open(
        tester,
        (c) => showShopTypeForm(c, save: (create, _) async => sent = create),
      );

      await tester.enterText(_field('Code'), 'coffee_shop');
      await tester.enterText(_field('English'), 'Coffee shop');
      await tester.enterText(_field('Lao (optional)'), 'ຮ້ານກາເຟ');
      await tester.tap(find.byTooltip('Local cafe'));
      await tester.tap(find.text('Create shop type'));
      await tester.pumpAndSettle();

      expect(await result, isTrue);
      expect(sent!.code, 'COFFEE_SHOP');
      expect(sent!.name, {'en': 'Coffee shop', 'lo': 'ຮ້ານກາເຟ'});
      expect(sent!.iconName, 'local_cafe');
      expect(sent!.description, isNull);
    });

    testWidgets('edit keeps Lao and other translations it does not show', (
      tester,
    ) async {
      UpdateShopTypeRequest? sent;
      final existing = ShopType.fromJson({
        'id': 3,
        'code': 'RESTAURANT',
        'name': {'en': 'Restaurant', 'lo': 'ຮ້ານອາຫານ', 'th': 'ร้านอาหาร'},
        'description': {'en': 'Food', 'lo': 'ອາຫານ'},
      });
      await _open(
        tester,
        (c) => showShopTypeForm(
          c,
          existing: existing,
          save: (_, update) async => sent = update,
        ),
      );

      // Lao is pre-filled, not blank.
      expect(_text(tester, 'Lao (optional)'), 'ຮ້ານອາຫານ');
      await tester.enterText(_field('English'), 'Restaurant & Bar');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(sent!.name, {
        'en': 'Restaurant & Bar',
        'lo': 'ຮ້ານອາຫານ',
        'th': 'ร้านอาหาร',
      });
      expect(sent!.description, {'en': 'Food', 'lo': 'ອາຫານ'});
    });

    testWidgets('failed save keeps the form open with typed input', (
      tester,
    ) async {
      final result = await _open(
        tester,
        (c) => showShopTypeForm(
          c,
          save: (_, _) async =>
              throw Exception('Code RESTAURANT already exists'),
        ),
      );
      await tester.enterText(_field('Code'), 'RESTAURANT');
      await tester.enterText(_field('English'), 'Restaurant');
      await tester.tap(find.text('Create shop type'));
      await tester.pumpAndSettle();

      expect(find.text('Code RESTAURANT already exists'), findsOneWidget);
      expect(find.text('New shop type'), findsOneWidget);
      expect(_text(tester, 'Code'), 'RESTAURANT');

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });
  });

  group('Unit form', () {
    testWidgets('requires category and sends all filled languages', (
      tester,
    ) async {
      CreateUnitRequest? sent;
      await _open(
        tester,
        (c) => showUnitForm(c, save: (create, _) async => sent = create),
      );
      await tester.enterText(_field('Code'), 'box');
      await tester.enterText(_field('Abbreviation'), 'bx');
      await tester.enterText(_field('English'), 'Box');
      await tester.tap(find.text('Create unit'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a category'), findsOneWidget);
      expect(sent, isNull);

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Piece').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('More languages'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Thai'), 'กล่อง');
      await tester.tap(find.text('Create unit'));
      await tester.pumpAndSettle();

      expect(sent!.category, 'piece');
      expect(sent!.name, {'en': 'Box', 'th': 'กล่อง'});
      expect(sent!.isActive, isTrue);
      expect(sent!.isDefault, isFalse);
    });

    testWidgets('edit keeps a legacy category', (tester) async {
      UpdateUnitRequest? sent;
      const unit = Unit(
        id: 1,
        code: 'dozen',
        name: {'en': 'Dozen'},
        abbreviation: 'dz',
        category: 'count',
        isActive: true,
        isDefault: false,
        sortOrder: 0,
      );
      await _open(
        tester,
        (c) => showUnitForm(
          c,
          existing: unit,
          save: (_, update) async => sent = update,
        ),
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(sent!.category, 'count');
    });
  });

  group('App release form', () {
    testWidgets('validates version code and URL', (tester) async {
      CreateAppReleaseRequest? sent;
      await _open(
        tester,
        (c) => showAppReleaseForm(
          c,
          initialPlatform: 'ios',
          save: (create, _) async => sent = create,
        ),
      );
      await tester.enterText(_field('Version name'), '1.2.6');
      await tester.enterText(_field('Title'), 'Bug fixes');
      await tester.enterText(_field("What's new"), 'Fixed printing');
      await tester.enterText(_field('Download URL'), 'apps.apple.com/ufin');
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a positive build number'), findsOneWidget);
      expect(find.text('Enter a full http(s) link'), findsOneWidget);

      await tester.enterText(_field('Version code'), '13');
      await tester.enterText(
        _field('Download URL'),
        'https://apps.apple.com/ufin',
      );
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();

      expect(sent!.platform, 'ios');
      expect(sent!.versionCode, 13);
      expect(sent!.isMandatory, isFalse);
    });

    testWidgets('opens as a bottom sheet on phones without overflow', (
      tester,
    ) async {
      await _open(
        tester,
        (c) => showAppReleaseForm(c, save: (_, _) async {}),
        size: const Size(390, 844),
      );
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
