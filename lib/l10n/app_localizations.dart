import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @loginTab.
  ///
  /// In ja, this message translates to:
  /// **'ログイン'**
  String get loginTab;

  /// No description provided for @signupTab.
  ///
  /// In ja, this message translates to:
  /// **'新規登録'**
  String get signupTab;

  /// No description provided for @emailLabel.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレス'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get passwordLabel;

  /// No description provided for @errorEmailRequired.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスを入力してください'**
  String get errorEmailRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを入力してください'**
  String get errorPasswordRequired;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスの確認が完了していません。受信ボックスをご確認ください'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスまたはパスワードが正しくありません'**
  String get errorInvalidCredentials;

  /// No description provided for @loginButton.
  ///
  /// In ja, this message translates to:
  /// **'ログインする'**
  String get loginButton;

  /// No description provided for @displayNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'表示名'**
  String get displayNameLabel;

  /// No description provided for @errorDisplayNameRequired.
  ///
  /// In ja, this message translates to:
  /// **'表示名を入力してください'**
  String get errorDisplayNameRequired;

  /// No description provided for @errorPasswordMin8.
  ///
  /// In ja, this message translates to:
  /// **'パスワードは8文字以上で入力してください'**
  String get errorPasswordMin8;

  /// No description provided for @signupButton.
  ///
  /// In ja, this message translates to:
  /// **'登録する'**
  String get signupButton;

  /// No description provided for @errorEmailAlreadyRegistered.
  ///
  /// In ja, this message translates to:
  /// **'このメールアドレスは既に登録されています'**
  String get errorEmailAlreadyRegistered;

  /// No description provided for @errorSignupFailed.
  ///
  /// In ja, this message translates to:
  /// **'登録に失敗しました。入力内容をご確認のうえ、再度お試しください'**
  String get errorSignupFailed;

  /// No description provided for @errorRateLimited.
  ///
  /// In ja, this message translates to:
  /// **'しばらく時間をおいてから再度お試しください'**
  String get errorRateLimited;

  /// No description provided for @signupConfirmationTitle.
  ///
  /// In ja, this message translates to:
  /// **'確認メールを送信しました'**
  String get signupConfirmationTitle;

  /// No description provided for @signupConfirmationBody.
  ///
  /// In ja, this message translates to:
  /// **'{email}宛に確認メールを送信しました。メール内のリンクをタップして登録を完了してください。'**
  String signupConfirmationBody(String email);

  /// No description provided for @webOnlyAccountTitle.
  ///
  /// In ja, this message translates to:
  /// **'このアカウントはアプリでは利用できません'**
  String get webOnlyAccountTitle;

  /// No description provided for @webOnlyAccountBody.
  ///
  /// In ja, this message translates to:
  /// **'飲食店・EcoMeal運営のアカウントは、パソコンのWeb管理画面からご利用ください。'**
  String get webOnlyAccountBody;

  /// No description provided for @openWebAdmin.
  ///
  /// In ja, this message translates to:
  /// **'Web管理画面を開く'**
  String get openWebAdmin;

  /// No description provided for @errorOpenWebAdmin.
  ///
  /// In ja, this message translates to:
  /// **'Web管理画面を開けませんでした'**
  String get errorOpenWebAdmin;

  /// No description provided for @errorProfileLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール情報の取得に失敗しました。もう一度お試しください'**
  String get errorProfileLoadFailed;

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal'**
  String get appTitle;

  /// No description provided for @driverAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal Driver'**
  String get driverAppTitle;

  /// No description provided for @driverBadge.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー'**
  String get driverBadge;

  /// No description provided for @switchLanguageLabel.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get switchLanguageLabel;

  /// No description provided for @driverLoginLead.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal から発行されたドライバー用アカウントでログインしてください。'**
  String get driverLoginLead;

  /// No description provided for @driverAccountIssuedNote.
  ///
  /// In ja, this message translates to:
  /// **'アカウントは運営から発行されます。招待メールのリンクでパスワードを設定してからログインしてください。'**
  String get driverAccountIssuedNote;

  /// No description provided for @driverOnlyAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー専用アプリです'**
  String get driverOnlyAppTitle;

  /// No description provided for @driverOnlyAppBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様は「EcoMeal」アプリ、飲食店・EcoMeal運営の方はパソコンのWeb管理画面をご利用ください。'**
  String get driverOnlyAppBody;

  /// No description provided for @driverAccountTitle.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー用アカウントです'**
  String get driverAccountTitle;

  /// No description provided for @driverAccountBody.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーの方は「EcoMeal Driver」アプリでログインしてください。このアプリはお客様専用です。'**
  String get driverAccountBody;

  /// No description provided for @driverSuspendedTitle.
  ///
  /// In ja, this message translates to:
  /// **'稼働が停止されています'**
  String get driverSuspendedTitle;

  /// No description provided for @driverSuspendedBody.
  ///
  /// In ja, this message translates to:
  /// **'このアカウントは現在シフトに入れない状態です。理由と再開の手続きは EcoMeal 運営にお問い合わせください。'**
  String get driverSuspendedBody;

  /// No description provided for @selectLanguage.
  ///
  /// In ja, this message translates to:
  /// **'言語を選択 / Select language'**
  String get selectLanguage;

  /// No description provided for @japaneseLanguage.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get japaneseLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @backToLogin.
  ///
  /// In ja, this message translates to:
  /// **'ログイン画面に戻る'**
  String get backToLogin;

  /// No description provided for @errorNetwork.
  ///
  /// In ja, this message translates to:
  /// **'通信に失敗しました。接続を確認して再度お試しください'**
  String get errorNetwork;

  /// No description provided for @signOutButton.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get signOutButton;

  /// No description provided for @errorSignOutFailed.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトに失敗しました。もう一度お試しください'**
  String get errorSignOutFailed;

  /// No description provided for @onboardingHeadline.
  ///
  /// In ja, this message translates to:
  /// **'今夜の食事を、未来につなぐ。'**
  String get onboardingHeadline;

  /// No description provided for @onboardingLead.
  ///
  /// In ja, this message translates to:
  /// **'街のレストランから生まれるおいしい余剰を、Eco-Truckがあなたの近くへ届けます。'**
  String get onboardingLead;

  /// No description provided for @onboardingImpact.
  ///
  /// In ja, this message translates to:
  /// **'食品ロスをおいしく削減'**
  String get onboardingImpact;

  /// No description provided for @loginLead.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスとパスワードでログインしましょう。'**
  String get loginLead;

  /// No description provided for @signupLead.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスとパスワードでアカウントを作成しましょう。'**
  String get signupLead;

  /// No description provided for @emailHint.
  ///
  /// In ja, this message translates to:
  /// **'example@example.jp'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを入力'**
  String get passwordHint;

  /// No description provided for @passwordMin8Helper.
  ///
  /// In ja, this message translates to:
  /// **'8文字以上で入力してください。'**
  String get passwordMin8Helper;

  /// No description provided for @showPassword.
  ///
  /// In ja, this message translates to:
  /// **'表示'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ja, this message translates to:
  /// **'非表示'**
  String get hidePassword;

  /// No description provided for @displayNameHint.
  ///
  /// In ja, this message translates to:
  /// **'表示名を入力'**
  String get displayNameHint;

  /// No description provided for @noAccountPrompt.
  ///
  /// In ja, this message translates to:
  /// **'まだアカウントをお持ちでない方は'**
  String get noAccountPrompt;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In ja, this message translates to:
  /// **'すでにアカウントをお持ちの方は'**
  String get haveAccountPrompt;

  /// No description provided for @signupSpamFolderNote.
  ///
  /// In ja, this message translates to:
  /// **'メールが届かない場合は、迷惑メールフォルダをご確認ください。'**
  String get signupSpamFolderNote;

  /// No description provided for @forgotPasswordPrompt.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを忘れた方は'**
  String get forgotPasswordPrompt;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In ja, this message translates to:
  /// **'こちら'**
  String get forgotPasswordAction;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In ja, this message translates to:
  /// **'パスワード再設定'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordRequestLead.
  ///
  /// In ja, this message translates to:
  /// **'登録したメールアドレスに、パスワード再設定用の確認コードを送信します。'**
  String get resetPasswordRequestLead;

  /// No description provided for @resetPasswordSendCodeButton.
  ///
  /// In ja, this message translates to:
  /// **'確認コードを送信する'**
  String get resetPasswordSendCodeButton;

  /// No description provided for @resetPasswordCodeLead.
  ///
  /// In ja, this message translates to:
  /// **'{email} が登録済みであれば、確認コードを送信しました。メールに記載のコードと、新しいパスワードを入力してください。'**
  String resetPasswordCodeLead(String email);

  /// No description provided for @verificationCodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'確認コード'**
  String get verificationCodeLabel;

  /// No description provided for @verificationCodeHint.
  ///
  /// In ja, this message translates to:
  /// **'メールに記載のコード'**
  String get verificationCodeHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In ja, this message translates to:
  /// **'新しいパスワード'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In ja, this message translates to:
  /// **'新しいパスワードを入力'**
  String get newPasswordHint;

  /// No description provided for @resetPasswordButton.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを再設定する'**
  String get resetPasswordButton;

  /// No description provided for @resendCodePrompt.
  ///
  /// In ja, this message translates to:
  /// **'コードが届かない場合は'**
  String get resendCodePrompt;

  /// No description provided for @resendCodeAction.
  ///
  /// In ja, this message translates to:
  /// **'再送する'**
  String get resendCodeAction;

  /// No description provided for @codeResent.
  ///
  /// In ja, this message translates to:
  /// **'確認コードを再送しました'**
  String get codeResent;

  /// No description provided for @passwordResetDone.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを再設定しました'**
  String get passwordResetDone;

  /// No description provided for @errorVerificationCodeFormat.
  ///
  /// In ja, this message translates to:
  /// **'メールに記載の確認コード（数字）を入力してください'**
  String get errorVerificationCodeFormat;

  /// No description provided for @errorVerificationCodeInvalid.
  ///
  /// In ja, this message translates to:
  /// **'確認コードが正しくないか、有効期限が切れています'**
  String get errorVerificationCodeInvalid;

  /// No description provided for @errorSamePassword.
  ///
  /// In ja, this message translates to:
  /// **'現在のパスワードとは異なるパスワードを入力してください'**
  String get errorSamePassword;

  /// No description provided for @errorResetRequestFailed.
  ///
  /// In ja, this message translates to:
  /// **'確認コードを送信できませんでした。もう一度お試しください'**
  String get errorResetRequestFailed;

  /// No description provided for @errorResetFailed.
  ///
  /// In ja, this message translates to:
  /// **'パスワードの再設定に失敗しました。もう一度お試しください'**
  String get errorResetFailed;

  /// No description provided for @retry.
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get retry;

  /// No description provided for @errorLoadRetry.
  ///
  /// In ja, this message translates to:
  /// **'データの取得に失敗しました。再試行'**
  String get errorLoadRetry;

  /// No description provided for @errorLoadTitle.
  ///
  /// In ja, this message translates to:
  /// **'データの取得に失敗しました。'**
  String get errorLoadTitle;

  /// No description provided for @errorLoadBody.
  ///
  /// In ja, this message translates to:
  /// **'通信状態を確認して、もう一度お試しください。'**
  String get errorLoadBody;

  /// No description provided for @errorLocationUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'位置情報を取得できませんでした'**
  String get errorLocationUnavailable;

  /// No description provided for @errorLocationBody.
  ///
  /// In ja, this message translates to:
  /// **'端末の位置情報の設定とネットワーク接続を確認してください。'**
  String get errorLocationBody;

  /// No description provided for @nearbyBatches.
  ///
  /// In ja, this message translates to:
  /// **'近くのフードバッグ'**
  String get nearbyBatches;

  /// No description provided for @countItems.
  ///
  /// In ja, this message translates to:
  /// **'{count}件'**
  String countItems(int count);

  /// No description provided for @liveUpdating.
  ///
  /// In ja, this message translates to:
  /// **'位置更新中'**
  String get liveUpdating;

  /// No description provided for @truckRunning.
  ///
  /// In ja, this message translates to:
  /// **'Eco-Truck 運行中'**
  String get truckRunning;

  /// No description provided for @truckNumber.
  ///
  /// In ja, this message translates to:
  /// **'Eco-Truck {number}号車'**
  String truckNumber(int number);

  /// No description provided for @truckRouteSummary.
  ///
  /// In ja, this message translates to:
  /// **'今夜の停車予定 · {count}地点'**
  String truckRouteSummary(int count);

  /// No description provided for @truckTapHint.
  ///
  /// In ja, this message translates to:
  /// **'地図のトラックか、このカードをタップすると停車予定とメニューを表示します'**
  String get truckTapHint;

  /// No description provided for @stopPassed.
  ///
  /// In ja, this message translates to:
  /// **'通過済み'**
  String get stopPassed;

  /// No description provided for @nextStopBadge.
  ///
  /// In ja, this message translates to:
  /// **'次の停車地'**
  String get nextStopBadge;

  /// No description provided for @truckNoBatches.
  ///
  /// In ja, this message translates to:
  /// **'このトラックで販売中のフードバッグはありません'**
  String get truckNoBatches;

  /// No description provided for @closeTruckRoute.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get closeTruckRoute;

  /// No description provided for @truckNextStop.
  ///
  /// In ja, this message translates to:
  /// **'次の停車地：{stopName}'**
  String truckNextStop(String stopName);

  /// No description provided for @truckEta.
  ///
  /// In ja, this message translates to:
  /// **'到着予定 {time}・あと{minutes}分'**
  String truckEta(String time, int minutes);

  /// No description provided for @homeEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'本日はまだ販売予定がありません'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'LINEと連携すると、Eco-Truckが近づいたときにお知らせが届きます。'**
  String get homeEmptyBody;

  /// No description provided for @setupLineNotify.
  ///
  /// In ja, this message translates to:
  /// **'LINE通知を設定する'**
  String get setupLineNotify;

  /// No description provided for @homeEmptyBodyLinked.
  ///
  /// In ja, this message translates to:
  /// **'Eco-Truckが近づいたら、EcoMeal公式アカウントからLINEでお知らせします。'**
  String get homeEmptyBodyLinked;

  /// No description provided for @openLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEを開く'**
  String get openLine;

  /// No description provided for @partnerStore.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal提携店'**
  String get partnerStore;

  /// No description provided for @mysteryBag.
  ///
  /// In ja, this message translates to:
  /// **'ミステリーバッグ'**
  String get mysteryBag;

  /// No description provided for @remainingBags.
  ///
  /// In ja, this message translates to:
  /// **'残り{qty}袋'**
  String remainingBags(int qty);

  /// No description provided for @batchDetailTitle.
  ///
  /// In ja, this message translates to:
  /// **'フードバッグ詳細'**
  String get batchDetailTitle;

  /// No description provided for @priceCalculating.
  ///
  /// In ja, this message translates to:
  /// **'価格を計算中...'**
  String get priceCalculating;

  /// No description provided for @errorPriceLoad.
  ///
  /// In ja, this message translates to:
  /// **'価格の取得に失敗しました'**
  String get errorPriceLoad;

  /// No description provided for @minutesRemaining.
  ///
  /// In ja, this message translates to:
  /// **'あと{minutes}分'**
  String minutesRemaining(int minutes);

  /// No description provided for @pickupByEcoTruck.
  ///
  /// In ja, this message translates to:
  /// **'Eco-Truckで受け取り'**
  String get pickupByEcoTruck;

  /// No description provided for @allergensHeading.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲン情報'**
  String get allergensHeading;

  /// No description provided for @allergensNone.
  ///
  /// In ja, this message translates to:
  /// **'該当なし'**
  String get allergensNone;

  /// No description provided for @ingredientsHeading.
  ///
  /// In ja, this message translates to:
  /// **'主な原材料・産地'**
  String get ingredientsHeading;

  /// No description provided for @ingredientWithOrigin.
  ///
  /// In ja, this message translates to:
  /// **'{name}（{origin}）'**
  String ingredientWithOrigin(String name, String origin);

  /// No description provided for @originUnknown.
  ///
  /// In ja, this message translates to:
  /// **'産地不明'**
  String get originUnknown;

  /// No description provided for @detailNote.
  ///
  /// In ja, this message translates to:
  /// **'内容は受け取りまでのお楽しみです。写真はイメージです。アレルギーをお持ちの方は表示をご確認ください。'**
  String get detailNote;

  /// No description provided for @dailyLimitReached.
  ///
  /// In ja, this message translates to:
  /// **'本日の予約上限（2件）に達しています'**
  String get dailyLimitReached;

  /// No description provided for @reserveButton.
  ///
  /// In ja, this message translates to:
  /// **'予約する'**
  String get reserveButton;

  /// No description provided for @mapSetupRequired.
  ///
  /// In ja, this message translates to:
  /// **'地図を表示できません。下の一覧はご覧いただけます。'**
  String get mapSetupRequired;

  /// No description provided for @openLocationSettings.
  ///
  /// In ja, this message translates to:
  /// **'位置情報の設定'**
  String get openLocationSettings;

  /// No description provided for @batchExpired.
  ///
  /// In ja, this message translates to:
  /// **'販売期限を過ぎました。別のフードバッグをお選びください。'**
  String get batchExpired;

  /// No description provided for @reservationCountFailed.
  ///
  /// In ja, this message translates to:
  /// **'予約件数を確認できませんでした。再試行してください。'**
  String get reservationCountFailed;

  /// No description provided for @homeTab.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get homeTab;

  /// No description provided for @reservationsTab.
  ///
  /// In ja, this message translates to:
  /// **'予約'**
  String get reservationsTab;

  /// No description provided for @myPageTab.
  ///
  /// In ja, this message translates to:
  /// **'マイページ'**
  String get myPageTab;

  /// No description provided for @locateMe.
  ///
  /// In ja, this message translates to:
  /// **'現在地へ'**
  String get locateMe;

  /// No description provided for @statusPending.
  ///
  /// In ja, this message translates to:
  /// **'数量確認待ち'**
  String get statusPending;

  /// No description provided for @statusAllocated.
  ///
  /// In ja, this message translates to:
  /// **'取り置き済み'**
  String get statusAllocated;

  /// No description provided for @statusPickedUp.
  ///
  /// In ja, this message translates to:
  /// **'受け取り済み'**
  String get statusPickedUp;

  /// No description provided for @statusRefunded.
  ///
  /// In ja, this message translates to:
  /// **'返金済み'**
  String get statusRefunded;

  /// No description provided for @statusExpired.
  ///
  /// In ja, this message translates to:
  /// **'失効'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル済み'**
  String get statusCancelled;

  /// No description provided for @reservationConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'予約内容の確認'**
  String get reservationConfirmTitle;

  /// No description provided for @paymentMethodRequired.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法（必須）'**
  String get paymentMethodRequired;

  /// No description provided for @paymentMethodSection.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法'**
  String get paymentMethodSection;

  /// No description provided for @addPaymentMethod.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法を追加'**
  String get addPaymentMethod;

  /// No description provided for @addPaymentMethodSub.
  ///
  /// In ja, this message translates to:
  /// **'クレジットカード・デビットカード'**
  String get addPaymentMethodSub;

  /// No description provided for @defaultCardLabel.
  ///
  /// In ja, this message translates to:
  /// **'デフォルトカード'**
  String get defaultCardLabel;

  /// No description provided for @addPaymentMethodHint.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法を追加すると、予約を確定できます。'**
  String get addPaymentMethodHint;

  /// No description provided for @addPaymentMethodButton.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法を追加してください'**
  String get addPaymentMethodButton;

  /// No description provided for @payNotice.
  ///
  /// In ja, this message translates to:
  /// **'予約を確定すると、{amount}が決済されます。'**
  String payNotice(String amount);

  /// No description provided for @payButton.
  ///
  /// In ja, this message translates to:
  /// **'{amount}を支払って予約する'**
  String payButton(String amount);

  /// No description provided for @errorPaymentMethodsLoad.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法を取得できませんでした'**
  String get errorPaymentMethodsLoad;

  /// No description provided for @errorPaymentMethodMissing.
  ///
  /// In ja, this message translates to:
  /// **'選択したカードが見つかりません。支払い方法を選び直してください'**
  String get errorPaymentMethodMissing;

  /// No description provided for @paymentTitle.
  ///
  /// In ja, this message translates to:
  /// **'お支払い'**
  String get paymentTitle;

  /// No description provided for @paymentProcessingTitle.
  ///
  /// In ja, this message translates to:
  /// **'お支払いを処理しています'**
  String get paymentProcessingTitle;

  /// No description provided for @paymentProcessingBody.
  ///
  /// In ja, this message translates to:
  /// **'完了までこの画面でお待ちください。\n支払いボタンを繰り返し押さないでください。'**
  String get paymentProcessingBody;

  /// No description provided for @paymentProcessingNote.
  ///
  /// In ja, this message translates to:
  /// **'決済結果を確認しています。\n通常は数秒で完了します。'**
  String get paymentProcessingNote;

  /// No description provided for @paymentSummaryLine.
  ///
  /// In ja, this message translates to:
  /// **'{amount}（税込）  ·  {card}'**
  String paymentSummaryLine(String amount, String card);

  /// No description provided for @reservationCompleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'予約完了'**
  String get reservationCompleteTitle;

  /// No description provided for @paymentDoneTitle.
  ///
  /// In ja, this message translates to:
  /// **'お支払いが完了しました'**
  String get paymentDoneTitle;

  /// No description provided for @paymentDoneBody.
  ///
  /// In ja, this message translates to:
  /// **'予約を受け付けました。\n受け取りの案内は予約画面で確認できます。'**
  String get paymentDoneBody;

  /// No description provided for @pickupPlaceLine.
  ///
  /// In ja, this message translates to:
  /// **'受取場所：{place}'**
  String pickupPlaceLine(String place);

  /// No description provided for @pickupTimeLine.
  ///
  /// In ja, this message translates to:
  /// **'受取時間：{time}'**
  String pickupTimeLine(String time);

  /// No description provided for @viewReservation.
  ///
  /// In ja, this message translates to:
  /// **'予約内容を確認'**
  String get viewReservation;

  /// No description provided for @paymentDeclinedTitle.
  ///
  /// In ja, this message translates to:
  /// **'お支払いできませんでした'**
  String get paymentDeclinedTitle;

  /// No description provided for @paymentDeclinedBody.
  ///
  /// In ja, this message translates to:
  /// **'カード会社が決済を承認しませんでした。\n別のカードを選ぶか、カード会社へご確認ください。'**
  String get paymentDeclinedBody;

  /// No description provided for @paymentCardExpiredBody.
  ///
  /// In ja, this message translates to:
  /// **'カードの有効期限が切れています。\n別のカードを選んでください。'**
  String get paymentCardExpiredBody;

  /// No description provided for @paymentNotCompletedNote.
  ///
  /// In ja, this message translates to:
  /// **'この支払いは完了していません。\n予約はまだ確定していません。'**
  String get paymentNotCompletedNote;

  /// No description provided for @payWithAnotherCard.
  ///
  /// In ja, this message translates to:
  /// **'別のカードで支払う'**
  String get payWithAnotherCard;

  /// No description provided for @backToReview.
  ///
  /// In ja, this message translates to:
  /// **'予約内容に戻る'**
  String get backToReview;

  /// No description provided for @paymentUnknownTitle.
  ///
  /// In ja, this message translates to:
  /// **'決済結果を確認できません'**
  String get paymentUnknownTitle;

  /// No description provided for @paymentUnknownBody.
  ///
  /// In ja, this message translates to:
  /// **'通信が途切れたため、支払い状況を確認しています。\n重複を防ぐため、再度支払わないでください。'**
  String get paymentUnknownBody;

  /// No description provided for @paymentUnknownNote.
  ///
  /// In ja, this message translates to:
  /// **'支払い・予約状況は確認中です。\n接続を確認してから結果を取得してください。'**
  String get paymentUnknownNote;

  /// No description provided for @recheckPayment.
  ///
  /// In ja, this message translates to:
  /// **'支払い状況を再確認'**
  String get recheckPayment;

  /// No description provided for @viewReservationHistory.
  ///
  /// In ja, this message translates to:
  /// **'予約履歴を確認'**
  String get viewReservationHistory;

  /// No description provided for @paymentNotFound.
  ///
  /// In ja, this message translates to:
  /// **'お支払いは完了していませんでした。もう一度お試しください'**
  String get paymentNotFound;

  /// No description provided for @errorRecheckFailed.
  ///
  /// In ja, this message translates to:
  /// **'確認できませんでした。接続を確認してもう一度お試しください'**
  String get errorRecheckFailed;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法'**
  String get paymentMethodsTitle;

  /// No description provided for @paymentMethodsSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'カードを安全に管理'**
  String get paymentMethodsSubtitle;

  /// No description provided for @paymentMethodsEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'支払い方法が未登録です'**
  String get paymentMethodsEmptyTitle;

  /// No description provided for @paymentMethodsEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'カードを登録すると、予約の支払いがワンタップで完了します。'**
  String get paymentMethodsEmptyBody;

  /// No description provided for @addCreditCard.
  ///
  /// In ja, this message translates to:
  /// **'＋ クレジットカードを追加'**
  String get addCreditCard;

  /// No description provided for @paymentProviderNote.
  ///
  /// In ja, this message translates to:
  /// **'支払い情報は認定決済プロバイダーによって安全に処理されます。'**
  String get paymentProviderNote;

  /// No description provided for @registeredCards.
  ///
  /// In ja, this message translates to:
  /// **'登録済みカード'**
  String get registeredCards;

  /// No description provided for @cardExpiresOn.
  ///
  /// In ja, this message translates to:
  /// **'有効期限 {expiry}'**
  String cardExpiresOn(String expiry);

  /// No description provided for @defaultBadge.
  ///
  /// In ja, this message translates to:
  /// **'デフォルト'**
  String get defaultBadge;

  /// No description provided for @addAnotherCard.
  ///
  /// In ja, this message translates to:
  /// **'＋  別のカードを追加'**
  String get addAnotherCard;

  /// No description provided for @paymentSafetyTitle.
  ///
  /// In ja, this message translates to:
  /// **'支払いの安全性'**
  String get paymentSafetyTitle;

  /// No description provided for @paymentSafetyBody.
  ///
  /// In ja, this message translates to:
  /// **'カード情報は暗号化され、決済プロバイダーによって安全に管理されます。\nデフォルトカードを設定すると、ワンタップで支払えます。'**
  String get paymentSafetyBody;

  /// No description provided for @setDefaultCard.
  ///
  /// In ja, this message translates to:
  /// **'デフォルトのカードに設定'**
  String get setDefaultCard;

  /// No description provided for @deleteCard.
  ///
  /// In ja, this message translates to:
  /// **'このカードを削除'**
  String get deleteCard;

  /// No description provided for @deleteCardTitle.
  ///
  /// In ja, this message translates to:
  /// **'このカードを削除しますか？'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardBody.
  ///
  /// In ja, this message translates to:
  /// **'{card} を削除します。削除すると、このカードは次回以降の注文に使えなくなります。'**
  String deleteCardBody(String card);

  /// No description provided for @deleteConfirm.
  ///
  /// In ja, this message translates to:
  /// **'削除する'**
  String get deleteConfirm;

  /// No description provided for @cardDeleted.
  ///
  /// In ja, this message translates to:
  /// **'カードを削除しました'**
  String get cardDeleted;

  /// No description provided for @defaultCardChanged.
  ///
  /// In ja, this message translates to:
  /// **'デフォルトのカードを変更しました'**
  String get defaultCardChanged;

  /// No description provided for @addCardTitle.
  ///
  /// In ja, this message translates to:
  /// **'カードを追加'**
  String get addCardTitle;

  /// No description provided for @addCardSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'安全な支払い方法'**
  String get addCardSubtitle;

  /// No description provided for @cardInfoSection.
  ///
  /// In ja, this message translates to:
  /// **'カード情報'**
  String get cardInfoSection;

  /// No description provided for @cardNumberLabel.
  ///
  /// In ja, this message translates to:
  /// **'カード番号'**
  String get cardNumberLabel;

  /// No description provided for @cardNumberHint.
  ///
  /// In ja, this message translates to:
  /// **'1234  5678  9012  3456'**
  String get cardNumberHint;

  /// No description provided for @cardHolderLabel.
  ///
  /// In ja, this message translates to:
  /// **'カード名義'**
  String get cardHolderLabel;

  /// No description provided for @cardHolderHint.
  ///
  /// In ja, this message translates to:
  /// **'カード名義人'**
  String get cardHolderHint;

  /// No description provided for @cardExpiryLabel.
  ///
  /// In ja, this message translates to:
  /// **'有効期限'**
  String get cardExpiryLabel;

  /// No description provided for @cardExpiryHint.
  ///
  /// In ja, this message translates to:
  /// **'MM / YY'**
  String get cardExpiryHint;

  /// No description provided for @cardCvcLabel.
  ///
  /// In ja, this message translates to:
  /// **'セキュリティコード'**
  String get cardCvcLabel;

  /// No description provided for @cardCvcHint.
  ///
  /// In ja, this message translates to:
  /// **'CVC'**
  String get cardCvcHint;

  /// No description provided for @cardTokenNote.
  ///
  /// In ja, this message translates to:
  /// **'カード情報は安全にトークン化されます。CVCは他人に知らせないでください。'**
  String get cardTokenNote;

  /// No description provided for @cardTermsNote.
  ///
  /// In ja, this message translates to:
  /// **'カードを追加すると、支払い条件に同意したものとみなされます。'**
  String get cardTermsNote;

  /// No description provided for @addCardButton.
  ///
  /// In ja, this message translates to:
  /// **'カードを追加する'**
  String get addCardButton;

  /// No description provided for @cardNumberInvalid.
  ///
  /// In ja, this message translates to:
  /// **'カード番号を確認してください。'**
  String get cardNumberInvalid;

  /// No description provided for @cardHolderRequired.
  ///
  /// In ja, this message translates to:
  /// **'カード名義を入力してください。'**
  String get cardHolderRequired;

  /// No description provided for @cardExpiryInvalid.
  ///
  /// In ja, this message translates to:
  /// **'有効期限を確認してください。'**
  String get cardExpiryInvalid;

  /// No description provided for @cardCvcInvalid.
  ///
  /// In ja, this message translates to:
  /// **'セキュリティコードを確認してください。'**
  String get cardCvcInvalid;

  /// No description provided for @errorCardLimit.
  ///
  /// In ja, this message translates to:
  /// **'登録できるカードは10枚までです'**
  String get errorCardLimit;

  /// No description provided for @errorCardAdd.
  ///
  /// In ja, this message translates to:
  /// **'カードを追加できませんでした。もう一度お試しください'**
  String get errorCardAdd;

  /// No description provided for @testPaymentNote.
  ///
  /// In ja, this message translates to:
  /// **'テスト中のため実際の請求は発生しません。テスト用カード 4242 4242 4242 4242 をお使いください（0002で終わるカードは決済が拒否されます）。'**
  String get testPaymentNote;

  /// No description provided for @paymentMethodRowDefault.
  ///
  /// In ja, this message translates to:
  /// **'{card} ・ デフォルト'**
  String paymentMethodRowDefault(String card);

  /// No description provided for @paymentMethodRowNone.
  ///
  /// In ja, this message translates to:
  /// **'未登録'**
  String get paymentMethodRowNone;

  /// No description provided for @freeCancelTitle.
  ///
  /// In ja, this message translates to:
  /// **'受取予定の30分前まで無料キャンセル'**
  String get freeCancelTitle;

  /// No description provided for @freeCancelBody.
  ///
  /// In ja, this message translates to:
  /// **'受取予定の30分前まで無料キャンセルできます。キャンセルは予約履歴から行えます。'**
  String get freeCancelBody;

  /// No description provided for @errorReservationFailed.
  ///
  /// In ja, this message translates to:
  /// **'予約できませんでした。売り切れた可能性があります。別のフードバッグをお選びください'**
  String get errorReservationFailed;

  /// No description provided for @tryAgain.
  ///
  /// In ja, this message translates to:
  /// **'もう一度試す'**
  String get tryAgain;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In ja, this message translates to:
  /// **'予約履歴'**
  String get orderHistoryTitle;

  /// No description provided for @orderHistorySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'あなたのEcoMealの記録'**
  String get orderHistorySubtitle;

  /// No description provided for @filterAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In ja, this message translates to:
  /// **'予約中'**
  String get filterActive;

  /// No description provided for @filterCompleted.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get filterCompleted;

  /// No description provided for @orderHistoryEmpty.
  ///
  /// In ja, this message translates to:
  /// **'まだ予約がありません'**
  String get orderHistoryEmpty;

  /// No description provided for @cancelDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'予約をキャンセルしますか？'**
  String get cancelDialogTitle;

  /// No description provided for @cancelDialogFree.
  ///
  /// In ja, this message translates to:
  /// **'受取予定の30分前まで無料キャンセルできます。現在の状況では全額返金されます。'**
  String get cancelDialogFree;

  /// No description provided for @cancelDialogNoRefund.
  ///
  /// In ja, this message translates to:
  /// **'受取予定の30分前を過ぎているため、キャンセルしても返金されません。'**
  String get cancelDialogNoRefund;

  /// No description provided for @back.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get back;

  /// No description provided for @cancelConfirmButton.
  ///
  /// In ja, this message translates to:
  /// **'キャンセルする'**
  String get cancelConfirmButton;

  /// No description provided for @cancelledWithRefund.
  ///
  /// In ja, this message translates to:
  /// **'キャンセルしました（¥{amount}を返金）'**
  String cancelledWithRefund(int amount);

  /// No description provided for @cancelledNoRefund.
  ///
  /// In ja, this message translates to:
  /// **'キャンセルしました（返金なし）'**
  String get cancelledNoRefund;

  /// No description provided for @errorCancelFailed.
  ///
  /// In ja, this message translates to:
  /// **'キャンセルに失敗しました。もう一度お試しください'**
  String get errorCancelFailed;

  /// No description provided for @orderNumber.
  ///
  /// In ja, this message translates to:
  /// **'注文 {number}'**
  String orderNumber(String number);

  /// No description provided for @pendingExplanation.
  ///
  /// In ja, this message translates to:
  /// **'注文内容の数量を配送員が確認中です。数量不足の場合は、各受け取りポイントの順番（FIFO）に従って分配します。分配されなかった数量については、自動で返金処理を行います。'**
  String get pendingExplanation;

  /// No description provided for @allocatedExplanation.
  ///
  /// In ja, this message translates to:
  /// **'{stopName}で1袋を確保しました。受け取り時はQRコードを提示し、読み取れない場合は下記コードを伝えてください。'**
  String allocatedExplanation(String stopName);

  /// No description provided for @freeCancelExpired.
  ///
  /// In ja, this message translates to:
  /// **'無料キャンセル期限を過ぎています（返金なし）'**
  String get freeCancelExpired;

  /// No description provided for @cancelButton.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancelButton;

  /// No description provided for @manualCodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'手動入力：{code}'**
  String manualCodeLabel(String code);

  /// No description provided for @pickupQrTitle.
  ///
  /// In ja, this message translates to:
  /// **'受け取りQR'**
  String get pickupQrTitle;

  /// No description provided for @pickupQrCaption.
  ///
  /// In ja, this message translates to:
  /// **'受け取り時にQRコードを読み取ってもらうか、コードを入力してもらってください。'**
  String get pickupQrCaption;

  /// No description provided for @refundFullBadge.
  ///
  /// In ja, this message translates to:
  /// **'全額返金されます'**
  String get refundFullBadge;

  /// No description provided for @refundFullNote.
  ///
  /// In ja, this message translates to:
  /// **'現在の予約状況では、キャンセル後に全額返金されます。'**
  String get refundFullNote;

  /// No description provided for @refundNoneBadge.
  ///
  /// In ja, this message translates to:
  /// **'返金なし'**
  String get refundNoneBadge;

  /// No description provided for @refundNoneNote.
  ///
  /// In ja, this message translates to:
  /// **'受取予定の30分前を過ぎているため、キャンセル後の返金はありません。'**
  String get refundNoneNote;

  /// No description provided for @errorBadge.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get errorBadge;

  /// No description provided for @browseBatches.
  ///
  /// In ja, this message translates to:
  /// **'近くのフードバッグを見る'**
  String get browseBatches;

  /// No description provided for @totalWithQuantity.
  ///
  /// In ja, this message translates to:
  /// **'合計（数量 {quantity}）'**
  String totalWithQuantity(int quantity);

  /// No description provided for @todayTime.
  ///
  /// In ja, this message translates to:
  /// **'本日 {time}'**
  String todayTime(String time);

  /// No description provided for @errorDisplayNameTooLong.
  ///
  /// In ja, this message translates to:
  /// **'表示名は{max}文字以内で入力してください'**
  String errorDisplayNameTooLong(int max);

  /// No description provided for @errorNameKanaTooLong.
  ///
  /// In ja, this message translates to:
  /// **'フリガナは{max}文字以内で入力してください'**
  String errorNameKanaTooLong(int max);

  /// No description provided for @errorLanguageSave.
  ///
  /// In ja, this message translates to:
  /// **'言語設定の保存に失敗しました'**
  String get errorLanguageSave;

  /// No description provided for @errorLineStatusLoad.
  ///
  /// In ja, this message translates to:
  /// **'LINE連携状態を取得できませんでした'**
  String get errorLineStatusLoad;

  /// No description provided for @lineLinked.
  ///
  /// In ja, this message translates to:
  /// **'LINE連携済み'**
  String get lineLinked;

  /// No description provided for @lineLinkedBody.
  ///
  /// In ja, this message translates to:
  /// **'受け取り通知をLINEで確認できます'**
  String get lineLinkedBody;

  /// No description provided for @lineLinkHint.
  ///
  /// In ja, this message translates to:
  /// **'通知はEcoMeal公式アカウント（LINE）のトークに届きます'**
  String get lineLinkHint;

  /// No description provided for @lineOpenChat.
  ///
  /// In ja, this message translates to:
  /// **'LINEでトークを開く'**
  String get lineOpenChat;

  /// No description provided for @errorOpenLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEを開けませんでした'**
  String get errorOpenLine;

  /// No description provided for @errorLineLinkFailed.
  ///
  /// In ja, this message translates to:
  /// **'LINE連携に失敗しました。もう一度お試しください'**
  String get errorLineLinkFailed;

  /// No description provided for @lineLinkButton.
  ///
  /// In ja, this message translates to:
  /// **'LINEと連携する'**
  String get lineLinkButton;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトしますか？'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトすると、ログイン画面に戻ります。'**
  String get logoutDialogBody;

  /// No description provided for @profileSaved.
  ///
  /// In ja, this message translates to:
  /// **'プロフィールを更新しました'**
  String get profileSaved;

  /// No description provided for @errorSaveFailed.
  ///
  /// In ja, this message translates to:
  /// **'保存に失敗しました。もう一度お試しください'**
  String get errorSaveFailed;

  /// No description provided for @discardDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'変更を破棄しますか？'**
  String get discardDialogTitle;

  /// No description provided for @discardDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'編集した内容は保存されません。'**
  String get discardDialogBody;

  /// No description provided for @keepEditing.
  ///
  /// In ja, this message translates to:
  /// **'編集を続ける'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In ja, this message translates to:
  /// **'破棄する'**
  String get discard;

  /// No description provided for @profileEditTitle.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール編集'**
  String get profileEditTitle;

  /// No description provided for @requiredBadge.
  ///
  /// In ja, this message translates to:
  /// **'必須'**
  String get requiredBadge;

  /// No description provided for @optionalBadge.
  ///
  /// In ja, this message translates to:
  /// **'任意'**
  String get optionalBadge;

  /// No description provided for @nameKanaLabel.
  ///
  /// In ja, this message translates to:
  /// **'フリガナ'**
  String get nameKanaLabel;

  /// No description provided for @nameKanaHint.
  ///
  /// In ja, this message translates to:
  /// **'例：ハルカ ミカ'**
  String get nameKanaHint;

  /// No description provided for @emailNotEditable.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスは変更できません'**
  String get emailNotEditable;

  /// No description provided for @credentialsChangeOutOfScope.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスとパスワードはこの画面では変更できません。パスワードはログイン画面の「パスワードを忘れた方は」から再設定できます。'**
  String get credentialsChangeOutOfScope;

  /// No description provided for @saveButton.
  ///
  /// In ja, this message translates to:
  /// **'保存する'**
  String get saveButton;

  /// No description provided for @languageLabel.
  ///
  /// In ja, this message translates to:
  /// **'言語 / Language'**
  String get languageLabel;

  /// No description provided for @errorBatchAlreadyConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'このロットは既に確定済みです'**
  String get errorBatchAlreadyConfirmed;

  /// No description provided for @errorStopNotOnRoute.
  ///
  /// In ja, this message translates to:
  /// **'指定された停車地点はこのロットの巡回ルート上に存在しません'**
  String get errorStopNotOnRoute;

  /// No description provided for @errorStopClosed.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点は既にクローズされています'**
  String get errorStopClosed;

  /// No description provided for @errorTemperatureRange.
  ///
  /// In ja, this message translates to:
  /// **'温度は-30〜99.9℃の範囲で入力してください'**
  String get errorTemperatureRange;

  /// No description provided for @errorConfirmFailed.
  ///
  /// In ja, this message translates to:
  /// **'確定登録に失敗しました。もう一度お試しください'**
  String get errorConfirmFailed;

  /// No description provided for @errorTemperatureRequired.
  ///
  /// In ja, this message translates to:
  /// **'温度を入力してください'**
  String get errorTemperatureRequired;

  /// No description provided for @errorConfirmedQtyRequired.
  ///
  /// In ja, this message translates to:
  /// **'確定数量を入力してください'**
  String get errorConfirmedQtyRequired;

  /// No description provided for @errorNonNegativeInteger.
  ///
  /// In ja, this message translates to:
  /// **'0以上の整数で入力してください'**
  String get errorNonNegativeInteger;

  /// No description provided for @pickupConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'集荷を確認'**
  String get pickupConfirmTitle;

  /// No description provided for @pickupSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{stopName} • 集荷 {index}/{total}'**
  String pickupSubtitle(String stopName, int index, int total);

  /// No description provided for @estimatedMeals.
  ///
  /// In ja, this message translates to:
  /// **'概算 {qty}食'**
  String estimatedMeals(int qty);

  /// No description provided for @confirmedQtyLabel.
  ///
  /// In ja, this message translates to:
  /// **'確定数量'**
  String get confirmedQtyLabel;

  /// No description provided for @mealUnit.
  ///
  /// In ja, this message translates to:
  /// **'食'**
  String get mealUnit;

  /// No description provided for @coreTemperatureLabel.
  ///
  /// In ja, this message translates to:
  /// **'受取時の中心温度'**
  String get coreTemperatureLabel;

  /// No description provided for @coldChainNotice.
  ///
  /// In ja, this message translates to:
  /// **'冷蔵品は10°C以下を確認してください。基準外の場合は運営へ連絡します。'**
  String get coldChainNotice;

  /// No description provided for @coldChainOverLimit.
  ///
  /// In ja, this message translates to:
  /// **'基準（10℃以下）を超えています。このロットは回収・販売できません。'**
  String get coldChainOverLimit;

  /// No description provided for @distributionStopsLabel.
  ///
  /// In ja, this message translates to:
  /// **'配分先の停車地'**
  String get distributionStopsLabel;

  /// No description provided for @distributionStopsHint.
  ///
  /// In ja, this message translates to:
  /// **'現在のルートの停車地を選択してください。選択した停車地に分配されます。'**
  String get distributionStopsHint;

  /// No description provided for @noDistributableStops.
  ///
  /// In ja, this message translates to:
  /// **'配分できる停車地がありません（全て出発済み）'**
  String get noDistributableStops;

  /// No description provided for @nextStopLabel.
  ///
  /// In ja, this message translates to:
  /// **'次の停車'**
  String get nextStopLabel;

  /// No description provided for @nthStopLabel.
  ///
  /// In ja, this message translates to:
  /// **'{n}番目'**
  String nthStopLabel(int n);

  /// No description provided for @distributionStopSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{order} • {time}予定'**
  String distributionStopSubtitle(String order, String time);

  /// No description provided for @selectedStopsCount.
  ///
  /// In ja, this message translates to:
  /// **'選択した停車地（{count}箇所）に分配されます。'**
  String selectedStopsCount(int count);

  /// No description provided for @confirmPickupButton.
  ///
  /// In ja, this message translates to:
  /// **'{qty}食の受け取りを確定'**
  String confirmPickupButton(String qty);

  /// No description provided for @pickupConfirmedToast.
  ///
  /// In ja, this message translates to:
  /// **'{qty}食の受け取りを確定しました（予約{allocated}件確保・{refunded}件返金）'**
  String pickupConfirmedToast(int qty, int allocated, int refunded);

  /// No description provided for @rejectPickupButton.
  ///
  /// In ja, this message translates to:
  /// **'回収しない（温度基準外）'**
  String get rejectPickupButton;

  /// No description provided for @rejectPickupDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'このロットを回収しませんか？'**
  String get rejectPickupDialogTitle;

  /// No description provided for @rejectPickupDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'芯温が{celsius}℃で、基準（10℃以下）を超えています。このロットは販売せず、予約はすべて返金されてお客様に通知されます。温度の記録は残ります。'**
  String rejectPickupDialogBody(String celsius);

  /// No description provided for @rejectPickupConfirm.
  ///
  /// In ja, this message translates to:
  /// **'回収しない'**
  String get rejectPickupConfirm;

  /// No description provided for @pickupRejectedToast.
  ///
  /// In ja, this message translates to:
  /// **'温度基準外のため回収しませんでした（予約{refunded}件を返金）'**
  String pickupRejectedToast(int refunded);

  /// No description provided for @noTruckAssigned.
  ///
  /// In ja, this message translates to:
  /// **'担当トラックが割り当てられていません。運営へ連絡してください'**
  String get noTruckAssigned;

  /// No description provided for @noRouteTonight.
  ///
  /// In ja, this message translates to:
  /// **'今夜のルートはまだありません'**
  String get noRouteTonight;

  /// No description provided for @errorLoad.
  ///
  /// In ja, this message translates to:
  /// **'データの取得に失敗しました'**
  String get errorLoad;

  /// No description provided for @noPendingPickup.
  ///
  /// In ja, this message translates to:
  /// **'この店舗の未確定の集荷はありません'**
  String get noPendingPickup;

  /// No description provided for @selectBatchToPickUp.
  ///
  /// In ja, this message translates to:
  /// **'集荷するロットを選択'**
  String get selectBatchToPickUp;

  /// No description provided for @tonightRouteTitle.
  ///
  /// In ja, this message translates to:
  /// **'今夜のルート'**
  String get tonightRouteTitle;

  /// No description provided for @gpsUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'位置情報取得不可'**
  String get gpsUnavailable;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @minutesShort.
  ///
  /// In ja, this message translates to:
  /// **'{minutes}分'**
  String minutesShort(int minutes);

  /// No description provided for @allStopsCompleted.
  ///
  /// In ja, this message translates to:
  /// **'全停車地点を完了'**
  String get allStopsCompleted;

  /// No description provided for @reservedOrdersLabel.
  ///
  /// In ja, this message translates to:
  /// **'予約注文'**
  String get reservedOrdersLabel;

  /// No description provided for @reservedOrdersCaption.
  ///
  /// In ja, this message translates to:
  /// **'未完了の停車地点の合計'**
  String get reservedOrdersCaption;

  /// No description provided for @stopDonePickup.
  ///
  /// In ja, this message translates to:
  /// **'完了 • 集荷済み'**
  String get stopDonePickup;

  /// No description provided for @stopDoneHandoff.
  ///
  /// In ja, this message translates to:
  /// **'完了 • {count}件引き渡し'**
  String stopDoneHandoff(int count);

  /// No description provided for @stopKindPickup.
  ///
  /// In ja, this message translates to:
  /// **'集荷'**
  String get stopKindPickup;

  /// No description provided for @stopReservations.
  ///
  /// In ja, this message translates to:
  /// **'予約 {count}件'**
  String stopReservations(int count);

  /// No description provided for @nextStopPrefixed.
  ///
  /// In ja, this message translates to:
  /// **'次の停車 • {body}'**
  String nextStopPrefixed(String body);

  /// No description provided for @stopCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}つの停車地点'**
  String stopCount(int count);

  /// No description provided for @routeDone.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get routeDone;

  /// No description provided for @routeInProgress.
  ///
  /// In ja, this message translates to:
  /// **'運行中'**
  String get routeInProgress;

  /// No description provided for @driverProfileTitle.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール・設定'**
  String get driverProfileTitle;

  /// No description provided for @driverRoleChip.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー'**
  String get driverRoleChip;

  /// No description provided for @assignedTruck.
  ///
  /// In ja, this message translates to:
  /// **'担当トラック'**
  String get assignedTruck;

  /// No description provided for @unassigned.
  ///
  /// In ja, this message translates to:
  /// **'未割当'**
  String get unassigned;

  /// No description provided for @plateNumberLabel.
  ///
  /// In ja, this message translates to:
  /// **'ナンバープレート'**
  String get plateNumberLabel;

  /// No description provided for @driverTabRoute.
  ///
  /// In ja, this message translates to:
  /// **'運行'**
  String get driverTabRoute;

  /// No description provided for @driverTabPickup.
  ///
  /// In ja, this message translates to:
  /// **'受取'**
  String get driverTabPickup;

  /// No description provided for @driverTabSales.
  ///
  /// In ja, this message translates to:
  /// **'販売'**
  String get driverTabSales;

  /// No description provided for @driverTabEnd.
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get driverTabEnd;

  /// No description provided for @noPickupsTonight.
  ///
  /// In ja, this message translates to:
  /// **'今夜の集荷予定はありません'**
  String get noPickupsTonight;

  /// No description provided for @gpsSending.
  ///
  /// In ja, this message translates to:
  /// **'GPS送信中'**
  String get gpsSending;

  /// No description provided for @driverAccountSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーアカウント'**
  String get driverAccountSubtitle;

  /// No description provided for @errorNotHandoverable.
  ///
  /// In ja, this message translates to:
  /// **'この予約は受け渡し確認できる状態ではありません'**
  String get errorNotHandoverable;

  /// No description provided for @errorWalkupSoldOut.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点のWalk-up在庫は売り切れです'**
  String get errorWalkupSoldOut;

  /// No description provided for @errorWalkupNotConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'確定登録前のロットではWalk-up販売できません'**
  String get errorWalkupNotConfirmed;

  /// No description provided for @errorBatchExpired.
  ///
  /// In ja, this message translates to:
  /// **'このロットは販売終了時刻を過ぎています'**
  String get errorBatchExpired;

  /// No description provided for @errorDonationExceedsStock.
  ///
  /// In ja, this message translates to:
  /// **'寄付数量が残り在庫を超えています'**
  String get errorDonationExceedsStock;

  /// No description provided for @errorDonationNotConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'確定登録前のロットは寄付記録できません'**
  String get errorDonationNotConfirmed;

  /// No description provided for @errorDonationStopsOpen.
  ///
  /// In ja, this message translates to:
  /// **'未出発の販売地点があるため、まだ寄付を記録できません'**
  String get errorDonationStopsOpen;

  /// No description provided for @errorDonationNoteRequired.
  ///
  /// In ja, this message translates to:
  /// **'寄付先を入力してください'**
  String get errorDonationNoteRequired;

  /// No description provided for @errorNotAssignedDriver.
  ///
  /// In ja, this message translates to:
  /// **'このトラックの担当ドライバーではありません'**
  String get errorNotAssignedDriver;

  /// No description provided for @errorGeneric.
  ///
  /// In ja, this message translates to:
  /// **'処理に失敗しました。もう一度お試しください'**
  String get errorGeneric;

  /// No description provided for @errorDonationQtyRequired.
  ///
  /// In ja, this message translates to:
  /// **'寄付数量を入力してください'**
  String get errorDonationQtyRequired;

  /// No description provided for @errorPositiveInteger.
  ///
  /// In ja, this message translates to:
  /// **'1以上の整数で入力してください'**
  String get errorPositiveInteger;

  /// No description provided for @handedOverToast.
  ///
  /// In ja, this message translates to:
  /// **'引き渡しを記録しました（{number}）'**
  String handedOverToast(String number);

  /// No description provided for @errorNotWaitingHere.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点で引き渡し待ちの予約ではありません'**
  String get errorNotWaitingHere;

  /// No description provided for @errorNoMatchingReservation.
  ///
  /// In ja, this message translates to:
  /// **'該当する予約がありません'**
  String get errorNoMatchingReservation;

  /// No description provided for @duplicateCodeTitle.
  ///
  /// In ja, this message translates to:
  /// **'同じコードの予約が複数あります'**
  String get duplicateCodeTitle;

  /// No description provided for @duplicateCodeOption.
  ///
  /// In ja, this message translates to:
  /// **'{number}（予約 {time}）'**
  String duplicateCodeOption(String number, String time);

  /// No description provided for @walkupSoldToast.
  ///
  /// In ja, this message translates to:
  /// **'Walk-up販売を登録しました（¥{price}）'**
  String walkupSoldToast(int price);

  /// No description provided for @departDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'停車地点を出発しますか？'**
  String get departDialogTitle;

  /// No description provided for @currentStop.
  ///
  /// In ja, this message translates to:
  /// **'現在の停車地点：{name}'**
  String currentStop(String name);

  /// No description provided for @departWarning.
  ///
  /// In ja, this message translates to:
  /// **'{count}件の予約が引き渡し待ちです。出発すると、これらの予約は「no-show / 失効」として扱われ、返金対象外になります。'**
  String departWarning(int count);

  /// No description provided for @departWarningTitle.
  ///
  /// In ja, this message translates to:
  /// **'未受取の予約が残っています'**
  String get departWarningTitle;

  /// No description provided for @cautionBadge.
  ///
  /// In ja, this message translates to:
  /// **'注意'**
  String get cautionBadge;

  /// No description provided for @departConfirm.
  ///
  /// In ja, this message translates to:
  /// **'出発する'**
  String get departConfirm;

  /// No description provided for @departedWithExpired.
  ///
  /// In ja, this message translates to:
  /// **'出発しました（未受取{count}件を失効）'**
  String departedWithExpired(int count);

  /// No description provided for @departed.
  ///
  /// In ja, this message translates to:
  /// **'出発しました'**
  String get departed;

  /// No description provided for @departedLabel.
  ///
  /// In ja, this message translates to:
  /// **'出発済み'**
  String get departedLabel;

  /// No description provided for @minutesUntilDeparture.
  ///
  /// In ja, this message translates to:
  /// **'停車終了まで {minutes}分'**
  String minutesUntilDeparture(int minutes);

  /// No description provided for @reservationsCount.
  ///
  /// In ja, this message translates to:
  /// **'予約 {count}'**
  String reservationsCount(int count);

  /// No description provided for @reservationHandoffTab.
  ///
  /// In ja, this message translates to:
  /// **'予約引き渡し'**
  String get reservationHandoffTab;

  /// No description provided for @handedOverLabel.
  ///
  /// In ja, this message translates to:
  /// **'引き渡し済み'**
  String get handedOverLabel;

  /// No description provided for @waitingLabel.
  ///
  /// In ja, this message translates to:
  /// **'予約待ち'**
  String get waitingLabel;

  /// No description provided for @departButton.
  ///
  /// In ja, this message translates to:
  /// **'停車地点を出発'**
  String get departButton;

  /// No description provided for @scanPickupQr.
  ///
  /// In ja, this message translates to:
  /// **'受け取りQRを読み取る'**
  String get scanPickupQr;

  /// No description provided for @scanPickupQrHint.
  ///
  /// In ja, this message translates to:
  /// **'お客様の受け取りQRを読み取ってください'**
  String get scanPickupQrHint;

  /// No description provided for @manualCodeFallback.
  ///
  /// In ja, this message translates to:
  /// **'QRが読み取れない場合：手動入力'**
  String get manualCodeFallback;

  /// No description provided for @batchLabel.
  ///
  /// In ja, this message translates to:
  /// **'ロット'**
  String get batchLabel;

  /// No description provided for @noWalkupBatches.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点で販売できるロットはありません'**
  String get noWalkupBatches;

  /// No description provided for @mealsRemaining.
  ///
  /// In ja, this message translates to:
  /// **'残り {qty}食'**
  String mealsRemaining(int qty);

  /// No description provided for @registerSale.
  ///
  /// In ja, this message translates to:
  /// **'販売を登録'**
  String get registerSale;

  /// No description provided for @soldLabel.
  ///
  /// In ja, this message translates to:
  /// **'販売済み'**
  String get soldLabel;

  /// No description provided for @enterPickupCode.
  ///
  /// In ja, this message translates to:
  /// **'受け取りコードを入力'**
  String get enterPickupCode;

  /// No description provided for @pickupCodeHint.
  ///
  /// In ja, this message translates to:
  /// **'例：A7K2'**
  String get pickupCodeHint;

  /// No description provided for @verifyCode.
  ///
  /// In ja, this message translates to:
  /// **'照合する'**
  String get verifyCode;

  /// No description provided for @noSalesTonight.
  ///
  /// In ja, this message translates to:
  /// **'今夜の販売予定はありません'**
  String get noSalesTonight;

  /// No description provided for @routeEndTitle.
  ///
  /// In ja, this message translates to:
  /// **'運行を終了'**
  String get routeEndTitle;

  /// No description provided for @routeSummaryTitle.
  ///
  /// In ja, this message translates to:
  /// **'運行サマリー'**
  String get routeSummaryTitle;

  /// No description provided for @routeEndThanks.
  ///
  /// In ja, this message translates to:
  /// **'今夜の運行、おつかれさまでした'**
  String get routeEndThanks;

  /// No description provided for @mealsCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}食'**
  String mealsCount(int count);

  /// No description provided for @salesStopsLabel.
  ///
  /// In ja, this message translates to:
  /// **'販売地点'**
  String get salesStopsLabel;

  /// No description provided for @openStopsWarning.
  ///
  /// In ja, this message translates to:
  /// **'未出発の販売地点が{count}箇所あります。「販売」タブから出発操作を行ってください。'**
  String openStopsWarning(int count);

  /// No description provided for @donationBatchOption.
  ///
  /// In ja, this message translates to:
  /// **'{name}（確定 {qty}食）'**
  String donationBatchOption(String name, int qty);

  /// No description provided for @donationRecorded.
  ///
  /// In ja, this message translates to:
  /// **'寄付を記録しました（このロットの残り {remaining}食）'**
  String donationRecorded(int remaining);

  /// No description provided for @donationTitle.
  ///
  /// In ja, this message translates to:
  /// **'未販売分の寄付記録'**
  String get donationTitle;

  /// No description provided for @donationLockedNotice.
  ///
  /// In ja, this message translates to:
  /// **'全ての販売地点を出発した後に寄付を記録できます（出発後は販売できなくなるため、在庫が確定します）。'**
  String get donationLockedNotice;

  /// No description provided for @noConfirmedBatches.
  ///
  /// In ja, this message translates to:
  /// **'確定済みのロットがありません'**
  String get noConfirmedBatches;

  /// No description provided for @donationQtyLabel.
  ///
  /// In ja, this message translates to:
  /// **'寄付数量'**
  String get donationQtyLabel;

  /// No description provided for @donationRecipientLabel.
  ///
  /// In ja, this message translates to:
  /// **'寄付先'**
  String get donationRecipientLabel;

  /// No description provided for @donationRecipientHint.
  ///
  /// In ja, this message translates to:
  /// **'例：○○こども食堂'**
  String get donationRecipientHint;

  /// No description provided for @donationHandedOverCheck.
  ///
  /// In ja, this message translates to:
  /// **'寄付先への引き渡しを確認しました'**
  String get donationHandedOverCheck;

  /// No description provided for @recordDonationButton.
  ///
  /// In ja, this message translates to:
  /// **'寄付を記録する'**
  String get recordDonationButton;

  /// No description provided for @driverLicenseTitle.
  ///
  /// In ja, this message translates to:
  /// **'運転免許証'**
  String get driverLicenseTitle;

  /// No description provided for @licenseStatusNone.
  ///
  /// In ja, this message translates to:
  /// **'未提出'**
  String get licenseStatusNone;

  /// No description provided for @licenseStatusSubmitted.
  ///
  /// In ja, this message translates to:
  /// **'確認待ち'**
  String get licenseStatusSubmitted;

  /// No description provided for @licenseStatusVerified.
  ///
  /// In ja, this message translates to:
  /// **'確認済み'**
  String get licenseStatusVerified;

  /// No description provided for @licenseStatusRejected.
  ///
  /// In ja, this message translates to:
  /// **'差し戻し'**
  String get licenseStatusRejected;

  /// No description provided for @licenseNoneBody.
  ///
  /// In ja, this message translates to:
  /// **'運転免許証を撮影して提出してください。運営が確認するまでシフトには入れません。'**
  String get licenseNoneBody;

  /// No description provided for @licenseSubmittedBody.
  ///
  /// In ja, this message translates to:
  /// **'運営が確認しています。確認が終わるとシフトに入れるようになります。'**
  String get licenseSubmittedBody;

  /// No description provided for @licenseExpiresOn.
  ///
  /// In ja, this message translates to:
  /// **'有効期限 {date}'**
  String licenseExpiresOn(String date);

  /// No description provided for @licenseRejectedLabel.
  ///
  /// In ja, this message translates to:
  /// **'運営からのメッセージ'**
  String get licenseRejectedLabel;

  /// No description provided for @licenseUploadButton.
  ///
  /// In ja, this message translates to:
  /// **'撮影してアップロード'**
  String get licenseUploadButton;

  /// No description provided for @licenseResubmitButton.
  ///
  /// In ja, this message translates to:
  /// **'更新した免許証を提出する'**
  String get licenseResubmitButton;

  /// No description provided for @licenseResubmitNote.
  ///
  /// In ja, this message translates to:
  /// **'提出し直すと、運営が確認するまで新しいシフトに入れません。'**
  String get licenseResubmitNote;

  /// No description provided for @licensePrivacyNote.
  ///
  /// In ja, this message translates to:
  /// **'画像は運営だけが見られます。'**
  String get licensePrivacyNote;

  /// No description provided for @licenseSourceCamera.
  ///
  /// In ja, this message translates to:
  /// **'カメラで撮影'**
  String get licenseSourceCamera;

  /// No description provided for @licenseSourceGallery.
  ///
  /// In ja, this message translates to:
  /// **'写真から選ぶ'**
  String get licenseSourceGallery;

  /// No description provided for @licenseUploadSuccess.
  ///
  /// In ja, this message translates to:
  /// **'提出しました。運営の確認をお待ちください。'**
  String get licenseUploadSuccess;

  /// No description provided for @licenseUploadError.
  ///
  /// In ja, this message translates to:
  /// **'提出できませんでした。通信状態を確認して、もう一度お試しください。'**
  String get licenseUploadError;

  /// No description provided for @upcomingShiftsTitle.
  ///
  /// In ja, this message translates to:
  /// **'今後のシフト（{days}日間）'**
  String upcomingShiftsTitle(int days);

  /// No description provided for @upcomingShiftsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'予定されたシフトはありません。運営がシフトを入れると、ここに表示されます。'**
  String get upcomingShiftsEmpty;

  /// No description provided for @shiftsLoadError.
  ///
  /// In ja, this message translates to:
  /// **'シフトを取得できませんでした。'**
  String get shiftsLoadError;

  /// QR読み取り画面のライト（懐中電灯）ボタン。夜間の受け渡しで暗い時に使う
  ///
  /// In ja, this message translates to:
  /// **'ライトをつける'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In ja, this message translates to:
  /// **'ライトを消す'**
  String get torchOff;

  /// No description provided for @mealPhotoLabel.
  ///
  /// In ja, this message translates to:
  /// **'料理の写真'**
  String get mealPhotoLabel;

  /// SCR-M04: 店舗が料理の写真を登録したロット（0038）。写真が無いときは detailNote（イメージ写真）
  ///
  /// In ja, this message translates to:
  /// **'写真は店舗が登録した料理です。数量や盛り付けは写真と異なる場合があります。アレルギーをお持ちの方は表示をご確認ください。'**
  String get detailNotePhoto;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
