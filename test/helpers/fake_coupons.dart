import 'package:ecomeal_mobile/features/coupons/coupons.dart';

// Gateway giả: danh sách coupon + trạng thái giới thiệu trong bộ nhớ. applyError != null thì ném lỗi đó.
class FakeCouponsGateway implements CouponsGateway {
  FakeCouponsGateway({List<Coupon>? coupons, MyReferral? referral})
      : coupons = coupons ?? [],
        referral = referral ?? const MyReferral(code: 'EM7K2Q', canApply: true, invited: 0, rewarded: 0);
  final List<Coupon> coupons;
  MyReferral referral;
  final applied = <String>[];
  Object? applyError;
  Object? fetchError; // != null: fetchUsableCoupons ném lỗi này

  static Coupon coupon(String id, {int amount = 100, String reason = 'referral_welcome', int days = 30}) =>
      Coupon(id: id, amount: amount, reason: reason, expiresAt: DateTime.now().add(Duration(days: days)));

  @override
  Future<List<Coupon>> fetchUsableCoupons() async {
    final error = fetchError;
    if (error != null) throw error;
    return List.of(coupons);
  }

  @override
  Future<MyReferral> fetchMyReferral() async => referral;

  @override
  Future<void> applyReferralCode(String code) async {
    applied.add(code);
    final e = applyError;
    if (e != null) throw e;
    coupons.add(coupon('welcome'));
    referral = MyReferral(code: referral.code, canApply: false, appliedCode: code, invited: 0, rewarded: 0);
  }
}
