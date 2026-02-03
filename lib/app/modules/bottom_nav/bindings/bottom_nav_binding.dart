import 'package:get/get.dart';

import '../controllers/bottom_nav_controller.dart';
import '../../home/controllers/home_controller.dart'; // Import HomeController

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavController>(() => BottomNavController());
    Get.lazyPut<HomeController>(() => HomeController(  
      getNewsUseCase: Get.find(),
    )); // Ensure HomeController is available
  }
}

