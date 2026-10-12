import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/jst_date.dart';
import '../../core/photo_picker.dart';
import '../../core/supabase_client.dart';

// App nhà hàng「EcoMeal Store」(ADR-015). Mọi dữ liệu đi qua gateway này để widget test thay bằng bản giả.

// Quán của tài khoản đang đăng nhập (restaurant_members → restaurants) + tên người đăng ký (SCR-S00 審査中).
class StoreRestaurant {
  const StoreRestaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.closingTime,
    required this.isApproved,
    required this.rejectedAt,
    required this.rejectionReason,
    required this.appliedAt,
    required this.applicantName,
    this.accountEmail = '',
  });
  final String id;
  final String name;
  final String address;
  final String closingTime; // 'HH:mm:ss' (restaurants.closing_time)
  final bool isApproved;
  final DateTime? rejectedAt; // != null: bị từ chối (0030) — chưa duyệt và chưa từ chối = 審査中
  final String? rejectionReason; // 0036
  final DateTime appliedAt;
  final String applicantName;
  final String accountEmail; // email đăng nhập của tài khoản này (SCR-S08)

  bool get isRejected => !isApproved && rejectedAt != null;
}

class StoreStop {
  const StoreStop({
    required this.name,
    required this.plannedTime,
    required this.departed,
    required this.allocatedQty,
    required this.remainingQty,
  });
  final String name;
  final DateTime plannedTime;
  final bool departed;
  final int allocatedQty; // số phân bổ cho điểm này (batch_route_stops.available_qty)
  final int remainingQty; // phân bổ − đơn còn hiệu lực (0062)
}

enum StoreBatchStatus { estimated, onSale, ended }

// 1 lô của quán (RPC get_store_batches, 0062 — chỉ số đếm, không có thông tin khách).
class StoreBatch {
  const StoreBatch({
    required this.id,
    required this.isConfirmed,
    required this.estimatedQty,
    required this.confirmedQty,
    required this.unitPrice,
    required this.sellByAt,
    required this.serviceDate,
    required this.photoUrl,
    required this.registeredAt,
    required this.collectionPlannedAt,
    required this.collectedAt,
    required this.temperatureCelsius,
    required this.collectedByName,
    required this.allergens,
    required this.reservedCount,
    required this.pickedUpCount,
    required this.stops,
  });
  final String id;
  final bool isConfirmed; // stage = 'confirmed' (tài xế đã xác nhận số thật lúc lấy hàng)
  final int estimatedQty;
  final int? confirmedQty;
  final int unitPrice;
  final DateTime sellByAt;
  final String serviceDate; // YYYY-MM-DD (routes.service_date)
  final String? photoUrl;
  final DateTime? registeredAt;
  final DateTime? collectionPlannedAt;
  final DateTime? collectedAt;
  final double? temperatureCelsius;
  final String? collectedByName;
  final List<String> allergens;
  final int reservedCount;
  final int pickedUpCount;
  final List<StoreStop> stops; // chỉ điểm bán công cộng, theo thứ tự tuyến

  // 概算 → 販売中（đã xác nhận, chưa quá hạn bán）→ 終了. Server chỉ có stage; mốc 終了 là hạn bán quán tự khai.
  StoreBatchStatus statusAt(DateTime now) {
    if (!isConfirmed) return StoreBatchStatus.estimated;
    return now.isBefore(sellByAt) ? StoreBatchStatus.onSale : StoreBatchStatus.ended;
  }

  int get remainingQty => stops.fold(0, (sum, s) => sum + s.remainingQty);
}

class StoreRevenue {
  const StoreRevenue({required this.orders, required this.revenue, required this.payout, required this.sharePct});
  final int orders;
  final int revenue;
  final int payout;
  final double sharePct;
}

class StoreRatingComment {
  const StoreRatingComment({required this.rating, required this.comment, required this.createdAt});
  final int rating;
  final String comment;
  final DateTime createdAt;
}

class StoreRatings {
  const StoreRatings({
    required this.count,
    required this.average,
    required this.distribution,
    required this.recentComments,
  });
  final int count;
  final double? average; // null: chưa có đánh giá
  final Map<int, int> distribution; // 1..5 → số lượt
  final List<StoreRatingComment> recentComments;
}

