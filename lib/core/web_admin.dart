// Web Admin trên Vercel (06 SCR-W01〜W10) — app dùng cho 2 việc: đích link xác thực mail (SCR-W10) và nút
// 「Web管理画面を開く」 khi tài khoản 飲食店・運営 đăng nhập app. Ghi đè bằng dart-define WEB_ADMIN_URL.
const webAdminUrl = String.fromEnvironment('WEB_ADMIN_URL', defaultValue: 'https://ecomeal-pi.vercel.app');
