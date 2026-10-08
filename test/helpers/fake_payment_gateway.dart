import 'package:ecomeal_mobile/features/payment/card_input.dart';
import 'package:ecomeal_mobile/features/payment/payment_gateway.dart';

// Danh sách thẻ trong bộ nhớ, cùng quy tắc với 0043: thẻ đầu tiên tự thành mặc định, xoá thẻ mặc định → thẻ
// còn lại đầu tiên thành mặc định. Ghi lại tham số thêm thẻ để test kiểm tra app chỉ gửi 4 số cuối.
class FakePaymentGateway implements PaymentGateway {
  FakePaymentGateway([List<PaymentMethod> initial = const []]) : methods = [...initial];

  List<PaymentMethod> methods;
  final added = <({CardBrand brand, String last4, CardExpiry expiry})>[];
  Object? fetchError;
  Object? addError;

  static PaymentMethod card(String id, CardBrand brand, String last4, {bool isDefault = false}) =>
      PaymentMethod(id: id, brand: brand, last4: last4, expMonth: 8, expYear: 2029, isDefault: isDefault);

  @override
  Future<List<PaymentMethod>> fetchMyPaymentMethods() async {
    if (fetchError != null) throw fetchError!;
    return [...methods.where((m) => m.isDefault), ...methods.where((m) => !m.isDefault)];
  }

  @override
  Future<String> addPaymentMethod({required CardBrand brand, required String last4, required CardExpiry expiry}) async {
    if (addError != null) throw addError!;
    added.add((brand: brand, last4: last4, expiry: expiry));
    final id = 'pm-${methods.length + 1}';
    methods = [
      ...methods,
      PaymentMethod(id: id, brand: brand, last4: last4, expMonth: expiry.month, expYear: expiry.year, isDefault: methods.isEmpty),
    ];
    return id;
  }

  @override
  Future<void> setDefaultPaymentMethod(String id) async {
    methods = [for (final m in methods) _copy(m, isDefault: m.id == id)];
  }

  @override
  Future<void> deletePaymentMethod(String id) async {
    final wasDefault = methods.firstWhere((m) => m.id == id).isDefault;
    methods = methods.where((m) => m.id != id).toList();
    if (wasDefault && methods.isNotEmpty) {
      methods = [_copy(methods.first, isDefault: true), ...methods.skip(1)];
    }
  }

  PaymentMethod _copy(PaymentMethod m, {required bool isDefault}) => PaymentMethod(
        id: m.id,
        brand: m.brand,
        last4: m.last4,
        expMonth: m.expMonth,
        expYear: m.expYear,
        isDefault: isDefault,
      );
}
