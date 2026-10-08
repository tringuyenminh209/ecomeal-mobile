import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

// Viết context.l10n.loginButton thay vì AppLocalizations.of(context).loginButton ở mọi màn hình.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
