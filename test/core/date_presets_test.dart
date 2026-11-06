import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/utils/date_presets.dart';

void main() {
  DateTimeRange r(DatePreset p, DateTime now) => p.range(now);
  DateTimeRange days(DateTime a, DateTime b) => DateTimeRange(start: a, end: b);

  test('ranges are whole days relative to now, ignoring the time', () {
    final now = DateTime(2026, 11, 6, 15, 42);
    expect(
      r(DatePreset.today, now),
      days(DateTime(2026, 11, 6), DateTime(2026, 11, 6)),
    );
    expect(
      r(DatePreset.yesterday, now),
      days(DateTime(2026, 11, 5), DateTime(2026, 11, 5)),
    );
    expect(
      r(DatePreset.last7Days, now),
      days(DateTime(2026, 10, 31), DateTime(2026, 11, 6)),
    );
    expect(
      r(DatePreset.thisMonth, now),
      days(DateTime(2026, 11, 1), DateTime(2026, 11, 6)),
    );
    expect(
      r(DatePreset.lastMonth, now),
      days(DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
    );
  });

  test('month and year boundaries', () {
    final newYear = DateTime(2027, 1, 1, 0, 5);
    expect(
      r(DatePreset.yesterday, newYear),
      days(DateTime(2026, 12, 31), DateTime(2026, 12, 31)),
    );
    expect(
      r(DatePreset.lastMonth, newYear),
      days(DateTime(2026, 12, 1), DateTime(2026, 12, 31)),
    );
    // Leap year: the day before 1 March is 29 February.
    expect(
      r(DatePreset.yesterday, DateTime(2028, 3, 1)),
      days(DateTime(2028, 2, 29), DateTime(2028, 2, 29)),
    );
    expect(
      r(DatePreset.lastMonth, DateTime(2028, 3, 15)),
      days(DateTime(2028, 2, 1), DateTime(2028, 2, 29)),
    );
  });

  test('matching finds the preset for a range of days', () {
    final now = DateTime(2026, 11, 6, 9);
    expect(
      DatePreset.matching(
        DateTime(2026, 11, 5),
        DateTime(2026, 11, 5, 23, 59),
        now: now,
      ),
      DatePreset.yesterday,
    );
    expect(
      DatePreset.matching(
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 4),
        now: now,
      ),
      isNull,
    );
  });
}