class PhotoRemoval {
  const PhotoRemoval({required this.id, required this.reason});
  final String id;
  final String reason;
}

// 1 kỳ quyết toán đã chốt (settlements, 0049 — chỉ thành viên của quán đọc được, RLS)
class StoreSettlement {
  const StoreSettlement({
    required this.id,
    required this.periodMonth,
    required this.orders,
    required this.sales,
    required this.payout,
    required this.confirmedAt,
    required this.paidAt,
  });
  final String id;
  final String periodMonth; // 'YYYY-MM-01'
  final int orders;
  final int sales;
  final int payout;
  final DateTime confirmedAt;
  final DateTime? paidAt; // != null: đã chuyển tiền (status = 'paid')

  // 「ST-2026-09-0A1F」— cùng quy tắc với Web (settlement-number.ts): tháng + 4 ký tự cuối của id
  String get number {
    final hex = id.replaceAll('-', '');
    return 'ST-${periodMonth.substring(0, 7)}-${hex.substring(hex.length - 4).toUpperCase()}';
  }
}

enum InquiryStatus { received, inProgress, done, rejected }

class StoreInquiry {
  const StoreInquiry({required this.id, required this.message, required this.status, required this.createdAt});
  final String id;
  final String message;
  final InquiryStatus status;
  final DateTime createdAt;
}

class AllergenType {
  const AllergenType({required this.id, required this.code, required this.nameJa, required this.nameEn});
  final String id;
  final String code;
  final String nameJa;
  final String nameEn;
}

class BatchIngredient {
  const BatchIngredient({required this.name, required this.origin});
  final String name;
  final String origin; // '' = không ghi xuất xứ
}

// Nội dung form SCR-S02 gửi lên create_surplus_batch (API-004)
class StoreBatchDraft {
  const StoreBatchDraft({
    required this.restaurantId,
    required this.estimatedQty,
    required this.unitPrice,
    required this.sellByAt,
    required this.allergenTypeIds,
    required this.ingredients,
    this.noAllergens = false,
    this.photo,
  });
  final String restaurantId;
  final int estimatedQty;
  final int unitPrice;
  final DateTime sellByAt;
  final List<String> allergenTypeIds;
  final List<BatchIngredient> ingredients;
  // 0068: dị ứng rỗng thì phải xác nhận 「アレルゲンは含まれていません」 (RPC từ chối bằng E-REST-018)
  final bool noAllergens;
  final PickedPhoto? photo;
}

// Lỗi ở bước tải ảnh (lô CHƯA được tạo) — để báo đúng việc người dùng cần làm (cùng cách Web: BatchPhotoUploadError)
class BatchPhotoUploadException implements Exception {
  const BatchPhotoUploadException(this.cause);
  final Object cause;
}

abstract class StoreGateway {
  Future<List<AllergenType>> fetchAllergenTypes();
  Future<String> registerBatch(StoreBatchDraft draft); // → id lô mới
  Future<StoreRestaurant?> fetchMyRestaurant(String userId);
  Future<List<StoreBatch>> fetchTodayBatches(String restaurantId);
  Future<StoreBatch?> fetchBatch(String restaurantId, String batchId);
  Future<StoreRevenue> fetchRevenue(String restaurantId, {required String from, required String to});
  Future<StoreRatings> fetchRatings(String restaurantId, {int days = 30});
  Future<List<PhotoRemoval>> fetchPhotoRemovals(String restaurantId);
  Future<void> acknowledgePhotoRemovals(String restaurantId);
  Future<List<StoreSettlement>> fetchSettlements(String restaurantId);
  Future<List<StoreInquiry>> fetchInquiries(String userId);
  Future<void> submitInquiry(String message);
}

class SupabaseStoreGateway implements StoreGateway {
  SupabaseStoreGateway(this._client);
  final SupabaseClient _client;

  String? _photoUrl(String? path) => path == null ? null : _client.storage.from('batch_photos').getPublicUrl(path);

