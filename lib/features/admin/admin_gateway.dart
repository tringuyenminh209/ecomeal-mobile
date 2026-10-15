import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/mfa_http_client.dart';
import '../../core/supabase_client.dart';

// App vận hành「EcoMeal Admin」(ADR-015). Mọi API của admin bị chặn ở server khi chưa qua 2 bước (0058: is_admin() cần
// aal2, pre-request chặn mọi request aal1 trừ đọc hồ sơ / API-077) — màn 2 bước ở app chỉ là hướng dẫn.

// Nên hiện gì sau khi đăng nhập (cùng quy tắc với Web: lib/admin-mfa.ts)
sealed class AdminMfaState {
  const AdminMfaState();
}

class AdminMfaOk extends AdminMfaState {
  const AdminMfaOk();
}

class AdminMfaChallenge extends AdminMfaState {
  const AdminMfaChallenge(this.factorId);
  final String factorId;
}

class AdminMfaEnroll extends AdminMfaState {
  const AdminMfaEnroll();
}

class TotpEnrollment {
  const TotpEnrollment({required this.factorId, required this.secret, required this.uri});
  final String factorId;
  final String secret;
  final String uri; // otpauth:// — nội dung mã QR
}

class AdminBadges {
  const AdminBadges({
    required this.openIssues,
    required this.pendingRestaurants,
    required this.pendingLicenses,
    required this.newInquiries,
    this.latestIssue,
    this.latestRestaurant,
    this.latestLicense,
    this.newInquiryTypes = const {},
    this.openDriverReports = 0,
    this.latestDriverReport,
  });
  final int openIssues;
  final int pendingRestaurants;
  final int pendingLicenses;
  final int newInquiries;
  final ({String orderId, String category, DateTime createdAt})? latestIssue;
  final ({String name, DateTime createdAt})? latestRestaurant;
  final ({String driverName, DateTime? submittedAt})? latestLicense;
  final Map<String, int> newInquiryTypes; // inquiries.type → số câu hỏi mới
  final int openDriverReports; // 0067: 運行の連絡 chưa xử lý
  final ({String plateNumber, String category, DateTime createdAt})? latestDriverReport;
}

class AdminTonight {
  const AdminTonight({
    required this.trucksTotal,
    required this.trucksRunning,
    required this.stopsTotal,
    required this.stopsDone,
    required this.reserved,
    required this.pickedUp,
  });
  final int trucksTotal;
  final int trucksRunning;
  final int stopsTotal;
  final int stopsDone;
  final int reserved;
  final int pickedUp;
}

class AdminRouteStop {
  const AdminRouteStop({
    required this.name,
    required this.lat,
    required this.lng,
    required this.plannedTime,
    required this.departed,
  });
  final String name;
  final double lat;
  final double lng;
  final DateTime plannedTime;
  final bool departed; // actual_departure_at != null
}

enum AdminRouteStatus { waiting, running, done }

// 1 tuyến (= 1 xe) đêm nay cho SCR-A02 (cùng nguồn với Web SCR-W07)
class AdminRoute {
  const AdminRoute({
    required this.id,
    required this.plateNumber,
    required this.driverName,
    required this.stops,
    required this.reservedCount,
    required this.lat,
    required this.lng,
  });
  final String id;
  final String plateNumber;
  final String? driverName;
  final List<AdminRouteStop> stops; // theo sequence
  final int? reservedCount; // null: chưa đọc được (API-027 lỗi) — chỉ ẩn con số này
  final double? lat; // vị trí GPS mới nhất (null: chưa gửi)
  final double? lng;

  // Cùng quy tắc với Web routeStatus.ts: hết điểm đã rời → 完了; có điểm đã rời → 走行中; chưa rời điểm nào → 待機
  AdminRouteStatus get status {
    final departed = stops.where((s) => s.departed).length;
    if (stops.isNotEmpty && departed == stops.length) return AdminRouteStatus.done;
    return departed > 0 ? AdminRouteStatus.running : AdminRouteStatus.waiting;
  }

