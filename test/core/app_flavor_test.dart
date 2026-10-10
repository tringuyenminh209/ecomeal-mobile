import 'package:flutter_test/flutter_test.dart';
import 'package:ecomeal_mobile/core/app_flavor.dart';

void main() {
  // 0059: register_push_token(p_app) và CHECK push_tokens.app chỉ nhận đúng 4 giá trị này
  test('pushApp khớp giá trị app của server (customer/driver/store/admin)', () {
    expect(AppFlavor.values.map((f) => f.pushApp), ['customer', 'driver', 'store', 'admin']);
  });

  test('theme tối cho app tài xế và app vận hành, sáng cho app khách và app nhà hàng', () {
    expect(AppFlavor.values.where((f) => f.usesNightTheme), [AppFlavor.driver, AppFlavor.admin]);
  });
}