  @override
  Future<List<AllergenType>> fetchAllergenTypes() async {
    final data = await _client.from('allergen_types').select('id, code, name_ja, name_en');
    return [
      for (final r in data)
        AllergenType(
          id: r['id'] as String,
          code: r['code'] as String,
          nameJa: r['name_ja'] as String,
          nameEn: r['name_en'] as String,
        ),
    ];
  }

  @override
  Future<String> registerBatch(StoreBatchDraft draft) async {
    // Ảnh (nếu có) tải lên TRƯỚC, rồi tạo lô kèm đường dẫn trong cùng 1 RPC (create_surplus_batch kiểm file có thật và đúng
    // thư mục quán). {restaurant_id}/{ngẫu nhiên}.{đuôi}: tên ngẫu nhiên để không lộ tên file gốc (có thể chứa tên quán).
    final photo = draft.photo;
    String? path;
    if (photo != null) {
      // Bucket chỉ nhận JPEG / PNG / WebP (0038); image_picker nén ảnh camera thành JPEG
      final ext = switch (photo.extension) {
        'png' => 'png',
        'webp' => 'webp',
        _ => 'jpg',
      };
      path = '${draft.restaurantId}/${const Uuid().v4()}.$ext';
      try {
        await _client.storage
            .from('batch_photos')
            .uploadBinary(
              path,
              photo.bytes,
              fileOptions: FileOptions(contentType: ext == 'jpg' ? 'image/jpeg' : 'image/$ext'),
            );
      } catch (e) {
        throw BatchPhotoUploadException(e);
      }
    }
    try {
      final data =
          await _client.rpc(
                'create_surplus_batch',
                params: {
                  'p_restaurant_id': draft.restaurantId,
                  'p_estimated_qty': draft.estimatedQty,
                  'p_unit_price': draft.unitPrice,
                  'p_restaurant_sell_by_at': draft.sellByAt.toUtc().toIso8601String(),
                  'p_allergen_type_ids': draft.allergenTypeIds,
                  'p_ingredients': [
                    for (final i in draft.ingredients)
                      {'ingredient_name': i.name, 'origin': i.origin.isEmpty ? null : i.origin},
                  ],
                  'p_photo_path': path,
                  'p_no_allergens': draft.noAllergens,
                },
              )
              as Map<String, dynamic>;
      return data['surplus_batch_id'] as String;
    } catch (e) {
      // Lô không được tạo → ảnh vừa tải thành file mồ côi: dọn ngay (policy 0038 chỉ cho xoá ảnh chưa gắn lô). Storage không
      // báo lỗi khi RLS chặn xoá (第48回) → kiểm số object đã xoá. Vẫn ném lỗi RPC gốc.
      if (path != null) {
        try {
          final removed = await _client.storage.from('batch_photos').remove([path]);
          if (removed.isEmpty) debugPrint('batch photo cleanup removed nothing: $path');
        } catch (cleanup) {
          debugPrint('batch photo cleanup failed: $path $cleanup');
        }
      }
      rethrow;
    }
  }

  @override
  Future<StoreRestaurant?> fetchMyRestaurant(String userId) async {
    final member = await _client
        .from('restaurant_members')
        .select('restaurants(id, name, address, closing_time, is_approved, rejected_at, rejection_reason, created_at)')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();
    final r = member?['restaurants'] as Map<String, dynamic>?;
    if (r == null) return null; // chủ quán chưa gửi đăng ký (W02 trên Web)
    final user = await _client.from('users').select('name').eq('id', userId).single();
    return StoreRestaurant(
      id: r['id'] as String,
      name: r['name'] as String,
      address: r['address'] as String,
      closingTime: r['closing_time'] as String,
      isApproved: r['is_approved'] as bool,
      rejectedAt: r['rejected_at'] == null ? null : DateTime.parse(r['rejected_at'] as String),
      rejectionReason: r['rejection_reason'] as String?,
      appliedAt: DateTime.parse(r['created_at'] as String),
      applicantName: user['name'] as String,
      accountEmail: _client.auth.currentUser?.email ?? '',
    );
  }

