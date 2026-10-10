import 'package:ecomeal_mobile/features/admin/admin_gateway.dart';
import 'package:ecomeal_mobile/features/notifications/notification_preferences.dart';

// App vận hành: trạng thái 2 bước đổi sang ok khi nhập đúng [validCode]
class FakeAdminGateway implements AdminGateway {
  FakeAdminGateway({this.state = const AdminMfaChallenge('factor-1'), this.validCode = '123456', this.badges, this.tonight});
  AdminMfaState state;
  final String validCode;
  AdminBadges? badges;
  AdminTonight? tonight;
  List<AdminRoute> routes = const [];
  Object? verifyError; // != null: verify ném lỗi này
  final verified = <String>[];
  int enrollments = 0;

  @override
  Future<AdminMfaState> resolveMfaState() async => state;

  @override
  Future<TotpEnrollment> startEnrollment() async {
    enrollments++;
    return const TotpEnrollment(factorId: 'factor-new', secret: 'JBSWY3DPEHPK3PXP', uri: 'otpauth://totp/EcoMeal:admin?secret=JBSWY3DPEHPK3PXP');
  }

  @override
  Future<void> verify(String factorId, String code) async {
    final error = verifyError;
    if (error != null) throw error;
    verified.add('$factorId:$code');
    if (code == validCode) state = const AdminMfaOk();
  }

  @override
  Future<List<AdminRoute>> fetchTonightRoutes(String serviceDate) async => routes;

  @override
  Future<String> fetchMyName(String userId) async => 'EcoMeal 運営チーム';

  @override
  Future<AdminBadges> fetchBadges() async =>
      badges ?? const AdminBadges(openIssues: 0, pendingRestaurants: 0, pendingLicenses: 0, newInquiries: 0);

  @override
  Future<AdminTonight> fetchTonight() async =>
      tonight ?? const AdminTonight(trucksTotal: 0, trucksRunning: 0, stopsTotal: 0, stopsDone: 0, reserved: 0, pickedUp: 0);
}

class FakePreferencesGateway implements NotificationPreferencesGateway {
  FakePreferencesGateway(this.items);
  List<NotificationPreference> items;
  Object? setError;
  final changes = <String>[];

  @override
  Future<List<NotificationPreference>> fetch() async => items;

  @override
  Future<void> set(String type, {required bool enabled}) async {
    final error = setError;
    if (error != null) throw error;
    changes.add('$type=$enabled');
    items = [
      for (final p in items) p.type == type ? NotificationPreference(type: type, isMandatory: p.isMandatory, isEnabled: enabled) : p,
    ];
  }
}
