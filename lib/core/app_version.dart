import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Số phiên bản app (SCR-M07, SCR-S08). Test thay bằng giá trị cố định (package_info_plus cần platform channel).
final appVersionProvider = FutureProvider<String>((ref) async => (await PackageInfo.fromPlatform()).version);
