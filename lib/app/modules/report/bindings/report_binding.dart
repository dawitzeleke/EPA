import 'package:get/get.dart';

import '../controllers/report_controller.dart';
import 'package:eprs/domain/usecases/get_sound_areas_usecase.dart';
import 'package:eprs/domain/usecases/get_cities_usecase.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    // Use put instead of lazyPut to ensure controller is created fresh each time
    // This helps avoid type issues with hot reload
    Get.put<ReportController>(
      ReportController(
        getSoundAreasUseCase: Get.find<GetSoundAreasUseCase>(),
        getCitiesUseCase: Get.find<GetCitiesUseCase>(),
      ),
      permanent: false,
    );
  }
}
