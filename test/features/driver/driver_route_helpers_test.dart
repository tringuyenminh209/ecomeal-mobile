import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/driver/driver_route_helpers.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

void main() {
  final stops = routeFixture.stops;

  test('nextStopOf(): điểm đầu tiên chưa rời đi; đã đi hết → null', () {
    expect(nextStopOf(stops)!.routeStopId, 'rB');
    expect(nextStopOf([stops[0], stops[1]]), isNull);
  });

  test('minutesUntil(): số phút còn lại, đã quá giờ thì 0 (không âm)', () {
    final planned = DateTime(2026, 10, 2, 19, 48);
    expect(minutesUntil(planned, now: DateTime(2026, 10, 2, 19, 40)), 8);
    expect(minutesUntil(planned, now: DateTime(2026, 10, 2, 20, 0)), 0);
  });

  test('distributableStopsAfter(): chỉ điểm public, SAU điểm thu gom, chưa rời đi', () {
    final ids = distributableStopsAfter(stops, stops[2]).map((s) => s.routeStopId).toList();
    expect(ids, ['p2', 'p3']); // p1 bị loại: đã rời đi VÀ đứng trước điểm thu gom rB
  });

  test('pickupPositionOf(): "集荷 2/2" cho quán B', () {
    final pos = pickupPositionOf(stops, stops[2]);
    expect(pos.index, 2);
    expect(pos.total, 2);
  });

  test('confirmErrorMessage(): mã lỗi RPC → câu của API-006/026 (ja + en)', () {
    expect(confirmErrorMessage(Exception('E-ORDER-009: batch is already confirmed'), l10nJa), 'このロットは既に確定済みです');
    expect(confirmErrorMessage(Exception('E-ROUTE-409: stop already closed'), l10nJa), 'この停車地点は既にクローズされています');
    expect(confirmErrorMessage(Exception('E-TEMP-001: temperature must be between -30 and 99.9'), l10nJa), '温度は-30〜99.9℃の範囲で入力してください');
    expect(confirmErrorMessage(Exception('timeout'), l10nJa), '確定登録に失敗しました。もう一度お試しください');
    expect(confirmErrorMessage(Exception('E-ORDER-009: batch is already confirmed'), l10nEn), 'This batch has already been confirmed');
  });

  test('validateTemperature()/validateConfirmedQty(): rỗng, ngoài khoảng, số âm', () {
    expect(validateTemperature('', l10nJa), '温度を入力してください');
    expect(validateTemperature('520', l10nJa), '温度は-30〜99.9℃の範囲で入力してください');
    // double.tryParse('NaN') trả NaN (không phải null), mà NaN so sánh luôn false → phải chặn riêng
    expect(validateTemperature('NaN', l10nJa), '温度は-30〜99.9℃の範囲で入力してください');
    expect(validateTemperature('75.0', l10nJa), isNull); // món giữ nóng — hợp lệ
    expect(validateTemperature('5.2', l10nJa), isNull);
    expect(validateConfirmedQty('-1', l10nJa), '0以上の整数で入力してください');
    expect(validateConfirmedQty('2.5', l10nJa), '0以上の整数で入力してください');
    expect(validateConfirmedQty('0', l10nJa), isNull); // 0 hợp lệ: quán báo không còn gì — FIFO hoàn tiền toàn bộ
  });
}
