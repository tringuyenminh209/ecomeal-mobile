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
  String get errorProfileLoadFailed =>
      'Couldn’t load your profile. Please try again';

  @override
  String get appTitle => 'EcoMeal';

  @override
  String get driverAppTitle => 'EcoMeal Driver';

  @override
  String get driverBadge => 'Driver';

  @override
  String get switchLanguageLabel => '日本語';

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
      'Card details are tokenized securely. Never share your CVC.';

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
      'Free cancellation up to 30 minutes before pickup';

  @override
  String get freeCancelBody =>
      'You can cancel for free up to 30 minutes before pickup. Cancel from your reservation history.';

  @override
  String get errorReservationFailed =>
      'Couldn’t complete the reservation. The meals may have sold out. Please choose another meal';

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
      'You can cancel for free up to 30 minutes before pickup. You will receive a full refund.';

  @override
  String get cancelDialogNoRefund =>
      'It’s less than 30 minutes before pickup, so you won’t get a refund if you cancel.';

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
  String orderNumber(String number) {
    return 'Order $number';
  }

  @override
  String get pendingExplanation =>
      'The driver is checking the quantity. If there is a shortage, meals are allocated per pickup point in order of reservation (FIFO). Anything not allocated is refunded automatically.';

  @override
  String allocatedExplanation(String stopName) {
    return 'One bag is reserved for you at $stopName. Show the QR code at pickup; if it cannot be scanned, tell the driver the code below.';
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
      'It’s less than 30 minutes before pickup, so you won’t get a refund if you cancel.';

  @override
  String get errorBadge => 'Error';

  @override
  String get browseBatches => 'See nearby meals';

  @override
  String totalWithQuantity(int quantity) {
    return 'Total (qty $quantity)';
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
      'This batch has already been confirmed';

  @override
  String get errorStopNotOnRoute =>
      'The selected stops are not on this batch\'s route';

  @override
  String get errorStopClosed => 'This stop has already been closed';

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
      'Check that chilled items are 10°C or below. Contact the operations team if not.';

  @override
  String get coldChainOverLimit =>
      'Above the limit (10℃ or below). This lot can\'t be collected or sold.';

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
  String pickupConfirmedToast(int qty, int allocated, int refunded) {
    return 'Confirmed $qty meals ($allocated reservations kept, $refunded refunded)';
  }

  @override
  String get rejectPickupButton => 'Don\'t collect (over temperature limit)';

  @override
  String get rejectPickupDialogTitle => 'Don\'t collect this lot?';

  @override
  String rejectPickupDialogBody(String celsius) {
    return 'The core temperature is $celsius℃, above the limit (10℃ or below). This lot won\'t be sold; all reservations are refunded and customers are notified. The temperature record is kept.';
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
  String get noPendingPickup => 'No unconfirmed pickups at this store';

  @override
  String get selectBatchToPickUp => 'Select a batch to pick up';

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
  String get allStopsCompleted => 'All stops completed';

  @override
  String get reservedOrdersLabel => 'Reservations';

  @override
  String get reservedOrdersCaption => 'Total for remaining stops';

  @override
  String get stopDonePickup => 'Done • Picked up';

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
  String stopCount(int count) {
    return '$count stops';
  }

  @override
  String get routeDone => 'Done';

  @override
  String get routeInProgress => 'In service';

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
  String get gpsSending => 'Sending GPS';

  @override
  String get driverAccountSubtitle => 'Driver account';

  @override
  String get errorNotHandoverable =>
      'This reservation cannot be handed over in its current state';

  @override
  String get errorWalkupSoldOut => 'Walk-up stock at this stop is sold out';

  @override
  String get errorWalkupNotConfirmed =>
      'Walk-up sales require a confirmed batch';

  @override
  String get errorBatchExpired => 'This batch is past its sell-by time';

  @override
  String get errorDonationExceedsStock =>
      'Donation quantity exceeds the remaining stock';

  @override
  String get errorDonationNotConfirmed => 'Donations require a confirmed batch';

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
    return '$count reservations are still waiting. If you depart, they will be treated as no-show / expired and will not be refunded.';
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
  String get batchLabel => 'Batch';

  @override
  String get noWalkupBatches => 'No batches can be sold at this stop';

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
  String donationBatchOption(String name, int qty) {
    return '$name (confirmed $qty meals)';
  }

  @override
  String donationRecorded(int remaining) {
    return 'Donation recorded ($remaining meals left in this batch)';
  }

  @override
  String get donationTitle => 'Record donation of unsold meals';

  @override
  String get donationLockedNotice =>
      'You can record donations after departing from every sales stop (no more sales are possible then, so the remaining stock is final).';

  @override
  String get noConfirmedBatches => 'No confirmed batches';

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
}
