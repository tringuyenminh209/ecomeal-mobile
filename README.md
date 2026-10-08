# EcoMeal Mobile

Chương 15–16: onboarding 日本語/English, đăng nhập/đăng ký Supabase, RoleGate,
SCR-M03 bản đồ + danh sách batch, SCR-M04 chi tiết + giá động/dị ứng/điểm nhận.
Session lưu bằng secure storage. Chương 17–18 chưa triển khai: đặt chỗ, lịch sử,
trang cá nhân. Tab マイページ hiện cho phép đăng xuất.

## 2 app từ 1 codebase (ADR-007, 2026-10-07)

| | App khách「EcoMeal」 | App tài xế「EcoMeal Driver」 |
|---|---|---|
| Điểm khởi động | `lib/main.dart` | `lib/main_driver.dart` |
| Android | `--flavor customer` → `com.ecomeal.ecomeal_mobile` | `--flavor driver` → `com.ecomeal.ecomeal_driver` |
| iOS | `com.ecomeal.ecomealMobile` | `com.ecomeal.ecomealDriver` (CI chạy `tool/ios_use_driver_variant.sh`) |
| Tài khoản vào được | khách | tài xế (đang hoạt động) |

Android **bắt buộc** `--flavor` (đã có productFlavors). Tài khoản sai app → màn báo dùng app khác rồi ログアウト.

## Chạy Android trên máy Windows hiện tại

Mở Android Studio project tại `C:\EcoMeal-mobile` (junction tới repo gốc) — build từ đường dẫn có chữ Nhật thì
Gradle từ chối. Dùng JDK 17. Run Configuration:
- App khách: Dart entrypoint `lib/main.dart`, Build flavor `customer`, Additional run args `--dart-define-from-file=env.json`.
- App tài xế: Dart entrypoint `lib/main_driver.dart`, Build flavor `driver`, cùng Additional run args.

Thêm plugin native nên Stop rồi Run lại, không chỉ hot reload.

```powershell
Set-Location C:\EcoMeal-mobile
C:\flutter\bin\flutter.bat run --flavor customer --dart-define-from-file=env.json
C:\flutter\bin\flutter.bat run --flavor driver -t lib/main_driver.dart --dart-define-from-file=env.json
```

Key Google Maps Android/iOS giới hạn theo package / bundle ID: phải thêm `com.ecomeal.ecomeal_driver` (Android, kèm
SHA-1) và `com.ecomeal.ecomealDriver` (iOS) vào giới hạn của key, nếu không bản đồ của app tài xế bị xám.

`env.json` được gitignore. Chỉ chứa `SUPABASE_URL`, `SUPABASE_ANON_KEY`
và key Maps client; không thêm service-role key hoặc mật khẩu demo.

## Google Maps Android

1. Bật **Maps SDK for Android** trong Google Cloud project EcoMeal.
2. Tạo key riêng, giới hạn Android application: package
   `com.ecomeal.ecomeal_mobile` + SHA-1 chứng chỉ ký. API restriction:
   **Maps SDK for Android**. Key HTTP-referrer của Web Admin không dùng cho Android.
3. Thêm trường `GOOGLE_MAPS_ANDROID_API_KEY` vào `env.json` local.
   Gradle đọc `dart-defines` để điền manifest; Dart dùng cùng giá trị để xác định
   map đã cấu hình. Không hardcode key trong manifest/Git.
4. Stop/Run lại app. Key debug và release cần đúng fingerprint tương ứng.

Lấy SHA-1 debug bằng `keytool -list -v -alias androiddebugkey -keystore
"$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android`.
Nếu chưa có key, app vẫn mở danh sách và hiển thị hướng dẫn thay cho bản đồ.
Không dùng key giả hoặc bản đồ ảnh giả.

Hướng dẫn chính thức: https://developers.google.com/maps/flutter-package/config

## iOS — Chương 15

SCR-M01/SCR-M02 dùng chung Dart với Android: chọn ngôn ngữ, onboarding,
đăng nhập/đăng ký email Supabase, RoleGate và session trong Keychain.
Không cần viết lại màn hình bằng Swift. Chương 15 không cần Maps key iOS.

Cấu hình native đã chuẩn bị: Podfile theo template Flutter 3.32.5, iOS tối thiểu
14.0 (do plugin Maps hiện có), CocoaPods xcconfig cho Debug/Release/Profile,
tên app EcoMeal và khai báo 日本語/English. Không cần Keychain Sharing để dùng
session riêng của app; không bật capability chia sẻ tài khoản giữa các app.

**Hiện mới kiểm tra cấu hình trên Windows; chưa chạy pod install, compile Swift,
Xcode signing hoặc test Keychain thực tế trên iPhone.** Cần máy macOS với Xcode,
Flutter tương thích lockfile và CocoaPods:
https://docs.flutter.dev/platform-integration/ios/setup

Trên Mac, clone repo, vào thư mục apps/mobile. Sao chép env.example.json thành
env.json rồi điền Supabase URL + anon/publishable key công khai. Không dùng
service-role key. Không chép Generated.xcconfig/Pods/build từ Windows sang Mac.

