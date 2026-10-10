import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import '../../l10n/l10n.dart';

// UC-44 クーポン・友だち紹介 (0056, API-072〜075, ADR-012). Phần giảm giá do EcoMeal chịu (quán vẫn nhận theo giá trước giảm).
class Coupon {
  const Coupon({required this.id, required this.amount, required this.reason, required this.expiresAt});
  final String id;
  final int amount;
  final String reason; // referral_welcome | referral_reward | campaign
  final DateTime expiresAt;
}

class MyReferral {
  const MyReferral({
    required this.code,
    required this.canApply,
    this.appliedCode,
    required this.invited,
    required this.rewarded,
  });
  final String code;
  final bool canApply; // còn nhập được mã của bạn bè (đăng ký ≤14 ngày, chưa nhận túi nào, chưa nhập mã)
  final String? appliedCode;
  final int invited;
  final int rewarded;
}

abstract class CouponsGateway {
  Future<List<Coupon>> fetchUsableCoupons(); // chưa dùng, còn hạn — sắp hết hạn trước
  Future<MyReferral> fetchMyReferral(); // API-072
  Future<void> applyReferralCode(String code); // API-073
}

class SupabaseCouponsGateway implements CouponsGateway {
  SupabaseCouponsGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Coupon>> fetchUsableCoupons() async {
    final rows = await _client
        .from('coupons')
        .select('id, amount, reason, expires_at')
        .isFilter('used_order_id', null)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('expires_at') as List;
    return rows.map((raw) {
      final r = raw as Map<String, dynamic>;
      return Coupon(
        id: r['id'] as String,
        amount: (r['amount'] as num).toInt(),
        reason: r['reason'] as String,
        expiresAt: DateTime.parse(r['expires_at'] as String),
      );
    }).toList();
  }

  @override
  Future<MyReferral> fetchMyReferral() async {
    final r = Map<String, dynamic>.from(await _client.rpc('get_my_referral') as Map);
    return MyReferral(
      code: r['code'] as String,
      canApply: r['can_apply'] as bool,
      appliedCode: r['applied_code'] as String?,
      invited: (r['invited'] as num).toInt(),
      rewarded: (r['rewarded'] as num).toInt(),
    );
  }

  @override
  Future<void> applyReferralCode(String code) => _client.rpc('apply_referral_code', params: {'p_code': code});
}

final couponsGatewayProvider = Provider<CouponsGateway>((ref) => SupabaseCouponsGateway(SupabaseClientHolder.instance));

// SCR-M05 (chọn coupon), SCR-M07 (số coupon) và SCR-M19 cùng đọc — dùng/nhận coupon xong thì invalidate.
final usableCouponsProvider = FutureProvider.autoDispose<List<Coupon>>((ref) => ref.watch(couponsGatewayProvider).fetchUsableCoupons());
final myReferralProvider = FutureProvider.autoDispose<MyReferral>((ref) => ref.watch(couponsGatewayProvider).fetchMyReferral());

// Tự chọn coupon có lợi nhất: giảm nhiều nhất, cùng mức thì sắp hết hạn trước.
Coupon? bestCoupon(List<Coupon> coupons) {
  if (coupons.isEmpty) return null;
  final sorted = [...coupons]
    ..sort((a, b) => a.amount != b.amount ? b.amount.compareTo(a.amount) : a.expiresAt.compareTo(b.expiresAt));
  return sorted.first;
}

// Chỉ để HIỂN THỊ trước khi đặt — cùng công thức với coupon_discount (0056): khách trả tối thiểu ¥50 (mức thấp nhất của
// Stripe). Đổi một bên thì đổi cả bên kia. Số tiền thật của đơn do server tính (price_paid / discount_amount).
const minimumCharge = 50;
int couponDiscount(int couponAmount, int price) {
  final room = price - minimumCharge;
  return room <= 0 ? 0 : (couponAmount < room ? couponAmount : room);
}

String couponTitle(Coupon c, AppLocalizations l10n) => switch (c.reason) {
      'referral_welcome' => l10n.couponReasonWelcome,
      'referral_reward' => l10n.couponReasonReward,
      _ => l10n.couponReasonCampaign,
    };

// Lỗi khi nhập mã giới thiệu
String referralErrorMessage(Object error, AppLocalizations l10n) {
  final message = error is PostgrestException ? error.message : '';
  if (message.contains('E-REF-404')) return l10n.referralErrorNotFound;
  if (message.contains('E-REF-409')) return l10n.referralErrorOwnCode;
  if (message.contains('E-REF-410')) return l10n.referralErrorNotEligible;
  if (message.contains('E-RATE-429')) return l10n.errorRateLimited;
  return l10n.referralErrorFailed;
}
