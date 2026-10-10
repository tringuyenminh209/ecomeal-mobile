import 'package:flutter/widgets.dart';

// App nhà hàng có bố cục iPad riêng (proposal §4, Figma section「Store · iPad（11インチ 横 1194×834）」559:1328):
// từ độ rộng này trở lên dùng thanh điều hướng dọc + 2 cột. iPad dọc (834) và điện thoại giữ bố cục 1 cột.
const storeWideBreakpoint = 900.0;

bool isStoreWide(BuildContext context) => MediaQuery.sizeOf(context).width >= storeWideBreakpoint;
