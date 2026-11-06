import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/app_release_detail_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/app_releases_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/app_release_form.dart';

AppRelease _release({
  int id = 1,
  String platform = 'android',
  String name = '2.2.0',
  int code = 20,
  bool published = true,
  String url = 'https://play.google.com/store/apps/details?id=com.ufin.pos',
  DateTime? at,
}) => AppRelease(
  id: id,
  versionName: name,
  versionCode: code,
  platform: platform,
  title: 'Bookings and SKUs',
  changelog: '• Automatic SKU numbers\n• Table bookings lock\n• Faster sync',
  isMandatory: false,
  isPublished: published,
  downloadUrl: url,
  releasedAt: at ?? DateTime(2026, 11, 6),
  createdAt: DateTime(2026, 11, 6),
  updatedAt: DateTime(2026, 11, 6),
);

final _releases = [
  _release(),
  _release(id: 2, name: '2.1.1', code: 19, at: DateTime(2026, 10, 1)),
  _release(
    id: 3,
    platform: 'ios',
    name: '2.1.1',
    code: 19,
    url: 'https://apps.apple.com/app/ufin-pos/id1',
    at: DateTime(2026, 10, 2),
  ),
];

class _Repository implements AdminRepository {
  List<AppRelease> releases = [..._releases];
  final List<CreateAppReleaseRequest> created = [];
  final List<int> published = [];

  @override
  Future<List<AppRelease>> getAppReleases() async => releases;

  @override
  Future<AppRelease> createAppRelease(CreateAppReleaseRequest r) async {
    created.add(r);
    final made = _release(
      id: 99,
      platform: r.platform,
      name: r.versionName,
      code: r.versionCode,
      published: false,
      url: r.downloadUrl,
    );
    releases = [...releases, made];
    return made;
  }

