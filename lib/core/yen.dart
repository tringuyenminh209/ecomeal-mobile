import 'package:intl/intl.dart';

// Số tiền yên có dấu phân cách hàng nghìn: 53320 → 「¥53,320」 (JPY không có số lẻ — CLAUDE.md).
final _yen = NumberFormat('#,##0', 'en_US');

String formatYen(int amount) => '¥${_yen.format(amount)}';
