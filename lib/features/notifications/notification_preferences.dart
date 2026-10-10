import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

// Bật / tắt từng loại thông báo (0060, API-080〜081). Server chỉ trả các loại thuộc app của role này, và khi tắt thì
// không tạo yêu cầu gửi push (không chỉ ẩn ở app). Loại bắt buộc (is_mandatory) không tắt được.
class NotificationPreference {
  const NotificationPreference({required this.type, required this.isMandatory, required this.isEnabled});
  final String type;
  final bool isMandatory;
  final bool isEnabled;
}

abstract class NotificationPreferencesGateway {
  Future<List<NotificationPreference>> fetch();
  Future<void> set(String type, {required bool enabled});
}

class SupabaseNotificationPreferencesGateway implements NotificationPreferencesGateway {
  SupabaseNotificationPreferencesGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<List<NotificationPreference>> fetch() async {
    final data = await _client.rpc('get_my_notification_preferences') as List;
    return [
      for (final p in data.cast<Map<String, dynamic>>())
        NotificationPreference(
          type: p['type'] as String,
          isMandatory: p['is_mandatory'] as bool,
          isEnabled: p['is_enabled'] as bool,
        ),
    ];
  }

  @override
  Future<void> set(String type, {required bool enabled}) =>
      _client.rpc('set_notification_preference', params: {'p_type': type, 'p_is_enabled': enabled});
}

final notificationPreferencesGatewayProvider = Provider<NotificationPreferencesGateway>(
  (ref) => SupabaseNotificationPreferencesGateway(SupabaseClientHolder.instance),
);

final notificationPreferencesProvider = FutureProvider.autoDispose.family<List<NotificationPreference>, String>(
  (ref, userId) => ref.watch(notificationPreferencesGatewayProvider).fetch(),
);
