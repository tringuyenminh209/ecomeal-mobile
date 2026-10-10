import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

// RPC raise dạng "E-XXX-NNN: <tiếng Anh nội bộ>" (10_API設計 §3): lấy mã ở đầu để chọn câu báo lỗi cho người dùng.
// null = không có mã (mất mạng, hết giờ, lỗi không phải của RPC).
String? rpcErrorCode(Object error) {
  if (error is PostgrestException) return RegExp(r'E-[A-Z]+-\d{3}').firstMatch(error.message)?.group(0);
  return null;
}
