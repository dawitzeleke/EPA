import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import 'package:eprs/domain/usecases/get_sound_areas_usecase.dart';
import 'package:eprs/domain/usecases/get_cities_usecase.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<ReportController>()) {
      final existing = Get.find<ReportController>();
      if (!existing.isClosed) {
        return;
      }
      Get.delete<ReportController>(force: true);
    }

    // Keep the controller alive while tabs are in use to avoid disposing
    // TextEditingControllers that are still referenced by the report view.
    Get.put<ReportController>(
      ReportController(
        getSoundAreasUseCase: Get.find<GetSoundAreasUseCase>(),
        getCitiesUseCase: Get.find<GetCitiesUseCase>(),
      ),
      permanent: true,
    );
  }
}
