import 'package:ecomeal_mobile/features/store/store_gateway.dart';

// App nhà hàng: dữ liệu trả về cố định, ghi lại thao tác (đã xác nhận thông báo ảnh bị gỡ…)
class FakeStoreGateway implements StoreGateway {
  FakeStoreGateway({
    this.restaurant,
    this.batches = const [],
    this.batchesError = false,
    this.removals = const [],
    this.allergenTypes = const [],
    this.registerError,
    this.settlements = const [],
    this.inquiries = const [],
    this.inquiryError,
  });
  StoreRestaurant? restaurant;
  List<StoreBatch> batches;
  bool batchesError;
  List<PhotoRemoval> removals;
  int acknowledged = 0;
  List<AllergenType> allergenTypes;
  Object? registerError; // != null: registerBatch ném lỗi này
  final drafts = <StoreBatchDraft>[];
  List<StoreSettlement> settlements;
  List<StoreInquiry> inquiries;
  Object? inquiryError; // != null: submitInquiry ném lỗi này
  final sentInquiries = <String>[];
  bool revenueError = false; // true: fetchRevenue ném lỗi (audit S07)
  bool ratingsError = false;

  @override
  Future<List<StoreSettlement>> fetchSettlements(String restaurantId) async => settlements;

  @override
  Future<List<StoreInquiry>> fetchInquiries(String userId) async => inquiries;

  @override
  Future<void> submitInquiry(String message) async {
    final error = inquiryError;
    if (error != null) throw error;
    sentInquiries.add(message);
  }

  @override
  Future<List<AllergenType>> fetchAllergenTypes() async => allergenTypes;

  @override
  Future<String> registerBatch(StoreBatchDraft draft) async {
    drafts.add(draft);
    final error = registerError;
    if (error != null) throw error;
    return 'new-batch';
  }

  @override
  Future<StoreRestaurant?> fetchMyRestaurant(String userId) async => restaurant;
  @override
  Future<List<StoreBatch>> fetchTodayBatches(String restaurantId) async {
    if (batchesError) throw Exception('network');
    return batches;
  }

  @override
  Future<StoreBatch?> fetchBatch(String restaurantId, String batchId) async =>
      batches.where((b) => b.id == batchId).firstOrNull;
  @override
  Future<StoreRevenue> fetchRevenue(String restaurantId, {required String from, required String to}) async =>
      revenueError ? throw Exception('network') : const StoreRevenue(orders: 86, revenue: 53320, payout: 10664, sharePct: 20);
  @override
  Future<StoreRatings> fetchRatings(String restaurantId, {int days = 30}) async =>
      ratingsError ? throw Exception('network') : const StoreRatings(count: 28, average: 4.3, distribution: {1: 1, 2: 1, 3: 3, 4: 7, 5: 16}, recentComments: []);
  @override
  Future<List<PhotoRemoval>> fetchPhotoRemovals(String restaurantId) async => removals;
  @override
  Future<void> acknowledgePhotoRemovals(String restaurantId) async {
    acknowledged++;
    removals = const [];
  }
}
