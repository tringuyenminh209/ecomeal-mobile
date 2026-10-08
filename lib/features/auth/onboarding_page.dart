import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/ecomeal_logo.dart';
import 'locale_controller.dart';

// SCR-M01 オンボーディング — khớp frame Figma 16:16295: logo, hero xanh nhạt, thông điệp, chọn ngôn ngữ ở đáy.
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
                    // ARB giữ câu hỏi và tên ngôn ngữ song ngữ để người dùng đọc được trước khi chọn (06 §0.1).
                    Text(
                      context.l10n.selectLanguage,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _LanguageOption(
                            key: const Key('selectJapaneseButton'),
                            label: context.l10n.japaneseLanguage,
                            // Figma tô đặc lựa chọn mặc định (日本語 — LocaleController mặc định 'ja').
                            highlighted: true,
                            onPressed: () => _selectLanguage(ref, const Locale('ja')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _LanguageOption(
                            key: const Key('selectEnglishButton'),
                            label: context.l10n.englishLanguage,
                            highlighted: false,
                            onPressed: () => _selectLanguage(ref, const Locale('en')),
                          ),
                        ),
                      ],
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

  Future<void> _selectLanguage(WidgetRef ref, Locale locale) async {
    await ref.read(localeControllerProvider.notifier).setLocale(locale);
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
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    super.key,
    required this.label,
    required this.highlighted,
    required this.onPressed,
  });
  final String label;
  final bool highlighted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    return highlighted
        ? FilledButton(
            style: FilledButton.styleFrom(shape: shape),
            onPressed: onPressed,
            // Cỡ chữ đặt ở Text (gộp với font của theme), KHÔNG ở styleFrom(textStyle:) — textStyle của
            // ButtonStyle thay hẳn style của theme nên sẽ mất fontFamily Noto Sans JP.
            child: Text(label, style: const TextStyle(fontSize: 14)),
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: shape,
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          );
  }
}
