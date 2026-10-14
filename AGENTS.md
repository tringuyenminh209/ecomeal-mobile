# AGENTS.md — apps/mobile（Flutter: お客様・ドライバー・店舗・運営アプリ）

Bổ sung cho `ecomeal/AGENTS.md` (mục Flutter/Android/CameraX/Sideloadly ở đó vẫn áp dụng). Chỉ ghi quy tắc riêng.

## 4 app trong 1 project (ADR-007, ADR-015)
| App | Entry | Android flavor | iOS |
|---|---|---|---|
| お客様 | `lib/main.dart` | `--flavor customer` | mặc định |
| ドライバー | `lib/main_driver.dart` | `--flavor driver -t lib/main_driver.dart` | `tool/ios_use_variant.sh driver` |
| 店舗 | `lib/main_store.dart` | `--flavor store -t lib/main_store.dart` | `tool/ios_use_variant.sh store` |
| 運営 | `lib/main_admin.dart` | `--flavor admin -t lib/main_admin.dart` | `tool/ios_use_variant.sh admin` |

## Quy tắc bắt buộc
- Build/run qua **`C:\EcoMeal-mobile`** (junction tới thư mục này) bằng PowerShell — đường dẫn có `デスクトップ` làm Gradle/shader compiler lỗi. JDK 17.
- Mọi chữ người dùng thấy đi qua ARB (`lib/l10n/app_ja.arb` là template + `app_en.arb`) và `context.l10n`. Hàm thuần trả câu → nhận `AppLocalizations`. Chữ tiếng Nhật đơn giản, đời thường.
- Widget test dựng app qua `test/helpers/test_app.dart` (mặc định `ja`).
- Khoá/API key chỉ nằm trong `env.json` (gitignore), truyền bằng `--dart-define-from-file=env.json`. Không commit `env.json`, `.idea/`.
- Token phiên lưu bằng `flutter_secure_storage`, không `shared_preferences`.
- **Build IPA**: repo `pj` hết quota GitHub Actions → đồng bộ sang repo công khai `ecomeal-mobile` bằng `bash tools/publish-mobile.sh` (từ `ecomeal/`), CI ở đó build IPA.
- Không đụng các file đang sửa dở của chủ dự án (`env.example.json`, `test/features/driver/*` khi chưa được giao).

## Kiểm tra trước khi commit
```powershell
cd C:\EcoMeal-mobile
C:\flutter\bin\flutter.bat analyze --no-pub
C:\flutter\bin\flutter.bat test --no-pub
```
Môi trường không có Flutter → ghi rõ "chưa chạy analyze/test", không báo xong.
