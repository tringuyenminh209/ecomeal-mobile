import 'package:flutter/widgets.dart';

// Bố cục iPad ngang của app 店舗 và app 運営 (Figma 559:1328「Store · iPad」, section 20〜24「Admin · iPad」— 1194×834):
// từ độ rộng này trở lên dùng thanh điều hướng dọc + 2 cột. iPad dọc (834) và điện thoại giữ bố cục 1 cột.
const wideLayoutBreakpoint = 900.0;

bool isWideLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= wideLayoutBreakpoint;
