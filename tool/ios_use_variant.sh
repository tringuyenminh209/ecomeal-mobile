#!/usr/bin/env bash
# ADR-007 / ADR-015: chuyển project iOS sang app khác trước khi build (bundle ID, tên hiển thị, bộ icon).
# Nhóm không có Mac nên không tạo Xcode scheme/flavor cho iOS — CI (macOS) chạy script này rồi build với `-t lib/main_<app>.dart`.
# Dùng: bash tool/ios_use_variant.sh driver|store|admin. Chạy nhiều lần liên tiếp được (đổi từ app nào cũng được).
# Chỉ chạy trên bản checkout của CI: script SỬA project, không tự hoàn lại.
set -euo pipefail
cd "$(dirname "$0")/.."
case "${1:-}" in
  driver) BUNDLE=com.ecomeal.ecomealDriver; NAME="EcoMeal Driver"; ICON=AppIcon-Driver ;;
  store)  BUNDLE=com.ecomeal.ecomealStore;  NAME="EcoMeal Store";  ICON=AppIcon-Store ;;
  admin)  BUNDLE=com.ecomeal.ecomealAdmin;  NAME="EcoMeal Admin";  ICON=AppIcon-Admin ;;
  *) echo "usage: $0 driver|store|admin" >&2; exit 2 ;;
esac
PBX=ios/Runner.xcodeproj/project.pbxproj
# Chỉ 3 cấu hình của Runner (bundle không có hậu tố); RunnerTests (…ecomealMobile.RunnerTests) giữ nguyên
sed -i '' -E "s/PRODUCT_BUNDLE_IDENTIFIER = com\.ecomeal\.ecomeal(Mobile|Driver|Store|Admin);/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE;/" "$PBX"
sed -i '' -E "s/ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon(-Driver|-Store|-Admin)?;/ASSETCATALOG_COMPILER_APPICON_NAME = $ICON;/" "$PBX"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NAME" ios/Runner/Info.plist
# LINE Rich Menu (lib/core/line_menu_link.dart): scheme ecomeal-customer chỉ để app khách nhận; app khác đổi sang scheme riêng
sed -i '' -E "s#<string>ecomeal-(customer|driver|store|admin)</string>#<string>ecomeal-$1</string>#" ios/Runner/Info.plist
test "$(grep -c "<string>ecomeal-$1</string>" ios/Runner/Info.plist)" -eq 1
test "$(grep -c "PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE;" "$PBX")" -eq 3
test "$(grep -c "ASSETCATALOG_COMPILER_APPICON_NAME = $ICON;" "$PBX")" -eq 3
echo "iOS project → $NAME ($BUNDLE, $ICON)"
