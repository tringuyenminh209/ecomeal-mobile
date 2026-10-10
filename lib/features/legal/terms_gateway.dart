import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

// UC-36: bản điều khoản hiện hành của app. Sửa nội dung SCR-M10/M11 (ARB termsArticle*/privacySection*) theo hướng
// quan trọng thì đổi hằng này (cùng ngày với legalEnactedOn) → mọi khách hàng đã đăng nhập phải đồng ý lại.
const currentTermsVersion = '2026-10-09';

// Trang của site công khai mở bằng trình duyệt ngoài: liên hệ (SCR-P04, khung 「お問い合わせ」 cuối SCR-M10/M11) và
// 特定商取引法に基づく表記 (SCR-P06, dòng trong 「アプリについて」 của SCR-M07). Bản tiếng Anh nằm dưới /en/.
const _publicSiteUrl = 'https://ecomeal-site.vercel.app';
const contactPageUrl = '$_publicSiteUrl/contact/';
String tokushohoPageUrl(String languageCode) => languageCode == 'en' ? '$_publicSiteUrl/en/tokushoho/' : '$_publicSiteUrl/tokushoho/';

abstract class TermsGateway {
  // users.terms_version của chính mình (NULL: tài khoản tạo trước 0044, chưa từng đồng ý).
  Future<String?> fetchAcceptedVersion(String userId);
  Future<void> acceptTerms(String version); // API-050
}

class SupabaseTermsGateway implements TermsGateway {
  SupabaseTermsGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<String?> fetchAcceptedVersion(String userId) async {
    final row = await _client.from('users').select('terms_version').eq('id', userId).single();
    return row['terms_version'] as String?;
  }

  // terms_version không nằm trong GRANT UPDATE cột (0044) — chỉ ghi được qua RPC, server tự lấy now().
  @override
  Future<void> acceptTerms(String version) async {
    await _client.rpc('accept_terms', params: {'p_version': version});
  }
}

final termsGatewayProvider = Provider<TermsGateway>((ref) => SupabaseTermsGateway(SupabaseClientHolder.instance));

// Theo userId: đổi tài khoản trên cùng máy không dùng lại kết quả của người trước.
final acceptedTermsVersionProvider = FutureProvider.autoDispose.family<String?, String>((ref, userId) {
  return ref.watch(termsGatewayProvider).fetchAcceptedVersion(userId);
});
