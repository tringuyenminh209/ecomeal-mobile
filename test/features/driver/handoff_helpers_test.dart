import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/features/driver/handoff_gateway.dart';
import 'package:ecomeal_mobile/features/driver/handoff_helpers.dart';
import '../../helpers/test_app.dart';
import 'driver_test_data.dart';

ReservationAtStop r(String id, String status) => ReservationAtStop(orderId: id, status: status, createdAt: DateTime(2026, 10, 2, 12));

void main() {
  test('matchManualCode(): khớp 4 ký tự cuối (không phân biệt hoa/thường), chỉ trong đơn allocated', () {
    final list = [
      r('11111111-0000-0000-0000-00000000beef', 'allocated'),
      r('22222222-0000-0000-0000-00000000cafe', 'picked_up'), // đã giao → không được khớp lại
    ];
    expect(matchManualCode(list, 'beef').map((m) => m.orderId), ['11111111-0000-0000-0000-00000000beef']);
    expect(matchManualCode(list, 'CAFE'), isEmpty);
    expect(matchManualCode(list, 'BEE'), isEmpty); // không đủ 4 ký tự → không tra
  });

  test('matchManualCode(): 2 đơn trùng mã → trả cả 2 để tài xế hỏi lại khách (06 §SCR-M06)', () {
    final list = [r('11111111-0000-0000-0000-00000000beef', 'allocated'), r('33333333-0000-0000-0000-00000000beef', 'allocated')];
    expect(matchManualCode(list, 'BEEF'), hasLength(2));
  });

  test('handoffErrorMessage() / validateDonationQty()', () {
    expect(handoffErrorMessage(Exception('E-ORDER-007: sold out at this pickup stop'), l10nJa), 'この停車地点で予約なしで販売できる分は売り切れです');
    expect(handoffErrorMessage(Exception('E-INV-001: quantity exceeds remaining stock'), l10nJa), '寄付数量が残り在庫を超えています');
    expect(handoffErrorMessage(Exception('E-INV-004: stops selling this batch are still open'), l10nJa), '未出発の販売地点があるため、まだ寄付を記録できません');
    expect(handoffErrorMessage(Exception('E-ROUTE-409: stop already closed'), l10nJa), 'この停車地点はすでに出発しました');
    expect(handoffErrorMessage(Exception('E-ORDER-007: sold out at this pickup stop'), l10nEn), 'Walk-up stock at this stop is sold out');
    expect(validateDonationQty('0', l10nJa), '1以上の整数で入力してください');
    expect(validateDonationQty('6', l10nJa), isNull);
  });

  test('openSalesStopCount(): chỉ đếm điểm bán chưa 出発, bỏ qua điểm thu gom', () {
    expect(openSalesStopCount(routeFixture.stops), 2); // p2, p3 (rB là điểm thu gom — không tính)
  });
}
