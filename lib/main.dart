import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FlutterDownloader.initialize();  // Initialize flutter_downloader here

  // Initialize dependency injection
  await di.InjectionContainer.init();

  runApp(
    GetMaterialApp(
      title: "EPA",
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
    ),
  );
}