  AdminRouteStop? get nextStop => stops.where((s) => !s.departed).firstOrNull;
}

abstract class AdminGateway {
  Future<List<AdminRoute>> fetchTonightRoutes(String serviceDate);
  Future<AdminMfaState> resolveMfaState();
  Future<TotpEnrollment> startEnrollment();
  Future<void> verify(String factorId, String code);
  Future<String> fetchMyName(String userId);
  Future<AdminBadges> fetchBadges();
  Future<AdminTonight> fetchTonight();
}

// Tên factor giống Web (lib/admin-mfa.ts): app và Web dùng chung 1 factor TOTP của tài khoản
const _totpFriendlyName = 'EcoMeal 管理画面';

class SupabaseAdminGateway implements AdminGateway {
  SupabaseAdminGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<AdminMfaState> resolveMfaState() async {
    // API-077: có bắt buộc không (aal1 vẫn gọi được — pre-request cho qua)
    final required = await _client.rpc('admin_mfa_required');
    if (required != true) return const AdminMfaOk();
    if (_client.auth.mfa.getAuthenticatorAssuranceLevel().currentLevel == AuthenticatorAssuranceLevels.aal2) {
      return const AdminMfaOk();
    }
    final factors = await _client.auth.mfa.listFactors();
    final verified = factors.totp.where((f) => f.status == FactorStatus.verified).firstOrNull;
    return verified == null ? const AdminMfaEnroll() : AdminMfaChallenge(verified.id);
  }

  @override
  Future<TotpEnrollment> startEnrollment() async {
    // Lần đăng ký trước bỏ dở để lại factor "chưa xác nhận" cùng tên → xoá rồi mới đăng ký lại (giống Web)
    final factors = await _client.auth.mfa.listFactors();
    for (final f in factors.all.where((f) => f.factorType == FactorType.totp && f.status != FactorStatus.verified)) {
      await _client.auth.mfa.unenroll(f.id);
    }
    final r = await _client.auth.mfa.enroll(factorType: FactorType.totp, friendlyName: _totpFriendlyName);
    final totp = r.totp!;
    return TotpEnrollment(factorId: r.id, secret: totp.secret, uri: totp.uri);
  }

  // Thành công → session lên aal2 (Supabase tự làm mới token)
  @override
  Future<void> verify(String factorId, String code) =>
      retryOnMfaIpMismatch(() => _client.auth.mfa.challengeAndVerify(factorId: factorId, code: code));

  @override
  Future<List<AdminRoute>> fetchTonightRoutes(String serviceDate) async {
    final routes = await _client
        .from('routes')
        .select(
          'id, truck_id, trucks(plate_number, users(name)), '
          'route_stops(sequence, planned_time, actual_departure_at, stop_locations(name, lat, lng))',
        )
        .eq('service_date', serviceDate);
    // Số đơn đặt: admin không đọc trực tiếp orders → RPC đếm (API-027). Lỗi thì chỉ ẩn con số
    Map<String, int>? counts;
    try {
      final rows = await _client.rpc('get_route_reservation_counts', params: {'p_service_date': serviceDate}) as List;
      counts = {for (final r in rows.cast<Map<String, dynamic>>()) r['route_id'] as String: r['reserved_count'] as int};
    } catch (_) {}
    return [for (final r in routes) await _route(r, counts)];
  }

