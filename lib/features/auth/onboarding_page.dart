import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import '../../widgets/language_picker.dart';
import 'locale_controller.dart';

// SCR-M01 オンボーディング — khớp frame Figma 16:16295: logo, hero xanh nhạt, thông điệp; đáy: hàng ngôn ngữ + 「はじめる」.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // Màn thấp (máy nhỏ, xoay ngang) thì cuộn được; màn đủ cao thì khối chọn ngôn ngữ dính đáy như Figma.
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: EcoMealLogo()),
                    const SizedBox(height: 32),
                    _HeroArt(caption: context.l10n.onboardingImpact),
                    const SizedBox(height: 32),
                    Text(
                      context.l10n.onboardingHeadline,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.onboardingLead,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    // Figma 1000:21670 (2026-10-20): 1 hàng ngôn ngữ (bấm → bảng chọn, đã chọn sẵn ngôn ngữ của máy) + 「はじめる」.
                    // Thêm ngôn ngữ không làm đổi màn này.
                    LanguageRow(
                      key: const Key('onboardingLanguageRow'),
                      inline: true,
                      current: ref.watch(localeControllerProvider).languageCode,
                      onTap: () async {
                        final code = await showLanguageSheet(context, current: ref.read(localeControllerProvider).languageCode);
                        if (code != null) await ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      key: const Key('onboardingStartButton'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _start(ref),
                      child: Text(context.l10n.onboardingStart, style: const TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start(WidgetRef ref) async {
    // Lưu ngôn ngữ đang chọn (kể cả khi giữ ngôn ngữ chọn sẵn) — có khoá này nghĩa là đã qua SCR-M01
    await ref.read(localeControllerProvider.notifier).setLocale(ref.read(localeControllerProvider));
    // KHÔNG Navigator.pushReplacement sang LoginSignupPage: route gốc là RoleGate (bước 8) — thay nó đi
    // thì sau khi đăng nhập không còn ai lắng nghe authControllerProvider để đưa vào màn chính (đã
    // bắt được khi chạy thật ở Chương 18). Chỉ đổi state, RoleGate tự chuyển sang SCR-M02.
    ref.read(onboardingDoneProvider.notifier).state = true;
  }
}

// "Hero art" của Figma: khối xanh nhạt bo góc lệch, ảnh món ăn hình bầu dục ở giữa, bong bóng chữ góc dưới.
// Ảnh xuất từ node 「Meal image」 (16:16310) của Figma ở 3x (690×570, đã có khung bo tròn + nền trong suốt).
// Ảnh minh hoạ chung, không phải món của nhà hàng nào (giống ảnh ở SCR-M04).
class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.caption});
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(110),
          topRight: Radius.circular(52),
          bottomLeft: Radius.circular(46),
          bottomRight: Radius.circular(120),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(96),
              child: Image.asset(
                'assets/images/onboarding-meal.png',
                width: 230,
                height: 190,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x121B1B1B),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                caption,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// "Language option" của Figma: 2 nút ngang nhau, cao 48, bo 8 (khác nút pill ở các màn khác).
