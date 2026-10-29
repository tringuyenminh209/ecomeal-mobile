// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get loginTab => 'Kirish';

  @override
  String get signupTab => 'Roʻyxatdan oʻtish';

  @override
  String get emailLabel => 'Elektron pochta';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get errorEmailRequired => 'Elektron pochta manzilini kiriting';

  @override
  String get errorPasswordRequired => 'Parolni kiriting';

  @override
  String get errorEmailNotConfirmed =>
      'Elektron pochta hali tasdiqlanmagan. Kiruvchi xatlarni tekshiring';

  @override
  String get errorInvalidCredentials => 'Elektron pochta yoki parol notoʻgʻri';

  @override
  String get loginButton => 'Kirish';

  @override
  String get displayNameLabel => 'Koʻrsatiladigan ism';

  @override
  String get errorDisplayNameRequired => 'Koʻrsatiladigan ismni kiriting';

  @override
  String get errorPasswordMin8 =>
      'Parol kamida 8 ta belgidan iborat boʻlishi kerak';

  @override
  String get signupButton => 'Roʻyxatdan oʻtish';

  @override
  String get errorEmailAlreadyRegistered =>
      'Bu elektron pochta allaqachon roʻyxatdan oʻtgan';

  @override
  String get errorSignupFailed =>
      'Roʻyxatdan oʻtib boʻlmadi. Maʼlumotlarni tekshirib, qayta urining';

  @override
  String get errorRateLimited => 'Biroz kutib, keyin qayta urining';

  @override
  String get signupConfirmationTitle => 'Tasdiqlash xati yuborildi';

  @override
  String signupConfirmationBody(String email) {
    return '$email manziliga tasdiqlash xati yuborildi. Roʻyxatdan oʻtishni yakunlash uchun xatdagi havolani bosing.';
  }

  @override
  String get webOnlyAccountTitle => 'Bu hisobdan ilovada foydalanib boʻlmaydi';

  @override
  String get webOnlyAccountBody =>
      'Restoran va EcoMeal boshqaruv jamoasi hisoblari uchun kompyuterdagi boshqaruv panelidan foydalaning.';

  @override
  String get openWebAdmin => 'Boshqaruv panelini ochish';

  @override
  String get errorOpenWebAdmin => 'Boshqaruv panelini ochib boʻlmadi';

  @override
  String get loadErrorTitle => 'Hisob maʼlumotlarini yuklab boʻlmadi';

  @override
  String get loadErrorBody => 'Aloqani tekshirib, qayta urining.';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'Haydovchi';

  @override
  String get driverLoginLead =>
      'EcoMeal tomonidan berilgan haydovchi hisobi bilan kiring.';

  @override
  String get driverAccountIssuedNote =>
      'Hisob EcoMeal boshqaruv jamoasi tomonidan beriladi. Taklif xatidagi havola orqali parol oʻrnatib, soʻng kiring.';

  @override
  String get driverOnlyAppTitle => 'Bu ilova faqat haydovchilar uchun';

  @override
  String get driverOnlyAppBody =>
      'Mijozlar “EcoMeal” ilovasidan, restoranlar va EcoMeal boshqaruv jamoasi esa kompyuterdagi boshqaruv panelidan foydalanishi kerak.';

  @override
  String get driverAccountTitle => 'Bu haydovchi hisobi';

  @override
  String get driverAccountBody =>
      'Haydovchilar “EcoMeal Driver” ilovasi orqali kirishi kerak. Bu ilova faqat mijozlar uchun.';

  @override
  String get storeAppTitle => 'EcoMeal Store';

  @override
  String get adminAppTitle => 'EcoMeal Admin';

  @override
  String get storeBadge => 'Restoran';

  @override
  String get storeLoginLead =>
      'EcoMeal tomonidan berilgan restoran hisobi bilan kiring.';

  @override
  String get storeLoginNote =>
      'Yangi restoranlar veb-sahifa (ecomeal-pi.vercel.app) orqali ariza topshirishi mumkin.';

  @override
  String get adminBadge => 'Boshqaruv';

  @override
  String get adminLoginLead =>
      'Boshqaruv hisobi bilan kiring. Shundan soʻng ikki bosqichli tasdiqlash kodini kiritasiz.';

  @override
  String get storeOnlyAppTitle => 'Bu ilova faqat restoranlar uchun';

  @override
  String get storeOnlyAppBody =>
      'Mijozlar “EcoMeal”, haydovchilar esa “EcoMeal Driver” ilovasidan foydalanishi kerak.';

  @override
  String get adminOnlyAppTitle =>
      'Bu ilova faqat EcoMeal boshqaruv jamoasi uchun';

  @override
  String get adminOnlyAppBody =>
      'Mijozlar “EcoMeal”, restoranlar “EcoMeal Store”, haydovchilar esa “EcoMeal Driver” ilovasidan foydalanishi kerak.';

  @override
  String get driverSuspendedTitle => 'Faoliyatingiz vaqtincha toʻxtatilgan';

  @override
  String get driverSuspendedBody =>
      'Bu hisob hozircha smenaga chiqa olmaydi. Sababi va qayta faollashtirish tartibi boʻyicha EcoMeal boshqaruv jamoasiga murojaat qiling.';

  @override
  String get backToLogin => 'Kirish ekraniga qaytish';

  @override
  String get errorNetwork =>
      'Aloqa xatosi. Internetni tekshirib, qayta urining';

  @override
  String get signOutButton => 'Chiqish';

  @override
  String get errorSignOutFailed => 'Hisobdan chiqib boʻlmadi. Qayta urining';

  @override
  String get onboardingHeadline => 'Bugungi kechki taom — kelajak uchun hissa.';

  @override
  String get onboardingLead =>
      'Eco-Truck shahardagi restoranlarda ortib qolgan mazali taomlarni yaqiningizdagi olish joyiga yetkazadi.';

  @override
  String get onboardingImpact =>
      'Oziq-ovqat isrofini mazali tarzda kamaytiring';

  @override
  String get loginLead => 'Elektron pochta va parol bilan kiring.';

  @override
  String get signupLead => 'Elektron pochta va parol bilan hisob yarating.';

  @override
  String get emailHint => 'example@example.jp';

  @override
  String get passwordHint => 'Parolni kiriting';

  @override
  String get passwordMin8Helper => 'Kamida 8 ta belgi kiriting.';

  @override
  String get showPassword => 'Koʻrsatish';

  @override
  String get hidePassword => 'Yashirish';

  @override
  String get displayNameHint => 'Koʻrsatiladigan ismni kiriting';

  @override
  String get noAccountPrompt => 'Hisobingiz yoʻqmi?';

  @override
  String get haveAccountPrompt => 'Hisobingiz bormi?';

  @override
  String get signupSpamFolderNote => 'Xat kelmasa, spam jildini tekshiring.';

  @override
  String get forgotPasswordPrompt => 'Parolni unutdingizmi?';

  @override
  String get forgotPasswordAction => 'Tiklash';

  @override
  String get resetPasswordTitle => 'Parolni tiklash';

  @override
  String get resetPasswordRequestLead =>
      'Roʻyxatdan oʻtgan elektron pochtangizga parolni tiklash uchun tasdiqlash kodini yuboramiz.';

  @override
  String get resetPasswordSendCodeButton => 'Tasdiqlash kodini yuborish';

  @override
  String resetPasswordCodeLead(String email) {
    return 'Agar $email roʻyxatdan oʻtgan boʻlsa, tasdiqlash kodi yuborildi. Xatdagi kodni va yangi parolni kiriting.';
  }

  @override
  String get verificationCodeLabel => 'Tasdiqlash kodi';

  @override
  String get verificationCodeHint => 'Xatdagi kod';

  @override
  String get newPasswordLabel => 'Yangi parol';

  @override
  String get newPasswordHint => 'Yangi parolni kiriting';

  @override
  String get resetPasswordButton => 'Parolni tiklash';

  @override
  String get resendCodePrompt => 'Kod kelmadimi?';

  @override
  String get resendCodeAction => 'Qayta yuborish';

  @override
  String get codeResent => 'Tasdiqlash kodi qayta yuborildi';

  @override
  String get passwordResetDone => 'Parol tiklandi';

  @override
  String get errorVerificationCodeFormat =>
      'Xatda koʻrsatilgan tasdiqlash kodini (raqamlarni) kiriting';

  @override
  String get errorVerificationCodeInvalid =>
      'Tasdiqlash kodi notoʻgʻri yoki muddati oʻtgan';

  @override
  String get errorSamePassword => 'Joriy paroldan farqli yangi parol kiriting';

  @override
  String get errorResetRequestFailed =>
      'Tasdiqlash kodini yuborib boʻlmadi. Qayta urining';

  @override
  String get errorResetFailed => 'Parolni tiklab boʻlmadi. Qayta urining';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get errorLoadRetry => 'Maʼlumot yuklanmadi. Qayta urinish';

  @override
  String get errorLoadTitle => 'Maʼlumot yuklanmadi.';

  @override
  String get errorLoadBody => 'Aloqani tekshirib, qayta urining.';

  @override
  String get errorLocationUnavailable => 'Joylashuvni aniqlab boʻlmadi';

  @override
  String get errorLocationBody =>
      'Qurilmaning joylashuv sozlamalari va internet aloqasini tekshiring.';

  @override
  String get nearbyBatches => 'Yaqin atrofdagi taom paketlari';

  @override
  String countItems(int count) {
    return '$count ta';
  }

  @override
  String get liveUpdating => 'Joylashuv yangilanmoqda';

  @override
  String get truckRunning => 'Eco-Truck yoʻlda';

  @override
  String truckNumber(int number) {
    return 'Eco-Truck #$number';
  }

  @override
  String truckRouteSummary(int count) {
    return 'Bugungi toʻxtash joylari · $count ta';
  }

  @override
  String get truckTapHint =>
      'Toʻxtash joylari va menyuni koʻrish uchun xaritadagi mashinani yoki shu kartani bosing';

  @override
  String get stopPassed => 'Oʻtib ketildi';

  @override
  String get nextStopBadge => 'Keyingi toʻxtash joyi';

  @override
  String get truckNoBatches => 'Bu mashinada hozir sotuvda taom paketi yoʻq';

  @override
  String get closeTruckRoute => 'Yopish';

  @override
  String truckNextStop(String stopName) {
    return 'Keyingi toʻxtash joyi: $stopName';
  }

  @override
  String truckEta(String time, int minutes) {
    return 'Taxminiy kelish: $time · $minutes daq qoldi';
  }

  @override
  String get homeEmptyTitle => 'Bugun hozircha sotuv rejalashtirilmagan';

  @override
  String get homeEmptyBody =>
      'Eco-Truck yaqinlashganda bildirishnoma olish uchun LINE bilan bogʻlang.';

  @override
  String get setupLineNotify => 'LINE bildirishnomasini sozlash';

  @override
  String get homeEmptyBodyLinked =>
      'Eco-Truck yaqinlashganda, EcoMeal rasmiy hisobi LINE orqali xabar beradi.';

  @override
  String get openLine => 'LINE ilovasini ochish';

  @override
  String get partnerStore => 'EcoMeal hamkor restorani';

  @override
  String get mysteryBag => 'Sirli paket';

  @override
  String remainingBags(int qty) {
    return '$qty ta qoldi';
  }

  @override
  String get batchDetailTitle => 'Taom paketi tafsilotlari';

  @override
  String get priceCalculating => 'Narx hisoblanmoqda...';

  @override
  String get errorPriceLoad => 'Narxni yuklab boʻlmadi';

  @override
  String truckPeek(String stop, String time, int minutes) {
    return 'Eco-Truck yoʻlda · keyingi: $stop $time ($minutes daq qoldi)';
  }

  @override
  String stopWalk(String stop, int minutes) {
    return '$stop · piyoda $minutes daq';
  }

  @override
  String get errorSessionExpired => 'Kirish muddati tugadi. Qaytadan kiring';

  @override
  String get errorPaymentService =>
      'Toʻlov xizmatidagi nosozlik sababli band qilib boʻlmadi. Birozdan soʻng qayta urining';

  @override
  String get errorPriceTooLow =>
      'Bu taom paketini joriy narxda karta orqali toʻlab boʻlmaydi. Boshqa taom paketini tanlang';

  @override
  String minutesRemaining(int minutes) {
    return '$minutes daq qoldi';
  }

  @override
  String get pickupByEcoTruck => 'Eco-Truckʼdan olish';

  @override
  String get allergensHeading => 'Allergenlar haqida maʼlumot';

  @override
  String get allergensNone => 'Yoʻq';

  @override
  String get ingredientsHeading => 'Asosiy masalliqlar va kelib chiqish joyi';

  @override
  String ingredientWithOrigin(String name, String origin) {
    return '$name ($origin)';
  }

  @override
  String get originUnknown => 'Kelib chiqishi nomaʼlum';

  @override
  String get detailNote =>
      'Paket ichidagi taomlar olinguncha sir saqlanadi. Surat namuna uchun berilgan. Allergiyangiz boʻlsa, koʻrsatilgan allergenlar maʼlumotini albatta tekshiring.';

  @override
  String get dailyLimitReached =>
      'Bugungi band qilish limitiga (2 ta) yetdingiz';

  @override
  String get reserveButton => 'Band qilish';

  @override
  String get mapSetupRequired =>
      'Xaritani koʻrsatib boʻlmadi. Quyidagi roʻyxatdan foydalanishingiz mumkin.';

  @override
  String get openLocationSettings => 'Joylashuv sozlamalari';

  @override
  String get batchExpired =>
      'Sotuv muddati tugadi. Boshqa taom paketini tanlang.';

  @override
  String get reservationCountFailed =>
      'Band qilishlar sonini tekshirib boʻlmadi. Qayta urining.';

  @override
  String get homeTab => 'Asosiy';

  @override
  String get reservationsTab => 'Buyurtmalar';

  @override
  String get myPageTab => 'Mening sahifam';

  @override
  String get locateMe => 'Joylashuvim';

  @override
  String get statusPending => 'Miqdor tekshirilmoqda';

  @override
  String get statusAllocated => 'Ajratib qoʻyildi';

  @override
  String get statusPickedUp => 'Qabul qilindi';

  @override
  String get statusRefunded => 'Pul qaytarildi';

  @override
  String get statusExpired => 'Muddati oʻtgan';

  @override
  String get statusCancelled => 'Bekor qilindi';

  @override
  String get reservationConfirmTitle => 'Band qilishni tasdiqlash';

  @override
  String get paymentMethodRequired => 'Toʻlov usuli (majburiy)';

  @override
  String get paymentMethodSection => 'Toʻlov usuli';

  @override
  String get addPaymentMethod => 'Toʻlov usulini qoʻshish';

  @override
  String get addPaymentMethodSub => 'Kredit yoki debet karta';

  @override
  String get defaultCardLabel => 'Asosiy karta';

  @override
  String get addPaymentMethodHint =>
      'Band qilishni tasdiqlash uchun toʻlov usulini qoʻshing.';

  @override
  String get addPaymentMethodButton => 'Toʻlov usulini qoʻshish';

  @override
  String payNotice(String amount) {
    return 'Band qilish tasdiqlanganda $amount yechib olinadi.';
  }

  @override
  String payButton(String amount) {
    return '$amount toʻlash va band qilish';
  }

  @override
  String get errorPaymentMethodsLoad => 'Toʻlov usullarini yuklab boʻlmadi';

  @override
  String get errorPaymentMethodMissing =>
      'Tanlangan karta topilmadi. Toʻlov usulini qaytadan tanlang';

  @override
  String get paymentTitle => 'Toʻlov';

  @override
  String get paymentProcessingTitle => 'Toʻlov amalga oshirilmoqda';

  @override
  String get paymentProcessingBody =>
      'Yakunlanguncha shu ekranda kuting.\nToʻlov tugmasini qayta-qayta bosmang.';

  @override
  String get paymentProcessingNote =>
      'Toʻlov natijasi tekshirilmoqda.\nOdatda bir necha soniya davom etadi.';

  @override
  String paymentSummaryLine(String amount, String card) {
    return '$amount (soliq bilan)  ·  $card';
  }

  @override
  String get reservationCompleteTitle => 'Band qilish yakunlandi';

  @override
  String get paymentDoneTitle => 'Toʻlov yakunlandi';

  @override
  String get paymentDoneBody =>
      'Band qilishingiz qabul qilindi.\nOlish boʻyicha maʼlumotni “Buyurtmalar” boʻlimida koʻrishingiz mumkin.';

  @override
  String pickupPlaceLine(String place) {
    return 'Olish joyi: $place';
  }

  @override
  String pickupTimeLine(String time) {
    return 'Olish vaqti: $time';
  }

  @override
  String get viewReservation => 'Band qilish tafsilotlarini koʻrish';

  @override
  String get paymentDeclinedTitle => 'Toʻlov amalga oshmadi';

  @override
  String get paymentDeclinedBody =>
      'Karta kompaniyasi toʻlovni tasdiqlamadi.\nBoshqa kartani tanlang yoki karta kompaniyasiga murojaat qiling.';

  @override
  String get paymentCardExpiredBody =>
      'Kartaning amal qilish muddati tugagan.\nBoshqa kartani tanlang.';

  @override
  String get paymentNotCompletedNote =>
      'Bu toʻlov yakunlanmadi.\nBand qilish hali tasdiqlanmagan.';

  @override
  String get payWithAnotherCard => 'Boshqa karta bilan toʻlash';

  @override
  String get backToReview => 'Band qilish tafsilotlariga qaytish';

  @override
  String get paymentUnknownTitle => 'Toʻlov natijasini aniqlab boʻlmadi';

  @override
  String get paymentUnknownBody =>
      'Aloqa uzilgani sababli toʻlov holati tekshirilmoqda.\nIkki marta toʻlov boʻlmasligi uchun qayta toʻlamang.';

  @override
  String get paymentUnknownNote =>
      'Toʻlov va band qilish holati tekshirilmoqda.\nInternet aloqasini tekshirib, qayta urining.';

  @override
  String get recheckPayment => 'Toʻlov holatini qayta tekshirish';

  @override
  String get viewReservationHistory => 'Band qilishlar tarixini koʻrish';

  @override
  String get paymentNotFound => 'Toʻlov yakunlanmadi. Qayta urining';

  @override
  String get errorRecheckFailed =>
      'Tekshirib boʻlmadi. Aloqani tekshirib, qayta urining';

  @override
  String get paymentMethodsTitle => 'Toʻlov usullari';

  @override
  String get paymentMethodsSubtitle => 'Kartalarni xavfsiz boshqarish';

  @override
  String get paymentMethodsEmptyTitle => 'Toʻlov usuli qoʻshilmagan';

  @override
  String get paymentMethodsEmptyBody =>
      'Band qilishda birgina bosish orqali toʻlash uchun karta qoʻshing.';

  @override
  String get addCreditCard => '+ Kredit karta qoʻshish';

  @override
  String get paymentProviderNote =>
      'Toʻlov maʼlumotlari toʻlov provayderi tomonidan xavfsiz qayta ishlanadi.';

  @override
  String get registeredCards => 'Saqlangan kartalar';

  @override
  String cardExpiresOn(String expiry) {
    return 'Amal qilish muddati $expiry';
  }

  @override
  String get defaultBadge => 'Asosiy';

  @override
  String get addAnotherCard => '+  Boshqa karta qoʻshish';

  @override
  String get paymentSafetyTitle => 'Toʻlov xavfsizligi';

  @override
  String get paymentSafetyBody =>
      'Karta maʼlumotlari shifrlanadi va toʻlov provayderi tomonidan xavfsiz saqlanadi.\nBir bosishda toʻlash uchun asosiy kartani belgilang.';

  @override
  String get setDefaultCard => 'Asosiy karta sifatida belgilash';

  @override
  String get deleteCard => 'Bu kartani oʻchirish';

  @override
  String get deleteCardTitle => 'Bu karta oʻchirilsinmi?';

  @override
  String deleteCardBody(String card) {
    return '$card oʻchiriladi. Keyingi buyurtmalarda bu kartadan foydalanib boʻlmaydi.';
  }

  @override
  String get deleteConfirm => 'Oʻchirish';

  @override
  String get cardDeleted => 'Karta oʻchirildi';

  @override
  String get defaultCardChanged => 'Asosiy karta oʻzgartirildi';

  @override
  String get addCardTitle => 'Karta qoʻshish';

  @override
  String get addCardSubtitle => 'Xavfsiz toʻlov usuli';

  @override
  String get cardInfoSection => 'Karta maʼlumotlari';

  @override
  String get cardNumberLabel => 'Karta raqami';

  @override
  String get cardNumberHint => '1234  5678  9012  3456';

  @override
  String get cardHolderLabel => 'Karta egasining ismi';

  @override
  String get cardHolderHint => 'Kartadagi ism';

  @override
  String get cardExpiryLabel => 'Amal qilish muddati';

  @override
  String get cardExpiryHint => 'MM / YY';

  @override
  String get cardCvcLabel => 'Xavfsizlik kodi';

  @override
  String get cardCvcHint => 'CVC';

  @override
  String get cardTokenNote =>
      'Karta raqami EcoMeal serverlarida saqlanmaydi, toʻlov provayderi tomonidan xavfsiz saqlanadi. Xavfsizlik kodini hech kimga bermang.';

  @override
  String get cardTermsNote =>
      'Karta qoʻshish orqali toʻlov shartlariga rozilik bildirasiz.';

  @override
  String get addCardButton => 'Karta qoʻshish';

  @override
  String get cardNumberInvalid => 'Karta raqamini tekshiring.';

  @override
  String get cardHolderRequired => 'Karta egasining ismini kiriting.';

  @override
  String get cardExpiryInvalid => 'Amal qilish muddatini tekshiring.';

  @override
  String get cardCvcInvalid => 'Xavfsizlik kodini tekshiring.';

  @override
  String get errorCardLimit => 'Koʻpi bilan 10 ta karta saqlash mumkin';

  @override
  String get errorCardAdd => 'Kartani qoʻshib boʻlmadi. Qayta urining';

  @override
  String get testPaymentNote =>
      'Sinov rejimida haqiqiy toʻlov yechilmaydi. 4242 4242 4242 4242 sinov kartasidan foydalaning (0002 bilan tugaydigan kartalar rad etiladi).';

  @override
  String paymentMethodRowDefault(String card) {
    return '$card · Asosiy';
  }

  @override
  String get paymentMethodRowNone => 'Qoʻshilmagan';

  @override
  String get freeCancelTitle =>
      'Olish vaqtidan 30 daqiqa oldingacha bepul bekor qilish';

  @override
  String get freeCancelBody =>
      'Olish vaqtidan 30 daqiqa oldingacha bepul bekor qilish mumkin (masalan, 20:00 da olish boʻlsa, 19:30 gacha). Band qilishlar tarixidan bekor qilishingiz mumkin.';

  @override
  String get errorReservationFailed =>
      'Band qilib boʻlmadi. Biroz kutib, qayta urining';

  @override
  String get errorDailyLimit =>
      'Bugungi band qilish limitiga (2 ta) yetganingiz sababli band qilib boʻlmadi. Band qilinganlarni “Buyurtma” boʻlimida koʻrishingiz mumkin';

  @override
  String get errorSoldOutAtStop =>
      'Bu olish joyidagi paketlar sotilib boʻldi. Boshqa taom paketini tanlang';

  @override
  String get errorBatchUnavailable =>
      'Bu taom paketi uchun band qilish yakunlandi. Boshqa taom paketini tanlang';

  @override
  String get actionSeeReservations => 'Band qilishlarni koʻrish';

  @override
  String get actionFindOtherBags => 'Boshqa taom paketlarini izlash';

  @override
  String get tryAgain => 'Qayta urinish';

  @override
  String get orderHistoryTitle => 'Band qilishlar tarixi';

  @override
  String get orderHistorySubtitle => 'Sizning EcoMeal tarixingiz';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get filterActive => 'Faol';

  @override
  String get filterCompleted => 'Yakunlangan';

  @override
  String get orderHistoryEmpty => 'Hozircha band qilishlar yoʻq';

  @override
  String get cancelDialogTitle => 'Band qilish bekor qilinsinmi?';

  @override
  String get cancelDialogFree =>
      'Olish vaqtidan 30 daqiqa oldingacha bepul bekor qilish mumkin. Hozir bekor qilsangiz, pul toʻliq qaytariladi.';

  @override
  String get cancelDialogNoRefund =>
      'Olish vaqtiga 30 daqiqadan kam qolgani sababli, bekor qilsangiz ham pul qaytarilmaydi.';

  @override
  String get back => 'Orqaga';

  @override
  String get cancelConfirmButton => 'Bekor qilish';

  @override
  String cancelledWithRefund(int amount) {
    return 'Bekor qilindi (¥$amount qaytariladi)';
  }

  @override
  String get cancelledNoRefund => 'Bekor qilindi (pul qaytarilmaydi)';

  @override
  String get errorCancelFailed => 'Bekor qilib boʻlmadi. Qayta urining';

  @override
  String reservedOrderLabel(String number) {
    return 'Band qilingan · Buyurtma $number';
  }

  @override
  String get reservedPaid => 'Toʻlangan';

  @override
  String orderNumber(String number) {
    return 'Buyurtma $number';
  }

  @override
  String get pendingExplanation =>
      'Haydovchi miqdorni tekshirmoqda. Agar paketlar yetarli boʻlmasa, har bir olish joyida avval band qilganlarga navbat bilan ajratiladi. Ajratib boʻlmagan qismi uchun pul avtomatik qaytariladi.';

  @override
  String allocatedExplanation(String stopName) {
    return '$stopName olish joyida siz uchun 1 ta paket ajratib qoʻyildi. QR kod hamda olish vaqti va joyini “Olish yoʻriqnomasi”da koʻring.';
  }

  @override
  String get freeCancelExpired =>
      'Bepul bekor qilish muddati oʻtgan (pul qaytarilmaydi)';

  @override
  String get cancelButton => 'Bekor qilish';

  @override
  String manualCodeLabel(String code) {
    return 'Qoʻlda kiritish kodi: $code';
  }

  @override
  String get pickupQrTitle => 'Olish QR kodi';

  @override
  String get pickupQrCaption =>
      'Olish vaqtida haydovchiga ushbu QR kodni skanerlating yoki kodni ayting.';

  @override
  String get refundFullBadge => 'Toʻliq qaytariladi';

  @override
  String get refundFullNote =>
      'Joriy holat boʻyicha bekor qilingandan soʻng pul toʻliq qaytariladi.';

  @override
  String get refundNoneBadge => 'Pul qaytarilmaydi';

  @override
  String get refundNoneNote =>
      'Olish vaqtiga 30 daqiqa yoki undan kam qolgani uchun bekor qilingach pul qaytarilmaydi.';

  @override
  String get errorBadge => 'Xato';

  @override
  String get browseBatches => 'Yaqin atrofdagi taom paketlarini koʻrish';

  @override
  String totalWithQuantity(int quantity) {
    return 'Jami (soliq bilan · soni $quantity)';
  }

  @override
  String todayTime(String time) {
    return 'Bugun $time';
  }

  @override
  String errorDisplayNameTooLong(int max) {
    return 'Koʻrsatiladigan ism $max ta belgidan oshmasligi kerak';
  }

  @override
  String errorNameKanaTooLong(int max) {
    return 'Furigana $max ta belgidan oshmasligi kerak';
  }

  @override
  String get errorLanguageSave => 'Til sozlamasini saqlab boʻlmadi';

  @override
  String get errorLineStatusLoad =>
      'LINE bogʻlanish holatini tekshirib boʻlmadi';

  @override
  String get lineLinked => 'LINE bogʻlangan';

  @override
  String get lineLinkedBody =>
      'Olish haqidagi bildirishnomalarni LINE orqali koʻrishingiz mumkin';

  @override
  String get lineLinkHint =>
      'Bildirishnomalar LINE ilovasidagi EcoMeal rasmiy hisobi chatiga keladi';

  @override
  String get lineOpenChat => 'LINE suhbatini ochish';

  @override
  String get errorOpenLine => 'LINE ilovasini ochib boʻlmadi';

  @override
  String get errorLineLinkFailed =>
      'LINE bilan bogʻlab boʻlmadi. Qayta urining';

  @override
  String get lineLinkButton => 'LINE bilan bogʻlash';

  @override
  String get logoutDialogTitle => 'Hisobdan chiqasizmi?';

  @override
  String get logoutDialogBody => 'Chiqsangiz, kirish ekraniga qaytasiz.';

  @override
  String get profileSaved => 'Profil yangilandi';

  @override
  String get errorSaveFailed => 'Saqlab boʻlmadi. Qayta urining';

  @override
  String get discardDialogTitle => 'Oʻzgarishlar bekor qilinsinmi?';

  @override
  String get discardDialogBody => 'Kiritilgan oʻzgarishlar saqlanmaydi.';

  @override
  String get keepEditing => 'Tahrirlashni davom ettirish';

  @override
  String get discard => 'Bekor qilish';

  @override
  String get profileEditTitle => 'Profilni tahrirlash';

  @override
  String get requiredBadge => 'Majburiy';

  @override
  String get optionalBadge => 'Ixtiyoriy';

  @override
  String get nameKanaLabel => 'Furigana (ism talaffuzi)';

  @override
  String get nameKanaHint => 'Masalan: Haruka Mika';

  @override
  String get emailNotEditable =>
      'Elektron pochta manzilini oʻzgartirib boʻlmaydi';

  @override
  String get credentialsChangeOutOfScope =>
      'Bu ekranda elektron pochta va parolni oʻzgartirib boʻlmaydi. Parolni kirish ekranidagi “Parolni unutdingizmi?” orqali tiklash mumkin.';

  @override
  String get saveButton => 'Saqlash';

  @override
  String get languageLabel => 'Til / Language';

  @override
  String get languageNameJa => 'Yapon tili';

  @override
  String get languageNameEn => 'Ingliz tili';

  @override
  String get languageNameVi => 'Vyetnam tili';

  @override
  String get languageNameUz => 'Oʻzbek tili';

  @override
  String get languageSearchHint => 'Tilni qidirish / Search';

  @override
  String get onboardingStart => 'Boshlash';

  @override
  String get errorBatchAlreadyConfirmed =>
      'Bu taomning miqdori allaqachon tasdiqlangan';

  @override
  String get errorStopNotOnRoute =>
      'Tanlangan toʻxtash joyi ushbu marshrutga kiritilmagan';

  @override
  String get errorStopClosed =>
      'Bu toʻxtash joyidan allaqachon joʻnab ketilgan';

  @override
  String get errorTemperatureRange =>
      'Haroratni -30 dan 99.9°C gacha oraliqda kiriting';

  @override
  String get errorConfirmFailed => 'Miqdorni tasdiqlab boʻlmadi. Qayta urining';

  @override
  String get errorTemperatureRequired => 'Haroratni kiriting';

  @override
  String get errorConfirmedQtyRequired => 'Tasdiqlangan miqdorni kiriting';

  @override
  String get errorNonNegativeInteger => '0 yoki undan katta butun son kiriting';

  @override
  String get pickupConfirmTitle => 'Yigʻishni tasdiqlash';

  @override
  String pickupSubtitle(String stopName, int index, int total) {
    return '$stopName • Yigʻish $index/$total';
  }

  @override
  String estimatedMeals(int qty) {
    return 'Taxminan $qty porsiya';
  }

  @override
  String get confirmedQtyLabel => 'Tasdiqlangan miqdor';

  @override
  String get mealUnit => 'porsiya';

  @override
  String get coreTemperatureLabel => 'Olish vaqtidagi ichki harorat';

  @override
  String get coldChainNotice =>
      'Sovutilgan taomlar 10°C yoki undan past ekanini tekshiring. Meʼyordan oshsa, EcoMeal boshqaruv jamoasiga murojaat qiling.';

  @override
  String get coldChainOverLimit =>
      'Meʼyordan (10°C yoki past) oshib ketgan. Bu taomni yigʻish va sotish mumkin emas.';

  @override
  String get distributionStopsLabel => 'Taqsimlanadigan toʻxtash joylari';

  @override
  String get distributionStopsHint =>
      'Joriy marshrutdagi toʻxtash joylarini tanlang. Taomlar tanlangan joylarga taqsimlanadi.';

  @override
  String get noDistributableStops =>
      'Taqsimlash uchun toʻxtash joyi yoʻq (barchasidan joʻnab ketilgan)';

  @override
  String get nextStopLabel => 'Keyingi toʻxtash joyi';

  @override
  String nthStopLabel(int n) {
    return '$n-joy';
  }

  @override
  String distributionStopSubtitle(String order, String time) {
    return '$order • moʻljal $time';
  }

  @override
  String selectedStopsCount(int count) {
    return 'Tanlangan $count ta toʻxtash joyiga taqsimlanadi.';
  }

  @override
  String confirmPickupButton(String qty) {
    return '$qty porsiya olinganini tasdiqlash';
  }

  @override
  String get rejectPickupButton => 'Yigʻmaslik (harorat meʼyoridan yuqori)';

  @override
  String get rejectPickupDialogTitle => 'Bu taom yigʻilmasinmi?';

  @override
  String rejectPickupDialogBody(String celsius) {
    return 'Ichki harorat $celsius°C boʻlib, meʼyordan (10°C yoki past) yuqori. Bu taom sotilmaydi, barcha band qilishlar uchun pul qaytariladi va mijozlarga xabar beriladi. Harorat qaydi saqlanib qoladi.';
  }

  @override
  String get rejectPickupConfirm => 'Yigʻmaslik';

  @override
  String pickupRejectedToast(int refunded) {
    return 'Harorat meʼyoridan oshgani sababli yigʻilmadi ($refunded ta band qilish uchun pul qaytariladi)';
  }

  @override
  String get noTruckAssigned =>
      'Sizga mashina biriktirilmagan. EcoMeal boshqaruv jamoasiga murojaat qiling';

  @override
  String get noRouteTonight => 'Bugungi kechki marshrut hali yoʻq';

  @override
  String get errorLoad => 'Maʼlumotlarni yuklab boʻlmadi';

  @override
  String get tonightRouteTitle => 'Bugungi kechki marshrut';

  @override
  String get gpsUnavailable => 'Joylashuv aniqlanmadi';

  @override
  String get settings => 'Sozlamalar';

  @override
  String minutesShort(int minutes) {
    return '$minutes daq';
  }

  @override
  String stopDoneHandoff(int count) {
    return 'Yakunlandi • $count ta topshirildi';
  }

  @override
  String get stopKindPickup => 'Yigʻish';

  @override
  String stopReservations(int count) {
    return 'Band qilish $count ta';
  }

  @override
  String nextStopPrefixed(String body) {
    return 'Keyingi toʻxtash • $body';
  }

  @override
  String get driverProfileTitle => 'Profil va sozlamalar';

  @override
  String get driverRoleChip => 'Haydovchi';

  @override
  String get assignedTruck => 'Biriktirilgan mashina';

  @override
  String get unassigned => 'Biriktirilmagan';

  @override
  String get plateNumberLabel => 'Davlat raqami';

  @override
  String get driverTabRoute => 'Marshrut';

  @override
  String get driverTabPickup => 'Yigʻish';

  @override
  String get driverTabSales => 'Sotuv';

  @override
  String get driverTabEnd => 'Yakun';

  @override
  String get noPickupsTonight => 'Bugun kechqurun yigʻish rejalashtirilmagan';

  @override
  String get gpsSending => 'Joylashuv uzatilmoqda';

  @override
  String get driverAccountSubtitle => 'Haydovchi hisobi';

  @override
  String get errorNotHandoverable =>
      'Bu band qilishni hozirgi holatida topshirib boʻlmaydi';

  @override
  String get errorPaymentNotConfirmed =>
      'Ushbu band qilish toʻlovi hali tasdiqlanmagan. Taomni topshirmasdan, EcoMeal boshqaruv jamoasiga murojaat qiling';

  @override
  String get errorWalkupSoldOut =>
      'Bu toʻxtash joyida oldindan band qilmasdan sotiladigan porsiyalar tugagan';

  @override
  String get errorWalkupNotConfirmed =>
      'Miqdor tasdiqlanmasdan oldin band qilishsiz sotib boʻlmaydi';

  @override
  String get errorBatchExpired => 'Bu taomning sotuv muddati oʻtgan';

  @override
  String get errorDonationExceedsStock =>
      'Xayriya miqdori qolgan zaxiradan oshib ketdi';

  @override
  String get errorDonationNotConfirmed =>
      'Miqdor tasdiqlanmasdan oldin xayriyani qayd etib boʻlmaydi';

  @override
  String get errorDonationStopsOpen =>
      'Hali joʻnab ketilmagan sotuv joylari borligi sababli xayriyani qayd etib boʻlmaydi';

  @override
  String get errorDonationNoteRequired => 'Xayriya qabul qiluvchini kiriting';

  @override
  String get errorNotAssignedDriver =>
      'Siz bu mashinaga biriktirilgan haydovchi emassiz';

  @override
  String get errorGeneric => 'Xatolik yuz berdi. Qayta urining';

  @override
  String get errorDonationQtyRequired => 'Xayriya miqdorini kiriting';

  @override
  String get errorPositiveInteger => '1 yoki undan katta butun son kiriting';

  @override
  String handedOverToast(String number) {
    return 'Topshirish qayd etildi ($number)';
  }

  @override
  String get errorNotWaitingHere =>
      'Ushbu band qilish bu toʻxtash joyida topshiriladigan buyurtma emas';

  @override
  String get errorNoMatchingReservation =>
      'Mos keladigan band qilish topilmadi';

  @override
  String get duplicateCodeTitle => 'Bir xil kodli bir nechta band qilish bor';

  @override
  String duplicateCodeOption(String number, String time) {
    return '$number (band qilingan: $time)';
  }

  @override
  String walkupSoldToast(int price) {
    return 'Band qilishsiz sotuv qayd etildi (¥$price)';
  }

  @override
  String get departDialogTitle => 'Bu toʻxtash joyidan joʻnab ketasizmi?';

  @override
  String currentStop(String name) {
    return 'Joriy toʻxtash joyi: $name';
  }

  @override
  String departWarning(int count) {
    return '$count ta band qilish hali olinmagan. Joʻnab ketsangiz, ular “olinmadi (muddati oʻtgan)” deb belgilanadi va pul qaytarilmaydi.';
  }

  @override
  String get departWarningTitle => 'Olinmagan band qilishlar qolgan';

  @override
  String get cautionBadge => 'Diqqat';

  @override
  String get departConfirm => 'Joʻnab ketish';

  @override
  String departedWithExpired(int count) {
    return 'Joʻnab ketildi ($count ta olinmagan buyurtma muddati tugadi)';
  }

  @override
  String get departed => 'Joʻnab ketildi';

  @override
  String get departedLabel => 'Joʻnab ketgan';

  @override
  String minutesUntilDeparture(int minutes) {
    return 'Joʻnab ketishgacha $minutes daq';
  }

  @override
  String reservationsCount(int count) {
    return 'Band qilish $count';
  }

  @override
  String get reservationHandoffTab => 'Band qilingan';

  @override
  String get walkupTab => 'Joyida sotuv';

  @override
  String get handedOverLabel => 'Topshirilgan';

  @override
  String get waitingLabel => 'Kutilmoqda';

  @override
  String get departButton => 'Toʻxtash joyidan joʻnash';

  @override
  String get scanPickupQr => 'Olish QR kodini skanerlash';

  @override
  String get scanPickupQrHint => 'Mijozning olish QR kodini skanerlang';

  @override
  String get manualCodeFallback => 'QR oʻqilmasa: Kodni qoʻlda kiritish';

  @override
  String get batchLabel => 'Taom';

  @override
  String get noWalkupBatches => 'Bu toʻxtash joyida sotiladigan taom yoʻq';

  @override
  String mealsRemaining(int qty) {
    return '$qty porsiya qoldi';
  }

  @override
  String get registerSale => 'Sotuvni qayd etish';

  @override
  String get soldLabel => 'Sotildi';

  @override
  String get enterPickupCode => 'Olish kodini kiriting';

  @override
  String get pickupCodeHint => 'Masalan: A7K2';

  @override
  String get verifyCode => 'Tekshirish';

  @override
  String get noSalesTonight => 'Bugun kechqurun sotuv rejalashtirilmagan';

  @override
  String get routeEndTitle => 'Marshrutni yakunlash';

  @override
  String get routeSummaryTitle => 'Marshrut yakuni';

  @override
  String get routeEndThanks =>
      'Bugungi kechki marshrut uchun rahmat, charchamang';

  @override
  String mealsCount(int count) {
    return '$count porsiya';
  }

  @override
  String get salesStopsLabel => 'Sotuv joylari';

  @override
  String openStopsWarning(int count) {
    return '$count ta sotuv joyidan hali joʻnab ketilmagan. “Sotuv” boʻlimida joʻnab ketishni tasdiqlang.';
  }

  @override
  String donationBatchOption(String name, int qty, int remaining) {
    return '$name (tasdiqlangan $qty porsiya · qolgan $remaining porsiya)';
  }

  @override
  String donationRecorded(int remaining) {
    return 'Xayriya qayd etildi (bu taomdan $remaining porsiya qoldi)';
  }

  @override
  String get donationTitle =>
      'Sotilmagan porsiyalarni xayriya sifatida qayd etish';

  @override
  String get donationLockedNotice =>
      'Barcha sotuv joylaridan joʻnab ketgach xayriyani qayd etish mumkin (joʻnab ketilgandan keyin sotuv toʻxtaydi va qoldiq aniq boʻladi).';

  @override
  String get noConfirmedBatches => 'Miqdori tasdiqlangan taom yoʻq';

  @override
  String get donationQtyLabel => 'Xayriya miqdori';

  @override
  String get donationRecipientLabel => 'Qabul qiluvchi tashkilot';

  @override
  String get donationRecipientHint => 'Masalan: Bolalar xayriya oshxonasi';

  @override
  String get donationHandedOverCheck =>
      'Xayriya qabul qiluvchiga topshirilganini tasdiqlayman';

  @override
  String get recordDonationButton => 'Xayriyani qayd etish';

  @override
  String get driverLicenseTitle => 'Haydovchilik guvohnomasi';

  @override
  String get licenseStatusNone => 'Topshirilmagan';

  @override
  String get licenseStatusSubmitted => 'Tekshirilmoqda';

  @override
  String get licenseStatusVerified => 'Tasdiqlangan';

  @override
  String get licenseStatusRejected => 'Qaytarilgan';

  @override
  String get licenseNoneBody =>
      'Haydovchilik guvohnomasini suratga olib yuboring. EcoMeal boshqaruv jamoasi tasdiqlamaguncha smenaga chiqa olmaysiz.';

  @override
  String get licenseSubmittedBody =>
      'EcoMeal boshqaruv jamoasi guvohnomani tekshirmoqda. Tasdiqlangandan soʻng smenalarga chiqishingiz mumkin boʻladi.';

  @override
  String licenseExpiresOn(String date) {
    return 'Amal qilish muddati $date';
  }

  @override
  String get licenseRejectedLabel => 'EcoMeal boshqaruv jamoasi xabari';

  @override
  String get licenseUploadButton => 'Suratga olib yuklash';

  @override
  String get licenseResubmitButton => 'Yangilangan guvohnomani yuborish';

  @override
  String get licenseResubmitNote =>
      'Qayta yuborilganda, EcoMeal boshqaruv jamoasi tekshirib chiqquncha yangi smenalarga chiqa olmaysiz.';

  @override
  String get licensePrivacyNote =>
      'Suratni faqat EcoMeal boshqaruv jamoasi koʻra oladi.';

  @override
  String get licenseSourceCamera => 'Kamerada suratga olish';

  @override
  String get licenseSourceGallery => 'Fotosuratlardan tanlash';

  @override
  String get licenseUploadSuccess =>
      'Yuborildi. EcoMeal boshqaruv jamoasi tekshirishini kuting.';

  @override
  String get licenseUploadError =>
      'Yuborib boʻlmadi. Internet aloqasini tekshirib, qayta urinib koʻring.';

  @override
  String upcomingShiftsTitle(int days) {
    return 'Kelgusi smenalar ($days kun)';
  }

  @override
  String get upcomingShiftsEmpty =>
      'Rejalashtirilgan smenalar yoʻq. Smenalar belgilangach, shu yerda koʻrinadi.';

  @override
  String get shiftsLoadError => 'Smenalarni yuklab boʻlmadi.';

  @override
  String get torchOn => 'Chiroqni yoqish';

  @override
  String get torchOff => 'Chiroqni oʻchirish';

  @override
  String get mealPhotoLabel => 'Taom surati';

  @override
  String get detailNotePhoto =>
      'Bu surat restoran tomonidan joylashtirilgan. Taom miqdori va koʻrinishi suratdagidan farq qilishi mumkin. Agar allergiyangiz boʻlsa, koʻrsatilgan allergenlar maʼlumotini tekshiring.';

  @override
  String get legalTermsTitle => 'Foydalanish shartlari';

  @override
  String get legalPrivacyTitle => 'Maxfiylik siyosati';

  @override
  String get legalEnactedOn =>
      'Tahrirlangan sana: 2026-yil 11-oktyabr (Qabul qilingan sana: 2026-yil 9-oktyabr)';

  @override
  String get legalDemoNotice =>
      'Ushbu matn bitiruv loyihasining sinov (demo) versiyasi uchun tayyorlangan. Xizmat rasman ishga tushirilishidan oldin mutaxassislar koʻrigidan oʻtkaziladi.';

  @override
  String get legalContactTitle => 'Bogʻlanish';

  @override
  String get termsArticle1Title => '1-modda (Qoʻllanish doirasi)';

  @override
  String get termsArticle1Body =>
      'Ushbu shartlar EcoMeal smartfon ilovasidan (keyingi oʻrinlarda “Xizmat”) foydalanish qoidalarini belgilaydi. Foydalanuvchi roʻyxatdan oʻtishda ushbu shartlarga rozilik bildirgan holda Xizmatdan foydalanadi.';

  @override
  String get termsArticle2Title => '2-modda (Hisob)';

  @override
  String get termsArticle2Body =>
      'Roʻyxatdan oʻtish elektron pochta va parol, LINE yoki Apple orqali amalga oshiriladi. Maʼlumotlaringizni toʻgʻri saqlang va parolingizni uchinchi shaxslarga bermang. LINE yoki Apple orqali roʻyxatdan oʻtilganda ham ushbu shartlar EcoMeal hisobi sifatida birdek qoʻllaniladi. Noqonuniy foydalanish holatlari aniqlansa, EcoMeal boshqaruv jamoasi hisobdan foydalanishni toʻxtatib qoʻyishi mumkin.';

  @override
  String get termsArticle3Title => '3-modda (Mahsulotlar)';

  @override
  String get termsArticle3Body =>
      'Xizmatda sotiladigan taomlar hamkor restoranlarda shu kuni tayyorlangan va ortib qolgan taomlar (sirli taom paketlari) hisoblanadi. Tarkibi va miqdori kunga qarab farq qiladi, sotuv muddati yaqinlashgan sari narxi pasayib boradi. Xarid qilishdan oldin ilovada allergenlar (28 tur) va xomashyo kelib chiqishini tekshiring. Taomlar bitta oshxonada tayyorlangani sababli, juda oz miqdorda allergenlar aralashib qolish ehtimoli butunlay istisno etilmaydi.';

  @override
  String get termsArticle4Title => '4-modda (Band qilish va toʻlov)';

  @override
  String get termsArticle4Body =>
      'Kuniga koʻpi bilan 2 ta buyurtma band qilish mumkin. Toʻlov saqlangan karta orqali amalga oshiriladi. Hozir Xizmat sinov bosqichida boʻlgani sababli, haqiqiy toʻlov yechilmaydi. Karta raqami va xavfsizlik kodi Xizmat serverlarida saqlanmaydi.';

  @override
  String get termsArticle5Title => '5-modda (Bekor qilish va pulni qaytarish)';

  @override
  String get termsArticle5Body =>
      'Taomni olish vaqtiga 30 daqiqadan koʻproq vaqt qolganda bekor qilinsa, pul toʻliq qaytariladi; 30 daqiqa yoki undan kam vaqt qolganda bekor qilinsa, pul qaytarilmaydi (masalan: olish vaqti 20:00 boʻlsa, 19:30 dan oldin toʻliq qaytariladi, 19:30 dan boshlab esa qaytarilmaydi). Miqdor yetarli boʻlmagani sababli yetkazib berilmagan buyurtmalar uchun pul avtomatik qaytariladi. Mashina olish joyidan joʻnab ketgunga qadar qabul qilib olinmagan buyurtmalar bekor qilinadi va ularning puli qaytarilmaydi.';

  @override
  String get termsArticle6Title => '6-modda (Taomni qabul qilib olish)';

  @override
  String get termsArticle6Body =>
      'Band qilingan olish joyi va vaqtida toʻxtab turgan Eco-Truck oldida buyurtma ekranidagi QR kod yoki tasdiqlash kodini koʻrsatib, taomingizni qabul qilib oling.';

  @override
  String get termsArticle7Title => '7-modda (Joylashuv va bildirishnomalar)';

  @override
  String get termsArticle7Body =>
      'Joylashuv maʼlumotlari yaqin atrofdagi olish joylarini koʻrsatish uchun faqat qurilmangizda ishlatiladi va serverda saqlanmaydi. Bildirishnomalar (mashinaning yaqinlashishi, pulni qaytarish, muammo xabariga javob, sevimli olish joyidagi yangi taom paketlari) ilova bildirishnomalari yoqilgan boʻlsa ilovaga keladi. Agar oʻchirilgan boʻlsa-yu, LINE bogʻlangan boʻlsa, EcoMeal rasmiy LINE hisobidan yuboriladi. Mashinaning yaqinlashishi haqidagi xabar LINE bogʻlangan boʻlsa, LINE orqali yetkaziladi.';

  @override
  String get termsArticle8Title => '8-modda (Profil surati)';

  @override
  String get termsArticle8Body =>
      'Profil surati faqat foydalanuvchining oʻz “Mening sahifam” boʻlimida koʻrinadi. Oʻzgalarning tasviri, mualliflik huquqi kabi uchinchi shaxslar huquqlarini buzuvchi yoki odob-axloq qoidalariga zid suratlarni yuklash taqiqlanadi. EcoMeal boshqaruv jamoasi nomaqbul suratlarni oʻchirib tashlashi mumkin.';

  @override
  String get termsArticle9Title => '9-modda (Taqiqlangan harakatlar)';

  @override
  String get termsArticle9Body =>
      'Qonunchilikka zid harakatlar, boshqa foydalanuvchilar, hamkor restoranlar yoki haydovchilarga xalaqit berish, sotib olingan taomlarni qayta sotish hamda Xizmatga ruxsatsiz kirish taqiqlanadi.';

  @override
  String get termsArticle10Title =>
      '10-modda (Oʻzgartirish, toʻxtatish va javobgarlikni cheklash)';

  @override
  String get termsArticle10Body =>
      'Xizmat bitiruv loyihasi doirasida ishlab chiqilmoqda va sinovdan oʻtkazilmoqda, shu bois uning mazmuni oldindan ogohlantirishsiz oʻzgartirilishi yoki toʻxtatilishi mumkin. Ushbu shartlar oʻzgargan taqdirda ilova orqali xabar beramiz va muhim oʻzgarishlar uchun foydalanuvchidan qayta rozilik soʻraladi.';

  @override
  String get privacySection1Title => '1. Yigʻiladigan maʼlumotlar';

  @override
  String get privacySection1Body =>
      'Roʻyxatdan oʻtish maʼlumotlari (elektron pochta, koʻrsatiladigan ism, furigana, profil surati), band qilish va xaridlar tarixi, toʻlov usuli (faqat karta turi, oxirgi 4 ta raqami va amal qilish muddati), LINE orqali kirilganda yoki bogʻlanganda LINE foydalanuvchi ID raqami, Apple orqali kirilganda Apple taqdim etadigan ID va elektron pochta (jumladan Apple yashirin pochtasi), murojaatlar mazmuni, ilovadan foydalanish holati (taom paketlari va band qilish ekranini ochish qaydlari), xatolik maʼlumotlari (xato tavsifi, qurilma turi, ilova talqini) hamda bildirishnomalar yuborish uchun qurilma identifikatori yigʻiladi. Karta raqami va xavfsizlik kodi bizda yigʻilmaydi va saqlanmaydi (toʻlov tizimi bevosita qabul qiladi).';

  @override
  String get privacySection2Title => '2. Joylashuv maʼlumotlari';

  @override
  String get privacySection2Body =>
      'Yaqin atrofdagi olish joylarini koʻrsatish uchun qurilma joylashuvidan foydalanamiz, biroq uni serverga yubormaymiz va saqlamaymiz.';

  @override
  String get privacySection3Title => '3. Foydalanish maqsadi';

  @override
  String get privacySection3Body =>
      'Band qilish, topshirish va pulni qaytarish jarayonlarini bajarish, buyurtmani olish haqida xabar berish, murojaatlarga javob qaytarish hamda Xizmatni yaxshilash uchun foydalaniladi.';

  @override
  String get privacySection4Title =>
      '4. Uchinchi shaxslarga taqdim etish va qayta ishlashni topshirish';

  @override
  String get privacySection4Body =>
      'Qonunchilikda belgilangan holatlardan tashqari, sizning roziligingizsiz maʼlumotlar uchinchi shaxslarga berilmaydi. Maʼlumotlarni saqlash (Supabase), xaritani koʻrsatish (Google Maps), bildirishnomalar (LINE, Firebase Cloud Messaging), toʻlovlarni qayta ishlash (Stripe) va nosozliklarni kuzatish (Sentry) maqsadida tegishli xizmatlarga maʼlumotlarni qayta ishlash topshiriladi.';

  @override
  String get privacySection5Title =>
      '5. Maʼlumotlarni koʻrish, toʻgʻrilash va oʻchirish soʻrovi';

  @override
  String get privacySection5Body =>
      'Roʻyxatdan oʻtkazilgan maʼlumotlarni koʻrish, toʻgʻrilash yoki oʻchirish boʻyicha murojaat shakli orqali biz bilan bogʻlaning. Hisobingiz va profil suratingizni istalgan vaqtda “Mening sahifam” boʻlimidan oʻchirishingiz mumkin.';

  @override
  String get termsUpdatedTitle => 'Foydalanish shartlari yangilandi';

  @override
  String get termsUpdatedBody =>
      'EcoMeal ilovasidan foydalanishda davom etish uchun yangilangan Foydalanish shartlari va Maxfiylik siyosatiga rozilik bildirishingiz kerak.';

  @override
  String get termsAgreeAndContinue => 'Roziman, davom etish';

  @override
  String get termsDeclineAndLogout => 'Rozi emasman (Chiqish)';

  @override
  String get errorTermsAcceptFailed =>
      'Rozilikni saqlab boʻlmadi. Qayta urinib koʻring';

  @override
  String get signupConsentBefore => '';

  @override
  String get signupConsentBetween => ' va ';

  @override
  String get signupConsentAfter => 'ga roziman';

  @override
  String get signupConsentHint =>
      'Rozilik belgilangach “Roʻyxatdan oʻtish” tugmasi faollashadi. Toʻliq matnni havola orqali oʻqishingiz mumkin.';

  @override
  String get aboutAppSection => 'Ilova haqida';

  @override
  String get appVersionLabel => 'Versiya';

  @override
  String get profilePhotoSet => 'Surat qoʻyish';

  @override
  String get profilePhotoChange => 'Suratni almashtirish';

  @override
  String get profilePhotoHint =>
      'JPEG yoki PNG (10MB gacha). Kvadrat shaklda qirqib koʻrsatiladi.';

  @override
  String get profilePhotoUploading => 'Surat yuklanmoqda…';

  @override
  String get errorProfilePhotoUpload =>
      'Suratni yuklab boʻlmadi. Internet aloqasini tekshirib, qayta urinib koʻring.';

  @override
  String get errorProfilePhotoInvalid =>
      'Hajmi 10MB dan oshmaydigan JPEG yoki PNG surat tanlang';

  @override
  String get profilePhotoSheetTitle => 'Profil surati';

  @override
  String get profilePhotoTake => 'Suratga olish';

  @override
  String get profilePhotoLibrary => 'Galereyadan tanlash';

  @override
  String get profilePhotoDelete => 'Suratni oʻchirish';

  @override
  String get profilePhotoDeleted => 'Surat oʻchirildi';

  @override
  String get photoAccessDeniedTitle => 'Kamera va rasmlarga ruxsat berilmagan';

  @override
  String get openSettings => 'Sozlamalarni ochish';

  @override
  String get photoAccessDeniedBody =>
      'Qurilma sozlamalarida EcoMeal ilovasiga kamera va rasmlardan foydalanishga ruxsat bering.';

  @override
  String get deleteAccountLink => 'Hisobni oʻchirish';

  @override
  String get deleteAccountTitle => 'Hisobni oʻchirish';

  @override
  String get deleteAccountLead =>
      'Hisob oʻchirilgach, EcoMeal ilovasiga boshqa kira olmaysiz. Ushbu amalni ortga qaytarib boʻlmaydi.';

  @override
  String get deleteAccountRemovedTitle => 'Oʻchiriladigan maʼlumotlar';

  @override
  String get deleteAccountRemoved1 =>
      '• Elektron pochta, koʻrsatiladigan ism, furigana va profil surati';

  @override
  String get deleteAccountRemoved2 =>
      '• Saqlangan kartalar (turi, oxirgi 4 ta raqami, amal qilish muddati)';

  @override
  String get deleteAccountRemoved3 =>
      '• LINE ulanishi va mashina yaqinlashishi haqidagi bildirishnomalar';

  @override
  String get deleteAccountKeptTitle =>
      'Saqlanib qoladigan maʼlumotlar (shaxsingizga bogʻlanmagan holda)';

  @override
  String get deleteAccountKeptBody =>
      'Oldingi band qilish va xaridlar tarixi savdo tushumi hamda restoranlar hisob-kitobini yuritish uchun ism va elektron pochtangiz olib tashlangan holda saqlanadi.';

  @override
  String get deleteAccountNote =>
      'Hali olinmagan buyurtmangiz boʻlsa, uni bekor qiling yoki taomni qabul qilib olgach hisobni oʻchiring. LINE ilovasidagi EcoMeal rasmiy hisobini esa LINE ilovasining oʻzidan doʻstlar roʻyxatidan oʻchirishingiz mumkin.';

  @override
  String get deleteAccountOpenOrders =>
      'Hali olinmagan buyurtmangiz bor. Hisobni oʻchirishdan oldin uni “Buyurtmalar” boʻlimida bekor qiling yoki taomni qabul qilib oling.';

  @override
  String get deleteAccountButton => 'Hisobni oʻchirish';

  @override
  String get deleteAccountDialogTitle => 'Hisobingiz oʻchirilsinmi?';

  @override
  String get deleteAccountDialogBody =>
      'Bu amalni ortga qaytarib boʻlmaydi. Band qilish va xarid qaydlari shaxsingiz aniqlanmaydigan shaklda qoladi.';

  @override
  String get deleteAccountConfirm => 'Oʻchirish';

  @override
  String get accountDeleted => 'Hisob oʻchirildi';

  @override
  String get errorDeleteAccount =>
      'Hisobni oʻchirib boʻlmadi. Qayta urinib koʻring';

  @override
  String get legalTokushohoTitle =>
      'Maxsus tijorat bitimlari toʻgʻrisidagi qonunga muvofiq maʼlumot';

  @override
  String taxIncludedLine(int rate) {
    return 'Shundan isteʼmol soligʻi ($rate%)';
  }

  @override
  String priceTaxIncluded(String price) {
    return '$price (soliq bilan)';
  }

  @override
  String get receiptButton => 'Kvitansiya';

  @override
  String get receiptTitle => 'Kvitansiya';

  @override
  String receiptAddressee(String name) {
    return 'Hurmatli $name';
  }

  @override
  String get receiptPurpose => 'Toʻlov maqsadi: Taomlar uchun';

  @override
  String receiptTaxableLine(int rate) {
    return '$rate% soliq stavkasi boʻyicha (soliq bilan)';
  }

  @override
  String get receiptUsedOn => 'Foydalanilgan sana';

  @override
  String get receiptOrderNumber => 'Buyurtma raqami';

  @override
  String get receiptPaymentMethod => 'Toʻlov usuli';

  @override
  String get receiptPaymentCard => 'Bank kartasi';

  @override
  String get receiptIssuedOn => 'Berilgan sana';

  @override
  String get receiptIssuer => 'EcoMeal boshqaruv jamoasi (bitiruv loyihasi)';

  @override
  String get receiptNote =>
      '※ Ushbu taomlarga imtiyozli soliq stavkasi (8%) qoʻllaniladi. Xizmat rasmiy hisob-faktura beruvchi sifatida roʻyxatdan oʻtmagani sababli roʻyxatdan oʻtish raqami koʻrsatilmagan. Kerak boʻlsa, ushbu ekranni saqlab oling yoki chop eting.';

  @override
  String get stripeCardIncomplete =>
      'Karta raqami, amal qilish muddati va xavfsizlik kodini kiriting.';

  @override
  String get errorCardDeclined =>
      'Bu kartani saqlab boʻlmadi. Boshqa kartani kiritib koʻring';

  @override
  String get pushSectionTitle => 'Ilova bildirishnomalari';

  @override
  String get pushOffTitle => 'Ilova bildirishnomalari';

  @override
  String get pushOffBody =>
      'Mashina yaqinlashganda yoki pul qaytarilganda ushbu telefonga bildirishnoma yetkaziladi.';

  @override
  String get pushEnableButton => 'Bildirishnomalarni yoqish';

  @override
  String get pushOnTitle => 'Bildirishnomalar yoqilgan';

  @override
  String get pushOnBody =>
      'Mashinaning yaqinlashishi, pul qaytarilishi va sevimli olish joyingizdagi yangi taomlar haqida xabar beramiz. Agar LINE bogʻlangan boʻlsa, mashina yaqinlashishi haqidagi xabar LINE orqali yetkaziladi.';

  @override
  String get pushDeniedTitle => 'Bildirishnomalarga ruxsat berilmagan';

  @override
  String get pushDeniedBody =>
      'Qurilma sozlamalarida EcoMeal ilovasi bildirishnomalariga ruxsat bering.';

  @override
  String get errorPushEnable =>
      'Bildirishnomalarni yoqib boʻlmadi. Qayta urinib koʻring';

  @override
  String get reportIssueButton => 'Muammoni bildirish';

  @override
  String get reportIssueTitle => 'Muammo haqida xabar berish';

  @override
  String get reportIssueQuestion => 'Qanday muammo yuz berdi?';

  @override
  String get issueCategoryWrongContents =>
      'Taom tarkibi yoki miqdori buyurtmadagidan farq qiladi';

  @override
  String get issueCategoryQuality =>
      'Sifatida muammo bor (aynigan, yot narsa chiqqan va h.k.)';

  @override
  String get issueCategoryNotReceived => 'Taomni qabul qilib ololmadim';

  @override
  String get issueCategoryOther => 'Boshqa';

  @override
  String get reportIssueDetailLabel => 'Batafsil maʼlumot';

  @override
  String get reportIssueDetailHint =>
      'Masalan: Nonning bir qismi mogʻorlagan ekan';

  @override
  String get reportIssueNote =>
      'Taomni olganingizdan keyin 48 soat ichida xabar bering. EcoMeal boshqaruv jamoasi vaziyatni koʻrib chiqadi va zarur boʻlsa, pulni qaytaradi (natijasi bildirishnoma va buyurtmalar tarixida koʻrsatiladi).';

  @override
  String get reportIssueSubmit => 'Xabarni yuborish';

  @override
  String get reportIssueSent => 'Xabar yuborildi';

  @override
  String get errorReportIssueSelect => 'Muammo turini tanlang';

  @override
  String get errorReportIssueDetail =>
      'Batafsil maʼlumot kiriting (500 belgigacha)';

  @override
  String get errorReportIssueLate =>
      'Taom olinganidan beri 48 soatdan koʻp vaqt oʻtgani sababli ilovadan xabar yuborib boʻlmaydi. Bogʻlanish shakli orqali murojaat qiling';

  @override
  String get errorReportIssueDuplicate =>
      'Ushbu buyurtma boʻyicha allaqachon xabar yuborilgan';

  @override
  String get errorReportIssue =>
      'Xabarni yuborib boʻlmadi. Qayta urinib koʻring';

  @override
  String get issueOpenTitle => 'Muammo yuborildi (koʻrib chiqilmoqda)';

  @override
  String get issueOpenBody =>
      'EcoMeal boshqaruv jamoasi murojaatni koʻrib chiqmoqda va zarur boʻlsa, pulni qaytaradi. Natijasi haqida xabar beramiz.';

  @override
  String issueResolvedRefund(int amount) {
    return 'Hal qilindi: ¥$amount qaytarildi';
  }

  @override
  String get issueResolvedNoRefund => 'Hal qilindi';

  @override
  String get favoriteStopsTitle => 'Sevimli olish joylari';

  @override
  String get favoriteStopsIntro =>
      'Ushbu olish joylarida yangi taom paketlari paydo boʻlsa, ilova bildirishnomasi (yoki LINE) orqali xabar beramiz. Koʻpi bilan 5 ta joyni saqlash mumkin.';

  @override
  String get favoriteStopsHint =>
      'Bugun kechqurun olish mumkin boʻlgan taom paketlarini koʻrish uchun olish joyini bosing. Sevimlilardan chiqarish uchun ★ belgisini bosing. Agar bildirishnoma kelmayotgan boʻlsa, “Mening sahifam”da “Ilova bildirishnomalari”ni yoqing.';

  @override
  String get stopBagsHeading =>
      'Bugun kechqurun ushbu joyda olish mumkin boʻlgan taom paketlari';

  @override
  String get stopBagsEmptyTitle => 'Bugun kechqurun hozircha taom paketi yoʻq';

  @override
  String get stopBagsEmptyBody =>
      'Ushbu olish joyida yangi taom paketi paydo boʻlsa, ilova bildirishnomasi (yoki LINE) orqali xabar beramiz.';

  @override
  String get favoriteStopsEmptyTitle => 'Hozircha sevimli olish joylari yoʻq';

  @override
  String get favoriteStopsEmptyBody =>
      'Taom paketi tafsilotlaridagi olish boʻlimida ☆ belgisini bossangiz, shu olish joyida yangi taomlar chiqqanda sizga xabar beramiz.';

  @override
  String get favoriteStopsRowNone =>
      'Saqlanmagan · Yangi taomlar haqida xabarlar';

  @override
  String favoriteStopsRowCount(int count) {
    return '$count ta joy · Yangi taomlar haqida xabarlar';
  }

  @override
  String get favoriteAddedTitle => 'Sevimlilarga qoʻshildi';

  @override
  String get favoriteAddedBody =>
      'Ushbu olish joyidagi yangi taomlar haqida xabar beramiz.';

  @override
  String get favoriteAddedPushOff =>
      'Bildirishnomalar oʻchirilgan, shuning uchun yangi taomlar haqida xabarlar kelmaydi.';

  @override
  String get favoriteAddedPushDenied =>
      'Bildirishnomalarga ruxsat berilmagani sababli yangi xabarlar kelmaydi.';

  @override
  String get favoriteRemovedTitle => 'Sevimlilardan olib tashlandi';

  @override
  String get favoriteRemovedBody =>
      'Ushbu olish joyi boʻyicha yangi taom bildirishnomalari toʻxtatildi.';

  @override
  String get favoriteFeedbackClose => 'Yopish';

  @override
  String get favoriteLimitReached =>
      'Sevimli olish joylari soni koʻpi bilan 5 ta boʻlishi mumkin. “Mening sahifam” orqali ularni tahrirlang';

  @override
  String get favoriteUpdateFailed =>
      'Sevimlilarni yangilab boʻlmadi. Birozdan soʻng qayta urinib koʻring';

  @override
  String get favoriteAddTooltip => 'Ushbu olish joyini sevimlilarga qoʻshish';

  @override
  String get favoriteRemoveTooltip => 'Sevimlilardan olib tashlash';

  @override
  String get ratingPromptTitle => 'Taom paketi sizga maʼqul boʻldimi?';

  @override
  String get ratingPromptHint =>
      'Baholash uchun yulduzchani bosing (olinganidan keyin 7 kun ichida)';

  @override
  String get ratingLabel1 => 'Qoniqarsiz';

  @override
  String get ratingLabel2 => 'Unchalik yoqmadi';

  @override
  String get ratingLabel3 => 'Oʻrtacha';

  @override
  String get ratingLabel4 => 'Yaxshi';

  @override
  String get ratingLabel5 => 'Aʼlo';

  @override
  String ratingStarSemantics(int count) {
    return '$count ta yulduz';
  }

  @override
  String ratingSheetOrder(String number, String time) {
    return 'Buyurtma #$number · Olingan vaqti $time';
  }

  @override
  String get ratingCommentLabel => 'Restoran uchun fikringiz (ixtiyoriy)';

  @override
  String get ratingCommentHint =>
      'Masalan: Porsiyasi moʻl ekan, olganimda hali iliq edi.';

  @override
  String get ratingPrivacyNote =>
      'Bahoyingiz restoranga ismingiz koʻrsatilmasdan yetkaziladi. Shaxsiy maʼlumotlarni yozmang.';

  @override
  String get ratingSubmit => 'Bahoni yuborish';

  @override
  String get ratingSent => 'Bahoyingiz yuborildi. Rahmat!';

  @override
  String get ratingErrorExpired =>
      'Taom olinganidan beri 7 kun oʻtgani sababli uni baholab boʻlmaydi';

  @override
  String get ratingErrorAlreadyRated => 'Ushbu buyurtma allaqachon baholangan';

  @override
  String get ratingErrorFailed =>
      'Bahoni yuborib boʻlmadi. Qayta urinib koʻring';

  @override
  String get ratedLabel => 'Sizning bahoyingiz';

  @override
  String get ratedThanks => 'Rahmat!';

  @override
  String ratedSemantics(int count) {
    return 'Sizning bahoyingiz: $count ta yulduz';
  }

  @override
  String get impactTitle => 'Siz asrab qolgan oziq-ovqat';

  @override
  String get impactEmpty =>
      'Taom paketini qabul qilib olganingizdan soʻng, isrofdan asrab qolingan taom miqdori va kamaytirilgan CO₂ shu yerda koʻrsatiladi.';

  @override
  String impactBagsValue(int count) {
    return '$count ta';
  }

  @override
  String get impactBagsLabel => 'Qabul qilingan taom paketlari';

  @override
  String get impactFoodLabel => 'Asrab qolingan taomlar';

  @override
  String get impactCo2Label => 'CO₂ kamayishi';

  @override
  String impactApproxKg(String kg) {
    return 'Taxminan ${kg}kg';
  }

  @override
  String impactNote(String bagKg, String factor) {
    return 'Taxminiy koʻrsatkich (1 paket taxminan ${bagKg}kg, 1kg oziq-ovqat isrofi uchun taxminan ${factor}kg CO₂ hisobida)';
  }

  @override
  String get couponsTitle => 'Kuponlar va doʻstlarni taklif qilish';

  @override
  String couponsRowSubtitle(int count) {
    return '$count ta kupon · Doʻstlarni taklif qilib ¥100 oling';
  }

  @override
  String get couponSectionLabel => 'Kupon';

  @override
  String get subtotalLabel => 'Oraliq summa';

  @override
  String couponAmountOff(int amount) {
    return '-¥$amount chegirma';
  }

  @override
  String couponValidUntil(String date) {
    return '$date gacha';
  }

  @override
  String get couponReasonWelcome =>
      'Doʻst taklifi kuponi (Roʻyxatdan oʻtish sovgʻasi)';

  @override
  String get couponReasonReward => 'Doʻst taklifi kuponi (Tavsiya bonusi)';

  @override
  String get couponReasonCampaign => 'Aksiya kuponi';

  @override
  String get couponsUsableHeading => 'Mavjud kuponlar';

  @override
  String get couponsNone => 'Hozircha faol kuponlar yoʻq';

  @override
  String get couponNoneHint =>
      'Doʻstlaringizni taklif qiling va ¥100 kuponiga ega boʻling';

  @override
  String get couponsAutoNote =>
      'Kupon buyurtmani tasdiqlash ekranida avtomatik tarzda qoʻllanadi (bitta buyurtmaga 1 ta kupon). Bepul bekor qilish muddati ichida bekor qilinsa, kupon qaytarib beriladi.';

  @override
  String get errorCouponUnavailable =>
      'Bu kupondan foydalanib boʻlmaydi. Tekshirib, qayta urinib koʻring';

  @override
  String get receiptCouponLine => 'Kupon chegirmasi';

  @override
  String get referralMyCodeLabel => 'Sizning taklif kodingiz';

  @override
  String get referralCopy => 'Nusxalash';

  @override
  String get referralCopied => 'Taklif kodi nusxalandi';

  @override
  String get referralShareLine => 'LINE orqali yuborish';

  @override
  String referralShareText(String code) {
    return 'EcoMeal orqali hali ham mazali boʻlgan sifatli taomlarni arzon narxda oling. Roʻyxatdan oʻtib, “$code” taklif kodini kiriting va ¥100 kuponiga ega boʻling!';
  }

  @override
  String get referralHowItWorks =>
      'Doʻstingiz ushbu kodni kiritsa, unga ¥100 kupon beriladi. Doʻstingiz birinchi taom paketini qabul qilib olganida, sizga ham ¥100 kupon taqdim etiladi.';

  @override
  String get referralEnterLabel => 'Doʻstingizning taklif kodini kiriting';

  @override
  String get referralEnterHint => 'Masalan: EM3PX9';

  @override
  String get referralApply => 'Qoʻllash';

  @override
  String get referralEnterNote =>
      'Roʻyxatdan oʻtgan kundan boshlab 14 kun ichida va birinchi taom paketini olishdan oldin kiritish mumkin.';

  @override
  String referralApplied(String code) {
    return '$code taklif kodi qoʻllanildi';
  }

  @override
  String get referralAppliedToast => '¥100 kuponiga ega boʻldingiz';

  @override
  String get referralErrorFormat =>
      '6 ta belgidan iborat taklif kodini kiriting';

  @override
  String get referralErrorNotFound => 'Bunday taklif kodi topilmadi';

  @override
  String get referralErrorOwnCode =>
      'Oʻzingizning taklif kodingizdan foydalana olmaysiz';

  @override
  String get referralErrorNotEligible =>
      'Taklif kodini kiritish muddati tugagan';

  @override
  String get referralErrorFailed =>
      'Taklif kodini qoʻllab boʻlmadi. Qayta urinib koʻring';

  @override
  String get socialLoginDivider => 'yoki';

  @override
  String get lineLoginButton => 'LINE orqali kirish';

  @override
  String get appleLoginButton => 'Apple orqali kirish';

  @override
  String get socialLoginNote =>
      'Birinchi marta kirayotgan boʻlsangiz, LINE yoki Apple hisobingiz orqali EcoMeal hisobi yaratiladi.';

  @override
  String get lineLoginFailed =>
      'LINE orqali kirib boʻlmadi. Birozdan soʻng qayta urinib koʻring';

  @override
  String get appleLoginFailed =>
      'Apple orqali kirib boʻlmadi. Birozdan soʻng qayta urinib koʻring';

  @override
  String get socialLoginNotCustomer =>
      'Ushbu hisob bilan LINE orqali kirib boʻlmaydi. Iltimos, elektron pochta va parol orqali kiring';

  @override
  String get signedInWithLine => 'LINE orqali kirilgan';

  @override
  String get storeReviewPendingTitle => 'Koʻrib chiqilmoqda';

  @override
  String get storeReviewPendingBody =>
      'EcoMeal arizangiz maʼlumotlarini tekshirmoqda. Natijani elektron pochta orqali maʼlum qilamiz.';

  @override
  String get storeReviewCheckButton => 'Koʻrib chiqish natijasini koʻrish';

  @override
  String get storeFieldName => 'Restoran nomi';

  @override
  String get storeFieldAppliedAt => 'Ariza sanasi';

  @override
  String get storeFieldApplicant => 'Ariza beruvchi';

  @override
  String get storeReviewRejectedTitle => 'Tasdiqlanmadi';

  @override
  String get storeReviewRejectedBody =>
      'Maʼlumotlarni qayta koʻrib chiqib, yana ariza topshirmoqchi boʻlsangiz, “Bogʻlanish” boʻlimi orqali murojaat qiling.';

  @override
  String get storeRejectionReasonLabel => 'Rad etish sababi';

  @override
  String get storeNotRegisteredTitle => 'Restoran hali roʻyxatdan oʻtmagan';

  @override
  String get storeNotRegisteredBody =>
      'Veb-sayt (ecomeal-pi.vercel.app) orqali restoranni roʻyxatdan oʻtkazishga ariza bering. Tasdiqlangach, ushbu ilovada taomlarni sotuvga qoʻyishingiz mumkin.';

  @override
  String get storeTabHome => 'Asosiy';

  @override
  String get storeTabRegister => 'Kiritish';

  @override
  String get storeTabSettlement => 'Tushum';

  @override
  String get storeTabSettings => 'Sozlamalar';

  @override
  String get storeRegisterCta => 'Bugungi taomlarni sotuvga qoʻyish';

  @override
  String storeRegisterDeadline(String time, String remaining) {
    return 'Tavsiya vaqti $time gacha ($remaining qoldi)';
  }

  @override
  String storeRegisterDeadlinePassed(String time) {
    return 'Tavsiya vaqti $time dan oʻtib ketdi. Mashina joʻnab ketgunicha taomlarni kiritishingiz mumkin.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours soat $minutes daq';
  }

  @override
  String get storePhotoRemovedTitle => 'Taom surati olib tashlandi';

  @override
  String get storePhotoRemovedHint =>
      'Keyingi safar restoran nomi yoki logotipi tushmagan suratdan foydalaning.';

  @override
  String get storePhotoRemovedAck => 'Tushunarli';

  @override
  String get storeTodayBatches => 'Bugungi taomlar';

  @override
  String get storeBatchStatusEstimated => 'Olib ketish kutilmoqda';

  @override
  String get storeBatchStatusOnSale => 'Sotuvda';

  @override
  String get storeBatchStatusEnded => 'Yakunlandi';

  @override
  String storeSellBy(String time) {
    return 'Sotuv $time gacha';
  }

  @override
  String storeCollectionPlanned(String time) {
    return 'Olib ketish vaqti: $time';
  }

  @override
  String storeBatchQtyConfirmed(int estimated, int confirmed) {
    return 'Rejada $estimated porsiya → Olib ketildi $confirmed porsiya';
  }

  @override
  String storeBatchQtyEstimated(int estimated) {
    return 'Rejada $estimated porsiya (olib ketish kutilmoqda)';
  }

  @override
  String storeBatchCounts(int reserved, int pickedUp) {
    return 'Band: $reserved ta · Topshirildi: $pickedUp ta';
  }

  @override
  String storeBatchReserved(int reserved) {
    return 'Band: $reserved ta';
  }

  @override
  String get storeNoBatchesTitle => 'Bugun hali taom kiritilmadi';

  @override
  String get storeNoBatchesBody =>
      'Ortib qolishi mumkin boʻlgan taomlar boʻlsa, soat 15:00–16:00 oraligʻida kiriting. Kechki mashina kelib olib ketadi.';

  @override
  String get storeLoadErrorTitle => 'Yuklab boʻlmadi';

  @override
  String get storeLoadErrorBody =>
      'Internet aloqasini tekshirib, qayta urinib koʻring.';

  @override
  String get storeReload => 'Qayta yuklash';

  @override
  String get storeMonthSales => 'Bu oydagi savdo';

  @override
  String storeMonthSalesSub(int orders, String from) {
    return '$orders porsiya ($from dan)';
  }

  @override
  String get storeMonthPayout => 'Bu oydagi restoran ulushi';

  @override
  String get storeMonthStatsLabel => 'Bu oydagi savdo va restoran ulushi';

  @override
  String get storeTapToReload => 'Qayta yuklash uchun bosing';

  @override
  String get storeRatingsLoadFailed => 'Mijozlar baholarini yuklab boʻlmadi';

  @override
  String storeSharePct(String pct) {
    return 'Ulush $pct%';
  }

  @override
  String storeRatingsRow(String average) {
    return 'Mijozlar bahosi $average';
  }

  @override
  String storeRatingsSub(int count) {
    return 'Oxirgi 30 kun · $count ta baho';
  }

  @override
  String get storeRatingsNone => 'Hozircha baholar yoʻq';

  @override
  String get storeBatchDetailTitle => 'Taom tafsilotlari';

  @override
  String storeBatchPriceLine(String price, String time) {
    return '$price · Sotuv $time gacha';
  }

  @override
  String get storeStatConfirmed => 'Olib ketilgan';

  @override
  String get storeStatEstimated => 'Taxminiy miqdor';

  @override
  String get storeStatReserved => 'Band qilingan';

  @override
  String get storeStatPickedUp => 'Topshirildi';

  @override
  String get storeStatRemaining => 'Qoldi';

  @override
  String get storeStatCollection => 'Olib ketish';

  @override
  String get storeProgress => 'Jarayon';

  @override
  String get storeStepEstimated => 'Kiritildi';

  @override
  String storeStepEstimatedDetail(int qty) {
    return '$qty porsiya kiritildi';
  }

  @override
  String get storeStepCollected => 'Haydovchi qabul qildi';

  @override
  String storeStepCollectedPlanned(String time) {
    return '$time da kutilmoqda';
  }

  @override
  String get storeStepCollectedHint =>
      'Haydovchi kelganida, haqiqiy miqdorni birga tekshiring.';

  @override
  String storeStepCollectedBy(String name) {
    return 'Haydovchi $name';
  }

  @override
  String get storeStepOnSale => 'Sotuvda';

  @override
  String storeStepOnSaleUntil(String time) {
    return '$time gacha';
  }

  @override
  String storeStepOnSaleDetail(int count) {
    return '$count ta olish joyida sotilmoqda';
  }

  @override
  String get storeStepEnded => 'Yakunlandi';

  @override
  String get storeStepEndedDetail =>
      'Sotilmay qolgani xayriya yoki hisobdan chiqarish sifatida qayd etiladi.';

  @override
  String get storeStopsRemaining => 'Olish joylari boʻyicha qoldiq';

  @override
  String get storeAutoUpdate => 'Avtomatik yangilanadi';

  @override
  String storeStopRemaining(int remaining) {
    return '$remaining ta qoldi';
  }

  @override
  String storeStopAllocated(int allocated) {
    return '/$allocated porsiya';
  }

  @override
  String get storeEstimatedNote =>
      'Haydovchi olib ketayotganda porsiyalar soni band qilinganidan kam chiqsa, taomlar navbat boʻyicha avvalroq band qilgan mijozlarga beriladi, qolgan buyurtmalar uchun esa pul avtomatik qaytariladi.';

  @override
  String get storeBatchNotFound => 'Ushbu eʼlon topilmadi';

  @override
  String storeTemperature(String celsius) {
    return '$celsius°C';
  }

  @override
  String get storeRegisterTitle => 'Bugungi taomlarni sotuvga qoʻyish';

  @override
  String get storeRegisterSubtitle =>
      'Taxminiy miqdorni kiriting — aniq soni haydovchi olib ketayotganda sanaladi';

  @override
  String get storeRequired => 'Majburiy';

  @override
  String get storePhotoTake => 'Taomni suratga olish';

  @override
  String get storePhotoRetake => 'Qayta suratga olish';

  @override
  String get storePhotoHint =>
      'Iltimos, suratga restoran nomi, logotipi va odamlarning yuzi tushmasin.';

  @override
  String get storePhotoCamera => 'Kamerada suratga olish';

  @override
  String get storePhotoLibrary => 'Galereyadan tanlash';

  @override
  String get storePhotoRemove => 'Suratni olib tashlash';

  @override
  String storeErrSummary(int count) {
    return 'Kiritilgan maʼlumotlarni tekshiring ($count ta joy)';
  }

  @override
  String get storePhotoCameraDenied => 'Kameradan foydalanib boʻlmadi';

  @override
  String get storePhotoCameraDeniedBody =>
      '“Sozlamalar”da kameraga ruxsat bering yoki galereyadan surat tanlang. Kiritgan maʼlumotlaringiz saqlanib qoladi.';

  @override
  String get storePhotoLibraryDenied => 'Galereyadan foydalanib boʻlmadi';

  @override
  String get storePhotoLibraryDeniedBody =>
      '“Sozlamalar”da galereyaga ruxsat bering yoki kamerada suratga oling. Kiritgan maʼlumotlaringiz saqlanib qoladi.';

  @override
  String get photoReadFailed => 'Suratni yuklab boʻlmadi';

  @override
  String get photoReadFailedBody =>
      'Qayta urinib koʻring yoki boshqa surat tanlang. Kiritilgan maʼlumotlar saqlab qolindi.';

  @override
  String get storeQtyLabel => 'Tayyorlanadigan taxminiy miqdor';

  @override
  String get storeQtyUnit => 'porsiya';

  @override
  String get storeQtyDecrease => '1 porsiya kamaytirish';

  @override
  String get storeQtyIncrease => '1 porsiya koʻpaytirish';

  @override
  String get storePriceLabel => '1 porsiya narxi (soliq bilan)';

  @override
  String get storePriceHint =>
      'Sotuv muddati yaqinlashgan sari mijozlar uchun narx avtomatik ravishda pasayadi (30–70% chegirma).';

  @override
  String get storeSellByLabel => 'Sotuv tugash vaqti';

  @override
  String get storeSellByToday => 'Bugun';

  @override
  String get storeSellByTomorrow => 'Ertaga';

  @override
  String get storeSellByChange => 'Oʻzgartirish';

  @override
  String get storeTimeTitle => 'Sotuv tugash vaqti';

  @override
  String get storeTimeHint =>
      'Vaqtni kiriting yoki quyidagi variantlardan tanlang';

  @override
  String get storeTimeDayNote =>
      '“Bugun” yoki “Ertaga” kiritish ekranidagi tanlovga qarab belgilanadi';

  @override
  String get storeTimeHour => 'Soat';

  @override
  String get storeTimeMinute => 'Daqiqa';

  @override
  String get storeTime24h => '24 soatlik format (00–23 soat / 00–59 daqiqa)';

  @override
  String get storeTimePresets => 'Tez-tez tanlanadigan vaqtlar';

  @override
  String get storeTimeConfirm => 'Shu vaqtni tanlash';

  @override
  String get storeTimeInvalid =>
      'Soatni 00–23, daqiqani 00–59 oraligʻida kiriting';

  @override
  String get storeAllergenLabel => 'Allergenlar (28 tur)';

  @override
  String get storeAllergenShowAll => 'Barchasini koʻrsatish (28 tur)';

  @override
  String get storeAllergenHint =>
      'Tegishli barcha turlarni belgilang. Koʻp uchraydigan 12 tur koʻrsatilgan. Hech biri boʻlmasa, “Allergenlar mavjud emas” bandini belgilang.';

  @override
  String get storeNoAllergens => 'Allergenlar mavjud emas';

  @override
  String get storeErrAllergenRequired =>
      'Allergenlarni tanlang yoki “Allergenlar mavjud emas” bandini belgilang';

  @override
  String storeAllergenSelected(int count) {
    return '$count ta tur tanlandi';
  }

  @override
  String get storeAllergenSheetNote =>
      'Tanlangan maʼlumotlar oyna yopilsa ham kiritish ekranida saqlanib qoladi.';

  @override
  String get storeAllergenMandatory => 'Koʻrsatish majburiy boʻlganlar (8 tur)';

  @override
  String get storeAllergenRecommended =>
      'Koʻrsatish tavsiya etilganlar (20 tur)';

  @override
  String get storeAllergenClear => 'Barchasini tozalash';

  @override
  String storeAllergenDone(int count) {
    return 'Tayyor ($count tur)';
  }

  @override
  String get storeAllergenLoadFailed =>
      'Allergenlar roʻyxatini yuklab boʻlmadi.';

  @override
  String get storeIngredientsLabel => 'Asosiy masalliqlar va kelib chiqishi';

  @override
  String get storeIngredientAdd => '＋ Masalliq qoʻshish';

  @override
  String get storeIngredientName => 'Masalliq';

  @override
  String get storeIngredientOrigin => 'Kelib chiqishi';

  @override
  String get storeIngredientOriginHint => 'Masalan: Yaponiya (Kagoshima)';

  @override
  String storeIngredientRemove(String name) {
    return '$name ni oʻchirish';
  }

  @override
  String get storeAdd => 'Qoʻshish';

  @override
  String get storeCancel => 'Bekor qilish';

  @override
  String get storeReviewButton => 'Maʼlumotlarni tekshirish';

  @override
  String get storeConfirmTitle => 'Shu maʼlumotlar bilan kiritilsinmi?';

  @override
  String get storeConfirmQty => 'Miqdor';

  @override
  String storeConfirmQtyValue(int qty) {
    return '$qty porsiya';
  }

  @override
  String get storeConfirmAllergens => 'Allergenlar';

  @override
  String get storeConfirmIngredients => 'Masalliqlar';

  @override
  String get storeConfirmNone => 'Yoʻq';

  @override
  String storeConfirmIngredientsMore(String first, int more) {
    return '$first va yana $more ta';
  }

  @override
  String get storeConfirmNote =>
      'Kiritilgach, kechki mashina kelib olib ketadi va mijozlar taomni band qila oladi.';

  @override
  String get storeConfirmPreviewTitle => 'Mijozlarga shunday koʻrinadi';

  @override
  String storeConfirmPreviewPrice(String price) {
    return 'Hozirgi narx $price';
  }

  @override
  String get storeConfirmPreviewPriceNote =>
      'Sotuv muddati yaqinlashgan sari narx yanada tushadi';

  @override
  String get storeConfirmEstimate => 'Restoran ulushi (taxminiy)';

  @override
  String storeConfirmEstimateValue(String amount) {
    return 'Koʻpi bilan $amount';
  }

  @override
  String storeConfirmEstimateNote(String pct) {
    return 'Barcha taom hozirgi narxda sotilgandagi taxminiy summa (restoran ulushi: $pct%). Narx arzonlashsa yoki sotilmay qolsa, summa kamayadi.';
  }

  @override
  String get storeConfirmPreviewFailed =>
      'Narxni hisoblab boʻlmadi. Lekin shunday holatda ham kiritish mumkin.';

  @override
  String get storeConfirmSubmit => 'Kiritish';

  @override
  String get storeConfirmBack => 'Ortga qaytib tuzatish';

  @override
  String storeSellByValue(String day, String time) {
    return '$day $time';
  }

  @override
  String get storeDoneTitle => 'Kiritildi';

  @override
  String get storeDoneBody =>
      'Kechki mashina kelib olib ketadi. Yangi buyurtma boʻlsa, sizga xabar beramiz.';

  @override
  String get storeDoneCollection => 'Olib ketish vaqti';

  @override
  String storeDoneCollectionValue(String time) {
    return 'Taxminan $time';
  }

  @override
  String get storeDoneRoute => 'Bugungi kechki mashina';

  @override
  String storeDoneRouteMore(String names) {
    return '$names va boshqalar';
  }

  @override
  String get storeDoneViewBatch => 'Eʼlonni koʻrish';

  @override
  String get storeDoneHome => 'Asosiy ekranga';

  @override
  String get storeErrPrice => 'Narxni kamida ¥200 qilib belgilang';

  @override
  String get storeErrSellByPast =>
      'Sotuv tugash vaqti hozirgi vaqtdan keyin boʻlishi kerak';

  @override
  String get storeErrIngredientName => 'Masalliq nomini kiriting';

  @override
  String get storeErrPhotoUpload =>
      'Suratni yuklab boʻlmadi. Internet aloqasini tekshirib, qayta urinib koʻring yoki suratni olib tashlab kiriting. (Taom hali kiritilmadi)';

  @override
  String get storeErrNotApproved =>
      'Restoraningiz hali tasdiqlanmagani sababli taomlarni kiritib boʻlmaydi.';

  @override
  String get storeErrPhotoInvalid =>
      'Suratni saqlab boʻlmadi. Boshqa surat tanlab, qayta urinib koʻring.';

  @override
  String get storeErrNoTruck =>
      'Bugungi kechki mashina hali belgilanmagani sababli taomlarni kiritib boʻlmaydi. Iltimos, EcoMeal bilan bogʻlaning.';

  @override
  String get storeErrNoStops =>
      'Olish joylari hali belgilanmagani sababli taomlarni kiritib boʻlmaydi. Iltimos, EcoMeal bilan bogʻlaning.';

  @override
  String get storeErrNoStopsLeft =>
      'Bugungi mashina restoraningizdan keyin toʻxtaydigan olish joyi qolmagani sababli taomlarni kiritib boʻlmaydi.';

  @override
  String get storeErrTruckDeparted =>
      'Bugungi mashina restoraningizdan allaqachon joʻnab ketgani sababli endi yangi taom kiritib boʻlmaydi.';

  @override
  String get storeErrRegisterFailed =>
      'Kiritib boʻlmadi. Internet aloqasini tekshirib, qayta urinib koʻring.';

  @override
  String get storeErrResultUnknown =>
      'Taom kiritilganini aniqlab boʻlmadi. Iltimos, “Kiritish” tugmasini yana bir bor bosing. Agar avval kiritilgan boʻlsa, oʻsha eʼlon ochiladi (takroran kiritilmaydi). Siz kiritgan maʼlumotlar saqlab qolingan.';

  @override
  String get storeSettlementTitle => 'Tushum';

  @override
  String get storeSettlementSubtitle => 'Oylik savdo va restoran ulushi';

  @override
  String storeSettlementCurrent(String month) {
    return '$month (hisoblanmoqda)';
  }

  @override
  String get storeSettlementCutoff => 'Oy oxirida umumiy hisob-kitob qilinadi';

  @override
  String storeSettlementEstimate(String amount) {
    return 'Kutilayotgan ulush $amount';
  }

  @override
  String storeSettlementCurrentSub(String sales, int orders, String pct) {
    return 'Savdo $sales · $orders porsiya · ulush $pct%';
  }

  @override
  String get storeSettlementStatements => 'Toʻlov tafsilotlari';

  @override
  String get storeSettlementConfirmed => 'Summa tasdiqlandi';

  @override
  String get storeSettlementPaid => 'Oʻtkazildi';

  @override
  String storeSettlementRowConfirmed(String date, int orders) {
    return '$date tasdiqlandi · $orders porsiya';
  }

  @override
  String storeSettlementRowPaid(String date, int orders) {
    return '$date oʻtkazildi · $orders porsiya';
  }

  @override
  String get storeSettlementNote =>
      'EcoMeal har oy oxirida yakuniy summani tasdiqlaydi. Pul oʻtkazilgach, toʻlov sanasi shu yerda koʻrinadi.';

  @override
  String get storeSettlementEmptyTitle => 'Hozircha toʻlov qaydlari yoʻq';

  @override
  String get storeSettlementEmptyBody =>
      'Oy oxirida EcoMeal summani tasdiqlaganidan soʻng, maʼlumotlar shu yerda koʻrinadi.';

  @override
  String get storeNoticeTitle => 'Toʻlov maʼlumotnomasi';

  @override
  String storeNoticeFor(String month) {
    return '$month uchun';
  }

  @override
  String storeNoticeAddressee(String name) {
    return 'Kimga: $name';
  }

  @override
  String storeNoticeIssued(String date) {
    return 'Berilgan: EcoMeal · $date';
  }

  @override
  String get storeNoticeOrders => 'Sotilgan porsiyalar (topshirilgan)';

  @override
  String storeNoticeOrdersValue(int orders) {
    return '$orders porsiya';
  }

  @override
  String get storeNoticeSales => 'Savdo summasi (soliq bilan)';

  @override
  String get storeNoticePayout => 'Toʻlanadigan summa';

  @override
  String get storeNoticeConfirmedAt => 'Summa tasdiqlangan sana';

  @override
  String get storeNoticePaidAt => 'Oʻtkazilgan sana';

  @override
  String get storeNoticeUnpaid => 'Hali oʻtkazilmagan (oʻtkazilgach koʻrinadi)';

  @override
  String get storeNoticeNumber => 'Maʼlumotnoma raqami';

  @override
  String get storeNoticeFootnote =>
      'Restoran ulushi faqat mijozlar qabul qilib olgan buyurtmalar boʻyicha, har bir buyurtmadagi ulush foizida hisoblanadi (pul qaytarilgan yoki muddati oʻtgan buyurtmalar hisobga olinmaydi).';

  @override
  String get storeNoticePrintOnWeb => 'Veb-saytda chop etish / PDF saqlash';

  @override
  String get storeRatingsTitle => 'Mijozlar bahosi';

  @override
  String get storeRatingsPeriod => 'Oxirgi 30 kun';

  @override
  String storeRatingsCount(int count) {
    return '$count ta baho';
  }

  @override
  String get storeRatingsRecent => 'Soʻnggi izohlar';

  @override
  String get storeRatingsAnonymous =>
      'Baholagan mijozlarning ismi koʻrsatilmaydi.';

  @override
  String get storeRatingsEmptyBody =>
      'Mijozlar taomni olib ketgach, 7 kun ichida yulduzcha va qisqa izoh bilan baholashlari mumkin.';

  @override
  String storeRatingStars(int rating) {
    return '★$rating';
  }

  @override
  String get storeInquiryTitle => 'Bogʻlanish';

  @override
  String get storeInquirySubtitle => 'EcoMeal bilan bogʻlanish';

  @override
  String get storeInquiryLabel => 'Murojaat matni';

  @override
  String get storeInquiryHint =>
      'Javob roʻyxatdan oʻtgan elektron pochtangizga yuboriladi. Murojaat holatini quyidagi roʻyxatda koʻrishingiz mumkin.';

  @override
  String get storeInquirySend => 'Yuborish';

  @override
  String get storeInquirySent => 'Yuborildi';

  @override
  String get storeInquirySendFailed =>
      'Yuborib boʻlmadi. Aloqani tekshirib, qayta urinib koʻring. Kiritilgan matn saqlab qolindi.';

  @override
  String get storeInquiryEmpty => 'Murojaat matnini kiriting';

  @override
  String get storeInquiryHistory => 'Avvalgi murojaatlar';

  @override
  String get storeInquiryStatusNew => 'Qabul qilindi';

  @override
  String get storeInquiryStatusInProgress => 'Koʻrib chiqilmoqda';

  @override
  String get storeInquiryStatusDone => 'Hal qilindi';

  @override
  String get storeInquiryStatusRejected => 'Rad etildi';

  @override
  String get storeInquiryHistoryEmpty => 'Hozircha murojaatlar yoʻq';

  @override
  String get storeAccountDeletionMessage => 'Hisobimni oʻchirishni soʻrayman.';

  @override
  String get inboxTitle => 'Xabarlar';

  @override
  String get inboxEmptyTitle => 'Hozircha xabarlar yoʻq';

  @override
  String get inboxEmptyBody =>
      'Band qilish, taom yigʻish va hisob-kitob yangiliklari shu yerda koʻrinadi hamda bildirishnoma orqali yuboriladi.';

  @override
  String get inboxOpen => 'Xabarlarni ochish';

  @override
  String inboxUnread(int count) {
    return '$count ta oʻqilmagan';
  }

  @override
  String get inboxJustNow => 'Hozirgina';

  @override
  String inboxMinutesAgo(int minutes) {
    return '$minutes daq oldin';
  }

  @override
  String inboxYesterday(String time) {
    return 'Kecha $time';
  }

  @override
  String get noticeRestaurantReviewedTitle => 'Koʻrib chiqish natijasi';

  @override
  String get noticeRestaurantReviewedBody =>
      'Koʻrib chiqish yakunlandi. Natija bilan tanishing.';

  @override
  String get noticeSettlementConfirmedTitle =>
      'Toʻlov tushumi summasi tasdiqlandi';

  @override
  String get noticeSettlementConfirmedBody =>
      'Summani “Tushum” boʻlimida tekshiring.';

  @override
  String get noticeSettlementPaidTitle => 'Pul oʻtkazmasi bajarildi';

  @override
  String get noticeSettlementPaidBody =>
      'Oʻtkazma sanasini “Tushum” boʻlimida tekshiring.';

  @override
  String get noticeBatchCollectedTitle => 'Yigʻish yakunlandi';

  @override
  String get noticeBatchCollectedBody =>
      'Haydovchi taomlarni olib ketdi. Olingan miqdorni sotuv tafsilotlarida tekshiring.';

  @override
  String get noticeBatchPhotoRemovedTitle => 'Taom surati olib tashlandi';

  @override
  String get noticeBatchPhotoRemovedBody =>
      'EcoMeal suratni olib tashladi. Sababini Asosiy ekranda koʻring.';

  @override
  String get noticeRatingReceivedTitle => 'Yangi baho qoldirildi';

  @override
  String get noticeRatingReceivedBody => 'Mijoz taomingizga baho qoldirdi.';

  @override
  String get noticeGenericTitle => 'Bildirishnoma';

  @override
  String get inboxEmptyBodyCustomer =>
      'Band qilgan taom paketingizni olib kelayotgan mashina yaqinlashganda yoki sevimli olish joyingizda yangi taomlar chiqqanda xabar beramiz.';

  @override
  String get noticeTruckApproachingTitle => 'Eco-Truck tez orada yetib keladi';

  @override
  String noticeTruckApproachingBody(String place) {
    return 'Mashina ${place}ga yaqinlashmoqda. Band qilish ekranidagi QR kodni tayyorlab qoʻying.';
  }

  @override
  String get noticeTruckApproachingPlace => 'olish joyi';

  @override
  String get noticeNewBatchTitle => 'Sevimli olish joyida yangi taomlar';

  @override
  String noticeNewBatchBody(String place) {
    return '${place}da olish mumkin boʻlgan taom paketlari chiqdi. Tugab qolmasidan oldin band qiling.';
  }

  @override
  String get noticeNewBatchPlace => 'sevimli olish joyi';

  @override
  String get noticeIssueResolvedTitle => 'Xabaringiz koʻrib chiqildi';

  @override
  String get noticeIssueResolvedBody =>
      'Tafsilotlarni band qilishlar tarixida koʻring.';

  @override
  String get noticeRefundedTitle => 'Buyurtmangiz uchun pul toʻliq qaytariladi';

  @override
  String get noticeRefundedBody =>
      'Band qilingan taom paketini tayyorlay olmaganimiz uchun uzr soʻraymiz. Toʻlangan summa toʻliq qaytariladi. Pulning kartaga tushish muddati bank yoki karta tashkilotiga bogʻliq.';

  @override
  String get storeSettingsTitle => 'Sozlamalar';

  @override
  String storeSettingsAddress(String address, String time) {
    return '$address · Yopilishi $time';
  }

  @override
  String get storeSettingsInfoNote =>
      'Restoran maʼlumotlarini oʻzgartirish uchun Bogʻlanish boʻlimi orqali murojaat qiling.';

  @override
  String get storeSettingsPush => 'Ilova bildirishnomalari';

  @override
  String get storeSettingsPushDenied =>
      'Qurilma sozlamalarida bildirishnomalar oʻchirilgan';

  @override
  String get storeSettingsRatings => 'Mijozlar bahosi';

  @override
  String get storeSettingsInquiry => 'Bogʻlanish';

  @override
  String get storeSettingsPrivacy => 'Maxfiylik siyosati';

  @override
  String get storeSettingsDeleteAccount => 'Hisobni oʻchirish soʻrovi';

  @override
  String storeSettingsVersion(String version) {
    return 'EcoMeal Store $version';
  }

  @override
  String get adminMfaTitle => 'Ikki bosqichli tasdiqlash';

  @override
  String get adminMfaLead =>
      'Autentifikator ilovasida koʻrsatilgan 6 xonali kodni kiriting.';

  @override
  String get adminMfaCodeLabel => 'Tasdiqlash kodi';

  @override
  String get adminMfaVerify => 'Tasdiqlash';

  @override
  String get adminMfaOtherAccount => 'Boshqa hisob bilan kirish';

  @override
  String get adminMfaSetupTitle => 'Ikki bosqichli tasdiqlashni sozlash';

  @override
  String get adminMfaSetupLead =>
      'Boshqaruv hisoblari uchun ikki bosqichli tasdiqlash majburiy.';

  @override
  String get adminMfaSetupStep1 =>
      'Ushbu qurilmada sozlash: quyidagi “Nusxalash” tugmasi orqali sozlash kalitini nusxalab, autentifikator ilovasidagi (masalan, Google Authenticator) “Sozlash kalitini kiritish” bandiga joylang. Boshqa qurilma boʻlsa, QR kodni skanerlash orqali ham sozlash mumkin.';

  @override
  String get adminMfaSetupKey => 'Sozlash kaliti';

  @override
  String get adminMfaCopy => 'Nusxalash';

  @override
  String get adminMfaCopied => 'Sozlash kaliti nusxalandi';

  @override
  String get adminMfaSetupStep2 =>
      'Ilovada koʻrsatilgan 6 xonali kodni kiriting.';

  @override
  String get adminMfaSetupDone => 'Sozlashni yakunlash';

  @override
  String get adminMfaInvalidCode => '6 xonali raqam kiriting';

  @override
  String get adminMfaWrongCode =>
      'Kod notoʻgʻri. Autentifikator ilovasidagi eng yangi kodni kiriting';

  @override
  String get adminMfaNetworkChanged =>
      'Tekshirish vaqtida tarmoq oʻzgarib qolgani sababli tasdiqlab boʻlmadi. Faqat Wi-Fi yoki mobil internetdan birini qoldirib, qayta urinib koʻring';

  @override
  String get adminMfaFailed => 'Tasdiqlab boʻlmadi. Biroz kutib, qayta urining';

  @override
  String get adminTabHome => 'Asosiy';

  @override
  String get adminTabOperations => 'Harakat';

  @override
  String get adminTabTasks => 'Vazifalar';

  @override
  String get adminTabSettings => 'Sozlamalar';

  @override
  String get adminDashboardTitle => 'Boshqaruv paneli';

  @override
  String get adminTonight => 'Bugun kechki qatnov';

  @override
  String get adminRunning => 'Qatnovda';

  @override
  String get adminTrucksRunning => 'Yoʻldagi mashinalar';

  @override
  String get adminStopsDone => 'Yakunlangan toʻxtash joylari';

  @override
  String get adminReserved => 'Band qilingan';

  @override
  String get adminPickedUp => 'Olingan';

  @override
  String get adminNoRouteTonight =>
      'Bugun kechqurun rejalashtirilgan qatnov yoʻq';

  @override
  String get adminNeedsAction => 'Koʻrib chiqilishi kerak';

  @override
  String get adminTaskIssues => 'Hal qilinmagan muammo xabarlari';

  @override
  String get adminTaskRestaurants => 'Tasdiqlash kutilayotgan restoranlar';

  @override
  String get adminTaskLicenses => 'Tekshirilishi kerak boʻlgan guvohnomalar';

  @override
  String get adminTaskInquiries => 'Yangi murojaatlar';

  @override
  String adminTaskLatest(String name, String time) {
    return 'Eng soʻnggi: $name · $time';
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
    return 'Hamkorlik arizasi $partner · Boshqa $other';
  }

  @override
  String get adminTaskNone => 'Yoʻq';

  @override
  String adminDateTime(String date, String time) {
    return '$date $time';
  }

  @override
  String get adminSettingsTitle => 'Sozlamalar';

  @override
  String get adminMfaOn => 'Ikki bosqichli tasdiqlash: Yoqilgan';

  @override
  String get adminNotifications => 'Bildirishnomalar';

  @override
  String get adminPrefIssues => 'Muammo xabarlari';

  @override
  String get adminPrefRestaurants => 'Restoran arizalari';

  @override
  String get adminPrefLicenses => 'Haydovchilik guvohnomalari';

  @override
  String get adminPrefInquiries => 'Murojaatlar';

  @override
  String get adminPrefSaveFailed =>
      'Bildirishnoma sozlamasini oʻzgartirib boʻlmadi';

  @override
  String get adminPushOff => 'Bu qurilmada bildirishnomalar oʻchirilgan';

  @override
  String get adminPushEnable => 'Yoqish';

  @override
  String get adminTwoFactor => 'Ikki bosqichli tasdiqlash';

  @override
  String get adminTwoFactorOn => 'Yoqilgan';

  @override
  String get adminOpenWebAdmin => 'Veb boshqaruv sahifasini ochish';

  @override
  String adminVersion(String version) {
    return 'EcoMeal Admin $version (TestFlight)';
  }

  @override
  String get noticeIssueReportedTitle => 'Yangi muammo xabari';

  @override
  String get noticeIssueReportedBody =>
      'Mijozdan buyurtma boʻyicha muammo xabari keldi.';

  @override
  String get noticeLicenseSubmittedTitle => 'Guvohnomani tekshirish soʻrovi';

  @override
  String get noticeLicenseSubmittedBody =>
      'Haydovchi haydovchilik guvohnomasini tekshirish uchun yubordi.';

  @override
  String get noticeInquiryReceivedTitle => 'Yangi murojaat';

  @override
  String get noticeInquiryReceivedBody => 'Yangi murojaat kelib tushdi.';

  @override
  String get noticeRestaurantAppliedTitle => 'Yangi restoran arizasi';

  @override
  String get noticeRestaurantAppliedBody =>
      'Restorandan hamkorlik uchun ariza kelib tushdi.';

  @override
  String get adminTasksTitle => 'Vazifalar';

  @override
  String get adminTasksSubtitle =>
      'Muammo · Koʻrib chiqish · Guvohnoma · Murojaat';

  @override
  String adminSegIssues(int count) {
    return 'Muammo $count';
  }

  @override
  String adminSegRestaurants(int count) {
    return 'Restoran $count';
  }

  @override
  String adminSegLicenses(int count) {
    return 'Guvohnoma $count';
  }

  @override
  String adminSegInquiries(int count) {
    return 'Murojaat $count';
  }

  @override
  String get adminIssueOpen => 'Hal qilinmagan';

  @override
  String get adminIssueResolved => 'Hal qilindi';

  @override
  String adminIssueLine(String message, String stop, String price) {
    return '$message ($stop · $price)';
  }

  @override
  String adminIssueMeta(String time, String name) {
    return '$time · Mijoz $name';
  }

  @override
  String adminIssueRefunded(String amount) {
    return '$amount qaytarildi · Javob berildi';
  }

  @override
  String get adminIssueNoRefund => 'Pul qaytarilmadi · Javob berildi';

  @override
  String get adminIssuesEmpty => 'Muammo xabarlari yoʻq';

  @override
  String get adminIssueOrder => 'Buyurtma';

  @override
  String adminIssueOrderValue(String price) {
    return 'Taom paketi · $price (soliq bilan)';
  }

  @override
  String get adminIssuePickup => 'Olish';

  @override
  String get adminIssueRestaurant => 'Restoran';

  @override
  String get adminIssueRefundLabel => 'Qaytariladigan summa';

  @override
  String get adminIssueFull => 'Toʻliq';

  @override
  String adminIssueRefundHint(String amount) {
    return 'Qaytarish miqdori $amount gacha. ¥0 (qaytarishsiz) ni ham tanlash mumkin.';
  }

  @override
  String get adminIssueNoRefundHint =>
      'Pul qaytarilmaydi (¥0). Mijozga faqat javob xabari yuboriladi.';

  @override
  String get adminIssueAnswerLabel => 'Mijozga javob';

  @override
  String get adminIssueSubmitRefund => 'Pulni qaytarish va hal qilish';

  @override
  String get adminIssueSubmitNoRefund => 'Hal qilingan deb belgilash';

  @override
  String get adminIssueSending => 'Yuborilmoqda…';

  @override
  String get adminIssueErrorTitle => 'Yuborib boʻlmadi';

  @override
  String get adminIssueErrorBody =>
      'Qayta urinib koʻring. Kiritilgan qaytarish summasi va javob matni saqlab qolindi. Pul hali qaytarilmadi.';

  @override
  String get adminIssueUnknownTitle => 'Jarayon natijasini tasdiqlab boʻlmadi';

  @override
  String get adminIssueUnknownBody =>
      'Aloqa uzilib qoldi. Qaytadan yuboring. Agar allaqachon bajarilgan boʻlsa, bu haqda xabar beramiz (pul ikki marta qaytarilmaydi). Kiritilgan summa va javob matni saqlab qolindi.';

  @override
  String get adminIssueRetry => 'Qayta yuborish';

  @override
  String adminIssueErrAmount(String amount) {
    return '0 dan $amount gacha boʻlgan summani kiriting';
  }

  @override
  String get adminIssueErrAnswer => 'Mijozga javob matnini kiriting';

  @override
  String get adminIssueErrAlready => 'Bu xabar allaqachon koʻrib chiqilgan';

  @override
  String get adminIssueResolvedToast => 'Hal qilingan deb belgilandi';

  @override
  String get adminRestPending => 'Kutilmoqda';

  @override
  String get adminRestRejected => 'Rad etildi';

  @override
  String get adminRestApproved => 'Tasdiqlandi';

  @override
  String get adminRestPendingBadge => 'Kutilmoqda';

  @override
  String adminRestApplied(String time) {
    return 'Ariza $time';
  }

  @override
  String get adminRestHasPl => 'PL sugʻurtasi PDF mavjud';

  @override
  String get adminRestNoPl => 'PL sugʻurtasi PDF yoʻq';

  @override
  String get adminRestEmpty => 'Mos keladigan restoran yoʻq';

  @override
  String get adminRestName => 'Restoran nomi';

  @override
  String get adminRestAddress => 'Manzil';

  @override
  String get adminRestContact => 'Aloqa';

  @override
  String get adminRestClosing => 'Yopilish vaqti';

  @override
  String get adminRestApplicant => 'Ariza beruvchi';

  @override
  String get adminRestPlDoc => 'PL sugʻurta guvohnomasi';

  @override
  String get adminRestPlOpen => 'Guvohnomani ochish (PDF)';

  @override
  String get adminRestPlFailed => 'Guvohnomani ochib boʻlmadi';

  @override
  String get adminRestReject => 'Rad etish';

  @override
  String get adminRestApprove => 'Tasdiqlash';

  @override
  String get adminRestRejectTitle => 'Rad etish sababi';

  @override
  String get adminRestRejectNote =>
      'Sabab restoranga elektron pochta va ilova orqali yuboriladi (majburiy · 500 belgigacha).';

  @override
  String get adminRestReasonPl =>
      'PL sugʻurta guvohnomasi oʻqib boʻlmaydi yoki muddati oʻtgan';

  @override
  String get adminRestReasonContact =>
      'Manzil yoki aloqa maʼlumotini tasdiqlab boʻlmadi';

  @override
  String get adminRestReasonOther => 'Boshqa';

  @override
  String get adminRestRejectSend => 'Rad etish xabarini yuborish';

  @override
  String get adminRestErrReason => 'Sababni kiriting (500 belgigacha)';

  @override
  String adminRestDecided(String name, String decision) {
    return '$name: $decision';
  }

  @override
  String get adminRestNotifyFailed =>
      'Koʻrib chiqish natijasi saqlandi, lekin bildirishnoma xatini yuborib boʻlmadi. Veb boshqaruv sahifasidan qayta yuboring.';

  @override
  String get adminRestRejectionReason => 'Rad etish sababi';

  @override
  String adminLicSubmitted(String time) {
    return 'Guvohnoma · Yuborildi $time';
  }

  @override
  String get adminLicEmpty => 'Tekshirish kutilayotgan guvohnoma yoʻq';

  @override
  String get adminLicImageFailed => 'Rasmni yuklab boʻlmadi';

  @override
  String get adminLicZoom => 'Kattalashtirish';

  @override
  String get adminLicTruck => 'Biriktirilgan mashina';

  @override
  String get adminLicNoTruck => 'Yoʻq';

  @override
  String get adminLicExpiry => 'Amal qilish muddati (rasmga qarab kiriting)';

  @override
  String get adminLicExpiryPick => 'Sanani tanlash';

  @override
  String get adminLicVerifyNote =>
      'Tasdiqlangach, haydovchini smenalarga biriktirish mumkin boʻladi.';

  @override
  String get adminLicReject => 'Qaytarish';

  @override
  String get adminLicVerify => 'Tasdiqlash';

  @override
  String get adminLicRejectTitle => 'Qaytarish sababi';

  @override
  String get adminLicErrExpiry =>
      'Amal qilish muddatini tanlang (bugun yoki keyingi sana)';

  @override
  String adminLicDone(String name) {
    return '$name guvohnomasi tasdiqlandi';
  }

  @override
  String get adminInqNew => 'Yangi';

  @override
  String get adminInqInProgress => 'Jarayonda';

  @override
  String get adminInqDone => 'Yakunlandi';

  @override
  String get adminInqTypePartner => 'Hamkorlik arizasi';

  @override
  String get adminInqTypeDriver => 'Haydovchilik arizasi';

  @override
  String get adminInqTypeContact => 'Murojaat';

  @override
  String get adminInqStatusNew => 'Yangi';

  @override
  String get adminInqStatusInProgress => 'Jarayonda';

  @override
  String get adminInqStatusDone => 'Hal qilindi';

  @override
  String get adminInqStatusRejected => 'Rad etildi';

  @override
  String get adminInqEmpty => 'Mos keladigan murojaat yoʻq';

  @override
  String get adminInqInviteOnWeb =>
      'Hisob yaratish (taklif yuborish) veb boshqaruv sahifasida amalga oshiriladi.';

  @override
  String get adminInqStatusLabel => 'Holat';

  @override
  String get adminInqNoteLabel => 'Boshqaruv izohi (ichki)';

  @override
  String get adminInqSave => 'Saqlash';

  @override
  String get adminInqSaved => 'Saqlandi';

  @override
  String get adminInqRetrySave => 'Qayta saqlash';

  @override
  String get adminInqErrorTitle => 'Saqlab boʻlmadi';

  @override
  String get adminInqErrorBody =>
      'Aloqani tekshirib, qayta urinib koʻring. Kiritilgan holat va izoh saqlab qolindi.';

  @override
  String get adminLicRetryVerify => 'Qayta tasdiqlash';

  @override
  String get adminLicErrorBody =>
      'Aloqani tekshirib, qayta urining. Kiritilgan amal qilish muddati saqlanib qolgan.';

  @override
  String get adminRestRetryApprove => 'Qayta tasdiqlash';

  @override
  String get adminRestRetryReject => 'Rad etishni qayta yuborish';

  @override
  String get adminRestErrorBody =>
      'Aloqani tekshirib, qayta urining. Koʻrib chiqish hali yakunlanmagan.';

  @override
  String get adminRestRejectErrorBody =>
      'Aloqani tekshirib, qayta urining. Rad etish hali yakunlanmagan, tanlangan sabab bilan qayta yuborish mumkin.';

  @override
  String get adminOpsTitle => 'Harakat kuzatuvi';

  @override
  String adminOpsSubtitle(String date, int count) {
    return '$date · $count ta mashina';
  }

  @override
  String adminOpsStale(String time) {
    return 'Yangilab boʻlmadi · $time holatiga';
  }

  @override
  String adminOpsUpdatedAt(String time) {
    return '$time da yangilandi (har 20 soniyada)';
  }

  @override
  String get adminOpsTrucks => 'Bugungi tungi mashinalar';

  @override
  String get adminPickIssue => 'Muammo xabarini tanlang';

  @override
  String get adminPickRestaurant => 'Restoranni tanlang';

  @override
  String get adminPickLicense => 'Haydovchilik guvohnomasini tanlang';

  @override
  String get adminPickInquiry => 'Murojaatni tanlang';

  @override
  String get adminPickDriverReport =>
      'Koʻrib chiqish uchun haydovchi xabarini tanlang';

  @override
  String get adminPickBody =>
      'Tafsilotlarni shu yerda koʻrish uchun chap tomondagi roʻyxatdan tanlang.';

  @override
  String adminOpsShowing(int count) {
    return '$count ta mashina koʻrsatilmoqda';
  }

  @override
  String get adminOpsRunning => 'Yoʻlda';

  @override
  String get adminOpsWaiting => 'Kutmoqda';

  @override
  String get adminOpsDone => 'Yakunlandi';

  @override
  String adminOpsNext(String driver, String stop) {
    return '$driver · keyingi: $stop';
  }

  @override
  String get adminGpsJustNow => 'Joylashuv: 1 daqiqadan kam oldin';

  @override
  String adminGpsMinutes(int minutes) {
    return 'Joylashuv $minutes daq oldin';
  }

  @override
  String adminGpsStale(int minutes) {
    return 'Joylashuv $minutes daq oldin · yangilanish toʻxtagan';
  }

  @override
  String get adminGpsNone => 'Joylashuv maʼlumoti hali olinmadi';

  @override
  String get adminOpsEta => 'Taxminiy kelish vaqti';

  @override
  String adminOpsReserved(int count) {
    return 'Band qilingan: $count ta';
  }

  @override
  String get adminOpsNoDriver => 'Haydovchi belgilanmagan';

  @override
  String get adminOpsMapUnavailable =>
      'Xaritani koʻrsatib boʻlmadi (xarita sozlamasi yakunlanmagan)';

  @override
  String get noticeReservationReceivedTitle => 'Yangi buyurtma tushdi';

  @override
  String noticeReservationReceivedBody(String time, int count, int total) {
    return 'Sotuv muddati $time boʻlgan taomga $count ta yangi buyurtma tushdi. Jami: $total ta.';
  }

  @override
  String get noticeReservationReceivedFallback =>
      'Buyurtmalar sonini ilovada tekshiring.';

  @override
  String get storeSettingsContract => 'Hamkorlik shartnomasi haqida';

  @override
  String get storeContractBody =>
      'Restoran uchun foydalanish shartlari (ulush foizi, toʻlov tushumi, pul oʻtkazish, oziq-ovqat bilan ishlash qoidalari va boshqalar) EcoMeal bilan tuzilgan hamkorlik shartnomasida belgilangan. Mijozlar uchun foydalanish shartlari restoranga tatbiq etilmaydi. Shartnomani tekshirish yoki oʻzgartirish boʻyicha Bogʻlanish boʻlimi orqali murojaat qiling.';

  @override
  String get storeContractInquiry => 'Bogʻlanish';

  @override
  String adminRestApproveConfirmTitle(String name) {
    return '$name tasdiqlansinmi?';
  }

  @override
  String get adminRestApproveConfirmBody =>
      'Tasdiqlangach, restoran ilova orqali ortiqcha taomlarni sotuvga qoʻya oladi va restoran masʼuliga xabarnoma yuboriladi.';

  @override
  String get adminRestMembers => 'Masʼul xodimlar';

  @override
  String get adminRestOwner => 'Rahbar';

  @override
  String get adminRestStaff => 'Xodim';

  @override
  String get adminRestNoMembers => 'Masʼul xodim roʻyxatga olinmagan';

  @override
  String get adminRestMonth => 'Bu oydagi savdo';

  @override
  String get adminRestSales => 'Savdo';

  @override
  String get adminRestPayout => 'Toʻlov ulushi';

  @override
  String get adminRestSold => 'Sotilgan porsiyalar';

  @override
  String get adminRestShare => 'Ulush foizi';

  @override
  String adminRestSharePct(String pct) {
    return '$pct%';
  }

  @override
  String get adminRestRatings => 'Mijozlar bahosi (oxirgi 30 kun)';

  @override
  String adminRestRatingsValue(String average, int count) {
    return '★$average ($count ta)';
  }

  @override
  String get adminRestNoRatings => 'Hozircha baholar yoʻq';

  @override
  String get adminRestBatches => 'Soʻnggi eʼlonlar';

  @override
  String get adminRestNoBatches => 'Hozircha eʼlonlar yoʻq';

  @override
  String adminRestBatchLine(int qty, String price) {
    return '$qty porsiya × $price';
  }

  @override
  String get adminRestBatchConfirmed => 'Tasdiqlangan';

  @override
  String get adminRestBatchEstimated => 'Taxminiy';

  @override
  String get adminRestSettlements => 'Hisob-kitob';

  @override
  String get adminRestNoSettlements => 'Tasdiqlangan hisob-kitob hali yoʻq';

  @override
  String get adminRestSettlementConfirmed => 'Tasdiqlangan';

  @override
  String adminLicVerifyConfirmTitle(String name) {
    return '${name}ning guvohnomasi tasdiqlansinmi?';
  }

  @override
  String adminLicVerifyConfirmBody(String date) {
    return 'Amal qilish muddati $date sifatida saqlanadi va haydovchini smenalarga qoʻyish mumkin boʻladi.';
  }

  @override
  String adminIssueConfirmRefundTitle(String amount) {
    return '$amount qaytarilsinmi?';
  }

  @override
  String adminIssueConfirmRefundBody(
    String order,
    String restaurant,
    String amount,
  ) {
    return '$order ($restaurant) boʻyicha mijozning toʻlov usuliga $amount qaytariladi va javob yuboriladi. Pulni qaytarishni bekor qilib boʻlmaydi.';
  }

  @override
  String get adminIssueConfirmNoRefundTitle =>
      'Pul qaytarmasdan hal qilingan deb belgilansinmi?';

  @override
  String adminIssueConfirmNoRefundBody(String order, String restaurant) {
    return '$order ($restaurant) boʻyicha mijozga faqat javob xabari yuboriladi. Keyinchalik pul qaytarib boʻlmaydi.';
  }

  @override
  String get adminMfaLostDevice =>
      'Telefonni yoʻqotgan yoki autentifikator ilovasini oʻchirib yuborgan boʻlsangiz, hisobga kira olmaysiz. Boshqa EcoMeal administratoridan ikki bosqichli tasdiqlashni tiklab berishni soʻrang.';

  @override
  String get adminIssueConfirmRefundAction => 'Pulni qaytarish';

  @override
  String get activeOrderOpen => 'Olish yoʻriqnomasini ochish';

  @override
  String get activeOrderTitle => 'Olish yoʻriqnomasi';

  @override
  String get activeOrderPlace => 'Olish joyi';

  @override
  String get activeOrderTime => 'Olish vaqti';

  @override
  String activeOrderBefore(String time, int minutes) {
    return 'Taxminiy kelish: $time · $minutes daq qoldi';
  }

  @override
  String activeOrderWindow(String end) {
    return 'Mashina hozir olish joyida toʻxtab turibdi ($end gacha)';
  }

  @override
  String get activeOrderOver =>
      'Mashina bu olish joyidan joʻnab ketdi. Agar taomni ololmagan boʻlsangiz, band qilishlar tarixidagi “Muammo haqida xabar berish” yoki Bogʻlanish boʻlimidan murojaat qiling.';

  @override
  String get activeOrderFindTitle => 'Mashinani qanday topish mumkin';

  @override
  String get activeOrderFindBody =>
      'Olish joyida toʻxtab turgan Eco-Truck (kuzovida EcoMeal logotipi bor) oldida ushbu QR kodni koʻrsating. Agar skanerlanmasa, yuqoridagi kodni haydovchiga ayting. Mashinaning joylashuvi va kelish vaqtini Asosiy ekrandagi xaritada ham koʻrish mumkin.';

  @override
  String get activeOrderPickedUp => 'Olindi';

  @override
  String get activeOrderEndedStatus => 'Bu buyurtmani olib boʻlmaydi';

  @override
  String get activeOrderEndedCancelledTitle => 'Bu buyurtma bekor qilingan';

  @override
  String get activeOrderEndedCancelledBody =>
      'Pul qaytarilganligini buyurtmalar tarixida tekshiring.';

  @override
  String get activeOrderEndedExpiredTitle => 'Bu buyurtmaning muddati oʻtgan';

  @override
  String get activeOrderEndedExpiredBody =>
      'Mashina olish joyidan joʻnab ketguncha olinmagani sababli pul qaytarilmaydi. Agar olishga ulgurmagan sababingiz boʻlsa, band qilishlar tarixidagi “Muammo haqida xabar berish” orqali murojaat qiling.';

  @override
  String get activeOrderEndedBack => 'Buyurtmalar tarixini koʻrish';

  @override
  String get pickupCompleteTitle => 'Olish yakunlandi';

  @override
  String get pickupCompleteBody =>
      'EcoMeal xizmatidan foydalanganingiz uchun rahmat.';

  @override
  String get leftoverAutoRecordNote =>
      'Xayriya qilinmagan porsiyalar oxirgi sotuv joyidan joʻnab ketilgandan 1 soat oʻtgach avtomatik tarzda “sotilmadi (hisobdan chiqarildi)” deb qayd etiladi. Xayriya qilinsa, shu vaqtgacha qayd eting.';

  @override
  String get driverReportTitle => 'Boshqaruvga xabar berish';

  @override
  String get driverReportLead =>
      'Xabar yuborilganda boshqaruv jamoasiga bildirishnoma boradi va ular tegishli mijozlar bilan bogʻlanadi. Xavfsizlikka oid shoshilinch holatda avvalo xavfsiz joyga toʻxtang.';

  @override
  String get driverReportDelay =>
      'Kechikish kutilmoqda (keyingi toʻxtash joyi)';

  @override
  String get driverReportVehicle => 'Mashina nosozligi (buzilish · YTH)';

  @override
  String get driverReportFood =>
      'Taom yoki harorat muammosi (olish rad etildi va h.k.)';

  @override
  String get driverReportOther => 'Boshqa';

  @override
  String driverReportMinutes(int minutes) {
    return '$minutes daq';
  }

  @override
  String get driverReportMinutesMax => '30+ daq';

  @override
  String get driverReportMessageHint =>
      'Holatni qisqacha yozing (ixtiyoriy; “Boshqa” uchun majburiy)';

  @override
  String get driverReportSend => 'Boshqaruvga yuborish';

  @override
  String get driverReportSent =>
      'Boshqaruv jamoasiga yuborildi. Ular bogʻlanguncha xavfsiz haydashda davom eting.';

  @override
  String get driverReportSelect => 'Xabar turini tanlang';

  @override
  String get driverReportNeedMessage =>
      '“Boshqa” tanlanganda holatni qisqacha yozing';

  @override
  String get driverReportNoRoute =>
      'Bugun tunda qatnovingiz yoʻqligi sababli yuborib boʻlmaydi';

  @override
  String get driverReportDuplicate =>
      'Shu turdagi xabarni hozirgina yubordingiz. Taxminan 1 daqiqa kutib, qayta urining';

  @override
  String get driverReportError =>
      'Yuborib boʻlmadi. Aloqa yaxshiroq joyda qayta urining';

  @override
  String get adminTaskDriverReports => 'Koʻrib chiqilmagan haydovchi xabarlari';

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
    return 'Haydovchi xabarlari $count';
  }

  @override
  String get adminDriverReportsEmpty => 'Haydovchilardan xabar yoʻq';

  @override
  String adminDriverReportMeta(String time, String driver, String stop) {
    return '$time · $driver · keyingi toʻxtash $stop';
  }

  @override
  String get adminDriverReportNoStop => 'yoʻq (marshrut yakunlangan)';

  @override
  String get adminDriverReportResolveTitle => 'Koʻrib chiqildi deb belgilash';

  @override
  String get adminDriverReportResolveNote =>
      'Bajarilgan ishni yozib qoʻying (masalan, mijozlarga xabar berildi). Mijozlarga xabar avtomatik yuborilmaydi.';

  @override
  String get adminDriverReportResolveSend => 'Koʻrib chiqildi deb belgilash';

  @override
  String get adminDriverReportDone => 'Koʻrib chiqildi deb belgilandi';

  @override
  String get adminDriverReportAlready =>
      'Boshqa operator allaqachon buni koʻrib chiqildi deb belgilagan';

  @override
  String get adminDriverReportError =>
      'Koʻrib chiqildi deb belgilab boʻlmadi. Qayta urining';

  @override
  String get noticeDriverReportedTitle => 'Haydovchidan xabar';

  @override
  String get noticeDriverReportedBody =>
      'Marshrutdagi haydovchi kechikish yoki muammo haqida xabar berdi.';

  @override
  String get driverReportShort => 'Boshqaruvga';

  @override
  String get driverProgressTitle => 'Bugungi jarayon';

  @override
  String driverProgressCount(int done, int total) {
    return '$total ta joydan $done tasi yakunlandi';
  }

  @override
  String driverProgressPickup(int done, int total) {
    return 'Yigʻish $done/$total';
  }

  @override
  String driverProgressSales(int done, int total) {
    return 'Sotuv $done/$total';
  }

  @override
  String get nextTaskLabel => 'Keyingi vazifa';

  @override
  String stepBadgePickup(int number) {
    return '$number-joy · Yigʻish';
  }

  @override
  String stepBadgeSales(int number) {
    return '$number-joy · Sotuv';
  }

  @override
  String nextTaskPickupTitle(String name) {
    return '$name dan taomlarni olish';
  }

  @override
  String nextTaskSalesTitle(String name) {
    return '$name da mijozlarga topshirish';
  }

  @override
  String get arriveByLabel => 'Kelish vaqti';

  @override
  String get timeLeftLabel => 'Qolgan vaqt';

  @override
  String get pickupAmountLabel => 'Olinadigan miqdor';

  @override
  String get handoutAmountLabel => 'Topshiriladigan miqdor';

  @override
  String approxMeals(int qty) {
    return 'Taxm. $qty porsiya';
  }

  @override
  String get nothingToPickUp => 'Bu yerda olinadigan taom qolmadi';

  @override
  String nextTaskPickupDetail(int count, String time) {
    return '$count xil taom · Restoranda sotuv tugashi: $time';
  }

  @override
  String nextTaskSalesDetail(int count) {
    return '$count ta buyurtma: QR kodni skanerlab topshiring';
  }

  @override
  String get navigateButton => 'Navigatsiya';

  @override
  String get arrivedPickupButton => 'Yetib keldim · Yigʻish';

  @override
  String get arrivedSalesButton => 'Yetib keldim · Topshirish';

  @override
  String get navigationFailed => 'Xarita ilovasini ochib boʻlmadi';

  @override
  String get allStopsDoneTitle => 'Barcha joylar yakunlandi';

  @override
  String get allStopsDoneBody =>
      'Sotilmay qolgan taomlar boʻlsa, “Yakun” boʻlimida xayriyani qayd etishingiz mumkin.';

  @override
  String get routePhasePickup => '1. Restorandan olish (Yigʻish)';

  @override
  String get routePhaseSales => '2. Mijozlarga topshirish (Sotuv)';

  @override
  String placesCount(int count) {
    return '$count ta joy';
  }

  @override
  String stopPickupPending(int qty) {
    return 'Taxminan $qty porsiya olish';
  }

  @override
  String stopPickupDone(int qty) {
    return 'Olindi · $qty porsiya';
  }

  @override
  String stopSalesLoad(int reserved, int total) {
    return 'Buyurtmalar: $reserved ta · Jami $total porsiya';
  }

  @override
  String pickupStopSubtitle(int index, int total, String time) {
    return 'Yigʻish $index/$total · Kelish: $time';
  }

  @override
  String get addressLabel => 'Manzil';

  @override
  String get copyAddressButton => 'Manzilni nusxalash';

  @override
  String get addressCopied => 'Manzil nusxalandi';

  @override
  String foodsToPickUp(int count) {
    return 'Olinadigan taomlar ($count ta)';
  }

  @override
  String get shopPlannedQty => '(restoran moʻljali)';

  @override
  String shopSellByLabel(String time) {
    return 'Restoranda sotuv tugashi: $time';
  }

  @override
  String get pickUpThisFood => 'Shu taomni olish';

  @override
  String pickedUpChip(int qty) {
    return 'Olindi · $qty porsiya';
  }

  @override
  String get pickupStepsTitle => 'Olish tartibi';

  @override
  String get pickupStep1 =>
      'Porsiyalarni sanang (restoran moʻljalidan farq qilsa ham mayli, haqiqiy sonni kiriting)';

  @override
  String get pickupStep2 =>
      'Ichki haroratni oʻlchang (sovutilgan taomlar 10°C yoki undan past)';

  @override
  String get pickupStep3 =>
      '“Olishni tasdiqlash” bosilgach, topshirish joylari va soni taqsimlanadi';

  @override
  String pickupDoneTitle(int qty) {
    return '$qty porsiya mashinaga yuklandi';
  }

  @override
  String pickupDoneSubtitle(String name, String temp) {
    return '$name · ichki harorat $temp°C';
  }

  @override
  String get securedReservations => 'Saqlab qolingan buyurtmalar';

  @override
  String get refundedReservations => 'Puli qaytarilgan buyurtmalar';

  @override
  String get dropsTitle => 'Bu taom topshiriladigan joylar';

  @override
  String dropSubtitle(String time, int count) {
    return '$time · shundan $count tasi buyurtma';
  }

  @override
  String get allPickupsDoneHint =>
      'Barcha yigʻishlar yakunlandi. Taomlar sovuq holda ekanini tekshirib, yoʻlga chiqing.';

  @override
  String get morePickupsHint => 'Keyingi restoranga yoʻl oling.';

  @override
  String get moreFoodHereHint => 'Bu restoranda hali olinadigan taom bor.';

  @override
  String get backToHome => 'Asosiy ekranga';

  @override
  String get handoutHereTitle => 'Shu joyda topshiriladiganlar';

  @override
  String totalMeals(int qty) {
    return 'Jami $qty porsiya';
  }

  @override
  String get reservedCustomers => 'Band qilgan mijozlar';

  @override
  String get walkupSellable => 'Band qilishsiz sotish mumkin';

  @override
  String get scanQrToHand => 'QR kodni skanerlab topshiring';

  @override
  String get registerOnSpot => 'Shu joyda sotuvni qayd eting';

  @override
  String get perFoodLabel => 'Taomlar boʻyicha soni';

  @override
  String batchCapacityRow(int capacity, int remaining) {
    return '$capacity porsiya (band qilishsiz $remaining porsiya qoldi)';
  }

  @override
  String get handoutStepsTitle => 'Shu joydagi tartib';

  @override
  String get handoutStep1 =>
      'Band qilgan mijozlar: olish QR kodini skanerlang (oʻqilmasa 4 belgili kodni kiriting)';

  @override
  String get handoutStep2 =>
      'Band qilmagan mijozlar: “Joyida sotuv” boʻlimida har bir porsiyani qayd eting';

  @override
  String get handoutStep3 =>
      'Tugagach: “Toʻxtash joyidan joʻnash” tugmasini bosing → keyingi joyga boring';

  @override
  String get walkupUnknownTitle => 'Sotuv qayd etilganini tasdiqlab boʻlmadi';

  @override
  String get walkupUnknownBody =>
      'Aloqa uzildi. Xuddi shu sotuvni qayta yuborish uchun “Sotuvni qayd etish” tugmasini yana bosing (ikki marta yozilmaydi). Agar allaqachon qayd etilgan boʻlsa, “Avvalgi sotuv allaqachon qayd etilgan” deb koʻrsatiladi.';

  @override
  String walkupReplayedToast(int price) {
    return 'Avvalgi sotuv allaqachon qayd etilgan (¥$price)';
  }

  @override
  String get donationUnknownTitle =>
      'Xayriya qayd etilganini tasdiqlab boʻlmadi';

  @override
  String get donationUnknownBody =>
      'Aloqa uzildi. Kiritilgan maʼlumotlar saqlanib qoldi. “Xayriyani qayd etish” tugmasini qayta bosish ikki marta yozib yubormaydi. Agar allaqachon yozilgan boʻlsa, “Bu xayriya allaqachon qayd etilgan” xabari chiqadi.';

  @override
  String donationReplayed(int remaining) {
    return 'Bu xayriya allaqachon qayd etilgan (bu taomdan $remaining porsiya qoldi)';
  }

  @override
  String donationBatchOptionEmpty(String name) {
    return '$name (qolmagan)';
  }

  @override
  String donationQtyOverRemaining(int remaining) {
    return '$remaining porsiya qolgan. $remaining yoki undan kam kiriting';
  }

  @override
  String get gpsPermissionTitle => 'Joylashuv ruxsati oʻchirilgan';

  @override
  String get gpsPermissionBody =>
      'Mijozlar va boshqaruv jamoasi mashina joylashuvini koʻra olmaydi. Sozlamalarda joylashuvga ruxsat bering (“Ilovadan foydalanganda” yetarli).';

  @override
  String get gpsServiceOffTitle => 'Qurilmada joylashuv xizmati oʻchirilgan';

  @override
  String get gpsServiceOffBody =>
      'Sozlamalar → Maxfiylik va xavfsizlik → Joylashuv xizmati boʻlimini yoqing.';

  @override
  String get gpsNotSentTitle => 'Mashina joylashuvi yuborilmayapti';

  @override
  String get gpsNotSentBody =>
      'Aloqa tiklanganda avtomatik yuboriladi. Oxirgi yuborilgan joylashuv koʻrsatilmoqda.';

  @override
  String get cameraUnavailableTitle => 'Kameradan foydalanib boʻlmaydi';

  @override
  String get cameraUnavailableBody =>
      'Sozlamalarda kameradan foydalanishga ruxsat bering. Skanerlab boʻlmasa, mijoz ekranidagi 4 belgili kod orqali ham topshirishingiz mumkin.';

  @override
  String get enterCodeManually => 'Kodni qoʻlda kiritish';

  @override
  String get routeMapOpen => 'Xaritani toʻliq ochish';

  @override
  String get routeMapTitle => 'Marshrut xaritasi';

  @override
  String routeMapSubtitle(int total, int next) {
    return '$total ta joy · $next-joyga yoʻl olinmoqda';
  }

  @override
  String routeMapAllDone(int total) {
    return '$total ta joy · barchasi yakunlandi';
  }

  @override
  String get routeMapFitAll => 'Butun marshrut';

  @override
  String get routeMapMyLocation => 'Joylashuvim';

  @override
  String get routeMapLegend =>
      'Uziq chiziq toʻxtash joylari navbatini bildiradi (haqiqiy yoʻl emas)';

  @override
  String get routeMapSelectedStop => 'Tanlangan joy';

  @override
  String get routeMapOpenStop => 'Shu joyni ochish';

  @override
  String get routeMapListHint =>
      'Barcha joylarni koʻrish uchun yuqoriga torting (1. Restorandan olish · 2. Mijozga topshirish)';

  @override
  String get routeMapRoadLoading => 'Marshrut yuklanmoqda…';

  @override
  String routeMapRoadLegend(int count, int minutes, String km) {
    return 'Yoʻl boʻylab yoʻnalish · $count ta joy qoldi, taxm. $minutes daq (${km}km)';
  }

  @override
  String get routeMapRoadFailed =>
      'Marshrutni yuklab boʻlmadi (uziq chiziq faqat navbatni koʻrsatadi)';

  @override
  String get routeMapRoadRetry => 'Qayta urinish';

  @override
  String get roadTimeLeftLabel => 'Yoʻl boʻylab';
}
