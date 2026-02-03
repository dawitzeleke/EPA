import 'package:eprs/domain/usecases/get_awareness_usecase.dart';
import 'package:get/get.dart';

import '../controllers/awareness_controller.dart';

class AwarenessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AwarenessController>(
      () => AwarenessController(
        getAwarenessUseCase: Get.find<GetAwarenessUseCase>(),
      ),
    );
  }
}