  StoreBatch _batch(Map<String, dynamic> j) {
    DateTime? at(String key) => j[key] == null ? null : DateTime.parse(j[key] as String);
    return StoreBatch(
      id: j['id'] as String,
      isConfirmed: j['stage'] == 'confirmed',
      estimatedQty: j['estimated_qty'] as int,
      confirmedQty: j['confirmed_qty'] as int?,
      unitPrice: j['unit_price'] as int,
      sellByAt: DateTime.parse(j['sell_by_at'] as String),
      serviceDate: j['service_date'] as String,
      photoUrl: _photoUrl(j['photo_path'] as String?),
      registeredAt: at('registered_at'),
      collectionPlannedAt: at('collection_planned_at'),
      collectedAt: at('collected_at'),
      temperatureCelsius: (j['temperature_celsius'] as num?)?.toDouble(),
      collectedByName: j['collected_by_name'] as String?,
      allergens: (j['allergens'] as List).cast<String>(),
      reservedCount: j['reserved_count'] as int,
      pickedUpCount: j['picked_up_count'] as int,
      stops: [
        for (final s in (j['stops'] as List).cast<Map<String, dynamic>>())
          StoreStop(
            name: s['name'] as String,
            plannedTime: DateTime.parse(s['planned_time'] as String),
            departed: s['departed'] as bool,
            allocatedQty: s['allocated_qty'] as int,
            remainingQty: s['remaining_qty'] as int,
          ),
      ],
    );
  }

  @override
  Future<List<StoreBatch>> fetchTodayBatches(String restaurantId) async {
    final data = await _client.rpc('get_store_batches', params: {'p_restaurant_id': restaurantId}) as List;
    return data.cast<Map<String, dynamic>>().map(_batch).toList();
  }

  @override
  Future<StoreBatch?> fetchBatch(String restaurantId, String batchId) async {
    final data =
        await _client.rpc('get_store_batches', params: {'p_restaurant_id': restaurantId, 'p_batch_id': batchId})
            as List;
    return data.isEmpty ? null : _batch(data.first as Map<String, dynamic>);
  }

  @override
  Future<StoreRevenue> fetchRevenue(String restaurantId, {required String from, required String to}) async {
    final j =
        await _client.rpc(
              'get_my_restaurant_revenue',
              params: {'p_restaurant_id': restaurantId, 'p_from': from, 'p_to': to},
            )
            as Map<String, dynamic>;
    return StoreRevenue(
      orders: j['orders'] as int,
      revenue: j['revenue'] as int,
      payout: j['payout'] as int,
      sharePct: (j['revenue_share_pct'] as num).toDouble(),
    );
  }

  @override
  Future<StoreRatings> fetchRatings(String restaurantId, {int days = 30}) async {
    final j =
        await _client.rpc('get_restaurant_ratings', params: {'p_restaurant_id': restaurantId, 'p_days': days})
            as Map<String, dynamic>;
    final dist = j['distribution'] as Map<String, dynamic>;
    return StoreRatings(
      count: j['count'] as int,
      average: (j['average'] as num?)?.toDouble(),
      distribution: {for (var i = 1; i <= 5; i++) i: dist['$i'] as int},
      recentComments: [
        for (final c in (j['recent_comments'] as List).cast<Map<String, dynamic>>())
          StoreRatingComment(
            rating: c['rating'] as int,
            comment: c['comment'] as String,
            createdAt: DateTime.parse(c['created_at'] as String),
          ),
      ],
    );
  }

  @override
  Future<List<PhotoRemoval>> fetchPhotoRemovals(String restaurantId) async {
    final data = await _client
        .from('batch_photo_removals')
        .select('id, reason')
        .eq('restaurant_id', restaurantId)
        .isFilter('acknowledged_at', null)
        .order('created_at', ascending: false)
        .limit(10);
    return [for (final r in data) PhotoRemoval(id: r['id'] as String, reason: r['reason'] as String)];
  }

  @override
  Future<void> acknowledgePhotoRemovals(String restaurantId) =>
      _client.rpc('acknowledge_batch_photo_removals', params: {'p_restaurant_id': restaurantId});

