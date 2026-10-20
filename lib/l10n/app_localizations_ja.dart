// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get loginTab => 'ログイン';

  @override
  String get signupTab => '新規登録';

  @override
  String get emailLabel => 'メールアドレス';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get errorEmailRequired => 'メールアドレスを入力してください';

  @override
  String get errorPasswordRequired => 'パスワードを入力してください';

  @override
  String get errorEmailNotConfirmed => 'メールアドレスの確認が完了していません。受信ボックスをご確認ください';

  @override
  String get errorInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません';

  @override
  String get loginButton => 'ログインする';

  @override
  String get displayNameLabel => '表示名';

  @override
  String get errorDisplayNameRequired => '表示名を入力してください';

  @override
  String get errorPasswordMin8 => 'パスワードは8文字以上で入力してください';

  @override
  String get signupButton => '登録する';

  @override
  String get errorEmailAlreadyRegistered => 'このメールアドレスは既に登録されています';

  @override
  String get errorSignupFailed => '登録に失敗しました。入力内容をご確認のうえ、再度お試しください';

  @override
  String get errorRateLimited => 'しばらく時間をおいてから再度お試しください';

  @override
  String get signupConfirmationTitle => '確認メールを送信しました';

  @override
  String signupConfirmationBody(String email) {
    return '$email宛に確認メールを送信しました。メール内のリンクをタップして登録を完了してください。';
  }

  @override
  String get webOnlyAccountTitle => 'このアカウントはアプリではご利用いただけません';

  @override
  String get webOnlyAccountBody =>
      '飲食店・EcoMeal運営のアカウントは、パソコンのWeb管理画面からご利用ください。';

  @override
  String get openWebAdmin => 'Web管理画面を開く';

  @override
  String get errorOpenWebAdmin => 'Web管理画面を開けませんでした';

  @override
  String get loadErrorTitle => 'アカウントの情報を読み込めませんでした';

  @override
  String get loadErrorBody => '通信状態を確認して、もう一度お試しください。';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'ドライバー';

  @override
  String get driverLoginLead => 'EcoMeal から発行されたドライバー用アカウントでログインしてください。';

  @override
  String get driverAccountIssuedNote =>
      'アカウントは運営から発行されます。招待メールのリンクからパスワードを設定して、ログインしてください。';

  @override
  String get driverOnlyAppTitle => 'ドライバー専用アプリです';

  @override
  String get driverOnlyAppBody =>
      'お客様は「EcoMeal」アプリ、飲食店・EcoMeal運営の方はパソコンのWeb管理画面をご利用ください。';

  @override
  String get driverAccountTitle => 'ドライバー用アカウントです';

  @override
  String get driverAccountBody =>
      'ドライバーの方は「EcoMeal Driver」アプリでログインしてください。このアプリはお客様専用です。';

  @override
  String get storeAppTitle => 'EcoMeal Store';

  @override
  String get adminAppTitle => 'EcoMeal Admin';

  @override
  String get storeBadge => '店舗';

  @override
  String get storeLoginLead => 'EcoMeal から発行された店舗用アカウントでログインしてください。';

  @override
  String get storeLoginNote =>
      'お店の新規登録は Web（ecomeal-pi.vercel.app）からお申し込みいただけます。';

  @override
  String get adminBadge => '運営';

  @override
  String get adminLoginLead => '運営アカウントでログインしてください。この後、2段階認証のコードを入力します。';

  @override
  String get storeOnlyAppTitle => '店舗専用アプリです';

  @override
  String get storeOnlyAppBody =>
      'お客様は「EcoMeal」、ドライバーの方は「EcoMeal Driver」アプリをご利用ください。';

  @override
  String get adminOnlyAppTitle => '運営専用アプリです';

  @override
  String get adminOnlyAppBody =>
      'お客様は「EcoMeal」、飲食店の方は「EcoMeal Store」、ドライバーの方は「EcoMeal Driver」アプリをご利用ください。';

  @override
  String get driverSuspendedTitle => '稼働が停止されています';

  @override
  String get driverSuspendedBody =>
      'このアカウントは現在シフトに入れない状態です。理由や再開の手続きについては、EcoMeal 運営までお問い合わせください。';

  @override
  String get backToLogin => 'ログイン画面に戻る';

  @override
  String get errorNetwork => '通信に失敗しました。接続を確認して再度お試しください';

  @override
  String get signOutButton => 'ログアウト';

  @override
  String get errorSignOutFailed => 'ログアウトに失敗しました。もう一度お試しください';

  @override
  String get onboardingHeadline => '今夜の食事を、未来につなぐ。';

  @override
  String get onboardingLead => '街のレストランで余った、まだおいしい料理を、Eco-Truckがあなたの近くへ届けます。';

  @override
  String get onboardingImpact => '食品ロスをおいしく削減';

  @override
  String get loginLead => 'メールアドレスとパスワードでログインしましょう。';

  @override
  String get signupLead => 'メールアドレスとパスワードでアカウントを作成しましょう。';

  @override
  String get emailHint => 'example@example.jp';

  @override
  String get passwordHint => 'パスワードを入力';

  @override
  String get passwordMin8Helper => '8文字以上で入力してください。';

  @override
  String get showPassword => '表示';

  @override
  String get hidePassword => '非表示';

  @override
  String get displayNameHint => '表示名を入力';

  @override
  String get noAccountPrompt => 'まだアカウントをお持ちでない方は';

  @override
  String get haveAccountPrompt => 'すでにアカウントをお持ちの方は';

  @override
  String get signupSpamFolderNote => 'メールが届かない場合は、迷惑メールフォルダをご確認ください。';

  @override
  String get forgotPasswordPrompt => 'パスワードを忘れた方は';

  @override
  String get forgotPasswordAction => 'こちら';

  @override
  String get resetPasswordTitle => 'パスワード再設定';

  @override
  String get resetPasswordRequestLead => '登録したメールアドレスに、パスワード再設定用の確認コードを送信します。';

  @override
  String get resetPasswordSendCodeButton => '確認コードを送信する';

  @override
  String resetPasswordCodeLead(String email) {
    return '$email が登録済みであれば、確認コードを送信しました。メールに記載のコードと、新しいパスワードを入力してください。';
  }

  @override
  String get verificationCodeLabel => '確認コード';

  @override
  String get verificationCodeHint => 'メールに記載のコード';

  @override
  String get newPasswordLabel => '新しいパスワード';

  @override
  String get newPasswordHint => '新しいパスワードを入力';

  @override
  String get resetPasswordButton => 'パスワードを再設定する';

  @override
  String get resendCodePrompt => 'コードが届かない場合は';

  @override
  String get resendCodeAction => '再送する';

  @override
  String get codeResent => '確認コードを再送しました';

  @override
  String get passwordResetDone => 'パスワードを再設定しました';

  @override
  String get errorVerificationCodeFormat => 'メールに記載の確認コード（数字）を入力してください';

  @override
  String get errorVerificationCodeInvalid => '確認コードが正しくないか、有効期限が切れています';

  @override
  String get errorSamePassword => '現在のパスワードとは異なるパスワードを入力してください';

  @override
  String get errorResetRequestFailed => '確認コードを送信できませんでした。もう一度お試しください';

  @override
  String get errorResetFailed => 'パスワードの再設定に失敗しました。もう一度お試しください';

  @override
  String get retry => '再試行';

  @override
  String get errorLoadRetry => 'もう一度読み込む';

  @override
  String get errorLoadTitle => '読み込めませんでした';

  @override
  String get errorLoadBody => '通信状態を確認して、もう一度お試しください。';

  @override
  String get errorLocationUnavailable => '位置情報を取得できませんでした';

  @override
  String get errorLocationBody => '端末の位置情報の設定とネットワーク接続を確認してください。';

  @override
  String get nearbyBatches => '近くのフードバッグ';

  @override
  String countItems(int count) {
    return '$count件';
  }

  @override
  String get liveUpdating => '位置更新中';

  @override
  String get truckRunning => 'Eco-Truck 運行中';

  @override
  String truckNumber(int number) {
    return 'Eco-Truck $number号車';
  }

  @override
  String truckRouteSummary(int count) {
    return '今夜の停車予定 · $count地点';
  }

  @override
  String get truckTapHint => '地図上のトラックまたはこのカードをタップすると、停車予定とメニューを確認できます';

  @override
  String get stopPassed => '通過済み';

  @override
  String get nextStopBadge => '次の停車地';

  @override
  String get truckNoBatches => 'このトラックで販売中のフードバッグはありません';

  @override
  String get closeTruckRoute => '閉じる';

  @override
  String truckNextStop(String stopName) {
    return '次の停車地：$stopName';
  }

  @override
  String truckEta(String time, int minutes) {
    return '到着予定 $time・あと$minutes分';
  }

  @override
  String get homeEmptyTitle => '本日はまだ販売予定がありません';

  @override
  String get homeEmptyBody => 'LINEと連携すると、Eco-Truckが近づいたときにお知らせが届きます。';

  @override
  String get setupLineNotify => 'LINE通知を設定する';

  @override
  String get homeEmptyBodyLinked =>
      'Eco-Truckが近づいたら、EcoMeal公式アカウントからLINEでお知らせします。';

  @override
  String get openLine => 'LINEを開く';

  @override
  String get partnerStore => 'EcoMeal提携店';

  @override
  String get mysteryBag => 'ミステリーバッグ';

  @override
  String remainingBags(int qty) {
    return '残り$qty袋';
  }

  @override
  String get batchDetailTitle => 'フードバッグ詳細';

  @override
  String get priceCalculating => '価格を計算中...';

  @override
  String get errorPriceLoad => '価格の取得に失敗しました';

  @override
  String truckPeek(String stop, String time, int minutes) {
    return 'Eco-Truck 運行中 · 次は$stop $time（あと$minutes分）';
  }

  @override
  String stopWalk(String stop, int minutes) {
    return '$stop · 徒歩$minutes分';
  }

  @override
  String get errorSessionExpired => 'ログインの有効期限が切れました。もう一度ログインしてください';

  @override
  String get errorPaymentService =>
      '決済サービスで問題が起きたため、予約できませんでした。時間をおいて、もう一度お試しください';

  @override
  String get errorPriceTooLow =>
      'このフードバッグは、現在の価格ではカードでお支払いいただけません。ほかのフードバッグをお選びください';

  @override
  String minutesRemaining(int minutes) {
    return 'あと$minutes分';
  }

  @override
  String get pickupByEcoTruck => 'Eco-Truckで受け取り';

  @override
  String get allergensHeading => 'アレルゲン情報';

  @override
  String get allergensNone => '該当なし';

  @override
  String get ingredientsHeading => '主な原材料・産地';

  @override
  String ingredientWithOrigin(String name, String origin) {
    return '$name（$origin）';
  }

  @override
  String get originUnknown => '産地情報なし';

  @override
  String get detailNote => '内容は受け取りまでのお楽しみです。写真はイメージです。アレルギーをお持ちの方は表示をご確認ください。';

  @override
  String get dailyLimitReached => '本日の予約上限（2件）に達しています';

  @override
  String get reserveButton => '予約する';

  @override
  String get mapSetupRequired => '地図を表示できません。下の一覧はご覧いただけます。';

  @override
  String get openLocationSettings => '設定を開く';

  @override
  String get batchExpired => '販売期限を過ぎました。別のフードバッグをお選びください。';

  @override
  String get reservationCountFailed => '予約件数を確認できませんでした。もう一度お試しください。';

  @override
  String get homeTab => 'ホーム';

  @override
  String get reservationsTab => '予約';

  @override
  String get myPageTab => 'マイページ';

  @override
  String get locateMe => '現在地へ';

  @override
  String get statusPending => '数量確認待ち';

  @override
  String get statusAllocated => '取り置き済み';

  @override
  String get statusPickedUp => '受け取り済み';

  @override
  String get statusRefunded => '返金済み';

  @override
  String get statusExpired => '失効';

  @override
  String get statusCancelled => 'キャンセル済み';

  @override
  String get reservationConfirmTitle => '予約内容の確認';

  @override
  String get paymentMethodRequired => '支払い方法（必須）';

  @override
  String get paymentMethodSection => '支払い方法';

  @override
  String get addPaymentMethod => '支払い方法を追加';

  @override
  String get addPaymentMethodSub => 'クレジットカード・デビットカード';

  @override
  String get defaultCardLabel => 'デフォルトカード';

  @override
  String get addPaymentMethodHint => '支払い方法を追加すると、予約を確定できます。';

  @override
  String get addPaymentMethodButton => '支払い方法を追加する';

  @override
  String payNotice(String amount) {
    return '予約を確定すると、$amountが決済されます。';
  }

  @override
  String payButton(String amount) {
    return '$amountを支払って予約する';
  }

  @override
  String get errorPaymentMethodsLoad => '支払い方法を取得できませんでした';

  @override
  String get errorPaymentMethodMissing => '選択したカードが見つかりません。支払い方法を選び直してください';

  @override
  String get paymentTitle => 'お支払い';

  @override
  String get paymentProcessingTitle => 'お支払いを処理しています';

  @override
  String get paymentProcessingBody =>
      '完了までこの画面でお待ちください。\n支払いボタンを繰り返し押さないでください。';

  @override
  String get paymentProcessingNote => '決済結果を確認しています。\n通常は数秒で完了します。';

  @override
  String paymentSummaryLine(String amount, String card) {
    return '$amount（税込）  ·  $card';
  }

  @override
  String get reservationCompleteTitle => '予約完了';

  @override
  String get paymentDoneTitle => 'お支払いが完了しました';

  @override
  String get paymentDoneBody => '予約を受け付けました。\n受け取りの案内は予約画面で確認できます。';

  @override
  String pickupPlaceLine(String place) {
    return '受取地点：$place';
  }

  @override
  String pickupTimeLine(String time) {
    return '受取時間：$time';
  }

  @override
  String get viewReservation => '予約内容を確認';

  @override
  String get paymentDeclinedTitle => 'お支払いできませんでした';

  @override
  String get paymentDeclinedBody =>
      'カード会社で決済が承認されませんでした。\n別のカードをお選びいただくか、カード会社へご確認ください。';

  @override
  String get paymentCardExpiredBody => 'カードの有効期限が切れています。\n別のカードをお選びください。';

  @override
  String get paymentNotCompletedNote => 'この支払いは完了していません。\n予約はまだ確定していません。';

  @override
  String get payWithAnotherCard => '別のカードで支払う';

  @override
  String get backToReview => '予約内容に戻る';

  @override
  String get paymentUnknownTitle => '決済結果を確認できません';

  @override
  String get paymentUnknownBody =>
      '通信が途切れたため、支払い状況を確認しています。\n二重のお支払いを防ぐため、もう一度お支払いの操作はしないでください。';

  @override
  String get paymentUnknownNote => '支払い・予約状況は確認中です。\n通信状況を確認してから、もう一度お試しください。';

  @override
  String get recheckPayment => '支払い状況を再確認';

  @override
  String get viewReservationHistory => '予約履歴を確認';

  @override
  String get paymentNotFound => 'お支払いは完了していませんでした。もう一度お試しください';

  @override
  String get errorRecheckFailed => '確認できませんでした。接続を確認してもう一度お試しください';

  @override
  String get paymentMethodsTitle => '支払い方法';

  @override
  String get paymentMethodsSubtitle => 'カードを安全に管理';

  @override
  String get paymentMethodsEmptyTitle => '支払い方法が未登録です';

  @override
  String get paymentMethodsEmptyBody => 'カードを登録すると、予約の支払いがワンタップで完了します。';

  @override
  String get addCreditCard => '＋ クレジットカードを追加';

  @override
  String get paymentProviderNote => '支払い情報は、決済代行会社が安全に処理します。';

  @override
  String get registeredCards => '登録済みカード';

  @override
  String cardExpiresOn(String expiry) {
    return '有効期限 $expiry';
  }

  @override
  String get defaultBadge => 'デフォルト';

  @override
  String get addAnotherCard => '＋  別のカードを追加';

  @override
  String get paymentSafetyTitle => '支払いの安全性';

  @override
  String get paymentSafetyBody =>
      'カード情報は暗号化され、決済代行会社が安全に管理します。\nデフォルトカードを設定すると、ワンタップで支払えます。';

  @override
  String get setDefaultCard => 'デフォルトのカードに設定';

  @override
  String get deleteCard => 'このカードを削除';

  @override
  String get deleteCardTitle => 'このカードを削除しますか？';

  @override
  String deleteCardBody(String card) {
    return '$card を削除します。削除すると、このカードは次回以降のご注文に使えなくなります。';
  }

  @override
  String get deleteConfirm => '削除する';

  @override
  String get cardDeleted => 'カードを削除しました';

  @override
  String get defaultCardChanged => 'デフォルトのカードを変更しました';

  @override
  String get addCardTitle => 'カードを追加';

  @override
  String get addCardSubtitle => '安全な支払い方法';

  @override
  String get cardInfoSection => 'カード情報';

  @override
  String get cardNumberLabel => 'カード番号';

  @override
  String get cardNumberHint => '1234  5678  9012  3456';

  @override
  String get cardHolderLabel => 'カード名義';

  @override
  String get cardHolderHint => '例: TARO YAMADA';

  @override
  String get cardExpiryLabel => '有効期限';

  @override
  String get cardExpiryHint => 'MM / YY';

  @override
  String get cardCvcLabel => 'セキュリティコード';

  @override
  String get cardCvcHint => 'CVC';

  @override
  String get cardTokenNote =>
      'カード番号はEcoMealのサーバーに保存されず、決済代行会社が安全に管理します。セキュリティコードは他人に知らせないでください。';

  @override
  String get cardTermsNote => 'カードを追加すると、支払い条件に同意したものとみなされます。';

  @override
  String get addCardButton => 'カードを追加する';

  @override
  String get cardNumberInvalid => 'カード番号を確認してください。';

  @override
  String get cardHolderRequired => 'カード名義を入力してください。';

  @override
  String get cardExpiryInvalid => '有効期限を確認してください。';

  @override
  String get cardCvcInvalid => 'セキュリティコードを確認してください。';

  @override
  String get errorCardLimit => '登録できるカードは10枚までです';

  @override
  String get errorCardAdd => 'カードを追加できませんでした。もう一度お試しください';

  @override
  String get testPaymentNote =>
      'テスト中のため、実際に請求されることはありません。テスト用カード 4242 4242 4242 4242 をお使いください（0002で終わるカードは決済が拒否されます）。';

  @override
  String paymentMethodRowDefault(String card) {
    return '$card ・ デフォルト';
  }

  @override
  String get paymentMethodRowNone => '未登録';

  @override
  String get freeCancelTitle => '受取予定の30分前になるまで無料キャンセル';

  @override
  String get freeCancelBody =>
      '受取予定の30分前になるまでなら無料でキャンセルできます（20:00受取なら19:30より前まで）。キャンセルは予約履歴から行えます。';

  @override
  String get errorReservationFailed => '予約できませんでした。時間をおいて、もう一度お試しください';

  @override
  String get errorDailyLimit =>
      '本日の予約上限（2件）に達しているため、予約できませんでした。予約した内容は「予約」タブで確認できます';

  @override
  String get errorSoldOutAtStop => 'この受取地点の分は売り切れました。別のフードバッグをお選びください';

  @override
  String get errorBatchUnavailable => 'このフードバッグの予約受付は終了しました。別のフードバッグをお選びください';

  @override
  String get actionSeeReservations => '予約を確認する';

  @override
  String get actionFindOtherBags => 'ほかのフードバッグを探す';

  @override
  String get tryAgain => 'もう一度試す';

  @override
  String get orderHistoryTitle => '予約履歴';

  @override
  String get orderHistorySubtitle => 'あなたのEcoMealの記録';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterActive => '予約中';

  @override
  String get filterCompleted => '完了';

  @override
  String get orderHistoryEmpty => 'まだ予約がありません';

  @override
  String get cancelDialogTitle => '予約をキャンセルしますか？';

  @override
  String get cancelDialogFree =>
      '受取予定の30分前になるまでなら無料でキャンセルできます。今キャンセルすると全額返金されます。';

  @override
  String get cancelDialogNoRefund => '受取予定の30分前になったため、キャンセルしても返金されません。';

  @override
  String get back => '戻る';

  @override
  String get cancelConfirmButton => 'キャンセルする';

  @override
  String cancelledWithRefund(int amount) {
    return 'キャンセルしました（¥$amountを返金）';
  }

  @override
  String get cancelledNoRefund => 'キャンセルしました（返金はありません）';

  @override
  String get errorCancelFailed => 'キャンセルに失敗しました。もう一度お試しください';

  @override
  String reservedOrderLabel(String number) {
    return '予約済み · 注文 $number';
  }

  @override
  String get reservedPaid => 'お支払い済み';

  @override
  String orderNumber(String number) {
    return '注文 $number';
  }

  @override
  String get pendingExplanation =>
      'ドライバーが数量を確認しています。数量が足りない場合は、受取地点ごとに予約の早い順で確保します。確保できなかった分は自動で返金します。';

  @override
  String allocatedExplanation(String stopName) {
    return '$stopNameで1袋を確保しました。QRコードと受取時間・受取地点は「受け取りの案内」で確認できます。';
  }

  @override
  String get freeCancelExpired => '無料キャンセル期限を過ぎています（返金はありません）';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String manualCodeLabel(String code) {
    return '手動入力：$code';
  }

  @override
  String get pickupQrTitle => '受け取りQR';

  @override
  String get pickupQrCaption => '受け取りのときに、QRコードを読み取ってもらうか、確認コードをドライバーにお伝えください。';

  @override
  String get refundFullBadge => '全額返金されます';

  @override
  String get refundFullNote => '現在の予約状況では、キャンセル後に全額返金されます。';

  @override
  String get refundNoneBadge => '返金なし';

  @override
  String get refundNoneNote => '受取予定の30分前になったため、キャンセル後の返金はありません。';

  @override
  String get errorBadge => 'エラー';

  @override
  String get browseBatches => '近くのフードバッグを見る';

  @override
  String totalWithQuantity(int quantity) {
    return '合計（税込・数量 $quantity）';
  }

  @override
  String todayTime(String time) {
    return '本日 $time';
  }

  @override
  String errorDisplayNameTooLong(int max) {
    return '表示名は$max文字以内で入力してください';
  }

  @override
  String errorNameKanaTooLong(int max) {
    return 'フリガナは$max文字以内で入力してください';
  }

  @override
  String get errorLanguageSave => '言語設定の保存に失敗しました';

  @override
  String get errorLineStatusLoad => 'LINE連携状態を取得できませんでした';

  @override
  String get lineLinked => 'LINE連携済み';

  @override
  String get lineLinkedBody => '受け取り通知をLINEで確認できます';

  @override
  String get lineLinkHint => '通知はEcoMeal公式アカウント（LINE）のトークに届きます';

  @override
  String get lineOpenChat => 'LINEでトークを開く';

  @override
  String get errorOpenLine => 'LINEを開けませんでした';

  @override
  String get errorLineLinkFailed => 'LINE連携に失敗しました。もう一度お試しください';

  @override
  String get lineLinkButton => 'LINEと連携する';

  @override
  String get logoutDialogTitle => 'ログアウトしますか？';

  @override
  String get logoutDialogBody => 'ログアウトすると、ログイン画面に戻ります。';

  @override
  String get profileSaved => 'プロフィールを更新しました';

  @override
  String get errorSaveFailed => '保存に失敗しました。もう一度お試しください';

  @override
  String get discardDialogTitle => '変更を破棄しますか？';

  @override
  String get discardDialogBody => '編集した内容は保存されません。';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discard => '破棄する';

  @override
  String get profileEditTitle => 'プロフィール編集';

  @override
  String get requiredBadge => '必須';

  @override
  String get optionalBadge => '任意';

  @override
  String get nameKanaLabel => 'フリガナ';

  @override
  String get nameKanaHint => '例：ヤマダ タロウ';

  @override
  String get emailNotEditable => 'メールアドレスは変更できません';

  @override
  String get credentialsChangeOutOfScope =>
      'メールアドレスとパスワードはこの画面では変更できません。パスワードはログイン画面の「パスワードを忘れた方は」から再設定できます。';

  @override
  String get saveButton => '保存する';

  @override
  String get languageLabel => '言語 / Language';

  @override
  String get languageNameJa => '日本語';

  @override
  String get languageNameEn => '英語';

  @override
  String get languageNameVi => 'ベトナム語';

  @override
  String get languageNameUz => 'ウズベク語';

  @override
  String get languageSearchHint => '言語を検索 / Search';

  @override
  String get onboardingStart => 'はじめる';

  @override
  String get errorBatchAlreadyConfirmed => 'この料理の数量はすでに確定しています';

  @override
  String get errorStopNotOnRoute => '選んだ停車地点は、このルートに含まれていません';

  @override
  String get errorStopClosed => 'この停車地点はすでに出発しました';

  @override
  String get errorTemperatureRange => '温度は-30〜99.9℃の範囲で入力してください';

  @override
  String get errorConfirmFailed => '数量を確定できませんでした。もう一度お試しください';

  @override
  String get errorTemperatureRequired => '温度を入力してください';

  @override
  String get errorConfirmedQtyRequired => '確定数量を入力してください';

  @override
  String get errorNonNegativeInteger => '0以上の整数で入力してください';

  @override
  String get pickupConfirmTitle => '集荷を確認';

  @override
  String pickupSubtitle(String stopName, int index, int total) {
    return '$stopName • 集荷 $index/$total';
  }

  @override
  String estimatedMeals(int qty) {
    return '概算 $qty食';
  }

  @override
  String get confirmedQtyLabel => '確定数量';

  @override
  String get mealUnit => '食';

  @override
  String get coreTemperatureLabel => '受取時の中心温度';

  @override
  String get coldChainNotice => '冷蔵品は10℃以下であることを確認してください。基準を超えた場合は運営へ連絡してください。';

  @override
  String get coldChainOverLimit => '基準（10℃以下）を超えています。この料理は回収・販売できません。';

  @override
  String get distributionStopsLabel => '配分先の停車地点';

  @override
  String get distributionStopsHint => '現在のルートの停車地点を選択してください。選択した停車地点に分配されます。';

  @override
  String get noDistributableStops => '配分できる停車地点がありません（すべて出発済み）';

  @override
  String get nextStopLabel => '次の停車';

  @override
  String nthStopLabel(int n) {
    return '$n番目';
  }

  @override
  String distributionStopSubtitle(String order, String time) {
    return '$order • $time予定';
  }

  @override
  String selectedStopsCount(int count) {
    return '選択した停車地点（$count箇所）に分配されます。';
  }

  @override
  String confirmPickupButton(String qty) {
    return '$qty食の受け取りを確定';
  }

  @override
  String get rejectPickupButton => '回収しない（温度基準外）';

  @override
  String get rejectPickupDialogTitle => 'この料理の回収を見送りますか？';

  @override
  String rejectPickupDialogBody(String celsius) {
    return '中心温度が$celsius℃で、基準（10℃以下）を超えています。この料理は販売せず、予約はすべて返金され、お客様に通知されます。温度の記録は残ります。';
  }

  @override
  String get rejectPickupConfirm => '回収しない';

  @override
  String pickupRejectedToast(int refunded) {
    return '温度基準外のため回収しませんでした（予約$refunded件を返金）';
  }

  @override
  String get noTruckAssigned => '担当トラックが割り当てられていません。運営へ連絡してください';

  @override
  String get noRouteTonight => '今夜のルートはまだありません';

  @override
  String get errorLoad => 'データの取得に失敗しました';

  @override
  String get tonightRouteTitle => '今夜のルート';

  @override
  String get gpsUnavailable => '位置情報取得不可';

  @override
  String get settings => '設定';

  @override
  String minutesShort(int minutes) {
    return '$minutes分';
  }

  @override
  String stopDoneHandoff(int count) {
    return '完了 • $count件引き渡し';
  }

  @override
  String get stopKindPickup => '集荷';

  @override
  String stopReservations(int count) {
    return '予約 $count件';
  }

  @override
  String nextStopPrefixed(String body) {
    return '次の停車 • $body';
  }

  @override
  String get driverProfileTitle => 'プロフィール・設定';

  @override
  String get driverRoleChip => 'ドライバー';

  @override
  String get assignedTruck => '担当トラック';

  @override
  String get unassigned => '未割当';

  @override
  String get plateNumberLabel => 'ナンバープレート';

  @override
  String get driverTabRoute => '運行';

  @override
  String get driverTabPickup => '集荷';

  @override
  String get driverTabSales => '販売';

  @override
  String get driverTabEnd => '終了';

  @override
  String get noPickupsTonight => '今夜の集荷予定はありません';

  @override
  String get gpsSending => '位置情報を送信中';

  @override
  String get driverAccountSubtitle => 'ドライバーアカウント';

  @override
  String get errorNotHandoverable => 'この予約は、受け渡しを確認できる状態ではありません';

  @override
  String get errorPaymentNotConfirmed => 'この予約は支払いの確認が終わっていません。渡さずに運営に連絡してください';

  @override
  String get errorWalkupSoldOut => 'この停車地点で予約なしで販売できる分は売り切れです';

  @override
  String get errorWalkupNotConfirmed => '数量を確定する前は、予約なしの販売はできません';

  @override
  String get errorBatchExpired => 'この料理は販売期限を過ぎています';

  @override
  String get errorDonationExceedsStock => '寄付数量が残り在庫を超えています';

  @override
  String get errorDonationNotConfirmed => '数量を確定する前は、寄付を記録できません';

  @override
  String get errorDonationStopsOpen => '未出発の販売地点があるため、まだ寄付を記録できません';

  @override
  String get errorDonationNoteRequired => '寄付先を入力してください';

  @override
  String get errorNotAssignedDriver => 'このトラックの担当ドライバーではありません';

  @override
  String get errorGeneric => 'エラーが発生しました。もう一度お試しください';

  @override
  String get errorDonationQtyRequired => '寄付数量を入力してください';

  @override
  String get errorPositiveInteger => '1以上の整数で入力してください';

  @override
  String handedOverToast(String number) {
    return '引き渡しを記録しました（$number）';
  }

  @override
  String get errorNotWaitingHere => 'この停車地点で引き渡し待ちの予約ではありません';

  @override
  String get errorNoMatchingReservation => '該当する予約がありません';

  @override
  String get duplicateCodeTitle => '同じコードの予約が複数あります';

  @override
  String duplicateCodeOption(String number, String time) {
    return '$number（予約 $time）';
  }

  @override
  String walkupSoldToast(int price) {
    return '予約なしの販売を記録しました（¥$price）';
  }

  @override
  String get departDialogTitle => '停車地点を出発しますか？';

  @override
  String currentStop(String name) {
    return '現在の停車地点：$name';
  }

  @override
  String departWarning(int count) {
    return '$count件の予約が引き渡し待ちです。出発すると、これらの予約は「受け取りなし（失効）」として扱われ、返金されません。';
  }

  @override
  String get departWarningTitle => '未受取の予約が残っています';

  @override
  String get cautionBadge => '注意';

  @override
  String get departConfirm => '出発する';

  @override
  String departedWithExpired(int count) {
    return '出発しました（未受取$count件を失効）';
  }

  @override
  String get departed => '出発しました';

  @override
  String get departedLabel => '出発済み';

  @override
  String minutesUntilDeparture(int minutes) {
    return '停車終了まで $minutes分';
  }

  @override
  String reservationsCount(int count) {
    return '予約 $count';
  }

  @override
  String get reservationHandoffTab => '予約引き渡し';

  @override
  String get walkupTab => '予約なし販売';

  @override
  String get handedOverLabel => '引き渡し済み';

  @override
  String get waitingLabel => '予約待ち';

  @override
  String get departButton => '停車地点を出発';

  @override
  String get scanPickupQr => '受け取りQRを読み取る';

  @override
  String get scanPickupQrHint => 'お客様の受け取りQRを読み取ってください';

  @override
  String get manualCodeFallback => 'QRが読み取れない場合：手動入力';

  @override
  String get batchLabel => '料理';

  @override
  String get noWalkupBatches => 'この停車地点で販売できる料理はありません';

  @override
  String mealsRemaining(int qty) {
    return '残り $qty食';
  }

  @override
  String get registerSale => '販売を登録';

  @override
  String get soldLabel => '販売済み';

  @override
  String get enterPickupCode => '受け取りコードを入力';

  @override
  String get pickupCodeHint => '例：A7K2';

  @override
  String get verifyCode => '照合する';

  @override
  String get noSalesTonight => '今夜の販売予定はありません';

  @override
  String get routeEndTitle => '運行を終了';

  @override
  String get routeSummaryTitle => '運行のまとめ';

  @override
  String get routeEndThanks => '今夜の運行、おつかれさまでした';

  @override
  String mealsCount(int count) {
    return '$count食';
  }

  @override
  String get salesStopsLabel => '販売地点';

  @override
  String openStopsWarning(int count) {
    return '未出発の販売地点が$count箇所あります。「販売」タブから出発操作を行ってください。';
  }

  @override
  String donationBatchOption(String name, int qty, int remaining) {
    return '$name（確定 $qty食・残り $remaining食）';
  }

  @override
  String donationRecorded(int remaining) {
    return '寄付を記録しました（この料理の残り $remaining食）';
  }

  @override
  String get donationTitle => '未販売分の寄付記録';

  @override
  String get donationLockedNotice =>
      '全ての販売地点を出発した後に寄付を記録できます（出発後は販売できなくなるため、在庫が確定します）。';

  @override
  String get noConfirmedBatches => '数量を確定した料理がありません';

  @override
  String get donationQtyLabel => '寄付数量';

  @override
  String get donationRecipientLabel => '寄付先';

  @override
  String get donationRecipientHint => '例：○○こども食堂';

  @override
  String get donationHandedOverCheck => '寄付先への引き渡しを確認しました';

  @override
  String get recordDonationButton => '寄付を記録する';

  @override
  String get driverLicenseTitle => '運転免許証';

  @override
  String get licenseStatusNone => '未提出';

  @override
  String get licenseStatusSubmitted => '確認待ち';

  @override
  String get licenseStatusVerified => '確認済み';

  @override
  String get licenseStatusRejected => '差し戻し';

  @override
  String get licenseNoneBody => '運転免許証を撮影して提出してください。運営が確認するまでシフトには入れません。';

  @override
  String get licenseSubmittedBody => '運営が確認しています。確認が終わるとシフトに入れるようになります。';

  @override
  String licenseExpiresOn(String date) {
    return '有効期限 $date';
  }

  @override
  String get licenseRejectedLabel => '運営からのメッセージ';

  @override
  String get licenseUploadButton => '撮影してアップロード';

  @override
  String get licenseResubmitButton => '更新した免許証を提出する';

  @override
  String get licenseResubmitNote => '提出し直すと、運営が確認するまで新しいシフトに入れません。';

  @override
  String get licensePrivacyNote => '画像は運営チームだけが確認します。';

  @override
  String get licenseSourceCamera => 'カメラで撮影';

  @override
  String get licenseSourceGallery => '写真から選ぶ';

  @override
  String get licenseUploadSuccess => '提出しました。運営の確認をお待ちください。';

  @override
  String get licenseUploadError => '提出できませんでした。通信状態を確認して、もう一度お試しください。';

  @override
  String upcomingShiftsTitle(int days) {
    return '今後のシフト（$days日間）';
  }

  @override
  String get upcomingShiftsEmpty => '予定されたシフトはありません。シフトが決まると、ここに表示されます。';

  @override
  String get shiftsLoadError => 'シフトを取得できませんでした。';

  @override
  String get torchOn => 'ライトをつける';

  @override
  String get torchOff => 'ライトを消す';

  @override
  String get mealPhotoLabel => '料理の写真';

  @override
  String get detailNotePhoto =>
      '写真は店舗が登録した料理です。数量や盛り付けは写真と異なる場合があります。アレルギーをお持ちの方は表示をご確認ください。';

  @override
  String get legalTermsTitle => '利用規約';

  @override
  String get legalPrivacyTitle => 'プライバシーポリシー';

  @override
  String get legalEnactedOn => '改定日: 2026年10月11日（制定日: 2026年10月9日）';

  @override
  String get legalDemoNotice => '卒業制作のデモ用の文面です。正式に公開する前に、専門家の確認を受ける予定です。';

  @override
  String get legalContactTitle => 'お問い合わせ';

  @override
  String get termsArticle1Title => '第1条（適用）';

  @override
  String get termsArticle1Body =>
      '本規約は、EcoMeal（以下「当サービス」）のスマートフォンアプリの利用条件を定めるものです。利用者は、会員登録の際に本規約に同意したうえで当サービスを利用するものとします。';

  @override
  String get termsArticle2Title => '第2条（アカウント）';

  @override
  String get termsArticle2Body =>
      '会員登録は、メールアドレスとパスワード、LINE、Apple のいずれかで行います。登録情報は正確に保ち、パスワードを第三者に知らせないでください。LINE・Apple で登録した場合も、同じ EcoMeal のアカウントとして本規約が適用されます。不正な利用が判明した場合、運営はアカウントの利用を停止することがあります。';

  @override
  String get termsArticle3Title => '第3条（商品）';

  @override
  String get termsArticle3Body =>
      '当サービスで販売する料理は、提携店舗でその日に調理され余剰となったもの（ミステリーバッグ）です。内容・数量は日によって異なり、販売期限が近づくほど価格が下がります。アレルゲン（28品目）と原材料の産地は購入前にアプリでご確認ください。同じ厨房で調理しているため、微量の混入の可能性はゼロではありません。';

  @override
  String get termsArticle4Title => '第4条（予約と支払い）';

  @override
  String get termsArticle4Body =>
      '予約は1日2件までです。支払いには登録したカードを使います。現在はテスト中のため、実際の請求は発生しません。カード番号・セキュリティコードは当サービスのサーバーに保存しません。';

  @override
  String get termsArticle5Title => '第5条（キャンセル・返金）';

  @override
  String get termsArticle5Body =>
      '受取予定時刻の30分前になるまでのキャンセルは全額返金、30分前ちょうど以降のキャンセルは返金なしとなります（例：20:00受取なら19:30より前は全額返金、19:30からは返金なし）。数量不足で確保できなかった予約は自動で返金します。受取地点の出発時刻までに受け取られなかった予約は失効し、返金はありません。';

  @override
  String get termsArticle6Title => '第6条（受け取り）';

  @override
  String get termsArticle6Body =>
      '予約した受取地点・時間帯に停車しているEco-Truckで、予約画面のQRコードまたは確認コードを提示して受け取ってください。';

  @override
  String get termsArticle7Title => '第7条（位置情報・通知）';

  @override
  String get termsArticle7Body =>
      '位置情報は、近くの受取地点を表示するために端末内で使用し、サーバーには保存しません。お知らせ（トラックの接近、返金、問題の報告への回答、お気に入りの受取地点の新着）は、アプリの通知をオンにしていればアプリに届きます。オンにしていない場合は、LINE と連携していれば EcoMeal 公式アカウントから届きます。トラックの接近は、LINE と連携している場合は LINE に届きます。';

  @override
  String get termsArticle8Title => '第8条（プロフィール写真）';

  @override
  String get termsArticle8Body =>
      'プロフィール写真は、利用者本人のマイページにのみ表示されます。他人の肖像・著作物など第三者の権利を侵害する画像や、公序良俗に反する画像は登録できません。運営は不適切な画像を削除することがあります。';

  @override
  String get termsArticle9Title => '第9条（禁止事項）';

  @override
  String get termsArticle9Body =>
      '法令に違反する行為、他の利用者・提携店舗・ドライバーへの迷惑行為、購入した商品の転売、当サービスへの不正アクセスを禁止します。';

  @override
  String get termsArticle10Title => '第10条（変更・停止・免責）';

  @override
  String get termsArticle10Body =>
      '当サービスは卒業制作として開発・検証中であり、予告なく内容の変更・停止を行うことがあります。本規約を変更する場合はアプリでお知らせし、重要な変更は改めて同意をいただきます。';

  @override
  String get privacySection1Title => '1. 取得する情報';

  @override
  String get privacySection1Body =>
      '会員登録の情報（メールアドレス、表示名、フリガナ、プロフィール写真）、予約・購入の履歴、支払い方法（カードのブランド・下4桁・有効期限のみ）、LINE でログイン・連携したときの LINE ユーザーID、Apple でサインインしたときに Apple から受け取る ID とメールアドレス（Apple の非公開メールアドレスの場合を含む）、お問い合わせの内容、アプリの利用状況（フードバッグや予約画面を開いた記録）、不具合の情報（エラーの内容・端末の種類・アプリのバージョン）、通知を受け取るための端末の識別子を取得します。カード番号・セキュリティコードは当サービスでは取得・保存しません（決済代行会社が直接受け取ります）。';

  @override
  String get privacySection2Title => '2. 位置情報';

  @override
  String get privacySection2Body =>
      '近くの受取地点を表示するために端末の位置情報を使いますが、サーバーには送信・保存しません。';

  @override
  String get privacySection3Title => '3. 利用目的';

  @override
  String get privacySection3Body =>
      '予約・受け渡し・返金の処理、受け取りのお知らせ、お問い合わせへの回答、サービスの改善のために利用します。';

  @override
  String get privacySection4Title => '4. 第三者への提供・委託';

  @override
  String get privacySection4Body =>
      '法令に基づく場合を除き、本人の同意なく第三者に提供しません。データの保管（Supabase）、地図の表示（Google マップ）、通知（LINE、Firebase Cloud Messaging）、決済（Stripe）、不具合の監視（Sentry）のため、各サービスに処理を委託します。';

  @override
  String get privacySection5Title => '5. 開示・訂正・削除のご請求';

  @override
  String get privacySection5Body =>
      '登録情報の開示・訂正・削除のご請求は、お問い合わせフォームからご連絡ください。アカウントとプロフィール写真は、マイページからいつでも削除できます。';

  @override
  String get termsUpdatedTitle => '利用規約が更新されました';

  @override
  String get termsUpdatedBody =>
      'EcoMealを引き続きご利用いただくには、最新の利用規約とプライバシーポリシーへの同意が必要です。';

  @override
  String get termsAgreeAndContinue => '同意して続ける';

  @override
  String get termsDeclineAndLogout => '同意しない（ログアウト）';

  @override
  String get errorTermsAcceptFailed => '同意を記録できませんでした。もう一度お試しください';

  @override
  String get signupConsentBefore => '';

  @override
  String get signupConsentBetween => 'と';

  @override
  String get signupConsentAfter => 'に同意します';

  @override
  String get signupConsentHint => '同意すると「登録する」を押せます。リンクから全文を確認できます。';

  @override
  String get aboutAppSection => 'アプリについて';

  @override
  String get appVersionLabel => 'バージョン';

  @override
  String get profilePhotoSet => '写真を設定';

  @override
  String get profilePhotoChange => '写真を変更';

  @override
  String get profilePhotoHint => 'JPEG・PNG（10MBまで）。正方形に切り抜いて表示します。';

  @override
  String get profilePhotoUploading => '写真をアップロードしています…';

  @override
  String get errorProfilePhotoUpload =>
      '写真をアップロードできませんでした。通信状況を確認して、もう一度お試しください。';

  @override
  String get errorProfilePhotoInvalid => '10MB以下のJPEG・PNGを選んでください';

  @override
  String get profilePhotoSheetTitle => 'プロフィール写真';

  @override
  String get profilePhotoTake => '写真を撮る';

  @override
  String get profilePhotoLibrary => 'ライブラリから選ぶ';

  @override
  String get profilePhotoDelete => '写真を削除';

  @override
  String get profilePhotoDeleted => '写真を削除しました';

  @override
  String get photoAccessDeniedTitle => 'カメラと写真へのアクセスが許可されていません';

  @override
  String get openSettings => '設定を開く';

  @override
  String get photoAccessDeniedBody => '端末の設定で、EcoMealにカメラと写真へのアクセスを許可してください。';

  @override
  String get deleteAccountLink => 'アカウントを削除';

  @override
  String get deleteAccountTitle => 'アカウントの削除';

  @override
  String get deleteAccountLead =>
      'アカウントを削除すると、EcoMealにログインできなくなります。この操作は取り消せません。';

  @override
  String get deleteAccountRemovedTitle => '削除されるもの';

  @override
  String get deleteAccountRemoved1 => '・メールアドレス、表示名、フリガナ、プロフィール写真';

  @override
  String get deleteAccountRemoved2 => '・登録したカード（ブランド・下4桁・有効期限）';

  @override
  String get deleteAccountRemoved3 => '・LINE連携と、トラック接近のお知らせ';

  @override
  String get deleteAccountKeptTitle => '残るもの（個人を特定できない形で）';

  @override
  String get deleteAccountKeptBody =>
      '過去の予約・購入の記録は、売上とお店へのお支払いの計算のため、氏名・メールアドレスを外して保存します。';

  @override
  String get deleteAccountNote =>
      '受け取り前の予約がある場合は、キャンセルするか受け取ってから削除してください。LINEのEcoMeal公式アカウントの友だち登録は、LINEアプリから解除できます。';

  @override
  String get deleteAccountOpenOrders =>
      '受け取り前の予約があります。予約タブでキャンセルするか、受け取ってから削除してください。';

  @override
  String get deleteAccountButton => 'アカウントを削除する';

  @override
  String get deleteAccountDialogTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountDialogBody => 'この操作は取り消せません。予約・購入の記録は個人が分からない形で残ります。';

  @override
  String get deleteAccountConfirm => '削除する';

  @override
  String get accountDeleted => 'アカウントを削除しました';

  @override
  String get errorDeleteAccount => 'アカウントを削除できませんでした。もう一度お試しください';

  @override
  String get legalTokushohoTitle => '特定商取引法に基づく表記';

  @override
  String taxIncludedLine(int rate) {
    return 'うち消費税（$rate%）';
  }

  @override
  String priceTaxIncluded(String price) {
    return '$price（税込）';
  }

  @override
  String get receiptButton => '領収書';

  @override
  String get receiptTitle => '領収書';

  @override
  String receiptAddressee(String name) {
    return '$name 様';
  }

  @override
  String get receiptPurpose => '但し 食品代として';

  @override
  String receiptTaxableLine(int rate) {
    return '$rate%対象（税込）';
  }

  @override
  String get receiptUsedOn => 'ご利用日';

  @override
  String get receiptOrderNumber => '注文番号';

  @override
  String get receiptPaymentMethod => 'お支払い方法';

  @override
  String get receiptPaymentCard => 'クレジットカード';

  @override
  String get receiptIssuedOn => '発行日';

  @override
  String get receiptIssuer => 'EcoMeal 運営チーム（卒業制作プロジェクト）';

  @override
  String get receiptNote =>
      '※ 軽減税率（8%）対象の商品です。当サービスは適格請求書発行事業者の登録を受けていないため、登録番号の記載はありません。この画面を保存・印刷してご利用ください。';

  @override
  String get stripeCardIncomplete => 'カード番号・有効期限・セキュリティコードを入力してください。';

  @override
  String get errorCardDeclined => 'このカードは登録できませんでした。別のカードをお試しください';

  @override
  String get pushSectionTitle => 'アプリの通知';

  @override
  String get pushOffTitle => 'アプリの通知';

  @override
  String get pushOffBody => 'トラックの接近や返金を、このスマートフォンに通知します。';

  @override
  String get pushEnableButton => '通知をオンにする';

  @override
  String get pushOnTitle => '通知はオンです';

  @override
  String get pushOnBody =>
      'トラックの接近・返金・お気に入りの受取地点の新着をお知らせします。LINEと連携している場合、トラックの接近はLINEに届きます。';

  @override
  String get pushDeniedTitle => '通知が許可されていません';

  @override
  String get pushDeniedBody => '端末の設定で、EcoMealの通知を許可してください。';

  @override
  String get errorPushEnable => '通知をオンにできませんでした。もう一度お試しください';

  @override
  String get reportIssueButton => '問題を報告';

  @override
  String get reportIssueTitle => '問題を報告';

  @override
  String get reportIssueQuestion => 'どのような問題でしたか？';

  @override
  String get issueCategoryWrongContents => '内容・数量が予約と違う';

  @override
  String get issueCategoryQuality => '品質に問題がある（傷み・異物など）';

  @override
  String get issueCategoryNotReceived => '受け取れなかった';

  @override
  String get issueCategoryOther => 'その他';

  @override
  String get reportIssueDetailLabel => '詳しい内容';

  @override
  String get reportIssueDetailHint => '例：パンの一部にカビがありました';

  @override
  String get reportIssueNote =>
      '受け取りから48時間以内にご報告ください。運営が確認し、必要に応じて返金します（結果は通知と予約履歴でお知らせします）。';

  @override
  String get reportIssueSubmit => '報告を送信';

  @override
  String get reportIssueSent => '報告を送信しました';

  @override
  String get errorReportIssueSelect => '問題の種類を選んでください';

  @override
  String get errorReportIssueDetail => '詳しい内容を入力してください（500文字以内）';

  @override
  String get errorReportIssueLate =>
      '受け取りから48時間を過ぎたため、アプリから報告できません。お問い合わせフォームからご連絡ください';

  @override
  String get errorReportIssueDuplicate => 'この注文はすでに報告済みです';

  @override
  String get errorReportIssue => '報告を送信できませんでした。もう一度お試しください';

  @override
  String get issueOpenTitle => '問題を報告しました（確認中）';

  @override
  String get issueOpenBody => '運営が内容を確認し、必要に応じて返金します。結果はお知らせします。';

  @override
  String issueResolvedRefund(int amount) {
    return '対応しました：¥$amountを返金';
  }

  @override
  String get issueResolvedNoRefund => '対応しました';

  @override
  String get favoriteStopsTitle => 'お気に入りの受取地点';

  @override
  String get favoriteStopsIntro =>
      'この受取地点に新しいフードバッグが出たら、アプリの通知（またはLINE）でお知らせします。最大5件まで登録できます。';

  @override
  String get favoriteStopsHint =>
      '地点をタップすると、今夜受け取れるフードバッグを見られます。★をタップすると解除できます。通知が届かない場合は、マイページの「アプリの通知」をオンにしてください。';

  @override
  String get stopBagsHeading => '今夜この受取地点で受け取れるフードバッグ';

  @override
  String get stopBagsEmptyTitle => '今夜はまだフードバッグがありません';

  @override
  String get stopBagsEmptyBody =>
      'この受取地点に新しいフードバッグが出たら、アプリの通知（またはLINE）でお知らせします。';

  @override
  String get favoriteStopsEmptyTitle => 'お気に入りの受取地点はまだありません';

  @override
  String get favoriteStopsEmptyBody =>
      'フードバッグ詳細の受け取り欄にある☆をタップすると、その受取地点に新しいフードバッグが出たときにお知らせします。';

  @override
  String get favoriteStopsRowNone => '未登録 ・ 新しいフードバッグをお知らせ';

  @override
  String favoriteStopsRowCount(int count) {
    return '$count件 ・ 新しいフードバッグをお知らせ';
  }

  @override
  String get favoriteAddedTitle => 'お気に入りに追加しました';

  @override
  String get favoriteAddedBody => 'この受取地点の新着をお知らせします。';

  @override
  String get favoriteAddedPushOff => '通知がオフのため、新着のお知らせは届きません。';

  @override
  String get favoriteAddedPushDenied => '通知が許可されていないため、新着のお知らせは届きません。';

  @override
  String get favoriteRemovedTitle => 'お気に入りを解除しました';

  @override
  String get favoriteRemovedBody => 'この受取地点の新着通知を停止しました。';

  @override
  String get favoriteFeedbackClose => '閉じる';

  @override
  String get favoriteLimitReached => 'お気に入りの受取地点は5件まで登録できます。マイページから整理してください';

  @override
  String get favoriteUpdateFailed => 'お気に入りを更新できませんでした。時間をおいて再度お試しください';

  @override
  String get favoriteAddTooltip => 'この受取地点をお気に入りに追加';

  @override
  String get favoriteRemoveTooltip => 'お気に入りから外す';

  @override
  String get ratingPromptTitle => 'フードバッグはいかがでしたか？';

  @override
  String get ratingPromptHint => '星をタップして評価（受け取りから7日以内）';

  @override
  String get ratingLabel1 => '不満';

  @override
  String get ratingLabel2 => 'やや不満';

  @override
  String get ratingLabel3 => 'ふつう';

  @override
  String get ratingLabel4 => '満足';

  @override
  String get ratingLabel5 => 'とても満足';

  @override
  String ratingStarSemantics(int count) {
    return '星$countつ';
  }

  @override
  String ratingSheetOrder(String number, String time) {
    return '注文 #$number ・ $time 受け取り';
  }

  @override
  String get ratingCommentLabel => 'お店へのひとこと（任意）';

  @override
  String get ratingCommentHint => '例: 量がたっぷりで、温かいまま受け取れました。';

  @override
  String get ratingPrivacyNote => '評価はお名前を出さずにお店に届きます。個人情報は書かないでください。';

  @override
  String get ratingSubmit => '評価を送信';

  @override
  String get ratingSent => '評価を送信しました。ありがとうございました';

  @override
  String get ratingErrorExpired => '受け取りから7日を過ぎたため評価できません';

  @override
  String get ratingErrorAlreadyRated => 'この注文はすでに評価済みです';

  @override
  String get ratingErrorFailed => '評価を送信できませんでした。もう一度お試しください';

  @override
  String get ratedLabel => 'あなたの評価';

  @override
  String get ratedThanks => 'ありがとうございました';

  @override
  String ratedSemantics(int count) {
    return 'あなたの評価 星$countつ';
  }

  @override
  String get impactTitle => 'あなたが救った食品';

  @override
  String get impactEmpty => 'フードバッグを受け取ると、ここに救った食品の量とCO₂の削減量が表示されます。';

  @override
  String impactBagsValue(int count) {
    return '$count個';
  }

  @override
  String get impactBagsLabel => '受け取ったフードバッグ';

  @override
  String get impactFoodLabel => '救った食品';

  @override
  String get impactCo2Label => 'CO₂削減';

  @override
  String impactApproxKg(String kg) {
    return '約${kg}kg';
  }

  @override
  String impactNote(String bagKg, String factor) {
    return '推定値です（1袋 約${bagKg}kg、食品ロス1kgあたりCO₂ 約${factor}kg で計算）';
  }

  @override
  String get couponsTitle => 'クーポン・友だち紹介';

  @override
  String couponsRowSubtitle(int count) {
    return 'クーポン$count枚 ・ 友だち紹介で¥100';
  }

  @override
  String get couponSectionLabel => 'クーポン';

  @override
  String get subtotalLabel => '小計';

  @override
  String couponAmountOff(int amount) {
    return '¥$amount引き';
  }

  @override
  String couponValidUntil(String date) {
    return '$dateまで';
  }

  @override
  String get couponReasonWelcome => '友だち紹介クーポン（登録特典）';

  @override
  String get couponReasonReward => '友だち紹介クーポン（お礼）';

  @override
  String get couponReasonCampaign => 'キャンペーンクーポン';

  @override
  String get couponsUsableHeading => '使えるクーポン';

  @override
  String get couponsNone => '使えるクーポンはありません';

  @override
  String get couponNoneHint => '友だちを紹介すると¥100クーポンがもらえます';

  @override
  String get couponsAutoNote =>
      'クーポンは予約内容の確認画面で自動的に使われます（1回の予約に1枚）。無料キャンセルの期間内にキャンセルすると戻ります。';

  @override
  String get errorCouponUnavailable => 'このクーポンは使えなくなりました。内容を確認して、もう一度お試しください';

  @override
  String get receiptCouponLine => 'クーポン値引き';

  @override
  String get referralMyCodeLabel => 'あなたの紹介コード';

  @override
  String get referralCopy => 'コピー';

  @override
  String get referralCopied => '紹介コードをコピーしました';

  @override
  String get referralShareLine => 'LINEで送る';

  @override
  String referralShareText(String code) {
    return 'EcoMealで、まだおいしい料理をお得に受け取れます。登録して紹介コード「$code」を入力すると¥100クーポンがもらえます。';
  }

  @override
  String get referralHowItWorks =>
      '友だちがこのコードを入力すると、友だちに¥100クーポンが届きます。友だちが最初のフードバッグを受け取ると、あなたにも¥100クーポンが届きます。';

  @override
  String get referralEnterLabel => '友だちの紹介コードを入力';

  @override
  String get referralEnterHint => '例: EM3PX9';

  @override
  String get referralApply => '適用';

  @override
  String get referralEnterNote => '登録から14日以内・最初のフードバッグを受け取る前まで使えます。';

  @override
  String referralApplied(String code) {
    return '紹介コード $code を適用しました';
  }

  @override
  String get referralAppliedToast => '¥100クーポンを受け取りました';

  @override
  String get referralErrorFormat => '6文字の紹介コードを入力してください';

  @override
  String get referralErrorNotFound => 'この紹介コードは見つかりません';

  @override
  String get referralErrorOwnCode => 'ご自身の紹介コードは使えません';

  @override
  String get referralErrorNotEligible => '紹介コードを入力できる期間が過ぎています';

  @override
  String get referralErrorFailed => '紹介コードを適用できませんでした。もう一度お試しください';

  @override
  String get socialLoginDivider => 'または';

  @override
  String get lineLoginButton => 'LINEでログイン';

  @override
  String get appleLoginButton => 'Appleでサインイン';

  @override
  String get socialLoginNote => '初めての方は、LINE・Appleのアカウントで EcoMeal に登録されます。';

  @override
  String get lineLoginFailed => 'LINEでログインできませんでした。時間をおいて、もう一度お試しください';

  @override
  String get appleLoginFailed => 'Appleでサインインできませんでした。時間をおいて、もう一度お試しください';

  @override
  String get socialLoginNotCustomer =>
      'このアカウントはLINEでログインできません。メールアドレスとパスワードでログインしてください';

  @override
  String get signedInWithLine => 'LINEでログイン中';

  @override
  String get storeReviewPendingTitle => '審査中です';

  @override
  String get storeReviewPendingBody => 'EcoMeal がご登録内容を確認しています。結果はメールでお知らせします。';

  @override
  String get storeReviewCheckButton => '審査の結果を確認する';

  @override
  String get storeFieldName => '店舗名';

  @override
  String get storeFieldAppliedAt => '申請日';

  @override
  String get storeFieldApplicant => '申請者';

  @override
  String get storeReviewRejectedTitle => '承認できませんでした';

  @override
  String get storeReviewRejectedBody => '内容を見直してもう一度申し込みたい場合は、お問い合わせからご連絡ください。';

  @override
  String get storeRejectionReasonLabel => '見送りの理由';

  @override
  String get storeNotRegisteredTitle => '店舗の登録が完了していません';

  @override
  String get storeNotRegisteredBody =>
      'Web（ecomeal-pi.vercel.app）からお店の登録をお申し込みください。承認されると、このアプリで料理を出品できます。';

  @override
  String get storeTabHome => 'ホーム';

  @override
  String get storeTabRegister => '登録';

  @override
  String get storeTabSettlement => '入金';

  @override
  String get storeTabSettings => '設定';

  @override
  String get storeRegisterCta => '今日の出品を登録';

  @override
  String storeRegisterDeadline(String time, String remaining) {
    return '目安 $timeまで（あと$remaining）';
  }

  @override
  String storeRegisterDeadlinePassed(String time) {
    return '目安の $time を過ぎました。トラックがお店を出発するまでは登録できます。';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get storePhotoRemovedTitle => '料理の写真が削除されました';

  @override
  String get storePhotoRemovedHint => '次回は店名・ロゴが写らない写真をお使いください。';

  @override
  String get storePhotoRemovedAck => '確認しました';

  @override
  String get storeTodayBatches => '今日の出品';

  @override
  String get storeBatchStatusEstimated => '回収待ち';

  @override
  String get storeBatchStatusOnSale => '販売中';

  @override
  String get storeBatchStatusEnded => '終了';

  @override
  String storeSellBy(String time) {
    return '販売終了 $time';
  }

  @override
  String storeCollectionPlanned(String time) {
    return '回収予定 $time';
  }

  @override
  String storeBatchQtyConfirmed(int estimated, int confirmed) {
    return '予定 $estimated食 → 引き取り $confirmed食';
  }

  @override
  String storeBatchQtyEstimated(int estimated) {
    return '予定 $estimated食（回収待ち）';
  }

  @override
  String storeBatchCounts(int reserved, int pickedUp) {
    return '予約 $reserved件 ・ 受取 $pickedUp件';
  }

  @override
  String storeBatchReserved(int reserved) {
    return '予約 $reserved件';
  }

  @override
  String get storeNoBatchesTitle => '今日の出品はまだありません';

  @override
  String get storeNoBatchesBody =>
      '余りそうな料理があれば、15〜16時頃を目安にご登録ください。今夜のトラックが引き取りに来ます。';

  @override
  String get storeLoadErrorTitle => '読み込めませんでした';

  @override
  String get storeLoadErrorBody => '通信状況を確認して、もう一度お試しください。';

  @override
  String get storeReload => '再読み込み';

  @override
  String get storeMonthSales => '今月の売上';

  @override
  String storeMonthSalesSub(int orders, String from) {
    return '$orders食（$from〜）';
  }

  @override
  String get storeMonthPayout => '今月のお店の取り分';

  @override
  String get storeMonthStatsLabel => '今月の売上・お店の取り分';

  @override
  String get storeTapToReload => 'タップしてもう一度読み込む';

  @override
  String get storeRatingsLoadFailed => 'お客様の評価を読み込めませんでした';

  @override
  String storeSharePct(String pct) {
    return '取り分 $pct%';
  }

  @override
  String storeRatingsRow(String average) {
    return 'お客様の評価 $average';
  }

  @override
  String storeRatingsSub(int count) {
    return '直近30日・$count件の評価';
  }

  @override
  String get storeRatingsNone => 'まだ評価がありません';

  @override
  String get storeBatchDetailTitle => '出品の詳細';

  @override
  String storeBatchPriceLine(String price, String time) {
    return '$price・販売終了 $time';
  }

  @override
  String get storeStatConfirmed => '回収した数';

  @override
  String get storeStatEstimated => '出せそうな数';

  @override
  String get storeStatReserved => '予約';

  @override
  String get storeStatPickedUp => 'お渡し済み';

  @override
  String get storeStatRemaining => '残り';

  @override
  String get storeStatCollection => '回収';

  @override
  String get storeProgress => '進捗';

  @override
  String get storeStepEstimated => '登録';

  @override
  String storeStepEstimatedDetail(int qty) {
    return '$qty食で登録';
  }

  @override
  String get storeStepCollected => 'ドライバーが引き取り';

  @override
  String storeStepCollectedPlanned(String time) {
    return '$time 予定';
  }

  @override
  String get storeStepCollectedHint => 'ドライバーが到着したら、実数を一緒に確認してください';

  @override
  String storeStepCollectedBy(String name) {
    return 'ドライバー $name';
  }

  @override
  String get storeStepOnSale => '販売中';

  @override
  String storeStepOnSaleUntil(String time) {
    return '〜$time';
  }

  @override
  String storeStepOnSaleDetail(int count) {
    return '$countか所の受取地点で販売';
  }

  @override
  String get storeStepEnded => '終了';

  @override
  String get storeStepEndedDetail => '売れ残りは寄付または廃棄として記録';

  @override
  String get storeStopsRemaining => '受取地点ごとの残り';

  @override
  String get storeAutoUpdate => '自動更新';

  @override
  String storeStopRemaining(int remaining) {
    return '残り $remaining';
  }

  @override
  String storeStopAllocated(int allocated) {
    return '/$allocated食';
  }

  @override
  String get storeEstimatedNote => '回収時に数が予約より少ない場合は、予約の早い順に確保し、残りは自動で返金されます。';

  @override
  String get storeBatchNotFound => 'この出品は見つかりませんでした';

  @override
  String storeTemperature(String celsius) {
    return '$celsius℃';
  }

  @override
  String get storeRegisterTitle => '今日の出品を登録';

  @override
  String get storeRegisterSubtitle => '出せそうな数で登録 — 実際の数はドライバーが引き取るときに数えます';

  @override
  String get storeRequired => '必須';

  @override
  String get storePhotoTake => '料理の写真を撮る';

  @override
  String get storePhotoRetake => '撮り直す';

  @override
  String get storePhotoHint => '店名・ロゴ・人の顔が写らないように撮ってください。';

  @override
  String get storePhotoCamera => 'カメラで撮る';

  @override
  String get storePhotoLibrary => '写真から選ぶ';

  @override
  String get storePhotoRemove => '写真を外す';

  @override
  String storeErrSummary(int count) {
    return '入力内容を確認してください（$countか所）';
  }

  @override
  String get storePhotoCameraDenied => 'カメラを使えません';

  @override
  String get storePhotoCameraDeniedBody =>
      '「設定」でカメラへのアクセスを許可するか、写真を選んでください。入力した内容はそのままです。';

  @override
  String get storePhotoLibraryDenied => '写真を使えません';

  @override
  String get storePhotoLibraryDeniedBody =>
      '「設定」で写真へのアクセスを許可するか、カメラで撮ってください。入力した内容はそのままです。';

  @override
  String get photoReadFailed => '写真を読み込めませんでした';

  @override
  String get photoReadFailedBody => 'もう一度試すか、別の写真を選んでください。入力した内容はそのままです。';

  @override
  String get storeQtyLabel => '用意できそうな数';

  @override
  String get storeQtyUnit => '食';

  @override
  String get storeQtyDecrease => '1食減らす';

  @override
  String get storeQtyIncrease => '1食増やす';

  @override
  String get storePriceLabel => '1食の値段（税込）';

  @override
  String get storePriceHint => '販売終了が近づくと、お客様への販売価格は自動で下がります（30〜70%引き）。';

  @override
  String get storeSellByLabel => '販売終了時刻';

  @override
  String get storeSellByToday => '本日';

  @override
  String get storeSellByTomorrow => '翌日';

  @override
  String get storeSellByChange => '変更';

  @override
  String get storeTimeTitle => '販売の終了時刻';

  @override
  String get storeTimeHint => '数字で入力、または下の時刻から選べます';

  @override
  String get storeTimeDayNote => '本日 / 翌日 は登録画面の選択を使います';

  @override
  String get storeTimeHour => '時';

  @override
  String get storeTimeMinute => '分';

  @override
  String get storeTime24h => '24時間表記（00–23時 / 00–59分）';

  @override
  String get storeTimePresets => 'よく使う時刻';

  @override
  String get storeTimeConfirm => 'この時刻にする';

  @override
  String get storeTimeInvalid => '時は00〜23、分は00〜59で入力してください';

  @override
  String get storeAllergenLabel => 'アレルゲン（28品目）';

  @override
  String get storeAllergenShowAll => 'すべて表示（28品目）';

  @override
  String get storeAllergenHint =>
      '該当するものをすべて選んでください。よく使う12品目を表示しています。どれも含まれない場合は「アレルゲンは含まれていません」にチェックを入れてください。';

  @override
  String get storeNoAllergens => 'アレルゲンは含まれていません';

  @override
  String get storeErrAllergenRequired =>
      'アレルゲンを選ぶか、「アレルゲンは含まれていません」にチェックを入れてください';

  @override
  String storeAllergenSelected(int count) {
    return '$count品目を選択中';
  }

  @override
  String get storeAllergenSheetNote => '選んだ内容は、閉じても登録画面に残ります。';

  @override
  String get storeAllergenMandatory => '表示義務のあるもの（8品目）';

  @override
  String get storeAllergenRecommended => '表示を推奨するもの（20品目）';

  @override
  String get storeAllergenClear => 'すべて解除';

  @override
  String storeAllergenDone(int count) {
    return '決定（$count品目）';
  }

  @override
  String get storeAllergenLoadFailed => 'アレルゲンの一覧を読み込めませんでした。';

  @override
  String get storeIngredientsLabel => '主な原材料と産地';

  @override
  String get storeIngredientAdd => '＋ 原材料を追加';

  @override
  String get storeIngredientName => '原材料';

  @override
  String get storeIngredientOrigin => '産地';

  @override
  String get storeIngredientOriginHint => '例: 国産（鹿児島県）';

  @override
  String storeIngredientRemove(String name) {
    return '$nameを削除';
  }

  @override
  String get storeAdd => '追加';

  @override
  String get storeCancel => 'キャンセル';

  @override
  String get storeReviewButton => '内容を確認する';

  @override
  String get storeConfirmTitle => 'この内容で登録しますか？';

  @override
  String get storeConfirmQty => '数';

  @override
  String storeConfirmQtyValue(int qty) {
    return '$qty食';
  }

  @override
  String get storeConfirmAllergens => 'アレルゲン';

  @override
  String get storeConfirmIngredients => '原材料';

  @override
  String get storeConfirmNone => 'なし';

  @override
  String storeConfirmIngredientsMore(String first, int more) {
    return '$firstほか$more件';
  }

  @override
  String get storeConfirmNote => '登録すると今夜のトラックが引き取りに来て、お客様が予約できるようになります。';

  @override
  String get storeConfirmPreviewTitle => 'お客様にはこう見えます';

  @override
  String storeConfirmPreviewPrice(String price) {
    return '現在の価格 $price';
  }

  @override
  String get storeConfirmPreviewPriceNote => '販売終了が近づくと、さらに下がります';

  @override
  String get storeConfirmEstimate => 'お店の取り分（目安）';

  @override
  String storeConfirmEstimateValue(String amount) {
    return '最大 $amount';
  }

  @override
  String storeConfirmEstimateNote(String pct) {
    return '現在の価格で全部売れた場合の目安です（取り分 $pct%）。値下がりや売れ残りがあると少なくなります。';
  }

  @override
  String get storeConfirmPreviewFailed => '値段を計算できませんでした。登録はこのままできます。';

  @override
  String get storeConfirmSubmit => '登録する';

  @override
  String get storeConfirmBack => '戻って修正する';

  @override
  String storeSellByValue(String day, String time) {
    return '$day $time';
  }

  @override
  String get storeDoneTitle => '登録しました';

  @override
  String get storeDoneBody => '今夜のトラックが引き取りに来ます。予約が入るとお知らせします。';

  @override
  String get storeDoneCollection => '回収予定';

  @override
  String storeDoneCollectionValue(String time) {
    return '$time ごろ';
  }

  @override
  String get storeDoneRoute => '今夜のトラック';

  @override
  String storeDoneRouteMore(String names) {
    return '$namesほか';
  }

  @override
  String get storeDoneViewBatch => '出品を見る';

  @override
  String get storeDoneHome => 'ホームへ';

  @override
  String get storeErrQty => '1食以上にしてください';

  @override
  String get storeErrPrice => '価格は200円以上で入力してください';

  @override
  String get storeErrSellByPast => '販売終了時刻は、現在より後の時刻を選んでください';

  @override
  String get storeErrIngredientName => '原材料名を入力してください';

  @override
  String get storeErrPhotoUpload =>
      '写真をアップロードできませんでした。通信状態を確認して再度お試しいただくか、写真を外して登録してください。（まだ登録されていません）';

  @override
  String get storeErrNotApproved => 'お店の承認が完了していないため、登録できません。';

  @override
  String get storeErrPhotoInvalid => '写真を登録できませんでした。写真を選び直して、もう一度お試しください。';

  @override
  String get storeErrNoTruck =>
      '今夜のトラックがまだ決まっていないため、登録できません。EcoMeal にお問い合わせください。';

  @override
  String get storeErrNoStops =>
      '受取地点がまだ設定されていないため、登録できません。EcoMeal にお問い合わせください。';

  @override
  String get storeErrNoStopsLeft => '今夜のトラックがお店のあとに回る受取地点が残っていないため、登録できません。';

  @override
  String get storeErrTruckDeparted => '今夜のトラックはすでにお店を出発したため、これ以上登録できません。';

  @override
  String get storeErrRegisterFailed => '登録できませんでした。通信状態を確認して、もう一度お試しください。';

  @override
  String get storeErrResultUnknown =>
      '登録できたか確認できませんでした。もう一度「登録する」を押してください。すでに登録されていた場合は、その出品が表示されます（二重に登録されることはありません）。入力した内容は残っています。';

  @override
  String get storeSettlementTitle => '入金';

  @override
  String get storeSettlementSubtitle => '月ごとの売上とお店の取り分';

  @override
  String storeSettlementCurrent(String month) {
    return '$month（集計中）';
  }

  @override
  String get storeSettlementCutoff => '月末にまとめて計算';

  @override
  String storeSettlementEstimate(String amount) {
    return '取り分の見込み $amount';
  }

  @override
  String storeSettlementCurrentSub(String sales, int orders, String pct) {
    return '売上 $sales・$orders食・取り分 $pct%';
  }

  @override
  String get storeSettlementStatements => '入金明細';

  @override
  String get storeSettlementConfirmed => '金額確定';

  @override
  String get storeSettlementPaid => '振込済み';

  @override
  String storeSettlementRowConfirmed(String date, int orders) {
    return '$date 金額確定・$orders食';
  }

  @override
  String storeSettlementRowPaid(String date, int orders) {
    return '$date 振込・$orders食';
  }

  @override
  String get storeSettlementNote =>
      'EcoMeal が月末にまとめて金額を確定します。振込が完了すると、振込日がここに表示されます。';

  @override
  String get storeSettlementEmptyTitle => '入金明細はまだありません';

  @override
  String get storeSettlementEmptyBody => '月末に EcoMeal が金額を確定すると、ここに表示されます。';

  @override
  String get storeNoticeTitle => 'お支払いのお知らせ';

  @override
  String storeNoticeFor(String month) {
    return '$month分';
  }

  @override
  String storeNoticeAddressee(String name) {
    return '$name 御中';
  }

  @override
  String storeNoticeIssued(String date) {
    return '発行: EcoMeal・$date';
  }

  @override
  String get storeNoticeOrders => '販売食数（受取完了）';

  @override
  String storeNoticeOrdersValue(int orders) {
    return '$orders食';
  }

  @override
  String get storeNoticeSales => '売上（税込）';

  @override
  String get storeNoticePayout => 'お支払額';

  @override
  String get storeNoticeConfirmedAt => '金額確定日';

  @override
  String get storeNoticePaidAt => '振込日';

  @override
  String get storeNoticeUnpaid => '未振込（振込後に表示）';

  @override
  String get storeNoticeNumber => '明細番号';

  @override
  String get storeNoticeFootnote =>
      'お店の取り分は、お客様への受け渡しが済んだ注文だけを対象に、注文ごとの割合で計算しています（返金や期限切れの注文は含みません）。';

  @override
  String get storeNoticePrintOnWeb => 'Web で印刷・PDF保存';

  @override
  String get storeRatingsTitle => 'お客様の評価';

  @override
  String get storeRatingsPeriod => '直近30日';

  @override
  String storeRatingsCount(int count) {
    return '$count件の評価';
  }

  @override
  String get storeRatingsRecent => '最近のひとこと';

  @override
  String get storeRatingsAnonymous => '評価したお客様の名前は表示されません。';

  @override
  String get storeRatingsEmptyBody => 'お客様が受け取ったあと、7日以内に星とひとことで評価できます。';

  @override
  String storeRatingStars(int rating) {
    return '★$rating';
  }

  @override
  String get storeInquiryTitle => 'お問い合わせ';

  @override
  String get storeInquirySubtitle => 'EcoMeal へのご連絡';

  @override
  String get storeInquiryLabel => 'お問い合わせ内容';

  @override
  String get storeInquiryHint => 'お返事はご登録のメールアドレスにお送りします。対応の状況は下の一覧で確認できます。';

  @override
  String get storeInquirySend => '送信する';

  @override
  String get storeInquirySent => '送信しました';

  @override
  String get storeInquirySendFailed =>
      '送信できませんでした。通信状態を確認して、もう一度お試しください。入力内容は残っています。';

  @override
  String get storeInquiryEmpty => 'お問い合わせ内容を入力してください';

  @override
  String get storeInquiryHistory => 'これまでのお問い合わせ';

  @override
  String get storeInquiryStatusNew => '受付';

  @override
  String get storeInquiryStatusInProgress => '確認中';

  @override
  String get storeInquiryStatusDone => '対応済み';

  @override
  String get storeInquiryStatusRejected => '対応できませんでした';

  @override
  String get storeInquiryHistoryEmpty => 'まだお問い合わせはありません';

  @override
  String get storeAccountDeletionMessage => 'アカウントの削除を希望します。';

  @override
  String get inboxTitle => 'お知らせ';

  @override
  String get inboxEmptyTitle => 'お知らせはありません';

  @override
  String get inboxEmptyBody => '予約・回収・精算などがあるとここに表示され、通知でもお知らせします。';

  @override
  String get inboxOpen => 'お知らせを開く';

  @override
  String inboxUnread(int count) {
    return '未読 $count件';
  }

  @override
  String get inboxJustNow => 'たった今';

  @override
  String inboxMinutesAgo(int minutes) {
    return '$minutes分前';
  }

  @override
  String inboxYesterday(String time) {
    return '昨日 $time';
  }

  @override
  String get noticeRestaurantReviewedTitle => '審査結果のお知らせ';

  @override
  String get noticeRestaurantReviewedBody => '審査が完了しました。結果をご確認ください。';

  @override
  String get noticeSettlementConfirmedTitle => '入金額が確定しました';

  @override
  String get noticeSettlementConfirmedBody => '入金の画面で金額をご確認ください。';

  @override
  String get noticeSettlementPaidTitle => 'お振込みが完了しました';

  @override
  String get noticeSettlementPaidBody => '入金の画面で振込日をご確認ください。';

  @override
  String get noticeBatchCollectedTitle => '回収が完了しました';

  @override
  String get noticeBatchCollectedBody =>
      'ドライバーが料理を引き取りました。引き取った数は出品の詳細でご確認ください。';

  @override
  String get noticeBatchPhotoRemovedTitle => '料理の写真が削除されました';

  @override
  String get noticeBatchPhotoRemovedBody =>
      'EcoMeal が料理の写真を削除しました。理由はホームでご確認ください。';

  @override
  String get noticeRatingReceivedTitle => '新しい評価が届きました';

  @override
  String get noticeRatingReceivedBody => 'お客様から評価が届きました。';

  @override
  String get noticeGenericTitle => 'お知らせ';

  @override
  String get inboxEmptyBodyCustomer =>
      '予約したフードバッグのトラックが近づいたときや、お気に入りの受取地点に新しいフードバッグが出たときにお知らせします。';

  @override
  String get noticeTruckApproachingTitle => 'Eco-Truckがまもなく到着します';

  @override
  String noticeTruckApproachingBody(String place) {
    return '$placeにまもなく到着します。予約画面のQRコードをご用意ください。';
  }

  @override
  String get noticeTruckApproachingPlace => '受取地点';

  @override
  String get noticeNewBatchTitle => 'お気に入りの受取地点に新着';

  @override
  String noticeNewBatchBody(String place) {
    return '$placeで受け取れるフードバッグが出ました。売り切れる前にご予約ください。';
  }

  @override
  String get noticeNewBatchPlace => 'お気に入りの受取地点';

  @override
  String get noticeIssueResolvedTitle => 'ご報告への対応が完了しました';

  @override
  String get noticeIssueResolvedBody => '対応内容は予約履歴でご確認ください。';

  @override
  String get noticeRefundedTitle => '全額返金のお知らせ';

  @override
  String get noticeRefundedBody =>
      'ご予約のフードバッグをご用意できず、申し訳ありません。お支払いの全額を返金します。カードへの反映時期はカード会社によって異なります。';

  @override
  String get storeSettingsTitle => '設定';

  @override
  String storeSettingsAddress(String address, String time) {
    return '$address・閉店 $time';
  }

  @override
  String get storeSettingsInfoNote => 'お店の情報を変更したい場合は、お問い合わせからご連絡ください。';

  @override
  String get storeSettingsPush => 'アプリの通知';

  @override
  String get storeSettingsPushDenied => '端末の設定で通知がオフになっています';

  @override
  String get storeSettingsRatings => 'お客様の評価';

  @override
  String get storeSettingsInquiry => 'お問い合わせ';

  @override
  String get storeSettingsPrivacy => 'プライバシーポリシー';

  @override
  String get storeSettingsDeleteAccount => 'アカウントの削除を依頼';

  @override
  String storeSettingsVersion(String version) {
    return 'EcoMeal Store $version';
  }

  @override
  String get adminMfaTitle => '2段階認証';

  @override
  String get adminMfaLead => '認証アプリに表示されている6桁のコードを入力してください。';

  @override
  String get adminMfaCodeLabel => '確認コード';

  @override
  String get adminMfaVerify => '確認する';

  @override
  String get adminMfaOtherAccount => '別のアカウントでログイン';

  @override
  String get adminMfaSetupTitle => '2段階認証の設定';

  @override
  String get adminMfaSetupLead => '運営アカウントは2段階認証が必須です。';

  @override
  String get adminMfaSetupStep1 =>
      'この端末で設定する場合: 下の「コピー」でセットアップキーをコピーし、認証アプリ（Google Authenticator など）の「セットアップキーを入力」に貼り付けます。別の端末がある場合は QR コードを読み取っても設定できます。';

  @override
  String get adminMfaSetupKey => 'セットアップキー';

  @override
  String get adminMfaCopy => 'コピー';

  @override
  String get adminMfaCopied => 'セットアップキーをコピーしました';

  @override
  String get adminMfaSetupStep2 => 'アプリに表示された6桁のコードを入力します。';

  @override
  String get adminMfaSetupDone => '設定を完了する';

  @override
  String get adminMfaInvalidCode => '6桁の数字を入力してください';

  @override
  String get adminMfaWrongCode => 'コードが正しくありません。認証アプリに表示されている最新のコードを入力してください';

  @override
  String get adminMfaNetworkChanged =>
      '通信の経路が途中で変わったため確認できませんでした。Wi-Fi かモバイル通信のどちらか一方にして、もう一度お試しください';

  @override
  String get adminMfaFailed => '確認できませんでした。時間をおいて、もう一度お試しください';

  @override
  String get adminTabHome => 'ホーム';

  @override
  String get adminTabOperations => '運行';

  @override
  String get adminTabTasks => '対応';

  @override
  String get adminTabSettings => '設定';

  @override
  String get adminDashboardTitle => 'ダッシュボード';

  @override
  String get adminTonight => '今夜の運行';

  @override
  String get adminRunning => '運行中';

  @override
  String get adminTrucksRunning => '走行中の車両';

  @override
  String get adminStopsDone => '停車地点 完了';

  @override
  String get adminReserved => '予約';

  @override
  String get adminPickedUp => '受取済み';

  @override
  String get adminNoRouteTonight => '今夜の運行予定はありません';

  @override
  String get adminNeedsAction => '対応が必要';

  @override
  String get adminTaskIssues => '未対応の問題報告';

  @override
  String get adminTaskRestaurants => '承認待ちの飲食店';

  @override
  String get adminTaskLicenses => '確認待ちの運転免許';

  @override
  String get adminTaskInquiries => '新しい問い合わせ';

  @override
  String adminTaskLatest(String name, String time) {
    return '最新: $name・$time';
  }

  @override
  String adminTaskIssueLatest(String number, String category, String time) {
    return '$number「$category」・$time';
  }

  @override
  String adminTaskLicenseLatest(String name, String time) {
    return '$name・$time';
  }

  @override
  String adminTaskInquiryTypes(int partner, int other) {
    return 'パートナー申込 $partner・その他 $other';
  }

  @override
  String get adminTaskNone => 'ありません';

  @override
  String adminDateTime(String date, String time) {
    return '$date $time';
  }

  @override
  String get adminSettingsTitle => '設定';

  @override
  String get adminMfaOn => '2段階認証 オン';

  @override
  String get adminNotifications => '通知';

  @override
  String get adminPrefIssues => '問題報告';

  @override
  String get adminPrefRestaurants => '飲食店の申請';

  @override
  String get adminPrefLicenses => '運転免許の提出';

  @override
  String get adminPrefInquiries => '問い合わせ';

  @override
  String get adminPrefSaveFailed => '通知の設定を変更できませんでした';

  @override
  String get adminPushOff => 'この端末の通知がオフです';

  @override
  String get adminPushEnable => '通知をオンにする';

  @override
  String get adminTwoFactor => '2段階認証';

  @override
  String get adminTwoFactorOn => 'オン';

  @override
  String get adminOpenWebAdmin => 'Web 管理画面を開く';

  @override
  String adminVersion(String version) {
    return 'EcoMeal Admin $version（TestFlight）';
  }

  @override
  String get noticeIssueReportedTitle => '新しい問題報告';

  @override
  String get noticeIssueReportedBody => 'お客様から注文の問題報告が届きました。';

  @override
  String get noticeLicenseSubmittedTitle => '免許の確認依頼';

  @override
  String get noticeLicenseSubmittedBody => 'ドライバーから運転免許の確認依頼が届きました。';

  @override
  String get noticeInquiryReceivedTitle => '新しいお問い合わせ';

  @override
  String get noticeInquiryReceivedBody => 'お問い合わせが届きました。';

  @override
  String get noticeRestaurantAppliedTitle => '新しい飲食店の申請';

  @override
  String get noticeRestaurantAppliedBody => '飲食店から参加の申請が届きました。';

  @override
  String get adminTasksTitle => '対応';

  @override
  String get adminTasksSubtitle => '問題報告・審査・免許・問い合わせ';

  @override
  String adminSegIssues(int count) {
    return '問題報告 $count';
  }

  @override
  String adminSegRestaurants(int count) {
    return '審査 $count';
  }

  @override
  String adminSegLicenses(int count) {
    return '免許 $count';
  }

  @override
  String adminSegInquiries(int count) {
    return '問合せ $count';
  }

  @override
  String get adminIssueOpen => '未対応';

  @override
  String get adminIssueResolved => '対応済み';

  @override
  String adminIssueLine(String message, String stop, String price) {
    return '$message（$stop・$price）';
  }

  @override
  String adminIssueMeta(String time, String name) {
    return '$time・お客様 $name';
  }

  @override
  String adminIssueRefunded(String amount) {
    return '$amount を返金・回答済み';
  }

  @override
  String get adminIssueNoRefund => '返金なし・回答済み';

  @override
  String get adminIssuesEmpty => '問題報告はありません';

  @override
  String get adminIssueOrder => '注文';

  @override
  String adminIssueOrderValue(String price) {
    return 'ミステリーバッグ・$price（税込）';
  }

  @override
  String get adminIssuePickup => '受け取り';

  @override
  String get adminIssueRestaurant => '飲食店';

  @override
  String get adminIssueRefundLabel => '返金額';

  @override
  String get adminIssueFull => '全額';

  @override
  String adminIssueRefundHint(String amount) {
    return '返金可能額 $amount まで。0円（返金なし）も選べます。';
  }

  @override
  String get adminIssueNoRefundHint => '返金なし（¥0）。お客様には回答だけが届きます。';

  @override
  String get adminIssueAnswerLabel => 'お客様への回答';

  @override
  String get adminIssueSubmitRefund => '返金して対応済みにする';

  @override
  String get adminIssueSubmitNoRefund => '対応済みにする';

  @override
  String get adminIssueSending => '送信中…';

  @override
  String get adminIssueErrorTitle => '送信できませんでした';

  @override
  String get adminIssueErrorBody =>
      'もう一度お試しください。入力した返金額と回答は残っています。返金はまだ行われていません。';

  @override
  String get adminIssueUnknownTitle => '処理結果を確認できませんでした';

  @override
  String get adminIssueUnknownBody =>
      '通信が途中で切れました。もう一度送信してください。すでに処理されていた場合は、その旨をお知らせします（二重に返金されることはありません）。入力した返金額と回答は残っています。';

  @override
  String get adminIssueRetry => 'もう一度送信する';

  @override
  String adminIssueErrAmount(String amount) {
    return '0〜$amount の金額を入力してください';
  }

  @override
  String get adminIssueErrAnswer => 'お客様への回答を入力してください';

  @override
  String get adminIssueErrAlready => 'この報告はすでに対応済みです';

  @override
  String get adminIssueResolvedToast => '対応済みにしました';

  @override
  String get adminRestTitle => '飲食店の審査';

  @override
  String get adminRestPending => '承認待ち';

  @override
  String get adminRestRejected => '却下済み';

  @override
  String get adminRestApproved => '承認済み';

  @override
  String get adminRestPendingBadge => '審査待ち';

  @override
  String adminRestApplied(String time) {
    return '申請 $time';
  }

  @override
  String get adminRestHasPl => 'PL保険 PDF あり';

  @override
  String get adminRestNoPl => 'PL保険 PDF なし';

  @override
  String get adminRestEmpty => '該当する飲食店はありません';

  @override
  String get adminRestName => '店舗名';

  @override
  String get adminRestAddress => '住所';

  @override
  String get adminRestContact => '連絡先';

  @override
  String get adminRestClosing => '閉店時刻';

  @override
  String get adminRestApplicant => '申請者';

  @override
  String get adminRestPlDoc => 'PL保険の証書';

  @override
  String get adminRestPlOpen => '証書を開く（PDF）';

  @override
  String get adminRestPlFailed => '証書を開けませんでした';

  @override
  String get adminRestReject => '却下する';

  @override
  String get adminRestApprove => '承認する';

  @override
  String get adminRestRejectTitle => '却下の理由';

  @override
  String get adminRestRejectNote => '理由は申請者にメールとアプリで通知されます（必須・500文字まで）。';

  @override
  String get adminRestReasonPl => 'PL保険の証書が読み取れない・期限切れ';

  @override
  String get adminRestReasonContact => '住所・連絡先が確認できない';

  @override
  String get adminRestReasonOther => 'その他';

  @override
  String get adminRestRejectSend => '却下を通知する';

  @override
  String get adminRestErrReason => '理由を入力してください（500文字まで）';

  @override
  String adminRestDecided(String name, String decision) {
    return '$nameを$decisionにしました';
  }

  @override
  String get adminRestNotifyFailed =>
      '審査は確定しましたが、通知メールを送れませんでした。Web 管理画面から再送してください。';

  @override
  String get adminRestRejectionReason => '却下の理由';

  @override
  String get adminLicTitle => '免許の確認';

  @override
  String adminLicSubmitted(String time) {
    return '運転免許・提出 $time';
  }

  @override
  String get adminLicEmpty => '確認待ちの運転免許はありません';

  @override
  String get adminLicImageFailed => '画像を読み込めませんでした';

  @override
  String get adminLicZoom => '拡大';

  @override
  String get adminLicTruck => '担当予定';

  @override
  String get adminLicNoTruck => 'なし';

  @override
  String get adminLicExpiry => '有効期限（画像を見て入力）';

  @override
  String get adminLicExpiryPick => '日付を選ぶ';

  @override
  String get adminLicVerifyNote => '確認済みにすると、シフトに入れられるようになります。';

  @override
  String get adminLicReject => '差し戻す';

  @override
  String get adminLicVerify => '確認済みにする';

  @override
  String get adminLicRejectTitle => '差し戻しの理由';

  @override
  String get adminLicErrExpiry => '有効期限（今日以降）を選んでください';

  @override
  String adminLicDone(String name) {
    return '$nameさんの免許を確認しました';
  }

  @override
  String get adminInqTitle => '問い合わせ';

  @override
  String get adminInqNew => '新着';

  @override
  String get adminInqInProgress => '対応中';

  @override
  String get adminInqDone => '完了';

  @override
  String get adminInqTypePartner => 'パートナー申込';

  @override
  String get adminInqTypeDriver => 'ドライバー参加相談';

  @override
  String get adminInqTypeContact => 'お問い合わせ';

  @override
  String get adminInqStatusNew => '新着';

  @override
  String get adminInqStatusInProgress => '対応中';

  @override
  String get adminInqStatusDone => '対応済み';

  @override
  String get adminInqStatusRejected => '見送り';

  @override
  String get adminInqEmpty => '該当する問い合わせはありません';

  @override
  String get adminInqInviteOnWeb => 'アカウントの発行（招待）は Web 管理画面で行います。';

  @override
  String get adminInqStatusLabel => '状態';

  @override
  String get adminInqNoteLabel => '運営メモ（社内用）';

  @override
  String get adminInqSave => '保存する';

  @override
  String get adminInqSaved => '保存しました';

  @override
  String get adminInqRetrySave => 'もう一度保存する';

  @override
  String get adminInqErrorTitle => '保存できませんでした';

  @override
  String get adminInqErrorBody => '通信状況を確認して、もう一度お試しください。入力した状態とメモは残っています。';

  @override
  String get adminLicRetryVerify => 'もう一度確認済みにする';

  @override
  String get adminLicErrorBody => '通信状況を確認して、もう一度お試しください。入力した有効期限は残っています。';

  @override
  String get adminRestRetryApprove => 'もう一度承認する';

  @override
  String get adminRestRetryReject => 'もう一度却下を通知する';

  @override
  String get adminRestErrorBody => '通信状況を確認して、もう一度お試しください。審査はまだ確定していません。';

  @override
  String get adminRestRejectErrorBody =>
      '通信状況を確認して、もう一度お試しください。却下はまだ確定していません。選んだ理由はそのまま再送できます。';

  @override
  String get adminSaveFailed => '保存できませんでした。通信状況を確認して、もう一度お試しください。';

  @override
  String get adminOpsTitle => '運行モニタ';

  @override
  String adminOpsSubtitle(String date, int count) {
    return '$date・$count台';
  }

  @override
  String adminOpsStale(String time) {
    return '更新できません · $time 時点';
  }

  @override
  String adminOpsUpdatedAt(String time) {
    return '$time 更新（20秒ごと）';
  }

  @override
  String get adminOpsTrucks => '今夜の車両';

  @override
  String get adminPickIssue => '問題報告を選んでください';

  @override
  String get adminPickRestaurant => '飲食店を選んでください';

  @override
  String get adminPickLicense => '運転免許を選んでください';

  @override
  String get adminPickInquiry => '問い合わせを選んでください';

  @override
  String get adminPickDriverReport => '運行の連絡を選んで対応してください';

  @override
  String get adminPickBody => '左の一覧から選ぶと、ここに詳細が表示されます。';

  @override
  String adminOpsShowing(int count) {
    return '$count台を表示中';
  }

  @override
  String get adminOpsRunning => '走行中';

  @override
  String get adminOpsWaiting => '待機';

  @override
  String get adminOpsDone => '完了';

  @override
  String adminOpsNext(String driver, String stop) {
    return '$driver・次: $stop';
  }

  @override
  String get adminGpsJustNow => '位置 1分以内';

  @override
  String adminGpsMinutes(int minutes) {
    return '位置 $minutes分前';
  }

  @override
  String adminGpsStale(int minutes) {
    return '位置 $minutes分前・更新が止まっています';
  }

  @override
  String get adminGpsNone => '位置はまだ届いていません';

  @override
  String get adminOpsEta => '到着予定';

  @override
  String adminOpsReserved(int count) {
    return '予約 $count件';
  }

  @override
  String get adminOpsNoDriver => 'ドライバー未定';

  @override
  String get adminOpsMapUnavailable => '地図を表示できません（地図の設定が完了していません）';

  @override
  String get noticeReservationReceivedTitle => '新しい予約が入りました';

  @override
  String noticeReservationReceivedBody(String time, int count, int total) {
    return '販売期限 $time の出品に予約が$count件入りました。合計$total件です。';
  }

  @override
  String get noticeReservationReceivedFallback => 'アプリで予約数をご確認ください。';

  @override
  String get storeSettingsContract => '提携契約について';

  @override
  String get storeContractBody =>
      'お店のご利用条件（取り分・入金・振込・食品の取り扱いなど）は、EcoMeal と結んだ提携契約に記載されています。お客様向けの利用規約はお店には適用されません。契約の確認や変更のご相談は、お問い合わせからご連絡ください。';

  @override
  String get storeContractInquiry => 'お問い合わせ';

  @override
  String adminRestApproveConfirmTitle(String name) {
    return '$nameを承認しますか？';
  }

  @override
  String get adminRestApproveConfirmBody =>
      '承認すると、店舗アプリで余剰の登録ができるようになり、店舗担当者に通知メールが届きます。';

  @override
  String get adminRestMembers => '担当者';

  @override
  String get adminRestOwner => 'オーナー';

  @override
  String get adminRestStaff => 'スタッフ';

  @override
  String get adminRestNoMembers => '担当者が登録されていません';

  @override
  String get adminRestMonth => '今月の売上';

  @override
  String get adminRestSales => '売上';

  @override
  String get adminRestPayout => '還元額';

  @override
  String get adminRestSold => '販売食数';

  @override
  String get adminRestShare => '還元率';

  @override
  String adminRestSharePct(String pct) {
    return '$pct%';
  }

  @override
  String get adminRestRatings => 'お客様の評価（直近30日）';

  @override
  String adminRestRatingsValue(String average, int count) {
    return '★$average（$count件）';
  }

  @override
  String get adminRestNoRatings => 'まだ評価はありません';

  @override
  String get adminRestBatches => '最近の出品';

  @override
  String get adminRestNoBatches => 'まだ出品はありません';

  @override
  String adminRestBatchLine(int qty, String price) {
    return '$qty食 × $price';
  }

  @override
  String get adminRestBatchConfirmed => '確定';

  @override
  String get adminRestBatchEstimated => '概算';

  @override
  String get adminRestSettlements => '精算';

  @override
  String get adminRestNoSettlements => '確定した精算はまだありません';

  @override
  String get adminRestSettlementConfirmed => '確定済み';

  @override
  String adminLicVerifyConfirmTitle(String name) {
    return '$nameさんの免許を確認済みにしますか？';
  }

  @override
  String adminLicVerifyConfirmBody(String date) {
    return '有効期限 $date で登録し、このドライバーをシフトに入れられるようになります。';
  }

  @override
  String adminIssueConfirmRefundTitle(String amount) {
    return '$amountを返金しますか？';
  }

  @override
  String adminIssueConfirmRefundBody(
    String order,
    String restaurant,
    String amount,
  ) {
    return '$order（$restaurant）のお客様の支払い方法に$amountを返金し、回答を送ります。返金は取り消せません。';
  }

  @override
  String get adminIssueConfirmNoRefundTitle => '返金なしで対応済みにしますか？';

  @override
  String adminIssueConfirmNoRefundBody(String order, String restaurant) {
    return '$order（$restaurant）のお客様に回答だけを送ります。あとから返金はできません。';
  }

  @override
  String get adminMfaLostDevice =>
      'スマートフォンを紛失した・認証アプリを削除した場合は、ログインできません。EcoMeal の別の管理者に2段階認証の解除を依頼してください。';

  @override
  String get adminIssueConfirmRefundAction => '返金する';

  @override
  String get activeOrderOpen => '受け取りの案内を開く';

  @override
  String get activeOrderTitle => '受け取りの案内';

  @override
  String get activeOrderPlace => '受取地点';

  @override
  String get activeOrderTime => '受取時間';

  @override
  String activeOrderBefore(String time, int minutes) {
    return '到着予定 $time・あと$minutes分';
  }

  @override
  String activeOrderWindow(String end) {
    return '受取地点に停車している時間です（$endまで）';
  }

  @override
  String get activeOrderOver =>
      'この受取地点での停車は終了しました。受け取れなかった場合は、予約履歴の「問題を報告」またはお問い合わせからご連絡ください。';

  @override
  String get activeOrderFindTitle => 'トラックの見つけ方';

  @override
  String get activeOrderFindBody =>
      '受取地点に停車している Eco-Truck（車体に EcoMeal のロゴ）で、このQRコードを見せてください。読み取れないときは、上の確認コードをお伝えください。トラックの位置と到着予定は、ホームの地図でも確認できます。';

  @override
  String get activeOrderPickedUp => '受け取りました';

  @override
  String get activeOrderEndedStatus => 'この予約は受け取れません';

  @override
  String get activeOrderEndedCancelledTitle => 'この予約はキャンセルされました';

  @override
  String get activeOrderEndedCancelledBody => '返金の有無は予約履歴でご確認ください。';

  @override
  String get activeOrderEndedExpiredTitle => 'この予約は失効しました';

  @override
  String get activeOrderEndedExpiredBody =>
      '受取地点の出発時刻までに受け取られなかったため、返金はありません。受け取れなかった事情がある場合は、予約履歴の「問題を報告」からご連絡ください。';

  @override
  String get activeOrderEndedBack => '予約履歴を見る';

  @override
  String get pickupCompleteTitle => '受け取り完了';

  @override
  String get pickupCompleteBody => 'ご利用ありがとうございました。';

  @override
  String get leftoverAutoRecordNote =>
      '寄付しなかった分は、最後の販売地点を出発してから1時間後に「売れ残り（廃棄）」として自動で記録されます。寄付する場合は、それまでに記録してください。';

  @override
  String get driverReportTitle => '運営に連絡';

  @override
  String get driverReportLead =>
      '送ると運営に通知が届き、影響のある予約のお客様には運営から連絡します。安全に関わる急ぎのときは、まず安全な場所に停車してください。';

  @override
  String get driverReportDelay => '到着が遅れそう（次の停車地）';

  @override
  String get driverReportVehicle => '車両のトラブル（故障・事故）';

  @override
  String get driverReportFood => '料理・温度の問題（受け取りを断った など）';

  @override
  String get driverReportOther => 'その他';

  @override
  String driverReportMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get driverReportMinutesMax => '30分以上';

  @override
  String get driverReportMessageHint => '状況をひとこと（任意。「その他」は必須）';

  @override
  String get driverReportSend => '運営に送信する';

  @override
  String get driverReportSent => '運営に送信しました。運営からの連絡を待つあいだも、安全に運行してください。';

  @override
  String get driverReportSelect => '連絡の種類を選んでください';

  @override
  String get driverReportNeedMessage => '「その他」は、状況をひとこと入力してください';

  @override
  String get driverReportNoRoute => '今夜の運行がないため、送れません';

  @override
  String get driverReportDuplicate => '同じ種類の連絡を送ったばかりです。1分ほど待ってから送ってください';

  @override
  String get driverReportError => '送れませんでした。電波の良い場所でもう一度お試しください';

  @override
  String get adminTaskDriverReports => '未対応の運行の連絡';

  @override
  String adminTaskDriverReportLatest(
    String plate,
    String category,
    String time,
  ) {
    return '$plate「$category」・$time';
  }

  @override
  String adminSegDriverReports(int count) {
    return '運行の連絡 $count';
  }

  @override
  String get adminDriverReportsEmpty => 'ドライバーからの連絡はありません';

  @override
  String adminDriverReportMeta(String time, String driver, String stop) {
    return '$time・$driver・次の停車 $stop';
  }

  @override
  String get adminDriverReportNoStop => 'なし（運行終了）';

  @override
  String get adminDriverReportResolveTitle => '対応済みにする';

  @override
  String get adminDriverReportResolveNote =>
      '行ったこと（お客様への連絡など）を残します。お客様への連絡は自動では送られません。';

  @override
  String get adminDriverReportResolveSend => '対応済みにする';

  @override
  String get adminDriverReportDone => '対応済みにしました';

  @override
  String get adminDriverReportAlready => '別の担当者がすでに対応済みにしました';

  @override
  String get adminDriverReportError => '対応済みにできませんでした。もう一度お試しください';

  @override
  String get noticeDriverReportedTitle => 'ドライバーから連絡';

  @override
  String get noticeDriverReportedBody => '運行中のドライバーから遅れ・トラブルの連絡が届きました。';

  @override
  String get driverReportShort => '運営に連絡';

  @override
  String get driverProgressTitle => '今夜の進捗';

  @override
  String driverProgressCount(int done, int total) {
    return '$totalか所中 $doneか所 完了';
  }

  @override
  String driverProgressPickup(int done, int total) {
    return '集荷 $done/$total';
  }

  @override
  String driverProgressSales(int done, int total) {
    return '販売 $done/$total';
  }

  @override
  String get nextTaskLabel => '次にやること';

  @override
  String stepBadgePickup(int number) {
    return '$numberか所目・集荷';
  }

  @override
  String stepBadgeSales(int number) {
    return '$numberか所目・販売';
  }

  @override
  String nextTaskPickupTitle(String name) {
    return '$name で料理を受け取る';
  }

  @override
  String nextTaskSalesTitle(String name) {
    return '$name でお客様にお渡しする';
  }

  @override
  String get arriveByLabel => '到着予定';

  @override
  String get timeLeftLabel => 'あと';

  @override
  String get pickupAmountLabel => '受け取る量';

  @override
  String get handoutAmountLabel => 'お渡しする数';

  @override
  String approxMeals(int qty) {
    return '約$qty食';
  }

  @override
  String get nothingToPickUp => 'ここで受け取る料理はもうありません';

  @override
  String nextTaskPickupDetail(int count, String time) {
    return '受け取る料理 $count品 ・ お店の販売終了 $time';
  }

  @override
  String nextTaskSalesDetail(int count) {
    return '予約 $count件は受け取りQRを読み取ってお渡しします';
  }

  @override
  String get navigateButton => 'ナビを開く';

  @override
  String get arrivedPickupButton => '到着・受け取り';

  @override
  String get arrivedSalesButton => '到着・お渡し';

  @override
  String get navigationFailed => '地図アプリを開けませんでした';

  @override
  String get allStopsDoneTitle => 'すべての地点を回りました';

  @override
  String get allStopsDoneBody => '売れ残りがあれば「終了」タブで寄付を記録できます。';

  @override
  String get routePhasePickup => '① お店で受け取る（集荷）';

  @override
  String get routePhaseSales => '② お客様にお渡し（販売）';

  @override
  String placesCount(int count) {
    return '$countか所';
  }

  @override
  String stopPickupPending(int qty) {
    return '約$qty食を受け取る';
  }

  @override
  String stopPickupDone(int qty) {
    return '受け取り済み・$qty食';
  }

  @override
  String stopSalesLoad(int reserved, int total) {
    return '予約 $reserved件 ・ 合計 $total食';
  }

  @override
  String pickupStopSubtitle(int index, int total, String time) {
    return '集荷 $index/$total ・ $time 着く予定';
  }

  @override
  String get addressLabel => '住所';

  @override
  String get copyAddressButton => '住所をコピー';

  @override
  String get addressCopied => '住所をコピーしました';

  @override
  String foodsToPickUp(int count) {
    return '受け取る料理（$count品）';
  }

  @override
  String get shopPlannedQty => '（お店の予定）';

  @override
  String shopSellByLabel(String time) {
    return 'お店の販売終了 $time';
  }

  @override
  String get pickUpThisFood => 'この料理を受け取る';

  @override
  String pickedUpChip(int qty) {
    return '受け取り済み・$qty食';
  }

  @override
  String get pickupStepsTitle => '受け取りの流れ';

  @override
  String get pickupStep1 => '数を数える（お店の予定と違っても大丈夫。実際の数を入れます）';

  @override
  String get pickupStep2 => '中心温度を測る（冷蔵品は10℃以下）';

  @override
  String get pickupStep3 => '「受け取りを確定」を押すと、配分先の停車地点と数が決まります';

  @override
  String pickupDoneTitle(int qty) {
    return '$qty食を積みました';
  }

  @override
  String pickupDoneSubtitle(String name, String temp) {
    return '$name ・ 中心温度 $temp℃';
  }

  @override
  String get securedReservations => '確保した予約';

  @override
  String get refundedReservations => '返金した予約';

  @override
  String get dropsTitle => 'この料理の配分先';

  @override
  String dropSubtitle(String time, int count) {
    return '$time ・ うち予約 $count件';
  }

  @override
  String get allPickupsDoneHint => '集荷はすべて終わりました。料理が冷えたままか確認して出発してください。';

  @override
  String get morePickupsHint => '次のお店へ向かってください。';

  @override
  String get moreFoodHereHint => 'このお店にまだ受け取る料理があります。';

  @override
  String get backToHome => 'ホームへ';

  @override
  String get handoutHereTitle => 'この地点でお渡しするもの';

  @override
  String totalMeals(int qty) {
    return '合計 $qty食';
  }

  @override
  String get reservedCustomers => '予約のお客様';

  @override
  String get walkupSellable => '予約なしで販売できる';

  @override
  String get scanQrToHand => 'QRを読み取ってお渡し';

  @override
  String get registerOnSpot => 'その場で販売を登録';

  @override
  String get perFoodLabel => '料理ごとの数';

  @override
  String batchCapacityRow(int capacity, int remaining) {
    return '$capacity食（予約なしの残り $remaining食）';
  }

  @override
  String get handoutStepsTitle => 'この地点での流れ';

  @override
  String get handoutStep1 => '予約のお客様: 受け取りQRを読み取る（読めないときは4桁のコード）';

  @override
  String get handoutStep2 => '予約のないお客様: 「予約なし販売」タブで1食ずつ登録';

  @override
  String get handoutStep3 => '終わったら「停車地点を出発」→ 次の地点へ';

  @override
  String get walkupUnknownTitle => '販売を登録できたか確認できませんでした';

  @override
  String get walkupUnknownBody =>
      '通信が切れました。もう一度「販売を登録」を押すと、同じ販売として送り直します（二重には登録されません）。登録済みだった場合は「前回の販売は登録済みでした」と出ます。';

  @override
  String walkupReplayedToast(int price) {
    return '前回の販売は登録済みでした（¥$price）';
  }

  @override
  String get donationUnknownTitle => '寄付を記録できたか確認できませんでした';

  @override
  String get donationUnknownBody =>
      '通信が切れました。入力はそのまま残しています。もう一度「寄付を記録する」を押しても二重には記録されません。記録済みだった場合は「この寄付は記録済みでした」と出ます。';

  @override
  String donationReplayed(int remaining) {
    return 'この寄付は記録済みでした（この料理の残り $remaining食）';
  }

  @override
  String donationBatchOptionEmpty(String name) {
    return '$name（残りなし）';
  }

  @override
  String donationQtyOverRemaining(int remaining) {
    return '残りは $remaining食です。$remaining食以下で入力してください';
  }

  @override
  String get gpsPermissionTitle => '位置情報がオフになっています';

  @override
  String get gpsPermissionBody =>
      '車の位置がお客様と運営に届きません。設定で位置情報の利用を許可してください（「アプリの使用中のみ」で使えます）。';

  @override
  String get gpsServiceOffTitle => '端末の位置情報サービスがオフです';

  @override
  String get gpsServiceOffBody => '設定 → プライバシーとセキュリティ → 位置情報サービス をオンにしてください。';

  @override
  String get gpsNotSentTitle => '位置を送れていません';

  @override
  String get gpsNotSentBody => '通信が戻ると自動で送ります。最後に送った位置を表示しています。';

  @override
  String get cameraUnavailableTitle => 'カメラを使えません';

  @override
  String get cameraUnavailableBody =>
      '設定でカメラの利用を許可してください。読み取れないときは、お客様の画面の4桁のコードでも受け渡しできます。';

  @override
  String get enterCodeManually => 'コードを手動で入力';

  @override
  String get routeMapOpen => '地図を大きく表示';

  @override
  String get routeMapTitle => 'ルートの地図';

  @override
  String routeMapSubtitle(int total, int next) {
    return '$totalか所 ・ $nextか所目へ向かっています';
  }

  @override
  String routeMapAllDone(int total) {
    return '$totalか所 ・ すべて完了';
  }

  @override
  String get routeMapFitAll => '全体';

  @override
  String get routeMapMyLocation => '現在地';

  @override
  String get routeMapLegend => '点線は回る順番の目安です（実際の道ではありません）';

  @override
  String get routeMapSelectedStop => '選んだ地点';

  @override
  String get routeMapOpenStop => 'この地点を開く';

  @override
  String get routeMapListHint => '上に引くと全地点を表示（① お店で受け取る・② お客様にお渡し）';

  @override
  String get routeMapRoadLoading => 'ルートを読み込んでいます…';

  @override
  String routeMapRoadLegend(int count, int minutes, String km) {
    return '道に沿ったルート ・ 残り$countか所 約$minutes分（${km}km）';
  }

  @override
  String get routeMapRoadFailed => 'ルートを読み込めませんでした（点線は順番の目安）';

  @override
  String get routeMapRoadRetry => 'もう一度';

  @override
  String get roadTimeLeftLabel => '道のりで あと';
}
