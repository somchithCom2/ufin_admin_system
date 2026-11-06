import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/config/theme/app_theme.dart';
import 'package:ufin_admin_system/core/utils/date_presets.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/pages/daily_sales_page.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

class _Repository extends AdminRepository {
  _Repository() : super(dio: Dio());

  final calls = <(DateTime, DateTime)>[];

  @override
  Future<DailySalesData> getDailySales({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    calls.add((startDate, endDate));
    return DailySalesData.fromJson({'date': '2026-11-06', 'totalOrders': 3});
  }
}

void main() {
  late _Repository repository;

  setUp(() => repository = _Repository());

  Future<void> open(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [adminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DailySalesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  FilterPill pill(WidgetTester tester, String label) =>
      tester.widget<FilterPill>(find.widgetWithText(FilterPill, label));

  /// Whole days: 00:00 on the first day to 23:59 on the last.
  (DateTime, DateTime) wholeDays(DatePreset preset) {
    final r = preset.range(DateTime.now());
    return (r.start, DateTime(r.end.year, r.end.month, r.end.day, 23, 59));
  }

  testWidgets('opens on Today with every quick period one tap away', (
    tester,
  ) async {
    await open(tester);
    expect(repository.calls.single, wholeDays(DatePreset.today));
    for (final label in [
      'Today',
      'Yesterday',
      'Last 7 days',
      'This month',
      'Last month',
      'Custom',
    ]) {
      expect(find.widgetWithText(FilterPill, label), findsOneWidget);
    }
    expect(pill(tester, 'Today').selected, isTrue);
    expect(pill(tester, 'Custom').selected, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a quick period loads its whole days and selects its chip', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.widgetWithText(FilterPill, 'Yesterday'));
    await tester.pumpAndSettle();
    expect(repository.calls.last, wholeDays(DatePreset.yesterday));
    expect(pill(tester, 'Yesterday').selected, isTrue);
    expect(pill(tester, 'Today').selected, isFalse);

    await tester.ensureVisible(find.widgetWithText(FilterPill, 'Last month'));
    await tester.tap(find.widgetWithText(FilterPill, 'Last month'));
    await tester.pumpAndSettle();
    expect(repository.calls.last, wholeDays(DatePreset.lastMonth));
    expect(pill(tester, 'Last month').selected, isTrue);
  });

  testWidgets('cancelling the custom period keeps the period on screen', (
    tester,
  ) async {
    await open(tester);
    final before = repository.calls.length;

    await tester.ensureVisible(find.widgetWithText(FilterPill, 'Custom'));
    await tester.tap(find.widgetWithText(FilterPill, 'Custom'));
    await tester.pumpAndSettle();
    // Move the start date to the 1st in the sheet (a no-op on the 1st of a
    // month), then back out.
    await tester.tap(find.text('Start Date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // The sheet shows the edit...
    if (DateTime.now().day != 1) {
      expect(find.textContaining('01/'), findsWidgets);
    }
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.calls.length, before);
    expect(pill(tester, 'Today').selected, isTrue);
    // Refresh reloads what is on screen, not the abandoned edit.
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(repository.calls.last, wholeDays(DatePreset.today));
  });

  testWidgets('desktop: the quick periods fit on one row', (tester) async {
    await open(tester, width: 1280);
    final tops = find
        .byType(FilterPill)
        .evaluate()
        .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
        .toSet();
    expect(tops, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
