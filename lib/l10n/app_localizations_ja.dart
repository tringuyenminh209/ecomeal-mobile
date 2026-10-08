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
  String get webOnlyAccountTitle => 'このアカウントはアプリでは利用できません';

  @override
  String get webOnlyAccountBody =>
      '飲食店・EcoMeal運営のアカウントは、パソコンのWeb管理画面からご利用ください。';

  @override
  String get openWebAdmin => 'Web管理画面を開く';

  @override
  String get errorOpenWebAdmin => 'Web管理画面を開けませんでした';

  @override
  String get errorProfileLoadFailed => 'プロフィール情報の取得に失敗しました。もう一度お試しください';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'ドライバー';

  @override
  String get switchLanguageLabel => 'English';

  @override
  String get driverLoginLead => 'EcoMeal から発行されたドライバー用アカウントでログインしてください。';

  @override
  String get driverAccountIssuedNote =>
      'アカウントは運営から発行されます。招待メールのリンクでパスワードを設定してからログインしてください。';

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
  String get driverSuspendedTitle => '稼働が停止されています';

  @override
  String get driverSuspendedBody =>
      'このアカウントは現在シフトに入れない状態です。理由と再開の手続きは EcoMeal 運営にお問い合わせください。';

  @override
  String get selectLanguage => '言語を選択 / Select language';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get englishLanguage => 'English';

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
  String get onboardingLead => '街のレストランから生まれるおいしい余剰を、Eco-Truckがあなたの近くへ届けます。';

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
  String get errorLoadRetry => 'データの取得に失敗しました。再試行';

  @override
  String get errorLoadTitle => 'データの取得に失敗しました。';

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
  String get truckTapHint => '地図のトラックか、このカードをタップすると停車予定とメニューを表示します';

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
  String get originUnknown => '産地不明';

  @override
  String get detailNote => '内容は受け取りまでのお楽しみです。写真はイメージです。アレルギーをお持ちの方は表示をご確認ください。';

  @override
  String get dailyLimitReached => '本日の予約上限（2件）に達しています';

  @override
  String get reserveButton => '予約する';

  @override
  String get mapSetupRequired => '地図を表示できません。下の一覧はご覧いただけます。';

  @override
  String get openLocationSettings => '位置情報の設定';

  @override
  String get batchExpired => '販売期限を過ぎました。別のフードバッグをお選びください。';

  @override
  String get reservationCountFailed => '予約件数を確認できませんでした。再試行してください。';

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
  String get addPaymentMethodButton => '支払い方法を追加してください';

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
    return '受取場所：$place';
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
      'カード会社が決済を承認しませんでした。\n別のカードを選ぶか、カード会社へご確認ください。';

  @override
  String get paymentCardExpiredBody => 'カードの有効期限が切れています。\n別のカードを選んでください。';

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
      '通信が途切れたため、支払い状況を確認しています。\n重複を防ぐため、再度支払わないでください。';

  @override
  String get paymentUnknownNote => '支払い・予約状況は確認中です。\n接続を確認してから結果を取得してください。';

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
  String get paymentProviderNote => '支払い情報は認定決済プロバイダーによって安全に処理されます。';

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
      'カード情報は暗号化され、決済プロバイダーによって安全に管理されます。\nデフォルトカードを設定すると、ワンタップで支払えます。';

  @override
  String get setDefaultCard => 'デフォルトのカードに設定';

  @override
  String get deleteCard => 'このカードを削除';

  @override
  String get deleteCardTitle => 'このカードを削除しますか？';

  @override
  String deleteCardBody(String card) {
    return '$card を削除します。削除すると、このカードは次回以降の注文に使えなくなります。';
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
  String get cardHolderHint => 'カード名義人';

  @override
  String get cardExpiryLabel => '有効期限';

  @override
  String get cardExpiryHint => 'MM / YY';

  @override
  String get cardCvcLabel => 'セキュリティコード';

  @override
  String get cardCvcHint => 'CVC';

  @override
  String get cardTokenNote => 'カード情報は安全にトークン化されます。CVCは他人に知らせないでください。';

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
      'テスト中のため実際の請求は発生しません。テスト用カード 4242 4242 4242 4242 をお使いください（0002で終わるカードは決済が拒否されます）。';

  @override
  String paymentMethodRowDefault(String card) {
    return '$card ・ デフォルト';
  }

  @override
  String get paymentMethodRowNone => '未登録';

  @override
  String get freeCancelTitle => '受取予定の30分前まで無料キャンセル';

  @override
  String get freeCancelBody => '受取予定の30分前まで無料キャンセルできます。キャンセルは予約履歴から行えます。';

  @override
  String get errorReservationFailed =>
      '予約できませんでした。売り切れた可能性があります。別のフードバッグをお選びください';

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
  String get cancelDialogFree => '受取予定の30分前まで無料キャンセルできます。現在の状況では全額返金されます。';

  @override
  String get cancelDialogNoRefund => '受取予定の30分前を過ぎているため、キャンセルしても返金されません。';

  @override
  String get back => '戻る';

  @override
  String get cancelConfirmButton => 'キャンセルする';

  @override
  String cancelledWithRefund(int amount) {
    return 'キャンセルしました（¥$amountを返金）';
  }

  @override
  String get cancelledNoRefund => 'キャンセルしました（返金なし）';

  @override
  String get errorCancelFailed => 'キャンセルに失敗しました。もう一度お試しください';

  @override
  String orderNumber(String number) {
    return '注文 $number';
  }

  @override
  String get pendingExplanation =>
      '注文内容の数量を配送員が確認中です。数量不足の場合は、各受け取りポイントの順番（FIFO）に従って分配します。分配されなかった数量については、自動で返金処理を行います。';

  @override
  String allocatedExplanation(String stopName) {
    return '$stopNameで1袋を確保しました。受け取り時はQRコードを提示し、読み取れない場合は下記コードを伝えてください。';
  }

  @override
  String get freeCancelExpired => '無料キャンセル期限を過ぎています（返金なし）';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String manualCodeLabel(String code) {
    return '手動入力：$code';
  }

  @override
  String get pickupQrTitle => '受け取りQR';

  @override
  String get pickupQrCaption => '受け取り時にQRコードを読み取ってもらうか、コードを入力してもらってください。';

  @override
  String get refundFullBadge => '全額返金されます';

  @override
  String get refundFullNote => '現在の予約状況では、キャンセル後に全額返金されます。';

  @override
  String get refundNoneBadge => '返金なし';

  @override
  String get refundNoneNote => '受取予定の30分前を過ぎているため、キャンセル後の返金はありません。';

  @override
  String get errorBadge => 'エラー';

  @override
  String get browseBatches => '近くのフードバッグを見る';

  @override
  String totalWithQuantity(int quantity) {
    return '合計（数量 $quantity）';
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
  String get nameKanaHint => '例：ハルカ ミカ';

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
  String get errorBatchAlreadyConfirmed => 'このロットは既に確定済みです';

  @override
  String get errorStopNotOnRoute => '指定された停車地点はこのロットの巡回ルート上に存在しません';

  @override
  String get errorStopClosed => 'この停車地点は既にクローズされています';

  @override
  String get errorTemperatureRange => '温度は-30〜99.9℃の範囲で入力してください';

  @override
  String get errorConfirmFailed => '確定登録に失敗しました。もう一度お試しください';

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
  String get coldChainNotice => '冷蔵品は10°C以下を確認してください。基準外の場合は運営へ連絡します。';

  @override
  String get coldChainOverLimit => '基準（10℃以下）を超えています。このロットは回収・販売できません。';

  @override
  String get distributionStopsLabel => '配分先の停車地';

  @override
  String get distributionStopsHint => '現在のルートの停車地を選択してください。選択した停車地に分配されます。';

  @override
  String get noDistributableStops => '配分できる停車地がありません（全て出発済み）';

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
    return '選択した停車地（$count箇所）に分配されます。';
  }

  @override
  String confirmPickupButton(String qty) {
    return '$qty食の受け取りを確定';
  }

  @override
  String pickupConfirmedToast(int qty, int allocated, int refunded) {
    return '$qty食の受け取りを確定しました（予約$allocated件確保・$refunded件返金）';
  }

  @override
  String get rejectPickupButton => '回収しない（温度基準外）';

  @override
  String get rejectPickupDialogTitle => 'このロットを回収しませんか？';

  @override
  String rejectPickupDialogBody(String celsius) {
    return '芯温が$celsius℃で、基準（10℃以下）を超えています。このロットは販売せず、予約はすべて返金されてお客様に通知されます。温度の記録は残ります。';
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
  String get noPendingPickup => 'この店舗の未確定の集荷はありません';

  @override
  String get selectBatchToPickUp => '集荷するロットを選択';

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
  String get allStopsCompleted => '全停車地点を完了';

  @override
  String get reservedOrdersLabel => '予約注文';

  @override
  String get reservedOrdersCaption => '未完了の停車地点の合計';

  @override
  String get stopDonePickup => '完了 • 集荷済み';

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
  String stopCount(int count) {
    return '$countつの停車地点';
  }

  @override
  String get routeDone => '完了';

  @override
  String get routeInProgress => '運行中';

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
  String get driverTabPickup => '受取';

  @override
  String get driverTabSales => '販売';

  @override
  String get driverTabEnd => '終了';

  @override
  String get noPickupsTonight => '今夜の集荷予定はありません';

  @override
  String get gpsSending => 'GPS送信中';

  @override
  String get driverAccountSubtitle => 'ドライバーアカウント';

  @override
  String get errorNotHandoverable => 'この予約は受け渡し確認できる状態ではありません';

  @override
  String get errorWalkupSoldOut => 'この停車地点のWalk-up在庫は売り切れです';

  @override
  String get errorWalkupNotConfirmed => '確定登録前のロットではWalk-up販売できません';

  @override
  String get errorBatchExpired => 'このロットは販売終了時刻を過ぎています';

  @override
  String get errorDonationExceedsStock => '寄付数量が残り在庫を超えています';

  @override
  String get errorDonationNotConfirmed => '確定登録前のロットは寄付記録できません';

  @override
  String get errorDonationStopsOpen => '未出発の販売地点があるため、まだ寄付を記録できません';

  @override
  String get errorDonationNoteRequired => '寄付先を入力してください';

  @override
  String get errorNotAssignedDriver => 'このトラックの担当ドライバーではありません';

  @override
  String get errorGeneric => '処理に失敗しました。もう一度お試しください';

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
    return 'Walk-up販売を登録しました（¥$price）';
  }

  @override
  String get departDialogTitle => '停車地点を出発しますか？';

  @override
  String currentStop(String name) {
    return '現在の停車地点：$name';
  }

  @override
  String departWarning(int count) {
    return '$count件の予約が引き渡し待ちです。出発すると、これらの予約は「no-show / 失効」として扱われ、返金対象外になります。';
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
  String get batchLabel => 'ロット';

  @override
  String get noWalkupBatches => 'この停車地点で販売できるロットはありません';

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
  String get routeSummaryTitle => '運行サマリー';

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
  String donationBatchOption(String name, int qty) {
    return '$name（確定 $qty食）';
  }

  @override
  String donationRecorded(int remaining) {
    return '寄付を記録しました（このロットの残り $remaining食）';
  }

  @override
  String get donationTitle => '未販売分の寄付記録';

  @override
  String get donationLockedNotice =>
      '全ての販売地点を出発した後に寄付を記録できます（出発後は販売できなくなるため、在庫が確定します）。';

  @override
  String get noConfirmedBatches => '確定済みのロットがありません';

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
  String get licensePrivacyNote => '画像は運営だけが見られます。';

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
  String get upcomingShiftsEmpty => '予定されたシフトはありません。運営がシフトを入れると、ここに表示されます。';

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
}
