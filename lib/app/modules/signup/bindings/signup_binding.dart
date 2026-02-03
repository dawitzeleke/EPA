import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import '../../../../domain/usecases/signup_usecase.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(
      () => SignUpController(
        signupUseCase: Get.find<SignupUseCase>(),
      ),
    );
  }
}
