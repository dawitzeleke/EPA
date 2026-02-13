import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/languages/app_translations.dart';
import 'app/modules/language/controllers/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FlutterDownloader.initialize();  // Initialize flutter_downloader here

  // Initialize dependency injection
  await di.InjectionContainer.init();

  final languageController = Get.put(LanguageController(), permanent: true);

  runApp(
    GetMaterialApp(
      title: "EPA",
      translations: AppTranslations(),
      locale: languageController.locale.value,
      fallbackLocale: AppTranslations.fallbackLocale,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
    ),
  );
}
