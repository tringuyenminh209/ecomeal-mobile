import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ecomeal_mobile/features/orders/order_helpers.dart';
import 'package:ecomeal_mobile/widgets/status_badge.dart';
import '../../helpers/test_app.dart';

void main() {
  const sampleId = 'a1b2c3d4-0000-0000-0000-00000000f00d';

  test('orderDisplayNumber(): cùng 1 id luôn ra cùng 1 số đơn (tất định)', () {
    expect(orderDisplayNumber(sampleId), orderDisplayNumber(sampleId));
    expect(orderDisplayNumber(sampleId), startsWith('#EM-'));
  });

  test('pickupManualCode(): đúng 4 ký tự, chữ hoa', () {
    final code = pickupManualCode(sampleId);
    expect(code.length, 4);
    expect(code, code.toUpperCase());
  });

  test('badgeForStatus(): đủ 6 trạng thái, đúng nhãn tiếng Nhật + màu khớp Figma', () {
    expect(badgeForStatus('pending', l10nJa).label, '数量確認待ち');
    expect(badgeForStatus('allocated', l10nJa).label, '取り置き済み');
    expect(badgeForStatus('picked_up', l10nJa).label, '受け取り済み');
    expect(badgeForStatus('refunded', l10nJa).label, '返金済み');
    expect(badgeForStatus('expired', l10nJa).label, '失効');
    expect(badgeForStatus('cancelled', l10nJa).label, 'キャンセル済み');
    // Màu theo Figma SCR-M06: allocated xanh, picked_up xám, refunded/expired đỏ.
    expect(badgeForStatus('pending', l10nJa).tone, BadgeTone.warning);
    expect(badgeForStatus('allocated', l10nJa).tone, BadgeTone.active);
    expect(badgeForStatus('picked_up', l10nJa).tone, BadgeTone.neutral);
    expect(badgeForStatus('refunded', l10nJa).tone, BadgeTone.error);
    expect(badgeForStatus('expired', l10nJa).tone, BadgeTone.error);
    expect(badgeForStatus('cancelled', l10nJa).tone, BadgeTone.warning);
  });

  test('badgeForStatus(): locale en → nhãn tiếng Anh, cùng màu', () {
    expect(badgeForStatus('allocated', l10nEn).label, 'Reserved');
    expect(badgeForStatus('allocated', l10nEn).tone, badgeForStatus('allocated', l10nJa).tone);
  });

  group('BR-003 — canCancel() / isFreeCancellation()', () {
    final pickupTime = DateTime(2026, 10, 2, 20, 0);

    test('canCancel(): pending/allocated → true, mọi kết cục khác → false (không phụ thuộc giờ)', () {
      expect(canCancel('pending'), isTrue);
      expect(canCancel('allocated'), isTrue);
      for (final s in ['picked_up', 'refunded', 'expired', 'cancelled']) {
        expect(canCancel(s), isFalse);
      }
    });

    test('isFreeCancellation(): còn hơn 30 phút → miễn phí (hoàn tiền)', () {
      expect(isFreeCancellation(pickupTime, now: DateTime(2026, 10, 2, 19, 0)), isTrue);
    });

    test('isFreeCancellation(): còn 29 phút → vẫn hủy được nhưng KHÔNG hoàn tiền', () {
      expect(isFreeCancellation(pickupTime, now: DateTime(2026, 10, 2, 19, 31)), isFalse);
    });
  });

  group('orderTimeLabel() — giờ Tokyo, "本日" khi cùng ngày JST', () {
    // Trong app, delegate localizations của MaterialApp nạp dữ liệu ngày của intl; test hàm thuần tự nạp.
    setUpAll(initializeDateFormatting);
    // planned_time từ Supabase là UTC: 11:10Z = 20:10 JST.
    final planned = DateTime.utc(2026, 10, 2, 11, 10);

    test('cùng ngày JST → 「本日 20:10」 (không phải giờ UTC 11:10)', () {
      expect(orderTimeLabel(planned, l10nJa, now: DateTime.utc(2026, 10, 2, 1, 0)), '本日 20:10');
    });

    test('khác ngày JST → 「10月2日 20:10」; en → "Oct 2 20:10"', () {
      final now = DateTime.utc(2026, 10, 5, 1, 0);
      expect(orderTimeLabel(planned, l10nJa, now: now), '10月2日 20:10');
      expect(orderTimeLabel(planned, l10nEn, now: now), 'Oct 2 20:10');
    });

    test('ranh giới ngày theo JST, không theo UTC: 16:00Z ngày 1 = 01:00 JST ngày 2 → vẫn là "本日" của ngày 2', () {
      expect(
        orderTimeLabel(DateTime.utc(2026, 10, 1, 16, 0), l10nJa, now: DateTime.utc(2026, 10, 2, 3, 0)),
        '本日 01:00',
      );
    });
  });

  test('filterOrders():"予約中" chỉ giữ pending/allocated, "完了" giữ phần còn lại', () {
    final statuses = ['pending', 'allocated', 'picked_up', 'refunded', 'expired', 'cancelled'];
    final active = filterOrders(statuses, OrderFilter.active, (s) => s);
    final completed = filterOrders(statuses, OrderFilter.completed, (s) => s);
    expect(active, ['pending', 'allocated']);
    expect(completed, ['picked_up', 'refunded', 'expired', 'cancelled']);
    expect(filterOrders(statuses, OrderFilter.all, (s) => s), statuses);
  });
}
