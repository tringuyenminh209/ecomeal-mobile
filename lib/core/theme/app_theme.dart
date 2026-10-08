import 'package:flutter/material.dart';

// 06_画面設計.md §0 デザイントークン = Figma trang "00 Foundations" (Color/*, Typography scale) và
// "01 Components" (Button/*, StatusBadge/*, Card, Input, Mobile/Bottom Navigation). Mọi màn hình Phần C
// lấy màu ở đây hoặc qua Theme.of(context) — không viết mã HEX rải rác trong từng màn.
abstract final class AppColors {
  static const primary = Color(0xFF2E7D32);
  static const amber = Color(0xFFF9A825);
  static const background = Color(0xFFFAFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1B1B1B);
  static const textSecondary = Color(0xFF5F6B5F);
  static const border = Color(0xFFD8DED8);
  static const error = Color(0xFFC62828);
  // 4 màu phụ lấy từ frame Figma (không có trong bảng §0): nền xanh nhạt của hero/icon tròn/nhãn
  // "EcoMeal提携店", nền đỏ nhạt của banner lỗi, nền xám của chip dị ứng/nguyên liệu, nền vàng nhạt
  // của khung lưu ý (huỷ miễn phí SCR-M05, 数量確認待ち SCR-M06).
  static const primarySoft = Color(0xFFE8F3E8);
  static const errorSoft = Color(0xFFFDECEC);
  static const chip = Color(0xFFEEF1EC);
  static const amberSoft = Color(0xFFFFF8E1);
  // Chữ "vàng" trên nền sáng (giá SCR-M04): #F9A825 trên trắng chỉ 1.97:1 → không đọc được với người mắt kém / ngoài
  // trời. #8A5A00 (warning-ink của Web Admin và trang công khai) 5.9:1. Vàng sáng giữ cho nền/viền/badge.
  static const amberInk = Color(0xFF8A5A00);
  // Nền thanh tab tài xế (Figma "Driver navigation", SCR-D01…D05) + viên "GPS送信中": xanh rất đậm, tách
  // hẳn khỏi thanh tab trắng của khách để tài xế nhìn là biết đang ở chế độ ドライバー.
  static const driverNav = Color(0xFF243127);
}

// Font Noto Sans JP (06 §0 タイポスケール, "日英共通フォント") — đóng gói sẵn trong assets/fonts/
// (khai ở pubspec.yaml), không tải lúc chạy: app phải hiển thị đúng font cả khi offline.
const _fontFamily = 'NotoSansJP';

// Bộ màu theo ngữ cảnh. day = AppColors (Figma "00 Foundations"); night = chế độ tài xế (làm việc ban đêm trong cabin:
// nền tối giảm chói, cùng màu nền "đêm" với trang công khai #151F18). Màn hình dùng chung cho cả 2 (tài xế + widget chung)
// đọc màu qua context.eco thay vì AppColors, để đổi theme là đổi hết.
// Quy ước tương phản: "surface" cũng là màu chữ đặt trên nền primary/error (sáng: chữ trắng trên xanh; tối: chữ tối trên
// xanh nhạt) — nên night.primary là xanh sáng #81C784, không phải #2E7D32 (chữ/viền xanh đậm gần như mất trên nền tối).
@immutable
class EcoPalette extends ThemeExtension<EcoPalette> {
  const EcoPalette({
    required this.primary,
    required this.amber,
    required this.onAmber,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.primarySoft,
    required this.errorSoft,
    required this.chip,
    required this.amberSoft,
    required this.driverNav,
  });

  final Color primary;
  final Color amber;
  final Color onAmber;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color primarySoft;
  final Color errorSoft;
  final Color chip;
  final Color amberSoft;
  final Color driverNav;

  static const day = EcoPalette(
    primary: AppColors.primary,
    amber: AppColors.amber,
    onAmber: AppColors.textPrimary,
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    error: AppColors.error,
    primarySoft: AppColors.primarySoft,
    errorSoft: AppColors.errorSoft,
    chip: AppColors.chip,
    amberSoft: AppColors.amberSoft,
    driverNav: AppColors.driverNav,
  );

  // Tương phản (WCAG, đã tính): textPrimary/surface 13.2:1, textSecondary/surface 6.9:1, primary/surface 7.4:1,
  // surface trên primary 7.4:1, error/surface 6.9:1, primary/primarySoft 6.2:1 — đều ≥ 4.5:1 (AA chữ thường).
  static const night = EcoPalette(
    primary: Color(0xFF81C784),
    amber: AppColors.amber,
    onAmber: AppColors.textPrimary,
    background: Color(0xFF151F18),
    surface: Color(0xFF1D2A21),
    textPrimary: Color(0xFFEEF2EC),
    textSecondary: Color(0xFFA8B3A9),
    border: Color(0xFF34453A),
    error: Color(0xFFEF9A9A),
    primarySoft: Color(0xFF24382A),
    errorSoft: Color(0xFF3A2424),
    chip: Color(0xFF263328),
    amberSoft: Color(0xFF3A3220),
    driverNav: Color(0xFF0F1611),
  );

  @override
  EcoPalette copyWith() => this;

