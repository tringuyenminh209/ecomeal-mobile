import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/jst_date.dart';
import '../../core/supabase_client.dart';

// SCR-D05 運転免許証・今後のシフト（レビュー第74回、migration 0037 — docs/proposals/2026-10-05 §6）.
// Tách khỏi DriverGateway (vận hành trong ngày) vì đây là hồ sơ tài khoản, không phụ thuộc tuyến đêm nay.

enum LicenseStatus { none, submitted, verified, rejected }

LicenseStatus licenseStatusFrom(String? value) => switch (value) {
      'submitted' => LicenseStatus.submitted,
      'verified' => LicenseStatus.verified,
      'rejected' => LicenseStatus.rejected,
      _ => LicenseStatus.none,
    };

class DriverLicense {
  const DriverLicense({required this.status, this.expiresOn, this.rejectReason, this.imagePath});
  final LicenseStatus status;
  final String? expiresOn; // YYYY-MM-DD（運営が確認時に入力）
  final String? rejectReason;
  final String? imagePath; // Storage driver_licenses のパス（再提出後に古い画像を消すため）
}

class DriverShift {
  const DriverShift({required this.serviceDate, required this.plateNumber});
  final String serviceDate; // YYYY-MM-DD（JST の運営日）
  final String plateNumber;
}

// 何日先までのシフトを出すか（Figma 277:773「今後のシフト（14日間）」）
const upcomingShiftDays = 14;

abstract class DriverAccountGateway {
  Future<DriverLicense> fetchLicense();
  Future<List<DriverShift>> fetchUpcomingShifts();
  // 画像を自分のフォルダに置いてから submit_driver_license（API-036）。古い画像は失敗しても無視して消す。
  Future<void> submitLicense({required Uint8List bytes, required String extension, String? previousPath});
}

class SupabaseDriverAccountGateway implements DriverAccountGateway {
  SupabaseDriverAccountGateway(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  @override
  Future<DriverLicense> fetchLicense() async {
    final row = await _client
        .from('driver_profiles')
        .select('license_status, license_expires_on, license_reject_reason, license_image_path')
        .eq('driver_id', _uid)
        .maybeSingle();
    if (row == null) return const DriverLicense(status: LicenseStatus.none);
    return DriverLicense(
      status: licenseStatusFrom(row['license_status'] as String?),
      expiresOn: row['license_expires_on'] as String?,
      rejectReason: row['license_reject_reason'] as String?,
      imagePath: row['license_image_path'] as String?,
    );
  }

  @override
  Future<List<DriverShift>> fetchUpcomingShifts() async {
    final today = todayInTokyo();
    final last = addDaysToDate(today, upcomingShiftDays - 1);
    final rows = await _client
        .from('driver_shifts')
        .select('service_date, trucks!inner(plate_number)')
        .eq('driver_id', _uid)
        .gte('service_date', today)
        .lte('service_date', last)
        .order('service_date') as List;
    return rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      return DriverShift(
        serviceDate: row['service_date'] as String,
        plateNumber: (row['trucks'] as Map<String, dynamic>)['plate_number'] as String,
      );
    }).toList();
  }

  @override
  Future<void> submitLicense({required Uint8List bytes, required String extension, String? previousPath}) async {
    final ext = licenseImageExtension(extension);
    final path = '$_uid/license-${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('driver_licenses').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: ext == 'png' ? 'image/png' : 'image/jpeg'),
        );
    await _client.rpc('submit_driver_license', params: {'p_image_path': path});
    if (previousPath != null && previousPath != path) {
      try {
        await _client.storage.from('driver_licenses').remove([previousPath]);
      } catch (_) {
        // 古い画像の掃除は副次的な処理——失敗しても提出は完了している（第55回）
      }
    }
  }
}

// バケットは jpeg/png/webp のみ許可。image_picker は品質指定時に JPEG を返すので、png 以外は jpg として扱う。
String licenseImageExtension(String extension) => extension.toLowerCase() == 'png' ? 'png' : 'jpg';

final driverAccountGatewayProvider =
    Provider<DriverAccountGateway>((ref) => SupabaseDriverAccountGateway(SupabaseClientHolder.instance));

final driverLicenseProvider = FutureProvider.autoDispose<DriverLicense>((ref) {
  return ref.watch(driverAccountGatewayProvider).fetchLicense();
});

final upcomingShiftsProvider = FutureProvider.autoDispose<List<DriverShift>>((ref) {
  return ref.watch(driverAccountGatewayProvider).fetchUpcomingShifts();
});