  @override
  Future<AppRelease> publishAppRelease(int id) async {
    published.add(id);
    final r = releases.firstWhere((r) => r.id == id);
    return AppRelease.fromJson({...r.toJson(), 'is_published': true});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Finder _field(String label) => find.widgetWithText(TextFormField, label).first;

String _text(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(of: _field(label), matching: find.byType(EditableText)),
    )
    .controller
    .text;

void main() {
  group('version helpers', () {
    test('the next version bumps the last number', () {
      expect(nextVersionName('2.2.0'), '2.2.1');
      expect(nextVersionName('1.9'), '1.10');
      expect(nextVersionName('2.2.0+20'), '2.2.1');
      expect(nextVersionName('beta'), 'beta');
    });

    test('the next build is per platform', () {
      expect(nextVersionCode(_releases, 'android'), 21);
      expect(nextVersionCode(_releases, 'ios'), 20);
      expect(nextVersionCode(_releases, 'windows'), isNull);
    });
  });

  late _Repository repository;
  setUp(() => repository = _Repository());

  Future<void> pump(WidgetTester tester, Widget home, {Size? size}) async {
    tester.view.physicalSize = size ?? const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.lightTheme, home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens the form on a button, so it gets a real route to pop.
  Future<void> openForm(
    WidgetTester tester,
    Future<bool> Function(BuildContext) open,
  ) async {
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (c) =>
              TextButton(onPressed: () => open(c), child: const Text('open')),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('release form', () {
    testWidgets('a new version keeps the notes and moves the version on', (
      tester,
    ) async {
      CreateAppReleaseRequest? sent;
      await openForm(
        tester,
        (c) => showAppReleaseForm(
          c,
          template: _releases.first,
          releases: _releases,
          save: (create, _) async => sent = create,
        ),
      );

      expect(find.text('New version from v2.2.0'), findsOneWidget);
      expect(_text(tester, 'Version name'), '2.2.1');
      expect(_text(tester, 'Version code'), '21');
      expect(_text(tester, 'Title'), 'Bookings and SKUs');
      expect(_text(tester, "What's new"), contains('Faster sync'));

      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();
      expect(sent!.platform, 'android');
      expect(sent!.versionName, '2.2.1');
      expect(sent!.versionCode, 21);
      expect(sent!.changelog, _releases.first.changelog);
    });

    testWidgets('a version a platform already has is caught before saving', (
      tester,
    ) async {
      var saves = 0;
      await openForm(
        tester,
        (c) => showAppReleaseForm(
          c,
          template: _releases.first,
          releases: _releases,
          save: (_, _) async => saves++,
        ),
      );
      await tester.enterText(_field('Version name'), '2.2.0');
      await tester.enterText(_field('Version code'), '20');
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();

      expect(find.text('Android already has v2.2.0'), findsOneWidget);
      expect(find.text('Android build 20 is v2.2.0'), findsOneWidget);
      expect(saves, 0);
    });

    testWidgets('copying to another platform keeps the version and uses '
        "that platform's store link", (tester) async {
      await openForm(
        tester,
        (c) => showAppReleaseForm(
          c,
          template: _releases.first,
          copy: ReleaseCopy.otherPlatform,
          releases: _releases,
          save: (_, _) async {},
        ),
      );

      final ios = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'iOS'),
      );
      expect(ios.selected, isTrue);
      expect(_text(tester, 'Version name'), '2.2.0');
      expect(_text(tester, 'Version code'), '20');
      expect(
        _text(tester, 'Download URL'),
        'https://apps.apple.com/app/ufin-pos/id1',
      );
      expect(find.text('From the newest iOS release'), findsOneWidget);
    });

    testWidgets('editing shows the version but does not offer to change it', (
      tester,
    ) async {
      await openForm(
        tester,
        (c) => showAppReleaseForm(
          c,
          existing: _releases.first,
          save: (_, _) async {},
        ),
      );

      expect(find.text('Android · v2.2.0 · build 20'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Version name'), findsNothing);
      expect(_text(tester, "What's new"), contains('Table bookings lock'));
    });
  });

  group('detail page', () {
    testWidgets('shows the whole changelog and copies it', (tester) async {
      String? clipboard;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(
        tester,
        AppReleaseDetailPage(release: _releases.first),
        size: const Size(390, 844),
      );

      expect(find.textContaining('Faster sync'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Copy'));
      await tester.pump();
      expect(clipboard, 'Bookings and SKUs\n\n${_releases.first.changelog}');
      expect(tester.takeException(), isNull);
    });

    testWidgets('publishing a draft shows it live', (tester) async {
      final draft = _release(id: 2, name: '2.1.1', code: 19, published: false);
      await pump(tester, AppReleaseDetailPage(release: draft));

      await tester.tap(find.widgetWithText(FilledButton, 'Publish'));
      await tester.pumpAndSettle();
      // The confirm dialog.
      await tester.tap(find.widgetWithText(FilledButton, 'Publish').last);
      await tester.pumpAndSettle();

      expect(repository.published, [2]);
      expect(find.widgetWithText(OutlinedButton, 'Unpublish'), findsOneWidget);
    });
  });

  group('list', () {
    testWidgets('filters by platform and opens a release', (tester) async {
      await pump(tester, const AppReleasesPage(), size: const Size(390, 844));

      // One Platform chip; the per-platform counts live in its menu.
      await tester.tap(find.widgetWithText(FilterButton, 'Platform'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MenuItemButton, 'All · 3'), findsOneWidget);
      await tester.tap(find.widgetWithText(MenuItemButton, 'iOS · 1'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilterButton, 'iOS · 1'), findsOneWidget);
      expect(find.text('v2.2.0'), findsNothing);
      expect(find.text('v2.1.1'), findsOneWidget);

      await tester.tap(find.text('v2.1.1'));
      await tester.pumpAndSettle();
      expect(find.byType(AppReleaseDetailPage), findsOneWidget);
      expect(find.text('iOS v2.1.1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a new version made from a card opens once saved', (
      tester,
    ) async {
      await pump(tester, const AppReleasesPage());

      await tester.tap(find.byTooltip('Actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('New version from this'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create release'));
      await tester.pumpAndSettle();

      expect(repository.created.single.versionName, '2.2.1');
      expect(find.text('Android v2.2.1'), findsOneWidget);
    });
  });
}
