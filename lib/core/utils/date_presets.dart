import 'package:flutter/material.dart';
import 'package:ufin_admin_system/l10n/l10n.dart';

/// Quick periods offered by report filters: whole days, inclusive, on the
/// local calendar (the console runs on Laos time).
enum DatePreset {
  today(CommonText.today),
  yesterday(CommonText.yesterday),
  last7Days(CommonText.last7Days),
  thisMonth(CommonText.thisMonth),
  lastMonth(CommonText.lastMonth);

  const DatePreset(this.label);

  final Tr label;

  /// First and last day of the period, as dates (midnight), relative to
  /// [now]. Built from calendar fields rather than subtracting durations so
  /// month and year boundaries are always right.
  DateTimeRange range(DateTime now) {
    final t = DateUtils.dateOnly(now);
    DateTime day(int offset) => DateTime(t.year, t.month, t.day + offset);
    return switch (this) {
      today => DateTimeRange(start: t, end: t),
      yesterday => DateTimeRange(start: day(-1), end: day(-1)),
      last7Days => DateTimeRange(start: day(-6), end: t),
      thisMonth => DateTimeRange(start: DateTime(t.year, t.month), end: t),
      // Day 0 of this month is the last day of the previous one.
      lastMonth => DateTimeRange(
        start: DateTime(t.year, t.month - 1),
        end: DateTime(t.year, t.month, 0),
      ),
    };
  }

  /// The preset covering exactly the days [start]..[end], if one does.
  /// Times are ignored; callers that care about times check them first.
  static DatePreset? matching(
    DateTime start,
    DateTime end, {
    required DateTime now,
  }) {
    for (final preset in values) {
      final r = preset.range(now);
      if (DateUtils.isSameDay(r.start, start) &&
          DateUtils.isSameDay(r.end, end)) {
        return preset;
      }
    }
    return null;
  }
}
