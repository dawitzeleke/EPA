import 'package:eprs/domain/usecases/get_offices_usecase.dart';
import 'package:get/get.dart';

import '../controllers/office_controller.dart';

class OfficeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfficeController>(
      () => OfficeController(
        getOfficesUsecase: Get.find<GetOfficesUsecase>(),
      ),
    );
  }
}
