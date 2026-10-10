import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/supabase_client.dart';

class UserProfile {
  const UserProfile({required this.name, required this.nameKana, required this.email, this.avatarPath});
  final String name;
  final String? nameKana;
  final String? avatarPath; // UC-35: đường dẫn trong bucket avatars, NULL = hiện chữ cái đầu
  final String email; // từ auth.users (Supabase Auth), KHÔNG phải cột của public.users
}

// Cùng pattern Gateway với AuthGateway/HomeGateway/OrderGateway — widget test mock interface này,
// không mock SupabaseClient (lý do ở box-why Chương 15).
abstract class ProfileGateway {
  Future<UserProfile> fetchMyProfile();
  Future<void> updateProfile({required String name, required String? nameKana}); // API-023 (SCR-M08)
  Future<void> updatePreferredLanguage(String languageCode); // API-023 (SCR-M07, UC-02)
  Future<bool> isLineLinked();
  Future<void> linkLineAccount(String idToken); // API-018b — Edge Function link-line-account (Chương 09)
  // API-049 (UC-35): tải ảnh JPEG đã cắt lên, trỏ users.avatar_path sang ảnh mới, xoá ảnh cũ. Trả về đường dẫn mới.
  Future<String> uploadAvatar(Uint8List jpegBytes, {String? previousPath});
  Future<void> removeAvatar(String path);
  Future<String> signedAvatarUrl(String path);
  // API-051 (UC-37): xoá tài khoản của chính mình. Lỗi E-ACCOUNT-409 → OpenReservationsException.
  Future<void> deleteMyAccount();
}

// Còn đơn chưa nhận (pending/allocated) — server từ chối xoá (E-ACCOUNT-409).
class OpenReservationsException implements Exception {
  const OpenReservationsException();
}

const _avatarBucket = 'avatars';
const _avatarUrlTtlSeconds = 3600; // API-049: URL ký có hiệu lực 1 giờ

class SupabaseProfileGateway implements ProfileGateway {
  SupabaseProfileGateway(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<UserProfile> fetchMyProfile() async {
    final row = await _client.from('users').select('name, name_kana, avatar_path').eq('id', _uid).single();
    return UserProfile(
      name: row['name'] as String,
      nameKana: row['name_kana'] as String?,
      email: _client.auth.currentUser!.email ?? '',
      avatarPath: row['avatar_path'] as String?,
    );
  }

  // 10_API設計 API-023: UPDATE chỉ 3 cột được GRANT; RLS users_update_own lọc về đúng dòng của mình.
  // PostgREST trả về [] (KHÔNG báo lỗi) khi không dòng nào khớp → API-023 yêu cầu client tự coi mảng
  // rỗng là "lưu thất bại", nên phải .select() để nhận lại các dòng đã cập nhật.
  Future<void> _updateOwnRow(Map<String, dynamic> values) async {
    final rows = await _client.from('users').update(values).eq('id', _uid).select('id') as List;
    if (rows.isEmpty) {
      throw StateError('API-023: 0 dòng được cập nhật');
    }
  }

  @override
  Future<void> updateProfile({required String name, required String? nameKana}) {
    return _updateOwnRow({'name': name, 'name_kana': nameKana});
  }

  @override
  Future<void> updatePreferredLanguage(String languageCode) {
    return _updateOwnRow({'preferred_language': languageCode});
  }

  // RLS user_line_accounts_select_own (Chương 01): chỉ đọc được dòng của chính mình.
  @override
  Future<bool> isLineLinked() async {
    final row = await _client.from('user_line_accounts').select('is_active').eq('user_id', _uid).maybeSingle();
    return row != null && row['is_active'] == true;
  }

  // functions.invoke tự gắn JWT người dùng vào header Authorization — đúng thứ Edge Function cần ở
  // bước 1 để biết "ai đang gọi". Status không phải 2xx → supabase_flutter ném FunctionException.
  @override
  Future<void> linkLineAccount(String idToken) async {
    final res = await _client.functions.invoke('link-line-account', body: {'liff_id_token': idToken});
    final data = res.data;
    if (data is! Map || data['success'] != true) {
      throw StateError('link-line-account: unexpected response');
    }
  }

  // Thứ tự của API-049: ① tải file ② cập nhật avatar_path ③ xoá file cũ. ② lỗi → xoá file vừa tải (không để file mồ côi)
  // và giữ ảnh cũ. ③ lỗi thì bỏ qua: ảnh mới đã dùng được, file cũ chỉ còn là rác trong thư mục của chính mình.
  @override
  Future<String> uploadAvatar(Uint8List jpegBytes, {String? previousPath}) async {
    final path = '$_uid/${const Uuid().v4()}.jpg';
    final bucket = _client.storage.from(_avatarBucket);
    await bucket.uploadBinary(path, jpegBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    try {
      await _updateOwnRow({'avatar_path': path});
    } catch (_) {
      try {
        await bucket.remove([path]);
      } catch (_) {}
      rethrow;
    }
    if (previousPath != null) await _removeQuietly(previousPath);
    return path;
  }

  // Xoá: trỏ avatar_path về NULL TRƯỚC rồi mới xoá file — ngược lại thì lỗi giữa chừng để hồ sơ trỏ vào file không còn.
  @override
  Future<void> removeAvatar(String path) async {
    await _updateOwnRow({'avatar_path': null});
    await _removeQuietly(path);
  }

  Future<void> _removeQuietly(String path) async {
    try {
      await _client.storage.from(_avatarBucket).remove([path]);
    } catch (_) {}
  }

  // Thứ tự: ① RPC xoá dữ liệu (auth.users → CASCADE, đơn hàng giữ lại nhưng bỏ user_id) ② xoá file ảnh bằng Storage API —
  // JWT hiện tại vẫn còn hiệu lực dù user đã bị xoá (Storage chỉ kiểm chữ ký + thư mục = sub), đã thử trên Supabase local
  // ③ đăng xuất cục bộ (scope local: không gọi server, user không còn nên gọi /logout chỉ ra lỗi) → RoleGate về SCR-M02.
  @override
  Future<void> deleteMyAccount() async {
    final Map<String, dynamic> result;
    try {
      result = Map<String, dynamic>.from(await _client.rpc('delete_my_account') as Map);
    } on PostgrestException catch (e) {
      if (e.message.contains('E-ACCOUNT-409')) throw const OpenReservationsException();
      rethrow;
    }
    final avatarPath = result['avatar_path'] as String?;
    if (avatarPath != null) await _removeQuietly(avatarPath);
    await _client.auth.signOut(scope: SignOutScope.local);
  }

  // Bucket không công khai (chỉ chủ tài khoản đọc được) → hiển thị bằng URL ký.
  @override
  Future<String> signedAvatarUrl(String path) {
    return _client.storage.from(_avatarBucket).createSignedUrl(path, _avatarUrlTtlSeconds);
  }
}

final profileGatewayProvider = Provider<ProfileGateway>((ref) => SupabaseProfileGateway(SupabaseClientHolder.instance));

final myProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(profileGatewayProvider).fetchMyProfile();
});

final lineLinkedProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(profileGatewayProvider).isLineLinked();
});

// Theo đường dẫn: đổi ảnh là đổi khoá → tự lấy URL mới; cùng ảnh thì dùng lại URL trong phiên.
final avatarUrlProvider = FutureProvider.autoDispose.family<String, String>((ref, path) {
  return ref.watch(profileGatewayProvider).signedAvatarUrl(path);
});
