#!/usr/bin/env bash
# ADR-007: chuyển project iOS sang app tài xế「EcoMeal Driver」trước khi build (bundle ID, tên hiển thị, bộ icon).
# Nhóm không có Mac nên không tạo Xcode scheme/flavor cho iOS — CI (macOS) chạy script này rồi build với
# `-t lib/main_driver.dart`. Chỉ chạy trên bản checkout của CI: script SỬA project, không tự hoàn lại.
set -euo pipefail
cd "$(dirname "$0")/.."
PBX=ios/Runner.xcodeproj/project.pbxproj
sed -i '' 's/PRODUCT_BUNDLE_IDENTIFIER = com\.ecomeal\.ecomealMobile;/PRODUCT_BUNDLE_IDENTIFIER = com.ecomeal.ecomealDriver;/' "$PBX"
sed -i '' 's/ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;/ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Driver;/' "$PBX"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName EcoMeal Driver" ios/Runner/Info.plist
# Runner có 3 cấu hình (Debug/Profile/Release): cả 3 phải đổi, RunnerTests giữ nguyên
test "$(grep -c 'PRODUCT_BUNDLE_IDENTIFIER = com.ecomeal.ecomealDriver;' "$PBX")" -eq 3
test "$(grep -c 'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Driver;' "$PBX")" -eq 3
echo "iOS project → EcoMeal Driver (com.ecomeal.ecomealDriver, AppIcon-Driver)"
