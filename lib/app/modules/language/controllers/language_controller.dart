import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageOption {
  final String label;
  final Locale locale;

  const LanguageOption({
    required this.label,
    required this.locale,
  });
}

class LanguageController extends GetxController {
  static const _storageKey = 'selected_locale';
  static const _defaultLocale = Locale('en', 'US');

  final GetStorage _storage;
  final Rx<Locale> locale = _defaultLocale.obs;

  LanguageController({GetStorage? storage})
      : _storage = storage ?? Get.find<GetStorage>() {
    locale.value = _readLocale();
  }

  static const List<LanguageOption> _allLanguages = [
    LanguageOption(label: 'English', locale: Locale('en', 'US')),
    LanguageOption(label: 'አማርኛ', locale: Locale('am', 'ET')),
    LanguageOption(label: 'Afaan Oromoo', locale: Locale('om', 'ET')),
    LanguageOption(label: 'Soomaali', locale: Locale('so', 'ET')),
  ];

  List<LanguageOption> get availableLanguages => _allLanguages;

  Locale _readLocale() {
    final raw = _storage.read<String>(_storageKey);
    if (raw == null || raw.isEmpty) return _defaultLocale;
    final parts = raw.split('_');
    if (parts.length != 2) return _defaultLocale;

    final stored = Locale(parts[0], parts[1]);
    if (_isSupported(stored)) return stored;

    return _defaultLocale;
  }

  void changeLocale(Locale newLocale) {
    if (!_isSupported(newLocale)) return;

    locale.value = newLocale;
    _storage.write(_storageKey, '${newLocale.languageCode}_${newLocale.countryCode}');
    Get.updateLocale(newLocale);
  }

  bool isSelected(Locale option) =>
      option.languageCode == locale.value.languageCode &&
      option.countryCode == locale.value.countryCode;

  String get currentLabel {
    switch (locale.value.languageCode) {
      case 'am':
        return 'AM';
      case 'om':
        return 'OM';
      case 'so':
        return 'SO';
      default:
        return 'EN';
    }
  }

  bool _isSupported(Locale locale) => availableLanguages.any(
        (option) =>
            option.locale.languageCode == locale.languageCode &&
            option.locale.countryCode == locale.countryCode,
      );
}
