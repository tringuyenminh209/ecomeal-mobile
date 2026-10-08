import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class UserProfile {
  const UserProfile({required this.name, required this.nameKana, required this.email});
  final String name;
  final String? nameKana;
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
}

class SupabaseProfileGateway implements ProfileGateway {
  SupabaseProfileGateway(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<UserProfile> fetchMyProfile() async {
    final row = await _client.from('users').select('name, name_kana').eq('id', _uid).single();
    return UserProfile(
      name: row['name'] as String,
      nameKana: row['name_kana'] as String?,
      email: _client.auth.currentUser!.email ?? '',
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
}

final profileGatewayProvider = Provider<ProfileGateway>((ref) => SupabaseProfileGateway(SupabaseClientHolder.instance));

final myProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) {
  return ref.watch(profileGatewayProvider).fetchMyProfile();
});

final lineLinkedProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(profileGatewayProvider).isLineLinked();
});
