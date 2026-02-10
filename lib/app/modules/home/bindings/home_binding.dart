import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(
        HomeController(
          getNewsUseCase: Get.find(),
        ),
        permanent: true,
      );
    }
  }
}
