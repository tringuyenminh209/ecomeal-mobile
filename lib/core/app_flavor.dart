import 'package:flutter_riverpod/flutter_riverpod.dart';

// ADR-007: 1 codebase → 2 app. Mỗi điểm khởi động (lib/main.dart = app khách, lib/main_driver.dart = app tài xế)
// override provider này; RoleGate và theme đọc nó để chỉ mở luồng của app mình.
enum AppFlavor { customer, driver }

final appFlavorProvider = Provider<AppFlavor>((ref) => AppFlavor.customer);
