import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../../domain/usecases/login_usecase.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        loginUseCase: Get.find<LoginUseCase>(),
      ),
    );
  }
}

