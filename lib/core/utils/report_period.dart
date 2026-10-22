/// How a report's start and end are sent to the backend.
///
/// A value at midnight is a whole day and goes as its date (`2026-10-22`), as
/// reports have always been asked for. A value with a time of day goes as
/// platform wall-clock time (Laos) with no offset, which is how the backend
/// reads it for the admin reports.
library;

/// The first instant a report counts.
String reportStartParam(DateTime d) => _isMidnight(d)
    ? _date(d)
    : '${_date(d)}T${_two(d.hour)}:${_two(d.minute)}:${_two(d.second)}';

/// The last instant a report counts. A picked end minute counts in full, so
/// 14:00 takes in a sale at 14:00:40; an end of 23:59 is the whole day.
String reportEndParam(DateTime d) => _isMidnight(d) || _isLastMinute(d)
    ? _date(d)
    : '${_date(d)}T${_two(d.hour)}:${_two(d.minute)}:59.999';

bool _isLastMinute(DateTime d) => d.hour == 23 && d.minute == 59;

bool _isMidnight(DateTime d) =>
    d.hour == 0 &&
    d.minute == 0 &&
    d.second == 0 &&
    d.millisecond == 0 &&
    d.microsecond == 0;

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

String _two(int n) => n.toString().padLeft(2, '0');
