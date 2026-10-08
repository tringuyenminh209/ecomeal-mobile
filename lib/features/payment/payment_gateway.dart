import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import 'card_input.dart';

// 1 dòng payment_methods (0043). Không có số thẻ đầy đủ — chỉ đủ để hiện「Visa •••• 3456」và hạn.
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
  });
  final String id;
  final CardBrand brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  // 「有効期限 08/29」
  String get expiryLabel => '${expMonth.toString().padLeft(2, '0')}/${(expYear % 100).toString().padLeft(2, '0')}';
}

// Cùng pattern Gateway với Order/Profile — widget test mock interface này.
abstract class PaymentGateway {
  Future<List<PaymentMethod>> fetchMyPaymentMethods();
  // API-046 — chỉ hãng + 4 số cuối + hạn. Trả về id thẻ vừa tạo.
  Future<String> addPaymentMethod({required CardBrand brand, required String last4, required CardExpiry expiry});
  Future<void> setDefaultPaymentMethod(String id); // API-047
  Future<void> deletePaymentMethod(String id); // API-048
}

class SupabasePaymentGateway implements PaymentGateway {
  SupabasePaymentGateway(this._client);
  final SupabaseClient _client;

  // RLS payment_methods_select_own: chỉ thấy thẻ của mình. Thẻ mặc định lên đầu, sau đó thẻ mới thêm.
  @override
  Future<List<PaymentMethod>> fetchMyPaymentMethods() async {
    final rows = await _client
        .from('payment_methods')
        .select('id, brand, last4, exp_month, exp_year, is_default')
        .order('is_default', ascending: false)
        .order('created_at', ascending: false) as List;
    return rows
        .map((raw) {
          final row = raw as Map<String, dynamic>;
          final brand = CardBrand.fromDb(row['brand'] as String);
          if (brand == null) return null; // hãng mới thêm ở server mà app bản cũ chưa biết — bỏ qua
          return PaymentMethod(
            id: row['id'] as String,
            brand: brand,
            last4: row['last4'] as String,
            expMonth: row['exp_month'] as int,
            expYear: row['exp_year'] as int,
            isDefault: row['is_default'] as bool,
          );
        })
        .whereType<PaymentMethod>()
        .toList();
  }

  @override
  Future<String> addPaymentMethod({required CardBrand brand, required String last4, required CardExpiry expiry}) async {
    final result = await _client.rpc('add_payment_method', params: {
      'p_brand': brand.name,
      'p_last4': last4,
      'p_exp_month': expiry.month,
      'p_exp_year': expiry.year,
    }) as Map<String, dynamic>;
    return result['payment_method_id'] as String;
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) =>
      _client.rpc('set_default_payment_method', params: {'p_payment_method_id': id});

  @override
  Future<void> deletePaymentMethod(String id) => _client.rpc('delete_payment_method', params: {'p_payment_method_id': id});
}

final paymentGatewayProvider = Provider<PaymentGateway>((ref) => SupabasePaymentGateway(SupabaseClientHolder.instance));

// SCR-M05 / M07 / M09 cùng đọc danh sách này — thêm/xoá/đổi mặc định xong thì invalidate để cả 3 cập nhật.
final myPaymentMethodsProvider = FutureProvider.autoDispose<List<PaymentMethod>>((ref) {
  return ref.watch(paymentGatewayProvider).fetchMyPaymentMethods();
});
