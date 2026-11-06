import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required double width,
    required Widget bar,
  }) async {
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // The app theme: chip and search heights are tuned against it.
        theme: AppTheme.lightTheme,
        home: Scaffold(body: Column(children: [bar])),
      ),
    );
    await tester.pumpAndSettle();
  }

  Widget bar({
    String? status,
    ValueChanged<String?>? onChanged,
    int extraChips = 0,
    VoidCallback? onClearAll,
  }) => FilterBar(
    search: AppSearchField(
      controller: TextEditingController(),
      onSubmitted: (_) {},
    ),
    filters: [
      FilterSelect<String>(
        label: 'Status',
        value: status,
        allLabel: 'All',
        options: const [
          FilterOption('active', 'Active'),
          FilterOption('expired', 'Expired'),
        ],
        onChanged: onChanged ?? (_) {},
      ),
      for (var i = 0; i < extraChips; i++)
        FilterButton(label: 'Filter $i', value: null, onTap: () {}),
    ],
    onClearAll: onClearAll,
  );

  Rect rectOf(WidgetTester tester, Finder f) => tester.getRect(f);

  testWidgets('wide: search and chips share one row', (tester) async {
    await pump(tester, width: 1280, bar: bar());
    final search = rectOf(tester, find.byType(AppSearchField));
    final chip = rectOf(tester, find.byType(FilterButton));
    expect(chip.left, greaterThan(search.right));
    expect(chip.center.dy, moreOrLessEquals(search.center.dy, epsilon: 1));
    // Search is capped so the chips get the rest of the row.
    expect(search.width, lessThanOrEqualTo(440));
    // Chip and search are the same height, so the row reads as one line.
    expect(chip.height, moreOrLessEquals(search.height, epsilon: 2));
  });

  testWidgets('narrow: chips sit under search, left-aligned, never centred', (
    tester,
  ) async {
    await pump(tester, width: 390, bar: bar());
    final search = rectOf(tester, find.byType(AppSearchField));
    final chip = rectOf(tester, find.byType(FilterButton));
    expect(chip.top, greaterThan(search.bottom));
    expect(chip.left, moreOrLessEquals(search.left, epsilon: 1));
  });

  testWidgets('narrow: many chips scroll on one row instead of wrapping', (
    tester,
  ) async {
    await pump(tester, width: 390, bar: bar(extraChips: 8));
    final tops = find
        .byType(FilterButton)
        .evaluate()
        .map((e) => tester.getRect(find.byWidget(e.widget)).top)
        .toSet();
    expect(tops, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('select shows the label, then the value with a clear button', (
    tester,
  ) async {
    String? picked = 'unset';
    await pump(tester, width: 390, bar: bar(onChanged: (v) => picked = v));
    expect(find.text('Status'), findsOneWidget);

    await tester.tap(find.byType(FilterButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Expired'));
    await tester.pumpAndSettle();
    expect(picked, 'expired');

    await pump(
      tester,
      width: 390,
      bar: bar(status: 'expired', onChanged: (v) => picked = v),
    );
    expect(find.widgetWithText(FilterButton, 'Expired'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear Status filter'));
    await tester.pumpAndSettle();
    expect(picked, isNull);
  });

  testWidgets('clear-all appears only when the page offers it', (tester) async {
    await pump(tester, width: 390, bar: bar());
    expect(find.byTooltip('Clear all filters'), findsNothing);

    var cleared = false;
    await pump(tester, width: 390, bar: bar(onClearAll: () => cleared = true));
    await tester.tap(find.byTooltip('Clear all filters'));
    expect(cleared, isTrue);
  });
}
