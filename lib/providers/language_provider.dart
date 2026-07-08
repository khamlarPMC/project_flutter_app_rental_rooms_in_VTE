import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._();
  static LanguageProvider get instance => _instance;
  LanguageProvider._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isLao => _locale.languageCode == 'lo';

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    setLocale(isLao ? const Locale('en') : const Locale('lo'));
  }
}
