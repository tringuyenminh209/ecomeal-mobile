import 'package:ecomeal_mobile/features/admin/admin_tasks_gateway.dart';

// Tab 対応 giả: danh sách cố định, ghi lại thao tác; [writeError] != null → mọi thao tác ghi ném lỗi này
class FakeAdminTasksGateway implements AdminTasksGateway {
  FakeAdminTasksGateway({this.issues = const [], this.restaurants = const [], this.licenses = const [], this.inquiries = const [], this.driverReports = const [], this.members = const [], this.batches = const []});
  List<AdminIssue> issues;
  List<AdminRestaurant> restaurants;
  List<AdminLicense> licenses;
  List<AdminInquiry> inquiries;
  List<AdminDriverReport> driverReports;
  List<AdminRestaurantMember> members;
  List<AdminBatch> batches;
  Object? writeError;
  bool notifyOk = true;
  final actions = <String>[];

  void _write(String action) {
    final e = writeError;
    if (e != null) throw e;
    actions.add(action);
  }

  @override
  Future<List<AdminIssue>> fetchIssues() async => issues;
  @override
  Future<void> resolveIssue(String issueId, {required int refund, required String resolution}) async =>
      _write('resolve:$issueId:$refund:$resolution');
  @override
  Future<List<AdminRestaurant>> fetchRestaurants() async => restaurants;
  @override
  Future<bool> decideRestaurant(String restaurantId, {required bool approve, String? reason}) async {
    _write('${approve ? 'approve' : 'reject'}:$restaurantId${reason == null ? '' : ':$reason'}');
    return notifyOk;
  }

  @override
  Future<String> plDocUrl(String path) async => 'https://example.test/$path';
  @override
  Future<List<AdminRestaurantMember>> fetchRestaurantMembers(String restaurantId) async => members;
  @override
  Future<List<AdminBatch>> fetchRecentBatches(String restaurantId) async => batches;
  @override
  Future<List<AdminLicense>> fetchLicenses() async => licenses;
  @override
  Future<String> licenseImageUrl(String path) async => throw Exception('no image in tests');
  @override
  Future<String?> assignedTruck(String driverId) async => 'なにわ 400 さ 12-34';
  @override
  Future<void> reviewLicense(String driverId, {required bool verify, String? expiresOn, String? reason}) async =>
      _write('${verify ? 'verify' : 'reject'}:$driverId:${expiresOn ?? reason}');
  @override
  Future<List<AdminInquiry>> fetchInquiries() async => inquiries;
  @override
  Future<void> updateInquiry(String inquiryId, {required String status, String? note}) async =>
      _write('inquiry:$inquiryId:$status:${note ?? ''}');
  @override
  Future<List<AdminDriverReport>> fetchDriverReports() async => driverReports;
  @override
  Future<void> resolveDriverReport(String reportId, {required String resolution}) async =>
      _write('driverReport:$reportId:$resolution');
}
