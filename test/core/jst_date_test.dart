import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/jst_date.dart';
void main() {
  test('pickup window is always JST, even when input is UTC and crosses midnight', () {
    expect(pickupWindowLabel(DateTime.utc(2026, 10, 4, 14, 50)), '23:50–00:10');
    expect(pickupWindowLabel(DateTime.utc(2026, 10, 4, 11, 10)), '20:10–20:30');
  });
  test('countdown rounds up a partial minute and clamps expired batches to zero', () {
    final now = DateTime.utc(2026, 10, 4, 10);
    expect(remainingMinutes(now.add(const Duration(seconds: 61)), now), 2);
    expect(remainingMinutes(now.add(const Duration(seconds: 1)), now), 1);
    expect(remainingMinutes(now, now), 0);
    expect(remainingMinutes(now.subtract(const Duration(hours: 1)), now), 0);
  });

  test('addDaysToDate: 月・年をまたいでも YYYY-MM-DD（SCR-D05 のシフト期間）', () {
    expect(addDaysToDate('2026-10-05', 13), '2026-10-18');
    expect(addDaysToDate('2026-12-25', 13), '2027-01-07');
  });
}
