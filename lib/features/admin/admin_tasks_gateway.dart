import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

// Tab 対応 của app vận hành (SCR-A03〜A06). Cùng RPC / query với Web Admin (SCR-W05・W19・W14・W11) — mọi thao tác ghi đều kiểm
// is_admin() (aal2) ở server.

class AdminIssue {
  const AdminIssue({
    required this.id,
    required this.orderId,
    required this.category,
    required this.message,
    required this.isOpen,
    required this.refundAmount,
    required this.createdAt,
    required this.pricePaid,
    required this.refundable,
    required this.plannedTime,
    required this.restaurantName,
    required this.stopName,
    required this.customerName,
  });
  final String id;
  final String orderId;
  final String category;
  final String message;
  final bool isOpen;
  final int? refundAmount; // khi đã xử lý
  final DateTime createdAt;
  final int pricePaid;
  final int refundable; // giá đã trả − đã hoàn trước đó (0050)
  final DateTime plannedTime;
  final String restaurantName;
  final String? stopName;
  final String? customerName; // null: tài khoản đã xoá
}

// 運行の連絡（SCR-D06 → API-086, 0067）
class AdminDriverReport {
  const AdminDriverReport({
    required this.id,
    required this.category,
    required this.delayMinutes,
    required this.message,
    required this.isOpen,
    required this.resolution,
    required this.createdAt,
    required this.plateNumber,
    required this.driverName,
    required this.nextStopName,
  });
  final String id;
  final String category; // delay | vehicle | food | other
  final int? delayMinutes; // chỉ khi delay (30 = 30分以上)
  final String? message;
  final bool isOpen;
  final String? resolution;
  final DateTime createdAt;
  final String plateNumber;
  final String? driverName; // null: tài khoản đã xoá
  final String? nextStopName; // điểm chưa rời đầu tiên lúc đọc; null: đã chạy hết tuyến
}

class AdminRestaurant {
  const AdminRestaurant({
    required this.id,
    required this.name,
    required this.nameKana,
    required this.address,
    required this.contact,
    required this.closingTime,
    required this.plDocPath,
    required this.createdAt,
    required this.isApproved,
    required this.rejectedAt,
    required this.rejectionReason,
    required this.applicantName,
  });
  final String id;
  final String name;
  final String? nameKana;
  final String address;
  final String? contact;
  final String closingTime;
  final String? plDocPath; // đường dẫn trong bucket pl_docs (không công khai)
  final DateTime createdAt;
  final bool isApproved;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String? applicantName;

  bool get isPending => !isApproved && rejectedAt == null;
}

// 店舗の担当者（get_restaurant_members、API-088、0069 — 運営だけ。メールは auth.users から）
// SCR-A03 店舗の詳細に出す最近の出品の件数
const recentBatchCount = 5;

class AdminRestaurantMember {
  const AdminRestaurantMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.isOwner,
    required this.createdAt,
  });
  final String userId;
  final String name;
  final String? email;
  final bool isOwner;
  final DateTime createdAt;
}

// 店舗の最近の出品（surplus_batches、RLS で運営が読める）
class AdminBatch {
  const AdminBatch({
    required this.id,
    required this.isConfirmed,
    required this.quantity,
    required this.unitPrice,
    required this.sellByAt,
  });
  final String id;
  final bool isConfirmed;
  final int quantity; // 確定数（なければ概算数）
  final int unitPrice;
  final DateTime sellByAt;
}

class AdminLicense {
  const AdminLicense({
    required this.driverId,
    required this.name,
    required this.status,
    required this.expiresOn,
    required this.submittedAt,
    required this.imagePath,
  });
  final String driverId;
  final String name;
  final String status; // none | submitted | verified | rejected
  final String? expiresOn;
  final DateTime? submittedAt;
  final String? imagePath;
}

class AdminInquiry {
  const AdminInquiry({
    required this.id,
    required this.type,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.message,
    required this.status,
    required this.adminNote,
    required this.createdAt,
  });
  final String id;
  final String type; // restaurant | driver | customer | other
  final String name;
  final String? companyName;
  final String email;
  final String? phone;
  final String message;
  final String status; // new | in_progress | done | rejected
  final String? adminNote;
  final DateTime createdAt;
}

// pl_insurance_doc_url lưu ".../storage/v1/object/pl_docs/{path}" (API-002) — tách lấy path để xin signed URL (cùng Web)
String? plDocPathFromUrl(String? url) {
  if (url == null) return null;
  final parts = url.split('/storage/v1/object/pl_docs/');
  return parts.length == 2 && parts[1].isNotEmpty ? parts[1] : null;
}

const _signedUrlSeconds = 300;

