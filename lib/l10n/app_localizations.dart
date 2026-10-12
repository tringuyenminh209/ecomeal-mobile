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

  /// No description provided for @languageToggleBoth.
  ///
  /// In ja, this message translates to:
  /// **'日本語 / English'**
  String get languageToggleBoth;

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

  /// No description provided for @storeAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal Store'**
  String get storeAppTitle;

  /// No description provided for @adminAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal Admin'**
  String get adminAppTitle;

  /// No description provided for @storeBadge.
  ///
  /// In ja, this message translates to:
  /// **'店舗'**
  String get storeBadge;

  /// No description provided for @storeLoginLead.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal から発行された店舗用アカウントでログインしてください。'**
  String get storeLoginLead;

  /// No description provided for @storeLoginNote.
  ///
  /// In ja, this message translates to:
  /// **'店舗の新規登録は Web 管理画面（ecomeal-pi.vercel.app）から申し込めます。'**
  String get storeLoginNote;

  /// No description provided for @adminBadge.
  ///
  /// In ja, this message translates to:
  /// **'運営'**
  String get adminBadge;

  /// No description provided for @adminLoginLead.
  ///
  /// In ja, this message translates to:
  /// **'運営アカウントでログインしてください。この後、2段階認証のコードを入力します。'**
  String get adminLoginLead;

  /// No description provided for @storeOnlyAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'店舗専用アプリです'**
  String get storeOnlyAppTitle;

  /// No description provided for @storeOnlyAppBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様は「EcoMeal」、ドライバーの方は「EcoMeal Driver」アプリをご利用ください。'**
  String get storeOnlyAppBody;

  /// No description provided for @adminOnlyAppTitle.
  ///
  /// In ja, this message translates to:
  /// **'運営専用アプリです'**
  String get adminOnlyAppTitle;

  /// No description provided for @adminOnlyAppBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様は「EcoMeal」、飲食店は「EcoMeal Store」、ドライバーの方は「EcoMeal Driver」アプリをご利用ください。'**
  String get adminOnlyAppBody;

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
  /// **'支払い情報は、決済代行会社が安全に処理します。'**
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
  /// **'カード情報は暗号化され、決済代行会社が安全に管理します。\nデフォルトカードを設定すると、ワンタップで支払えます。'**
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
  /// **'カード番号はEcoMealのサーバーに保存されず、決済代行会社が安全に管理します。セキュリティコードは他人に知らせないでください。'**
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
  /// **'ドライバーが数量を確認しています。数量が足りない場合は、受取地点ごとに予約の早い順で確保します。確保できなかった分は自動で返金します。'**
  String get pendingExplanation;

  /// No description provided for @allocatedExplanation.
  ///
  /// In ja, this message translates to:
  /// **'{stopName}で1袋を確保しました。QRコードと受け取りの時間・場所は「受け取りの案内」で確認できます。'**
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
  /// **'合計（税込・数量 {quantity}）'**
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
  /// **'この料理の数量はすでに確定しています'**
  String get errorBatchAlreadyConfirmed;

  /// No description provided for @errorStopNotOnRoute.
  ///
  /// In ja, this message translates to:
  /// **'選んだ停車地点は、この料理を運ぶルートにありません'**
  String get errorStopNotOnRoute;

  /// No description provided for @errorStopClosed.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点はすでに出発済みです'**
  String get errorStopClosed;

  /// No description provided for @errorTemperatureRange.
  ///
  /// In ja, this message translates to:
  /// **'温度は-30〜99.9℃の範囲で入力してください'**
  String get errorTemperatureRange;

  /// No description provided for @errorConfirmFailed.
  ///
  /// In ja, this message translates to:
  /// **'数量を確定できませんでした。もう一度お試しください'**
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
  /// **'冷蔵品は10℃以下を確認してください。基準外の場合は運営へ連絡します。'**
  String get coldChainNotice;

  /// No description provided for @coldChainOverLimit.
  ///
  /// In ja, this message translates to:
  /// **'基準（10℃以下）を超えています。この料理は回収・販売できません。'**
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
  /// **'この料理を回収しませんか？'**
  String get rejectPickupDialogTitle;

  /// No description provided for @rejectPickupDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'中心温度が{celsius}℃で、基準（10℃以下）を超えています。この料理は販売せず、予約はすべて返金されてお客様に通知されます。温度の記録は残ります。'**
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
  /// **'集荷する料理を選択'**
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
  /// **'位置情報を送信中'**
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
  /// **'この停車地点で予約なしで販売できる分は売り切れです'**
  String get errorWalkupSoldOut;

  /// No description provided for @errorWalkupNotConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'数量を確定する前は、予約なしの販売はできません'**
  String get errorWalkupNotConfirmed;

  /// No description provided for @errorBatchExpired.
  ///
  /// In ja, this message translates to:
  /// **'この料理は販売期限を過ぎています'**
  String get errorBatchExpired;

  /// No description provided for @errorDonationExceedsStock.
  ///
  /// In ja, this message translates to:
  /// **'寄付数量が残り在庫を超えています'**
  String get errorDonationExceedsStock;

  /// No description provided for @errorDonationNotConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'数量を確定する前は、寄付を記録できません'**
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
  /// **'予約なしの販売を記録しました（¥{price}）'**
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
  /// **'{count}件の予約が引き渡し待ちです。出発すると、これらの予約は「受け取りなし（失効）」として扱われ、返金されません。'**
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

  /// No description provided for @walkupTab.
  ///
  /// In ja, this message translates to:
  /// **'予約なし販売'**
  String get walkupTab;

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
  /// **'料理'**
  String get batchLabel;

  /// No description provided for @noWalkupBatches.
  ///
  /// In ja, this message translates to:
  /// **'この停車地点で販売できる料理はありません'**
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
  /// **'運行のまとめ'**
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
  /// **'寄付を記録しました（この料理の残り {remaining}食）'**
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
  /// **'数量を確定した料理がありません'**
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

  /// SCR-M10 のタイトル、SCR-M07「アプリについて」・SCR-M02 同意欄のリンク
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get legalTermsTitle;

  /// SCR-M11 のタイトル、SCR-M07・SCR-M02 のリンク
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get legalPrivacyTitle;

  /// 規約の版 currentTermsVersion と同じ日付
  ///
  /// In ja, this message translates to:
  /// **'改定日: 2026年10月11日（制定日: 2026年10月9日）'**
  String get legalEnactedOn;

  /// No description provided for @legalDemoNotice.
  ///
  /// In ja, this message translates to:
  /// **'卒業制作のデモ用の文面です。実運用の前に専門家の確認を受けます。'**
  String get legalDemoNotice;

  /// No description provided for @legalContactTitle.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get legalContactTitle;

  /// No description provided for @termsArticle1Title.
  ///
  /// In ja, this message translates to:
  /// **'第1条（適用）'**
  String get termsArticle1Title;

  /// No description provided for @termsArticle1Body.
  ///
  /// In ja, this message translates to:
  /// **'本規約は、EcoMeal（以下「当サービス」）のスマートフォンアプリの利用条件を定めるものです。利用者は、会員登録の際に本規約に同意したうえで当サービスを利用するものとします。'**
  String get termsArticle1Body;

  /// No description provided for @termsArticle2Title.
  ///
  /// In ja, this message translates to:
  /// **'第2条（アカウント）'**
  String get termsArticle2Title;

  /// No description provided for @termsArticle2Body.
  ///
  /// In ja, this message translates to:
  /// **'会員登録は、メールアドレスとパスワード、LINE、Apple のいずれかで行います。登録情報は正確に保ち、パスワードを第三者に知らせないでください。LINE・Apple で登録した場合も、同じ EcoMeal のアカウントとして本規約が適用されます。不正な利用が判明した場合、運営はアカウントの利用を停止することがあります。'**
  String get termsArticle2Body;

  /// No description provided for @termsArticle3Title.
  ///
  /// In ja, this message translates to:
  /// **'第3条（商品）'**
  String get termsArticle3Title;

  /// No description provided for @termsArticle3Body.
  ///
  /// In ja, this message translates to:
  /// **'当サービスで販売する料理は、提携店舗でその日に調理され余剰となったもの（ミステリーバッグ）です。内容・数量は日によって異なり、販売期限が近づくほど価格が下がります。アレルゲン（28品目）と原材料の産地は購入前にアプリでご確認ください。同じ厨房で調理しているため、微量の混入の可能性はゼロではありません。'**
  String get termsArticle3Body;

  /// No description provided for @termsArticle4Title.
  ///
  /// In ja, this message translates to:
  /// **'第4条（予約と支払い）'**
  String get termsArticle4Title;

  /// No description provided for @termsArticle4Body.
  ///
  /// In ja, this message translates to:
  /// **'予約は1日2件までです。支払いには登録したカードを使います。現在はテスト中のため、実際の請求は発生しません。カード番号・セキュリティコードは当サービスのサーバーに保存しません。'**
  String get termsArticle4Body;

  /// No description provided for @termsArticle5Title.
  ///
  /// In ja, this message translates to:
  /// **'第5条（キャンセル・返金）'**
  String get termsArticle5Title;

  /// No description provided for @termsArticle5Body.
  ///
  /// In ja, this message translates to:
  /// **'受取予定時刻の30分前までのキャンセルは全額返金、それ以降のキャンセルは返金なしとなります。数量不足で確保できなかった予約は自動で返金します。受取地点の出発時刻までに受け取られなかった予約は失効し、返金はありません。'**
  String get termsArticle5Body;

  /// No description provided for @termsArticle6Title.
  ///
  /// In ja, this message translates to:
  /// **'第6条（受け取り）'**
  String get termsArticle6Title;

  /// No description provided for @termsArticle6Body.
  ///
  /// In ja, this message translates to:
  /// **'予約した受取地点・時間帯に停車しているEco-Truckで、予約画面のQRコードまたは確認コードを提示して受け取ってください。'**
  String get termsArticle6Body;

  /// No description provided for @termsArticle7Title.
  ///
  /// In ja, this message translates to:
  /// **'第7条（位置情報・通知）'**
  String get termsArticle7Title;

  /// No description provided for @termsArticle7Body.
  ///
  /// In ja, this message translates to:
  /// **'位置情報は、近くの受取地点を表示するために端末内で使用し、サーバーには保存しません。お知らせ（トラックの接近、返金、問題の報告への回答、お気に入りの受取地点の新着）は、アプリの通知をオンにしていればアプリに届きます。オンにしていない場合は、LINE と連携していれば EcoMeal 公式アカウントから届きます。トラックの接近は、LINE と連携している場合は LINE に届きます。'**
  String get termsArticle7Body;

  /// No description provided for @termsArticle8Title.
  ///
  /// In ja, this message translates to:
  /// **'第8条（プロフィール写真）'**
  String get termsArticle8Title;

  /// No description provided for @termsArticle8Body.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール写真は、利用者本人のマイページにのみ表示されます。他人の肖像・著作物など第三者の権利を侵害する画像や、公序良俗に反する画像は登録できません。運営は不適切な画像を削除することがあります。'**
  String get termsArticle8Body;

  /// No description provided for @termsArticle9Title.
  ///
  /// In ja, this message translates to:
  /// **'第9条（禁止事項）'**
  String get termsArticle9Title;

  /// No description provided for @termsArticle9Body.
  ///
  /// In ja, this message translates to:
  /// **'法令に違反する行為、他の利用者・提携店舗・ドライバーへの迷惑行為、購入した商品の転売、当サービスへの不正アクセスを禁止します。'**
  String get termsArticle9Body;

  /// No description provided for @termsArticle10Title.
  ///
  /// In ja, this message translates to:
  /// **'第10条（変更・停止・免責）'**
  String get termsArticle10Title;

  /// No description provided for @termsArticle10Body.
  ///
  /// In ja, this message translates to:
  /// **'当サービスは卒業制作として開発・検証中であり、予告なく内容の変更・停止を行うことがあります。本規約を変更する場合はアプリでお知らせし、重要な変更は改めて同意をいただきます。'**
  String get termsArticle10Body;

  /// No description provided for @privacySection1Title.
  ///
  /// In ja, this message translates to:
  /// **'1. 取得する情報'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In ja, this message translates to:
  /// **'会員登録の情報（メールアドレス、表示名、フリガナ、プロフィール写真）、予約・購入の履歴、支払い方法（カードのブランド・下4桁・有効期限のみ）、LINE でログイン・連携したときの LINE ユーザーID、Apple でサインインしたときに Apple から受け取る ID とメールアドレス（Apple の非公開メールアドレスの場合を含む）、お問い合わせの内容、アプリの利用状況（フードバッグや予約画面を開いた記録）、不具合の情報（エラーの内容・端末の種類・アプリのバージョン）、通知を受け取るための端末の識別子を取得します。カード番号・セキュリティコードは当サービスでは取得・保存しません（決済代行会社が直接受け取ります）。'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In ja, this message translates to:
  /// **'2. 位置情報'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In ja, this message translates to:
  /// **'近くの受取地点を表示するために端末の位置情報を使いますが、サーバーには送信・保存しません。'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In ja, this message translates to:
  /// **'3. 利用目的'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In ja, this message translates to:
  /// **'予約・受け渡し・返金の処理、受け取りのお知らせ、お問い合わせへの回答、サービスの改善のために利用します。'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In ja, this message translates to:
  /// **'4. 第三者への提供・委託'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In ja, this message translates to:
  /// **'法令に基づく場合を除き、本人の同意なく第三者に提供しません。データの保管（Supabase）、地図の表示（Google マップ）、通知（LINE、Firebase Cloud Messaging）、決済（Stripe）、不具合の監視（Sentry）のため、各サービスに処理を委託します。'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In ja, this message translates to:
  /// **'5. 開示・訂正・削除のご請求'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In ja, this message translates to:
  /// **'登録情報の開示・訂正・削除のご請求は、お問い合わせフォームからご連絡ください。アカウントとプロフィール写真は、マイページからいつでも削除できます。'**
  String get privacySection5Body;

  /// SCR-M10 同意が必要（改定時・既存ユーザー、Figma 420:1136）
  ///
  /// In ja, this message translates to:
  /// **'利用規約が更新されました'**
  String get termsUpdatedTitle;

  /// No description provided for @termsUpdatedBody.
  ///
  /// In ja, this message translates to:
  /// **'EcoMealを引き続きご利用いただくには、最新の利用規約とプライバシーポリシーへの同意が必要です。'**
  String get termsUpdatedBody;

  /// No description provided for @termsAgreeAndContinue.
  ///
  /// In ja, this message translates to:
  /// **'同意して続ける'**
  String get termsAgreeAndContinue;

  /// No description provided for @termsDeclineAndLogout.
  ///
  /// In ja, this message translates to:
  /// **'同意しない（ログアウト）'**
  String get termsDeclineAndLogout;

  /// No description provided for @errorTermsAcceptFailed.
  ///
  /// In ja, this message translates to:
  /// **'同意を記録できませんでした。もう一度お試しください'**
  String get errorTermsAcceptFailed;

  /// SCR-M02 同意欄: Before + 利用規約(リンク) + Between + プライバシーポリシー(リンク) + After
  ///
  /// In ja, this message translates to:
  /// **''**
  String get signupConsentBefore;

  /// No description provided for @signupConsentBetween.
  ///
  /// In ja, this message translates to:
  /// **'と'**
  String get signupConsentBetween;

  /// No description provided for @signupConsentAfter.
  ///
  /// In ja, this message translates to:
  /// **'に同意します'**
  String get signupConsentAfter;

  /// No description provided for @signupConsentHint.
  ///
  /// In ja, this message translates to:
  /// **'同意すると「登録する」を押せます。リンクから全文を確認できます。'**
  String get signupConsentHint;

  /// SCR-M07 のカード見出し（Figma 419:5532）
  ///
  /// In ja, this message translates to:
  /// **'アプリについて'**
  String get aboutAppSection;

  /// No description provided for @appVersionLabel.
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get appVersionLabel;

  /// SCR-M08 写真なし（Figma 419:970）
  ///
  /// In ja, this message translates to:
  /// **'写真を設定'**
  String get profilePhotoSet;

  /// No description provided for @profilePhotoChange.
  ///
  /// In ja, this message translates to:
  /// **'写真を変更'**
  String get profilePhotoChange;

  /// No description provided for @profilePhotoHint.
  ///
  /// In ja, this message translates to:
  /// **'JPEG・PNG（10MBまで）。正方形に切り抜いて表示します。'**
  String get profilePhotoHint;

  /// No description provided for @profilePhotoUploading.
  ///
  /// In ja, this message translates to:
  /// **'写真をアップロードしています…'**
  String get profilePhotoUploading;

  /// No description provided for @errorProfilePhotoUpload.
  ///
  /// In ja, this message translates to:
  /// **'写真をアップロードできませんでした。通信状況を確認して、もう一度お試しください。'**
  String get errorProfilePhotoUpload;

  /// No description provided for @errorProfilePhotoInvalid.
  ///
  /// In ja, this message translates to:
  /// **'10MB以下のJPEG・PNGを選んでください'**
  String get errorProfilePhotoInvalid;

  /// No description provided for @profilePhotoSheetTitle.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール写真'**
  String get profilePhotoSheetTitle;

  /// No description provided for @profilePhotoTake.
  ///
  /// In ja, this message translates to:
  /// **'写真を撮る'**
  String get profilePhotoTake;

  /// No description provided for @profilePhotoLibrary.
  ///
  /// In ja, this message translates to:
  /// **'ライブラリから選ぶ'**
  String get profilePhotoLibrary;

  /// No description provided for @profilePhotoDelete.
  ///
  /// In ja, this message translates to:
  /// **'写真を削除'**
  String get profilePhotoDelete;

  /// No description provided for @profilePhotoDeleted.
  ///
  /// In ja, this message translates to:
  /// **'写真を削除しました'**
  String get profilePhotoDeleted;

  /// No description provided for @photoAccessDeniedTitle.
  ///
  /// In ja, this message translates to:
  /// **'カメラ（写真）へのアクセスが許可されていません'**
  String get photoAccessDeniedTitle;

  /// No description provided for @openSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get openSettings;

  /// No description provided for @photoAccessDeniedBody.
  ///
  /// In ja, this message translates to:
  /// **'端末の設定で、EcoMealにカメラと写真へのアクセスを許可してください。'**
  String get photoAccessDeniedBody;

  /// No description provided for @deleteAccountLink.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除'**
  String get deleteAccountLink;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountLead.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除すると、EcoMealにログインできなくなります。この操作は取り消せません。'**
  String get deleteAccountLead;

  /// No description provided for @deleteAccountRemovedTitle.
  ///
  /// In ja, this message translates to:
  /// **'削除されるもの'**
  String get deleteAccountRemovedTitle;

  /// No description provided for @deleteAccountRemoved1.
  ///
  /// In ja, this message translates to:
  /// **'・メールアドレス、表示名、フリガナ、プロフィール写真'**
  String get deleteAccountRemoved1;

  /// No description provided for @deleteAccountRemoved2.
  ///
  /// In ja, this message translates to:
  /// **'・登録したカード（ブランド・下4桁・有効期限）'**
  String get deleteAccountRemoved2;

  /// No description provided for @deleteAccountRemoved3.
  ///
  /// In ja, this message translates to:
  /// **'・LINE連携と、トラック接近のお知らせ'**
  String get deleteAccountRemoved3;

  /// No description provided for @deleteAccountKeptTitle.
  ///
  /// In ja, this message translates to:
  /// **'残るもの（あなたと結びつかない形で）'**
  String get deleteAccountKeptTitle;

  /// No description provided for @deleteAccountKeptBody.
  ///
  /// In ja, this message translates to:
  /// **'過去の予約・購入の記録は、売上と店舗への還元の計算のため、氏名・メールアドレスを外して保存します。'**
  String get deleteAccountKeptBody;

  /// No description provided for @deleteAccountNote.
  ///
  /// In ja, this message translates to:
  /// **'受け取り前の予約がある場合は、キャンセルするか受け取ってから削除してください。LINEのEcoMeal公式アカウントの友だち登録は、LINEアプリから解除できます。'**
  String get deleteAccountNote;

  /// No description provided for @deleteAccountOpenOrders.
  ///
  /// In ja, this message translates to:
  /// **'受け取り前の予約があります。予約タブでキャンセルするか、受け取ってから削除してください。'**
  String get deleteAccountOpenOrders;

  /// No description provided for @deleteAccountButton.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除する'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除しますか？'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'この操作は取り消せません。予約・購入の記録は個人が分からない形で残ります。'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ja, this message translates to:
  /// **'削除する'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除しました'**
  String get accountDeleted;

  /// No description provided for @errorDeleteAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウントを削除できませんでした。もう一度お試しください'**
  String get errorDeleteAccount;

  /// No description provided for @legalTokushohoTitle.
  ///
  /// In ja, this message translates to:
  /// **'特定商取引法に基づく表記'**
  String get legalTokushohoTitle;

  /// No description provided for @taxIncludedLine.
  ///
  /// In ja, this message translates to:
  /// **'うち消費税（{rate}%）'**
  String taxIncludedLine(int rate);

  /// No description provided for @priceTaxIncluded.
  ///
  /// In ja, this message translates to:
  /// **'{price}（税込）'**
  String priceTaxIncluded(String price);

  /// No description provided for @receiptButton.
  ///
  /// In ja, this message translates to:
  /// **'領収書'**
  String get receiptButton;

  /// No description provided for @receiptTitle.
  ///
  /// In ja, this message translates to:
  /// **'領収書'**
  String get receiptTitle;

  /// No description provided for @receiptAddressee.
  ///
  /// In ja, this message translates to:
  /// **'{name} 様'**
  String receiptAddressee(String name);

  /// No description provided for @receiptPurpose.
  ///
  /// In ja, this message translates to:
  /// **'但し 食品代として'**
  String get receiptPurpose;

  /// No description provided for @receiptTaxableLine.
  ///
  /// In ja, this message translates to:
  /// **'{rate}%対象（税込）'**
  String receiptTaxableLine(int rate);

  /// No description provided for @receiptUsedOn.
  ///
  /// In ja, this message translates to:
  /// **'ご利用日'**
  String get receiptUsedOn;

  /// No description provided for @receiptOrderNumber.
  ///
  /// In ja, this message translates to:
  /// **'注文番号'**
  String get receiptOrderNumber;

  /// No description provided for @receiptPaymentMethod.
  ///
  /// In ja, this message translates to:
  /// **'お支払い方法'**
  String get receiptPaymentMethod;

  /// No description provided for @receiptPaymentCard.
  ///
  /// In ja, this message translates to:
  /// **'クレジットカード'**
  String get receiptPaymentCard;

  /// No description provided for @receiptIssuedOn.
  ///
  /// In ja, this message translates to:
  /// **'発行日'**
  String get receiptIssuedOn;

  /// No description provided for @receiptIssuer.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal 運営チーム（卒業制作プロジェクト「栗まんじゅう」）'**
  String get receiptIssuer;

  /// No description provided for @receiptNote.
  ///
  /// In ja, this message translates to:
  /// **'※ 軽減税率（8%）対象の商品です。当サービスは適格請求書発行事業者の登録を受けていないため、登録番号の記載はありません。この画面を保存・印刷してご利用ください。'**
  String get receiptNote;

  /// No description provided for @stripeCardIncomplete.
  ///
  /// In ja, this message translates to:
  /// **'カード番号・有効期限・セキュリティコードを入力してください。'**
  String get stripeCardIncomplete;

  /// No description provided for @errorCardDeclined.
  ///
  /// In ja, this message translates to:
  /// **'このカードは登録できませんでした。別のカードをお試しください'**
  String get errorCardDeclined;

  /// No description provided for @pushSectionTitle.
  ///
  /// In ja, this message translates to:
  /// **'アプリの通知'**
  String get pushSectionTitle;

  /// No description provided for @pushOffTitle.
  ///
  /// In ja, this message translates to:
  /// **'アプリの通知'**
  String get pushOffTitle;

  /// No description provided for @pushOffBody.
  ///
  /// In ja, this message translates to:
  /// **'トラックの接近や返金を、このスマートフォンに通知します。'**
  String get pushOffBody;

  /// No description provided for @pushEnableButton.
  ///
  /// In ja, this message translates to:
  /// **'通知をオンにする'**
  String get pushEnableButton;

  /// No description provided for @pushOnTitle.
  ///
  /// In ja, this message translates to:
  /// **'通知はオンです'**
  String get pushOnTitle;

  /// No description provided for @pushOnBody.
  ///
  /// In ja, this message translates to:
  /// **'トラックの接近・返金・お気に入りの受取地点の新着をお知らせします。LINEと連携している場合、トラックの接近はLINEに届きます。'**
  String get pushOnBody;

  /// No description provided for @pushDeniedTitle.
  ///
  /// In ja, this message translates to:
  /// **'通知が許可されていません'**
  String get pushDeniedTitle;

  /// No description provided for @pushDeniedBody.
  ///
  /// In ja, this message translates to:
  /// **'端末の設定で、EcoMealの通知を許可してください。'**
  String get pushDeniedBody;

  /// No description provided for @errorPushEnable.
  ///
  /// In ja, this message translates to:
  /// **'通知をオンにできませんでした。もう一度お試しください'**
  String get errorPushEnable;

  /// No description provided for @reportIssueButton.
  ///
  /// In ja, this message translates to:
  /// **'問題を報告'**
  String get reportIssueButton;

  /// No description provided for @reportIssueTitle.
  ///
  /// In ja, this message translates to:
  /// **'問題を報告'**
  String get reportIssueTitle;

  /// No description provided for @reportIssueQuestion.
  ///
  /// In ja, this message translates to:
  /// **'どのような問題でしたか？'**
  String get reportIssueQuestion;

  /// No description provided for @issueCategoryWrongContents.
  ///
  /// In ja, this message translates to:
  /// **'内容・数量が予約と違う'**
  String get issueCategoryWrongContents;

  /// No description provided for @issueCategoryQuality.
  ///
  /// In ja, this message translates to:
  /// **'品質に問題がある（傷み・異物など）'**
  String get issueCategoryQuality;

  /// No description provided for @issueCategoryNotReceived.
  ///
  /// In ja, this message translates to:
  /// **'受け取れなかった'**
  String get issueCategoryNotReceived;

  /// No description provided for @issueCategoryOther.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get issueCategoryOther;

  /// No description provided for @reportIssueDetailLabel.
  ///
  /// In ja, this message translates to:
  /// **'詳しい内容'**
  String get reportIssueDetailLabel;

  /// No description provided for @reportIssueDetailHint.
  ///
  /// In ja, this message translates to:
  /// **'例：パンの一部にカビがありました'**
  String get reportIssueDetailHint;

  /// No description provided for @reportIssueNote.
  ///
  /// In ja, this message translates to:
  /// **'受け取りから48時間以内にご報告ください。運営が確認し、必要に応じて返金します（結果は通知と予約履歴でお知らせします）。'**
  String get reportIssueNote;

  /// No description provided for @reportIssueSubmit.
  ///
  /// In ja, this message translates to:
  /// **'報告を送信'**
  String get reportIssueSubmit;

  /// No description provided for @reportIssueSent.
  ///
  /// In ja, this message translates to:
  /// **'報告を送信しました'**
  String get reportIssueSent;

  /// No description provided for @errorReportIssueSelect.
  ///
  /// In ja, this message translates to:
  /// **'問題の種類を選んでください'**
  String get errorReportIssueSelect;

  /// No description provided for @errorReportIssueDetail.
  ///
  /// In ja, this message translates to:
  /// **'詳しい内容を入力してください（500文字以内）'**
  String get errorReportIssueDetail;

  /// No description provided for @errorReportIssueLate.
  ///
  /// In ja, this message translates to:
  /// **'受け取りから48時間を過ぎたため、アプリから報告できません。お問い合わせフォームからご連絡ください'**
  String get errorReportIssueLate;

  /// No description provided for @errorReportIssueDuplicate.
  ///
  /// In ja, this message translates to:
  /// **'この注文はすでに報告済みです'**
  String get errorReportIssueDuplicate;

  /// No description provided for @errorReportIssue.
  ///
  /// In ja, this message translates to:
  /// **'報告を送信できませんでした。もう一度お試しください'**
  String get errorReportIssue;

  /// No description provided for @issueOpenTitle.
  ///
  /// In ja, this message translates to:
  /// **'問題を報告しました（確認中）'**
  String get issueOpenTitle;

  /// No description provided for @issueOpenBody.
  ///
  /// In ja, this message translates to:
  /// **'運営が内容を確認し、必要に応じて返金します。結果はお知らせします。'**
  String get issueOpenBody;

  /// No description provided for @issueResolvedRefund.
  ///
  /// In ja, this message translates to:
  /// **'対応しました：¥{amount}を返金'**
  String issueResolvedRefund(int amount);

  /// No description provided for @issueResolvedNoRefund.
  ///
  /// In ja, this message translates to:
  /// **'対応しました'**
  String get issueResolvedNoRefund;

  /// No description provided for @favoriteStopsTitle.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの受取地点'**
  String get favoriteStopsTitle;

  /// No description provided for @favoriteStopsIntro.
  ///
  /// In ja, this message translates to:
  /// **'この受取地点に新しいフードバッグが出たら、アプリの通知（またはLINE）でお知らせします。最大5件まで登録できます。'**
  String get favoriteStopsIntro;

  /// No description provided for @favoriteStopsHint.
  ///
  /// In ja, this message translates to:
  /// **'地点をタップすると、今夜受け取れるフードバッグを見られます。★をタップすると解除できます。通知が届かない場合は、マイページの「アプリの通知」をオンにしてください。'**
  String get favoriteStopsHint;

  /// No description provided for @stopBagsHeading.
  ///
  /// In ja, this message translates to:
  /// **'今夜この受取地点で受け取れるフードバッグ'**
  String get stopBagsHeading;

  /// No description provided for @stopBagsEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'今夜はまだフードバッグがありません'**
  String get stopBagsEmptyTitle;

  /// No description provided for @stopBagsEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'この受取地点に新しいフードバッグが出たら、アプリの通知（またはLINE）でお知らせします。'**
  String get stopBagsEmptyBody;

  /// No description provided for @favoriteStopsEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの受取地点はまだありません'**
  String get favoriteStopsEmptyTitle;

  /// No description provided for @favoriteStopsEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'フードバッグ詳細の受け取り欄にある☆をタップすると、その受取地点に新しいフードバッグが出たときにお知らせします。'**
  String get favoriteStopsEmptyBody;

  /// No description provided for @favoriteStopsRowNone.
  ///
  /// In ja, this message translates to:
  /// **'未登録 ・ 新しいフードバッグをお知らせ'**
  String get favoriteStopsRowNone;

  /// No description provided for @favoriteStopsRowCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}件 ・ 新しいフードバッグをお知らせ'**
  String favoriteStopsRowCount(int count);

  /// No description provided for @favoriteAdded.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りに追加しました。この受取地点に新しいフードバッグが出たらお知らせします'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りから外しました'**
  String get favoriteRemoved;

  /// No description provided for @favoriteLimitReached.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの受取地点は5件まで登録できます。マイページから整理してください'**
  String get favoriteLimitReached;

  /// No description provided for @favoriteUpdateFailed.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りを更新できませんでした。時間をおいて再度お試しください'**
  String get favoriteUpdateFailed;

  /// No description provided for @favoriteAddTooltip.
  ///
  /// In ja, this message translates to:
  /// **'この受取地点をお気に入りに追加'**
  String get favoriteAddTooltip;

  /// No description provided for @favoriteRemoveTooltip.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りから外す'**
  String get favoriteRemoveTooltip;

  /// No description provided for @ratingPromptTitle.
  ///
  /// In ja, this message translates to:
  /// **'フードバッグはいかがでしたか？'**
  String get ratingPromptTitle;

  /// No description provided for @ratingPromptHint.
  ///
  /// In ja, this message translates to:
  /// **'星をタップして評価（受け取りから7日以内）'**
  String get ratingPromptHint;

  /// No description provided for @ratingLabel1.
  ///
  /// In ja, this message translates to:
  /// **'不満'**
  String get ratingLabel1;

  /// No description provided for @ratingLabel2.
  ///
  /// In ja, this message translates to:
  /// **'やや不満'**
  String get ratingLabel2;

  /// No description provided for @ratingLabel3.
  ///
  /// In ja, this message translates to:
  /// **'ふつう'**
  String get ratingLabel3;

  /// No description provided for @ratingLabel4.
  ///
  /// In ja, this message translates to:
  /// **'満足'**
  String get ratingLabel4;

  /// No description provided for @ratingLabel5.
  ///
  /// In ja, this message translates to:
  /// **'とても満足'**
  String get ratingLabel5;

  /// No description provided for @ratingStarSemantics.
  ///
  /// In ja, this message translates to:
  /// **'星{count}つ'**
  String ratingStarSemantics(int count);

  /// No description provided for @ratingSheetOrder.
  ///
  /// In ja, this message translates to:
  /// **'注文 #{number} ・ {time} 受け取り'**
  String ratingSheetOrder(String number, String time);

  /// No description provided for @ratingCommentLabel.
  ///
  /// In ja, this message translates to:
  /// **'お店へのひとこと（任意）'**
  String get ratingCommentLabel;

  /// No description provided for @ratingCommentHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 量がたっぷりで、温かいまま受け取れました。'**
  String get ratingCommentHint;

  /// No description provided for @ratingPrivacyNote.
  ///
  /// In ja, this message translates to:
  /// **'評価はお名前を出さずにお店に届きます。個人情報は書かないでください。'**
  String get ratingPrivacyNote;

  /// No description provided for @ratingSubmit.
  ///
  /// In ja, this message translates to:
  /// **'評価を送信'**
  String get ratingSubmit;

  /// No description provided for @ratingSent.
  ///
  /// In ja, this message translates to:
  /// **'評価を送信しました。ありがとうございました'**
  String get ratingSent;

  /// No description provided for @ratingErrorExpired.
  ///
  /// In ja, this message translates to:
  /// **'受け取りから7日を過ぎたため評価できません'**
  String get ratingErrorExpired;

  /// No description provided for @ratingErrorAlreadyRated.
  ///
  /// In ja, this message translates to:
  /// **'この注文はすでに評価済みです'**
  String get ratingErrorAlreadyRated;

  /// No description provided for @ratingErrorFailed.
  ///
  /// In ja, this message translates to:
  /// **'評価を送信できませんでした。もう一度お試しください'**
  String get ratingErrorFailed;

  /// No description provided for @ratedLabel.
  ///
  /// In ja, this message translates to:
  /// **'あなたの評価'**
  String get ratedLabel;

  /// No description provided for @ratedThanks.
  ///
  /// In ja, this message translates to:
  /// **'ありがとうございました'**
  String get ratedThanks;

  /// No description provided for @ratedSemantics.
  ///
  /// In ja, this message translates to:
  /// **'あなたの評価 星{count}つ'**
  String ratedSemantics(int count);

  /// No description provided for @impactTitle.
  ///
  /// In ja, this message translates to:
  /// **'あなたが救った食品'**
  String get impactTitle;

  /// No description provided for @impactEmpty.
  ///
  /// In ja, this message translates to:
  /// **'フードバッグを受け取ると、ここに救った食品の量とCO₂の削減量が表示されます。'**
  String get impactEmpty;

  /// No description provided for @impactBagsValue.
  ///
  /// In ja, this message translates to:
  /// **'{count}個'**
  String impactBagsValue(int count);

  /// No description provided for @impactBagsLabel.
  ///
  /// In ja, this message translates to:
  /// **'受け取ったフードバッグ'**
  String get impactBagsLabel;

  /// No description provided for @impactFoodLabel.
  ///
  /// In ja, this message translates to:
  /// **'救った食品'**
  String get impactFoodLabel;

  /// No description provided for @impactCo2Label.
  ///
  /// In ja, this message translates to:
  /// **'CO₂削減'**
  String get impactCo2Label;

  /// No description provided for @impactApproxKg.
  ///
  /// In ja, this message translates to:
  /// **'約{kg}kg'**
  String impactApproxKg(String kg);

  /// No description provided for @impactNote.
  ///
  /// In ja, this message translates to:
  /// **'推定値です（1袋 約{bagKg}kg、食品ロス1kgあたりCO₂ 約{factor}kg で計算）'**
  String impactNote(String bagKg, String factor);

  /// No description provided for @couponsTitle.
  ///
  /// In ja, this message translates to:
  /// **'クーポン・友だち紹介'**
  String get couponsTitle;

  /// No description provided for @couponsRowSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'クーポン{count}枚 ・ 友だちを紹介して¥100'**
  String couponsRowSubtitle(int count);

  /// No description provided for @couponSectionLabel.
  ///
  /// In ja, this message translates to:
  /// **'クーポン'**
  String get couponSectionLabel;

  /// No description provided for @subtotalLabel.
  ///
  /// In ja, this message translates to:
  /// **'小計'**
  String get subtotalLabel;

  /// No description provided for @couponAmountOff.
  ///
  /// In ja, this message translates to:
  /// **'¥{amount}引き'**
  String couponAmountOff(int amount);

  /// No description provided for @couponValidUntil.
  ///
  /// In ja, this message translates to:
  /// **'{date}まで'**
  String couponValidUntil(String date);

  /// No description provided for @couponReasonWelcome.
  ///
  /// In ja, this message translates to:
  /// **'友だち紹介クーポン（ようこそ）'**
  String get couponReasonWelcome;

  /// No description provided for @couponReasonReward.
  ///
  /// In ja, this message translates to:
  /// **'友だち紹介クーポン（お礼）'**
  String get couponReasonReward;

  /// No description provided for @couponReasonCampaign.
  ///
  /// In ja, this message translates to:
  /// **'キャンペーンクーポン'**
  String get couponReasonCampaign;

  /// No description provided for @couponsUsableHeading.
  ///
  /// In ja, this message translates to:
  /// **'使えるクーポン'**
  String get couponsUsableHeading;

  /// No description provided for @couponsNone.
  ///
  /// In ja, this message translates to:
  /// **'使えるクーポンはありません'**
  String get couponsNone;

  /// No description provided for @couponsAutoNote.
  ///
  /// In ja, this message translates to:
  /// **'クーポンは予約内容の確認画面で自動的に使われます（1回の予約に1枚）。無料キャンセルの期間内にキャンセルすると戻ります。'**
  String get couponsAutoNote;

  /// No description provided for @errorCouponUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'このクーポンは使えなくなりました。内容を確認して、もう一度お試しください'**
  String get errorCouponUnavailable;

  /// No description provided for @receiptCouponLine.
  ///
  /// In ja, this message translates to:
  /// **'クーポン値引き'**
  String get receiptCouponLine;

  /// No description provided for @referralMyCodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'あなたの紹介コード'**
  String get referralMyCodeLabel;

  /// No description provided for @referralCopy.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get referralCopy;

  /// No description provided for @referralCopied.
  ///
  /// In ja, this message translates to:
  /// **'紹介コードをコピーしました'**
  String get referralCopied;

  /// No description provided for @referralShareLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEで送る'**
  String get referralShareLine;

  /// No description provided for @referralShareText.
  ///
  /// In ja, this message translates to:
  /// **'EcoMealで余ったお弁当をお得に受け取れます。登録して紹介コード「{code}」を入力すると¥100クーポンがもらえます。'**
  String referralShareText(String code);

  /// No description provided for @referralHowItWorks.
  ///
  /// In ja, this message translates to:
  /// **'友だちがこのコードを入力すると、友だちに¥100クーポン。友だちが最初のフードバッグを受け取ると、あなたにも¥100クーポンが届きます。'**
  String get referralHowItWorks;

  /// No description provided for @referralEnterLabel.
  ///
  /// In ja, this message translates to:
  /// **'友だちの紹介コードを入力'**
  String get referralEnterLabel;

  /// No description provided for @referralEnterHint.
  ///
  /// In ja, this message translates to:
  /// **'例: EM3PX9'**
  String get referralEnterHint;

  /// No description provided for @referralApply.
  ///
  /// In ja, this message translates to:
  /// **'適用'**
  String get referralApply;

  /// No description provided for @referralEnterNote.
  ///
  /// In ja, this message translates to:
  /// **'登録から14日以内・最初のフードバッグを受け取る前まで使えます。'**
  String get referralEnterNote;

  /// No description provided for @referralApplied.
  ///
  /// In ja, this message translates to:
  /// **'紹介コード {code} を適用しました'**
  String referralApplied(String code);

  /// No description provided for @referralAppliedToast.
  ///
  /// In ja, this message translates to:
  /// **'¥100クーポンを受け取りました'**
  String get referralAppliedToast;

  /// No description provided for @referralErrorFormat.
  ///
  /// In ja, this message translates to:
  /// **'6文字の紹介コードを入力してください'**
  String get referralErrorFormat;

  /// No description provided for @referralErrorNotFound.
  ///
  /// In ja, this message translates to:
  /// **'この紹介コードは見つかりません'**
  String get referralErrorNotFound;

  /// No description provided for @referralErrorOwnCode.
  ///
  /// In ja, this message translates to:
  /// **'自分の紹介コードは使えません'**
  String get referralErrorOwnCode;

  /// No description provided for @referralErrorNotEligible.
  ///
  /// In ja, this message translates to:
  /// **'紹介コードを入力できる期間が過ぎています'**
  String get referralErrorNotEligible;

  /// No description provided for @referralErrorFailed.
  ///
  /// In ja, this message translates to:
  /// **'紹介コードを適用できませんでした。もう一度お試しください'**
  String get referralErrorFailed;

  /// No description provided for @socialLoginDivider.
  ///
  /// In ja, this message translates to:
  /// **'または'**
  String get socialLoginDivider;

  /// No description provided for @lineLoginButton.
  ///
  /// In ja, this message translates to:
  /// **'LINEでログイン'**
  String get lineLoginButton;

  /// No description provided for @appleLoginButton.
  ///
  /// In ja, this message translates to:
  /// **'Appleでサインイン'**
  String get appleLoginButton;

  /// No description provided for @socialLoginNote.
  ///
  /// In ja, this message translates to:
  /// **'初めての方は、LINE・Appleのアカウントで EcoMeal のアカウントが作成されます。'**
  String get socialLoginNote;

  /// No description provided for @lineLoginFailed.
  ///
  /// In ja, this message translates to:
  /// **'LINEでログインできませんでした。時間をおいて、もう一度お試しください'**
  String get lineLoginFailed;

  /// No description provided for @appleLoginFailed.
  ///
  /// In ja, this message translates to:
  /// **'Appleでサインインできませんでした。時間をおいて、もう一度お試しください'**
  String get appleLoginFailed;

  /// No description provided for @socialLoginNotCustomer.
  ///
  /// In ja, this message translates to:
  /// **'このアカウントはLINEでログインできません。メールアドレスとパスワードでログインしてください'**
  String get socialLoginNotCustomer;

  /// No description provided for @signedInWithLine.
  ///
  /// In ja, this message translates to:
  /// **'LINEでログイン中'**
  String get signedInWithLine;

  /// No description provided for @storeReviewPendingTitle.
  ///
  /// In ja, this message translates to:
  /// **'審査中です'**
  String get storeReviewPendingTitle;

  /// No description provided for @storeReviewPendingBody.
  ///
  /// In ja, this message translates to:
  /// **'運営が登録内容を確認しています。結果はメールとアプリの通知でお知らせします（通常2営業日以内）。'**
  String get storeReviewPendingBody;

  /// No description provided for @storeFieldName.
  ///
  /// In ja, this message translates to:
  /// **'店舗名'**
  String get storeFieldName;

  /// No description provided for @storeFieldAppliedAt.
  ///
  /// In ja, this message translates to:
  /// **'申請日'**
  String get storeFieldAppliedAt;

  /// No description provided for @storeFieldApplicant.
  ///
  /// In ja, this message translates to:
  /// **'申請者'**
  String get storeFieldApplicant;

  /// No description provided for @storeReviewRejectedTitle.
  ///
  /// In ja, this message translates to:
  /// **'承認できませんでした'**
  String get storeReviewRejectedTitle;

  /// No description provided for @storeReviewRejectedBody.
  ///
  /// In ja, this message translates to:
  /// **'内容を修正して、Web 管理画面からもう一度申請できます。'**
  String get storeReviewRejectedBody;

  /// No description provided for @storeRejectionReasonLabel.
  ///
  /// In ja, this message translates to:
  /// **'却下の理由'**
  String get storeRejectionReasonLabel;

  /// No description provided for @storeNotRegisteredTitle.
  ///
  /// In ja, this message translates to:
  /// **'店舗の登録がまだです'**
  String get storeNotRegisteredTitle;

  /// No description provided for @storeNotRegisteredBody.
  ///
  /// In ja, this message translates to:
  /// **'Web 管理画面から店舗の登録を申し込んでください。審査のあと、このアプリで余剰を登録できます。'**
  String get storeNotRegisteredBody;

  /// No description provided for @storeTabHome.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get storeTabHome;

  /// No description provided for @storeTabRegister.
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get storeTabRegister;

  /// No description provided for @storeTabSettlement.
  ///
  /// In ja, this message translates to:
  /// **'精算'**
  String get storeTabSettlement;

  /// No description provided for @storeTabSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get storeTabSettings;

  /// No description provided for @storeRegisterCta.
  ///
  /// In ja, this message translates to:
  /// **'今日の余剰を登録'**
  String get storeRegisterCta;

  /// No description provided for @storeRegisterDeadline.
  ///
  /// In ja, this message translates to:
  /// **'締め切り {time}（あと{remaining}）'**
  String storeRegisterDeadline(String time, String remaining);

  /// No description provided for @storeRegisterDeadlinePassed.
  ///
  /// In ja, this message translates to:
  /// **'締め切り {time} を過ぎています'**
  String storeRegisterDeadlinePassed(String time);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In ja, this message translates to:
  /// **'{hours}時間{minutes}分'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @storePhotoRemovedTitle.
  ///
  /// In ja, this message translates to:
  /// **'料理の写真が外されました'**
  String get storePhotoRemovedTitle;

  /// No description provided for @storePhotoRemovedHint.
  ///
  /// In ja, this message translates to:
  /// **'次回は店名・ロゴが写らない写真をお使いください。'**
  String get storePhotoRemovedHint;

  /// No description provided for @storePhotoRemovedAck.
  ///
  /// In ja, this message translates to:
  /// **'確認しました'**
  String get storePhotoRemovedAck;

  /// No description provided for @storeTodayBatches.
  ///
  /// In ja, this message translates to:
  /// **'今日の出品'**
  String get storeTodayBatches;

  /// No description provided for @storeBatchStatusEstimated.
  ///
  /// In ja, this message translates to:
  /// **'概算'**
  String get storeBatchStatusEstimated;

  /// No description provided for @storeBatchStatusOnSale.
  ///
  /// In ja, this message translates to:
  /// **'販売中'**
  String get storeBatchStatusOnSale;

  /// No description provided for @storeBatchStatusEnded.
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get storeBatchStatusEnded;

  /// No description provided for @storeSellBy.
  ///
  /// In ja, this message translates to:
  /// **'販売期限 {time}'**
  String storeSellBy(String time);

  /// No description provided for @storeCollectionPlanned.
  ///
  /// In ja, this message translates to:
  /// **'回収予定 {time}'**
  String storeCollectionPlanned(String time);

  /// No description provided for @storeBatchQtyConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'概算 {estimated}個 → 確定 {confirmed}個'**
  String storeBatchQtyConfirmed(int estimated, int confirmed);

  /// No description provided for @storeBatchQtyEstimated.
  ///
  /// In ja, this message translates to:
  /// **'概算 {estimated}個（回収待ち）'**
  String storeBatchQtyEstimated(int estimated);

  /// No description provided for @storeBatchCounts.
  ///
  /// In ja, this message translates to:
  /// **'予約 {reserved}件 ・ 受取 {pickedUp}件'**
  String storeBatchCounts(int reserved, int pickedUp);

  /// No description provided for @storeBatchReserved.
  ///
  /// In ja, this message translates to:
  /// **'予約 {reserved}件'**
  String storeBatchReserved(int reserved);

  /// No description provided for @storeNoBatchesTitle.
  ///
  /// In ja, this message translates to:
  /// **'今日の出品はまだありません'**
  String get storeNoBatchesTitle;

  /// No description provided for @storeNoBatchesBody.
  ///
  /// In ja, this message translates to:
  /// **'余りそうな料理があれば、16:00 までに概算で登録してください。今夜のルートに組み込まれます。'**
  String get storeNoBatchesBody;

  /// No description provided for @storeLoadErrorTitle.
  ///
  /// In ja, this message translates to:
  /// **'読み込めませんでした'**
  String get storeLoadErrorTitle;

  /// No description provided for @storeLoadErrorBody.
  ///
  /// In ja, this message translates to:
  /// **'通信状況を確認して、もう一度お試しください。'**
  String get storeLoadErrorBody;

  /// No description provided for @storeReload.
  ///
  /// In ja, this message translates to:
  /// **'再読み込み'**
  String get storeReload;

  /// No description provided for @storeMonthSales.
  ///
  /// In ja, this message translates to:
  /// **'今月の売上'**
  String get storeMonthSales;

  /// No description provided for @storeMonthSalesSub.
  ///
  /// In ja, this message translates to:
  /// **'{orders}食（{from}〜）'**
  String storeMonthSalesSub(int orders, String from);

  /// No description provided for @storeMonthPayout.
  ///
  /// In ja, this message translates to:
  /// **'今月の還元額'**
  String get storeMonthPayout;

  /// No description provided for @storeSharePct.
  ///
  /// In ja, this message translates to:
  /// **'還元率 {pct}%'**
  String storeSharePct(String pct);

  /// No description provided for @storeRatingsRow.
  ///
  /// In ja, this message translates to:
  /// **'お客様の評価 {average}'**
  String storeRatingsRow(String average);

  /// No description provided for @storeRatingsSub.
  ///
  /// In ja, this message translates to:
  /// **'直近30日・{count}件の評価'**
  String storeRatingsSub(int count);

  /// No description provided for @storeRatingsNone.
  ///
  /// In ja, this message translates to:
  /// **'まだ評価がありません'**
  String get storeRatingsNone;

  /// No description provided for @storeBatchDetailTitle.
  ///
  /// In ja, this message translates to:
  /// **'出品の詳細'**
  String get storeBatchDetailTitle;

  /// No description provided for @storeBatchPriceLine.
  ///
  /// In ja, this message translates to:
  /// **'{price}・販売期限 {time}'**
  String storeBatchPriceLine(String price, String time);

  /// No description provided for @storeStatConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'確定'**
  String get storeStatConfirmed;

  /// No description provided for @storeStatEstimated.
  ///
  /// In ja, this message translates to:
  /// **'概算'**
  String get storeStatEstimated;

  /// No description provided for @storeStatReserved.
  ///
  /// In ja, this message translates to:
  /// **'予約'**
  String get storeStatReserved;

  /// No description provided for @storeStatPickedUp.
  ///
  /// In ja, this message translates to:
  /// **'受取'**
  String get storeStatPickedUp;

  /// No description provided for @storeStatRemaining.
  ///
  /// In ja, this message translates to:
  /// **'残り'**
  String get storeStatRemaining;

  /// No description provided for @storeStatCollection.
  ///
  /// In ja, this message translates to:
  /// **'回収'**
  String get storeStatCollection;

  /// No description provided for @storeProgress.
  ///
  /// In ja, this message translates to:
  /// **'進み具合'**
  String get storeProgress;

  /// No description provided for @storeStepEstimated.
  ///
  /// In ja, this message translates to:
  /// **'概算登録'**
  String get storeStepEstimated;

  /// No description provided for @storeStepEstimatedDetail.
  ///
  /// In ja, this message translates to:
  /// **'{qty}個で登録'**
  String storeStepEstimatedDetail(int qty);

  /// No description provided for @storeStepCollected.
  ///
  /// In ja, this message translates to:
  /// **'回収・数量確定'**
  String get storeStepCollected;

  /// No description provided for @storeStepCollectedPlanned.
  ///
  /// In ja, this message translates to:
  /// **'{time} 予定'**
  String storeStepCollectedPlanned(String time);

  /// No description provided for @storeStepCollectedHint.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーが到着したら、実数を一緒に確認してください'**
  String get storeStepCollectedHint;

  /// No description provided for @storeStepCollectedBy.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー {name}'**
  String storeStepCollectedBy(String name);

  /// No description provided for @storeStepOnSale.
  ///
  /// In ja, this message translates to:
  /// **'販売中'**
  String get storeStepOnSale;

  /// No description provided for @storeStepOnSaleUntil.
  ///
  /// In ja, this message translates to:
  /// **'〜{time}'**
  String storeStepOnSaleUntil(String time);

  /// No description provided for @storeStepOnSaleDetail.
  ///
  /// In ja, this message translates to:
  /// **'{count}か所の受取地点で販売'**
  String storeStepOnSaleDetail(int count);

  /// No description provided for @storeStepEnded.
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get storeStepEnded;

  /// No description provided for @storeStepEndedDetail.
  ///
  /// In ja, this message translates to:
  /// **'売れ残りは寄付または廃棄として記録'**
  String get storeStepEndedDetail;

  /// No description provided for @storeStopsRemaining.
  ///
  /// In ja, this message translates to:
  /// **'受取地点ごとの残り'**
  String get storeStopsRemaining;

  /// No description provided for @storeAutoUpdate.
  ///
  /// In ja, this message translates to:
  /// **'自動更新'**
  String get storeAutoUpdate;

  /// No description provided for @storeStopRemaining.
  ///
  /// In ja, this message translates to:
  /// **'残り {remaining}'**
  String storeStopRemaining(int remaining);

  /// No description provided for @storeStopAllocated.
  ///
  /// In ja, this message translates to:
  /// **'/{allocated}個'**
  String storeStopAllocated(int allocated);

  /// No description provided for @storeEstimatedNote.
  ///
  /// In ja, this message translates to:
  /// **'回収時に数が予約より少ない場合は、予約の早い順に確保し、残りは自動で返金されます。'**
  String get storeEstimatedNote;

  /// No description provided for @storeBatchNotFound.
  ///
  /// In ja, this message translates to:
  /// **'この出品は見つかりませんでした'**
  String get storeBatchNotFound;

  /// No description provided for @storeTemperature.
  ///
  /// In ja, this message translates to:
  /// **'{celsius}℃'**
  String storeTemperature(String celsius);

  /// No description provided for @storeRegisterTitle.
  ///
  /// In ja, this message translates to:
  /// **'余剰を登録'**
  String get storeRegisterTitle;

  /// No description provided for @storeRegisterSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'概算 — 回収時にドライバーが数量を確定します'**
  String get storeRegisterSubtitle;

  /// No description provided for @storeRequired.
  ///
  /// In ja, this message translates to:
  /// **'必須'**
  String get storeRequired;

  /// No description provided for @storePhotoTake.
  ///
  /// In ja, this message translates to:
  /// **'料理の写真を撮る'**
  String get storePhotoTake;

  /// No description provided for @storePhotoRetake.
  ///
  /// In ja, this message translates to:
  /// **'撮り直す'**
  String get storePhotoRetake;

  /// No description provided for @storePhotoHint.
  ///
  /// In ja, this message translates to:
  /// **'店名・ロゴ・人の顔が写らないように撮ってください。'**
  String get storePhotoHint;

  /// No description provided for @storePhotoCamera.
  ///
  /// In ja, this message translates to:
  /// **'カメラで撮る'**
  String get storePhotoCamera;

  /// No description provided for @storePhotoLibrary.
  ///
  /// In ja, this message translates to:
  /// **'写真から選ぶ'**
  String get storePhotoLibrary;

  /// No description provided for @storePhotoRemove.
  ///
  /// In ja, this message translates to:
  /// **'写真を外す'**
  String get storePhotoRemove;

  /// No description provided for @storeQtyLabel.
  ///
  /// In ja, this message translates to:
  /// **'用意できそうな数'**
  String get storeQtyLabel;

  /// No description provided for @storeQtyUnit.
  ///
  /// In ja, this message translates to:
  /// **'個'**
  String get storeQtyUnit;

  /// No description provided for @storeQtyDecrease.
  ///
  /// In ja, this message translates to:
  /// **'1個減らす'**
  String get storeQtyDecrease;

  /// No description provided for @storeQtyIncrease.
  ///
  /// In ja, this message translates to:
  /// **'1個増やす'**
  String get storeQtyIncrease;

  /// No description provided for @storePriceLabel.
  ///
  /// In ja, this message translates to:
  /// **'単価（税込）'**
  String get storePriceLabel;

  /// No description provided for @storePriceHint.
  ///
  /// In ja, this message translates to:
  /// **'販売期限が近づくと、アプリで自動的に値引きされます（30〜70%）。'**
  String get storePriceHint;

  /// No description provided for @storeSellByLabel.
  ///
  /// In ja, this message translates to:
  /// **'販売期限'**
  String get storeSellByLabel;

  /// No description provided for @storeSellByToday.
  ///
  /// In ja, this message translates to:
  /// **'本日'**
  String get storeSellByToday;

  /// No description provided for @storeSellByTomorrow.
  ///
  /// In ja, this message translates to:
  /// **'翌日'**
  String get storeSellByTomorrow;

  /// No description provided for @storeSellByChange.
  ///
  /// In ja, this message translates to:
  /// **'変更'**
  String get storeSellByChange;

  /// No description provided for @storeAllergenLabel.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲン（28品目）'**
  String get storeAllergenLabel;

  /// No description provided for @storeAllergenShowAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて表示（28品目）'**
  String get storeAllergenShowAll;

  /// No description provided for @storeAllergenHint.
  ///
  /// In ja, this message translates to:
  /// **'該当するものをすべて選んでください。よく使う12品目を表示しています。どれも含まれない場合は「アレルゲンは含まれていません」にチェックを入れてください。'**
  String get storeAllergenHint;

  /// No description provided for @storeNoAllergens.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲンは含まれていません'**
  String get storeNoAllergens;

  /// No description provided for @storeErrAllergenRequired.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲンを選ぶか、「アレルゲンは含まれていません」にチェックを入れてください'**
  String get storeErrAllergenRequired;

  /// No description provided for @storeAllergenSelected.
  ///
  /// In ja, this message translates to:
  /// **'{count}品目を選択中'**
  String storeAllergenSelected(int count);

  /// No description provided for @storeAllergenSheetNote.
  ///
  /// In ja, this message translates to:
  /// **'選んだ内容は、閉じても登録画面に残ります。'**
  String get storeAllergenSheetNote;

  /// No description provided for @storeAllergenMandatory.
  ///
  /// In ja, this message translates to:
  /// **'表示義務（特定原材料・8品目）'**
  String get storeAllergenMandatory;

  /// No description provided for @storeAllergenRecommended.
  ///
  /// In ja, this message translates to:
  /// **'表示推奨（20品目）'**
  String get storeAllergenRecommended;

  /// No description provided for @storeAllergenClear.
  ///
  /// In ja, this message translates to:
  /// **'すべて解除'**
  String get storeAllergenClear;

  /// No description provided for @storeAllergenDone.
  ///
  /// In ja, this message translates to:
  /// **'決定（{count}品目）'**
  String storeAllergenDone(int count);

  /// No description provided for @storeAllergenLoadFailed.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲンの一覧を読み込めませんでした。'**
  String get storeAllergenLoadFailed;

  /// No description provided for @storeIngredientsLabel.
  ///
  /// In ja, this message translates to:
  /// **'主な原材料と産地'**
  String get storeIngredientsLabel;

  /// No description provided for @storeIngredientAdd.
  ///
  /// In ja, this message translates to:
  /// **'＋ 原材料を追加'**
  String get storeIngredientAdd;

  /// No description provided for @storeIngredientName.
  ///
  /// In ja, this message translates to:
  /// **'原材料'**
  String get storeIngredientName;

  /// No description provided for @storeIngredientOrigin.
  ///
  /// In ja, this message translates to:
  /// **'産地'**
  String get storeIngredientOrigin;

  /// No description provided for @storeIngredientOriginHint.
  ///
  /// In ja, this message translates to:
  /// **'例: 国産（鹿児島県）'**
  String get storeIngredientOriginHint;

  /// No description provided for @storeIngredientRemove.
  ///
  /// In ja, this message translates to:
  /// **'{name}を削除'**
  String storeIngredientRemove(String name);

  /// No description provided for @storeAdd.
  ///
  /// In ja, this message translates to:
  /// **'追加'**
  String get storeAdd;

  /// No description provided for @storeCancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get storeCancel;

  /// No description provided for @storeReviewButton.
  ///
  /// In ja, this message translates to:
  /// **'内容を確認する'**
  String get storeReviewButton;

  /// No description provided for @storeConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'この内容で登録しますか？'**
  String get storeConfirmTitle;

  /// No description provided for @storeConfirmQty.
  ///
  /// In ja, this message translates to:
  /// **'数'**
  String get storeConfirmQty;

  /// No description provided for @storeConfirmQtyValue.
  ///
  /// In ja, this message translates to:
  /// **'{qty}個'**
  String storeConfirmQtyValue(int qty);

  /// No description provided for @storeConfirmAllergens.
  ///
  /// In ja, this message translates to:
  /// **'アレルゲン'**
  String get storeConfirmAllergens;

  /// No description provided for @storeConfirmIngredients.
  ///
  /// In ja, this message translates to:
  /// **'原材料'**
  String get storeConfirmIngredients;

  /// No description provided for @storeConfirmNone.
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get storeConfirmNone;

  /// No description provided for @storeConfirmIngredientsMore.
  ///
  /// In ja, this message translates to:
  /// **'{first}ほか{more}件'**
  String storeConfirmIngredientsMore(String first, int more);

  /// No description provided for @storeConfirmNote.
  ///
  /// In ja, this message translates to:
  /// **'登録すると今夜のルートに組み込まれ、お客様の予約受付が始まります。'**
  String get storeConfirmNote;

  /// No description provided for @storeConfirmSubmit.
  ///
  /// In ja, this message translates to:
  /// **'登録する'**
  String get storeConfirmSubmit;

  /// No description provided for @storeConfirmBack.
  ///
  /// In ja, this message translates to:
  /// **'戻って修正する'**
  String get storeConfirmBack;

  /// No description provided for @storeSellByValue.
  ///
  /// In ja, this message translates to:
  /// **'{day} {time}'**
  String storeSellByValue(String day, String time);

  /// No description provided for @storeDoneTitle.
  ///
  /// In ja, this message translates to:
  /// **'登録しました'**
  String get storeDoneTitle;

  /// No description provided for @storeDoneBody.
  ///
  /// In ja, this message translates to:
  /// **'今夜のルートに組み込まれました。予約が入るとお知らせします。'**
  String get storeDoneBody;

  /// No description provided for @storeDoneCollection.
  ///
  /// In ja, this message translates to:
  /// **'回収予定'**
  String get storeDoneCollection;

  /// No description provided for @storeDoneCollectionValue.
  ///
  /// In ja, this message translates to:
  /// **'{time} ごろ'**
  String storeDoneCollectionValue(String time);

  /// No description provided for @storeDoneRoute.
  ///
  /// In ja, this message translates to:
  /// **'ルート'**
  String get storeDoneRoute;

  /// No description provided for @storeDoneRouteMore.
  ///
  /// In ja, this message translates to:
  /// **'{names}ほか'**
  String storeDoneRouteMore(String names);

  /// No description provided for @storeDoneViewBatch.
  ///
  /// In ja, this message translates to:
  /// **'出品を見る'**
  String get storeDoneViewBatch;

  /// No description provided for @storeDoneHome.
  ///
  /// In ja, this message translates to:
  /// **'ホームへ'**
  String get storeDoneHome;

  /// No description provided for @storeErrQty.
  ///
  /// In ja, this message translates to:
  /// **'1個以上を指定してください'**
  String get storeErrQty;

  /// No description provided for @storeErrPrice.
  ///
  /// In ja, this message translates to:
  /// **'単価は1円以上で入力してください'**
  String get storeErrPrice;

  /// No description provided for @storeErrSellByPast.
  ///
  /// In ja, this message translates to:
  /// **'販売期限は現在より後の時刻にしてください'**
  String get storeErrSellByPast;

  /// No description provided for @storeErrIngredientName.
  ///
  /// In ja, this message translates to:
  /// **'原材料名を入力してください'**
  String get storeErrIngredientName;

  /// No description provided for @storeErrPhotoUpload.
  ///
  /// In ja, this message translates to:
  /// **'写真をアップロードできませんでした。通信状態を確認して再度お試しいただくか、写真を外して登録してください。（まだ登録されていません）'**
  String get storeErrPhotoUpload;

  /// No description provided for @storeErrNotApproved.
  ///
  /// In ja, this message translates to:
  /// **'店舗の承認が完了していないため、登録できません。'**
  String get storeErrNotApproved;

  /// No description provided for @storeErrPhotoInvalid.
  ///
  /// In ja, this message translates to:
  /// **'写真を登録できませんでした。写真を選び直して、もう一度お試しください。'**
  String get storeErrPhotoInvalid;

  /// No description provided for @storeErrNoTruck.
  ///
  /// In ja, this message translates to:
  /// **'本日の担当トラックが割り当てられていないため、登録できません。EcoMeal運営にお問い合わせください。'**
  String get storeErrNoTruck;

  /// No description provided for @storeErrNoStops.
  ///
  /// In ja, this message translates to:
  /// **'受取地点が登録されていないため、登録できません。EcoMeal運営にお問い合わせください。'**
  String get storeErrNoStops;

  /// No description provided for @storeErrNoStopsLeft.
  ///
  /// In ja, this message translates to:
  /// **'本日の運行ルートでは、店舗の集荷後に販売できる受取地点が残っていないため、登録できません。'**
  String get storeErrNoStopsLeft;

  /// No description provided for @storeErrTruckDeparted.
  ///
  /// In ja, this message translates to:
  /// **'本日はトラックが既に店舗を出発したため、これ以上登録できません。'**
  String get storeErrTruckDeparted;

  /// No description provided for @storeErrRegisterFailed.
  ///
  /// In ja, this message translates to:
  /// **'登録できませんでした。通信状態を確認して、もう一度お試しください。'**
  String get storeErrRegisterFailed;

  /// No description provided for @storeSettlementTitle.
  ///
  /// In ja, this message translates to:
  /// **'精算'**
  String get storeSettlementTitle;

  /// No description provided for @storeSettlementSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'月ごとの売上と還元額'**
  String get storeSettlementSubtitle;

  /// No description provided for @storeSettlementCurrent.
  ///
  /// In ja, this message translates to:
  /// **'{month}（集計中）'**
  String storeSettlementCurrent(String month);

  /// No description provided for @storeSettlementCutoff.
  ///
  /// In ja, this message translates to:
  /// **'月末締め'**
  String get storeSettlementCutoff;

  /// No description provided for @storeSettlementEstimate.
  ///
  /// In ja, this message translates to:
  /// **'還元見込み {amount}'**
  String storeSettlementEstimate(String amount);

  /// No description provided for @storeSettlementCurrentSub.
  ///
  /// In ja, this message translates to:
  /// **'売上 {sales}・{orders}食・還元率 {pct}%'**
  String storeSettlementCurrentSub(String sales, int orders, String pct);

  /// No description provided for @storeSettlementStatements.
  ///
  /// In ja, this message translates to:
  /// **'精算書'**
  String get storeSettlementStatements;

  /// No description provided for @storeSettlementConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'確定'**
  String get storeSettlementConfirmed;

  /// No description provided for @storeSettlementPaid.
  ///
  /// In ja, this message translates to:
  /// **'振込済み'**
  String get storeSettlementPaid;

  /// No description provided for @storeSettlementRowConfirmed.
  ///
  /// In ja, this message translates to:
  /// **'{date} 確定・{orders}食'**
  String storeSettlementRowConfirmed(String date, int orders);

  /// No description provided for @storeSettlementRowPaid.
  ///
  /// In ja, this message translates to:
  /// **'{date} 振込・{orders}食'**
  String storeSettlementRowPaid(String date, int orders);

  /// No description provided for @storeSettlementNote.
  ///
  /// In ja, this message translates to:
  /// **'毎月末で締めて運営が確定します。振込が済むと、振込日がここに表示されます。'**
  String get storeSettlementNote;

  /// No description provided for @storeSettlementEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'精算書はまだありません'**
  String get storeSettlementEmptyTitle;

  /// No description provided for @storeSettlementEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'月末に締めたあと、運営が確定するとここに表示されます。'**
  String get storeSettlementEmptyBody;

  /// No description provided for @storeNoticeTitle.
  ///
  /// In ja, this message translates to:
  /// **'支払通知書'**
  String get storeNoticeTitle;

  /// No description provided for @storeNoticeFor.
  ///
  /// In ja, this message translates to:
  /// **'{month}分'**
  String storeNoticeFor(String month);

  /// No description provided for @storeNoticeAddressee.
  ///
  /// In ja, this message translates to:
  /// **'{name} 御中'**
  String storeNoticeAddressee(String name);

  /// No description provided for @storeNoticeIssued.
  ///
  /// In ja, this message translates to:
  /// **'発行: EcoMeal 運営チーム・{date}'**
  String storeNoticeIssued(String date);

  /// No description provided for @storeNoticeOrders.
  ///
  /// In ja, this message translates to:
  /// **'販売食数（受取完了）'**
  String get storeNoticeOrders;

  /// No description provided for @storeNoticeOrdersValue.
  ///
  /// In ja, this message translates to:
  /// **'{orders}食'**
  String storeNoticeOrdersValue(int orders);

  /// No description provided for @storeNoticeSales.
  ///
  /// In ja, this message translates to:
  /// **'売上（税込）'**
  String get storeNoticeSales;

  /// No description provided for @storeNoticePayout.
  ///
  /// In ja, this message translates to:
  /// **'お支払額'**
  String get storeNoticePayout;

  /// No description provided for @storeNoticeConfirmedAt.
  ///
  /// In ja, this message translates to:
  /// **'確定日'**
  String get storeNoticeConfirmedAt;

  /// No description provided for @storeNoticePaidAt.
  ///
  /// In ja, this message translates to:
  /// **'振込日'**
  String get storeNoticePaidAt;

  /// No description provided for @storeNoticeUnpaid.
  ///
  /// In ja, this message translates to:
  /// **'未振込（振込後に表示）'**
  String get storeNoticeUnpaid;

  /// No description provided for @storeNoticeNumber.
  ///
  /// In ja, this message translates to:
  /// **'精算番号'**
  String get storeNoticeNumber;

  /// No description provided for @storeNoticeFootnote.
  ///
  /// In ja, this message translates to:
  /// **'還元額は受け取りが完了した注文だけで、注文ごとの還元率で計算しています（返金・失効した注文は含みません）。'**
  String get storeNoticeFootnote;

  /// No description provided for @storeNoticePrintOnWeb.
  ///
  /// In ja, this message translates to:
  /// **'Web で印刷・PDF保存'**
  String get storeNoticePrintOnWeb;

  /// No description provided for @storeRatingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'お客様の評価'**
  String get storeRatingsTitle;

  /// No description provided for @storeRatingsPeriod.
  ///
  /// In ja, this message translates to:
  /// **'直近30日'**
  String get storeRatingsPeriod;

  /// No description provided for @storeRatingsCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}件の評価'**
  String storeRatingsCount(int count);

  /// No description provided for @storeRatingsRecent.
  ///
  /// In ja, this message translates to:
  /// **'最近のひとこと'**
  String get storeRatingsRecent;

  /// No description provided for @storeRatingsAnonymous.
  ///
  /// In ja, this message translates to:
  /// **'評価したお客様の名前は表示されません。'**
  String get storeRatingsAnonymous;

  /// No description provided for @storeRatingsEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様が受け取ったあと、7日以内に星とひとことで評価できます。'**
  String get storeRatingsEmptyBody;

  /// No description provided for @storeRatingStars.
  ///
  /// In ja, this message translates to:
  /// **'★{rating}'**
  String storeRatingStars(int rating);

  /// No description provided for @storeInquiryTitle.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get storeInquiryTitle;

  /// No description provided for @storeInquirySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'運営へのご連絡'**
  String get storeInquirySubtitle;

  /// No description provided for @storeInquiryLabel.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ内容'**
  String get storeInquiryLabel;

  /// No description provided for @storeInquiryHint.
  ///
  /// In ja, this message translates to:
  /// **'通常1営業日以内に、メールとアプリの通知でお返事します。'**
  String get storeInquiryHint;

  /// No description provided for @storeInquirySend.
  ///
  /// In ja, this message translates to:
  /// **'送信する'**
  String get storeInquirySend;

  /// No description provided for @storeInquirySent.
  ///
  /// In ja, this message translates to:
  /// **'送信しました'**
  String get storeInquirySent;

  /// No description provided for @storeInquirySendFailed.
  ///
  /// In ja, this message translates to:
  /// **'送信できませんでした。通信状態を確認して、もう一度お試しください。入力内容は残っています。'**
  String get storeInquirySendFailed;

  /// No description provided for @storeInquiryEmpty.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ内容を入力してください'**
  String get storeInquiryEmpty;

  /// No description provided for @storeInquiryHistory.
  ///
  /// In ja, this message translates to:
  /// **'これまでのお問い合わせ'**
  String get storeInquiryHistory;

  /// No description provided for @storeInquiryStatusNew.
  ///
  /// In ja, this message translates to:
  /// **'受付'**
  String get storeInquiryStatusNew;

  /// No description provided for @storeInquiryStatusInProgress.
  ///
  /// In ja, this message translates to:
  /// **'確認中'**
  String get storeInquiryStatusInProgress;

  /// No description provided for @storeInquiryStatusDone.
  ///
  /// In ja, this message translates to:
  /// **'対応済み'**
  String get storeInquiryStatusDone;

  /// No description provided for @storeInquiryStatusRejected.
  ///
  /// In ja, this message translates to:
  /// **'対応できませんでした'**
  String get storeInquiryStatusRejected;

  /// No description provided for @storeInquiryHistoryEmpty.
  ///
  /// In ja, this message translates to:
  /// **'まだお問い合わせはありません'**
  String get storeInquiryHistoryEmpty;

  /// No description provided for @storeAccountDeletionMessage.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除を希望します。'**
  String get storeAccountDeletionMessage;

  /// No description provided for @inboxTitle.
  ///
  /// In ja, this message translates to:
  /// **'お知らせ'**
  String get inboxTitle;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'お知らせはありません'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In ja, this message translates to:
  /// **'予約・回収・精算などがあるとここに表示され、通知でもお知らせします。'**
  String get inboxEmptyBody;

  /// No description provided for @inboxOpen.
  ///
  /// In ja, this message translates to:
  /// **'お知らせを開く'**
  String get inboxOpen;

  /// No description provided for @inboxUnread.
  ///
  /// In ja, this message translates to:
  /// **'未読 {count}件'**
  String inboxUnread(int count);

  /// No description provided for @inboxJustNow.
  ///
  /// In ja, this message translates to:
  /// **'たった今'**
  String get inboxJustNow;

  /// No description provided for @inboxMinutesAgo.
  ///
  /// In ja, this message translates to:
  /// **'{minutes}分前'**
  String inboxMinutesAgo(int minutes);

  /// No description provided for @inboxYesterday.
  ///
  /// In ja, this message translates to:
  /// **'昨日 {time}'**
  String inboxYesterday(String time);

  /// No description provided for @noticeRestaurantReviewedTitle.
  ///
  /// In ja, this message translates to:
  /// **'審査結果のお知らせ'**
  String get noticeRestaurantReviewedTitle;

  /// No description provided for @noticeRestaurantReviewedBody.
  ///
  /// In ja, this message translates to:
  /// **'審査が完了しました。結果をご確認ください。'**
  String get noticeRestaurantReviewedBody;

  /// No description provided for @noticeSettlementConfirmedTitle.
  ///
  /// In ja, this message translates to:
  /// **'精算が確定しました'**
  String get noticeSettlementConfirmedTitle;

  /// No description provided for @noticeSettlementConfirmedBody.
  ///
  /// In ja, this message translates to:
  /// **'精算画面で金額をご確認ください。'**
  String get noticeSettlementConfirmedBody;

  /// No description provided for @noticeSettlementPaidTitle.
  ///
  /// In ja, this message translates to:
  /// **'お振込みが完了しました'**
  String get noticeSettlementPaidTitle;

  /// No description provided for @noticeSettlementPaidBody.
  ///
  /// In ja, this message translates to:
  /// **'精算画面で振込日をご確認ください。'**
  String get noticeSettlementPaidBody;

  /// No description provided for @noticeBatchCollectedTitle.
  ///
  /// In ja, this message translates to:
  /// **'回収が完了しました'**
  String get noticeBatchCollectedTitle;

  /// No description provided for @noticeBatchCollectedBody.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーが料理を回収しました。確定した数量は出品の詳細でご確認ください。'**
  String get noticeBatchCollectedBody;

  /// No description provided for @noticeBatchPhotoRemovedTitle.
  ///
  /// In ja, this message translates to:
  /// **'料理の写真が外されました'**
  String get noticeBatchPhotoRemovedTitle;

  /// No description provided for @noticeBatchPhotoRemovedBody.
  ///
  /// In ja, this message translates to:
  /// **'運営が写真を外しました。理由はホームでご確認ください。'**
  String get noticeBatchPhotoRemovedBody;

  /// No description provided for @noticeRatingReceivedTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しい評価が届きました'**
  String get noticeRatingReceivedTitle;

  /// No description provided for @noticeRatingReceivedBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様から評価が届きました。'**
  String get noticeRatingReceivedBody;

  /// No description provided for @noticeGenericTitle.
  ///
  /// In ja, this message translates to:
  /// **'お知らせ'**
  String get noticeGenericTitle;

  /// No description provided for @inboxEmptyBodyCustomer.
  ///
  /// In ja, this message translates to:
  /// **'予約したフードバッグのトラックが近づいたときや、お気に入りの受取地点に新しいフードバッグが出たときにお知らせします。'**
  String get inboxEmptyBodyCustomer;

  /// No description provided for @noticeTruckApproachingTitle.
  ///
  /// In ja, this message translates to:
  /// **'Eco-Truckがまもなく到着します'**
  String get noticeTruckApproachingTitle;

  /// No description provided for @noticeTruckApproachingBody.
  ///
  /// In ja, this message translates to:
  /// **'{place}にまもなく到着します。予約画面のQRコードをご用意ください。'**
  String noticeTruckApproachingBody(String place);

  /// No description provided for @noticeTruckApproachingPlace.
  ///
  /// In ja, this message translates to:
  /// **'受取地点'**
  String get noticeTruckApproachingPlace;

  /// No description provided for @noticeNewBatchTitle.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの受取地点に新着'**
  String get noticeNewBatchTitle;

  /// No description provided for @noticeNewBatchBody.
  ///
  /// In ja, this message translates to:
  /// **'{place}で受け取れるフードバッグが出ました。売り切れる前にご予約ください。'**
  String noticeNewBatchBody(String place);

  /// No description provided for @noticeNewBatchPlace.
  ///
  /// In ja, this message translates to:
  /// **'お気に入りの受取地点'**
  String get noticeNewBatchPlace;

  /// No description provided for @noticeIssueResolvedTitle.
  ///
  /// In ja, this message translates to:
  /// **'ご報告に対応しました'**
  String get noticeIssueResolvedTitle;

  /// No description provided for @noticeIssueResolvedBody.
  ///
  /// In ja, this message translates to:
  /// **'対応内容は予約履歴でご確認ください。'**
  String get noticeIssueResolvedBody;

  /// No description provided for @noticeRefundedTitle.
  ///
  /// In ja, this message translates to:
  /// **'返金しました'**
  String get noticeRefundedTitle;

  /// No description provided for @noticeRefundedBody.
  ///
  /// In ja, this message translates to:
  /// **'ご予約のフードバッグをご用意できなかったため、全額を返金しました。'**
  String get noticeRefundedBody;

  /// No description provided for @storeSettingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get storeSettingsTitle;

  /// No description provided for @storeSettingsAddress.
  ///
  /// In ja, this message translates to:
  /// **'{address}・閉店 {time}'**
  String storeSettingsAddress(String address, String time);

  /// No description provided for @storeSettingsInfoNote.
  ///
  /// In ja, this message translates to:
  /// **'店舗情報の変更は Web 管理画面またはお問い合わせから。'**
  String get storeSettingsInfoNote;

  /// No description provided for @storeSettingsPush.
  ///
  /// In ja, this message translates to:
  /// **'アプリの通知'**
  String get storeSettingsPush;

  /// No description provided for @storeSettingsPushDenied.
  ///
  /// In ja, this message translates to:
  /// **'端末の設定で通知がオフになっています'**
  String get storeSettingsPushDenied;

  /// No description provided for @storeSettingsRatings.
  ///
  /// In ja, this message translates to:
  /// **'お客様の評価'**
  String get storeSettingsRatings;

  /// No description provided for @storeSettingsInquiry.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get storeSettingsInquiry;

  /// No description provided for @storeSettingsPrivacy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get storeSettingsPrivacy;

  /// No description provided for @storeSettingsDeleteAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの削除を依頼'**
  String get storeSettingsDeleteAccount;

  /// No description provided for @storeSettingsVersion.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal Store {version}'**
  String storeSettingsVersion(String version);

  /// No description provided for @adminMfaTitle.
  ///
  /// In ja, this message translates to:
  /// **'2段階認証'**
  String get adminMfaTitle;

  /// No description provided for @adminMfaLead.
  ///
  /// In ja, this message translates to:
  /// **'認証アプリに表示されている6桁のコードを入力してください。'**
  String get adminMfaLead;

  /// No description provided for @adminMfaCodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'確認コード'**
  String get adminMfaCodeLabel;

  /// No description provided for @adminMfaVerify.
  ///
  /// In ja, this message translates to:
  /// **'確認する'**
  String get adminMfaVerify;

  /// No description provided for @adminMfaOtherAccount.
  ///
  /// In ja, this message translates to:
  /// **'別のアカウントでログイン'**
  String get adminMfaOtherAccount;

  /// No description provided for @adminMfaSetupTitle.
  ///
  /// In ja, this message translates to:
  /// **'2段階認証の設定'**
  String get adminMfaSetupTitle;

  /// No description provided for @adminMfaSetupLead.
  ///
  /// In ja, this message translates to:
  /// **'運営アカウントは2段階認証が必須です。'**
  String get adminMfaSetupLead;

  /// No description provided for @adminMfaSetupStep1.
  ///
  /// In ja, this message translates to:
  /// **'この端末で設定する場合: 下の「コピー」でセットアップキーをコピーし、認証アプリ（Google Authenticator など）の「セットアップキーを入力」に貼り付けます。別の端末がある場合は QR コードを読み取っても設定できます。'**
  String get adminMfaSetupStep1;

  /// No description provided for @adminMfaSetupKey.
  ///
  /// In ja, this message translates to:
  /// **'セットアップキー'**
  String get adminMfaSetupKey;

  /// No description provided for @adminMfaCopy.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get adminMfaCopy;

  /// No description provided for @adminMfaCopied.
  ///
  /// In ja, this message translates to:
  /// **'セットアップキーをコピーしました'**
  String get adminMfaCopied;

  /// No description provided for @adminMfaSetupStep2.
  ///
  /// In ja, this message translates to:
  /// **'アプリに表示された6桁のコードを入力します。'**
  String get adminMfaSetupStep2;

  /// No description provided for @adminMfaSetupDone.
  ///
  /// In ja, this message translates to:
  /// **'設定を完了する'**
  String get adminMfaSetupDone;

  /// No description provided for @adminMfaInvalidCode.
  ///
  /// In ja, this message translates to:
  /// **'6桁の数字を入力してください'**
  String get adminMfaInvalidCode;

  /// No description provided for @adminMfaWrongCode.
  ///
  /// In ja, this message translates to:
  /// **'コードが正しくありません。認証アプリに表示されている最新のコードを入力してください'**
  String get adminMfaWrongCode;

  /// No description provided for @adminMfaFailed.
  ///
  /// In ja, this message translates to:
  /// **'確認できませんでした。時間をおいて、もう一度お試しください'**
  String get adminMfaFailed;

  /// No description provided for @adminTabHome.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get adminTabHome;

  /// No description provided for @adminTabOperations.
  ///
  /// In ja, this message translates to:
  /// **'運行'**
  String get adminTabOperations;

  /// No description provided for @adminTabTasks.
  ///
  /// In ja, this message translates to:
  /// **'対応'**
  String get adminTabTasks;

  /// No description provided for @adminTabSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get adminTabSettings;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In ja, this message translates to:
  /// **'ダッシュボード'**
  String get adminDashboardTitle;

  /// No description provided for @adminTonight.
  ///
  /// In ja, this message translates to:
  /// **'今夜の運行'**
  String get adminTonight;

  /// No description provided for @adminRunning.
  ///
  /// In ja, this message translates to:
  /// **'運行中'**
  String get adminRunning;

  /// No description provided for @adminTrucksRunning.
  ///
  /// In ja, this message translates to:
  /// **'走行中の車両'**
  String get adminTrucksRunning;

  /// No description provided for @adminStopsDone.
  ///
  /// In ja, this message translates to:
  /// **'停車地点 完了'**
  String get adminStopsDone;

  /// No description provided for @adminReserved.
  ///
  /// In ja, this message translates to:
  /// **'予約'**
  String get adminReserved;

  /// No description provided for @adminPickedUp.
  ///
  /// In ja, this message translates to:
  /// **'受取済み'**
  String get adminPickedUp;

  /// No description provided for @adminNoRouteTonight.
  ///
  /// In ja, this message translates to:
  /// **'今夜の運行はまだありません'**
  String get adminNoRouteTonight;

  /// No description provided for @adminNeedsAction.
  ///
  /// In ja, this message translates to:
  /// **'対応が必要'**
  String get adminNeedsAction;

  /// No description provided for @adminTaskIssues.
  ///
  /// In ja, this message translates to:
  /// **'未対応の問題報告'**
  String get adminTaskIssues;

  /// No description provided for @adminTaskRestaurants.
  ///
  /// In ja, this message translates to:
  /// **'承認待ちの飲食店'**
  String get adminTaskRestaurants;

  /// No description provided for @adminTaskLicenses.
  ///
  /// In ja, this message translates to:
  /// **'確認待ちの運転免許'**
  String get adminTaskLicenses;

  /// No description provided for @adminTaskInquiries.
  ///
  /// In ja, this message translates to:
  /// **'新しい問い合わせ'**
  String get adminTaskInquiries;

  /// No description provided for @adminTaskLatest.
  ///
  /// In ja, this message translates to:
  /// **'最新: {name}・{time}'**
  String adminTaskLatest(String name, String time);

  /// No description provided for @adminTaskIssueLatest.
  ///
  /// In ja, this message translates to:
  /// **'{number}「{category}」・{time}'**
  String adminTaskIssueLatest(String number, String category, String time);

  /// No description provided for @adminTaskLicenseLatest.
  ///
  /// In ja, this message translates to:
  /// **'{name}・{time}'**
  String adminTaskLicenseLatest(String name, String time);

  /// No description provided for @adminTaskInquiryTypes.
  ///
  /// In ja, this message translates to:
  /// **'パートナー申込 {partner}・その他 {other}'**
  String adminTaskInquiryTypes(int partner, int other);

  /// No description provided for @adminTaskNone.
  ///
  /// In ja, this message translates to:
  /// **'ありません'**
  String get adminTaskNone;

  /// No description provided for @adminDateTime.
  ///
  /// In ja, this message translates to:
  /// **'{date} {time}'**
  String adminDateTime(String date, String time);

  /// No description provided for @adminSettingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get adminSettingsTitle;

  /// No description provided for @adminMfaOn.
  ///
  /// In ja, this message translates to:
  /// **'2段階認証 オン'**
  String get adminMfaOn;

  /// No description provided for @adminNotifications.
  ///
  /// In ja, this message translates to:
  /// **'通知'**
  String get adminNotifications;

  /// No description provided for @adminPrefIssues.
  ///
  /// In ja, this message translates to:
  /// **'問題報告'**
  String get adminPrefIssues;

  /// No description provided for @adminPrefRestaurants.
  ///
  /// In ja, this message translates to:
  /// **'飲食店の申請'**
  String get adminPrefRestaurants;

  /// No description provided for @adminPrefLicenses.
  ///
  /// In ja, this message translates to:
  /// **'運転免許の提出'**
  String get adminPrefLicenses;

  /// No description provided for @adminPrefInquiries.
  ///
  /// In ja, this message translates to:
  /// **'問い合わせ'**
  String get adminPrefInquiries;

  /// No description provided for @adminPrefSaveFailed.
  ///
  /// In ja, this message translates to:
  /// **'通知の設定を変更できませんでした'**
  String get adminPrefSaveFailed;

  /// No description provided for @adminPushOff.
  ///
  /// In ja, this message translates to:
  /// **'この端末の通知がオフです'**
  String get adminPushOff;

  /// No description provided for @adminPushEnable.
  ///
  /// In ja, this message translates to:
  /// **'通知をオンにする'**
  String get adminPushEnable;

  /// No description provided for @adminTwoFactor.
  ///
  /// In ja, this message translates to:
  /// **'2段階認証'**
  String get adminTwoFactor;

  /// No description provided for @adminTwoFactorOn.
  ///
  /// In ja, this message translates to:
  /// **'オン'**
  String get adminTwoFactorOn;

  /// No description provided for @adminOpenWebAdmin.
  ///
  /// In ja, this message translates to:
  /// **'Web 管理画面を開く'**
  String get adminOpenWebAdmin;

  /// No description provided for @adminVersion.
  ///
  /// In ja, this message translates to:
  /// **'EcoMeal Admin {version}（TestFlight）'**
  String adminVersion(String version);

  /// No description provided for @noticeIssueReportedTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しい問題報告'**
  String get noticeIssueReportedTitle;

  /// No description provided for @noticeIssueReportedBody.
  ///
  /// In ja, this message translates to:
  /// **'お客様から注文の問題報告が届きました。'**
  String get noticeIssueReportedBody;

  /// No description provided for @noticeLicenseSubmittedTitle.
  ///
  /// In ja, this message translates to:
  /// **'免許の確認依頼'**
  String get noticeLicenseSubmittedTitle;

  /// No description provided for @noticeLicenseSubmittedBody.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーから運転免許の確認依頼が届きました。'**
  String get noticeLicenseSubmittedBody;

  /// No description provided for @noticeInquiryReceivedTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しいお問い合わせ'**
  String get noticeInquiryReceivedTitle;

  /// No description provided for @noticeInquiryReceivedBody.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせが届きました。'**
  String get noticeInquiryReceivedBody;

  /// No description provided for @noticeRestaurantAppliedTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しい飲食店の申請'**
  String get noticeRestaurantAppliedTitle;

  /// No description provided for @noticeRestaurantAppliedBody.
  ///
  /// In ja, this message translates to:
  /// **'飲食店から参加の申請が届きました。'**
  String get noticeRestaurantAppliedBody;

  /// No description provided for @adminTasksTitle.
  ///
  /// In ja, this message translates to:
  /// **'対応'**
  String get adminTasksTitle;

  /// No description provided for @adminTasksSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'問題報告・審査・免許・問い合わせ'**
  String get adminTasksSubtitle;

  /// No description provided for @adminSegIssues.
  ///
  /// In ja, this message translates to:
  /// **'問題報告 {count}'**
  String adminSegIssues(int count);

  /// No description provided for @adminSegRestaurants.
  ///
  /// In ja, this message translates to:
  /// **'審査 {count}'**
  String adminSegRestaurants(int count);

  /// No description provided for @adminSegLicenses.
  ///
  /// In ja, this message translates to:
  /// **'免許 {count}'**
  String adminSegLicenses(int count);

  /// No description provided for @adminSegInquiries.
  ///
  /// In ja, this message translates to:
  /// **'問合せ {count}'**
  String adminSegInquiries(int count);

  /// No description provided for @adminIssueOpen.
  ///
  /// In ja, this message translates to:
  /// **'未対応'**
  String get adminIssueOpen;

  /// No description provided for @adminIssueResolved.
  ///
  /// In ja, this message translates to:
  /// **'対応済み'**
  String get adminIssueResolved;

  /// No description provided for @adminIssueLine.
  ///
  /// In ja, this message translates to:
  /// **'{message}（{stop}・{price}）'**
  String adminIssueLine(String message, String stop, String price);

  /// No description provided for @adminIssueMeta.
  ///
  /// In ja, this message translates to:
  /// **'{time}・顧客 {name}'**
  String adminIssueMeta(String time, String name);

  /// No description provided for @adminIssueRefunded.
  ///
  /// In ja, this message translates to:
  /// **'{amount} を返金・回答済み'**
  String adminIssueRefunded(String amount);

  /// No description provided for @adminIssueNoRefund.
  ///
  /// In ja, this message translates to:
  /// **'返金なし・回答済み'**
  String get adminIssueNoRefund;

  /// No description provided for @adminIssuesEmpty.
  ///
  /// In ja, this message translates to:
  /// **'問題報告はありません'**
  String get adminIssuesEmpty;

  /// No description provided for @adminIssueOrder.
  ///
  /// In ja, this message translates to:
  /// **'注文'**
  String get adminIssueOrder;

  /// No description provided for @adminIssueOrderValue.
  ///
  /// In ja, this message translates to:
  /// **'ミステリーバッグ・{price}（税込）'**
  String adminIssueOrderValue(String price);

  /// No description provided for @adminIssuePickup.
  ///
  /// In ja, this message translates to:
  /// **'受け取り'**
  String get adminIssuePickup;

  /// No description provided for @adminIssueRestaurant.
  ///
  /// In ja, this message translates to:
  /// **'飲食店'**
  String get adminIssueRestaurant;

  /// No description provided for @adminIssueRefundLabel.
  ///
  /// In ja, this message translates to:
  /// **'返金額'**
  String get adminIssueRefundLabel;

  /// No description provided for @adminIssueFull.
  ///
  /// In ja, this message translates to:
  /// **'全額'**
  String get adminIssueFull;

  /// No description provided for @adminIssueRefundHint.
  ///
  /// In ja, this message translates to:
  /// **'返金可能額 {amount} まで。0円（返金なし）も選べます。'**
  String adminIssueRefundHint(String amount);

  /// No description provided for @adminIssueNoRefundHint.
  ///
  /// In ja, this message translates to:
  /// **'返金なし（¥0）。お客様には回答だけが届きます。'**
  String get adminIssueNoRefundHint;

  /// No description provided for @adminIssueAnswerLabel.
  ///
  /// In ja, this message translates to:
  /// **'お客様への回答'**
  String get adminIssueAnswerLabel;

  /// No description provided for @adminIssueSubmitRefund.
  ///
  /// In ja, this message translates to:
  /// **'返金して対応済みにする'**
  String get adminIssueSubmitRefund;

  /// No description provided for @adminIssueSubmitNoRefund.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにする'**
  String get adminIssueSubmitNoRefund;

  /// No description provided for @adminIssueSending.
  ///
  /// In ja, this message translates to:
  /// **'送信中…'**
  String get adminIssueSending;

  /// No description provided for @adminIssueErrorTitle.
  ///
  /// In ja, this message translates to:
  /// **'送信できませんでした'**
  String get adminIssueErrorTitle;

  /// No description provided for @adminIssueErrorBody.
  ///
  /// In ja, this message translates to:
  /// **'通信状況を確認して、もう一度お試しください。入力した返金額と回答は残っています。返金はまだ行われていません。'**
  String get adminIssueErrorBody;

  /// No description provided for @adminIssueRetry.
  ///
  /// In ja, this message translates to:
  /// **'もう一度送信する'**
  String get adminIssueRetry;

  /// No description provided for @adminIssueErrAmount.
  ///
  /// In ja, this message translates to:
  /// **'0〜{amount} の金額を入力してください'**
  String adminIssueErrAmount(String amount);

  /// No description provided for @adminIssueErrAnswer.
  ///
  /// In ja, this message translates to:
  /// **'お客様への回答を入力してください'**
  String get adminIssueErrAnswer;

  /// No description provided for @adminIssueErrAlready.
  ///
  /// In ja, this message translates to:
  /// **'この報告はすでに対応済みです'**
  String get adminIssueErrAlready;

  /// No description provided for @adminIssueResolvedToast.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにしました'**
  String get adminIssueResolvedToast;

  /// No description provided for @adminRestTitle.
  ///
  /// In ja, this message translates to:
  /// **'飲食店の審査'**
  String get adminRestTitle;

  /// No description provided for @adminRestPending.
  ///
  /// In ja, this message translates to:
  /// **'承認待ち'**
  String get adminRestPending;

  /// No description provided for @adminRestRejected.
  ///
  /// In ja, this message translates to:
  /// **'却下済み'**
  String get adminRestRejected;

  /// No description provided for @adminRestApproved.
  ///
  /// In ja, this message translates to:
  /// **'承認済み'**
  String get adminRestApproved;

  /// No description provided for @adminRestPendingBadge.
  ///
  /// In ja, this message translates to:
  /// **'審査待ち'**
  String get adminRestPendingBadge;

  /// No description provided for @adminRestApplied.
  ///
  /// In ja, this message translates to:
  /// **'申請 {time}'**
  String adminRestApplied(String time);

  /// No description provided for @adminRestHasPl.
  ///
  /// In ja, this message translates to:
  /// **'PL保険 PDF あり'**
  String get adminRestHasPl;

  /// No description provided for @adminRestNoPl.
  ///
  /// In ja, this message translates to:
  /// **'PL保険 PDF なし'**
  String get adminRestNoPl;

  /// No description provided for @adminRestEmpty.
  ///
  /// In ja, this message translates to:
  /// **'該当する飲食店はありません'**
  String get adminRestEmpty;

  /// No description provided for @adminRestName.
  ///
  /// In ja, this message translates to:
  /// **'店舗名'**
  String get adminRestName;

  /// No description provided for @adminRestAddress.
  ///
  /// In ja, this message translates to:
  /// **'住所'**
  String get adminRestAddress;

  /// No description provided for @adminRestContact.
  ///
  /// In ja, this message translates to:
  /// **'連絡先'**
  String get adminRestContact;

  /// No description provided for @adminRestClosing.
  ///
  /// In ja, this message translates to:
  /// **'閉店時刻'**
  String get adminRestClosing;

  /// No description provided for @adminRestApplicant.
  ///
  /// In ja, this message translates to:
  /// **'申請者'**
  String get adminRestApplicant;

  /// No description provided for @adminRestPlDoc.
  ///
  /// In ja, this message translates to:
  /// **'PL保険の証書'**
  String get adminRestPlDoc;

  /// No description provided for @adminRestPlOpen.
  ///
  /// In ja, this message translates to:
  /// **'証書を開く（PDF）'**
  String get adminRestPlOpen;

  /// No description provided for @adminRestPlFailed.
  ///
  /// In ja, this message translates to:
  /// **'証書を開けませんでした'**
  String get adminRestPlFailed;

  /// No description provided for @adminRestReject.
  ///
  /// In ja, this message translates to:
  /// **'却下する'**
  String get adminRestReject;

  /// No description provided for @adminRestApprove.
  ///
  /// In ja, this message translates to:
  /// **'承認する'**
  String get adminRestApprove;

  /// No description provided for @adminRestRejectTitle.
  ///
  /// In ja, this message translates to:
  /// **'却下の理由'**
  String get adminRestRejectTitle;

  /// No description provided for @adminRestRejectNote.
  ///
  /// In ja, this message translates to:
  /// **'理由は飲食店にメールとアプリで通知されます（必須・500文字まで）。'**
  String get adminRestRejectNote;

  /// No description provided for @adminRestReasonPl.
  ///
  /// In ja, this message translates to:
  /// **'PL保険の証書が読み取れない・期限切れ'**
  String get adminRestReasonPl;

  /// No description provided for @adminRestReasonContact.
  ///
  /// In ja, this message translates to:
  /// **'住所・連絡先が確認できない'**
  String get adminRestReasonContact;

  /// No description provided for @adminRestReasonOther.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get adminRestReasonOther;

  /// No description provided for @adminRestRejectSend.
  ///
  /// In ja, this message translates to:
  /// **'却下を通知する'**
  String get adminRestRejectSend;

  /// No description provided for @adminRestErrReason.
  ///
  /// In ja, this message translates to:
  /// **'理由を入力してください（500文字まで）'**
  String get adminRestErrReason;

  /// No description provided for @adminRestDecided.
  ///
  /// In ja, this message translates to:
  /// **'{name}を{decision}しました'**
  String adminRestDecided(String name, String decision);

  /// No description provided for @adminRestNotifyFailed.
  ///
  /// In ja, this message translates to:
  /// **'審査は確定しましたが、通知メールを送れませんでした。Web 管理画面から再送してください。'**
  String get adminRestNotifyFailed;

  /// No description provided for @adminRestRejectionReason.
  ///
  /// In ja, this message translates to:
  /// **'却下の理由'**
  String get adminRestRejectionReason;

  /// No description provided for @adminLicTitle.
  ///
  /// In ja, this message translates to:
  /// **'免許の確認'**
  String get adminLicTitle;

  /// No description provided for @adminLicSubmitted.
  ///
  /// In ja, this message translates to:
  /// **'運転免許・提出 {time}'**
  String adminLicSubmitted(String time);

  /// No description provided for @adminLicEmpty.
  ///
  /// In ja, this message translates to:
  /// **'確認待ちの運転免許はありません'**
  String get adminLicEmpty;

  /// No description provided for @adminLicImageFailed.
  ///
  /// In ja, this message translates to:
  /// **'画像を読み込めませんでした'**
  String get adminLicImageFailed;

  /// No description provided for @adminLicZoom.
  ///
  /// In ja, this message translates to:
  /// **'拡大'**
  String get adminLicZoom;

  /// No description provided for @adminLicTruck.
  ///
  /// In ja, this message translates to:
  /// **'担当予定'**
  String get adminLicTruck;

  /// No description provided for @adminLicNoTruck.
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get adminLicNoTruck;

  /// No description provided for @adminLicExpiry.
  ///
  /// In ja, this message translates to:
  /// **'有効期限（画像を見て入力）'**
  String get adminLicExpiry;

  /// No description provided for @adminLicExpiryPick.
  ///
  /// In ja, this message translates to:
  /// **'日付を選ぶ'**
  String get adminLicExpiryPick;

  /// No description provided for @adminLicVerifyNote.
  ///
  /// In ja, this message translates to:
  /// **'確認済みにすると、シフトに入れられるようになります。'**
  String get adminLicVerifyNote;

  /// No description provided for @adminLicReject.
  ///
  /// In ja, this message translates to:
  /// **'差し戻す'**
  String get adminLicReject;

  /// No description provided for @adminLicVerify.
  ///
  /// In ja, this message translates to:
  /// **'確認済みにする'**
  String get adminLicVerify;

  /// No description provided for @adminLicRejectTitle.
  ///
  /// In ja, this message translates to:
  /// **'差し戻しの理由'**
  String get adminLicRejectTitle;

  /// No description provided for @adminLicErrExpiry.
  ///
  /// In ja, this message translates to:
  /// **'有効期限（今日以降）を選んでください'**
  String get adminLicErrExpiry;

  /// No description provided for @adminLicDone.
  ///
  /// In ja, this message translates to:
  /// **'{name}さんの免許を更新しました'**
  String adminLicDone(String name);

  /// No description provided for @adminInqTitle.
  ///
  /// In ja, this message translates to:
  /// **'問い合わせ'**
  String get adminInqTitle;

  /// No description provided for @adminInqNew.
  ///
  /// In ja, this message translates to:
  /// **'新着'**
  String get adminInqNew;

  /// No description provided for @adminInqInProgress.
  ///
  /// In ja, this message translates to:
  /// **'対応中'**
  String get adminInqInProgress;

  /// No description provided for @adminInqDone.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get adminInqDone;

  /// No description provided for @adminInqTypePartner.
  ///
  /// In ja, this message translates to:
  /// **'パートナー申込'**
  String get adminInqTypePartner;

  /// No description provided for @adminInqTypeDriver.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー応募'**
  String get adminInqTypeDriver;

  /// No description provided for @adminInqTypeContact.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get adminInqTypeContact;

  /// No description provided for @adminInqStatusNew.
  ///
  /// In ja, this message translates to:
  /// **'新着'**
  String get adminInqStatusNew;

  /// No description provided for @adminInqStatusInProgress.
  ///
  /// In ja, this message translates to:
  /// **'対応中'**
  String get adminInqStatusInProgress;

  /// No description provided for @adminInqStatusDone.
  ///
  /// In ja, this message translates to:
  /// **'対応済み'**
  String get adminInqStatusDone;

  /// No description provided for @adminInqStatusRejected.
  ///
  /// In ja, this message translates to:
  /// **'見送り'**
  String get adminInqStatusRejected;

  /// No description provided for @adminInqEmpty.
  ///
  /// In ja, this message translates to:
  /// **'該当する問い合わせはありません'**
  String get adminInqEmpty;

  /// No description provided for @adminInqInviteOnWeb.
  ///
  /// In ja, this message translates to:
  /// **'アカウントの発行（招待）は Web 管理画面で行います。'**
  String get adminInqInviteOnWeb;

  /// No description provided for @adminInqStatusLabel.
  ///
  /// In ja, this message translates to:
  /// **'状態'**
  String get adminInqStatusLabel;

  /// No description provided for @adminInqNoteLabel.
  ///
  /// In ja, this message translates to:
  /// **'運営メモ（社内用）'**
  String get adminInqNoteLabel;

  /// No description provided for @adminInqSave.
  ///
  /// In ja, this message translates to:
  /// **'保存する'**
  String get adminInqSave;

  /// No description provided for @adminInqSaved.
  ///
  /// In ja, this message translates to:
  /// **'保存しました'**
  String get adminInqSaved;

  /// No description provided for @adminSaveFailed.
  ///
  /// In ja, this message translates to:
  /// **'保存できませんでした。通信状況を確認して、もう一度お試しください。'**
  String get adminSaveFailed;

  /// No description provided for @adminOpsTitle.
  ///
  /// In ja, this message translates to:
  /// **'運行モニタ'**
  String get adminOpsTitle;

  /// No description provided for @adminOpsSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{date}・{count}台'**
  String adminOpsSubtitle(String date, int count);

  /// No description provided for @adminOpsLive.
  ///
  /// In ja, this message translates to:
  /// **'ライブ'**
  String get adminOpsLive;

  /// No description provided for @adminOpsShowing.
  ///
  /// In ja, this message translates to:
  /// **'{count}台を表示中'**
  String adminOpsShowing(int count);

  /// No description provided for @adminOpsRunning.
  ///
  /// In ja, this message translates to:
  /// **'走行中'**
  String get adminOpsRunning;

  /// No description provided for @adminOpsWaiting.
  ///
  /// In ja, this message translates to:
  /// **'待機'**
  String get adminOpsWaiting;

  /// No description provided for @adminOpsDone.
  ///
  /// In ja, this message translates to:
  /// **'完了'**
  String get adminOpsDone;

  /// No description provided for @adminOpsNext.
  ///
  /// In ja, this message translates to:
  /// **'{driver}・次: {stop}'**
  String adminOpsNext(String driver, String stop);

  /// No description provided for @adminOpsEta.
  ///
  /// In ja, this message translates to:
  /// **'到着予定'**
  String get adminOpsEta;

  /// No description provided for @adminOpsReserved.
  ///
  /// In ja, this message translates to:
  /// **'予約 {count}件'**
  String adminOpsReserved(int count);

  /// No description provided for @adminOpsNoDriver.
  ///
  /// In ja, this message translates to:
  /// **'ドライバー未定'**
  String get adminOpsNoDriver;

  /// No description provided for @adminOpsMapUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'地図を表示できません（地図の設定が完了していません）'**
  String get adminOpsMapUnavailable;

  /// No description provided for @noticeReservationReceivedTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しい予約が入りました'**
  String get noticeReservationReceivedTitle;

  /// No description provided for @noticeReservationReceivedBody.
  ///
  /// In ja, this message translates to:
  /// **'販売期限 {time} の出品に予約が{count}件入りました。合計{total}件です。'**
  String noticeReservationReceivedBody(String time, int count, int total);

  /// No description provided for @noticeReservationReceivedFallback.
  ///
  /// In ja, this message translates to:
  /// **'アプリで予約数をご確認ください。'**
  String get noticeReservationReceivedFallback;

  /// No description provided for @storeSettingsContract.
  ///
  /// In ja, this message translates to:
  /// **'提携契約について'**
  String get storeSettingsContract;

  /// No description provided for @storeContractBody.
  ///
  /// In ja, this message translates to:
  /// **'店舗のご利用条件（還元率・精算・振込・食品の取り扱いなど）は、EcoMeal と締結した提携契約に定めています。お客様向けの利用規約は店舗には適用されません。契約内容の確認や変更のご相談はお問い合わせからご連絡ください。'**
  String get storeContractBody;

  /// No description provided for @storeContractInquiry.
  ///
  /// In ja, this message translates to:
  /// **'お問い合わせ'**
  String get storeContractInquiry;

  /// No description provided for @adminRestApproveConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'{name}を承認しますか？'**
  String adminRestApproveConfirmTitle(String name);

  /// No description provided for @adminRestApproveConfirmBody.
  ///
  /// In ja, this message translates to:
  /// **'承認すると、店舗アプリで余剰の登録ができるようになり、店舗担当者に通知メールが届きます。'**
  String get adminRestApproveConfirmBody;

  /// No description provided for @adminLicVerifyConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'{name}さんの免許を確認済みにしますか？'**
  String adminLicVerifyConfirmTitle(String name);

  /// No description provided for @adminLicVerifyConfirmBody.
  ///
  /// In ja, this message translates to:
  /// **'有効期限 {date} で登録し、このドライバーをシフトに入れられるようになります。'**
  String adminLicVerifyConfirmBody(String date);

  /// No description provided for @adminIssueConfirmRefundTitle.
  ///
  /// In ja, this message translates to:
  /// **'{amount}を返金しますか？'**
  String adminIssueConfirmRefundTitle(String amount);

  /// No description provided for @adminIssueConfirmRefundBody.
  ///
  /// In ja, this message translates to:
  /// **'{order}（{restaurant}）のお客様の支払い方法に{amount}を返金し、回答を送ります。返金は取り消せません。'**
  String adminIssueConfirmRefundBody(
    String order,
    String restaurant,
    String amount,
  );

  /// No description provided for @adminIssueConfirmNoRefundTitle.
  ///
  /// In ja, this message translates to:
  /// **'返金なしで対応済みにしますか？'**
  String get adminIssueConfirmNoRefundTitle;

  /// No description provided for @adminIssueConfirmNoRefundBody.
  ///
  /// In ja, this message translates to:
  /// **'{order}（{restaurant}）のお客様に回答だけを送ります。あとから返金はできません。'**
  String adminIssueConfirmNoRefundBody(String order, String restaurant);

  /// No description provided for @adminMfaLostDevice.
  ///
  /// In ja, this message translates to:
  /// **'スマートフォンを紛失した・認証アプリを削除した場合は、ログインできません。EcoMeal の別の管理者に2段階認証の解除を依頼してください。'**
  String get adminMfaLostDevice;

  /// No description provided for @adminIssueConfirmRefundAction.
  ///
  /// In ja, this message translates to:
  /// **'返金する'**
  String get adminIssueConfirmRefundAction;

  /// No description provided for @activeOrderOpen.
  ///
  /// In ja, this message translates to:
  /// **'受け取りの案内を開く'**
  String get activeOrderOpen;

  /// No description provided for @activeOrderTitle.
  ///
  /// In ja, this message translates to:
  /// **'受け取りの案内'**
  String get activeOrderTitle;

  /// No description provided for @activeOrderPlace.
  ///
  /// In ja, this message translates to:
  /// **'受取場所'**
  String get activeOrderPlace;

  /// No description provided for @activeOrderTime.
  ///
  /// In ja, this message translates to:
  /// **'受取時間'**
  String get activeOrderTime;

  /// No description provided for @activeOrderBefore.
  ///
  /// In ja, this message translates to:
  /// **'到着予定 {time}・あと{minutes}分'**
  String activeOrderBefore(String time, int minutes);

  /// No description provided for @activeOrderWindow.
  ///
  /// In ja, this message translates to:
  /// **'受取地点に停車している時間です（{end}まで）'**
  String activeOrderWindow(String end);

  /// No description provided for @activeOrderOver.
  ///
  /// In ja, this message translates to:
  /// **'この受取地点の停車は終わりました。受け取れなかった場合は、予約履歴の「問題を報告」かお問い合わせからご連絡ください。'**
  String get activeOrderOver;

  /// No description provided for @activeOrderFindTitle.
  ///
  /// In ja, this message translates to:
  /// **'トラックの見つけ方'**
  String get activeOrderFindTitle;

  /// No description provided for @activeOrderFindBody.
  ///
  /// In ja, this message translates to:
  /// **'受取地点に停車している Eco-Truck（車体に EcoMeal のロゴ）で、この QR を見せてください。読み取れないときは上のコードを伝えてください。トラックの位置と到着予定は、ホームの地図でも確認できます。'**
  String get activeOrderFindBody;

  /// No description provided for @activeOrderPickedUp.
  ///
  /// In ja, this message translates to:
  /// **'受け取りました'**
  String get activeOrderPickedUp;

  /// No description provided for @pickupCompleteTitle.
  ///
  /// In ja, this message translates to:
  /// **'受け取り完了'**
  String get pickupCompleteTitle;

  /// No description provided for @pickupCompleteBody.
  ///
  /// In ja, this message translates to:
  /// **'ご利用ありがとうございました。'**
  String get pickupCompleteBody;

  /// No description provided for @leftoverAutoRecordNote.
  ///
  /// In ja, this message translates to:
  /// **'寄付しなかった分は、最後の販売地点を出発してから1時間後に「売れ残り（廃棄）」として自動で記録されます。寄付する場合は、それまでに記録してください。'**
  String get leftoverAutoRecordNote;

  /// No description provided for @driverReportButton.
  ///
  /// In ja, this message translates to:
  /// **'運営に連絡（遅れ・トラブル）'**
  String get driverReportButton;

  /// No description provided for @driverReportTitle.
  ///
  /// In ja, this message translates to:
  /// **'運営に連絡'**
  String get driverReportTitle;

  /// No description provided for @driverReportLead.
  ///
  /// In ja, this message translates to:
  /// **'送ると運営に通知が届き、影響する予約のお客様には運営から連絡します。急ぎの安全上の問題は、まず安全な場所に停車してください。'**
  String get driverReportLead;

  /// No description provided for @driverReportDelay.
  ///
  /// In ja, this message translates to:
  /// **'到着が遅れそう（次の停車地）'**
  String get driverReportDelay;

  /// No description provided for @driverReportVehicle.
  ///
  /// In ja, this message translates to:
  /// **'車両のトラブル（故障・事故）'**
  String get driverReportVehicle;

  /// No description provided for @driverReportFood.
  ///
  /// In ja, this message translates to:
  /// **'料理・温度の問題（受け取りを断った など）'**
  String get driverReportFood;

  /// No description provided for @driverReportOther.
  ///
  /// In ja, this message translates to:
  /// **'その他'**
  String get driverReportOther;

  /// No description provided for @driverReportMinutes.
  ///
  /// In ja, this message translates to:
  /// **'{minutes}分'**
  String driverReportMinutes(int minutes);

  /// No description provided for @driverReportMinutesMax.
  ///
  /// In ja, this message translates to:
  /// **'30分以上'**
  String get driverReportMinutesMax;

  /// No description provided for @driverReportMessageHint.
  ///
  /// In ja, this message translates to:
  /// **'状況をひとこと（任意。「その他」は必須）'**
  String get driverReportMessageHint;

  /// No description provided for @driverReportSend.
  ///
  /// In ja, this message translates to:
  /// **'運営に送信する'**
  String get driverReportSend;

  /// No description provided for @driverReportSent.
  ///
  /// In ja, this message translates to:
  /// **'運営に送信しました。運営からの連絡を待つあいだも、安全に運行してください。'**
  String get driverReportSent;

  /// No description provided for @driverReportSelect.
  ///
  /// In ja, this message translates to:
  /// **'連絡の種類を選んでください'**
  String get driverReportSelect;

  /// No description provided for @driverReportNeedMessage.
  ///
  /// In ja, this message translates to:
  /// **'「その他」は、状況をひとこと入力してください'**
  String get driverReportNeedMessage;

  /// No description provided for @driverReportNoRoute.
  ///
  /// In ja, this message translates to:
  /// **'今夜の運行がないため、送れません'**
  String get driverReportNoRoute;

  /// No description provided for @driverReportDuplicate.
  ///
  /// In ja, this message translates to:
  /// **'同じ種類の連絡を送ったばかりです。1分ほど待ってから送ってください'**
  String get driverReportDuplicate;

  /// No description provided for @driverReportError.
  ///
  /// In ja, this message translates to:
  /// **'送れませんでした。電波の良い場所でもう一度お試しください'**
  String get driverReportError;

  /// No description provided for @adminTaskDriverReports.
  ///
  /// In ja, this message translates to:
  /// **'未対応の運行の連絡'**
  String get adminTaskDriverReports;

  /// No description provided for @adminTaskDriverReportLatest.
  ///
  /// In ja, this message translates to:
  /// **'{plate}「{category}」・{time}'**
  String adminTaskDriverReportLatest(
    String plate,
    String category,
    String time,
  );

  /// No description provided for @adminSegDriverReports.
  ///
  /// In ja, this message translates to:
  /// **'運行の連絡 {count}'**
  String adminSegDriverReports(int count);

  /// No description provided for @adminDriverReportsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーからの連絡はありません'**
  String get adminDriverReportsEmpty;

  /// No description provided for @adminDriverReportMeta.
  ///
  /// In ja, this message translates to:
  /// **'{time}・{driver}・次の停車 {stop}'**
  String adminDriverReportMeta(String time, String driver, String stop);

  /// No description provided for @adminDriverReportNoStop.
  ///
  /// In ja, this message translates to:
  /// **'なし（運行終了）'**
  String get adminDriverReportNoStop;

  /// No description provided for @adminDriverReportResolveTitle.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにする'**
  String get adminDriverReportResolveTitle;

  /// No description provided for @adminDriverReportResolveNote.
  ///
  /// In ja, this message translates to:
  /// **'行ったこと（お客様への連絡など）を残します。お客様への連絡は自動では送られません。'**
  String get adminDriverReportResolveNote;

  /// No description provided for @adminDriverReportResolveSend.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにする'**
  String get adminDriverReportResolveSend;

  /// No description provided for @adminDriverReportDone.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにしました'**
  String get adminDriverReportDone;

  /// No description provided for @adminDriverReportAlready.
  ///
  /// In ja, this message translates to:
  /// **'ほかの運営がすでに対応済みにしました'**
  String get adminDriverReportAlready;

  /// No description provided for @adminDriverReportError.
  ///
  /// In ja, this message translates to:
  /// **'対応済みにできませんでした。もう一度お試しください'**
  String get adminDriverReportError;

  /// No description provided for @noticeDriverReportedTitle.
  ///
  /// In ja, this message translates to:
  /// **'ドライバーから連絡'**
  String get noticeDriverReportedTitle;

  /// No description provided for @noticeDriverReportedBody.
  ///
  /// In ja, this message translates to:
  /// **'運行中のドライバーから遅れ・トラブルの連絡が届きました。'**
  String get noticeDriverReportedBody;
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