  @override
  Future<List<StoreSettlement>> fetchSettlements(String restaurantId) async {
    final data = await _client
        .from('settlements')
        .select('id, period_month, orders, sales, payout, confirmed_at, paid_at')
        .eq('restaurant_id', restaurantId)
        .order('period_month', ascending: false)
        .limit(36);
    return [
      for (final r in data)
        StoreSettlement(
          id: r['id'] as String,
          periodMonth: r['period_month'] as String,
          orders: r['orders'] as int,
          sales: r['sales'] as int,
          payout: r['payout'] as int,
          confirmedAt: DateTime.parse(r['confirmed_at'] as String),
          paidAt: r['paid_at'] == null ? null : DateTime.parse(r['paid_at'] as String),
        ),
    ];
  }

  @override
  Future<List<StoreInquiry>> fetchInquiries(String userId) async {
    final data = await _client
        .from('inquiries')
        .select('id, message, status, created_at')
        .eq('submitted_by', userId)
        .order('created_at', ascending: false)
        .limit(20);
    return [
      for (final r in data)
        StoreInquiry(
          id: r['id'] as String,
          message: r['message'] as String,
          status: switch (r['status']) {
            'in_progress' => InquiryStatus.inProgress,
            'done' => InquiryStatus.done,
            'rejected' => InquiryStatus.rejected,
            _ => InquiryStatus.received,
          },
          createdAt: DateTime.parse(r['created_at'] as String),
        ),
    ];
  }

  // API-031 submit-inquiry (Edge Function): người gửi là quán đăng nhập → server tự gắn restaurant_id / submitted_by
  @override
  Future<void> submitInquiry(String message) async {
    await _client.functions.invoke('submit-inquiry', body: {'message': message});
  }
}

final storeGatewayProvider = Provider<StoreGateway>((ref) => SupabaseStoreGateway(SupabaseClientHolder.instance));

// Theo userId: đăng xuất rồi tài khoản khác đăng nhập trên cùng máy thì không thấy quán của người trước (bài học 第49回).
final myRestaurantProvider = FutureProvider.autoDispose.family<StoreRestaurant?, String>(
  (ref, userId) => ref.watch(storeGatewayProvider).fetchMyRestaurant(userId),
);

// Danh mục 28 品目 (0002) — ít đổi, giữ suốt phiên (không autoDispose)
final allergenTypesProvider = FutureProvider<List<AllergenType>>(
  (ref) => ref.watch(storeGatewayProvider).fetchAllergenTypes(),
);

final storeTodayBatchesProvider = FutureProvider.autoDispose.family<List<StoreBatch>, String>(
  (ref, restaurantId) => ref.watch(storeGatewayProvider).fetchTodayBatches(restaurantId),
);

final storeBatchProvider = FutureProvider.autoDispose.family<StoreBatch?, ({String restaurantId, String batchId})>(
  (ref, key) => ref.watch(storeGatewayProvider).fetchBatch(key.restaurantId, key.batchId),
);

// Tháng này theo JST: ngày 1 → hôm nay (cùng kỳ với thẻ 今月の売上 của Web, MyRevenueCard)
final storeMonthRevenueProvider = FutureProvider.autoDispose.family<StoreRevenue, String>((ref, restaurantId) {
  final today = todayInTokyo();
  return ref.watch(storeGatewayProvider).fetchRevenue(restaurantId, from: '${today.substring(0, 8)}01', to: today);
});

final storeRatingsProvider = FutureProvider.autoDispose.family<StoreRatings, String>(
  (ref, restaurantId) => ref.watch(storeGatewayProvider).fetchRatings(restaurantId),
);

final storeSettlementsProvider = FutureProvider.autoDispose.family<List<StoreSettlement>, String>(
  (ref, restaurantId) => ref.watch(storeGatewayProvider).fetchSettlements(restaurantId),
);

final storeInquiriesProvider = FutureProvider.autoDispose.family<List<StoreInquiry>, String>(
  (ref, userId) => ref.watch(storeGatewayProvider).fetchInquiries(userId),
);

final photoRemovalsProvider = FutureProvider.autoDispose.family<List<PhotoRemoval>, String>(
  (ref, restaurantId) => ref.watch(storeGatewayProvider).fetchPhotoRemovals(restaurantId),
);
