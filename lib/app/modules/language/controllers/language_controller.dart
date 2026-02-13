import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageOption {
  final String key;
  final Locale locale;

  const LanguageOption({
    required this.key,
    required this.locale,
  });
}

class LanguageController extends GetxController {
  static const _storageKey = 'selected_locale';

  final GetStorage _storage;
  final Rx<Locale> locale = const Locale('en', 'US').obs;

  LanguageController({GetStorage? storage})
      : _storage = storage ?? Get.find<GetStorage>() {
    locale.value = _readLocale();
  }

  final List<LanguageOption> availableLanguages = const [
    LanguageOption(key: 'English', locale: Locale('en', 'US')),
    LanguageOption(key: 'Amharic', locale: Locale('am', 'ET')),
    LanguageOption(key: 'Afaan Oromo', locale: Locale('om', 'ET')),
  ];

  Locale _readLocale() {
    final raw = _storage.read<String>(_storageKey);
    if (raw == null || raw.isEmpty) return const Locale('en', 'US');
    final parts = raw.split('_');
    if (parts.length != 2) return const Locale('en', 'US');
    return Locale(parts[0], parts[1]);
  }

  void changeLocale(Locale newLocale) {
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
      default:
        return 'EN';
    }
  }
}
