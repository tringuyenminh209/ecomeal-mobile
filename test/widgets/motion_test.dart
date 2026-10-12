import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecomeal_mobile/core/motion.dart';
import 'package:ecomeal_mobile/features/home/truck_glide.dart';
import 'package:ecomeal_mobile/widgets/animated_check.dart';
import 'package:ecomeal_mobile/widgets/batch_photo.dart';
import '../helpers/test_app.dart';

// Chuyển động của app (docs/proposals/2026-10-12_mobile-animation-guide.md): token, "giảm chuyển động", ✓, xe trượt, Hero.
Widget _reduced(Widget child, {required bool reduce}) => testApp(
  Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  group('Motion.of', () {
    testWidgets('「視差効果を減らす」オン → 0ms、オフ → token の時間', (tester) async {
      late Duration on, off;
      await tester.pumpWidget(
        _reduced(
          Builder(
            builder: (c) {
              on = Motion.of(c, Motion.page);
              return const SizedBox();
            },
          ),
          reduce: true,
        ),
      );
      await tester.pumpWidget(
        _reduced(
          Builder(
            builder: (c) {
              off = Motion.of(c, Motion.page);
              return const SizedBox();
            },
          ),
          reduce: false,
        ),
      );
      expect(on, Duration.zero);
      expect(off, Motion.page);
    });
  });

  group('AnimatedCheck', () {
    testWidgets('通常は数フレームかけて描かれる', (tester) async {
      await tester.pumpWidget(
        _reduced(const AnimatedCheck(size: 72, color: Colors.white, background: Colors.green), reduce: false),
      );
      final frames = await tester.pumpAndSettle();
      expect(frames, greaterThan(5));
    });
    testWidgets('「視差効果を減らす」オン → 最初のフレームで完成（動かない）', (tester) async {
      await tester.pumpWidget(
        _reduced(const AnimatedCheck(size: 72, color: Colors.white, background: Colors.green), reduce: true),
      );
      expect(await tester.pumpAndSettle(), 1);
    });
  });

  group('truck glide', () {
    const umeda = LatLng(34.7025, 135.4959);
    test('lerpLatLng: 0 → 出発点、1 → 目的地、0.5 → 中間', () {
      const to = LatLng(34.7045, 135.4979);
      expect(lerpLatLng(umeda, to, 0), umeda);
      expect(lerpLatLng(umeda, to, 1), to);
      final mid = lerpLatLng(umeda, to, 0.5);
      expect(mid.latitude, closeTo(34.7035, 1e-9));
      expect(mid.longitude, closeTo(135.4969, 1e-9));
    });
    test('数百 m の移動は滑らせる、同じ位置・1.5 km 超は滑らせない（その場で置く）', () {
      expect(shouldGlide(umeda, const LatLng(34.7045, 135.4959)), isTrue); // 約 220 m
      expect(shouldGlide(umeda, umeda), isFalse);
      expect(shouldGlide(umeda, const LatLng(34.6466, 135.5133)), isFalse); // 天王寺まで約 6 km
    });
    test('approxMeters: 緯度 0.001° ≒ 111 m', () {
      expect(approxMeters(umeda, const LatLng(34.7035, 135.4959)), closeTo(111, 2));
    });
  });

  group('batchPhotoHeroTag', () {
    test('同じ便・地点でも、一覧ごとに別の tag（同じ画面に同じ tag の Hero を2つ置かない）', () {
      final a = batchPhotoHeroTag(batchId: 'b1', routeStopId: 's1', scope: 'nearby');
      final b = batchPhotoHeroTag(batchId: 'b1', routeStopId: 's1', scope: 'route');
      expect(a, isNot(b));
      expect(a, batchPhotoHeroTag(batchId: 'b1', routeStopId: 's1', scope: 'nearby'));
    });
    testWidgets('heroTag あり → Hero、「視差効果を減らす」オン → HeroMode 無効', (tester) async {
      await tester.pumpWidget(
        _reduced(const BatchPhoto(photoUrl: null, width: 72, height: 72, heroTag: 't'), reduce: true),
      );
      expect(find.byType(Hero), findsOneWidget);
      expect(tester.widget<HeroMode>(find.byType(HeroMode)).enabled, isFalse);
      await tester.pumpWidget(_reduced(const BatchPhoto(photoUrl: null, width: 72, height: 72), reduce: false));
      expect(find.byType(Hero), findsNothing);
    });
  });
}