abstract class AdminTasksGateway {
  Future<List<AdminIssue>> fetchIssues();
  Future<void> resolveIssue(String issueId, {required int refund, required String resolution});
  Future<List<AdminRestaurant>> fetchRestaurants();
  // Trả về: đã gửi được mail / thông báo kết quả (API-035) hay chưa — việc duyệt đã chốt dù gửi lỗi
  Future<bool> decideRestaurant(String restaurantId, {required bool approve, String? reason});
  Future<String> plDocUrl(String path);
  Future<List<AdminRestaurantMember>> fetchRestaurantMembers(String restaurantId);
  Future<List<AdminBatch>> fetchRecentBatches(String restaurantId);
  Future<List<AdminLicense>> fetchLicenses();
  Future<String> licenseImageUrl(String path);
  Future<String?> assignedTruck(String driverId);
  Future<void> reviewLicense(String driverId, {required bool verify, String? expiresOn, String? reason});
  Future<List<AdminInquiry>> fetchInquiries();
  Future<void> updateInquiry(String inquiryId, {required String status, String? note});
  Future<List<AdminDriverReport>> fetchDriverReports();
  Future<void> resolveDriverReport(String reportId, {required String resolution});
}

class SupabaseAdminTasksGateway implements AdminTasksGateway {
  SupabaseAdminTasksGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<List<AdminIssue>> fetchIssues() async {
    final data = await _client.rpc('get_order_issues') as List;
    return [
      for (final j in data.cast<Map<String, dynamic>>())
        AdminIssue(
          id: j['id'] as String,
          orderId: j['order_id'] as String,
          category: j['category'] as String,
          message: j['message'] as String,
          isOpen: j['status'] == 'open',
          refundAmount: j['refund_amount'] as int?,
          createdAt: DateTime.parse(j['created_at'] as String),
          pricePaid: j['price_paid'] as int,
          refundable: j['refundable'] as int,
          plannedTime: DateTime.parse(j['planned_time'] as String),
          restaurantName: j['restaurant_name'] as String,
          stopName: j['stop_name'] as String?,
          customerName: j['customer_name'] as String?,
        ),
    ];
  }

  @override
  Future<void> resolveIssue(String issueId, {required int refund, required String resolution}) => _client.rpc(
    'resolve_order_issue',
    params: {'p_issue_id': issueId, 'p_refund_amount': refund, 'p_resolution': resolution},
  );

  @override
  Future<List<AdminRestaurant>> fetchRestaurants() async {
    final data = await _client
        .from('restaurants')
        .select(
          'id, name, name_kana, address, contact, closing_time, pl_insurance_doc_url, created_at, is_approved, '
          'rejected_at, rejection_reason, restaurant_members(users(name))',
        )
        .order('created_at', ascending: false)
        .limit(100);
    return [
      for (final r in data)
        AdminRestaurant(
          id: r['id'] as String,
          name: r['name'] as String,
          nameKana: r['name_kana'] as String?,
          address: r['address'] as String,
          contact: r['contact'] as String?,
          closingTime: r['closing_time'] as String,
          plDocPath: plDocPathFromUrl(r['pl_insurance_doc_url'] as String?),
          createdAt: DateTime.parse(r['created_at'] as String),
          isApproved: r['is_approved'] as bool,
          rejectedAt: r['rejected_at'] == null ? null : DateTime.parse(r['rejected_at'] as String),
          rejectionReason: r['rejection_reason'] as String?,
          applicantName:
              ((r['restaurant_members'] as List?)?.cast<Map<String, dynamic>>().firstOrNull?['users']
                      as Map<String, dynamic>?)?['name']
                  as String?,
        ),
    ];
  }