```sh
flutter doctor -v
flutter pub get
flutter gen-l10n
cd ios && pod install && cd ..
open -a Simulator
flutter devices
flutter run -d <simulator-id> --dart-define-from-file=env.json
```

Simulator không cần tài khoản Apple Developer trả phí hoặc signing team.
Với iPhone thật, mở ios/Runner.xcworkspace, chọn Runner → Signing & Capabilities,
chọn team Apple ID của người build và bật Developer Mode trên điện thoại.
Không hardcode Development Team của một cá nhân vào Git.

Test Chương 15 trên iOS:
- Cài lần đầu: thấy onboarding; chọn 日本語/English → màn login cùng ngôn ngữ.
- Chọn đăng ký email/mật khẩu hợp lệ → thông báo xác nhận email. Xác nhận email
  rồi đăng nhập; chưa triển khai callback LINE/OAuth native ở chương này.
- Sai email/mật khẩu, email chưa xác nhận hoặc lỗi mạng → thông báo rõ, thử lại được.
- Đăng nhập đúng role customer → Home (Chương 16 đã merge); driver còn placeholder.
- Đóng/mở app → session còn trong Keychain; đăng xuất → quay về login.
- Bàn phím và Safe Area trên iPhone nhỏ: form cuộn được, nút không bị che.

### Maps iOS — Chương 16/17

Bật Maps SDK for iOS, tạo key riêng giới hạn bundle ID
`com.ecomeal.ecomealMobile` (chưa tạo key iOS nào). Điền `GOOGLE_MAPS_IOS_API_KEY`
trong env.json — **nguồn duy nhất**, giống key Android: Dart đọc qua `String.fromEnvironment`,
còn AppDelegate đọc `DART_DEFINES` mà Flutter ghi vào `ios/Flutter/Generated.xcconfig`
(Info.plist khai báo `DartDefines = $(DART_DEFINES)`, mỗi phần tử là base64 của `TÊN=giá trị`).
Không dùng Local.xcconfig: bản trước lấy key native từ đó và key Dart từ env.json — chỉ điền
một bên thì Dart vẽ GoogleMap khi SDK chưa có key → app crash ngay ở ホーム.
Vì Info.plist chứa toàn bộ dart-define, env.json chỉ được có giá trị công khai
(Supabase URL + anon/publishable key, key Maps có giới hạn bundle ID) — không bao giờ service-role.
Build từ Xcode thì chạy `flutter run`/`flutter build ios --config-only --dart-define-from-file=env.json`
trước để Generated.xcconfig có DART_DEFINES. Chưa có key thì Home vẫn hiển thị list/GPS, thay bản đồ bằng hướng dẫn cấu hình.

Chương 17 (SCR-M05/M06, `qr_flutter`) thuần Dart, không cần cấu hình native thêm.

Test Chương 16/17 trên iOS (Simulator đủ, trừ GPS thật):
- Simulator → Features → Location → Custom Location (vd 34.70, 135.50) để thử sắp xếp theo khoảng cách;
  từ chối quyền → banner + thử lại; "Don't Allow" vĩnh viễn → nút mở Cài đặt.
- Có key: bản đồ + marker xe; không key: khung hướng dẫn, không crash.
- Đặt → về tab 予約 (không còn SCR-M04/M05 phía sau khi vuốt quay lại); kéo xuống để tải lại;
  thẻ allocated có QR + 手動入力; huỷ → toast hoàn tiền/không hoàn.
- Giờ trên thẻ là giờ Nhật dù Simulator đặt múi giờ khác (Settings → General → Date & Time).

### Cài lên iPhone thật từ Windows (không có Mac)

> **Quota GitHub Actions (2026-10-07):** repo private có 3.000 phút/tháng, máy macOS tính x10 (1 lần build 2 IPA
> ≈ 20 phút = ~200 phút quota). Quota tháng 10 đã hết → workflow **iOS build đang tắt** tới 2026-11-01.
> Bật lại: `gh workflow enable "iOS build"` (hoặc Actions → iOS build → Enable workflow). Từ bản sửa này, push chỉ
> chạy analyze + test trên Linux; build IPA chỉ khi bấm tay (tick `smoke_test` nếu muốn chạy thử trên Simulator).
> **Giữ lại file IPA đã tải**: file không hết hạn — app trên iPhone hết hạn sau 7 ngày thì cài lại chính file đó.

1. GitHub → Actions → **iOS build** → Run workflow (nhánh `main`). Chạy tay mới sinh IPA
   (`flutter build ios --release --no-codesign`); artifact **EcoMeal-ipa** (giữ 7 ngày) chứa 2 file:
   `EcoMeal.ipa` (app khách) và `EcoMeal-Driver.ipa` (app tài xế).
2. Cài iTunes (bản apple.com, không phải Microsoft Store) + Sideloadly. Cắm iPhone, kéo file IPA
   vào Sideloadly, đăng nhập Apple ID — Sideloadly ký lại bằng Apple ID đó. Bỏ tick `Use automatic bundle ID`
   để giữ đúng bundle ID (`com.ecomeal.ecomealMobile` / `com.ecomeal.ecomealDriver`).
