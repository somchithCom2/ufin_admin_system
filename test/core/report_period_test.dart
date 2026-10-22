import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/utils/report_period.dart';

void main() {
  test('the default whole day is sent as dates, exactly as before', () {
    expect(reportStartParam(DateTime(2026, 10, 22)), '2026-10-22');
    expect(reportEndParam(DateTime(2026, 10, 22, 23, 59)), '2026-10-22');
    expect(reportEndParam(DateTime(2026, 10, 22)), '2026-10-22');
  });

  test('picked times are sent as platform wall-clock time', () {
    expect(
      reportStartParam(DateTime(2026, 10, 22, 8, 30)),
      '2026-10-22T08:30:00',
    );
    expect(
      reportEndParam(DateTime(2026, 10, 22, 14, 0)),
      '2026-10-22T14:00:59.999',
    );
  });
}
