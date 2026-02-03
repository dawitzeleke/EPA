import 'package:get/get.dart';

import '../controllers/setting_controller.dart';
import '../../../../domain/usecases/update_profile_usecase.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingController>(
      () => SettingController(
        updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
      ),
    );
  }
}
