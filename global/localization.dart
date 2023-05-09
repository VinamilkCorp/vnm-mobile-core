import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Localization {
  static Localization _i = Localization._();
  AppLocalizations? _locale;

  Localization._();

  factory Localization() => _i;

  void initialize(BuildContext context) {
    _locale = AppLocalizations.of(context);
  }

  AppLocalizations get locale => _locale!;
}