  @override
  EcoPalette lerp(ThemeExtension<EcoPalette>? other, double t) {
    if (other is! EcoPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return EcoPalette(
      primary: c(primary, other.primary),
      amber: c(amber, other.amber),
      onAmber: c(onAmber, other.onAmber),
      background: c(background, other.background),
      surface: c(surface, other.surface),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      border: c(border, other.border),
      error: c(error, other.error),
      primarySoft: c(primarySoft, other.primarySoft),
      errorSoft: c(errorSoft, other.errorSoft),
      chip: c(chip, other.chip),
      amberSoft: c(amberSoft, other.amberSoft),
      driverNav: c(driverNav, other.driverNav),
    );
  }
}

extension EcoPaletteContext on BuildContext {
  EcoPalette get eco => Theme.of(this).extension<EcoPalette>() ?? EcoPalette.day;
}

ThemeData buildAppTheme({bool dark = false}) {
  final p = dark ? EcoPalette.night : EcoPalette.day;
  final scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: p.primary,
    onPrimary: p.surface,
    primaryContainer: p.primarySoft,
    onPrimaryContainer: p.primary,
    secondary: p.amber,
    onSecondary: p.onAmber,
    error: p.error,
    onError: p.surface,
    errorContainer: p.errorSoft,
    onErrorContainer: p.error,
    surface: p.surface,
    onSurface: p.textPrimary,
    onSurfaceVariant: p.textSecondary,
    outline: p.border,
    outlineVariant: p.border,
    // Material 3 phủ 1 lớp màu primary lên surface khi có elevation — Figma không có lớp này.
    surfaceTint: Colors.transparent,
  );

  final pill = StadiumBorder();
  final buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  // Button/Primary·Secondary·Destructive của Figma: cao 48 (vùng chạm tối thiểu), bo tròn 999, chữ 15 Bold.
  final buttonMinSize = Size(64, 48);
  final buttonPadding = EdgeInsets.symmetric(horizontal: 24);

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width),
      );

  return ThemeData(
    useMaterial3: true,
    extensions: [p],
    colorScheme: scheme,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: p.background,
    textTheme: ThemeData(useMaterial3: true, brightness: dark ? Brightness.dark : Brightness.light).textTheme.copyWith(
      // 06 §0 タイポスケール: H1 24/700, H2 20/700, H3 17/600, 本文 15/400, キャプション 12/400.
      // Figma dùng thêm 26 cho tiêu đề lớn của SCR-M01/M02 → headlineMedium.
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: p.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: p.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: p.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: p.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: p.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: p.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: p.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: p.textSecondary,
      ),
      labelLarge: buttonText,
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: p.textPrimary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.textPrimary,
      ),
    ),
    // ElevatedButton và FilledButton cùng 1 hình dạng Button/Primary — các màn viết trước khi có theme
    // (ElevatedButton) tự khớp Figma, không phải sửa từng chỗ.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.surface,
        // Figma "Disabled": nền primary nhạt, chữ trắng — vẫn đọc được nhãn nút.
        disabledBackgroundColor: p.primary.withValues(alpha: 0.4),
        disabledForegroundColor: p.surface,
        elevation: 0,
        minimumSize: buttonMinSize,
        padding: buttonPadding,
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.surface,
        disabledBackgroundColor: p.primary.withValues(alpha: 0.4),
        disabledForegroundColor: p.surface,
        minimumSize: buttonMinSize,
        padding: buttonPadding,
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    // Button/Secondary: nền trắng, viền + chữ primary.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: p.surface,
        foregroundColor: p.primary,
        side: BorderSide(color: p.primary),
        minimumSize: buttonMinSize,
        padding: buttonPadding,
        shape: pill,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        textStyle: buttonText.copyWith(fontSize: 14),
      ),
    ),
    // Input của Figma: nền trắng, viền Border 1px bo 8, cao 48; focus = viền Primary 2px; lỗi = viền Error.
    // Nhãn đặt PHÍA TRÊN ô (widget LabeledField), nên theme không dùng labelText nổi.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, color: p.textSecondary),
      helperStyle: TextStyle(fontFamily: _fontFamily, fontSize: 11, color: p.textSecondary),
      errorStyle: TextStyle(fontFamily: _fontFamily, fontSize: 11, color: p.error),
      errorMaxLines: 2,
      border: inputBorder(p.border),
      enabledBorder: inputBorder(p.border),
      disabledBorder: inputBorder(p.border.withValues(alpha: 0.6)),
      focusedBorder: inputBorder(p.primary, 2),
      errorBorder: inputBorder(p.error),
      focusedErrorBorder: inputBorder(p.error, 2),
    ),
    // MysteryBagCard / TruckStatusCard: nền trắng, viền Border, bo 16, không đổ bóng.
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.border),
      ),
    ),
    // Chip dị ứng / nguyên liệu (SCR-M04): nền xám nhạt bo tròn, không viền.
    chipTheme: ChipThemeData(
      backgroundColor: p.chip,
      side: BorderSide.none,
      shape: StadiumBorder(),
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        color: p.textPrimary,
      ),
      padding: EdgeInsets.symmetric(horizontal: 4),
    ),
    // Mobile/Bottom Navigation: nền trắng, KHÔNG có viên chỉ báo, mục đang chọn tô màu Primary.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? p.primary
              : p.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? p.primary
              : p.textSecondary,
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: p.border,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.primary,
    ),
  );
}