  @override
  Future<bool> decideRestaurant(String restaurantId, {required bool approve, String? reason}) async {
    await _client.rpc(
      'approve_restaurant',
      params: {
        'p_restaurant_id': restaurantId,
        'p_decision': approve ? 'approve' : 'reject',
        if (!approve) 'p_reason': reason,
      },
    );
    try {
      await _client.functions.invoke('notify-restaurant-review', body: {'restaurant_id': restaurantId});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> plDocUrl(String path) => _client.storage.from('pl_docs').createSignedUrl(path, _signedUrlSeconds);

  @override
  Future<List<AdminRestaurantMember>> fetchRestaurantMembers(String restaurantId) async {
    final data = await _client.rpc('get_restaurant_members', params: {'p_restaurant_id': restaurantId}) as List;
    return [
      for (final m in data.cast<Map<String, dynamic>>())
        AdminRestaurantMember(
          userId: m['user_id'] as String,
          name: m['name'] as String,
          email: m['email'] as String?,
          isOwner: m['role'] == 'owner',
          createdAt: DateTime.parse(m['created_at'] as String),
        ),
    ];
  }

  @override
  Future<List<AdminBatch>> fetchRecentBatches(String restaurantId) async {
    final data = await _client
        .from('surplus_batches')
        .select('id, stage, estimated_qty, confirmed_qty, unit_price, restaurant_sell_by_at')
        .eq('restaurant_id', restaurantId)
        .order('restaurant_sell_by_at', ascending: false)
        .limit(recentBatchCount);
    return [
      for (final b in data)
        AdminBatch(
          id: b['id'] as String,
          isConfirmed: b['stage'] == 'confirmed',
          quantity: (b['confirmed_qty'] ?? b['estimated_qty']) as int,
          unitPrice: b['unit_price'] as int,
          sellByAt: DateTime.parse(b['restaurant_sell_by_at'] as String),
        ),
    ];
  }

  @override
  Future<List<AdminLicense>> fetchLicenses() async {
    final data = await _client
        .from('driver_profiles')
        .select(
          'driver_id, license_status, license_expires_on, license_submitted_at, license_image_path, '
          'users!driver_profiles_driver_id_fkey(name)',
        )
        .eq('license_status', 'submitted')
        .order('license_submitted_at');
    return [
      for (final r in data)
        AdminLicense(
          driverId: r['driver_id'] as String,
          name: (r['users'] as Map<String, dynamic>)['name'] as String,
          status: r['license_status'] as String,
          expiresOn: r['license_expires_on'] as String?,
          submittedAt: r['license_submitted_at'] == null ? null : DateTime.parse(r['license_submitted_at'] as String),
          imagePath: r['license_image_path'] as String?,
        ),
    ];
  }

  @override
  Future<String> licenseImageUrl(String path) =>
      _client.storage.from('driver_licenses').createSignedUrl(path, _signedUrlSeconds);

  @override
  Future<String?> assignedTruck(String driverId) async {
    final row = await _client.from('trucks').select('plate_number').eq('driver_id', driverId).limit(1).maybeSingle();
    return row?['plate_number'] as String?;
  }

  @override
  Future<void> reviewLicense(String driverId, {required bool verify, String? expiresOn, String? reason}) => _client.rpc(
    'review_driver_license',
    params: {
      'p_driver_id': driverId,
      'p_decision': verify ? 'verify' : 'reject',
      'p_expires_on': expiresOn,
      'p_reason': reason,
    },
  );

  @override
  Future<List<AdminInquiry>> fetchInquiries() async {
    final data = await _client
        .from('inquiries')
        .select('id, type, name, company_name, email, phone, message, status, admin_note, created_at')
        .order('created_at', ascending: false)
        .limit(100);
    return [
      for (final r in data)
        AdminInquiry(
          id: r['id'] as String,
          type: r['type'] as String,
          name: r['name'] as String,
          companyName: r['company_name'] as String?,
          email: r['email'] as String,
          phone: r['phone'] as String?,
          message: r['message'] as String,
          status: r['status'] as String,
          adminNote: r['admin_note'] as String?,
          createdAt: DateTime.parse(r['created_at'] as String),
        ),
    ];
  }

  @override
  Future<void> updateInquiry(String inquiryId, {required String status, String? note}) => _client.rpc(
    'update_inquiry_status',
    params: {'p_inquiry_id': inquiryId, 'p_status': status, 'p_admin_note': note},
  );

  @override
  Future<List<AdminDriverReport>> fetchDriverReports() async {
    final data = await _client.rpc('get_driver_reports') as List;
    return [
      for (final j in data.cast<Map<String, dynamic>>())
        AdminDriverReport(
          id: j['id'] as String,
          category: j['category'] as String,
          delayMinutes: j['delay_minutes'] as int?,
          message: j['message'] as String?,
          isOpen: j['status'] == 'open',
          resolution: j['resolution'] as String?,
          createdAt: DateTime.parse(j['created_at'] as String),
          plateNumber: j['plate_number'] as String,
          driverName: j['driver_name'] as String?,
          nextStopName: j['next_stop_name'] as String?,
        ),
    ];
  }

  @override
  Future<void> resolveDriverReport(String reportId, {required String resolution}) =>
      _client.rpc('resolve_driver_report', params: {'p_report_id': reportId, 'p_resolution': resolution});
}

final adminTasksGatewayProvider = Provider<AdminTasksGateway>(
  (ref) => SupabaseAdminTasksGateway(SupabaseClientHolder.instance),
);

final adminIssuesProvider = FutureProvider.autoDispose<List<AdminIssue>>(
  (ref) => ref.watch(adminTasksGatewayProvider).fetchIssues(),
);
final adminRestaurantsProvider = FutureProvider.autoDispose<List<AdminRestaurant>>(
  (ref) => ref.watch(adminTasksGatewayProvider).fetchRestaurants(),
);
final adminRestaurantMembersProvider = FutureProvider.autoDispose.family<List<AdminRestaurantMember>, String>(
  (ref, restaurantId) => ref.watch(adminTasksGatewayProvider).fetchRestaurantMembers(restaurantId),
);
final adminRecentBatchesProvider = FutureProvider.autoDispose.family<List<AdminBatch>, String>(
  (ref, restaurantId) => ref.watch(adminTasksGatewayProvider).fetchRecentBatches(restaurantId),
);
final adminLicensesProvider = FutureProvider.autoDispose<List<AdminLicense>>(
  (ref) => ref.watch(adminTasksGatewayProvider).fetchLicenses(),
);
final adminInquiriesProvider = FutureProvider.autoDispose<List<AdminInquiry>>(
  (ref) => ref.watch(adminTasksGatewayProvider).fetchInquiries(),
);
final adminDriverReportsProvider = FutureProvider.autoDispose<List<AdminDriverReport>>(
  (ref) => ref.watch(adminTasksGatewayProvider).fetchDriverReports(),
);
