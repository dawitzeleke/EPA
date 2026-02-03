import 'package:get/get.dart';

import '../controllers/office_detail_map_view_controller.dart';

class OfficeDetailMapViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfficeDetailMapViewController>(
      () => OfficeDetailMapViewController(),
    );
  }
}
