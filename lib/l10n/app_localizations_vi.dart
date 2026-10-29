// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get loginTab => 'Đăng nhập';

  @override
  String get signupTab => 'Đăng ký';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get errorEmailRequired => 'Vui lòng nhập email';

  @override
  String get errorPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get errorEmailNotConfirmed =>
      'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư đến';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không đúng';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get displayNameLabel => 'Tên hiển thị';

  @override
  String get errorDisplayNameRequired => 'Vui lòng nhập tên hiển thị';

  @override
  String get errorPasswordMin8 => 'Mật khẩu phải từ 8 ký tự trở lên';

  @override
  String get signupButton => 'Đăng ký';

  @override
  String get errorEmailAlreadyRegistered => 'Email này đã được đăng ký';

  @override
  String get errorSignupFailed =>
      'Đăng ký không thành công. Vui lòng kiểm tra lại thông tin và thử lại';

  @override
  String get errorRateLimited => 'Vui lòng đợi một lát rồi thử lại';

  @override
  String get signupConfirmationTitle => 'Đã gửi email xác nhận';

  @override
  String signupConfirmationBody(String email) {
    return 'Đã gửi email xác nhận đến $email. Vui lòng nhấn vào liên kết trong email để hoàn tất đăng ký.';
  }

  @override
  String get webOnlyAccountTitle =>
      'Tài khoản này không dùng được trên ứng dụng';

  @override
  String get webOnlyAccountBody =>
      'Tài khoản của quán đối tác và ban vận hành EcoMeal vui lòng sử dụng trang quản trị web trên máy tính.';

  @override
  String get openWebAdmin => 'Mở trang quản trị';

  @override
  String get errorOpenWebAdmin => 'Không mở được trang quản trị';

  @override
  String get loadErrorTitle => 'Không tải được thông tin tài khoản';

  @override
  String get loadErrorBody => 'Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'Tài xế';

  @override
  String get driverLoginLead =>
      'Vui lòng đăng nhập bằng tài khoản tài xế do EcoMeal cấp.';

  @override
  String get driverAccountIssuedNote =>
      'Tài khoản do ban vận hành cấp. Vui lòng đặt mật khẩu qua liên kết trong email mời rồi đăng nhập.';

  @override
  String get driverOnlyAppTitle => 'Ứng dụng dành riêng cho tài xế';

  @override
  String get driverOnlyAppBody =>
      'Khách hàng vui lòng dùng ứng dụng “EcoMeal”; quán đối tác và ban vận hành EcoMeal vui lòng dùng trang quản trị trên máy tính.';

  @override
  String get driverAccountTitle => 'Đây là tài khoản tài xế';

  @override
  String get driverAccountBody =>
      'Tài xế vui lòng đăng nhập bằng ứng dụng “EcoMeal Driver”. Ứng dụng này dành riêng cho khách hàng.';

  @override
  String get storeAppTitle => 'EcoMeal Store';

  @override
  String get adminAppTitle => 'EcoMeal Admin';

  @override
  String get storeBadge => 'Quán';

  @override
  String get storeLoginLead =>
      'Vui lòng đăng nhập bằng tài khoản quán do EcoMeal cấp.';

  @override
  String get storeLoginNote =>
      'Quán mới có thể đăng ký tham gia trên trang web (ecomeal-pi.vercel.app).';

  @override
  String get adminBadge => 'Vận hành';

  @override
  String get adminLoginLead =>
      'Vui lòng đăng nhập bằng tài khoản ban vận hành. Sau đó bạn sẽ nhập mã xác thực 2 bước.';

  @override
  String get storeOnlyAppTitle => 'Ứng dụng dành riêng cho quán';

  @override
  String get storeOnlyAppBody =>
      'Khách hàng vui lòng dùng ứng dụng “EcoMeal”, tài xế dùng “EcoMeal Driver”.';

  @override
  String get adminOnlyAppTitle => 'Ứng dụng dành riêng cho ban vận hành';

  @override
  String get adminOnlyAppBody =>
      'Khách hàng vui lòng dùng “EcoMeal”, quán đối tác dùng “EcoMeal Store”, tài xế dùng “EcoMeal Driver”.';

  @override
  String get driverSuspendedTitle => 'Tài khoản đang tạm ngừng hoạt động';

  @override
  String get driverSuspendedBody =>
      'Tài khoản này hiện không thể nhận ca chạy. Vui lòng liên hệ ban vận hành EcoMeal để biết lý do và cách mở lại.';

  @override
  String get backToLogin => 'Quay lại màn hình đăng nhập';

  @override
  String get errorNetwork => 'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại';

  @override
  String get signOutButton => 'Đăng xuất';

  @override
  String get errorSignOutFailed => 'Không thể đăng xuất. Vui lòng thử lại';

  @override
  String get onboardingHeadline => 'Bữa tối hôm nay, nối dài tương lai.';

  @override
  String get onboardingLead =>
      'Eco-Truck mang những phần ăn ngon lành còn dư từ các quán đối tác đến điểm nhận gần bạn.';

  @override
  String get onboardingImpact => 'Giảm lãng phí thực phẩm qua từng bữa ngon';

  @override
  String get loginLead => 'Đăng nhập bằng email và mật khẩu.';

  @override
  String get signupLead => 'Tạo tài khoản bằng email và mật khẩu.';

  @override
  String get emailHint => 'example@example.jp';

  @override
  String get passwordHint => 'Nhập mật khẩu';

  @override
  String get passwordMin8Helper => 'Vui lòng nhập từ 8 ký tự trở lên.';

  @override
  String get showPassword => 'Hiện';

  @override
  String get hidePassword => 'Ẩn';

  @override
  String get displayNameHint => 'Nhập tên hiển thị';

  @override
  String get noAccountPrompt => 'Bạn chưa có tài khoản?';

  @override
  String get haveAccountPrompt => 'Bạn đã có tài khoản?';

  @override
  String get signupSpamFolderNote =>
      'Nếu không nhận được email, vui lòng kiểm tra thư mục thư rác.';

  @override
  String get forgotPasswordPrompt => 'Quên mật khẩu?';

  @override
  String get forgotPasswordAction => 'Đặt lại tại đây';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get resetPasswordRequestLead =>
      'Mã xác nhận đặt lại mật khẩu sẽ được gửi đến email bạn đã đăng ký.';

  @override
  String get resetPasswordSendCodeButton => 'Gửi mã xác nhận';

  @override
  String resetPasswordCodeLead(String email) {
    return 'Nếu $email đã được đăng ký, mã xác nhận đã được gửi. Vui lòng nhập mã trong email và mật khẩu mới.';
  }

  @override
  String get verificationCodeLabel => 'Mã xác nhận';

  @override
  String get verificationCodeHint => 'Mã trong email';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get newPasswordHint => 'Nhập mật khẩu mới';

  @override
  String get resetPasswordButton => 'Đặt lại mật khẩu';

  @override
  String get resendCodePrompt => 'Chưa nhận được mã?';

  @override
  String get resendCodeAction => 'Gửi lại';

  @override
  String get codeResent => 'Đã gửi lại mã xác nhận';

  @override
  String get passwordResetDone => 'Đã đặt lại mật khẩu';

  @override
  String get errorVerificationCodeFormat =>
      'Vui lòng nhập mã xác nhận (chữ số) trong email';

  @override
  String get errorVerificationCodeInvalid =>
      'Mã xác nhận không đúng hoặc đã hết hạn';

  @override
  String get errorSamePassword =>
      'Vui lòng nhập mật khẩu khác với mật khẩu hiện tại';

  @override
  String get errorResetRequestFailed =>
      'Không gửi được mã xác nhận. Vui lòng thử lại';

  @override
  String get errorResetFailed =>
      'Không đặt lại được mật khẩu. Vui lòng thử lại';

  @override
  String get retry => 'Thử lại';

  @override
  String get errorLoadRetry => 'Không tải được dữ liệu. Thử lại';

  @override
  String get errorLoadTitle => 'Không tải được dữ liệu';

  @override
  String get errorLoadBody => 'Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get errorLocationUnavailable => 'Không thể xác định vị trí';

  @override
  String get errorLocationBody =>
      'Vui lòng kiểm tra cài đặt vị trí và kết nối mạng của thiết bị.';

  @override
  String get nearbyBatches => 'Túi đồ ăn gần bạn';

  @override
  String countItems(int count) {
    return '$count phần';
  }

  @override
  String get liveUpdating => 'Đang cập nhật vị trí';

  @override
  String get truckRunning => 'Eco-Truck đang chạy';

  @override
  String truckNumber(int number) {
    return 'Eco-Truck số $number';
  }

  @override
  String truckRouteSummary(int count) {
    return 'Lịch dừng tối nay · $count điểm';
  }

  @override
  String get truckTapHint =>
      'Chạm vào xe trên bản đồ hoặc thẻ này để xem lịch dừng và thực đơn';

  @override
  String get stopPassed => 'Đã qua';

  @override
  String get nextStopBadge => 'Điểm dừng tiếp theo';

  @override
  String get truckNoBatches => 'Xe này hiện không có túi đồ ăn nào đang bán';

  @override
  String get closeTruckRoute => 'Đóng';

  @override
  String truckNextStop(String stopName) {
    return 'Điểm dừng tiếp theo: $stopName';
  }

  @override
  String truckEta(String time, int minutes) {
    return 'Dự kiến đến $time · còn $minutes phút';
  }

  @override
  String get homeEmptyTitle => 'Hôm nay chưa có lịch bán';

  @override
  String get homeEmptyBody =>
      'Liên kết với LINE để nhận thông báo khi Eco-Truck đến gần.';

  @override
  String get setupLineNotify => 'Cài đặt thông báo LINE';

  @override
  String get homeEmptyBodyLinked =>
      'Khi Eco-Truck đến gần, tài khoản chính thức của EcoMeal sẽ gửi thông báo qua LINE.';

  @override
  String get openLine => 'Mở LINE';

  @override
  String get partnerStore => 'Quán đối tác EcoMeal';

  @override
  String get mysteryBag => 'Túi bất ngờ';

  @override
  String remainingBags(int qty) {
    return 'Còn $qty túi';
  }

  @override
  String get batchDetailTitle => 'Chi tiết túi đồ ăn';

  @override
  String get priceCalculating => 'Đang tính giá...';

  @override
  String get errorPriceLoad => 'Không tải được giá';

  @override
  String truckPeek(String stop, String time, int minutes) {
    return 'Eco-Truck đang chạy · Điểm tới: $stop $time (còn $minutes phút)';
  }

  @override
  String stopWalk(String stop, int minutes) {
    return '$stop · đi bộ $minutes phút';
  }

  @override
  String get errorSessionExpired =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';

  @override
  String get errorPaymentService =>
      'Không thể đặt trước do dịch vụ thanh toán gặp sự cố. Vui lòng thử lại sau';

  @override
  String get errorPriceTooLow =>
      'Túi đồ ăn này không thể thanh toán bằng thẻ ở mức giá hiện tại. Vui lòng chọn túi đồ ăn khác';

  @override
  String minutesRemaining(int minutes) {
    return 'Còn $minutes phút';
  }

  @override
  String get pickupByEcoTruck => 'Nhận tại Eco-Truck';

  @override
  String get allergensHeading => 'Thông tin chất gây dị ứng';

  @override
  String get allergensNone => 'Không có';

  @override
  String get ingredientsHeading => 'Nguyên liệu chính & xuất xứ';

  @override
  String ingredientWithOrigin(String name, String origin) {
    return '$name ($origin)';
  }

  @override
  String get originUnknown => 'Chưa rõ xuất xứ';

  @override
  String get detailNote =>
      'Món bên trong là điều bất ngờ cho đến khi nhận. Ảnh chỉ mang tính minh họa. Nếu bạn bị dị ứng thực phẩm, vui lòng kiểm tra kỹ thông tin chất gây dị ứng.';

  @override
  String get dailyLimitReached =>
      'Bạn đã đạt giới hạn đặt trước hôm nay (2 đơn)';

  @override
  String get reserveButton => 'Đặt trước';

  @override
  String get mapSetupRequired =>
      'Không hiển thị được bản đồ. Bạn vẫn có thể xem danh sách bên dưới.';

  @override
  String get openLocationSettings => 'Mở cài đặt vị trí';

  @override
  String get batchExpired => 'Đã quá hạn bán. Vui lòng chọn túi đồ ăn khác.';

  @override
  String get reservationCountFailed =>
      'Không kiểm tra được số đơn đặt trước. Vui lòng thử lại.';

  @override
  String get homeTab => 'Trang chủ';

  @override
  String get reservationsTab => 'Đặt trước';

  @override
  String get myPageTab => 'Trang của tôi';

  @override
  String get locateMe => 'Vị trí hiện tại';

  @override
  String get statusPending => 'Chờ kiểm số lượng';

  @override
  String get statusAllocated => 'Đã giữ phần';

  @override
  String get statusPickedUp => 'Đã nhận';

  @override
  String get statusRefunded => 'Đã hoàn tiền';

  @override
  String get statusExpired => 'Hết hạn';

  @override
  String get statusCancelled => 'Đã hủy';

  @override
  String get reservationConfirmTitle => 'Xác nhận đặt trước';

  @override
  String get paymentMethodRequired => 'Phương thức thanh toán (bắt buộc)';

  @override
  String get paymentMethodSection => 'Phương thức thanh toán';

  @override
  String get addPaymentMethod => 'Thêm phương thức thanh toán';

  @override
  String get addPaymentMethodSub => 'Thẻ tín dụng · Thẻ ghi nợ';

  @override
  String get defaultCardLabel => 'Thẻ mặc định';

  @override
  String get addPaymentMethodHint =>
      'Thêm phương thức thanh toán để xác nhận đặt trước.';

  @override
  String get addPaymentMethodButton => 'Thêm phương thức thanh toán';

  @override
  String payNotice(String amount) {
    return 'Khi xác nhận đặt trước, bạn sẽ thanh toán $amount.';
  }

  @override
  String payButton(String amount) {
    return 'Thanh toán $amount và đặt trước';
  }

  @override
  String get errorPaymentMethodsLoad => 'Không tải được phương thức thanh toán';

  @override
  String get errorPaymentMethodMissing =>
      'Không tìm thấy thẻ đã chọn. Vui lòng chọn lại phương thức thanh toán';

  @override
  String get paymentTitle => 'Thanh toán';

  @override
  String get paymentProcessingTitle => 'Đang xử lý thanh toán';

  @override
  String get paymentProcessingBody =>
      'Vui lòng giữ nguyên màn hình cho đến khi hoàn tất.\nKhông nhấn nút thanh toán nhiều lần.';

  @override
  String get paymentProcessingNote =>
      'Đang kiểm tra kết quả thanh toán.\nThường chỉ mất vài giây.';

  @override
  String paymentSummaryLine(String amount, String card) {
    return '$amount (đã gồm thuế)  ·  $card';
  }

  @override
  String get reservationCompleteTitle => 'Đặt trước hoàn tất';

  @override
  String get paymentDoneTitle => 'Thanh toán hoàn tất';

  @override
  String get paymentDoneBody =>
      'Đã tiếp nhận đơn đặt trước của bạn.\nBạn có thể xem hướng dẫn nhận đồ tại màn hình Đặt trước.';

  @override
  String pickupPlaceLine(String place) {
    return 'Điểm nhận: $place';
  }

  @override
  String pickupTimeLine(String time) {
    return 'Giờ nhận: $time';
  }

  @override
  String get viewReservation => 'Xem đơn đặt trước';

  @override
  String get paymentDeclinedTitle => 'Thanh toán không thành công';

  @override
  String get paymentDeclinedBody =>
      'Đơn vị phát hành thẻ đã từ chối giao dịch.\nVui lòng chọn thẻ khác hoặc liên hệ đơn vị phát hành thẻ.';

  @override
  String get paymentCardExpiredBody =>
      'Thẻ đã hết hạn sử dụng.\nVui lòng chọn thẻ khác.';

  @override
  String get paymentNotCompletedNote =>
      'Thanh toán này chưa hoàn tất.\nĐơn đặt trước vẫn chưa được xác nhận.';

  @override
  String get payWithAnotherCard => 'Thanh toán bằng thẻ khác';

  @override
  String get backToReview => 'Quay lại xác nhận đặt trước';

  @override
  String get paymentUnknownTitle => 'Chưa xác nhận được kết quả thanh toán';

  @override
  String get paymentUnknownBody =>
      'Mất kết nối nên hệ thống đang kiểm tra trạng thái thanh toán.\nĐể tránh bị trừ tiền hai lần, vui lòng không thao tác thanh toán lại.';

  @override
  String get paymentUnknownNote =>
      'Đang kiểm tra trạng thái thanh toán và đặt trước.\nVui lòng kiểm tra kết nối mạng rồi thử lại.';

  @override
  String get recheckPayment => 'Kiểm tra lại thanh toán';

  @override
  String get viewReservationHistory => 'Xem lịch sử đặt trước';

  @override
  String get paymentNotFound => 'Thanh toán chưa hoàn tất. Vui lòng thử lại';

  @override
  String get errorRecheckFailed =>
      'Không kiểm tra được. Vui lòng kiểm tra mạng và thử lại';

  @override
  String get paymentMethodsTitle => 'Phương thức thanh toán';

  @override
  String get paymentMethodsSubtitle => 'Quản lý thẻ an toàn';

  @override
  String get paymentMethodsEmptyTitle => 'Chưa có phương thức thanh toán';

  @override
  String get paymentMethodsEmptyBody =>
      'Thêm thẻ để thanh toán đặt trước chỉ với một chạm.';

  @override
  String get addCreditCard => '+ Thêm thẻ tín dụng';

  @override
  String get paymentProviderNote =>
      'Thông tin thanh toán được đơn vị trung gian thanh toán xử lý an toàn.';

  @override
  String get registeredCards => 'Thẻ đã lưu';

  @override
  String cardExpiresOn(String expiry) {
    return 'Hết hạn $expiry';
  }

  @override
  String get defaultBadge => 'Mặc định';

  @override
  String get addAnotherCard => '+  Thêm thẻ khác';

  @override
  String get paymentSafetyTitle => 'An toàn thanh toán';

  @override
  String get paymentSafetyBody =>
      'Thông tin thẻ được mã hóa và quản lý an toàn bởi đơn vị thanh toán.\nĐặt thẻ mặc định để thanh toán chỉ với một chạm.';

  @override
  String get setDefaultCard => 'Đặt làm thẻ mặc định';

  @override
  String get deleteCard => 'Xóa thẻ này';

  @override
  String get deleteCardTitle => 'Xóa thẻ này?';

  @override
  String deleteCardBody(String card) {
    return 'Thẻ $card sẽ bị xóa và không thể dùng cho các đơn đặt trước sau này.';
  }

  @override
  String get deleteConfirm => 'Xóa';

  @override
  String get cardDeleted => 'Đã xóa thẻ';

  @override
  String get defaultCardChanged => 'Đã đổi thẻ mặc định';

  @override
  String get addCardTitle => 'Thêm thẻ';

  @override
  String get addCardSubtitle => 'Phương thức thanh toán an toàn';

  @override
  String get cardInfoSection => 'Thông tin thẻ';

  @override
  String get cardNumberLabel => 'Số thẻ';

  @override
  String get cardNumberHint => '1234  5678  9012  3456';

  @override
  String get cardHolderLabel => 'Tên chủ thẻ';

  @override
  String get cardHolderHint => 'Tên in trên thẻ';

  @override
  String get cardExpiryLabel => 'Ngày hết hạn';

  @override
  String get cardExpiryHint => 'MM / YY';

  @override
  String get cardCvcLabel => 'Mã bảo mật';

  @override
  String get cardCvcHint => 'CVC';

  @override
  String get cardTokenNote =>
      'Số thẻ không lưu trên máy chủ EcoMeal mà do đơn vị thanh toán quản lý an toàn. Tuyệt đối không chia sẻ mã bảo mật cho người khác.';

  @override
  String get cardTermsNote =>
      'Khi thêm thẻ, bạn đồng ý với điều khoản thanh toán.';

  @override
  String get addCardButton => 'Thêm thẻ';

  @override
  String get cardNumberInvalid => 'Vui lòng kiểm tra lại số thẻ.';

  @override
  String get cardHolderRequired => 'Vui lòng nhập tên chủ thẻ.';

  @override
  String get cardExpiryInvalid => 'Vui lòng kiểm tra hạn thẻ.';

  @override
  String get cardCvcInvalid => 'Vui lòng kiểm tra mã bảo mật.';

  @override
  String get errorCardLimit => 'Chỉ có thể lưu tối đa 10 thẻ';

  @override
  String get errorCardAdd => 'Không thêm được thẻ. Vui lòng thử lại';

  @override
  String get testPaymentNote =>
      'Đang thử nghiệm nên không trừ tiền thật. Hãy dùng thẻ thử 4242 4242 4242 4242 (thẻ kết thúc bằng 0002 sẽ bị từ chối thanh toán).';

  @override
  String paymentMethodRowDefault(String card) {
    return '$card · Mặc định';
  }

  @override
  String get paymentMethodRowNone => 'Chưa lưu';

  @override
  String get freeCancelTitle => 'Hủy miễn phí trước giờ nhận 30 phút';

  @override
  String get freeCancelBody =>
      'Bạn có thể hủy miễn phí trước giờ nhận dự kiến 30 phút (ví dụ nhận lúc 20:00 thì hủy trước 19:30) ngay tại mục Lịch sử đặt trước.';

  @override
  String get errorReservationFailed =>
      'Không thể đặt trước lúc này. Vui lòng thử lại sau';

  @override
  String get errorDailyLimit =>
      'Bạn đã đạt giới hạn đặt trước hôm nay (tối đa 2 đơn). Bạn có thể xem các đơn đã đặt tại mục “Đặt trước”.';

  @override
  String get errorSoldOutAtStop =>
      'Điểm nhận này đã hết suất. Vui lòng chọn túi đồ ăn khác';

  @override
  String get errorBatchUnavailable =>
      'Túi đồ ăn này đã ngừng nhận đặt trước. Vui lòng chọn túi đồ ăn khác';

  @override
  String get actionSeeReservations => 'Xem đơn đặt trước';

  @override
  String get actionFindOtherBags => 'Tìm túi đồ ăn khác';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get orderHistoryTitle => 'Lịch sử đặt trước';

  @override
  String get orderHistorySubtitle => 'Lịch sử EcoMeal của bạn';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterActive => 'Chờ nhận';

  @override
  String get filterCompleted => 'Hoàn tất';

  @override
  String get orderHistoryEmpty => 'Chưa có đơn đặt trước nào';

  @override
  String get cancelDialogTitle => 'Bạn muốn hủy đơn đặt trước này?';

  @override
  String get cancelDialogFree =>
      'Bạn có thể hủy miễn phí trước giờ nhận 30 phút. Nếu hủy bây giờ, bạn sẽ được hoàn tiền toàn bộ.';

  @override
  String get cancelDialogNoRefund =>
      'Hiện đã cách giờ nhận dưới 30 phút nên nếu hủy, bạn sẽ không được hoàn tiền.';

  @override
  String get back => 'Quay lại';

  @override
  String get cancelConfirmButton => 'Hủy đặt trước';

  @override
  String cancelledWithRefund(int amount) {
    return 'Đã hủy (hoàn tiền ¥$amount)';
  }

  @override
  String get cancelledNoRefund => 'Đã hủy (không hoàn tiền)';

  @override
  String get errorCancelFailed => 'Không thể hủy đơn lúc này. Vui lòng thử lại';

  @override
  String reservedOrderLabel(String number) {
    return 'Đã đặt trước · Đơn $number';
  }

  @override
  String get reservedPaid => 'Đã thanh toán';

  @override
  String orderNumber(String number) {
    return 'Đơn $number';
  }

  @override
  String get pendingExplanation =>
      'Tài xế đang kiểm tra số lượng thực tế. Nếu không đủ suất ăn, hệ thống sẽ ưu tiên giữ phần theo thứ tự đặt trước tại từng điểm nhận. Phần không giữ được sẽ được tự động hoàn tiền.';

  @override
  String allocatedExplanation(String stopName) {
    return 'Đã giữ 1 túi đồ ăn cho bạn tại $stopName. Xem mã QR cùng giờ và điểm nhận tại “Hướng dẫn nhận đồ”.';
  }

  @override
  String get freeCancelExpired => 'Đã qua hạn hủy miễn phí (không hoàn tiền)';

  @override
  String get cancelButton => 'Hủy';

  @override
  String manualCodeLabel(String code) {
    return 'Mã nhập tay: $code';
  }

  @override
  String get pickupQrTitle => 'Mã QR nhận đồ';

  @override
  String get pickupQrCaption =>
      'Khi nhận đồ, hãy đưa mã QR này cho tài xế quét hoặc đọc mã xác nhận.';

  @override
  String get refundFullBadge => 'Hoàn tiền toàn bộ';

  @override
  String get refundFullNote =>
      'Với tình trạng đơn hiện tại, bạn sẽ được hoàn tiền toàn bộ sau khi hủy.';

  @override
  String get refundNoneBadge => 'Không hoàn tiền';

  @override
  String get refundNoneNote =>
      'Hiện đã cách giờ nhận dưới 30 phút nên sẽ không được hoàn tiền sau khi hủy.';

  @override
  String get errorBadge => 'Lỗi';

  @override
  String get browseBatches => 'Xem túi đồ ăn gần bạn';

  @override
  String totalWithQuantity(int quantity) {
    return 'Tổng cộng (đã gồm thuế · SL $quantity)';
  }

  @override
  String todayTime(String time) {
    return 'Hôm nay $time';
  }

  @override
  String errorDisplayNameTooLong(int max) {
    return 'Tên hiển thị không được quá $max ký tự';
  }

  @override
  String errorNameKanaTooLong(int max) {
    return 'Phiên âm tên không được quá $max ký tự';
  }

  @override
  String get errorLanguageSave => 'Không thể lưu cài đặt ngôn ngữ';

  @override
  String get errorLineStatusLoad =>
      'Không kiểm tra được trạng thái liên kết LINE';

  @override
  String get lineLinked => 'Đã liên kết LINE';

  @override
  String get lineLinkedBody => 'Bạn có thể xem thông báo nhận đồ qua LINE';

  @override
  String get lineLinkHint =>
      'Thông báo sẽ được gửi qua tin nhắn từ tài khoản LINE chính thức của EcoMeal';

  @override
  String get lineOpenChat => 'Mở tin nhắn LINE';

  @override
  String get errorOpenLine => 'Không thể mở ứng dụng LINE';

  @override
  String get errorLineLinkFailed =>
      'Không thể liên kết với LINE. Vui lòng thử lại';

  @override
  String get lineLinkButton => 'Liên kết với LINE';

  @override
  String get logoutDialogTitle => 'Bạn có muốn đăng xuất?';

  @override
  String get logoutDialogBody =>
      'Sau khi đăng xuất, bạn sẽ quay về màn hình đăng nhập.';

  @override
  String get profileSaved => 'Đã cập nhật hồ sơ';

  @override
  String get errorSaveFailed => 'Không thể lưu thông tin. Vui lòng thử lại';

  @override
  String get discardDialogTitle => 'Hủy thay đổi?';

  @override
  String get discardDialogBody => 'Nội dung bạn vừa sửa sẽ không được lưu.';

  @override
  String get keepEditing => 'Tiếp tục sửa';

  @override
  String get discard => 'Bỏ thay đổi';

  @override
  String get profileEditTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get requiredBadge => 'Bắt buộc';

  @override
  String get optionalBadge => 'Không bắt buộc';

  @override
  String get nameKanaLabel => 'Phiên âm tên (Furigana)';

  @override
  String get nameKanaHint => 'VD: Haruka Mika';

  @override
  String get emailNotEditable => 'Không thể thay đổi địa chỉ email';

  @override
  String get credentialsChangeOutOfScope =>
      'Không thể đổi địa chỉ email và mật khẩu tại màn hình này. Bạn có thể đặt lại mật khẩu từ mục “Quên mật khẩu?” ở màn hình đăng nhập.';

  @override
  String get saveButton => 'Lưu';

  @override
  String get languageLabel => 'Ngôn ngữ / Language';

  @override
  String get languageNameJa => 'Tiếng Nhật';

  @override
  String get languageNameEn => 'Tiếng Anh';

  @override
  String get languageNameVi => 'Tiếng Việt';

  @override
  String get languageNameUz => 'Tiếng Uzbek';

  @override
  String get languageSearchHint => 'Tìm ngôn ngữ / Search';

  @override
  String get onboardingStart => 'Bắt đầu';

  @override
  String get errorBatchAlreadyConfirmed =>
      'Số lượng của món ăn này đã được chốt trước đó';

  @override
  String get errorStopNotOnRoute =>
      'Điểm dừng đã chọn không nằm trên tuyến của món ăn này';

  @override
  String get errorStopClosed => 'Xe đã rời khỏi điểm dừng này';

  @override
  String get errorTemperatureRange =>
      'Vui lòng nhập nhiệt độ trong khoảng -30 đến 99.9°C';

  @override
  String get errorConfirmFailed => 'Không thể chốt số lượng. Vui lòng thử lại';

  @override
  String get errorTemperatureRequired => 'Vui lòng nhập nhiệt độ';

  @override
  String get errorConfirmedQtyRequired => 'Vui lòng nhập số lượng chốt';

  @override
  String get errorNonNegativeInteger => 'Vui lòng nhập số nguyên từ 0 trở lên';

  @override
  String get pickupConfirmTitle => 'Xác nhận thu hàng';

  @override
  String pickupSubtitle(String stopName, int index, int total) {
    return '$stopName • Thu hàng $index/$total';
  }

  @override
  String estimatedMeals(int qty) {
    return 'Dự kiến $qty suất';
  }

  @override
  String get confirmedQtyLabel => 'Số lượng chốt';

  @override
  String get mealUnit => 'suất';

  @override
  String get coreTemperatureLabel => 'Nhiệt độ tâm khi nhận';

  @override
  String get coldChainNotice =>
      'Đảm bảo đồ lạnh ở mức 10°C trở xuống. Nếu vượt mức chuẩn, hãy liên hệ ban vận hành.';

  @override
  String get coldChainOverLimit =>
      'Vượt mức chuẩn (tối đa 10°C). Không được phép thu nhận và bán món này.';

  @override
  String get distributionStopsLabel => 'Điểm dừng phân bổ';

  @override
  String get distributionStopsHint =>
      'Hãy chọn các điểm dừng trên tuyến hiện tại. Suất ăn sẽ được phân bổ về những điểm đã chọn.';

  @override
  String get noDistributableStops =>
      'Không có điểm dừng nào để phân bổ (đã rời hết các điểm)';

  @override
  String get nextStopLabel => 'Điểm dừng tiếp theo';

  @override
  String nthStopLabel(int n) {
    return 'Điểm thứ $n';
  }

  @override
  String distributionStopSubtitle(String order, String time) {
    return '$order • dự kiến $time';
  }

  @override
  String selectedStopsCount(int count) {
    return 'Sẽ phân bổ cho $count điểm dừng đã chọn.';
  }

  @override
  String confirmPickupButton(String qty) {
    return 'Xác nhận thu $qty suất';
  }

  @override
  String get rejectPickupButton => 'Từ chối thu hàng (vượt nhiệt độ chuẩn)';

  @override
  String get rejectPickupDialogTitle => 'Từ chối thu nhận món ăn này?';

  @override
  String rejectPickupDialogBody(String celsius) {
    return 'Nhiệt độ tâm là $celsius°C, vượt mức chuẩn (tối đa 10°C). Món này sẽ không được bán, toàn bộ đơn đặt trước sẽ được hoàn tiền và thông báo cho khách. Bản ghi nhiệt độ vẫn được lưu lại.';
  }

  @override
  String get rejectPickupConfirm => 'Từ chối thu hàng';

  @override
  String pickupRejectedToast(int refunded) {
    return 'Đã từ chối thu hàng do vượt nhiệt độ chuẩn (hoàn tiền $refunded đơn đặt trước)';
  }

  @override
  String get noTruckAssigned =>
      'Bạn chưa được phân công xe tải. Vui lòng liên hệ ban vận hành';

  @override
  String get noRouteTonight => 'Chưa có tuyến tối nay';

  @override
  String get errorLoad => 'Không thể tải dữ liệu';

  @override
  String get tonightRouteTitle => 'Tuyến tối nay';

  @override
  String get gpsUnavailable => 'Không lấy được vị trí';

  @override
  String get settings => 'Cài đặt';

  @override
  String minutesShort(int minutes) {
    return '$minutes phút';
  }

  @override
  String stopDoneHandoff(int count) {
    return 'Hoàn tất • đã giao $count đơn';
  }

  @override
  String get stopKindPickup => 'Thu hàng';

  @override
  String stopReservations(int count) {
    return '$count đơn đặt trước';
  }

  @override
  String nextStopPrefixed(String body) {
    return 'Điểm dừng tiếp theo • $body';
  }

  @override
  String get driverProfileTitle => 'Hồ sơ & cài đặt';

  @override
  String get driverRoleChip => 'Tài xế';

  @override
  String get assignedTruck => 'Xe phụ trách';

  @override
  String get unassigned => 'Chưa gán';

  @override
  String get plateNumberLabel => 'Biển số xe';

  @override
  String get driverTabRoute => 'Tuyến chạy';

  @override
  String get driverTabPickup => 'Thu hàng';

  @override
  String get driverTabSales => 'Bán hàng';

  @override
  String get driverTabEnd => 'Kết thúc';

  @override
  String get noPickupsTonight => 'Tối nay không có lịch thu hàng';

  @override
  String get gpsSending => 'Đang gửi vị trí';

  @override
  String get driverAccountSubtitle => 'Tài khoản tài xế';

  @override
  String get errorNotHandoverable => 'Đơn đặt trước này hiện chưa thể giao đồ';

  @override
  String get errorPaymentNotConfirmed =>
      'Đơn đặt trước này chưa được xác nhận thanh toán. Vui lòng không giao đồ và liên hệ ban vận hành';

  @override
  String get errorWalkupSoldOut =>
      'Suất bán trực tiếp tại điểm dừng này đã hết';

  @override
  String get errorWalkupNotConfirmed =>
      'Cần chốt số lượng thu hàng trước khi bán trực tiếp';

  @override
  String get errorBatchExpired => 'Món ăn này đã quá hạn bán';

  @override
  String get errorDonationExceedsStock =>
      'Số lượng tặng vượt quá số suất còn lại';

  @override
  String get errorDonationNotConfirmed =>
      'Cần chốt số lượng thu hàng trước khi ghi nhận tặng';

  @override
  String get errorDonationStopsOpen =>
      'Vẫn còn điểm bán xe chưa rời đi nên chưa thể ghi nhận tặng';

  @override
  String get errorDonationNoteRequired => 'Vui lòng nhập nơi nhận tặng';

  @override
  String get errorNotAssignedDriver => 'Bạn không phải tài xế phụ trách xe này';

  @override
  String get errorGeneric => 'Đã có lỗi xảy ra. Vui lòng thử lại';

  @override
  String get errorDonationQtyRequired => 'Vui lòng nhập số lượng tặng';

  @override
  String get errorPositiveInteger => 'Vui lòng nhập số nguyên từ 1 trở lên';

  @override
  String handedOverToast(String number) {
    return 'Đã ghi nhận giao đồ ($number)';
  }

  @override
  String get errorNotWaitingHere =>
      'Đơn này không phải đơn chờ nhận tại điểm dừng này';

  @override
  String get errorNoMatchingReservation =>
      'Không tìm thấy đơn đặt trước phù hợp';

  @override
  String get duplicateCodeTitle => 'Có nhiều đơn đặt trước trùng mã này';

  @override
  String duplicateCodeOption(String number, String time) {
    return '$number (đặt lúc $time)';
  }

  @override
  String walkupSoldToast(int price) {
    return 'Đã ghi nhận bán trực tiếp (¥$price)';
  }

  @override
  String get departDialogTitle => 'Rời khỏi điểm dừng này?';

  @override
  String currentStop(String name) {
    return 'Điểm dừng hiện tại: $name';
  }

  @override
  String departWarning(int count) {
    return 'Còn $count đơn đặt trước đang chờ nhận. Nếu rời đi bây giờ, các đơn này sẽ tính là “không đến nhận (quá hạn)” và không được hoàn tiền.';
  }

  @override
  String get departWarningTitle => 'Vẫn còn đơn đặt trước chưa nhận';

  @override
  String get cautionBadge => 'Lưu ý';

  @override
  String get departConfirm => 'Rời điểm dừng';

  @override
  String departedWithExpired(int count) {
    return 'Đã rời điểm dừng ($count đơn chưa nhận đã quá hạn)';
  }

  @override
  String get departed => 'Đã rời điểm dừng';

  @override
  String get departedLabel => 'Đã rời đi';

  @override
  String minutesUntilDeparture(int minutes) {
    return 'Còn $minutes phút đến giờ rời điểm';
  }

  @override
  String reservationsCount(int count) {
    return '$count đơn đặt trước';
  }

  @override
  String get reservationHandoffTab => 'Đơn đặt trước';

  @override
  String get walkupTab => 'Bán trực tiếp';

  @override
  String get handedOverLabel => 'Đã giao';

  @override
  String get waitingLabel => 'Chờ nhận';

  @override
  String get departButton => 'Rời điểm dừng';

  @override
  String get scanPickupQr => 'Quét mã QR nhận đồ';

  @override
  String get scanPickupQrHint => 'Hãy quét mã QR nhận đồ của khách hàng';

  @override
  String get manualCodeFallback => 'Không quét được mã QR? Nhập mã thủ công';

  @override
  String get batchLabel => 'Món ăn';

  @override
  String get noWalkupBatches => 'Không có món ăn nào để bán tại điểm dừng này';

  @override
  String mealsRemaining(int qty) {
    return 'Còn $qty suất';
  }

  @override
  String get registerSale => 'Ghi nhận bán hàng';

  @override
  String get soldLabel => 'Đã bán';

  @override
  String get enterPickupCode => 'Nhập mã nhận đồ';

  @override
  String get pickupCodeHint => 'VD: A7K2';

  @override
  String get verifyCode => 'Kiểm tra mã';

  @override
  String get noSalesTonight => 'Tối nay không có lịch bán hàng';

  @override
  String get routeEndTitle => 'Kết thúc tuyến chạy';

  @override
  String get routeSummaryTitle => 'Tổng kết tuyến chạy';

  @override
  String get routeEndThanks => 'Cảm ơn bạn đã hoàn thành tuyến chạy tối nay';

  @override
  String mealsCount(int count) {
    return '$count suất';
  }

  @override
  String get salesStopsLabel => 'Điểm bán';

  @override
  String openStopsWarning(int count) {
    return 'Còn $count điểm bán xe chưa rời đi. Vui lòng vào mục “Bán hàng” để thao tác rời điểm.';
  }

  @override
  String donationBatchOption(String name, int qty, int remaining) {
    return '$name (chốt $qty suất · còn $remaining suất)';
  }

  @override
  String donationRecorded(int remaining) {
    return 'Đã ghi nhận tặng (món này còn $remaining suất)';
  }

  @override
  String get donationTitle => 'Ghi nhận tặng phần chưa bán hết';

  @override
  String get donationLockedNotice =>
      'Bạn có thể ghi nhận tặng sau khi đã rời tất cả các điểm bán (khi đã rời điểm sẽ không thể bán thêm, số lượng tồn kho sẽ được chốt).';

  @override
  String get noConfirmedBatches => 'Chưa có món ăn nào đã chốt số lượng';

  @override
  String get donationQtyLabel => 'Số lượng tặng';

  @override
  String get donationRecipientLabel => 'Nơi nhận tặng';

  @override
  String get donationRecipientHint => 'VD: Bếp ăn từ thiện ABC';

  @override
  String get donationHandedOverCheck =>
      'Tôi xác nhận đã bàn giao cho nơi nhận tặng';

  @override
  String get recordDonationButton => 'Ghi nhận tặng';

  @override
  String get driverLicenseTitle => 'Giấy phép lái xe';

  @override
  String get licenseStatusNone => 'Chưa nộp';

  @override
  String get licenseStatusSubmitted => 'Chờ xét duyệt';

  @override
  String get licenseStatusVerified => 'Đã xác nhận';

  @override
  String get licenseStatusRejected => 'Yêu cầu nộp lại';

  @override
  String get licenseNoneBody =>
      'Vui lòng chụp ảnh giấy phép lái xe và tải lên. Bạn chỉ có thể nhận ca chạy sau khi ban vận hành đã xác nhận.';

  @override
  String get licenseSubmittedBody =>
      'Ban vận hành đang kiểm tra thông tin. Sau khi xác nhận xong, bạn sẽ có thể nhận ca chạy.';

  @override
  String licenseExpiresOn(String date) {
    return 'Hạn đến $date';
  }

  @override
  String get licenseRejectedLabel => 'Tin nhắn từ ban vận hành';

  @override
  String get licenseUploadButton => 'Chụp ảnh và tải lên';

  @override
  String get licenseResubmitButton => 'Gửi lại giấy phép lái xe mới';

  @override
  String get licenseResubmitNote =>
      'Khi gửi lại, bạn sẽ tạm thời không nhận được ca chạy mới cho đến khi ban vận hành xác nhận xong.';

  @override
  String get licensePrivacyNote => 'Chỉ ban vận hành mới xem được ảnh này.';

  @override
  String get licenseSourceCamera => 'Chụp bằng máy ảnh';

  @override
  String get licenseSourceGallery => 'Chọn từ thư viện ảnh';

  @override
  String get licenseUploadSuccess =>
      'Đã gửi. Vui lòng chờ ban vận hành xác nhận.';

  @override
  String get licenseUploadError =>
      'Không gửi được. Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String upcomingShiftsTitle(int days) {
    return 'Ca chạy sắp tới ($days ngày)';
  }

  @override
  String get upcomingShiftsEmpty =>
      'Hiện chưa có ca chạy nào. Khi ban vận hành xếp ca, lịch chạy sẽ hiển thị tại đây.';

  @override
  String get shiftsLoadError => 'Không tải được lịch ca chạy.';

  @override
  String get torchOn => 'Bật đèn pin';

  @override
  String get torchOff => 'Tắt đèn pin';

  @override
  String get mealPhotoLabel => 'Ảnh món ăn';

  @override
  String get detailNotePhoto =>
      'Ảnh món ăn do quán đăng. Số lượng và cách trình bày thực tế có thể khác với hình ảnh. Nếu bạn có cơ địa dị ứng, vui lòng kiểm tra kỹ thông tin chất gây dị ứng.';

  @override
  String get legalTermsTitle => 'Điều khoản sử dụng';

  @override
  String get legalPrivacyTitle => 'Chính sách quyền riêng tư';

  @override
  String get legalEnactedOn =>
      'Ngày sửa đổi: 11/10/2026 (Ngày ban hành: 09/10/2026)';

  @override
  String get legalDemoNotice =>
      'Nội dung này dùng cho bản thử nghiệm của đồ án tốt nghiệp và sẽ được chuyên gia rà soát trước khi vận hành thực tế.';

  @override
  String get legalContactTitle => 'Liên hệ';

  @override
  String get termsArticle1Title => 'Điều 1 (Phạm vi áp dụng)';

  @override
  String get termsArticle1Body =>
      'Điều khoản này quy định các điều kiện sử dụng ứng dụng di động EcoMeal (sau đây gọi là “Dịch vụ”). Người dùng cần đồng ý với điều khoản này khi đăng ký tài khoản trước khi sử dụng Dịch vụ.';

  @override
  String get termsArticle2Title => 'Điều 2 (Tài khoản)';

  @override
  String get termsArticle2Body =>
      'Bạn có thể đăng ký tài khoản bằng địa chỉ email và mật khẩu, LINE hoặc Apple. Vui lòng đảm bảo thông tin đăng ký luôn chính xác và không tiết lộ mật khẩu cho bên thứ ba. Khi đăng ký qua LINE hoặc Apple, điều khoản này vẫn áp dụng như một tài khoản EcoMeal thông thường. Nếu phát hiện hành vi sử dụng trái phép, ban vận hành có thể tạm khóa tài khoản.';

  @override
  String get termsArticle3Title => 'Điều 3 (Sản phẩm)';

  @override
  String get termsArticle3Body =>
      'Đồ ăn bán trên Dịch vụ là các phần ăn được chế biến trong ngày và còn dư tại các quán đối tác (túi đồ ăn bất ngờ). Món ăn và số lượng thay đổi tùy ngày, giá sẽ giảm dần khi càng gần hạn bán. Vui lòng kiểm tra kỹ 28 nhóm chất gây dị ứng và xuất xứ nguyên liệu trên ứng dụng trước khi mua. Do chế biến chung trong cùng một khu bếp, không thể loại trừ hoàn toàn khả năng lẫn một lượng rất nhỏ chất gây dị ứng.';

  @override
  String get termsArticle4Title => 'Điều 4 (Đặt trước và thanh toán)';

  @override
  String get termsArticle4Body =>
      'Mỗi ngày bạn có thể đặt trước tối đa 2 đơn. Thanh toán được thực hiện bằng thẻ đã lưu. Hiện tại Dịch vụ đang trong giai đoạn thử nghiệm nên bạn sẽ không bị trừ tiền thực tế. Số thẻ và mã bảo mật không được lưu trên máy chủ của Dịch vụ.';

  @override
  String get termsArticle5Title => 'Điều 5 (Hủy và hoàn tiền)';

  @override
  String get termsArticle5Body =>
      'Nếu hủy đơn trước mốc 30 phút so với giờ nhận dự kiến, bạn sẽ được hoàn tiền toàn bộ; từ mốc 30 phút trước giờ nhận trở đi, đơn hủy sẽ không được hoàn tiền (ví dụ: nhận lúc 20:00 thì hủy trước 19:30 được hoàn tiền toàn bộ, từ 19:30 trở đi sẽ không hoàn tiền). Các đơn không chuẩn bị đủ số lượng sẽ được tự động hoàn tiền. Đơn không được nhận trước giờ xe rời điểm nhận sẽ hết hiệu lực và không được hoàn tiền.';

  @override
  String get termsArticle6Title => 'Điều 6 (Nhận đồ)';

  @override
  String get termsArticle6Body =>
      'Vui lòng đến xe Eco-Truck đang đỗ tại điểm nhận trong khung giờ đã đặt và xuất trình mã QR hoặc mã xác nhận trên màn hình đơn hàng để nhận đồ.';

  @override
  String get termsArticle7Title => 'Điều 7 (Vị trí và thông báo)';

  @override
  String get termsArticle7Body =>
      'Thông tin vị trí chỉ được sử dụng trực tiếp trên thiết bị để gợi ý các điểm nhận gần bạn và không lưu trên máy chủ. Các thông báo (xe sắp đến, hoàn tiền, phản hồi báo cáo sự cố, túi đồ ăn mới tại điểm nhận yêu thích) sẽ gửi về ứng dụng nếu bạn bật thông báo. Nếu tắt thông báo ứng dụng nhưng đã liên kết LINE, thông báo sẽ gửi từ tài khoản LINE chính thức của EcoMeal. Riêng thông báo xe sắp đến sẽ gửi qua LINE nếu bạn đã liên kết LINE.';

  @override
  String get termsArticle8Title => 'Điều 8 (Ảnh hồ sơ)';

  @override
  String get termsArticle8Body =>
      'Ảnh hồ sơ chỉ hiển thị tại mục Trang của tôi của chính bạn. Không được tải lên hình ảnh xâm phạm quyền của bên thứ ba như quyền hình ảnh cá nhân, bản quyền hoặc hình ảnh vi phạm thuần phong mỹ tục. Ban vận hành có thể xóa các hình ảnh không phù hợp.';

  @override
  String get termsArticle9Title => 'Điều 9 (Hành vi bị cấm)';

  @override
  String get termsArticle9Body =>
      'Nghiêm cấm các hành vi vi phạm pháp luật, gây phiền hà cho người dùng khác, quán đối tác hoặc tài xế, bán lại đồ ăn đã mua hoặc truy cập trái phép vào Dịch vụ.';

  @override
  String get termsArticle10Title =>
      'Điều 10 (Thay đổi, tạm ngừng và miễn trừ trách nhiệm)';

  @override
  String get termsArticle10Body =>
      'Dịch vụ đang trong quá trình phát triển và kiểm chứng trong khuôn khổ đồ án tốt nghiệp nên có thể thay đổi hoặc tạm ngừng mà không báo trước. Khi sửa đổi điều khoản này, chúng tôi sẽ thông báo trên ứng dụng và xin lại sự đồng ý của bạn đối với các thay đổi quan trọng.';

  @override
  String get privacySection1Title => '1. Thông tin thu thập';

  @override
  String get privacySection1Body =>
      'Chúng tôi thu thập thông tin đăng ký tài khoản (địa chỉ email, tên hiển thị, phiên âm tên, ảnh hồ sơ), lịch sử đặt trước và mua hàng, phương thức thanh toán (chỉ lưu thương hiệu thẻ, 4 số cuối và hạn sử dụng), ID người dùng LINE khi bạn đăng nhập hoặc liên kết LINE, ID và địa chỉ email nhận từ Apple khi đăng nhập bằng Apple (bao gồm cả email ẩn danh của Apple), nội dung liên hệ, nhật ký sử dụng ứng dụng (thao tác xem túi đồ ăn và màn hình đặt trước), thông tin lỗi (chi tiết lỗi, loại thiết bị, phiên bản ứng dụng) và mã định danh thiết bị để gửi thông báo. Dịch vụ không thu thập hay lưu trữ số thẻ và mã bảo mật (đơn vị trung gian thanh toán sẽ tiếp nhận trực tiếp).';

  @override
  String get privacySection2Title => '2. Thông tin vị trí';

  @override
  String get privacySection2Body =>
      'Chúng tôi sử dụng vị trí của thiết bị để gợi ý các điểm nhận gần bạn nhưng không gửi lên hay lưu trữ trên máy chủ.';

  @override
  String get privacySection3Title => '3. Mục đích sử dụng';

  @override
  String get privacySection3Body =>
      'Thông tin được dùng để xử lý đặt trước, giao nhận đồ và hoàn tiền, gửi thông báo nhận đồ, phản hồi liên hệ và cải thiện Dịch vụ.';

  @override
  String get privacySection4Title =>
      '4. Cung cấp cho bên thứ ba và ủy thác xử lý';

  @override
  String get privacySection4Body =>
      'Chúng tôi không cung cấp thông tin cho bên thứ ba nếu không có sự đồng ý của bạn, trừ trường hợp theo quy định pháp luật. Chúng tôi ủy thác xử lý dữ liệu cho các bên cung cấp dịch vụ: lưu trữ dữ liệu (Supabase), hiển thị bản đồ (Google Maps), gửi thông báo (LINE, Firebase Cloud Messaging), thanh toán (Stripe) và giám sát lỗi (Sentry).';

  @override
  String get privacySection5Title => '5. Yêu cầu xem, chỉnh sửa và xóa dữ liệu';

  @override
  String get privacySection5Body =>
      'Để yêu cầu tra cứu, chỉnh sửa hoặc xóa thông tin đã đăng ký, vui lòng liên hệ qua biểu mẫu liên hệ. Bạn có thể tự xóa tài khoản và ảnh hồ sơ bất cứ lúc nào tại Trang của tôi.';

  @override
  String get termsUpdatedTitle => 'Điều khoản sử dụng đã được cập nhật';

  @override
  String get termsUpdatedBody =>
      'Để tiếp tục sử dụng EcoMeal, bạn cần đồng ý với Điều khoản sử dụng và Chính sách quyền riêng tư mới nhất.';

  @override
  String get termsAgreeAndContinue => 'Đồng ý và tiếp tục';

  @override
  String get termsDeclineAndLogout => 'Không đồng ý (Đăng xuất)';

  @override
  String get errorTermsAcceptFailed =>
      'Không thể ghi nhận sự đồng ý. Vui lòng thử lại';

  @override
  String get signupConsentBefore => 'Tôi đồng ý với ';

  @override
  String get signupConsentBetween => ' và ';

  @override
  String get signupConsentAfter => '';

  @override
  String get signupConsentHint =>
      'Đánh dấu đồng ý để bật nút “Đăng ký”. Bấm vào liên kết để đọc toàn văn.';

  @override
  String get aboutAppSection => 'Về ứng dụng';

  @override
  String get appVersionLabel => 'Phiên bản';

  @override
  String get profilePhotoSet => 'Thêm ảnh';

  @override
  String get profilePhotoChange => 'Đổi ảnh';

  @override
  String get profilePhotoHint =>
      'JPEG, PNG (tối đa 10MB). Ảnh sẽ được cắt vuông khi hiển thị.';

  @override
  String get profilePhotoUploading => 'Đang tải ảnh lên…';

  @override
  String get errorProfilePhotoUpload =>
      'Không tải được ảnh lên. Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get errorProfilePhotoInvalid =>
      'Vui lòng chọn ảnh JPEG hoặc PNG từ 10MB trở xuống';

  @override
  String get profilePhotoSheetTitle => 'Ảnh đại diện';

  @override
  String get profilePhotoTake => 'Chụp ảnh';

  @override
  String get profilePhotoLibrary => 'Chọn từ thư viện';

  @override
  String get profilePhotoDelete => 'Xóa ảnh';

  @override
  String get profilePhotoDeleted => 'Đã xóa ảnh';

  @override
  String get photoAccessDeniedTitle => 'Chưa cấp quyền truy cập máy ảnh và ảnh';

  @override
  String get openSettings => 'Mở cài đặt';

  @override
  String get photoAccessDeniedBody =>
      'Vui lòng cho phép EcoMeal truy cập máy ảnh và thư viện ảnh trong cài đặt thiết bị.';

  @override
  String get deleteAccountLink => 'Xóa tài khoản';

  @override
  String get deleteAccountTitle => 'Xóa tài khoản';

  @override
  String get deleteAccountLead =>
      'Sau khi xóa tài khoản, bạn sẽ không thể đăng nhập vào EcoMeal nữa. Thao tác này không thể hoàn tác.';

  @override
  String get deleteAccountRemovedTitle => 'Dữ liệu sẽ bị xóa';

  @override
  String get deleteAccountRemoved1 =>
      '• Địa chỉ email, tên hiển thị, phiên âm tên, ảnh đại diện';

  @override
  String get deleteAccountRemoved2 =>
      '• Thẻ đã lưu (thương hiệu thẻ, 4 số cuối, hạn sử dụng)';

  @override
  String get deleteAccountRemoved3 => '• Liên kết LINE và thông báo xe sắp đến';

  @override
  String get deleteAccountKeptTitle => 'Dữ liệu được giữ lại (đã ẩn danh)';

  @override
  String get deleteAccountKeptBody =>
      'Lịch sử đặt trước và mua hàng trước đây được lưu lại sau khi đã gỡ bỏ tên và địa chỉ email để phục vụ đối soát doanh thu và quyết toán với các quán đối tác.';

  @override
  String get deleteAccountNote =>
      'Nếu bạn còn đơn đặt trước chưa nhận, vui lòng hủy hoặc nhận đồ trước khi xóa tài khoản. Bạn có thể hủy kết bạn với tài khoản chính thức EcoMeal trong ứng dụng LINE.';

  @override
  String get deleteAccountOpenOrders =>
      'Bạn đang có đơn đặt trước chưa nhận. Vui lòng hủy tại tab Đặt trước hoặc nhận đồ trước khi xóa tài khoản.';

  @override
  String get deleteAccountButton => 'Xóa tài khoản';

  @override
  String get deleteAccountDialogTitle => 'Xóa tài khoản?';

  @override
  String get deleteAccountDialogBody =>
      'Thao tác này không thể hoàn tác. Lịch sử đặt trước và mua hàng sẽ được lưu lại dưới dạng ẩn danh.';

  @override
  String get deleteAccountConfirm => 'Xóa';

  @override
  String get accountDeleted => 'Đã xóa tài khoản';

  @override
  String get errorDeleteAccount => 'Không xóa được tài khoản. Vui lòng thử lại';

  @override
  String get legalTokushohoTitle =>
      'Thông tin theo Luật Giao dịch Thương mại Đặc định';

  @override
  String taxIncludedLine(int rate) {
    return 'Trong đó thuế tiêu dùng ($rate%)';
  }

  @override
  String priceTaxIncluded(String price) {
    return '$price (đã gồm thuế)';
  }

  @override
  String get receiptButton => 'Biên lai';

  @override
  String get receiptTitle => 'Biên lai';

  @override
  String receiptAddressee(String name) {
    return 'Khách hàng: $name';
  }

  @override
  String get receiptPurpose => 'Nội dung: Tiền thực phẩm';

  @override
  String receiptTaxableLine(int rate) {
    return 'Áp dụng thuế $rate% (đã gồm thuế)';
  }

  @override
  String get receiptUsedOn => 'Ngày mua';

  @override
  String get receiptOrderNumber => 'Mã đơn hàng';

  @override
  String get receiptPaymentMethod => 'Phương thức thanh toán';

  @override
  String get receiptPaymentCard => 'Thẻ tín dụng';

  @override
  String get receiptIssuedOn => 'Ngày phát hành';

  @override
  String get receiptIssuer => 'Ban vận hành EcoMeal (Đồ án tốt nghiệp)';

  @override
  String get receiptNote =>
      '※ Sản phẩm thuộc diện áp dụng thuế suất giảm (8%). Do Dịch vụ chưa đăng ký là đơn vị phát hành hóa đơn hợp chuẩn, biên lai này không có mã số đăng ký thuế. Vui lòng chụp lưu hoặc in màn hình này khi cần sử dụng.';

  @override
  String get stripeCardIncomplete =>
      'Vui lòng nhập số thẻ, hạn sử dụng và mã bảo mật.';

  @override
  String get errorCardDeclined =>
      'Không thể liên kết thẻ này. Vui lòng thử thẻ khác';

  @override
  String get pushSectionTitle => 'Thông báo ứng dụng';

  @override
  String get pushOffTitle => 'Thông báo ứng dụng';

  @override
  String get pushOffBody =>
      'Nhận thông báo trên điện thoại khi xe sắp đến hoặc khi có hoàn tiền.';

  @override
  String get pushEnableButton => 'Bật thông báo';

  @override
  String get pushOnTitle => 'Thông báo đang bật';

  @override
  String get pushOnBody =>
      'Ứng dụng sẽ thông báo khi xe sắp đến, khi có hoàn tiền và khi có túi đồ ăn mới tại điểm nhận yêu thích. Nếu đã liên kết LINE, thông báo xe sắp đến sẽ gửi qua LINE.';

  @override
  String get pushDeniedTitle => 'Chưa cho phép thông báo';

  @override
  String get pushDeniedBody =>
      'Vui lòng cho phép EcoMeal gửi thông báo trong cài đặt thiết bị.';

  @override
  String get errorPushEnable => 'Không bật được thông báo. Vui lòng thử lại';

  @override
  String get reportIssueButton => 'Báo sự cố';

  @override
  String get reportIssueTitle => 'Báo sự cố';

  @override
  String get reportIssueQuestion => 'Bạn gặp vấn đề gì?';

  @override
  String get issueCategoryWrongContents =>
      'Món ăn hoặc số lượng khác với đơn đã đặt';

  @override
  String get issueCategoryQuality =>
      'Chất lượng có vấn đề (ôi thiu, có dị vật...)';

  @override
  String get issueCategoryNotReceived => 'Không nhận được đồ';

  @override
  String get issueCategoryOther => 'Khác';

  @override
  String get reportIssueDetailLabel => 'Mô tả chi tiết';

  @override
  String get reportIssueDetailHint => 'VD: Một phần bánh mì bị mốc';

  @override
  String get reportIssueNote =>
      'Vui lòng báo sự cố trong vòng 48 giờ kể từ khi nhận đồ. Ban vận hành sẽ kiểm tra và hoàn tiền nếu cần (kết quả sẽ được gửi qua thông báo và hiển thị trong lịch sử đặt trước).';

  @override
  String get reportIssueSubmit => 'Gửi báo cáo';

  @override
  String get reportIssueSent => 'Đã gửi báo cáo';

  @override
  String get errorReportIssueSelect => 'Vui lòng chọn loại sự cố';

  @override
  String get errorReportIssueDetail =>
      'Vui lòng nhập mô tả chi tiết (tối đa 500 ký tự)';

  @override
  String get errorReportIssueLate =>
      'Đã quá 48 giờ kể từ khi nhận đồ nên không thể báo qua ứng dụng. Vui lòng liên hệ với chúng tôi qua biểu mẫu liên hệ';

  @override
  String get errorReportIssueDuplicate =>
      'Đơn hàng này đã được gửi báo cáo trước đó';

  @override
  String get errorReportIssue => 'Không gửi được báo cáo. Vui lòng thử lại';

  @override
  String get issueOpenTitle => 'Đã báo sự cố (đang kiểm tra)';

  @override
  String get issueOpenBody =>
      'Ban vận hành đang kiểm tra nội dung và sẽ hoàn tiền nếu cần. Chúng tôi sẽ thông báo kết quả cho bạn.';

  @override
  String issueResolvedRefund(int amount) {
    return 'Đã xử lý: Hoàn tiền ¥$amount';
  }

  @override
  String get issueResolvedNoRefund => 'Đã xử lý';

  @override
  String get favoriteStopsTitle => 'Điểm nhận yêu thích';

  @override
  String get favoriteStopsIntro =>
      'Khi có túi đồ ăn mới tại các điểm nhận này, ứng dụng sẽ gửi thông báo (hoặc qua LINE) cho bạn. Bạn có thể lưu tối đa 5 điểm.';

  @override
  String get favoriteStopsHint =>
      'Chạm vào điểm nhận để xem các túi đồ ăn có thể nhận tối nay. Chạm ★ để bỏ lưu. Nếu không nhận được thông báo, hãy bật “Thông báo ứng dụng” tại Trang của tôi.';

  @override
  String get stopBagsHeading => 'Túi đồ ăn có thể nhận tại điểm này tối nay';

  @override
  String get stopBagsEmptyTitle => 'Tối nay chưa có túi đồ ăn nào';

  @override
  String get stopBagsEmptyBody =>
      'Khi có túi đồ ăn mới tại điểm nhận này, ứng dụng sẽ gửi thông báo (hoặc qua LINE) cho bạn.';

  @override
  String get favoriteStopsEmptyTitle => 'Chưa có điểm nhận yêu thích';

  @override
  String get favoriteStopsEmptyBody =>
      'Chạm biểu tượng ☆ ở mục điểm nhận trong chi tiết túi đồ ăn để nhận thông báo khi có đồ ăn mới tại điểm nhận đó.';

  @override
  String get favoriteStopsRowNone =>
      'Chưa lưu · Nhận thông báo khi có túi đồ ăn mới';

  @override
  String favoriteStopsRowCount(int count) {
    return '$count điểm · Nhận thông báo khi có túi đồ ăn mới';
  }

  @override
  String get favoriteAddedTitle => 'Đã thêm vào yêu thích';

  @override
  String get favoriteAddedBody =>
      'Chúng tôi sẽ thông báo khi có túi đồ ăn mới tại điểm nhận này.';

  @override
  String get favoriteAddedPushOff =>
      'Hiện thông báo đang tắt nên bạn sẽ chưa nhận được thông báo mới.';

  @override
  String get favoriteAddedPushDenied =>
      'Chưa cấp quyền thông báo nên bạn sẽ không nhận được thông báo mới.';

  @override
  String get favoriteRemovedTitle => 'Đã bỏ khỏi yêu thích';

  @override
  String get favoriteRemovedBody =>
      'Đã tắt thông báo túi đồ ăn mới cho điểm nhận này.';

  @override
  String get favoriteFeedbackClose => 'Đóng';

  @override
  String get favoriteLimitReached =>
      'Bạn chỉ có thể lưu tối đa 5 điểm nhận yêu thích. Vui lòng vào Trang của tôi để quản lý lại';

  @override
  String get favoriteUpdateFailed =>
      'Không cập nhật được danh sách yêu thích. Vui lòng thử lại sau';

  @override
  String get favoriteAddTooltip => 'Thêm điểm nhận này vào yêu thích';

  @override
  String get favoriteRemoveTooltip => 'Bỏ khỏi yêu thích';

  @override
  String get ratingPromptTitle => 'Túi đồ ăn của bạn thế nào?';

  @override
  String get ratingPromptHint =>
      'Chạm vào số sao để đánh giá (trong 7 ngày kể từ khi nhận)';

  @override
  String get ratingLabel1 => 'Không hài lòng';

  @override
  String get ratingLabel2 => 'Chưa ưng ý';

  @override
  String get ratingLabel3 => 'Bình thường';

  @override
  String get ratingLabel4 => 'Hài lòng';

  @override
  String get ratingLabel5 => 'Rất hài lòng';

  @override
  String ratingStarSemantics(int count) {
    return '$count sao';
  }

  @override
  String ratingSheetOrder(String number, String time) {
    return 'Đơn #$number · Nhận lúc $time';
  }

  @override
  String get ratingCommentLabel => 'Lời nhắn gửi quán (tùy chọn)';

  @override
  String get ratingCommentHint =>
      'VD: Phần ăn đầy đặn, lúc nhận vẫn còn ấm nóng.';

  @override
  String get ratingPrivacyNote =>
      'Đánh giá của bạn sẽ được gửi ẩn danh đến quán. Vui lòng không ghi thông tin cá nhân.';

  @override
  String get ratingSubmit => 'Gửi đánh giá';

  @override
  String get ratingSent => 'Đã gửi đánh giá. Cảm ơn bạn';

  @override
  String get ratingErrorExpired =>
      'Đã quá hạn 7 ngày kể từ khi nhận nên không thể đánh giá';

  @override
  String get ratingErrorAlreadyRated => 'Bạn đã đánh giá đơn hàng này rồi';

  @override
  String get ratingErrorFailed => 'Không gửi được đánh giá. Vui lòng thử lại';

  @override
  String get ratedLabel => 'Đánh giá của bạn';

  @override
  String get ratedThanks => 'Cảm ơn bạn';

  @override
  String ratedSemantics(int count) {
    return 'Đánh giá của bạn: $count sao';
  }

  @override
  String get impactTitle => 'Thực phẩm bạn đã giải cứu';

  @override
  String get impactEmpty =>
      'Khi bạn nhận túi đồ ăn, lượng thực phẩm đã giải cứu và lượng phát thải CO₂ giảm được sẽ hiển thị tại đây.';

  @override
  String impactBagsValue(int count) {
    return '$count túi';
  }

  @override
  String get impactBagsLabel => 'Túi đồ ăn đã nhận';

  @override
  String get impactFoodLabel => 'Thực phẩm đã cứu';

  @override
  String get impactCo2Label => 'Giảm phát thải CO₂';

  @override
  String impactApproxKg(String kg) {
    return 'Khoảng ${kg}kg';
  }

  @override
  String impactNote(String bagKg, String factor) {
    return 'Số liệu ước tính (tính theo khoảng ${bagKg}kg mỗi túi và giảm khoảng ${factor}kg CO₂ cho mỗi 1kg thực phẩm tránh lãng phí)';
  }

  @override
  String get couponsTitle => 'Mã giảm giá · Giới thiệu bạn bè';

  @override
  String couponsRowSubtitle(int count) {
    return '$count mã giảm giá · Giới thiệu bạn bè nhận ¥100';
  }

  @override
  String get couponSectionLabel => 'Mã giảm giá';

  @override
  String get subtotalLabel => 'Tạm tính';

  @override
  String couponAmountOff(int amount) {
    return 'Giảm ¥$amount';
  }

  @override
  String couponValidUntil(String date) {
    return 'Hạn đến $date';
  }

  @override
  String get couponReasonWelcome => 'Mã giới thiệu bạn bè (Quà chào mừng)';

  @override
  String get couponReasonReward => 'Mã giới thiệu bạn bè (Quà cảm ơn)';

  @override
  String get couponReasonCampaign => 'Mã giảm giá khuyến mãi';

  @override
  String get couponsUsableHeading => 'Mã giảm giá có thể dùng';

  @override
  String get couponsNone => 'Chưa có mã giảm giá nào dùng được';

  @override
  String get couponNoneHint => 'Giới thiệu bạn bè để nhận mã giảm giá ¥100';

  @override
  String get couponsAutoNote =>
      'Mã giảm giá sẽ được tự động áp dụng tại màn hình xác nhận đặt trước (mỗi đơn áp dụng 1 mã). Nếu bạn hủy đơn trong thời hạn hủy miễn phí, mã giảm giá sẽ được hoàn lại.';

  @override
  String get errorCouponUnavailable =>
      'Mã giảm giá này không còn dùng được nữa. Vui lòng kiểm tra lại thông tin và thử lại';

  @override
  String get receiptCouponLine => 'Giảm giá (coupon)';

  @override
  String get referralMyCodeLabel => 'Mã giới thiệu của bạn';

  @override
  String get referralCopy => 'Sao chép';

  @override
  String get referralCopied => 'Đã sao chép mã giới thiệu';

  @override
  String get referralShareLine => 'Gửi qua LINE';

  @override
  String referralShareText(String code) {
    return 'Cùng EcoMeal nhận đồ ăn ngon với giá cực ưu đãi! Đăng ký tài khoản và nhập mã giới thiệu “$code” để nhận ngay mã giảm giá ¥100 nhé.';
  }

  @override
  String get referralHowItWorks =>
      'Khi bạn bè nhập mã giới thiệu của bạn, họ sẽ nhận được mã giảm giá ¥100. Khi họ nhận túi đồ ăn đầu tiên, bạn cũng sẽ nhận được mã giảm giá ¥100.';

  @override
  String get referralEnterLabel => 'Nhập mã giới thiệu từ bạn bè';

  @override
  String get referralEnterHint => 'VD: EM3PX9';

  @override
  String get referralApply => 'Áp dụng';

  @override
  String get referralEnterNote =>
      'Áp dụng trong vòng 14 ngày kể từ khi đăng ký và trước khi nhận túi đồ ăn đầu tiên.';

  @override
  String referralApplied(String code) {
    return 'Đã áp dụng mã giới thiệu $code';
  }

  @override
  String get referralAppliedToast => 'Bạn đã nhận được mã giảm giá ¥100';

  @override
  String get referralErrorFormat => 'Vui lòng nhập mã giới thiệu gồm 6 ký tự';

  @override
  String get referralErrorNotFound => 'Không tìm thấy mã giới thiệu này';

  @override
  String get referralErrorOwnCode =>
      'Không thể dùng mã giới thiệu của chính mình';

  @override
  String get referralErrorNotEligible => 'Đã hết thời hạn nhập mã giới thiệu';

  @override
  String get referralErrorFailed =>
      'Không áp dụng được mã giới thiệu. Vui lòng thử lại';

  @override
  String get socialLoginDivider => 'hoặc';

  @override
  String get lineLoginButton => 'Đăng nhập bằng LINE';

  @override
  String get appleLoginButton => 'Đăng nhập bằng Apple';

  @override
  String get socialLoginNote =>
      'Nếu dùng lần đầu, tài khoản EcoMeal sẽ được tạo qua tài khoản LINE hoặc Apple.';

  @override
  String get lineLoginFailed =>
      'Không đăng nhập được bằng LINE. Vui lòng thử lại sau';

  @override
  String get appleLoginFailed =>
      'Không đăng nhập được bằng Apple. Vui lòng thử lại sau';

  @override
  String get socialLoginNotCustomer =>
      'Tài khoản này không thể đăng nhập bằng LINE. Vui lòng đăng nhập bằng email và mật khẩu';

  @override
  String get signedInWithLine => 'Đang đăng nhập bằng LINE';

  @override
  String get storeReviewPendingTitle => 'Đang xét duyệt';

  @override
  String get storeReviewPendingBody =>
      'EcoMeal đang kiểm tra thông tin đăng ký của quán. Kết quả sẽ được thông báo qua email.';

  @override
  String get storeReviewCheckButton => 'Kiểm tra kết quả xét duyệt';

  @override
  String get storeFieldName => 'Tên quán';

  @override
  String get storeFieldAppliedAt => 'Ngày đăng ký';

  @override
  String get storeFieldApplicant => 'Người đăng ký';

  @override
  String get storeReviewRejectedTitle => 'Chưa được phê duyệt';

  @override
  String get storeReviewRejectedBody =>
      'Nếu muốn chỉnh sửa thông tin để đăng ký lại, vui lòng liên hệ qua mục Liên hệ.';

  @override
  String get storeRejectionReasonLabel => 'Lý do từ chối';

  @override
  String get storeNotRegisteredTitle => 'Chưa hoàn tất đăng ký quán';

  @override
  String get storeNotRegisteredBody =>
      'Vui lòng đăng ký quán qua trang web (ecomeal-pi.vercel.app). Sau khi được duyệt, quán có thể đăng bán món ăn ngay trên ứng dụng này.';

  @override
  String get storeTabHome => 'Trang chủ';

  @override
  String get storeTabRegister => 'Đăng bán';

  @override
  String get storeTabSettlement => 'Tiền về';

  @override
  String get storeTabSettings => 'Cài đặt';

  @override
  String get storeRegisterCta => 'Đăng bán phần ăn hôm nay';

  @override
  String storeRegisterDeadline(String time, String remaining) {
    return 'Nên đăng trước $time (còn $remaining)';
  }

  @override
  String storeRegisterDeadlinePassed(String time) {
    return 'Đã qua giờ gợi ý $time. Quán vẫn có thể đăng bán cho đến khi xe rời quán';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String get storePhotoRemovedTitle => 'Ảnh món ăn đã bị gỡ';

  @override
  String get storePhotoRemovedHint =>
      'Lần tới vui lòng dùng ảnh không để lộ tên quán hoặc logo.';

  @override
  String get storePhotoRemovedAck => 'Đã hiểu';

  @override
  String get storeTodayBatches => 'Món đăng bán hôm nay';

  @override
  String get storeBatchStatusEstimated => 'Chờ thu hàng';

  @override
  String get storeBatchStatusOnSale => 'Đang bán';

  @override
  String get storeBatchStatusEnded => 'Đã kết thúc';

  @override
  String storeSellBy(String time) {
    return 'Hết giờ bán $time';
  }

  @override
  String storeCollectionPlanned(String time) {
    return 'Dự kiến thu hàng $time';
  }

  @override
  String storeBatchQtyConfirmed(int estimated, int confirmed) {
    return 'Dự kiến $estimated suất → Đã nhận $confirmed suất';
  }

  @override
  String storeBatchQtyEstimated(int estimated) {
    return 'Dự kiến $estimated suất (chờ thu hàng)';
  }

  @override
  String storeBatchCounts(int reserved, int pickedUp) {
    return 'Đặt trước $reserved · Đã nhận $pickedUp';
  }

  @override
  String storeBatchReserved(int reserved) {
    return 'Đặt trước $reserved đơn';
  }

  @override
  String get storeNoBatchesTitle => 'Hôm nay chưa có món đăng bán';

  @override
  String get storeNoBatchesBody =>
      'Nếu có phần ăn dự kiến dư, quán hãy đăng vào khoảng 15–16 giờ. Xe tối nay sẽ đến lấy hàng.';

  @override
  String get storeLoadErrorTitle => 'Không tải được dữ liệu';

  @override
  String get storeLoadErrorBody => 'Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get storeReload => 'Tải lại';

  @override
  String get storeMonthSales => 'Doanh thu tháng này';

  @override
  String storeMonthSalesSub(int orders, String from) {
    return '$orders suất (từ $from)';
  }

  @override
  String get storeMonthPayout => 'Phần nhận của quán tháng này';

  @override
  String get storeMonthStatsLabel =>
      'Doanh thu và phần nhận của quán tháng này';

  @override
  String get storeTapToReload => 'Chạm để tải lại';

  @override
  String get storeRatingsLoadFailed => 'Không tải được đánh giá của khách hàng';

  @override
  String storeSharePct(String pct) {
    return 'Tỷ lệ nhận $pct%';
  }

  @override
  String storeRatingsRow(String average) {
    return 'Đánh giá của khách $average';
  }

  @override
  String storeRatingsSub(int count) {
    return '30 ngày gần đây · $count đánh giá';
  }

  @override
  String get storeRatingsNone => 'Chưa có đánh giá nào';

  @override
  String get storeBatchDetailTitle => 'Chi tiết đợt bán';

  @override
  String storeBatchPriceLine(String price, String time) {
    return '$price · Hết giờ bán $time';
  }

  @override
  String get storeStatConfirmed => 'Đã thu';

  @override
  String get storeStatEstimated => 'Dự kiến';

  @override
  String get storeStatReserved => 'Đặt trước';

  @override
  String get storeStatPickedUp => 'Đã giao';

  @override
  String get storeStatRemaining => 'Còn lại';

  @override
  String get storeStatCollection => 'Thu hàng';

  @override
  String get storeProgress => 'Tiến độ';

  @override
  String get storeStepEstimated => 'Đã đăng';

  @override
  String storeStepEstimatedDetail(int qty) {
    return 'Đăng $qty suất';
  }

  @override
  String get storeStepCollected => 'Tài xế nhận hàng';

  @override
  String storeStepCollectedPlanned(String time) {
    return 'Dự kiến $time';
  }

  @override
  String get storeStepCollectedHint =>
      'Khi tài xế đến, vui lòng cùng kiểm đếm số lượng thực tế';

  @override
  String storeStepCollectedBy(String name) {
    return 'Tài xế $name';
  }

  @override
  String get storeStepOnSale => 'Đang bán';

  @override
  String storeStepOnSaleUntil(String time) {
    return 'đến $time';
  }

  @override
  String storeStepOnSaleDetail(int count) {
    return 'Bán tại $count điểm nhận';
  }

  @override
  String get storeStepEnded => 'Đã kết thúc';

  @override
  String get storeStepEndedDetail =>
      'Phần chưa bán hết được ghi nhận quyên góp hoặc hủy bỏ';

  @override
  String get storeStopsRemaining => 'Số lượng còn theo từng điểm nhận';

  @override
  String get storeAutoUpdate => 'Tự động cập nhật';

  @override
  String storeStopRemaining(int remaining) {
    return 'Còn $remaining';
  }

  @override
  String storeStopAllocated(int allocated) {
    return '/$allocated suất';
  }

  @override
  String get storeEstimatedNote =>
      'Nếu số lượng lúc thu hàng ít hơn số đơn đặt trước, hệ thống sẽ giữ phần theo thứ tự đặt sớm nhất và tự động hoàn tiền cho các đơn còn lại.';

  @override
  String get storeBatchNotFound => 'Không tìm thấy đợt bán này';

  @override
  String storeTemperature(String celsius) {
    return '$celsius°C';
  }

  @override
  String get storeRegisterTitle => 'Đăng bán phần ăn hôm nay';

  @override
  String get storeRegisterSubtitle =>
      'Chỉ cần nhập số lượng ước tính — số thực tế sẽ được đếm khi tài xế đến lấy';

  @override
  String get storeRequired => 'Bắt buộc';

  @override
  String get storePhotoTake => 'Chụp ảnh món ăn';

  @override
  String get storePhotoRetake => 'Chụp lại';

  @override
  String get storePhotoHint =>
      'Vui lòng chụp ảnh không để lộ tên quán, logo hoặc khuôn mặt người.';

  @override
  String get storePhotoCamera => 'Chụp ảnh';

  @override
  String get storePhotoLibrary => 'Chọn từ thư viện ảnh';

  @override
  String get storePhotoRemove => 'Gỡ ảnh';

  @override
  String storeErrSummary(int count) {
    return 'Vui lòng kiểm tra thông tin đã nhập ($count mục)';
  }

  @override
  String get storePhotoCameraDenied => 'Không dùng được máy ảnh';

  @override
  String get storePhotoCameraDeniedBody =>
      'Hãy cấp quyền máy ảnh trong “Cài đặt” hoặc chọn ảnh từ thư viện. Nội dung đã nhập vẫn được giữ nguyên.';

  @override
  String get storePhotoLibraryDenied => 'Không mở được thư viện ảnh';

  @override
  String get storePhotoLibraryDeniedBody =>
      'Hãy cấp quyền truy cập ảnh trong “Cài đặt” hoặc chụp bằng máy ảnh. Nội dung đã nhập vẫn được giữ nguyên.';

  @override
  String get photoReadFailed => 'Không đọc được ảnh';

  @override
  String get photoReadFailedBody =>
      'Vui lòng thử lại hoặc chọn ảnh khác. Nội dung đã nhập vẫn được giữ nguyên.';

  @override
  String get storeQtyLabel => 'Số suất dự kiến';

  @override
  String get storeQtyUnit => 'suất';

  @override
  String get storeQtyDecrease => 'Giảm 1 suất';

  @override
  String get storeQtyIncrease => 'Tăng 1 suất';

  @override
  String get storePriceLabel => 'Giá mỗi suất (đã gồm thuế)';

  @override
  String get storePriceHint =>
      'Khi gần hết giờ bán, giá hiển thị cho khách sẽ tự động giảm dần (giảm 30–70%).';

  @override
  String get storeSellByLabel => 'Giờ kết thúc bán';

  @override
  String get storeSellByToday => 'Hôm nay';

  @override
  String get storeSellByTomorrow => 'Ngày mai';

  @override
  String get storeSellByChange => 'Đổi';

  @override
  String get storeTimeTitle => 'Giờ kết thúc bán';

  @override
  String get storeTimeHint => 'Nhập bằng số hoặc chọn từ các mốc giờ bên dưới';

  @override
  String get storeTimeDayNote =>
      'Hôm nay / Ngày mai sẽ theo lựa chọn trên màn hình đăng bán';

  @override
  String get storeTimeHour => 'Giờ';

  @override
  String get storeTimeMinute => 'Phút';

  @override
  String get storeTime24h => 'Định dạng 24 giờ (00–23 giờ / 00–59 phút)';

  @override
  String get storeTimePresets => 'Mốc giờ hay dùng';

  @override
  String get storeTimeConfirm => 'Chọn giờ này';

  @override
  String get storeTimeInvalid => 'Vui lòng nhập giờ từ 00–23 và phút từ 00–59';

  @override
  String get storeAllergenLabel => 'Chất gây dị ứng (28 loại)';

  @override
  String get storeAllergenShowAll => 'Xem tất cả (28 loại)';

  @override
  String get storeAllergenHint =>
      'Vui lòng chọn tất cả chất dị ứng có trong món ăn. Đang hiển thị 12 loại phổ biến. Nếu không có chất nào, hãy chọn “Không chứa chất gây dị ứng”.';

  @override
  String get storeNoAllergens => 'Không chứa chất gây dị ứng';

  @override
  String get storeErrAllergenRequired =>
      'Vui lòng chọn chất gây dị ứng hoặc đánh dấu vào “Không chứa chất gây dị ứng”';

  @override
  String storeAllergenSelected(int count) {
    return 'Đang chọn $count loại';
  }

  @override
  String get storeAllergenSheetNote =>
      'Các mục đã chọn vẫn được giữ trên màn hình đăng bán sau khi đóng.';

  @override
  String get storeAllergenMandatory => 'Bắt buộc ghi nhãn (8 loại)';

  @override
  String get storeAllergenRecommended => 'Khuyến khích ghi nhãn (20 loại)';

  @override
  String get storeAllergenClear => 'Bỏ chọn tất cả';

  @override
  String storeAllergenDone(int count) {
    return 'Xong ($count loại)';
  }

  @override
  String get storeAllergenLoadFailed =>
      'Không tải được danh sách chất gây dị ứng.';

  @override
  String get storeIngredientsLabel => 'Nguyên liệu chính và xuất xứ';

  @override
  String get storeIngredientAdd => '+ Thêm nguyên liệu';

  @override
  String get storeIngredientName => 'Nguyên liệu';

  @override
  String get storeIngredientOrigin => 'Xuất xứ';

  @override
  String get storeIngredientOriginHint => 'VD: Nhật Bản (Kagoshima)';

  @override
  String storeIngredientRemove(String name) {
    return 'Xóa $name';
  }

  @override
  String get storeAdd => 'Thêm';

  @override
  String get storeCancel => 'Hủy';

  @override
  String get storeReviewButton => 'Xem lại thông tin';

  @override
  String get storeConfirmTitle => 'Đăng bán với thông tin này?';

  @override
  String get storeConfirmQty => 'Số lượng';

  @override
  String storeConfirmQtyValue(int qty) {
    return '$qty suất';
  }

  @override
  String get storeConfirmAllergens => 'Chất gây dị ứng';

  @override
  String get storeConfirmIngredients => 'Nguyên liệu';

  @override
  String get storeConfirmNone => 'Không có';

  @override
  String storeConfirmIngredientsMore(String first, int more) {
    return '$first và $more nguyên liệu khác';
  }

  @override
  String get storeConfirmNote =>
      'Sau khi đăng bán, xe tối nay sẽ đến nhận hàng và khách có thể bắt đầu đặt trước.';

  @override
  String get storeConfirmPreviewTitle => 'Hiển thị phía khách hàng';

  @override
  String storeConfirmPreviewPrice(String price) {
    return 'Giá hiện tại $price';
  }

  @override
  String get storeConfirmPreviewPriceNote =>
      'Giá sẽ tiếp tục giảm khi gần hết giờ bán';

  @override
  String get storeConfirmEstimate => 'Phần nhận của quán (ước tính)';

  @override
  String storeConfirmEstimateValue(String amount) {
    return 'Tối đa $amount';
  }

  @override
  String storeConfirmEstimateNote(String pct) {
    return 'Tính khi bán hết ở mức giá hiện tại (tỷ lệ nhận $pct%). Sẽ thấp hơn nếu giá giảm hoặc còn suất chưa bán hết.';
  }

  @override
  String get storeConfirmPreviewFailed =>
      'Không tính trước được giá. Quán vẫn có thể tiếp tục đăng bán.';

  @override
  String get storeConfirmSubmit => 'Đăng bán';

  @override
  String get storeConfirmBack => 'Quay lại chỉnh sửa';

  @override
  String storeSellByValue(String day, String time) {
    return '$day $time';
  }

  @override
  String get storeDoneTitle => 'Đã đăng bán';

  @override
  String get storeDoneBody =>
      'Xe tối nay sẽ đến nhận hàng. Hệ thống sẽ thông báo khi có đơn đặt trước.';

  @override
  String get storeDoneCollection => 'Dự kiến thu hàng';

  @override
  String storeDoneCollectionValue(String time) {
    return 'Khoảng $time';
  }

  @override
  String get storeDoneRoute => 'Xe tối nay';

  @override
  String storeDoneRouteMore(String names) {
    return '$names và các điểm khác';
  }

  @override
  String get storeDoneViewBatch => 'Xem đợt bán';

  @override
  String get storeDoneHome => 'Về trang chủ';

  @override
  String get storeErrPrice => 'Vui lòng nhập giá từ 200 yên trở lên';

  @override
  String get storeErrSellByPast =>
      'Giờ kết thúc bán phải sau thời điểm hiện tại';

  @override
  String get storeErrIngredientName => 'Vui lòng nhập tên nguyên liệu';

  @override
  String get storeErrPhotoUpload =>
      'Không tải được ảnh lên. Vui lòng kiểm tra mạng rồi thử lại, hoặc gỡ ảnh để đăng bán. (Hiện vẫn chưa được đăng)';

  @override
  String get storeErrNotApproved =>
      'Quán chưa được phê duyệt nên chưa thể đăng bán.';

  @override
  String get storeErrPhotoInvalid =>
      'Không đính kèm được ảnh. Vui lòng chọn lại ảnh và thử lại.';

  @override
  String get storeErrNoTruck =>
      'Chưa có xe cho tối nay nên chưa thể đăng bán. Vui lòng liên hệ EcoMeal.';

  @override
  String get storeErrNoStops =>
      'Chưa có điểm nhận nên chưa thể đăng bán. Vui lòng liên hệ EcoMeal.';

  @override
  String get storeErrNoStopsLeft =>
      'Xe tối nay không còn điểm nhận nào sau khi qua quán nên không thể đăng bán.';

  @override
  String get storeErrTruckDeparted =>
      'Xe tối nay đã rời quán nên không thể đăng thêm.';

  @override
  String get storeErrRegisterFailed =>
      'Không thể đăng bán. Vui lòng kiểm tra kết nối mạng và thử lại.';

  @override
  String get storeErrResultUnknown =>
      'Chưa thể xác nhận kết quả đăng bán. Vui lòng bấm “Đăng bán” lần nữa. Nếu đã được đăng, hệ thống sẽ hiển thị đợt bán đó (không bao giờ bị đăng trùng hai lần). Nội dung đã nhập vẫn được giữ nguyên.';

  @override
  String get storeSettlementTitle => 'Tiền về tài khoản';

  @override
  String get storeSettlementSubtitle =>
      'Doanh thu và phần nhận của quán theo tháng';

  @override
  String storeSettlementCurrent(String month) {
    return '$month (đang tổng hợp)';
  }

  @override
  String get storeSettlementCutoff => 'Chốt tổng kết vào cuối tháng';

  @override
  String storeSettlementEstimate(String amount) {
    return 'Dự kiến nhận $amount';
  }

  @override
  String storeSettlementCurrentSub(String sales, int orders, String pct) {
    return 'Doanh thu $sales · $orders suất · tỷ lệ $pct%';
  }

  @override
  String get storeSettlementStatements => 'Bảng kê thanh toán';

  @override
  String get storeSettlementConfirmed => 'Đã chốt số tiền';

  @override
  String get storeSettlementPaid => 'Đã chuyển khoản';

  @override
  String storeSettlementRowConfirmed(String date, int orders) {
    return 'Chốt ngày $date · $orders suất';
  }

  @override
  String storeSettlementRowPaid(String date, int orders) {
    return 'Chuyển khoản $date · $orders suất';
  }

  @override
  String get storeSettlementNote =>
      'EcoMeal sẽ tổng kết và chốt số tiền vào cuối mỗi tháng. Sau khi chuyển khoản, ngày chuyển sẽ hiển thị tại đây.';

  @override
  String get storeSettlementEmptyTitle => 'Chưa có bảng kê nào';

  @override
  String get storeSettlementEmptyBody =>
      'Sau khi kết thúc tháng và EcoMeal chốt số tiền, bảng kê sẽ hiển thị tại đây.';

  @override
  String get storeNoticeTitle => 'Thông báo thanh toán';

  @override
  String storeNoticeFor(String month) {
    return 'Kỳ $month';
  }

  @override
  String storeNoticeAddressee(String name) {
    return 'Kính gửi: $name';
  }

  @override
  String storeNoticeIssued(String date) {
    return 'Phát hành: EcoMeal · $date';
  }

  @override
  String get storeNoticeOrders => 'Số suất đã bán (khách đã nhận)';

  @override
  String storeNoticeOrdersValue(int orders) {
    return '$orders suất';
  }

  @override
  String get storeNoticeSales => 'Doanh thu (đã gồm thuế)';

  @override
  String get storeNoticePayout => 'Số tiền thanh toán';

  @override
  String get storeNoticeConfirmedAt => 'Ngày chốt số tiền';

  @override
  String get storeNoticePaidAt => 'Ngày chuyển khoản';

  @override
  String get storeNoticeUnpaid => 'Chưa chuyển khoản (hiển thị sau khi chuyển)';

  @override
  String get storeNoticeNumber => 'Mã bảng kê';

  @override
  String get storeNoticeFootnote =>
      'Phần nhận của quán chỉ tính trên các đơn khách đã nhận theo tỷ lệ của từng đơn (không tính các đơn hoàn tiền hoặc quá hạn).';

  @override
  String get storeNoticePrintOnWeb => 'In / Lưu PDF trên trang web';

  @override
  String get storeRatingsTitle => 'Đánh giá của khách hàng';

  @override
  String get storeRatingsPeriod => '30 ngày gần đây';

  @override
  String storeRatingsCount(int count) {
    return '$count đánh giá';
  }

  @override
  String get storeRatingsRecent => 'Nhận xét gần đây';

  @override
  String get storeRatingsAnonymous =>
      'Tên khách hàng đánh giá sẽ không hiển thị.';

  @override
  String get storeRatingsEmptyBody =>
      'Sau khi nhận đồ, khách hàng có thể đánh giá bằng số sao và lời nhắn trong vòng 7 ngày.';

  @override
  String storeRatingStars(int rating) {
    return '★$rating';
  }

  @override
  String get storeInquiryTitle => 'Liên hệ';

  @override
  String get storeInquirySubtitle => 'Liên hệ EcoMeal';

  @override
  String get storeInquiryLabel => 'Nội dung liên hệ';

  @override
  String get storeInquiryHint =>
      'Phản hồi sẽ được gửi tới địa chỉ email đã đăng ký. Bạn có thể xem tiến độ xử lý ở danh sách bên dưới.';

  @override
  String get storeInquirySend => 'Gửi';

  @override
  String get storeInquirySent => 'Đã gửi';

  @override
  String get storeInquirySendFailed =>
      'Không gửi được. Vui lòng kiểm tra kết nối mạng và thử lại. Nội dung đã nhập vẫn được giữ nguyên.';

  @override
  String get storeInquiryEmpty => 'Vui lòng nhập nội dung liên hệ';

  @override
  String get storeInquiryHistory => 'Lịch sử liên hệ';

  @override
  String get storeInquiryStatusNew => 'Đã tiếp nhận';

  @override
  String get storeInquiryStatusInProgress => 'Đang xử lý';

  @override
  String get storeInquiryStatusDone => 'Đã giải quyết';

  @override
  String get storeInquiryStatusRejected => 'Không thể hỗ trợ';

  @override
  String get storeInquiryHistoryEmpty => 'Chưa có liên hệ nào';

  @override
  String get storeAccountDeletionMessage => 'Tôi muốn yêu cầu xóa tài khoản.';

  @override
  String get inboxTitle => 'Thông báo';

  @override
  String get inboxEmptyTitle => 'Không có thông báo nào';

  @override
  String get inboxEmptyBody =>
      'Khi có cập nhật về đặt trước, thu hàng, quyết toán..., hệ thống sẽ hiển thị tại đây và gửi thông báo cho bạn.';

  @override
  String get inboxOpen => 'Mở thông báo';

  @override
  String inboxUnread(int count) {
    return '$count chưa đọc';
  }

  @override
  String get inboxJustNow => 'Vừa xong';

  @override
  String inboxMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String inboxYesterday(String time) {
    return 'Hôm qua $time';
  }

  @override
  String get noticeRestaurantReviewedTitle => 'Kết quả xét duyệt quán';

  @override
  String get noticeRestaurantReviewedBody =>
      'Đã có kết quả xét duyệt quán. Vui lòng kiểm tra kết quả.';

  @override
  String get noticeSettlementConfirmedTitle => 'Đã chốt số tiền thanh toán';

  @override
  String get noticeSettlementConfirmedBody =>
      'Vui lòng kiểm tra số tiền tại màn hình Tiền về.';

  @override
  String get noticeSettlementPaidTitle => 'Đã hoàn tất chuyển khoản';

  @override
  String get noticeSettlementPaidBody =>
      'Vui lòng kiểm tra ngày chuyển khoản tại màn hình Tiền về.';

  @override
  String get noticeBatchCollectedTitle => 'Đã thu hàng xong';

  @override
  String get noticeBatchCollectedBody =>
      'Tài xế đã lấy đồ ăn. Vui lòng xem số lượng đã nhận trong chi tiết đợt đăng bán.';

  @override
  String get noticeBatchPhotoRemovedTitle => 'Ảnh món ăn đã bị gỡ';

  @override
  String get noticeBatchPhotoRemovedBody =>
      'EcoMeal đã gỡ ảnh món ăn. Vui lòng xem lý do tại Trang chủ.';

  @override
  String get noticeRatingReceivedTitle => 'Có đánh giá mới';

  @override
  String get noticeRatingReceivedBody =>
      'Khách hàng đã gửi đánh giá cho quán của bạn.';

  @override
  String get noticeGenericTitle => 'Thông báo';

  @override
  String get inboxEmptyBodyCustomer =>
      'Chúng tôi sẽ thông báo khi xe chở túi đồ ăn bạn đặt sắp đến hoặc khi có túi đồ ăn mới tại điểm nhận yêu thích.';

  @override
  String get noticeTruckApproachingTitle => 'Eco-Truck sắp đến';

  @override
  String noticeTruckApproachingBody(String place) {
    return 'Xe sắp đến $place. Hãy chuẩn bị sẵn mã QR trên màn hình đặt trước.';
  }

  @override
  String get noticeTruckApproachingPlace => 'điểm nhận';

  @override
  String get noticeNewBatchTitle => 'Có túi đồ ăn mới tại điểm nhận yêu thích';

  @override
  String noticeNewBatchBody(String place) {
    return 'Đã có túi đồ ăn tại $place. Hãy đặt trước kẻo hết nhé!';
  }

  @override
  String get noticeNewBatchPlace => 'điểm nhận yêu thích';

  @override
  String get noticeIssueResolvedTitle => 'Đã xử lý báo cáo của bạn';

  @override
  String get noticeIssueResolvedBody =>
      'Vui lòng xem chi tiết xử lý trong lịch sử đặt trước.';

  @override
  String get noticeRefundedTitle => 'Thông báo hoàn tiền toàn bộ';

  @override
  String get noticeRefundedBody =>
      'Rất tiếc vì không thể chuẩn bị túi đồ ăn bạn đã đặt, chúng tôi xin chân thành cáo lỗi và sẽ hoàn lại toàn bộ tiền. Thời gian tiền về thẻ tùy thuộc vào công ty phát hành thẻ.';

  @override
  String get storeSettingsTitle => 'Cài đặt';

  @override
  String storeSettingsAddress(String address, String time) {
    return '$address · Đóng cửa $time';
  }

  @override
  String get storeSettingsInfoNote =>
      'Nếu muốn thay đổi thông tin quán, vui lòng liên hệ qua mục Liên hệ.';

  @override
  String get storeSettingsPush => 'Thông báo ứng dụng';

  @override
  String get storeSettingsPushDenied =>
      'Thông báo đang bị tắt trong cài đặt thiết bị';

  @override
  String get storeSettingsRatings => 'Đánh giá của khách hàng';

  @override
  String get storeSettingsInquiry => 'Liên hệ';

  @override
  String get storeSettingsPrivacy => 'Chính sách quyền riêng tư';

  @override
  String get storeSettingsDeleteAccount => 'Yêu cầu xóa tài khoản';

  @override
  String storeSettingsVersion(String version) {
    return 'EcoMeal Store $version';
  }

  @override
  String get adminMfaTitle => 'Xác thực 2 bước';

  @override
  String get adminMfaLead =>
      'Vui lòng nhập mã 6 chữ số hiển thị trong ứng dụng xác thực.';

  @override
  String get adminMfaCodeLabel => 'Mã xác nhận';

  @override
  String get adminMfaVerify => 'Xác nhận';

  @override
  String get adminMfaOtherAccount => 'Đăng nhập bằng tài khoản khác';

  @override
  String get adminMfaSetupTitle => 'Thiết lập xác thực 2 bước';

  @override
  String get adminMfaSetupLead =>
      'Tài khoản ban vận hành bắt buộc phải bật xác thực 2 bước.';

  @override
  String get adminMfaSetupStep1 =>
      'Nếu thiết lập trên thiết bị này: bấm “Sao chép” bên dưới để lấy khóa thiết lập, rồi dán vào mục “Nhập khóa thiết lập” trong ứng dụng xác thực (như Google Authenticator). Nếu có thiết bị khác, bạn cũng có thể quét mã QR để thiết lập.';

  @override
  String get adminMfaSetupKey => 'Khóa thiết lập';

  @override
  String get adminMfaCopy => 'Sao chép';

  @override
  String get adminMfaCopied => 'Đã sao chép khóa thiết lập';

  @override
  String get adminMfaSetupStep2 =>
      'Nhập mã 6 chữ số hiển thị trong ứng dụng xác thực.';

  @override
  String get adminMfaSetupDone => 'Hoàn tất thiết lập';

  @override
  String get adminMfaInvalidCode => 'Vui lòng nhập 6 chữ số';

  @override
  String get adminMfaWrongCode =>
      'Mã không đúng. Vui lòng nhập mã mới nhất hiển thị trong ứng dụng xác thực.';

  @override
  String get adminMfaNetworkChanged =>
      'Kết nối mạng bị thay đổi giữa chừng nên không thể xác nhận. Vui lòng chỉ dùng Wi-Fi hoặc dữ liệu di động rồi thử lại.';

  @override
  String get adminMfaFailed =>
      'Không thể xác nhận. Vui lòng đợi một lát rồi thử lại.';

  @override
  String get adminTabHome => 'Trang chủ';

  @override
  String get adminTabOperations => 'Vận hành';

  @override
  String get adminTabTasks => 'Xử lý';

  @override
  String get adminTabSettings => 'Cài đặt';

  @override
  String get adminDashboardTitle => 'Tổng quan';

  @override
  String get adminTonight => 'Vận hành tối nay';

  @override
  String get adminRunning => 'Đang chạy';

  @override
  String get adminTrucksRunning => 'Xe đang chạy';

  @override
  String get adminStopsDone => 'Điểm dừng đã xong';

  @override
  String get adminReserved => 'Đặt trước';

  @override
  String get adminPickedUp => 'Đã nhận';

  @override
  String get adminNoRouteTonight => 'Tối nay chưa có lịch vận hành';

  @override
  String get adminNeedsAction => 'Việc cần xử lý';

  @override
  String get adminTaskIssues => 'Báo cáo sự cố chờ xử lý';

  @override
  String get adminTaskRestaurants => 'Quán ăn chờ xét duyệt';

  @override
  String get adminTaskLicenses => 'Giấy phép lái xe chờ duyệt';

  @override
  String get adminTaskInquiries => 'Liên hệ mới';

  @override
  String adminTaskLatest(String name, String time) {
    return 'Mới nhất: $name · $time';
  }

  @override
  String adminTaskIssueLatest(String number, String category, String time) {
    return '$number “$category” · $time';
  }

  @override
  String adminTaskLicenseLatest(String name, String time) {
    return '$name · $time';
  }

  @override
  String adminTaskInquiryTypes(int partner, int other) {
    return 'Đăng ký đối tác $partner · Khác $other';
  }

  @override
  String get adminTaskNone => 'Không có';

  @override
  String adminDateTime(String date, String time) {
    return '$date $time';
  }

  @override
  String get adminSettingsTitle => 'Cài đặt';

  @override
  String get adminMfaOn => 'Xác thực 2 bước: Bật';

  @override
  String get adminNotifications => 'Thông báo';

  @override
  String get adminPrefIssues => 'Báo cáo sự cố';

  @override
  String get adminPrefRestaurants => 'Đăng ký quán ăn';

  @override
  String get adminPrefLicenses => 'Nộp giấy phép lái xe';

  @override
  String get adminPrefInquiries => 'Liên hệ';

  @override
  String get adminPrefSaveFailed => 'Không thay đổi được cài đặt thông báo';

  @override
  String get adminPushOff => 'Thông báo trên thiết bị này đang tắt';

  @override
  String get adminPushEnable => 'Bật thông báo';

  @override
  String get adminTwoFactor => 'Xác thực 2 bước';

  @override
  String get adminTwoFactorOn => 'Đang bật';

  @override
  String get adminOpenWebAdmin => 'Mở trang quản trị web';

  @override
  String adminVersion(String version) {
    return 'EcoMeal Admin $version (TestFlight)';
  }

  @override
  String get noticeIssueReportedTitle => 'Có báo cáo sự cố mới';

  @override
  String get noticeIssueReportedBody =>
      'Khách hàng đã gửi báo cáo sự cố về đơn hàng.';

  @override
  String get noticeLicenseSubmittedTitle => 'Yêu cầu duyệt giấy phép lái xe';

  @override
  String get noticeLicenseSubmittedBody =>
      'Tài xế vừa gửi giấy phép lái xe yêu cầu xác nhận.';

  @override
  String get noticeInquiryReceivedTitle => 'Có liên hệ mới';

  @override
  String get noticeInquiryReceivedBody => 'Bạn có một yêu cầu liên hệ mới.';

  @override
  String get noticeRestaurantAppliedTitle => 'Có quán ăn mới đăng ký';

  @override
  String get noticeRestaurantAppliedBody =>
      'Một quán ăn vừa gửi đơn đăng ký tham gia.';

  @override
  String get adminTasksTitle => 'Xử lý';

  @override
  String get adminTasksSubtitle => 'Sự cố · Xét duyệt · Bằng lái · Liên hệ';

  @override
  String adminSegIssues(int count) {
    return 'Sự cố $count';
  }

  @override
  String adminSegRestaurants(int count) {
    return 'Xét duyệt $count';
  }

  @override
  String adminSegLicenses(int count) {
    return 'Bằng lái $count';
  }

  @override
  String adminSegInquiries(int count) {
    return 'Liên hệ $count';
  }

  @override
  String get adminIssueOpen => 'Chưa xử lý';

  @override
  String get adminIssueResolved => 'Đã xử lý';

  @override
  String adminIssueLine(String message, String stop, String price) {
    return '$message ($stop · $price)';
  }

  @override
  String adminIssueMeta(String time, String name) {
    return '$time · Khách hàng $name';
  }

  @override
  String adminIssueRefunded(String amount) {
    return 'Đã hoàn tiền $amount · Đã phản hồi';
  }

  @override
  String get adminIssueNoRefund => 'Không hoàn tiền · Đã phản hồi';

  @override
  String get adminIssuesEmpty => 'Không có báo cáo sự cố nào';

  @override
  String get adminIssueOrder => 'Đơn hàng';

  @override
  String adminIssueOrderValue(String price) {
    return 'Túi bất ngờ · $price (đã gồm thuế)';
  }

  @override
  String get adminIssuePickup => 'Nhận đồ';

  @override
  String get adminIssueRestaurant => 'Quán ăn';

  @override
  String get adminIssueRefundLabel => 'Số tiền hoàn';

  @override
  String get adminIssueFull => 'Toàn bộ';

  @override
  String adminIssueRefundHint(String amount) {
    return 'Tối đa $amount. Có thể chọn ¥0 (không hoàn tiền).';
  }

  @override
  String get adminIssueNoRefundHint =>
      'Không hoàn tiền (¥0). Khách hàng chỉ nhận được nội dung phản hồi.';

  @override
  String get adminIssueAnswerLabel => 'Phản hồi cho khách hàng';

  @override
  String get adminIssueSubmitRefund => 'Hoàn tiền và đánh dấu đã xử lý';

  @override
  String get adminIssueSubmitNoRefund => 'Đánh dấu đã xử lý';

  @override
  String get adminIssueSending => 'Đang gửi…';

  @override
  String get adminIssueErrorTitle => 'Không gửi được';

  @override
  String get adminIssueErrorBody =>
      'Vui lòng thử lại. Số tiền hoàn và nội dung phản hồi đã nhập vẫn được giữ nguyên. Tiền vẫn chưa được hoàn.';

  @override
  String get adminIssueUnknownTitle => 'Chưa xác nhận được kết quả xử lý';

  @override
  String get adminIssueUnknownBody =>
      'Kết nối mạng bị ngắt giữa chừng. Vui lòng bấm gửi lại. Nếu yêu cầu đã được xử lý trước đó, hệ thống sẽ báo cho bạn biết (không bao giờ bị hoàn tiền hai lần). Số tiền hoàn và phản hồi đã nhập vẫn được giữ nguyên.';

  @override
  String get adminIssueRetry => 'Gửi lại';

  @override
  String adminIssueErrAmount(String amount) {
    return 'Vui lòng nhập số tiền từ 0 đến $amount';
  }

  @override
  String get adminIssueErrAnswer =>
      'Vui lòng nhập nội dung phản hồi cho khách hàng';

  @override
  String get adminIssueErrAlready => 'Báo cáo này đã được xử lý trước đó';

  @override
  String get adminIssueResolvedToast => 'Đã đánh dấu xử lý xong';

  @override
  String get adminRestPending => 'Chờ duyệt';

  @override
  String get adminRestRejected => 'Đã từ chối';

  @override
  String get adminRestApproved => 'Đã phê duyệt';

  @override
  String get adminRestPendingBadge => 'Chờ xét duyệt';

  @override
  String adminRestApplied(String time) {
    return 'Đăng ký $time';
  }

  @override
  String get adminRestHasPl => 'Có PDF bảo hiểm PL';

  @override
  String get adminRestNoPl => 'Chưa có PDF bảo hiểm PL';

  @override
  String get adminRestEmpty => 'Không có quán ăn nào';

  @override
  String get adminRestName => 'Tên quán';

  @override
  String get adminRestAddress => 'Địa chỉ';

  @override
  String get adminRestContact => 'Liên hệ';

  @override
  String get adminRestClosing => 'Giờ đóng cửa';

  @override
  String get adminRestApplicant => 'Người đăng ký';

  @override
  String get adminRestPlDoc => 'Giấy chứng nhận bảo hiểm PL';

  @override
  String get adminRestPlOpen => 'Mở giấy chứng nhận (PDF)';

  @override
  String get adminRestPlFailed => 'Không mở được giấy chứng nhận';

  @override
  String get adminRestReject => 'Từ chối';

  @override
  String get adminRestApprove => 'Phê duyệt';

  @override
  String get adminRestRejectTitle => 'Lý do từ chối';

  @override
  String get adminRestRejectNote =>
      'Lý do sẽ được gửi tới quán qua email và ứng dụng (bắt buộc · tối đa 500 ký tự).';

  @override
  String get adminRestReasonPl =>
      'Giấy chứng nhận bảo hiểm PL bị mờ hoặc đã hết hạn';

  @override
  String get adminRestReasonContact =>
      'Không xác minh được địa chỉ hoặc thông tin liên hệ';

  @override
  String get adminRestReasonOther => 'Khác';

  @override
  String get adminRestRejectSend => 'Gửi thông báo từ chối';

  @override
  String get adminRestErrReason => 'Vui lòng nhập lý do (tối đa 500 ký tự)';

  @override
  String adminRestDecided(String name, String decision) {
    return '$name: $decision';
  }

  @override
  String get adminRestNotifyFailed =>
      'Đã lưu kết quả xét duyệt nhưng chưa gửi được email thông báo. Vui lòng gửi lại từ trang quản trị web.';

  @override
  String get adminRestRejectionReason => 'Lý do từ chối';

  @override
  String adminLicSubmitted(String time) {
    return 'Bằng lái · Nộp $time';
  }

  @override
  String get adminLicEmpty => 'Không có giấy phép lái xe nào chờ duyệt';

  @override
  String get adminLicImageFailed => 'Không tải được hình ảnh';

  @override
  String get adminLicZoom => 'Phóng to';

  @override
  String get adminLicTruck => 'Xe dự kiến phụ trách';

  @override
  String get adminLicNoTruck => 'Không có';

  @override
  String get adminLicExpiry => 'Ngày hết hạn (xem trên ảnh để nhập)';

  @override
  String get adminLicExpiryPick => 'Chọn ngày';

  @override
  String get adminLicVerifyNote =>
      'Sau khi xác nhận, tài xế có thể được xếp vào ca chạy.';

  @override
  String get adminLicReject => 'Yêu cầu nộp lại';

  @override
  String get adminLicVerify => 'Đánh dấu đã xác nhận';

  @override
  String get adminLicRejectTitle => 'Lý do yêu cầu nộp lại';

  @override
  String get adminLicErrExpiry =>
      'Vui lòng chọn ngày hết hạn (từ hôm nay trở đi)';

  @override
  String adminLicDone(String name) {
    return 'Đã xác nhận bằng lái của $name';
  }

  @override
  String get adminInqNew => 'Mới';

  @override
  String get adminInqInProgress => 'Đang xử lý';

  @override
  String get adminInqDone => 'Hoàn tất';

  @override
  String get adminInqTypePartner => 'Đăng ký đối tác';

  @override
  String get adminInqTypeDriver => 'Đăng ký làm tài xế';

  @override
  String get adminInqTypeContact => 'Liên hệ chung';

  @override
  String get adminInqStatusNew => 'Mới';

  @override
  String get adminInqStatusInProgress => 'Đang xử lý';

  @override
  String get adminInqStatusDone => 'Đã xử lý';

  @override
  String get adminInqStatusRejected => 'Từ chối tiếp nhận';

  @override
  String get adminInqEmpty => 'Không có liên hệ nào';

  @override
  String get adminInqInviteOnWeb =>
      'Việc cấp tài khoản (gửi lời mời) được thực hiện trên trang quản trị web.';

  @override
  String get adminInqStatusLabel => 'Trạng thái';

  @override
  String get adminInqNoteLabel => 'Ghi chú vận hành (nội bộ)';

  @override
  String get adminInqSave => 'Lưu';

  @override
  String get adminInqSaved => 'Đã lưu';

  @override
  String get adminInqRetrySave => 'Lưu lại';

  @override
  String get adminInqErrorTitle => 'Không lưu được';

  @override
  String get adminInqErrorBody =>
      'Vui lòng kiểm tra kết nối mạng và thử lại. Trạng thái và ghi chú đã nhập vẫn được giữ nguyên.';

  @override
  String get adminLicRetryVerify => 'Thử xác nhận lại';

  @override
  String get adminLicErrorBody =>
      'Vui lòng kiểm tra kết nối mạng rồi thử lại. Hạn dùng vừa nhập vẫn được giữ nguyên.';

  @override
  String get adminRestRetryApprove => 'Thử duyệt lại';

  @override
  String get adminRestRetryReject => 'Gửi lại thông báo từ chối';

  @override
  String get adminRestErrorBody =>
      'Vui lòng kiểm tra kết nối mạng rồi thử lại. Kết quả xét duyệt chưa được lưu.';

  @override
  String get adminRestRejectErrorBody =>
      'Vui lòng kiểm tra kết nối mạng rồi thử lại. Thao tác từ chối chưa được lưu, bạn có thể gửi lại với lý do đã chọn.';

  @override
  String get adminOpsTitle => 'Giám sát vận hành';

  @override
  String adminOpsSubtitle(String date, int count) {
    return '$date · $count xe';
  }

  @override
  String adminOpsStale(String time) {
    return 'Chưa cập nhật được · tính đến $time';
  }

  @override
  String adminOpsUpdatedAt(String time) {
    return 'Cập nhật lúc $time (mỗi 20 giây)';
  }

  @override
  String get adminOpsTrucks => 'Xe chạy tối nay';

  @override
  String get adminPickIssue => 'Chọn báo cáo sự cố';

  @override
  String get adminPickRestaurant => 'Chọn quán ăn';

  @override
  String get adminPickLicense => 'Chọn bằng lái xe';

  @override
  String get adminPickInquiry => 'Chọn yêu cầu liên hệ';

  @override
  String get adminPickDriverReport => 'Chọn tin báo của tài xế để xử lý';

  @override
  String get adminPickBody =>
      'Chọn mục từ danh sách bên trái để xem chi tiết tại đây.';

  @override
  String adminOpsShowing(int count) {
    return 'Đang hiển thị $count xe';
  }

  @override
  String get adminOpsRunning => 'Đang chạy';

  @override
  String get adminOpsWaiting => 'Đang chờ';

  @override
  String get adminOpsDone => 'Hoàn tất';

  @override
  String adminOpsNext(String driver, String stop) {
    return '$driver · Điểm tiếp: $stop';
  }

  @override
  String get adminGpsJustNow => 'Vị trí trong vòng 1 phút';

  @override
  String adminGpsMinutes(int minutes) {
    return 'Vị trí $minutes phút trước';
  }

  @override
  String adminGpsStale(int minutes) {
    return 'Vị trí $minutes phút trước · đã ngừng cập nhật';
  }

  @override
  String get adminGpsNone => 'Chưa nhận được vị trí';

  @override
  String get adminOpsEta => 'Dự kiến đến';

  @override
  String adminOpsReserved(int count) {
    return 'Đặt trước $count đơn';
  }

  @override
  String get adminOpsNoDriver => 'Chưa xếp tài xế';

  @override
  String get adminOpsMapUnavailable =>
      'Không thể hiển thị bản đồ (chưa hoàn tất thiết lập bản đồ)';

  @override
  String get noticeReservationReceivedTitle => 'Có đơn đặt trước mới';

  @override
  String noticeReservationReceivedBody(String time, int count, int total) {
    return 'Đợt đăng bán hạn đến $time vừa có thêm $count đơn đặt trước. Tổng cộng $total đơn.';
  }

  @override
  String get noticeReservationReceivedFallback =>
      'Mở app để kiểm tra số lượng đơn đặt trước.';

  @override
  String get storeSettingsContract => 'Hợp đồng đối tác';

  @override
  String get storeContractBody =>
      'Điều khoản dành cho quán (tỷ lệ chia sẻ doanh thu, thanh toán, chuyển khoản, xử lý thực phẩm...) được quy định trong hợp đồng đối tác đã ký với EcoMeal. Điều khoản sử dụng dành cho khách hàng không áp dụng cho quán. Nếu cần kiểm tra hoặc muốn điều chỉnh hợp đồng, vui lòng liên hệ qua mục Liên hệ.';

  @override
  String get storeContractInquiry => 'Liên hệ';

  @override
  String adminRestApproveConfirmTitle(String name) {
    return 'Phê duyệt $name?';
  }

  @override
  String get adminRestApproveConfirmBody =>
      'Sau khi phê duyệt, quán có thể đăng bán đồ ăn dư trên app dành cho quán và người phụ trách sẽ nhận được email thông báo.';

  @override
  String get adminRestMembers => 'Người phụ trách';

  @override
  String get adminRestOwner => 'Chủ quán';

  @override
  String get adminRestStaff => 'Nhân viên';

  @override
  String get adminRestNoMembers => 'Chưa có người phụ trách nào được đăng ký';

  @override
  String get adminRestMonth => 'Doanh thu tháng này';

  @override
  String get adminRestSales => 'Doanh thu';

  @override
  String get adminRestPayout => 'Tiền trả quán';

  @override
  String get adminRestSold => 'Số suất đã bán';

  @override
  String get adminRestShare => 'Tỷ lệ trả quán';

  @override
  String adminRestSharePct(String pct) {
    return '$pct%';
  }

  @override
  String get adminRestRatings => 'Đánh giá từ khách hàng (30 ngày gần nhất)';

  @override
  String adminRestRatingsValue(String average, int count) {
    return '★$average ($count đánh giá)';
  }

  @override
  String get adminRestNoRatings => 'Chưa có đánh giá nào';

  @override
  String get adminRestBatches => 'Đợt đăng bán gần đây';

  @override
  String get adminRestNoBatches => 'Chưa có đợt đăng bán nào';

  @override
  String adminRestBatchLine(int qty, String price) {
    return '$qty suất × $price';
  }

  @override
  String get adminRestBatchConfirmed => 'Đã chốt';

  @override
  String get adminRestBatchEstimated => 'Ước tính';

  @override
  String get adminRestSettlements => 'Quyết toán';

  @override
  String get adminRestNoSettlements => 'Chưa có đợt quyết toán nào được chốt';

  @override
  String get adminRestSettlementConfirmed => 'Đã chốt';

  @override
  String adminLicVerifyConfirmTitle(String name) {
    return 'Xác nhận bằng lái xe của $name?';
  }

  @override
  String adminLicVerifyConfirmBody(String date) {
    return 'Hệ thống sẽ lưu ngày hết hạn $date và tài xế này có thể được xếp vào ca chạy.';
  }

  @override
  String adminIssueConfirmRefundTitle(String amount) {
    return 'Hoàn tiền $amount?';
  }

  @override
  String adminIssueConfirmRefundBody(
    String order,
    String restaurant,
    String amount,
  ) {
    return 'Hệ thống sẽ hoàn $amount về phương thức thanh toán của khách cho đơn $order ($restaurant) và gửi phản hồi. Thao tác hoàn tiền không thể thu hồi.';
  }

  @override
  String get adminIssueConfirmNoRefundTitle =>
      'Đánh dấu đã xử lý mà không hoàn tiền?';

  @override
  String adminIssueConfirmNoRefundBody(String order, String restaurant) {
    return 'Hệ thống sẽ chỉ gửi phản hồi cho khách của đơn $order ($restaurant). Bạn sẽ không thể hoàn tiền sau thao tác này.';
  }

  @override
  String get adminMfaLostDevice =>
      'Nếu bị mất điện thoại hoặc đã xóa ứng dụng xác thực, bạn sẽ không thể đăng nhập. Vui lòng liên hệ một quản trị viên khác của EcoMeal để yêu cầu hủy xác thực 2 bước.';

  @override
  String get adminIssueConfirmRefundAction => 'Hoàn tiền';

  @override
  String get activeOrderOpen => 'Xem hướng dẫn nhận đồ';

  @override
  String get activeOrderTitle => 'Hướng dẫn nhận đồ';

  @override
  String get activeOrderPlace => 'Điểm nhận';

  @override
  String get activeOrderTime => 'Giờ nhận';

  @override
  String activeOrderBefore(String time, int minutes) {
    return 'Dự kiến đến lúc $time · còn $minutes phút';
  }

  @override
  String activeOrderWindow(String end) {
    return 'Xe đang đỗ tại điểm nhận (đến $end)';
  }

  @override
  String get activeOrderOver =>
      'Xe đã rời khỏi điểm nhận này. Nếu chưa kịp nhận đồ, bạn vui lòng báo qua mục “Báo sự cố” trong lịch sử đặt trước hoặc liên hệ với chúng tôi.';

  @override
  String get activeOrderFindTitle => 'Cách tìm xe';

  @override
  String get activeOrderFindBody =>
      'Hãy đưa mã QR này tại xe Eco-Truck đang đỗ ở điểm nhận (thân xe có in logo EcoMeal). Nếu không quét được mã, bạn hãy đọc mã xác nhận ở trên cho tài xế. Bạn cũng có thể theo dõi vị trí xe và giờ đến dự kiến trên bản đồ Trang chủ.';

  @override
  String get activeOrderPickedUp => 'Đã nhận đồ';

  @override
  String get activeOrderEndedStatus => 'Không thể nhận đơn đặt trước này';

  @override
  String get activeOrderEndedCancelledTitle => 'Đơn đặt trước này đã bị hủy';

  @override
  String get activeOrderEndedCancelledBody =>
      'Vui lòng kiểm tra lịch sử đặt trước để xem thông tin hoàn tiền.';

  @override
  String get activeOrderEndedExpiredTitle => 'Đơn đặt trước này đã hết hạn';

  @override
  String get activeOrderEndedExpiredBody =>
      'Do đồ ăn không được nhận trước giờ xe rời điểm, đơn này sẽ không được hoàn tiền. Nếu có lý do khiến bạn không thể đến nhận, vui lòng liên hệ qua mục “Báo sự cố” trong lịch sử đặt trước.';

  @override
  String get activeOrderEndedBack => 'Xem lịch sử đặt trước';

  @override
  String get pickupCompleteTitle => 'Nhận đồ hoàn tất';

  @override
  String get pickupCompleteBody => 'Cảm ơn bạn đã đồng hành cùng EcoMeal!';

  @override
  String get leftoverAutoRecordNote =>
      'Số suất không đem tặng sẽ tự động được ghi nhận là “bán thừa (tiêu hủy)” sau 1 giờ kể từ khi xe rời điểm bán cuối cùng. Nếu có tặng, vui lòng ghi nhận trước thời điểm đó.';

  @override
  String get driverReportTitle => 'Báo cho ban vận hành';

  @override
  String get driverReportLead =>
      'Khi bạn gửi tin, ban vận hành sẽ nhận thông báo và liên hệ với các khách hàng có đơn bị ảnh hưởng. Trường hợp khẩn cấp liên quan đến an toàn, trước tiên hãy tấp vào nơi an toàn đỗ xe.';

  @override
  String get driverReportDelay => 'Có thể đến trễ (điểm dừng tiếp theo)';

  @override
  String get driverReportVehicle => 'Sự cố xe (hỏng xe · va chạm)';

  @override
  String get driverReportFood =>
      'Vấn đề món ăn · nhiệt độ (từ chối nhận món...)';

  @override
  String get driverReportOther => 'Khác';

  @override
  String driverReportMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get driverReportMinutesMax => 'Trên 30 phút';

  @override
  String get driverReportMessageHint =>
      'Mô tả ngắn tình hình (không bắt buộc; bắt buộc nếu chọn “Khác”)';

  @override
  String get driverReportSend => 'Gửi cho ban vận hành';

  @override
  String get driverReportSent =>
      'Đã gửi cho ban vận hành. Hãy tiếp tục lái xe an toàn trong khi chờ phản hồi.';

  @override
  String get driverReportSelect => 'Chọn loại sự cố cần báo';

  @override
  String get driverReportNeedMessage =>
      'Nếu chọn “Khác”, vui lòng nhập mô tả ngắn về tình hình';

  @override
  String get driverReportNoRoute =>
      'Không thể gửi vì tối nay bạn không có tuyến chạy';

  @override
  String get driverReportDuplicate =>
      'Bạn vừa gửi tin báo cùng loại. Vui lòng đợi khoảng 1 phút rồi gửi lại.';

  @override
  String get driverReportError =>
      'Chưa gửi được tin. Vui lòng thử lại ở nơi có sóng tốt hơn.';

  @override
  String get adminTaskDriverReports => 'Tin báo vận hành chờ xử lý';

  @override
  String adminTaskDriverReportLatest(
    String plate,
    String category,
    String time,
  ) {
    return '$plate “$category” · $time';
  }

  @override
  String adminSegDriverReports(int count) {
    return 'Tài xế báo $count';
  }

  @override
  String get adminDriverReportsEmpty => 'Không có tin báo nào từ tài xế';

  @override
  String adminDriverReportMeta(String time, String driver, String stop) {
    return '$time · $driver · Điểm dừng tiếp: $stop';
  }

  @override
  String get adminDriverReportNoStop => 'Không có (đã xong tuyến)';

  @override
  String get adminDriverReportResolveTitle => 'Đánh dấu đã xử lý';

  @override
  String get adminDriverReportResolveNote =>
      'Ghi lại nội dung đã xử lý (ví dụ: đã liên hệ khách hàng). Hệ thống sẽ không tự động gửi thông báo cho khách.';

  @override
  String get adminDriverReportResolveSend => 'Đánh dấu đã xử lý';

  @override
  String get adminDriverReportDone => 'Đã đánh dấu đã xử lý';

  @override
  String get adminDriverReportAlready =>
      'Một nhân sự khác trong ban vận hành đã xử lý tin này';

  @override
  String get adminDriverReportError =>
      'Chưa thể đánh dấu đã xử lý. Vui lòng thử lại.';

  @override
  String get noticeDriverReportedTitle => 'Tin báo từ tài xế';

  @override
  String get noticeDriverReportedBody =>
      'Tài xế đang chạy tuyến vừa báo bị trễ hoặc gặp sự cố.';

  @override
  String get driverReportShort => 'Báo vận hành';

  @override
  String get driverProgressTitle => 'Tiến độ tối nay';

  @override
  String driverProgressCount(int done, int total) {
    return 'Hoàn tất $done/$total điểm';
  }

  @override
  String driverProgressPickup(int done, int total) {
    return 'Thu hàng $done/$total';
  }

  @override
  String driverProgressSales(int done, int total) {
    return 'Bán hàng $done/$total';
  }

  @override
  String get nextTaskLabel => 'Việc tiếp theo';

  @override
  String stepBadgePickup(int number) {
    return 'Điểm $number · Thu hàng';
  }

  @override
  String stepBadgeSales(int number) {
    return 'Điểm $number · Bán hàng';
  }

  @override
  String nextTaskPickupTitle(String name) {
    return 'Nhận đồ ăn tại $name';
  }

  @override
  String nextTaskSalesTitle(String name) {
    return 'Giao đồ cho khách tại $name';
  }

  @override
  String get arriveByLabel => 'Dự kiến đến';

  @override
  String get timeLeftLabel => 'Còn lại';

  @override
  String get pickupAmountLabel => 'Số lượng nhận';

  @override
  String get handoutAmountLabel => 'Số lượng giao';

  @override
  String approxMeals(int qty) {
    return 'Khoảng $qty suất';
  }

  @override
  String get nothingToPickUp => 'Không còn món nào cần nhận tại đây';

  @override
  String nextTaskPickupDetail(int count, String time) {
    return 'Cần nhận $count món · Quán dừng bán lúc $time';
  }

  @override
  String nextTaskSalesDetail(int count) {
    return 'Quét mã QR nhận đồ để giao $count đơn đặt trước';
  }

  @override
  String get navigateButton => 'Chỉ đường';

  @override
  String get arrivedPickupButton => 'Đã đến · Nhận hàng';

  @override
  String get arrivedSalesButton => 'Đã đến · Giao đồ';

  @override
  String get navigationFailed => 'Không thể mở ứng dụng bản đồ';

  @override
  String get allStopsDoneTitle => 'Đã đi qua tất cả các điểm dừng';

  @override
  String get allStopsDoneBody =>
      'Nếu còn đồ chưa bán hết, bạn có thể ghi nhận tặng từ thiện ở tab “Kết thúc”.';

  @override
  String get routePhasePickup => '1. Nhận món tại quán (Thu hàng)';

  @override
  String get routePhaseSales => '2. Giao cho khách (Bán hàng)';

  @override
  String placesCount(int count) {
    return '$count điểm';
  }

  @override
  String stopPickupPending(int qty) {
    return 'Nhận khoảng $qty suất';
  }

  @override
  String stopPickupDone(int qty) {
    return 'Đã nhận · $qty suất';
  }

  @override
  String stopSalesLoad(int reserved, int total) {
    return 'Đặt trước $reserved đơn · Tổng $total suất';
  }

  @override
  String pickupStopSubtitle(int index, int total, String time) {
    return 'Thu hàng $index/$total · Dự kiến đến lúc $time';
  }

  @override
  String get addressLabel => 'Địa chỉ';

  @override
  String get copyAddressButton => 'Sao chép địa chỉ';

  @override
  String get addressCopied => 'Đã sao chép địa chỉ';

  @override
  String foodsToPickUp(int count) {
    return 'Món cần nhận ($count món)';
  }

  @override
  String get shopPlannedQty => '(quán dự kiến)';

  @override
  String shopSellByLabel(String time) {
    return 'Quán dừng bán lúc $time';
  }

  @override
  String get pickUpThisFood => 'Nhận món này';

  @override
  String pickedUpChip(int qty) {
    return 'Đã nhận · $qty suất';
  }

  @override
  String get pickupStepsTitle => 'Quy trình nhận hàng';

  @override
  String get pickupStep1 =>
      'Đếm số suất thực tế (khác với số quán dự kiến cũng không sao, hãy nhập số thực nhận)';

  @override
  String get pickupStep2 =>
      'Đo nhiệt độ tâm (đồ bảo quản lạnh phải từ 10°C trở xuống)';

  @override
  String get pickupStep3 =>
      'Bấm “Xác nhận nhận hàng” để hệ thống tự động phân bổ điểm giao và số lượng';

  @override
  String pickupDoneTitle(int qty) {
    return 'Đã xếp $qty suất lên xe';
  }

  @override
  String pickupDoneSubtitle(String name, String temp) {
    return '$name · Nhiệt độ tâm: $temp°C';
  }

  @override
  String get securedReservations => 'Đơn đặt trước được giữ';

  @override
  String get refundedReservations => 'Đơn đặt trước đã hoàn tiền';

  @override
  String get dropsTitle => 'Điểm giao món này';

  @override
  String dropSubtitle(String time, int count) {
    return '$time · trong đó $count đơn đặt trước';
  }

  @override
  String get allPickupsDoneHint =>
      'Đã hoàn tất thu hàng. Hãy kiểm tra đồ ăn vẫn được giữ lạnh rồi xuất phát.';

  @override
  String get morePickupsHint => 'Di chuyển đến quán tiếp theo.';

  @override
  String get moreFoodHereHint => 'Quán này vẫn còn món cần nhận.';

  @override
  String get backToHome => 'Về Trang chủ';

  @override
  String get handoutHereTitle => 'Món cần giao tại điểm này';

  @override
  String totalMeals(int qty) {
    return 'Tổng cộng $qty suất';
  }

  @override
  String get reservedCustomers => 'Khách đã đặt trước';

  @override
  String get walkupSellable => 'Có thể bán trực tiếp';

  @override
  String get scanQrToHand => 'Quét mã QR rồi giao đồ';

  @override
  String get registerOnSpot => 'Ghi nhận bán tại chỗ';

  @override
  String get perFoodLabel => 'Số lượng theo từng món';

  @override
  String batchCapacityRow(int capacity, int remaining) {
    return '$capacity suất (còn $remaining suất bán trực tiếp)';
  }

  @override
  String get handoutStepsTitle => 'Quy trình tại điểm dừng';

  @override
  String get handoutStep1 =>
      'Khách đã đặt trước: quét mã QR nhận đồ (nếu không quét được thì nhập mã 4 ký tự)';

  @override
  String get handoutStep2 =>
      'Khách chưa đặt trước: ghi nhận từng suất ở tab “Bán tại chỗ”';

  @override
  String get handoutStep3 =>
      'Xong việc: bấm “Rời điểm dừng” → di chuyển đến điểm tiếp theo';

  @override
  String get walkupUnknownTitle =>
      'Chưa thể xác nhận lượt bán đã được ghi nhận hay chưa';

  @override
  String get walkupUnknownBody =>
      'Kết nối mạng bị gián đoạn. Bạn bấm “Ghi nhận bán” lần nữa để gửi lại lượt bán này (yên tâm không bị ghi trùng hai lần). Nếu hệ thống đã lưu trước đó, màn hình sẽ thông báo “Lần bán vừa rồi đã được ghi nhận”.';

  @override
  String walkupReplayedToast(int price) {
    return 'Lượt bán vừa rồi đã được ghi nhận (¥$price)';
  }

  @override
  String get donationUnknownTitle =>
      'Chưa thể xác nhận lượt tặng đã được ghi nhận hay chưa';

  @override
  String get donationUnknownBody =>
      'Kết nối mạng bị gián đoạn. Thông tin bạn nhập vẫn được giữ nguyên. Bấm “Ghi nhận tặng” lần nữa cũng không bị ghi trùng hai lần. Nếu hệ thống đã lưu trước đó, màn hình sẽ thông báo “Lượt tặng này đã được ghi nhận”.';

  @override
  String donationReplayed(int remaining) {
    return 'Lượt tặng này đã được ghi nhận (món này còn $remaining suất)';
  }

  @override
  String donationBatchOptionEmpty(String name) {
    return '$name (đã hết)';
  }

  @override
  String donationQtyOverRemaining(int remaining) {
    return 'Chỉ còn $remaining suất. Vui lòng nhập tối đa $remaining suất.';
  }

  @override
  String get gpsPermissionTitle => 'Chưa cấp quyền vị trí';

  @override
  String get gpsPermissionBody =>
      'Khách hàng và ban vận hành sẽ không thấy được vị trí xe. Vui lòng cấp quyền vị trí trong Cài đặt (chỉ cần chọn “Khi dùng ứng dụng”).';

  @override
  String get gpsServiceOffTitle => 'Dịch vụ định vị trên thiết bị đang tắt';

  @override
  String get gpsServiceOffBody =>
      'Vui lòng bật Cài đặt → Quyền riêng tư & Bảo mật → Dịch vụ định vị.';

  @override
  String get gpsNotSentTitle => 'Chưa gửi được vị trí xe';

  @override
  String get gpsNotSentBody =>
      'Khi có mạng trở lại, ứng dụng sẽ tự động cập nhật. Đang hiển thị vị trí gửi gần nhất.';

  @override
  String get cameraUnavailableTitle => 'Không thể sử dụng camera';

  @override
  String get cameraUnavailableBody =>
      'Vui lòng cấp quyền camera trong Cài đặt. Nếu không thể quét mã, bạn vẫn có thể giao đồ bằng mã 4 ký tự trên màn hình của khách.';

  @override
  String get enterCodeManually => 'Nhập mã thủ công';

  @override
  String get routeMapOpen => 'Mở rộng bản đồ';

  @override
  String get routeMapTitle => 'Bản đồ tuyến chạy';

  @override
  String routeMapSubtitle(int total, int next) {
    return '$total điểm · Đang đến điểm thứ $next';
  }

  @override
  String routeMapAllDone(int total) {
    return '$total điểm · Đã hoàn tất';
  }

  @override
  String get routeMapFitAll => 'Toàn tuyến';

  @override
  String get routeMapMyLocation => 'Vị trí hiện tại';

  @override
  String get routeMapLegend =>
      'Đường nét đứt thể hiện thứ tự dừng xe (không phải đường đi thực tế)';

  @override
  String get routeMapSelectedStop => 'Điểm đã chọn';

  @override
  String get routeMapOpenStop => 'Mở điểm này';

  @override
  String get routeMapListHint =>
      'Vuốt lên để xem toàn bộ điểm dừng (1. Nhận tại quán · 2. Giao cho khách)';

  @override
  String get routeMapRoadLoading => 'Đang tải lộ trình…';

  @override
  String routeMapRoadLegend(int count, int minutes, String km) {
    return 'Lộ trình đường bộ · Còn $count điểm, khoảng $minutes phút (${km}km)';
  }

  @override
  String get routeMapRoadFailed =>
      'Chưa tải được lộ trình đường đi (đường nét đứt chỉ thể hiện thứ tự các điểm)';

  @override
  String get routeMapRoadRetry => 'Thử lại';

  @override
  String get roadTimeLeftLabel => 'Đường bộ còn';
}
