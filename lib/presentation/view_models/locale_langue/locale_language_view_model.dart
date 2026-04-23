import 'package:event_go/core/base/base_view_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LocaleNotifier extends BaseViewModel {
  static const String localeKey = "selected_locale";

  LocaleNotifier() {
    initLocale();
  }

  Locale _locale = const Locale('vi');

  Locale get locale => _locale;

  Future<void> initLocale() async {
    final box = Hive.box('settings');

    final savedLocaleCode = box.get(localeKey, defaultValue: 'vi');

    _locale = Locale(savedLocaleCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    final box = Hive.box('settings');
    await box.put(localeKey, locale.languageCode);

    notifyListeners();
  }
}
