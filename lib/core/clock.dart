import 'package:flutter_riverpod/flutter_riverpod.dart';

// "Bây giờ" đi qua provider để widget test thay được đồng hồ (SCR-D03 đếm ngược tới giờ rời điểm).
// App thật dùng DateTime.now — không có logic nào khác ở đây.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
