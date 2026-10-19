// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTab => 'Log in';

  @override
  String get signupTab => 'Sign up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get errorEmailRequired => 'Please enter your email address';

  @override
  String get errorPasswordRequired => 'Please enter your password';

  @override
  String get errorEmailNotConfirmed =>
      'Your email address has not been confirmed yet. Please check your inbox';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get loginButton => 'Log in';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get errorDisplayNameRequired => 'Please enter a display name';

  @override
  String get errorPasswordMin8 => 'Password must be at least 8 characters';

  @override
  String get signupButton => 'Sign up';

  @override
  String get errorEmailAlreadyRegistered =>
      'This email address is already registered';

  @override
  String get errorSignupFailed =>
      'Couldn’t sign up. Please check your details and try again';

  @override
  String get errorRateLimited =>
      'Too many attempts. Please wait a moment and try again';

  @override
  String get signupConfirmationTitle => 'Confirmation email sent';

  @override
  String signupConfirmationBody(String email) {
    return 'We sent a confirmation email to $email. Tap the link in the email to finish signing up.';
  }

  @override
  String get webOnlyAccountTitle => 'This account can\'t be used in the app';

  @override
  String get webOnlyAccountBody =>
      'Restaurant and EcoMeal operations accounts use the web admin console on a computer.';

  @override
  String get openWebAdmin => 'Open web admin';

  @override
  String get errorOpenWebAdmin => 'Couldn\'t open the web admin';

  @override
  String get loadErrorTitle => 'Couldn\'t load your account information';

  @override
  String get loadErrorBody => 'Check your connection and try again.';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'Driver';

  @override
  String get languageToggleBoth => '日本語 / English';

  @override
  String get driverLoginLead =>
      'Sign in with the driver account issued by EcoMeal.';

  @override
  String get driverAccountIssuedNote =>
      'Accounts are issued by EcoMeal. Set your password from the link in the invitation email, then sign in.';

  @override
  String get driverOnlyAppTitle => 'This app is for drivers only';

  @override
  String get driverOnlyAppBody =>
      'Customers: please use the EcoMeal app. Restaurants and EcoMeal staff: please use the web admin on a computer.';

  @override
  String get driverAccountTitle => 'This is a driver account';

  @override
  String get driverAccountBody =>
      'Drivers, please sign in with the EcoMeal Driver app. This app is for customers only.';

  @override
  String get storeAppTitle => 'EcoMeal Store';

  @override
  String get adminAppTitle => 'EcoMeal Admin';

  @override
  String get storeBadge => 'Store';

  @override
  String get storeLoginLead =>
      'Sign in with the store account issued by EcoMeal.';

  @override
  String get storeLoginNote =>
      'New stores can apply from the web dashboard (ecomeal-pi.vercel.app).';

  @override
  String get adminBadge => 'Ops';

  @override
  String get adminLoginLead =>
      'Sign in with your operations account. You will then enter a two-factor code.';

  @override
  String get storeOnlyAppTitle => 'This app is for stores';

  @override
  String get storeOnlyAppBody =>
      'Customers please use the \"EcoMeal\" app, and drivers the \"EcoMeal Driver\" app.';

  @override
  String get adminOnlyAppTitle => 'This app is for EcoMeal operations';

  @override
  String get adminOnlyAppBody =>
      'Customers please use \"EcoMeal\", restaurants \"EcoMeal Store\", and drivers \"EcoMeal Driver\".';

  @override
  String get driverSuspendedTitle => 'Your account is suspended';

  @override
  String get driverSuspendedBody =>
      'This account can\'t take shifts right now. Please contact EcoMeal for the reason and how to resume.';

  @override
  String get selectLanguage => '言語を選択 / Select language';

  @override
  String get japaneseLanguage => '日本語';

  @override
  String get englishLanguage => 'English';

  @override
  String get backToLogin => 'Back to log in';

  @override
  String get errorNetwork =>
      'Connection failed. Check your connection and try again';

  @override
  String get signOutButton => 'Log out';

  @override
  String get errorSignOutFailed => 'Couldn’t log out. Please try again';

  @override
  String get onboardingHeadline =>
      'Turn tonight\'s meal into a better tomorrow.';

  @override
  String get onboardingLead =>
      'Eco-Truck brings delicious surplus food from local restaurants to a stop near you.';

  @override
  String get onboardingImpact => 'Cut food waste, deliciously';

  @override
  String get loginLead => 'Log in with your email address and password.';

  @override
  String get signupLead =>
      'Create an account with your email address and password.';

  @override
  String get emailHint => 'example@example.com';

  @override
  String get passwordHint => 'Enter a password';

  @override
  String get passwordMin8Helper => 'Use at least 8 characters.';

  @override
  String get showPassword => 'Show';

  @override
  String get hidePassword => 'Hide';

  @override
  String get displayNameHint => 'Enter a display name';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get signupSpamFolderNote =>
      'If the email doesn\'t arrive, check your spam folder.';

  @override
  String get forgotPasswordPrompt => 'Forgot your password?';

  @override
  String get forgotPasswordAction => 'Reset it';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordRequestLead =>
      'We\'ll send a verification code to the email address you registered with.';

  @override
  String get resetPasswordSendCodeButton => 'Send code';

  @override
  String resetPasswordCodeLead(String email) {
    return 'If $email is registered, we\'ve sent a verification code to it. Enter the code from the email and your new password.';
  }

  @override
  String get verificationCodeLabel => 'Verification code';

  @override
  String get verificationCodeHint => 'Code from the email';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordHint => 'Enter a new password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get resendCodePrompt => 'Didn\'t get the code?';

  @override
  String get resendCodeAction => 'Resend';

  @override
  String get codeResent => 'We\'ve sent a new code';

  @override
  String get passwordResetDone => 'Your password has been reset';

  @override
  String get errorVerificationCodeFormat =>
      'Enter the numeric code from the email';

  @override
  String get errorVerificationCodeInvalid =>
      'The code is incorrect or has expired';

  @override
  String get errorSamePassword =>
      'Choose a password different from your current one';

  @override
  String get errorResetRequestFailed =>
      'Couldn\'t send the code. Please try again';

  @override
  String get errorResetFailed =>
      'Couldn\'t reset your password. Please try again';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoadRetry => 'Couldn’t load data. Retry';

  @override
  String get errorLoadTitle => 'Couldn’t load data.';

  @override
  String get errorLoadBody => 'Check your connection and try again.';

  @override
  String get errorLocationUnavailable => 'Couldn’t get your location';

  @override
  String get errorLocationBody =>
      'Check your device\'s location settings and network connection.';

  @override
  String get nearbyBatches => 'Nearby meals';

  @override
  String countItems(int count) {
    return '$count items';
  }

  @override
  String get liveUpdating => 'Live location';

  @override
  String get truckRunning => 'Eco-Truck on the road';

  @override
  String truckNumber(int number) {
    return 'Eco-Truck $number';
  }

  @override
  String truckRouteSummary(int count) {
    return 'Tonight\'s stops · $count';
  }

  @override
  String get truckTapHint =>
      'Tap a truck on the map or this card to see its stops and menu';

  @override
  String get stopPassed => 'Passed';

  @override
  String get nextStopBadge => 'Next stop';

  @override
  String get truckNoBatches => 'No meals on sale on this truck';

  @override
  String get closeTruckRoute => 'Close';

  @override
  String truckNextStop(String stopName) {
    return 'Next stop: $stopName';
  }

  @override
  String truckEta(String time, int minutes) {
    return 'Arrives $time · in $minutes min';
  }

  @override
  String get homeEmptyTitle => 'No sales scheduled yet today';

  @override
  String get homeEmptyBody =>
      'Link LINE to get a notification when the Eco-Truck is nearby.';

  @override
  String get setupLineNotify => 'Set up LINE notifications';

  @override
  String get homeEmptyBodyLinked =>
      'We\'ll message you on LINE from the EcoMeal official account when an Eco-Truck is nearby.';

  @override
  String get openLine => 'Open LINE';

  @override
  String get partnerStore => 'EcoMeal partner store';

  @override
  String get mysteryBag => 'Mystery bag';

  @override
  String remainingBags(int qty) {
    return '$qty left';
  }

  @override
  String get batchDetailTitle => 'Meal details';

  @override
  String get priceCalculating => 'Calculating price...';

  @override
  String get errorPriceLoad => 'Couldn’t load the price';

  @override
  String truckPeek(String stop, String time, int minutes) {
    return 'Eco-Truck running · next: $stop $time ($minutes min)';
  }

  @override
  String stopWalk(String stop, int minutes) {
    return '$stop · $minutes min walk';
  }

  @override
  String get errorSessionExpired =>
      'Your login has expired. Please log in again';

  @override
  String get errorPaymentService =>
      'We couldn\'t complete the payment because of a problem with the payment service. Please try again later';

  @override
  String get errorPriceTooLow =>
      'This meal can’t be paid by card at its current price. Please choose another meal';

  @override
  String minutesRemaining(int minutes) {
    return '$minutes min left';
  }

  @override
  String get pickupByEcoTruck => 'Pick up at the Eco-Truck';

  @override
  String get allergensHeading => 'Allergens';

  @override
  String get allergensNone => 'None';

  @override
  String get ingredientsHeading => 'Main ingredients & origin';

  @override
  String ingredientWithOrigin(String name, String origin) {
    return '$name ($origin)';
  }

  @override
  String get originUnknown => 'Origin unknown';

  @override
  String get detailNote =>
      'The contents are a surprise until pickup. Photos are for illustration. If you have allergies, please check the labels.';

  @override
  String get dailyLimitReached =>
      'You have reached today\'s reservation limit (2)';

  @override
  String get reserveButton => 'Reserve';

  @override
  String get mapSetupRequired =>
      'The map isn’t available. You can still use the list below.';

  @override
  String get openLocationSettings => 'Location settings';

  @override
  String get batchExpired =>
      'Sales for this meal have ended. Please choose another meal.';

  @override
  String get reservationCountFailed =>
      'Couldn’t check today’s reservations. Please try again.';

  @override
  String get homeTab => 'Home';

  @override
  String get reservationsTab => 'Reservations';

  @override
  String get myPageTab => 'My page';

  @override
  String get locateMe => 'My location';

  @override
  String get statusPending => 'Awaiting quantity check';

  @override
  String get statusAllocated => 'Reserved';

  @override
  String get statusPickedUp => 'Picked up';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get reservationConfirmTitle => 'Confirm reservation';

  @override
  String get paymentMethodRequired => 'Payment method (required)';

  @override
  String get paymentMethodSection => 'Payment method';

  @override
  String get addPaymentMethod => 'Add a payment method';

  @override
  String get addPaymentMethodSub => 'Credit or debit card';

  @override
  String get defaultCardLabel => 'Default card';

  @override
  String get addPaymentMethodHint =>
      'Add a payment method to confirm your reservation.';

  @override
  String get addPaymentMethodButton => 'Add a payment method';

  @override
  String payNotice(String amount) {
    return '$amount will be charged when you confirm.';
  }

  @override
  String payButton(String amount) {
    return 'Pay $amount and reserve';
  }

  @override
  String get errorPaymentMethodsLoad => 'Could not load your payment methods';

  @override
  String get errorPaymentMethodMissing =>
      'The selected card was not found. Please choose a payment method again';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentProcessingTitle => 'Processing your payment';

  @override
  String get paymentProcessingBody =>
      'Please stay on this screen until it finishes.\nDo not press the pay button again.';

  @override
  String get paymentProcessingNote =>
      'Checking the payment result.\nThis usually takes a few seconds.';

  @override
  String paymentSummaryLine(String amount, String card) {
    return '$amount (tax incl.)  ·  $card';
  }

  @override
  String get reservationCompleteTitle => 'Reservation complete';

  @override
  String get paymentDoneTitle => 'Payment complete';

  @override
  String get paymentDoneBody =>
      'Your reservation is confirmed.\nPickup details are on the Reservations screen.';

  @override
  String pickupPlaceLine(String place) {
    return 'Pickup place: $place';
  }

  @override
  String pickupTimeLine(String time) {
    return 'Pickup time: $time';
  }

  @override
  String get viewReservation => 'View reservation';

  @override
  String get paymentDeclinedTitle => 'Payment failed';

  @override
  String get paymentDeclinedBody =>
      'Your card issuer did not approve the payment.\nChoose another card or contact your card issuer.';

  @override
  String get paymentCardExpiredBody =>
      'This card has expired.\nPlease choose another card.';

  @override
  String get paymentNotCompletedNote =>
      'This payment was not completed.\nYour reservation is not confirmed yet.';

  @override
  String get payWithAnotherCard => 'Pay with another card';

  @override
  String get backToReview => 'Back to reservation';

  @override
  String get paymentUnknownTitle => 'Payment result unknown';

  @override
  String get paymentUnknownBody =>
      'The connection was lost, so we are checking your payment.\nTo avoid paying twice, do not pay again.';

  @override
  String get paymentUnknownNote =>
      'Your payment and reservation are being checked.\nCheck your connection, then get the result.';

  @override
  String get recheckPayment => 'Check payment status';

  @override
  String get viewReservationHistory => 'View reservation history';

  @override
  String get paymentNotFound =>
      'The payment was not completed. Please try again';

  @override
  String get errorRecheckFailed =>
      'Could not check. Check your connection and try again';

  @override
  String get paymentMethodsTitle => 'Payment methods';

  @override
  String get paymentMethodsSubtitle => 'Manage your cards securely';

  @override
  String get paymentMethodsEmptyTitle => 'No payment method yet';

  @override
  String get paymentMethodsEmptyBody =>
      'Add a card to pay for reservations in one tap.';

  @override
  String get addCreditCard => '+ Add a credit card';

  @override
  String get paymentProviderNote =>
      'Payment details are processed securely by a certified payment provider.';

  @override
  String get registeredCards => 'Saved cards';

  @override
  String cardExpiresOn(String expiry) {
    return 'Expires $expiry';
  }

  @override
  String get defaultBadge => 'Default';

  @override
  String get addAnotherCard => '+  Add another card';

  @override
  String get paymentSafetyTitle => 'Payment security';

  @override
  String get paymentSafetyBody =>
      'Card details are encrypted and managed securely by the payment provider.\nSet a default card to pay in one tap.';

  @override
  String get setDefaultCard => 'Set as default card';

  @override
  String get deleteCard => 'Delete this card';

  @override
  String get deleteCardTitle => 'Delete this card?';

  @override
  String deleteCardBody(String card) {
    return '$card will be deleted. You will not be able to use it for future orders.';
  }

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get cardDeleted => 'Card deleted';

  @override
  String get defaultCardChanged => 'Default card changed';

  @override
  String get addCardTitle => 'Add card';

  @override
  String get addCardSubtitle => 'Secure payment method';

  @override
  String get cardInfoSection => 'Card details';

  @override
  String get cardNumberLabel => 'Card number';

  @override
  String get cardNumberHint => '1234  5678  9012  3456';

  @override
  String get cardHolderLabel => 'Cardholder name';

  @override
  String get cardHolderHint => 'Name on card';

  @override
  String get cardExpiryLabel => 'Expiry date';

  @override
  String get cardExpiryHint => 'MM / YY';

  @override
  String get cardCvcLabel => 'Security code';

  @override
  String get cardCvcHint => 'CVC';

  @override
  String get cardTokenNote =>
      'Card numbers are not stored on EcoMeal\'s servers; the payment provider keeps them secure. Never share your security code.';

  @override
  String get cardTermsNote =>
      'By adding a card, you agree to the payment terms.';

  @override
  String get addCardButton => 'Add card';

  @override
  String get cardNumberInvalid => 'Check the card number.';

  @override
  String get cardHolderRequired => 'Enter the cardholder name.';

  @override
  String get cardExpiryInvalid => 'Check the expiry date.';

  @override
  String get cardCvcInvalid => 'Check the security code.';

  @override
  String get errorCardLimit => 'You can save up to 10 cards';

  @override
  String get errorCardAdd => 'Could not add the card. Please try again';

  @override
  String get testPaymentNote =>
      'Test mode: no real charge is made. Use the test card 4242 4242 4242 4242 (cards ending in 0002 are declined).';

  @override
  String paymentMethodRowDefault(String card) {
    return '$card · Default';
  }

  @override
  String get paymentMethodRowNone => 'Not added';

  @override
  String get freeCancelTitle =>
      'Free cancellation until 30 minutes before pickup';

  @override
  String get freeCancelBody =>
      'You can cancel for free until 30 minutes before pickup (for a 20:00 pickup, before 19:30). Cancel from your reservation history.';

  @override
  String get errorReservationFailed =>
      'Couldn’t complete the reservation. Please wait a moment and try again';

  @override
  String get errorDailyLimit =>
      'You\'ve reached today\'s limit of 2 reservations, so this one couldn\'t be made. You can see your reservations in the Reservations tab';

  @override
  String get errorSoldOutAtStop =>
      'This pickup point is sold out. Please choose another meal';

  @override
  String get errorBatchUnavailable =>
      'Reservations for this meal have closed. Please choose another meal';

  @override
  String get actionSeeReservations => 'See reservations';

  @override
  String get actionFindOtherBags => 'Find other meals';

  @override
  String get tryAgain => 'Try again';

  @override
  String get orderHistoryTitle => 'Reservation history';

  @override
  String get orderHistorySubtitle => 'Your EcoMeal record';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Upcoming';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get orderHistoryEmpty => 'No reservations yet';

  @override
  String get cancelDialogTitle => 'Cancel this reservation?';

  @override
  String get cancelDialogFree =>
      'You can cancel for free until 30 minutes before pickup. If you cancel now, you will receive a full refund.';

  @override
  String get cancelDialogNoRefund =>
      'It’s now 30 minutes or less before pickup, so you won’t get a refund if you cancel.';

  @override
  String get back => 'Back';

  @override
  String get cancelConfirmButton => 'Cancel reservation';

  @override
  String cancelledWithRefund(int amount) {
    return 'Cancelled (¥$amount refunded)';
  }

  @override
  String get cancelledNoRefund => 'Cancelled (no refund)';

  @override
  String get errorCancelFailed => 'Couldn’t cancel. Please try again';

  @override
  String reservedOrderLabel(String number) {
    return 'Reserved · Order $number';
  }

  @override
  String get reservedPaid => 'Paid';

  @override
  String orderNumber(String number) {
    return 'Order $number';
  }

  @override
  String get pendingExplanation =>
      'The driver is checking the quantity. If there are not enough meals, they are reserved at each pickup point in the order the reservations were made. Anything we can\'t reserve is refunded automatically.';

  @override
  String allocatedExplanation(String stopName) {
    return 'One bag is reserved for you at $stopName. Open the pickup guide for your QR code, time and place.';
  }

  @override
  String get freeCancelExpired =>
      'Free cancellation period has passed (no refund)';

  @override
  String get cancelButton => 'Cancel';

  @override
  String manualCodeLabel(String code) {
    return 'Manual code: $code';
  }

  @override
  String get pickupQrTitle => 'Pickup QR';

  @override
  String get pickupQrCaption =>
      'At pickup, have the driver scan this QR code or enter the code.';

  @override
  String get refundFullBadge => 'Full refund';

  @override
  String get refundFullNote =>
      'Based on the current status, you will get a full refund after cancelling.';

  @override
  String get refundNoneBadge => 'No refund';

  @override
  String get refundNoneNote =>
      'It’s now 30 minutes or less before pickup, so you won’t get a refund if you cancel.';

  @override
  String get errorBadge => 'Error';

  @override
  String get browseBatches => 'See nearby meals';

  @override
  String totalWithQuantity(int quantity) {
    return 'Total incl. tax (qty $quantity)';
  }

  @override
  String todayTime(String time) {
    return 'Today $time';
  }

  @override
  String errorDisplayNameTooLong(int max) {
    return 'Display name must be $max characters or fewer';
  }

  @override
  String errorNameKanaTooLong(int max) {
    return 'Furigana must be $max characters or fewer';
  }

  @override
  String get errorLanguageSave => 'Couldn’t save your language setting';

  @override
  String get errorLineStatusLoad => 'Couldn’t check your LINE link status';

  @override
  String get lineLinked => 'Linked with LINE';

  @override
  String get lineLinkedBody => 'You can check pickup notifications in LINE';

  @override
  String get lineLinkHint =>
      'Notifications arrive in the EcoMeal official account chat on LINE';

  @override
  String get lineOpenChat => 'Open chat in LINE';

  @override
  String get errorOpenLine => 'Couldn\'t open LINE';

  @override
  String get errorLineLinkFailed => 'Couldn’t link with LINE. Please try again';

  @override
  String get lineLinkButton => 'Link with LINE';

  @override
  String get logoutDialogTitle => 'Log out?';

  @override
  String get logoutDialogBody => 'You will return to the login screen.';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get errorSaveFailed => 'Couldn’t save. Please try again';

  @override
  String get discardDialogTitle => 'Discard changes?';

  @override
  String get discardDialogBody => 'Your edits will not be saved.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get requiredBadge => 'Required';

  @override
  String get optionalBadge => 'Optional';

  @override
  String get nameKanaLabel => 'Furigana';

  @override
  String get nameKanaHint => 'e.g. ハルカ ミカ';

  @override
  String get emailNotEditable => 'Email address cannot be changed';

  @override
  String get credentialsChangeOutOfScope =>
      'Your email address and password can’t be changed here. To reset your password, use “Forgot your password?” on the login screen.';

  @override
  String get saveButton => 'Save';

  @override
  String get languageLabel => '言語 / Language';

  @override
  String get errorBatchAlreadyConfirmed =>
      'The quantity for this food has already been confirmed';

  @override
  String get errorStopNotOnRoute =>
      'The selected stops are not on the route for this food';

  @override
  String get errorStopClosed => 'You have already departed from this stop';

  @override
  String get errorTemperatureRange =>
      'Enter a temperature between -30 and 99.9℃';

  @override
  String get errorConfirmFailed => 'Couldn’t confirm. Please try again';

  @override
  String get errorTemperatureRequired => 'Please enter the temperature';

  @override
  String get errorConfirmedQtyRequired => 'Please enter the confirmed quantity';

  @override
  String get errorNonNegativeInteger => 'Enter a whole number of 0 or more';

  @override
  String get pickupConfirmTitle => 'Confirm pickup';

  @override
  String pickupSubtitle(String stopName, int index, int total) {
    return '$stopName • Pickup $index/$total';
  }

  @override
  String estimatedMeals(int qty) {
    return 'Est. $qty meals';
  }

  @override
  String get confirmedQtyLabel => 'Confirmed quantity';

  @override
  String get mealUnit => 'meals';

  @override
  String get coreTemperatureLabel => 'Core temperature at pickup';

  @override
  String get coldChainNotice =>
      'Check that chilled items are 10℃ or below. Contact the operations team if not.';

  @override
  String get coldChainOverLimit =>
      'Above the limit (10℃ or below). This food can\'t be collected or sold.';

  @override
  String get distributionStopsLabel => 'Distribute to stops';

  @override
  String get distributionStopsHint =>
      'Select stops on the current route. Meals are distributed to the selected stops.';

  @override
  String get noDistributableStops => 'No stops to distribute to (all departed)';

  @override
  String get nextStopLabel => 'Next stop';

  @override
  String nthStopLabel(int n) {
    return 'Stop $n';
  }

  @override
  String distributionStopSubtitle(String order, String time) {
    return '$order • ETA $time';
  }

  @override
  String selectedStopsCount(int count) {
    return 'Distributed to $count selected stops.';
  }

  @override
  String confirmPickupButton(String qty) {
    return 'Confirm $qty meals picked up';
  }

  @override
  String get rejectPickupButton => 'Don\'t collect (over temperature limit)';

  @override
  String get rejectPickupDialogTitle => 'Don\'t collect this food?';

  @override
  String rejectPickupDialogBody(String celsius) {
    return 'The core temperature is $celsius℃, above the limit (10℃ or below). This food won\'t be sold; all reservations are refunded and customers are notified. The temperature record is kept.';
  }

  @override
  String get rejectPickupConfirm => 'Don\'t collect';

  @override
  String pickupRejectedToast(int refunded) {
    return 'Not collected: over the temperature limit ($refunded reservations refunded)';
  }

  @override
  String get noTruckAssigned =>
      'No truck is assigned to you. Please contact the operations team';

  @override
  String get noRouteTonight => 'No route for tonight yet';

  @override
  String get errorLoad => 'Couldn’t load data';

  @override
  String get tonightRouteTitle => 'Tonight\'s route';

  @override
  String get gpsUnavailable => 'Location unavailable';

  @override
  String get settings => 'Settings';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String stopDoneHandoff(int count) {
    return 'Done • $count handed over';
  }

  @override
  String get stopKindPickup => 'Pickup';

  @override
  String stopReservations(int count) {
    return '$count reservations';
  }

  @override
  String nextStopPrefixed(String body) {
    return 'Next stop • $body';
  }

  @override
  String get driverProfileTitle => 'Profile & settings';

  @override
  String get driverRoleChip => 'Driver';

  @override
  String get assignedTruck => 'Assigned truck';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get plateNumberLabel => 'License plate';

  @override
  String get driverTabRoute => 'Route';

  @override
  String get driverTabPickup => 'Pickup';

  @override
  String get driverTabSales => 'Sales';

  @override
  String get driverTabEnd => 'Finish';

  @override
  String get noPickupsTonight => 'No pickups scheduled tonight';

  @override
  String get gpsSending => 'Sharing location';

  @override
  String get driverAccountSubtitle => 'Driver account';

  @override
  String get errorNotHandoverable =>
      'This reservation cannot be handed over in its current state';

  @override
  String get errorPaymentNotConfirmed =>
      'Payment for this reservation is not confirmed yet. Do not hand it over — contact support';

  @override
  String get errorWalkupSoldOut => 'Walk-up stock at this stop is sold out';

  @override
  String get errorWalkupNotConfirmed =>
      'Confirm the quantity before selling without a reservation';

  @override
  String get errorBatchExpired => 'This food is past its sell-by time';

  @override
  String get errorDonationExceedsStock =>
      'Donation quantity exceeds the remaining stock';

  @override
  String get errorDonationNotConfirmed =>
      'Confirm the quantity before recording a donation';

  @override
  String get errorDonationStopsOpen =>
      'Some sales stops have not departed yet, so donations cannot be recorded';

  @override
  String get errorDonationNoteRequired => 'Please enter the recipient';

  @override
  String get errorNotAssignedDriver =>
      'You are not the assigned driver for this truck';

  @override
  String get errorGeneric => 'Something went wrong. Please try again';

  @override
  String get errorDonationQtyRequired => 'Please enter the donation quantity';

  @override
  String get errorPositiveInteger => 'Enter a whole number of 1 or more';

  @override
  String handedOverToast(String number) {
    return 'Handover recorded ($number)';
  }

  @override
  String get errorNotWaitingHere =>
      'This reservation is not waiting for handover at this stop';

  @override
  String get errorNoMatchingReservation => 'No matching reservation';

  @override
  String get duplicateCodeTitle => 'Several reservations share this code';

  @override
  String duplicateCodeOption(String number, String time) {
    return '$number (reserved $time)';
  }

  @override
  String walkupSoldToast(int price) {
    return 'Walk-up sale recorded (¥$price)';
  }

  @override
  String get departDialogTitle => 'Depart from this stop?';

  @override
  String currentStop(String name) {
    return 'Current stop: $name';
  }

  @override
  String departWarning(int count) {
    return '$count reservations are still waiting. If you depart, they will be treated as not picked up (expired) and will not be refunded.';
  }

  @override
  String get departWarningTitle => 'Some reservations are still waiting';

  @override
  String get cautionBadge => 'Caution';

  @override
  String get departConfirm => 'Depart';

  @override
  String departedWithExpired(int count) {
    return 'Departed ($count uncollected expired)';
  }

  @override
  String get departed => 'Departed';

  @override
  String get departedLabel => 'Departed';

  @override
  String minutesUntilDeparture(int minutes) {
    return '$minutes min until departure';
  }

  @override
  String reservationsCount(int count) {
    return '$count reservations';
  }

  @override
  String get reservationHandoffTab => 'Reservations';

  @override
  String get walkupTab => 'Walk-up';

  @override
  String get handedOverLabel => 'Handed over';

  @override
  String get waitingLabel => 'Waiting';

  @override
  String get departButton => 'Depart from stop';

  @override
  String get scanPickupQr => 'Scan pickup QR';

  @override
  String get scanPickupQrHint => 'Scan the customer\'s pickup QR code';

  @override
  String get manualCodeFallback => 'Can\'t scan the QR? Enter the code';

  @override
  String get batchLabel => 'Food';

  @override
  String get noWalkupBatches => 'No food can be sold at this stop';

  @override
  String mealsRemaining(int qty) {
    return '$qty meals left';
  }

  @override
  String get registerSale => 'Record sale';

  @override
  String get soldLabel => 'Sold';

  @override
  String get enterPickupCode => 'Enter pickup code';

  @override
  String get pickupCodeHint => 'e.g. A7K2';

  @override
  String get verifyCode => 'Verify';

  @override
  String get noSalesTonight => 'No sales scheduled tonight';

  @override
  String get routeEndTitle => 'Finish route';

  @override
  String get routeSummaryTitle => 'Route summary';

  @override
  String get routeEndThanks => 'Great work on tonight\'s route';

  @override
  String mealsCount(int count) {
    return '$count meals';
  }

  @override
  String get salesStopsLabel => 'Sales stops';

  @override
  String openStopsWarning(int count) {
    return '$count sales stops have not departed yet. Depart from them in the Sales tab.';
  }

  @override
  String donationBatchOption(String name, int qty, int remaining) {
    return '$name ($qty confirmed · $remaining left)';
  }

  @override
  String donationRecorded(int remaining) {
    return 'Donation recorded ($remaining meals of this food left)';
  }

  @override
  String get donationTitle => 'Record donation of unsold meals';

  @override
  String get donationLockedNotice =>
      'You can record donations after departing from every sales stop (no more sales are possible then, so the remaining stock is final).';

  @override
  String get noConfirmedBatches => 'No food with a confirmed quantity';

  @override
  String get donationQtyLabel => 'Donation quantity';

  @override
  String get donationRecipientLabel => 'Recipient';

  @override
  String get donationRecipientHint => 'e.g. XX children\'s cafeteria';

  @override
  String get donationHandedOverCheck =>
      'I confirm the meals were handed to the recipient';

  @override
  String get recordDonationButton => 'Record donation';

  @override
  String get driverLicenseTitle => 'Driver\'s license';

  @override
  String get licenseStatusNone => 'Not submitted';

  @override
  String get licenseStatusSubmitted => 'Under review';

  @override
  String get licenseStatusVerified => 'Verified';

  @override
  String get licenseStatusRejected => 'Returned';

  @override
  String get licenseNoneBody =>
      'Take a photo of your driver\'s license and submit it. You can\'t be scheduled until EcoMeal checks it.';

  @override
  String get licenseSubmittedBody =>
      'EcoMeal is checking your license. You can be scheduled once it is verified.';

  @override
  String licenseExpiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get licenseRejectedLabel => 'Message from EcoMeal';

  @override
  String get licenseUploadButton => 'Take photo and upload';

  @override
  String get licenseResubmitButton => 'Submit a renewed license';

  @override
  String get licenseResubmitNote =>
      'After you resubmit, you can\'t be scheduled for new shifts until EcoMeal checks it again.';

  @override
  String get licensePrivacyNote => 'Only EcoMeal staff can see the image.';

  @override
  String get licenseSourceCamera => 'Take a photo';

  @override
  String get licenseSourceGallery => 'Choose from photos';

  @override
  String get licenseUploadSuccess =>
      'Submitted. Please wait for EcoMeal to check it.';

  @override
  String get licenseUploadError =>
      'Couldn\'t submit. Check your connection and try again.';

  @override
  String upcomingShiftsTitle(int days) {
    return 'Upcoming shifts ($days days)';
  }

  @override
  String get upcomingShiftsEmpty =>
      'No shifts scheduled. Shifts appear here when EcoMeal assigns them.';

  @override
  String get shiftsLoadError => 'Couldn\'t load your shifts.';

  @override
  String get torchOn => 'Turn on flashlight';

  @override
  String get torchOff => 'Turn off flashlight';

  @override
  String get mealPhotoLabel => 'Photo of the meal';

  @override
  String get detailNotePhoto =>
      'This photo was added by the restaurant. Portions and presentation may differ. If you have allergies, please check the labels.';

  @override
  String get legalTermsTitle => 'Terms of Use';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalEnactedOn =>
      'Revised: October 11, 2026 (effective October 9, 2026)';

  @override
  String get legalDemoNotice =>
      'This text is a demo for a graduation project. It will be reviewed by a professional before real operation.';

  @override
  String get legalContactTitle => 'Contact';

  @override
  String get termsArticle1Title => 'Article 1 (Scope)';

  @override
  String get termsArticle1Body =>
      'These terms set out the conditions for using the EcoMeal smartphone app (the \"Service\"). By registering, you agree to these terms before using the Service.';

  @override
  String get termsArticle2Title => 'Article 2 (Your account)';

  @override
  String get termsArticle2Body =>
      'You register with an email address and password, LINE, or Apple. Keep your details accurate and do not share your password. If you register with LINE or Apple, these terms apply to your EcoMeal account in the same way. If we find misuse, we may suspend the account.';

  @override
  String get termsArticle3Title => 'Article 3 (Products)';

  @override
  String get termsArticle3Body =>
      'The food sold on the Service is surplus food cooked that day at partner restaurants (mystery bags). Contents and quantities vary by day, and prices drop as the sales deadline approaches. Check the allergens (28 items) and ingredient origins in the app before buying. Because the food is prepared in shared kitchens, trace cross-contact cannot be ruled out.';

  @override
  String get termsArticle4Title => 'Article 4 (Reservations and payment)';

  @override
  String get termsArticle4Body =>
      'You can make up to two reservations per day. Payment uses a card you have registered. The Service is in testing, so no real charges are made. Card numbers and security codes are not stored on our servers.';

  @override
  String get termsArticle5Title => 'Article 5 (Cancellations and refunds)';

  @override
  String get termsArticle5Body =>
      'Cancellations made before the point 30 minutes ahead of pickup are fully refunded; from that point on, cancellations are not refunded (for a 20:00 pickup: before 19:30 is refunded, from 19:30 it is not). Reservations that cannot be filled because of a shortage are refunded automatically. Reservations not picked up before the truck leaves the pickup point expire without a refund.';

  @override
  String get termsArticle6Title => 'Article 6 (Pickup)';

  @override
  String get termsArticle6Body =>
      'Pick up your order from the Eco-Truck parked at the reserved pickup point and time by showing the QR code or confirmation code on the reservation screen.';

  @override
  String get termsArticle7Title => 'Article 7 (Location and notifications)';

  @override
  String get termsArticle7Body =>
      'Your location is used on your device to show nearby pickup points and is not stored on our servers. Notices (truck arriving, refunds, answers to your problem reports, new food bags at favourite pickup points) come to the app if app notifications are on. If they are off and you have linked LINE, they come from the EcoMeal official account on LINE. Truck-arrival notices go to LINE if you have linked LINE.';

  @override
  String get termsArticle8Title => 'Article 8 (Profile photo)';

  @override
  String get termsArticle8Body =>
      'Your profile photo is shown only on your own My Page. You may not upload images that infringe the rights of others, such as their likeness or copyrighted works, or images that are offensive. We may remove inappropriate images.';

  @override
  String get termsArticle9Title => 'Article 9 (Prohibited conduct)';

  @override
  String get termsArticle9Body =>
      'You may not break the law, harass other users, partner restaurants or drivers, resell purchased items, or attempt unauthorized access to the Service.';

  @override
  String get termsArticle10Title =>
      'Article 10 (Changes, suspension and disclaimer)';

  @override
  String get termsArticle10Body =>
      'The Service is being developed and tested as a graduation project and may be changed or suspended without notice. We will announce changes to these terms in the app and ask for your consent again for significant changes.';

  @override
  String get privacySection1Title => '1. Information we collect';

  @override
  String get privacySection1Body =>
      'Registration details (email address, display name, furigana, profile photo), reservation and purchase history, payment methods (card brand, last four digits and expiry only), your LINE user ID if you sign in with or link LINE, the ID and email address Apple provides if you sign in with Apple (including Apple\'s private relay address), the content of your inquiries, how you use the app (records of opening food bags and the reservation screen), error information (error details, device type, app version), and a device identifier for sending notifications. We do not collect or store card numbers or security codes; our payment provider receives them directly.';

  @override
  String get privacySection2Title => '2. Location';

  @override
  String get privacySection2Body =>
      'We use your device\'s location to show nearby pickup points, but it is not sent to or stored on our servers.';

  @override
  String get privacySection3Title => '3. How we use it';

  @override
  String get privacySection3Body =>
      'To process reservations, handovers and refunds, send pickup notices, answer inquiries, and improve the Service.';

  @override
  String get privacySection4Title => '4. Sharing and outsourcing';

  @override
  String get privacySection4Body =>
      'We do not share your information with third parties without your consent except where required by law. We use Supabase (data storage), Google Maps (maps), LINE and Firebase Cloud Messaging (notifications), Stripe (payments) and Sentry (error monitoring) to process data on our behalf.';

  @override
  String get privacySection5Title => '5. Access, correction and deletion';

  @override
  String get privacySection5Body =>
      'To request access to or correction or deletion of your information, contact us through the inquiry form. You can delete your account and profile photo from My Page at any time.';

  @override
  String get termsUpdatedTitle => 'The Terms of Use have been updated';

  @override
  String get termsUpdatedBody =>
      'To keep using EcoMeal, please agree to the latest Terms of Use and Privacy Policy.';

  @override
  String get termsAgreeAndContinue => 'Agree and continue';

  @override
  String get termsDeclineAndLogout => 'Don\'t agree (log out)';

  @override
  String get errorTermsAcceptFailed =>
      'Couldn\'t record your consent. Please try again.';

  @override
  String get signupConsentBefore => 'I agree to the ';

  @override
  String get signupConsentBetween => ' and ';

  @override
  String get signupConsentAfter => '';

  @override
  String get signupConsentHint =>
      'Check the box to enable Sign up. Tap a link to read the full text.';

  @override
  String get aboutAppSection => 'About this app';

  @override
  String get appVersionLabel => 'Version';

  @override
  String get profilePhotoSet => 'Add photo';

  @override
  String get profilePhotoChange => 'Change photo';

  @override
  String get profilePhotoHint =>
      'JPEG or PNG (up to 10 MB). Cropped to a square.';

  @override
  String get profilePhotoUploading => 'Uploading photo…';

  @override
  String get errorProfilePhotoUpload =>
      'Couldn\'t upload the photo. Check your connection and try again.';

  @override
  String get errorProfilePhotoInvalid =>
      'Choose a JPEG or PNG of 10 MB or less';

  @override
  String get profilePhotoSheetTitle => 'Profile photo';

  @override
  String get profilePhotoTake => 'Take photo';

  @override
  String get profilePhotoLibrary => 'Choose from library';

  @override
  String get profilePhotoDelete => 'Delete photo';

  @override
  String get profilePhotoDeleted => 'Photo deleted';

  @override
  String get photoAccessDeniedTitle => 'Camera (photo) access is not allowed';

  @override
  String get openSettings => 'Open settings';

  @override
  String get photoAccessDeniedBody =>
      'Allow EcoMeal to access the camera and photos in your device settings.';

  @override
  String get deleteAccountLink => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountLead =>
      'After you delete your account, you can no longer log in to EcoMeal. This cannot be undone.';

  @override
  String get deleteAccountRemovedTitle => 'What will be deleted';

  @override
  String get deleteAccountRemoved1 =>
      '• Email address, display name, furigana and profile photo';

  @override
  String get deleteAccountRemoved2 =>
      '• Saved cards (brand, last four digits, expiry)';

  @override
  String get deleteAccountRemoved3 => '• LINE link and truck-arrival notices';

  @override
  String get deleteAccountKeptTitle => 'What we keep (not linked to you)';

  @override
  String get deleteAccountKeptBody =>
      'Past reservations and purchases are kept without your name or email address, to calculate sales and restaurant payouts.';

  @override
  String get deleteAccountNote =>
      'If you have reservations not yet picked up, cancel or pick them up first. You can unfriend the EcoMeal official LINE account in the LINE app.';

  @override
  String get deleteAccountOpenOrders =>
      'You have reservations not yet picked up. Cancel them in the Reservations tab or pick them up before deleting your account.';

  @override
  String get deleteAccountButton => 'Delete my account';

  @override
  String get deleteAccountDialogTitle => 'Delete your account?';

  @override
  String get deleteAccountDialogBody =>
      'This cannot be undone. Reservation and purchase records are kept in a form that does not identify you.';

  @override
  String get deleteAccountConfirm => 'Delete';

  @override
  String get accountDeleted => 'Your account has been deleted';

  @override
  String get errorDeleteAccount =>
      'Couldn\'t delete your account. Please try again.';

  @override
  String get legalTokushohoTitle =>
      'Specified Commercial Transactions Act notice';

  @override
  String taxIncludedLine(int rate) {
    return 'Incl. consumption tax ($rate%)';
  }

  @override
  String priceTaxIncluded(String price) {
    return '$price incl. tax';
  }

  @override
  String get receiptButton => 'Receipt';

  @override
  String get receiptTitle => 'Receipt';

  @override
  String receiptAddressee(String name) {
    return '$name';
  }

  @override
  String get receiptPurpose => 'For food';

  @override
  String receiptTaxableLine(int rate) {
    return 'Subject to $rate% (incl. tax)';
  }

  @override
  String get receiptUsedOn => 'Date of use';

  @override
  String get receiptOrderNumber => 'Order number';

  @override
  String get receiptPaymentMethod => 'Payment method';

  @override
  String get receiptPaymentCard => 'Credit card';

  @override
  String get receiptIssuedOn => 'Issued on';

  @override
  String get receiptIssuer => 'EcoMeal operations team (graduation project)';

  @override
  String get receiptNote =>
      '* Food items subject to the reduced tax rate (8%). EcoMeal is not a registered qualified invoice issuer, so no registration number is shown. Save or print this screen if you need it.';

  @override
  String get stripeCardIncomplete =>
      'Enter the card number, expiry date and security code.';

  @override
  String get errorCardDeclined =>
      'This card couldn\'t be added. Please try another card.';

  @override
  String get pushSectionTitle => 'App notifications';

  @override
  String get pushOffTitle => 'App notifications';

  @override
  String get pushOffBody =>
      'Get notified on this phone when the truck is arriving or a refund is made.';

  @override
  String get pushEnableButton => 'Turn on notifications';

  @override
  String get pushOnTitle => 'Notifications are on';

  @override
  String get pushOnBody =>
      'We\'ll notify you when the truck is arriving, about refunds, and about new food bags at your favorite pickup points. If you\'ve linked LINE, truck-arrival notices go to LINE.';

  @override
  String get pushDeniedTitle => 'Notifications are not allowed';

  @override
  String get pushDeniedBody =>
      'Allow EcoMeal notifications in your device settings.';

  @override
  String get errorPushEnable =>
      'Couldn\'t turn on notifications. Please try again.';

  @override
  String get reportIssueButton => 'Report a problem';

  @override
  String get reportIssueTitle => 'Report a problem';

  @override
  String get reportIssueQuestion => 'What was the problem?';

  @override
  String get issueCategoryWrongContents =>
      'Items or quantity differ from the reservation';

  @override
  String get issueCategoryQuality =>
      'Quality problem (spoiled, foreign object, etc.)';

  @override
  String get issueCategoryNotReceived => 'I couldn\'t pick it up';

  @override
  String get issueCategoryOther => 'Other';

  @override
  String get reportIssueDetailLabel => 'Details';

  @override
  String get reportIssueDetailHint => 'e.g. Part of the bread was moldy';

  @override
  String get reportIssueNote =>
      'Please report within 48 hours of pickup. We will review it and refund if needed (you will be notified and see the result in your reservation history).';

  @override
  String get reportIssueSubmit => 'Send report';

  @override
  String get reportIssueSent => 'Report sent';

  @override
  String get errorReportIssueSelect => 'Choose the type of problem';

  @override
  String get errorReportIssueDetail =>
      'Enter the details (up to 500 characters)';

  @override
  String get errorReportIssueLate =>
      'More than 48 hours have passed since pickup, so you can no longer report it in the app. Please use the contact form.';

  @override
  String get errorReportIssueDuplicate =>
      'This order has already been reported';

  @override
  String get errorReportIssue => 'Couldn\'t send the report. Please try again.';

  @override
  String get issueOpenTitle => 'Problem reported (under review)';

  @override
  String get issueOpenBody =>
      'We\'re reviewing it and will refund if needed. We\'ll let you know the result.';

  @override
  String issueResolvedRefund(int amount) {
    return 'Resolved: ¥$amount refunded';
  }

  @override
  String get issueResolvedNoRefund => 'Resolved';

  @override
  String get favoriteStopsTitle => 'Favorite pickup points';

  @override
  String get favoriteStopsIntro =>
      'We\'ll notify you in the app (or on LINE) when new food bags are available at these pickup points. You can add up to 5.';

  @override
  String get favoriteStopsHint =>
      'Tap a pickup point to see tonight’s food bags there. Tap ★ to remove. Not getting notifications? Turn on \"App notifications\" in My Page.';

  @override
  String get stopBagsHeading => 'Food bags you can pick up here tonight';

  @override
  String get stopBagsEmptyTitle => 'No food bags here yet tonight';

  @override
  String get stopBagsEmptyBody =>
      'We’ll notify you in the app (or on LINE) when new food bags appear at this pickup point.';

  @override
  String get favoriteStopsEmptyTitle => 'No favorite pickup points yet';

  @override
  String get favoriteStopsEmptyBody =>
      'Tap ☆ in the pickup section of a food bag, and we\'ll let you know when new food bags are available there.';

  @override
  String get favoriteStopsRowNone => 'None ・ Get notified about new food bags';

  @override
  String favoriteStopsRowCount(int count) {
    return '$count ・ Get notified about new food bags';
  }

  @override
  String get favoriteAddedTitle => 'Added to favorites';

  @override
  String get favoriteAddedBody =>
      'We\'ll let you know about new food bags here.';

  @override
  String get favoriteAddedPushOff =>
      'Notifications are off, so you won\'t get updates yet.';

  @override
  String get favoriteAddedPushDenied =>
      'Notifications aren\'t allowed, so you won\'t get updates.';

  @override
  String get favoriteRemovedTitle => 'Removed from favorites';

  @override
  String get favoriteRemovedBody =>
      'Notifications for this pickup point are off.';

  @override
  String get favoriteFeedbackClose => 'Close';

  @override
  String get favoriteLimitReached =>
      'You can add up to 5 favorite pickup points. Remove one in My Page first';

  @override
  String get favoriteUpdateFailed =>
      'Couldn\'t update your favorites. Please try again later';

  @override
  String get favoriteAddTooltip => 'Add this pickup point to favorites';

  @override
  String get favoriteRemoveTooltip => 'Remove from favorites';

  @override
  String get ratingPromptTitle => 'How was your food bag?';

  @override
  String get ratingPromptHint => 'Tap a star to rate (within 7 days of pickup)';

  @override
  String get ratingLabel1 => 'Poor';

  @override
  String get ratingLabel2 => 'Fair';

  @override
  String get ratingLabel3 => 'OK';

  @override
  String get ratingLabel4 => 'Good';

  @override
  String get ratingLabel5 => 'Great';

  @override
  String ratingStarSemantics(int count) {
    return '$count stars';
  }

  @override
  String ratingSheetOrder(String number, String time) {
    return 'Order #$number ・ Picked up $time';
  }

  @override
  String get ratingCommentLabel => 'A note for the restaurant (optional)';

  @override
  String get ratingCommentHint =>
      'e.g. Generous portions, still warm at pickup.';

  @override
  String get ratingPrivacyNote =>
      'Your rating reaches the restaurant without your name. Please don\'t include personal information.';

  @override
  String get ratingSubmit => 'Send rating';

  @override
  String get ratingSent => 'Thanks for your rating';

  @override
  String get ratingErrorExpired => 'You can only rate within 7 days of pickup';

  @override
  String get ratingErrorAlreadyRated => 'You\'ve already rated this order';

  @override
  String get ratingErrorFailed =>
      'Couldn\'t send your rating. Please try again';

  @override
  String get ratedLabel => 'Your rating';

  @override
  String get ratedThanks => 'Thank you';

  @override
  String ratedSemantics(int count) {
    return 'Your rating: $count stars';
  }

  @override
  String get impactTitle => 'Food you have saved';

  @override
  String get impactEmpty =>
      'Once you pick up a food bag, you\'ll see how much food you\'ve saved and the CO₂ avoided here.';

  @override
  String impactBagsValue(int count) {
    return '$count';
  }

  @override
  String get impactBagsLabel => 'Food bags picked up';

  @override
  String get impactFoodLabel => 'Food saved';

  @override
  String get impactCo2Label => 'CO₂ avoided';

  @override
  String impactApproxKg(String kg) {
    return '~$kg kg';
  }

  @override
  String impactNote(String bagKg, String factor) {
    return 'Estimates (about $bagKg kg per bag, about $factor kg of CO₂ per kg of food waste)';
  }

  @override
  String get couponsTitle => 'Coupons & referrals';

  @override
  String couponsRowSubtitle(int count) {
    return '$count coupons ・ Invite friends for ¥100';
  }

  @override
  String get couponSectionLabel => 'Coupon';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String couponAmountOff(int amount) {
    return '¥$amount off';
  }

  @override
  String couponValidUntil(String date) {
    return 'Valid until $date';
  }

  @override
  String get couponReasonWelcome => 'Referral coupon (welcome)';

  @override
  String get couponReasonReward => 'Referral coupon (thank you)';

  @override
  String get couponReasonCampaign => 'Campaign coupon';

  @override
  String get couponsUsableHeading => 'Available coupons';

  @override
  String get couponsNone => 'No coupons available';

  @override
  String get couponsAutoNote =>
      'Coupons are applied automatically on the reservation screen (one per reservation). Cancel within the free period and the coupon comes back.';

  @override
  String get errorCouponUnavailable =>
      'This coupon can\'t be used anymore. Please check and try again';

  @override
  String get receiptCouponLine => 'Coupon discount';

  @override
  String get referralMyCodeLabel => 'Your referral code';

  @override
  String get referralCopy => 'Copy';

  @override
  String get referralCopied => 'Referral code copied';

  @override
  String get referralShareLine => 'Send on LINE';

  @override
  String referralShareText(String code) {
    return 'Get leftover bento at a discount with EcoMeal. Sign up and enter referral code \"$code\" to get a ¥100 coupon.';
  }

  @override
  String get referralHowItWorks =>
      'When a friend enters this code, they get a ¥100 coupon. When they pick up their first food bag, you get a ¥100 coupon too.';

  @override
  String get referralEnterLabel => 'Enter a friend\'s referral code';

  @override
  String get referralEnterHint => 'e.g. EM3PX9';

  @override
  String get referralApply => 'Apply';

  @override
  String get referralEnterNote =>
      'Available within 14 days of sign-up, before your first pickup.';

  @override
  String referralApplied(String code) {
    return 'Referral code $code applied';
  }

  @override
  String get referralAppliedToast => 'You got a ¥100 coupon';

  @override
  String get referralErrorFormat => 'Enter a 6-character referral code';

  @override
  String get referralErrorNotFound => 'We couldn\'t find this referral code';

  @override
  String get referralErrorOwnCode => 'You can\'t use your own referral code';

  @override
  String get referralErrorNotEligible =>
      'The period for entering a referral code has ended';

  @override
  String get referralErrorFailed =>
      'Couldn\'t apply the referral code. Please try again';

  @override
  String get socialLoginDivider => 'or';

  @override
  String get lineLoginButton => 'Log in with LINE';

  @override
  String get appleLoginButton => 'Sign in with Apple';

  @override
  String get socialLoginNote =>
      'If it\'s your first time, an EcoMeal account is created with your LINE or Apple account.';

  @override
  String get lineLoginFailed =>
      'Couldn\'t log in with LINE. Please try again later';

  @override
  String get appleLoginFailed =>
      'Couldn\'t sign in with Apple. Please try again later';

  @override
  String get socialLoginNotCustomer =>
      'This account can\'t log in with LINE. Please log in with your email and password';

  @override
  String get signedInWithLine => 'Logged in with LINE';

  @override
  String get storeReviewPendingTitle => 'Under review';

  @override
  String get storeReviewPendingBody =>
      'EcoMeal is reviewing your registration. We\'ll email you the result.';

  @override
  String get storeReviewCheckButton => 'Check the review result';

  @override
  String get storeFieldName => 'Store';

  @override
  String get storeFieldAppliedAt => 'Applied on';

  @override
  String get storeFieldApplicant => 'Applicant';

  @override
  String get storeReviewRejectedTitle => 'Application not approved';

  @override
  String get storeReviewRejectedBody =>
      'To apply again with corrected details, contact us from Inquiries.';

  @override
  String get storeRejectionReasonLabel => 'Reason';

  @override
  String get storeNotRegisteredTitle => 'Your store is not registered yet';

  @override
  String get storeNotRegisteredBody =>
      'Apply to register your store from the web dashboard. After review, you can register surplus food in this app.';

  @override
  String get storeTabHome => 'Home';

  @override
  String get storeTabRegister => 'Register';

  @override
  String get storeTabSettlement => 'Payouts';

  @override
  String get storeTabSettings => 'Settings';

  @override
  String get storeRegisterCta => 'Register today\'s surplus';

  @override
  String storeRegisterDeadline(String time, String remaining) {
    return 'Aim for $time ($remaining left)';
  }

  @override
  String storeRegisterDeadlinePassed(String time) {
    return 'Past the $time target. You can still register until the truck leaves your shop';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get storePhotoRemovedTitle => 'A food photo was removed';

  @override
  String get storePhotoRemovedHint =>
      'Next time, please use a photo without your store name or logo.';

  @override
  String get storePhotoRemovedAck => 'Got it';

  @override
  String get storeTodayBatches => 'Today\'s listings';

  @override
  String get storeBatchStatusEstimated => 'Estimate';

  @override
  String get storeBatchStatusOnSale => 'On sale';

  @override
  String get storeBatchStatusEnded => 'Ended';

  @override
  String storeSellBy(String time) {
    return 'Sell by $time';
  }

  @override
  String storeCollectionPlanned(String time) {
    return 'Pickup at $time';
  }

  @override
  String storeBatchQtyConfirmed(int estimated, int confirmed) {
    return 'Est. $estimated → confirmed $confirmed';
  }

  @override
  String storeBatchQtyEstimated(int estimated) {
    return 'Est. $estimated (awaiting pickup)';
  }

  @override
  String storeBatchCounts(int reserved, int pickedUp) {
    return '$reserved reserved ・ $pickedUp picked up';
  }

  @override
  String storeBatchReserved(int reserved) {
    return '$reserved reserved';
  }

  @override
  String get storeNoBatchesTitle => 'No listings today yet';

  @override
  String get storeNoBatchesBody =>
      'If food may be left over, register it around 3–4 pm. Tonight\'s truck will come to pick it up.';

  @override
  String get storeLoadErrorTitle => 'Couldn\'t load';

  @override
  String get storeLoadErrorBody => 'Check your connection and try again.';

  @override
  String get storeReload => 'Reload';

  @override
  String get storeMonthSales => 'Sales this month';

  @override
  String storeMonthSalesSub(int orders, String from) {
    return '$orders meals (since $from)';
  }

  @override
  String get storeMonthPayout => 'Payout this month';

  @override
  String storeSharePct(String pct) {
    return 'Share $pct%';
  }

  @override
  String storeRatingsRow(String average) {
    return 'Customer rating $average';
  }

  @override
  String storeRatingsSub(int count) {
    return 'Last 30 days ・ $count ratings';
  }

  @override
  String get storeRatingsNone => 'No ratings yet';

  @override
  String get storeBatchDetailTitle => 'Listing details';

  @override
  String storeBatchPriceLine(String price, String time) {
    return '$price ・ sell by $time';
  }

  @override
  String get storeStatConfirmed => 'Confirmed';

  @override
  String get storeStatEstimated => 'Estimate';

  @override
  String get storeStatReserved => 'Reserved';

  @override
  String get storeStatPickedUp => 'Picked up';

  @override
  String get storeStatRemaining => 'Left';

  @override
  String get storeStatCollection => 'Pickup';

  @override
  String get storeProgress => 'Progress';

  @override
  String get storeStepEstimated => 'Estimate registered';

  @override
  String storeStepEstimatedDetail(int qty) {
    return 'Registered $qty';
  }

  @override
  String get storeStepCollected => 'Pickup & count';

  @override
  String storeStepCollectedPlanned(String time) {
    return 'Planned $time';
  }

  @override
  String get storeStepCollectedHint =>
      'When the driver arrives, confirm the actual count together';

  @override
  String storeStepCollectedBy(String name) {
    return 'Driver $name';
  }

  @override
  String get storeStepOnSale => 'On sale';

  @override
  String storeStepOnSaleUntil(String time) {
    return 'until $time';
  }

  @override
  String storeStepOnSaleDetail(int count) {
    return 'Sold at $count pickup points';
  }

  @override
  String get storeStepEnded => 'Ended';

  @override
  String get storeStepEndedDetail =>
      'Leftovers are recorded as donated or discarded';

  @override
  String get storeStopsRemaining => 'Left at each pickup point';

  @override
  String get storeAutoUpdate => 'Auto-updating';

  @override
  String storeStopRemaining(int remaining) {
    return '$remaining left';
  }

  @override
  String storeStopAllocated(int allocated) {
    return ' / $allocated';
  }

  @override
  String get storeEstimatedNote =>
      'If fewer items are collected than reserved, the earliest reservations are kept and the rest are refunded automatically.';

  @override
  String get storeBatchNotFound => 'This listing was not found';

  @override
  String storeTemperature(String celsius) {
    return '$celsius°C';
  }

  @override
  String get storeRegisterTitle => 'Register surplus';

  @override
  String get storeRegisterSubtitle =>
      'Estimate — the driver confirms the count at pickup';

  @override
  String get storeRequired => 'Required';

  @override
  String get storePhotoTake => 'Take a food photo';

  @override
  String get storePhotoRetake => 'Retake';

  @override
  String get storePhotoHint =>
      'Make sure no store name, logo or faces are in the photo.';

  @override
  String get storePhotoCamera => 'Take photo';

  @override
  String get storePhotoLibrary => 'Choose from library';

  @override
  String get storePhotoRemove => 'Remove photo';

  @override
  String get storeQtyLabel => 'Expected quantity';

  @override
  String get storeQtyUnit => 'meals';

  @override
  String get storeQtyDecrease => 'One meal fewer';

  @override
  String get storeQtyIncrease => 'One meal more';

  @override
  String get storePriceLabel => 'Unit price (tax incl.)';

  @override
  String get storePriceHint =>
      'As the sell-by time approaches, the app discounts automatically (30–70%).';

  @override
  String get storeSellByLabel => 'Sell by';

  @override
  String get storeSellByToday => 'Today';

  @override
  String get storeSellByTomorrow => 'Tomorrow';

  @override
  String get storeSellByChange => 'Change';

  @override
  String get storeTimeTitle => 'Sales end time';

  @override
  String get storeTimeHint => 'Type the time, or pick one below';

  @override
  String get storeTimeDayNote =>
      'Today / Tomorrow follows your choice on the form';

  @override
  String get storeTimeHour => 'Hour';

  @override
  String get storeTimeMinute => 'Min';

  @override
  String get storeTime24h => '24-hour clock (00–23 h / 00–59 min)';

  @override
  String get storeTimePresets => 'Common times';

  @override
  String get storeTimeConfirm => 'Use this time';

  @override
  String get storeTimeInvalid =>
      'Enter 00–23 for the hour and 00–59 for minutes';

  @override
  String get storeAllergenLabel => 'Allergens (28 items)';

  @override
  String get storeAllergenShowAll => 'Show all (28)';

  @override
  String get storeAllergenHint =>
      'Select all that apply. The 12 most common are shown. If none apply, check “Contains no allergens”.';

  @override
  String get storeNoAllergens => 'Contains no allergens';

  @override
  String get storeErrAllergenRequired =>
      'Choose the allergens, or check “Contains no allergens”.';

  @override
  String storeAllergenSelected(int count) {
    return '$count selected';
  }

  @override
  String get storeAllergenSheetNote =>
      'Your selection stays on the form after you close this.';

  @override
  String get storeAllergenMandatory => 'Mandatory labeling (8 items)';

  @override
  String get storeAllergenRecommended => 'Recommended labeling (20 items)';

  @override
  String get storeAllergenClear => 'Clear all';

  @override
  String storeAllergenDone(int count) {
    return 'Done ($count)';
  }

  @override
  String get storeAllergenLoadFailed => 'Couldn\'t load the allergen list.';

  @override
  String get storeIngredientsLabel => 'Main ingredients & origin';

  @override
  String get storeIngredientAdd => '+ Add ingredient';

  @override
  String get storeIngredientName => 'Ingredient';

  @override
  String get storeIngredientOrigin => 'Origin';

  @override
  String get storeIngredientOriginHint => 'e.g. Japan (Kagoshima)';

  @override
  String storeIngredientRemove(String name) {
    return 'Remove $name';
  }

  @override
  String get storeAdd => 'Add';

  @override
  String get storeCancel => 'Cancel';

  @override
  String get storeReviewButton => 'Review';

  @override
  String get storeConfirmTitle => 'Register with these details?';

  @override
  String get storeConfirmQty => 'Quantity';

  @override
  String storeConfirmQtyValue(int qty) {
    return '$qty meals';
  }

  @override
  String get storeConfirmAllergens => 'Allergens';

  @override
  String get storeConfirmIngredients => 'Ingredients';

  @override
  String get storeConfirmNone => 'None';

  @override
  String storeConfirmIngredientsMore(String first, int more) {
    return '$first and $more more';
  }

  @override
  String get storeConfirmNote =>
      'Once registered, tonight\'s truck will come to pick it up and customers can reserve.';

  @override
  String get storeConfirmPreviewTitle => 'What customers will see';

  @override
  String storeConfirmPreviewPrice(String price) {
    return 'Price now $price';
  }

  @override
  String get storeConfirmPreviewPriceNote =>
      'It drops further as the selling time ends';

  @override
  String get storeConfirmEstimate => 'Your share (estimate)';

  @override
  String storeConfirmEstimateValue(String amount) {
    return 'Up to $amount';
  }

  @override
  String storeConfirmEstimateNote(String pct) {
    return 'If all sell at today\'s price (your share $pct%). Less if prices drop or some go unsold.';
  }

  @override
  String get storeConfirmPreviewFailed =>
      'Couldn\'t calculate the price. You can still register.';

  @override
  String get storeConfirmSubmit => 'Register';

  @override
  String get storeConfirmBack => 'Go back and edit';

  @override
  String storeSellByValue(String day, String time) {
    return '$day $time';
  }

  @override
  String get storeDoneTitle => 'Registered';

  @override
  String get storeDoneBody =>
      'It has been added to tonight\'s route. We\'ll let you know when reservations come in.';

  @override
  String get storeDoneCollection => 'Pickup';

  @override
  String storeDoneCollectionValue(String time) {
    return 'around $time';
  }

  @override
  String get storeDoneRoute => 'Route';

  @override
  String storeDoneRouteMore(String names) {
    return '$names and more';
  }

  @override
  String get storeDoneViewBatch => 'View listing';

  @override
  String get storeDoneHome => 'Back to home';

  @override
  String get storeErrQty => 'Choose at least 1 meal';

  @override
  String get storeErrPrice => 'Enter a price of at least ¥200';

  @override
  String get storeErrSellByPast => 'The sell-by time must be in the future';

  @override
  String get storeErrIngredientName => 'Enter the ingredient name';

  @override
  String get storeErrPhotoUpload =>
      'Couldn\'t upload the photo. Check your connection and try again, or remove the photo. (Nothing has been registered yet.)';

  @override
  String get storeErrNotApproved =>
      'Your store is not approved yet, so you can\'t register.';

  @override
  String get storeErrPhotoInvalid =>
      'Couldn\'t attach the photo. Choose it again and retry.';

  @override
  String get storeErrNoTruck =>
      'No truck is assigned today, so you can\'t register. Please contact EcoMeal.';

  @override
  String get storeErrNoStops =>
      'No pickup points are set up, so you can\'t register. Please contact EcoMeal.';

  @override
  String get storeErrNoStopsLeft =>
      'Tonight\'s route has no pickup points left after your store, so you can\'t register.';

  @override
  String get storeErrTruckDeparted =>
      'The truck has already left your store today, so you can\'t register more.';

  @override
  String get storeErrRegisterFailed =>
      'Couldn\'t register. Check your connection and try again.';

  @override
  String get storeErrResultUnknown =>
      'We couldn\'t confirm whether it was registered. Please tap \"Register\" again. If it was already registered, that listing will be shown (it will never be registered twice). What you entered is kept.';

  @override
  String get storeSettlementTitle => 'Payouts';

  @override
  String get storeSettlementSubtitle => 'Monthly sales and payouts';

  @override
  String storeSettlementCurrent(String month) {
    return '$month (in progress)';
  }

  @override
  String get storeSettlementCutoff => 'Closes at month end';

  @override
  String storeSettlementEstimate(String amount) {
    return 'Expected payout $amount';
  }

  @override
  String storeSettlementCurrentSub(String sales, int orders, String pct) {
    return 'Sales $sales ・ $orders meals ・ share $pct%';
  }

  @override
  String get storeSettlementStatements => 'Statements';

  @override
  String get storeSettlementConfirmed => 'Confirmed';

  @override
  String get storeSettlementPaid => 'Paid';

  @override
  String storeSettlementRowConfirmed(String date, int orders) {
    return 'Confirmed $date ・ $orders meals';
  }

  @override
  String storeSettlementRowPaid(String date, int orders) {
    return 'Paid $date ・ $orders meals';
  }

  @override
  String get storeSettlementNote =>
      'EcoMeal confirms each month after it closes. Once transferred, the payment date appears here.';

  @override
  String get storeSettlementEmptyTitle => 'No statements yet';

  @override
  String get storeSettlementEmptyBody =>
      'Statements appear here after each month is closed and confirmed.';

  @override
  String get storeNoticeTitle => 'Payment statement';

  @override
  String storeNoticeFor(String month) {
    return 'For $month';
  }

  @override
  String storeNoticeAddressee(String name) {
    return 'To: $name';
  }

  @override
  String storeNoticeIssued(String date) {
    return 'Issued by EcoMeal ・ $date';
  }

  @override
  String get storeNoticeOrders => 'Meals sold (picked up)';

  @override
  String storeNoticeOrdersValue(int orders) {
    return '$orders';
  }

  @override
  String get storeNoticeSales => 'Sales (tax incl.)';

  @override
  String get storeNoticePayout => 'Payout';

  @override
  String get storeNoticeConfirmedAt => 'Confirmed on';

  @override
  String get storeNoticePaidAt => 'Paid on';

  @override
  String get storeNoticeUnpaid => 'Not paid yet (shown after transfer)';

  @override
  String get storeNoticeNumber => 'Statement no.';

  @override
  String get storeNoticeFootnote =>
      'The payout covers picked-up orders only, using each order\'s share rate (refunded or expired orders are excluded).';

  @override
  String get storeNoticePrintOnWeb => 'Print / save PDF on the web';

  @override
  String get storeRatingsTitle => 'Customer ratings';

  @override
  String get storeRatingsPeriod => 'Last 30 days';

  @override
  String storeRatingsCount(int count) {
    return '$count ratings';
  }

  @override
  String get storeRatingsRecent => 'Recent comments';

  @override
  String get storeRatingsAnonymous => 'Customer names are not shown.';

  @override
  String get storeRatingsEmptyBody =>
      'Customers can rate with stars and a comment within 7 days of pickup.';

  @override
  String storeRatingStars(int rating) {
    return '★$rating';
  }

  @override
  String get storeInquiryTitle => 'Contact';

  @override
  String get storeInquirySubtitle => 'Message EcoMeal';

  @override
  String get storeInquiryLabel => 'Message';

  @override
  String get storeInquiryHint =>
      'We reply to your registered email address. You can check the status in the list below.';

  @override
  String get storeInquirySend => 'Send';

  @override
  String get storeInquirySent => 'Sent';

  @override
  String get storeInquirySendFailed =>
      'Couldn\'t send. Check your connection and try again. Your message is kept.';

  @override
  String get storeInquiryEmpty => 'Enter a message';

  @override
  String get storeInquiryHistory => 'Previous messages';

  @override
  String get storeInquiryStatusNew => 'Received';

  @override
  String get storeInquiryStatusInProgress => 'In progress';

  @override
  String get storeInquiryStatusDone => 'Resolved';

  @override
  String get storeInquiryStatusRejected => 'Declined';

  @override
  String get storeInquiryHistoryEmpty => 'No messages yet';

  @override
  String get storeAccountDeletionMessage =>
      'I would like to delete my account.';

  @override
  String get inboxTitle => 'Notifications';

  @override
  String get inboxEmptyTitle => 'No notifications';

  @override
  String get inboxEmptyBody =>
      'Updates about pickups, payouts and more appear here and as notifications.';

  @override
  String get inboxOpen => 'Open notifications';

  @override
  String inboxUnread(int count) {
    return '$count unread';
  }

  @override
  String get inboxJustNow => 'Just now';

  @override
  String inboxMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String inboxYesterday(String time) {
    return 'Yesterday $time';
  }

  @override
  String get noticeRestaurantReviewedTitle => 'Review result';

  @override
  String get noticeRestaurantReviewedBody =>
      'Your review is complete. Please check the result.';

  @override
  String get noticeSettlementConfirmedTitle => 'Statement confirmed';

  @override
  String get noticeSettlementConfirmedBody =>
      'Check the amount on the payouts screen.';

  @override
  String get noticeSettlementPaidTitle => 'Payment transferred';

  @override
  String get noticeSettlementPaidBody =>
      'Check the transfer date on the payouts screen.';

  @override
  String get noticeBatchCollectedTitle => 'Pickup completed';

  @override
  String get noticeBatchCollectedBody =>
      'The driver collected your food. See the confirmed count in the listing details.';

  @override
  String get noticeBatchPhotoRemovedTitle => 'A food photo was removed';

  @override
  String get noticeBatchPhotoRemovedBody =>
      'EcoMeal removed a photo. See the reason on the home screen.';

  @override
  String get noticeRatingReceivedTitle => 'New rating';

  @override
  String get noticeRatingReceivedBody => 'A customer rated your food.';

  @override
  String get noticeGenericTitle => 'Notification';

  @override
  String get inboxEmptyBodyCustomer =>
      'We’ll let you know when the truck for your reservation is close, or when new food bags appear at your favorite pickup points.';

  @override
  String get noticeTruckApproachingTitle => 'Eco-Truck is arriving soon';

  @override
  String noticeTruckApproachingBody(String place) {
    return 'The truck is almost at $place. Have your reservation QR code ready.';
  }

  @override
  String get noticeTruckApproachingPlace => 'your pickup point';

  @override
  String get noticeNewBatchTitle => 'New food bags near you';

  @override
  String noticeNewBatchBody(String place) {
    return 'New food bags are available at $place. Reserve before they sell out.';
  }

  @override
  String get noticeNewBatchPlace => 'your favorite pickup point';

  @override
  String get noticeIssueResolvedTitle => 'We responded to your report';

  @override
  String get noticeIssueResolvedBody =>
      'Check your reservation history for details.';

  @override
  String get noticeRefundedTitle => 'Your reservation will be fully refunded';

  @override
  String get noticeRefundedBody =>
      'We couldn’t prepare your food bag, so we will refund the full amount you paid. When it appears depends on your card company.';

  @override
  String get storeSettingsTitle => 'Settings';

  @override
  String storeSettingsAddress(String address, String time) {
    return '$address ・ closes $time';
  }

  @override
  String get storeSettingsInfoNote =>
      'To change your shop details, contact us from Inquiries.';

  @override
  String get storeSettingsPush => 'App notifications';

  @override
  String get storeSettingsPushDenied =>
      'Notifications are off in device settings';

  @override
  String get storeSettingsRatings => 'Customer ratings';

  @override
  String get storeSettingsInquiry => 'Contact';

  @override
  String get storeSettingsPrivacy => 'Privacy policy';

  @override
  String get storeSettingsDeleteAccount => 'Request account deletion';

  @override
  String storeSettingsVersion(String version) {
    return 'EcoMeal Store $version';
  }

  @override
  String get adminMfaTitle => 'Two-factor authentication';

  @override
  String get adminMfaLead =>
      'Enter the 6-digit code shown in your authenticator app.';

  @override
  String get adminMfaCodeLabel => 'Verification code';

  @override
  String get adminMfaVerify => 'Verify';

  @override
  String get adminMfaOtherAccount => 'Sign in with another account';

  @override
  String get adminMfaSetupTitle => 'Set up two-factor authentication';

  @override
  String get adminMfaSetupLead =>
      'Two-factor authentication is required for operations accounts.';

  @override
  String get adminMfaSetupStep1 =>
      'On this device: tap \"Copy\" to copy the setup key, then paste it into \"Enter a setup key\" in your authenticator app (e.g. Google Authenticator). With another device, you can scan the QR code instead.';

  @override
  String get adminMfaSetupKey => 'Setup key';

  @override
  String get adminMfaCopy => 'Copy';

  @override
  String get adminMfaCopied => 'Setup key copied';

  @override
  String get adminMfaSetupStep2 => 'Enter the 6-digit code shown in the app.';

  @override
  String get adminMfaSetupDone => 'Finish setup';

  @override
  String get adminMfaInvalidCode => 'Enter 6 digits';

  @override
  String get adminMfaWrongCode =>
      'The code is incorrect. Enter the latest code shown in your authenticator app.';

  @override
  String get adminMfaNetworkChanged =>
      'Your network changed during the check. Use either Wi-Fi or mobile data, then try again';

  @override
  String get adminMfaFailed => 'Couldn\'t verify. Please try again later.';

  @override
  String get adminTabHome => 'Home';

  @override
  String get adminTabOperations => 'Operations';

  @override
  String get adminTabTasks => 'Tasks';

  @override
  String get adminTabSettings => 'Settings';

  @override
  String get adminDashboardTitle => 'Dashboard';

  @override
  String get adminTonight => 'Tonight\'s operations';

  @override
  String get adminRunning => 'Running';

  @override
  String get adminTrucksRunning => 'Trucks running';

  @override
  String get adminStopsDone => 'Stops done';

  @override
  String get adminReserved => 'Reserved';

  @override
  String get adminPickedUp => 'Picked up';

  @override
  String get adminNoRouteTonight => 'No operations tonight yet';

  @override
  String get adminNeedsAction => 'Needs action';

  @override
  String get adminTaskIssues => 'Open issue reports';

  @override
  String get adminTaskRestaurants => 'Stores awaiting approval';

  @override
  String get adminTaskLicenses => 'Licenses to review';

  @override
  String get adminTaskInquiries => 'New inquiries';

  @override
  String adminTaskLatest(String name, String time) {
    return 'Latest: $name ・ $time';
  }

  @override
  String adminTaskIssueLatest(String number, String category, String time) {
    return '$number \"$category\" ・ $time';
  }

  @override
  String adminTaskLicenseLatest(String name, String time) {
    return '$name ・ $time';
  }

  @override
  String adminTaskInquiryTypes(int partner, int other) {
    return 'Partner applications $partner ・ Other $other';
  }

  @override
  String get adminTaskNone => 'None';

  @override
  String adminDateTime(String date, String time) {
    return '$date $time';
  }

  @override
  String get adminSettingsTitle => 'Settings';

  @override
  String get adminMfaOn => 'Two-factor on';

  @override
  String get adminNotifications => 'Notifications';

  @override
  String get adminPrefIssues => 'Issue reports';

  @override
  String get adminPrefRestaurants => 'Store applications';

  @override
  String get adminPrefLicenses => 'License submissions';

  @override
  String get adminPrefInquiries => 'Inquiries';

  @override
  String get adminPrefSaveFailed => 'Couldn\'t change the notification setting';

  @override
  String get adminPushOff => 'Notifications are off on this device';

  @override
  String get adminPushEnable => 'Turn on';

  @override
  String get adminTwoFactor => 'Two-factor authentication';

  @override
  String get adminTwoFactorOn => 'On';

  @override
  String get adminOpenWebAdmin => 'Open the web dashboard';

  @override
  String adminVersion(String version) {
    return 'EcoMeal Admin $version (TestFlight)';
  }

  @override
  String get noticeIssueReportedTitle => 'New issue report';

  @override
  String get noticeIssueReportedBody =>
      'A customer reported a problem with an order.';

  @override
  String get noticeLicenseSubmittedTitle => 'License review requested';

  @override
  String get noticeLicenseSubmittedBody =>
      'A driver submitted a license for review.';

  @override
  String get noticeInquiryReceivedTitle => 'New inquiry';

  @override
  String get noticeInquiryReceivedBody => 'A new inquiry has arrived.';

  @override
  String get noticeRestaurantAppliedTitle => 'New store application';

  @override
  String get noticeRestaurantAppliedBody => 'A restaurant applied to join.';

  @override
  String get adminTasksTitle => 'Tasks';

  @override
  String get adminTasksSubtitle => 'Issues, reviews, licenses, inquiries';

  @override
  String adminSegIssues(int count) {
    return 'Issues $count';
  }

  @override
  String adminSegRestaurants(int count) {
    return 'Reviews $count';
  }

  @override
  String adminSegLicenses(int count) {
    return 'Licenses $count';
  }

  @override
  String adminSegInquiries(int count) {
    return 'Inquiries $count';
  }

  @override
  String get adminIssueOpen => 'Open';

  @override
  String get adminIssueResolved => 'Resolved';

  @override
  String adminIssueLine(String message, String stop, String price) {
    return '$message ($stop ・ $price)';
  }

  @override
  String adminIssueMeta(String time, String name) {
    return '$time ・ customer $name';
  }

  @override
  String adminIssueRefunded(String amount) {
    return 'Refunded $amount ・ answered';
  }

  @override
  String get adminIssueNoRefund => 'No refund ・ answered';

  @override
  String get adminIssuesEmpty => 'No issue reports';

  @override
  String get adminIssueOrder => 'Order';

  @override
  String adminIssueOrderValue(String price) {
    return 'Mystery bag ・ $price (tax incl.)';
  }

  @override
  String get adminIssuePickup => 'Pickup';

  @override
  String get adminIssueRestaurant => 'Store';

  @override
  String get adminIssueRefundLabel => 'Refund';

  @override
  String get adminIssueFull => 'Full';

  @override
  String adminIssueRefundHint(String amount) {
    return 'Up to $amount. You can also choose ¥0 (no refund).';
  }

  @override
  String get adminIssueNoRefundHint =>
      'No refund (¥0). The customer only receives your answer.';

  @override
  String get adminIssueAnswerLabel => 'Answer to the customer';

  @override
  String get adminIssueSubmitRefund => 'Refund and resolve';

  @override
  String get adminIssueSubmitNoRefund => 'Resolve';

  @override
  String get adminIssueSending => 'Sending…';

  @override
  String get adminIssueErrorTitle => 'Couldn\'t send';

  @override
  String get adminIssueErrorBody =>
      'Please try again. Your refund amount and answer are kept. No refund has been made yet.';

  @override
  String get adminIssueUnknownTitle => 'Couldn\'t confirm the result';

  @override
  String get adminIssueUnknownBody =>
      'The connection was lost. Please send again. If it was already processed, we\'ll let you know (it will never be refunded twice). Your refund amount and answer are kept.';

  @override
  String get adminIssueRetry => 'Send again';

  @override
  String adminIssueErrAmount(String amount) {
    return 'Enter an amount from 0 to $amount';
  }

  @override
  String get adminIssueErrAnswer => 'Enter an answer to the customer';

  @override
  String get adminIssueErrAlready => 'This report has already been resolved';

  @override
  String get adminIssueResolvedToast => 'Marked as resolved';

  @override
  String get adminRestTitle => 'Store reviews';

  @override
  String get adminRestPending => 'Pending';

  @override
  String get adminRestRejected => 'Rejected';

  @override
  String get adminRestApproved => 'Approved';

  @override
  String get adminRestPendingBadge => 'Pending';

  @override
  String adminRestApplied(String time) {
    return 'Applied $time';
  }

  @override
  String get adminRestHasPl => 'PL insurance PDF attached';

  @override
  String get adminRestNoPl => 'No PL insurance PDF';

  @override
  String get adminRestEmpty => 'No stores here';

  @override
  String get adminRestName => 'Store';

  @override
  String get adminRestAddress => 'Address';

  @override
  String get adminRestContact => 'Contact';

  @override
  String get adminRestClosing => 'Closes at';

  @override
  String get adminRestApplicant => 'Applicant';

  @override
  String get adminRestPlDoc => 'PL insurance certificate';

  @override
  String get adminRestPlOpen => 'Open certificate (PDF)';

  @override
  String get adminRestPlFailed => 'Couldn\'t open the certificate';

  @override
  String get adminRestReject => 'Reject';

  @override
  String get adminRestApprove => 'Approve';

  @override
  String get adminRestRejectTitle => 'Reason for rejection';

  @override
  String get adminRestRejectNote =>
      'The reason is sent to the store by email and app (required, up to 500 characters).';

  @override
  String get adminRestReasonPl => 'PL certificate unreadable or expired';

  @override
  String get adminRestReasonContact => 'Address or contact can\'t be verified';

  @override
  String get adminRestReasonOther => 'Other';

  @override
  String get adminRestRejectSend => 'Send rejection';

  @override
  String get adminRestErrReason => 'Enter a reason (up to 500 characters)';

  @override
  String adminRestDecided(String name, String decision) {
    return '$name: $decision';
  }

  @override
  String get adminRestNotifyFailed =>
      'The review is saved, but the email couldn\'t be sent. Resend it from the web dashboard.';

  @override
  String get adminRestRejectionReason => 'Reason';

  @override
  String get adminLicTitle => 'License review';

  @override
  String adminLicSubmitted(String time) {
    return 'License ・ submitted $time';
  }

  @override
  String get adminLicEmpty => 'No licenses waiting for review';

  @override
  String get adminLicImageFailed => 'Couldn\'t load the image';

  @override
  String get adminLicZoom => 'Zoom';

  @override
  String get adminLicTruck => 'Assigned truck';

  @override
  String get adminLicNoTruck => 'None';

  @override
  String get adminLicExpiry => 'Expiry date (from the image)';

  @override
  String get adminLicExpiryPick => 'Choose a date';

  @override
  String get adminLicVerifyNote =>
      'Once verified, the driver can be assigned to shifts.';

  @override
  String get adminLicReject => 'Return';

  @override
  String get adminLicVerify => 'Verify';

  @override
  String get adminLicRejectTitle => 'Reason for returning';

  @override
  String get adminLicErrExpiry => 'Choose an expiry date (today or later)';

  @override
  String adminLicDone(String name) {
    return 'Updated $name\'s license';
  }

  @override
  String get adminInqTitle => 'Inquiries';

  @override
  String get adminInqNew => 'New';

  @override
  String get adminInqInProgress => 'In progress';

  @override
  String get adminInqDone => 'Done';

  @override
  String get adminInqTypePartner => 'Partner application';

  @override
  String get adminInqTypeDriver => 'Driver application';

  @override
  String get adminInqTypeContact => 'Inquiry';

  @override
  String get adminInqStatusNew => 'New';

  @override
  String get adminInqStatusInProgress => 'In progress';

  @override
  String get adminInqStatusDone => 'Done';

  @override
  String get adminInqStatusRejected => 'Declined';

  @override
  String get adminInqEmpty => 'No inquiries here';

  @override
  String get adminInqInviteOnWeb =>
      'Accounts (invitations) are issued on the web dashboard.';

  @override
  String get adminInqStatusLabel => 'Status';

  @override
  String get adminInqNoteLabel => 'Internal note';

  @override
  String get adminInqSave => 'Save';

  @override
  String get adminInqSaved => 'Saved';

  @override
  String get adminInqRetrySave => 'Save again';

  @override
  String get adminInqErrorTitle => 'Couldn’t save';

  @override
  String get adminInqErrorBody =>
      'Check your connection and try again. Your status and notes are kept.';

  @override
  String get adminLicRetryVerify => 'Mark as verified again';

  @override
  String get adminLicErrorBody =>
      'Check your connection and try again. The expiry date you entered is kept.';

  @override
  String get adminRestRetryApprove => 'Approve again';

  @override
  String get adminRestRetryReject => 'Send rejection again';

  @override
  String get adminRestErrorBody =>
      'Check your connection and try again. The review hasn’t been finalised.';

  @override
  String get adminRestRejectErrorBody =>
      'Check your connection and try again. The rejection hasn’t been finalised; it can be resent with the same reason.';

  @override
  String get adminSaveFailed =>
      'Couldn\'t save. Check your connection and try again.';

  @override
  String get adminOpsTitle => 'Operations monitor';

  @override
  String adminOpsSubtitle(String date, int count) {
    return '$date ・ $count trucks';
  }

  @override
  String adminOpsStale(String time) {
    return 'Can’t refresh · as of $time';
  }

  @override
  String adminOpsUpdatedAt(String time) {
    return 'Updated $time (every 20 s)';
  }

  @override
  String get adminOpsTrucks => 'Tonight’s trucks';

  @override
  String get adminPickIssue => 'Select an issue report';

  @override
  String get adminPickRestaurant => 'Select a restaurant';

  @override
  String get adminPickLicense => 'Select a driver’s licence';

  @override
  String get adminPickInquiry => 'Select an inquiry';

  @override
  String get adminPickDriverReport => 'Select a driver report to respond';

  @override
  String get adminPickBody =>
      'Choose an item from the list on the left to see its details here.';

  @override
  String adminOpsShowing(int count) {
    return 'Showing $count trucks';
  }

  @override
  String get adminOpsRunning => 'Running';

  @override
  String get adminOpsWaiting => 'Waiting';

  @override
  String get adminOpsDone => 'Done';

  @override
  String adminOpsNext(String driver, String stop) {
    return '$driver ・ next: $stop';
  }

  @override
  String get adminOpsEta => 'ETA';

  @override
  String adminOpsReserved(int count) {
    return '$count reserved';
  }

  @override
  String get adminOpsNoDriver => 'No driver';

  @override
  String get adminOpsMapUnavailable =>
      'Map unavailable (map setup is not finished)';

  @override
  String get noticeReservationReceivedTitle => 'New reservations';

  @override
  String noticeReservationReceivedBody(String time, int count, int total) {
    return '$count new for your listing selling until $time ($total in total).';
  }

  @override
  String get noticeReservationReceivedFallback => 'Check the count in the app.';

  @override
  String get storeSettingsContract => 'About the partnership agreement';

  @override
  String get storeContractBody =>
      'Your terms as a partner store (revenue share, settlement, transfers, food handling, etc.) are set out in the partnership agreement you signed with EcoMeal. The customer terms of use do not apply to stores. To check or change your agreement, contact us.';

  @override
  String get storeContractInquiry => 'Contact us';

  @override
  String adminRestApproveConfirmTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String get adminRestApproveConfirmBody =>
      'Once approved, the store can register surplus food in the store app, and the store contact receives a notification email.';

  @override
  String get adminRestMembers => 'Store staff';

  @override
  String get adminRestOwner => 'Owner';

  @override
  String get adminRestStaff => 'Staff';

  @override
  String get adminRestNoMembers => 'No staff registered';

  @override
  String get adminRestMonth => 'Sales this month';

  @override
  String get adminRestSales => 'Sales';

  @override
  String get adminRestPayout => 'Payout';

  @override
  String get adminRestSold => 'Meals sold';

  @override
  String get adminRestShare => 'Payout rate';

  @override
  String adminRestSharePct(String pct) {
    return '$pct%';
  }

  @override
  String get adminRestRatings => 'Customer ratings (last 30 days)';

  @override
  String adminRestRatingsValue(String average, int count) {
    return '★$average ($count)';
  }

  @override
  String get adminRestNoRatings => 'No ratings yet';

  @override
  String get adminRestBatches => 'Recent listings';

  @override
  String get adminRestNoBatches => 'No listings yet';

  @override
  String adminRestBatchLine(int qty, String price) {
    return '$qty meals × $price';
  }

  @override
  String get adminRestBatchConfirmed => 'Confirmed';

  @override
  String get adminRestBatchEstimated => 'Estimate';

  @override
  String get adminRestSettlements => 'Settlements';

  @override
  String get adminRestNoSettlements => 'No settlements confirmed yet';

  @override
  String get adminRestSettlementConfirmed => 'Confirmed';

  @override
  String adminLicVerifyConfirmTitle(String name) {
    return 'Mark $name’s licence as verified?';
  }

  @override
  String adminLicVerifyConfirmBody(String date) {
    return 'The expiry date $date is saved and this driver can be assigned to shifts.';
  }

  @override
  String adminIssueConfirmRefundTitle(String amount) {
    return 'Refund $amount?';
  }

  @override
  String adminIssueConfirmRefundBody(
    String order,
    String restaurant,
    String amount,
  ) {
    return '$amount is refunded to the customer’s payment method for $order ($restaurant) and your answer is sent. Refunds cannot be undone.';
  }

  @override
  String get adminIssueConfirmNoRefundTitle => 'Resolve without a refund?';

  @override
  String adminIssueConfirmNoRefundBody(String order, String restaurant) {
    return 'Only your answer is sent to the customer for $order ($restaurant). You cannot refund later.';
  }

  @override
  String get adminMfaLostDevice =>
      'If you lost your phone or deleted your authenticator app, you cannot sign in. Ask another EcoMeal administrator to reset your two-factor authentication.';

  @override
  String get adminIssueConfirmRefundAction => 'Refund';

  @override
  String get activeOrderOpen => 'Open pickup guide';

  @override
  String get activeOrderTitle => 'Pickup guide';

  @override
  String get activeOrderPlace => 'Pickup point';

  @override
  String get activeOrderTime => 'Pickup time';

  @override
  String activeOrderBefore(String time, int minutes) {
    return 'Arrives at $time · in $minutes min';
  }

  @override
  String activeOrderWindow(String end) {
    return 'The truck is parked at the pickup point now (until $end)';
  }

  @override
  String get activeOrderOver =>
      'The truck has left this pickup point. If you could not collect your meal, use Report a problem in your reservations or contact us.';

  @override
  String get activeOrderFindTitle => 'How to find the truck';

  @override
  String get activeOrderFindBody =>
      'Show this QR code at the Eco-Truck parked at the pickup point (EcoMeal logo on the side). If it cannot be scanned, tell the driver the code above. You can also see where the truck is and when it arrives on the Home map.';

  @override
  String get activeOrderPickedUp => 'Picked up';

  @override
  String get activeOrderEndedStatus => 'This reservation can\'t be picked up';

  @override
  String get activeOrderEndedCancelledTitle => 'This reservation was cancelled';

  @override
  String get activeOrderEndedCancelledBody =>
      'Check your reservation history to see whether it was refunded.';

  @override
  String get activeOrderEndedExpiredTitle => 'This reservation has expired';

  @override
  String get activeOrderEndedExpiredBody =>
      'It wasn\'t picked up before the truck left the pickup point, so it isn\'t refunded. If something kept you from picking it up, use \"Report a problem\" in your reservation history.';

  @override
  String get activeOrderEndedBack => 'See reservation history';

  @override
  String get pickupCompleteTitle => 'Pickup complete';

  @override
  String get pickupCompleteBody => 'Thank you for using EcoMeal.';

  @override
  String get leftoverAutoRecordNote =>
      'Meals you do not donate are recorded automatically as unsold (discarded) one hour after you leave the last sales stop. Record any donation before then.';

  @override
  String get driverReportTitle => 'Contact operations';

  @override
  String get driverReportLead =>
      'The operations team is notified and contacts customers whose reservations are affected. For urgent safety problems, stop somewhere safe first.';

  @override
  String get driverReportDelay => 'Running late (next stop)';

  @override
  String get driverReportVehicle => 'Vehicle trouble (breakdown or accident)';

  @override
  String get driverReportFood =>
      'Food or temperature problem (e.g. refused a pickup)';

  @override
  String get driverReportOther => 'Other';

  @override
  String driverReportMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get driverReportMinutesMax => '30+ min';

  @override
  String get driverReportMessageHint =>
      'Describe the situation (optional; required for Other)';

  @override
  String get driverReportSend => 'Send to operations';

  @override
  String get driverReportSent =>
      'Sent to operations. Keep driving safely while you wait for them to contact you.';

  @override
  String get driverReportSelect => 'Choose what happened';

  @override
  String get driverReportNeedMessage =>
      'For Other, please describe the situation';

  @override
  String get driverReportNoRoute =>
      'You can\'t send this because you have no route tonight';

  @override
  String get driverReportDuplicate =>
      'You just sent this kind of message. Wait about a minute and try again';

  @override
  String get driverReportError =>
      'Couldn\'t send. Try again somewhere with a better signal';

  @override
  String get adminTaskDriverReports => 'Open driver messages';

  @override
  String adminTaskDriverReportLatest(
    String plate,
    String category,
    String time,
  ) {
    return '$plate \"$category\" · $time';
  }

  @override
  String adminSegDriverReports(int count) {
    return 'Drivers $count';
  }

  @override
  String get adminDriverReportsEmpty => 'No messages from drivers';

  @override
  String adminDriverReportMeta(String time, String driver, String stop) {
    return '$time · $driver · next stop $stop';
  }

  @override
  String get adminDriverReportNoStop => 'none (route finished)';

  @override
  String get adminDriverReportResolveTitle => 'Mark as handled';

  @override
  String get adminDriverReportResolveNote =>
      'Record what you did (for example, contacting customers). Customers are not contacted automatically.';

  @override
  String get adminDriverReportResolveSend => 'Mark as handled';

  @override
  String get adminDriverReportDone => 'Marked as handled';

  @override
  String get adminDriverReportAlready =>
      'Another team member already marked this as handled';

  @override
  String get adminDriverReportError =>
      'Couldn\'t mark this as handled. Please try again';

  @override
  String get noticeDriverReportedTitle => 'Message from a driver';

  @override
  String get noticeDriverReportedBody =>
      'A driver reported a delay or problem on tonight\'s route.';

  @override
  String get driverReportShort => 'Contact ops';

  @override
  String get driverProgressTitle => 'Tonight\'s progress';

  @override
  String driverProgressCount(int done, int total) {
    return '$done of $total stops done';
  }

  @override
  String driverProgressPickup(int done, int total) {
    return 'Pickups $done/$total';
  }

  @override
  String driverProgressSales(int done, int total) {
    return 'Sales $done/$total';
  }

  @override
  String get nextTaskLabel => 'Next';

  @override
  String stepBadgePickup(int number) {
    return 'Stop $number · Pickup';
  }

  @override
  String stepBadgeSales(int number) {
    return 'Stop $number · Sales';
  }

  @override
  String nextTaskPickupTitle(String name) {
    return 'Pick up food at $name';
  }

  @override
  String nextTaskSalesTitle(String name) {
    return 'Hand out food at $name';
  }

  @override
  String get arriveByLabel => 'Arrive by';

  @override
  String get timeLeftLabel => 'Time left';

  @override
  String get pickupAmountLabel => 'To pick up';

  @override
  String get handoutAmountLabel => 'To hand out';

  @override
  String approxMeals(int qty) {
    return 'About $qty';
  }

  @override
  String get nothingToPickUp => 'Nothing left to pick up here';

  @override
  String nextTaskPickupDetail(int count, String time) {
    return '$count items · shop stops selling at $time';
  }

  @override
  String nextTaskSalesDetail(int count) {
    return 'Scan the pickup QR for $count reservations';
  }

  @override
  String get navigateButton => 'Navigate';

  @override
  String get arrivedPickupButton => 'I\'m here · pick up';

  @override
  String get arrivedSalesButton => 'I\'m here · hand out';

  @override
  String get navigationFailed => 'Couldn\'t open the map app';

  @override
  String get allStopsDoneTitle => 'All stops are done';

  @override
  String get allStopsDoneBody =>
      'If food is left, record the donation in the End tab.';

  @override
  String get routePhasePickup => '1. Pick up at shops';

  @override
  String get routePhaseSales => '2. Hand out to customers';

  @override
  String placesCount(int count) {
    return '$count stops';
  }

  @override
  String stopPickupPending(int qty) {
    return 'Pick up about $qty';
  }

  @override
  String stopPickupDone(int qty) {
    return 'Picked up · $qty';
  }

  @override
  String stopSalesLoad(int reserved, int total) {
    return '$reserved reserved · $total in total';
  }

  @override
  String pickupStopSubtitle(int index, int total, String time) {
    return 'Pickup $index/$total · arrive by $time';
  }

  @override
  String get addressLabel => 'Address';

  @override
  String get copyAddressButton => 'Copy address';

  @override
  String get addressCopied => 'Address copied';

  @override
  String foodsToPickUp(int count) {
    return 'Food to pick up ($count)';
  }

  @override
  String get shopPlannedQty => '(shop\'s estimate)';

  @override
  String shopSellByLabel(String time) {
    return 'Shop stops selling at $time';
  }

  @override
  String get pickUpThisFood => 'Pick up this food';

  @override
  String pickedUpChip(int qty) {
    return 'Picked up · $qty';
  }

  @override
  String get pickupStepsTitle => 'How to pick up';

  @override
  String get pickupStep1 =>
      'Count the meals (it\'s fine if it differs from the estimate — enter the real number)';

  @override
  String get pickupStep2 =>
      'Measure the core temperature (chilled food: 10℃ or below)';

  @override
  String get pickupStep3 =>
      'Press confirm — the app decides where each meal goes';

  @override
  String pickupDoneTitle(int qty) {
    return 'Loaded $qty meals';
  }

  @override
  String pickupDoneSubtitle(String name, String temp) {
    return '$name · core temp $temp℃';
  }

  @override
  String get securedReservations => 'Reservations kept';

  @override
  String get refundedReservations => 'Reservations refunded';

  @override
  String get dropsTitle => 'Where this food goes';

  @override
  String dropSubtitle(String time, int count) {
    return '$time · $count reserved';
  }

  @override
  String get allPickupsDoneHint =>
      'All pickups are done. Check the food is still cold, then head out.';

  @override
  String get morePickupsHint => 'Head to the next shop.';

  @override
  String get moreFoodHereHint => 'There is more food to pick up at this shop.';

  @override
  String get backToHome => 'Home';

  @override
  String get handoutHereTitle => 'To hand out here';

  @override
  String totalMeals(int qty) {
    return '$qty in total';
  }

  @override
  String get reservedCustomers => 'Reserved';

  @override
  String get walkupSellable => 'Can sell without reservation';

  @override
  String get scanQrToHand => 'Scan QR, then hand over';

  @override
  String get registerOnSpot => 'Register each sale';

  @override
  String get perFoodLabel => 'By food';

  @override
  String batchCapacityRow(int capacity, int remaining) {
    return '$capacity ($remaining left without reservation)';
  }

  @override
  String get handoutStepsTitle => 'What to do here';

  @override
  String get handoutStep1 =>
      'Reserved customers: scan their pickup QR (or the 4-digit code)';

  @override
  String get handoutStep2 =>
      'Customers without a reservation: register each meal in the Walk-up tab';

  @override
  String get handoutStep3 => 'When done, press Depart and go to the next stop';

  @override
  String get walkupUnknownTitle => 'Couldn\'t confirm the sale was recorded';

  @override
  String get walkupUnknownBody =>
      'The connection dropped. Tap \"Record sale\" again to resend the same sale (it will not be recorded twice). If it was already recorded, you will see \"The last sale was already recorded\".';

  @override
  String walkupReplayedToast(int price) {
    return 'The last sale was already recorded (¥$price)';
  }

  @override
  String get donationUnknownTitle =>
      'Couldn\'t confirm the donation was recorded';

  @override
  String get donationUnknownBody =>
      'The connection dropped. Your entries are kept. Tapping \"Record donation\" again will not record it twice. If it was already recorded, you will see \"This donation was already recorded\".';

  @override
  String donationReplayed(int remaining) {
    return 'This donation was already recorded ($remaining meals left for this batch)';
  }

  @override
  String donationBatchOptionEmpty(String name) {
    return '$name (none left)';
  }

  @override
  String donationQtyOverRemaining(int remaining) {
    return 'Only $remaining meals are left. Enter $remaining or fewer.';
  }

  @override
  String get gpsPermissionTitle => 'Location access is off';

  @override
  String get gpsPermissionBody =>
      'Customers and operations can\'t see the truck. Allow location access in Settings (\"While using the app\" is enough).';

  @override
  String get gpsServiceOffTitle => 'Location Services are off on this device';

  @override
  String get gpsServiceOffBody =>
      'Turn on Settings → Privacy & Security → Location Services.';

  @override
  String get gpsNotSentTitle => 'The truck\'s location isn\'t being sent';

  @override
  String get gpsNotSentBody =>
      'It will be sent automatically when the connection is back. Showing the last sent location.';

  @override
  String get cameraUnavailableTitle => 'The camera can\'t be used';

  @override
  String get cameraUnavailableBody =>
      'Allow camera access in Settings. If you can\'t scan, you can also hand over with the 4-character code on the customer\'s screen.';

  @override
  String get enterCodeManually => 'Enter the code manually';

  @override
  String get routeMapOpen => 'Show the map full screen';

  @override
  String get routeMapTitle => 'Route map';

  @override
  String routeMapSubtitle(int total, int next) {
    return '$total stops · heading to stop $next';
  }

  @override
  String routeMapAllDone(int total) {
    return '$total stops · all done';
  }

  @override
  String get routeMapFitAll => 'Whole route';

  @override
  String get routeMapMyLocation => 'My location';

  @override
  String get routeMapLegend =>
      'Dotted lines show the order of stops, not the actual roads';

  @override
  String get routeMapSelectedStop => 'Selected stop';

  @override
  String get routeMapOpenStop => 'Open this stop';

  @override
  String get routeMapListHint =>
      'Pull up to see every stop (① pick up at stores · ② hand over to customers)';
}