  Future<AdminRoute> _route(Map<String, dynamic> r, Map<String, int>? counts) async {
    // Vị trí mới nhất của TỪNG xe bằng limit 1 (không kéo cả lịch sử GPS — bài học 第51回)
    final loc = await _client
        .from('truck_locations')
        .select('lat, lng')
        .eq('truck_id', r['truck_id'] as String)
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final truck = r['trucks'] as Map<String, dynamic>;
    final stops = (r['route_stops'] as List).cast<Map<String, dynamic>>()
      ..sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));
    return AdminRoute(
      id: r['id'] as String,
      plateNumber: truck['plate_number'] as String,
      driverName: (truck['users'] as Map<String, dynamic>?)?['name'] as String?,
      stops: [
        for (final s in stops)
          AdminRouteStop(
            name: (s['stop_locations'] as Map<String, dynamic>)['name'] as String,
            lat: ((s['stop_locations'] as Map<String, dynamic>)['lat'] as num).toDouble(),
            lng: ((s['stop_locations'] as Map<String, dynamic>)['lng'] as num).toDouble(),
            plannedTime: DateTime.parse(s['planned_time'] as String),
            departed: s['actual_departure_at'] != null,
          ),
      ],
      reservedCount: counts?[r['id'] as String],
      lat: (loc?['lat'] as num?)?.toDouble(),
      lng: (loc?['lng'] as num?)?.toDouble(),
    );
  }

  @override
  Future<String> fetchMyName(String userId) async =>
      (await _client.from('users').select('name').eq('id', userId).single())['name'] as String;

  @override
  Future<AdminBadges> fetchBadges() async {
    final j = await _client.rpc('get_admin_badges') as Map<String, dynamic>;
    final issue = j['latest_issue'] as Map<String, dynamic>?;
    final restaurant = j['latest_restaurant'] as Map<String, dynamic>?;
    final license = j['latest_license'] as Map<String, dynamic>?;
    final report = j['latest_driver_report'] as Map<String, dynamic>?;
    return AdminBadges(
      openIssues: j['open_issues'] as int,
      pendingRestaurants: j['pending_restaurants'] as int,
      pendingLicenses: j['pending_licenses'] as int,
      newInquiries: j['new_inquiries'] as int,
      latestIssue: issue == null
          ? null
          : (
              orderId: issue['order_id'] as String,
              category: issue['category'] as String,
              createdAt: DateTime.parse(issue['created_at'] as String),
            ),
      latestRestaurant: restaurant == null
          ? null
          : (name: restaurant['name'] as String, createdAt: DateTime.parse(restaurant['created_at'] as String)),
      latestLicense: license == null
          ? null
          : (
              driverName: license['driver_name'] as String,
              submittedAt: license['submitted_at'] == null ? null : DateTime.parse(license['submitted_at'] as String),
            ),
      newInquiryTypes: (j['new_inquiry_types'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as int)),
      // 0067 より前のサーバーにはキーが無い → 0 件として扱う
      openDriverReports: j['open_driver_reports'] as int? ?? 0,
      latestDriverReport: report == null
          ? null
          : (
              plateNumber: report['plate_number'] as String,
              category: report['category'] as String,
              createdAt: DateTime.parse(report['created_at'] as String),
            ),
    );
  }

  @override
  Future<AdminTonight> fetchTonight() async {
    final j = await _client.rpc('get_admin_tonight') as Map<String, dynamic>;
    return AdminTonight(
      trucksTotal: j['trucks_total'] as int,
      trucksRunning: j['trucks_running'] as int,
      stopsTotal: j['stops_total'] as int,
      stopsDone: j['stops_done'] as int,
      reserved: j['reserved'] as int,
      pickedUp: j['picked_up'] as int,
    );
  }
}

final adminGatewayProvider = Provider<AdminGateway>((ref) => SupabaseAdminGateway(SupabaseClientHolder.instance));

// Theo userId (bài học 第49回)
final adminMfaStateProvider = FutureProvider.autoDispose.family<AdminMfaState, String>(
  (ref, userId) => ref.watch(adminGatewayProvider).resolveMfaState(),
);
final adminNameProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, userId) => ref.watch(adminGatewayProvider).fetchMyName(userId),
);
final adminBadgesProvider = FutureProvider.autoDispose<AdminBadges>(
  (ref) => ref.watch(adminGatewayProvider).fetchBadges(),
);
final adminRoutesProvider = FutureProvider.autoDispose.family<List<AdminRoute>, String>(
  (ref, serviceDate) => ref.watch(adminGatewayProvider).fetchTonightRoutes(serviceDate),
);
final adminTonightProvider = FutureProvider.autoDispose<AdminTonight>(
  (ref) => ref.watch(adminGatewayProvider).fetchTonight(),
);