3. iPhone: Cài đặt → Cài đặt chung → VPN & Quản lý thiết bị → tin cậy Apple ID;
   iOS 16+ bật Quyền riêng tư & Bảo mật → Chế độ nhà phát triển.

Apple ID miễn phí: app hết hạn sau 7 ngày (cài lại), tối đa 3 app. Nếu Sideloadly phải đổi bundle ID
thì LINE Login và key Maps iOS (giới hạn theo bundle ID) không chạy — phần còn lại vẫn test được.
Phát cho cả nhóm cần Apple Developer Program + TestFlight (chưa làm).

## Test thủ công Chương 16

- Đăng nhập role customer → ホーム. Cho phép GPS → danh sách xếp theo khoảng cách;
  từ chối GPS → vẫn chọn được batch, có banner và thử lại. Quyền bị chặn vĩnh viễn
  có nút mở cài đặt.
- Không có batch bán được → trạng thái trống. Mất mạng → lỗi có thử lại.
- Tạo route/điểm public và batch còn hạn, phân bổ số lượng bằng Web Admin theo
  quy trình đã có. Bấm thẻ → đúng điểm nhận và khung giờ JST, giá RPC, dị ứng,
  nguyên liệu. Tên nhà hàng ẩn. Ảnh minh hoạ lấy từ Figma, không phải ảnh của lô.
- Giá được lấy lại mỗi 30 giây, đồng hồ còn hạn cập nhật mỗi giây. Hết hạn trên
  chi tiết → quay lại và thông báo. Dữ liệu list/xe nhận Realtime; list cũng
  tự làm mới 30 giây để xử lý hết hạn không tạo event DB.
- Có hai đơn reserved hôm nay (không tính cancelled/refunded) → khoá CTA.
  Lỗi lấy giá hoặc số đơn → cũng không cho tiếp tục.
- Đổi ngôn ngữ trước đăng nhập → nhãn và tên dị ứng đúng 日本語/English.
- Không có dữ liệu cloud hôm nay thì chỉ test được Empty/GPS. Không tự seed/reset
  database cloud để tạo dữ liệu thử.

## LINE Login — Chương 18 (SCR-M07)

App dùng LINE Login SDK (`flutter_line_sdk`) trên **cùng LINE Login channel** mà Edge Function
`link-line-account` verify (`LINE_LIFF_CHANNEL_ID`). Điền channel ID vào `env.json` → `LINE_CHANNEL_ID`
(giá trị công khai; channel EcoMeal hiện là 2011847544). `LINE_OFFICIAL_ACCOUNT_ID` = ID Official Account (`@939hqcxi`) cho nút 「LINEでトークを開く」/「LINEを開く」; thiếu thì nút bị ẩn. Chưa có thì app vẫn chạy, chỉ nút 「LINEと連携する」 báo lỗi.

Làm 1 lần ở LINE Developers Console → channel LINE Login → tab **LINE Login** → **Mobile app**:
- Android: package `com.ecomeal.ecomeal_mobile` + package signature của keystore (debug của máy build; release riêng).
- iOS: bundle ID `com.ecomeal.ecomealmobile` (console yêu cầu chữ thường).
- Scope `openid` phải bật. Channel ở chế độ Developing → chỉ tài khoản LINE là admin/tester mới đăng nhập được.

Native đã cấu hình trong repo: Android `minSdk` ≥ 24; iOS Info.plist có URL scheme `line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)`
và `LSApplicationQueriesSchemes` `lineauth2`. Trên web (Chrome) LINE SDK không chạy — app bỏ qua bước setup.

## Quên mật khẩu — UC-28 (SCR-M02)

Đặt lại bằng **mã trong mail** (không phải link — app chưa có deep link). Làm 1 lần ở Supabase Dashboard
→ Authentication → Emails → **Reset password**: Subject `【EcoMeal】パスワード再設定の確認コード / Password reset code`,
Body = toàn bộ `supabase/templates/recovery.html` (template phải chứa `{{ .Token }}`, nếu không mail chỉ có link).
Mã 6–10 chữ số theo "Email OTP Length" (app chấp nhận cả dải). Mail gửi qua Resend (`noreply@gentsuki.site`, SMTP port 587).

Test thủ công: こちら → email → mã → mật khẩu mới → vào thẳng màn chính, toast 「パスワードを再設定しました」;
đăng nhập lại bằng mật khẩu mới. Sai mã → E-AUTH-412; trùng mật khẩu cũ → E-AUTH-413 dưới ô.

## Kiểm tra tự động

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --debug --flavor customer --dart-define-from-file=env.json
flutter build apk --debug --flavor driver -t lib/main_driver.dart --dart-define-from-file=env.json
```

Ảnh tham khảo: Figma `V016dcIM24T9RdB4YrGUgx`, SCR-M03 `16:16388`,
SCR-M04 `16:16465`; `assets/images/` là asset xuất từ Figma.
