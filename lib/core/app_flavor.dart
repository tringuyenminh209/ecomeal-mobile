import 'package:flutter_riverpod/flutter_riverpod.dart';

// ADR-007 / ADR-015: 1 codebase → 4 app. Mỗi điểm khởi động (lib/main.dart = app khách, lib/main_driver.dart = app tài xế,
// lib/main_store.dart = app nhà hàng, lib/main_admin.dart = app vận hành) override provider này; RoleGate và theme đọc nó
// để chỉ mở luồng của app mình.
enum AppFlavor {
  customer,
  driver,
  store,
  admin;

  // Giá trị push_tokens.app / p_app của register_push_token (0059) — trùng tên enum
  String get pushApp => name;

  // App tài xế (trong cabin ban đêm) và app vận hành (đêm vận hành) dùng bộ màu tối (EcoPalette.night)
  bool get usesNightTheme => this == AppFlavor.driver || this == AppFlavor.admin;
}

final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.customer);
