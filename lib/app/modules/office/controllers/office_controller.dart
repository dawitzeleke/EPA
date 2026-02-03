import 'package:eprs/data/models/office_model.dart';
import 'package:eprs/domain/usecases/get_offices_usecase.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class OfficeLocation {
  final String name;
  final String address;
  final String phone;
  final String email;
  final LatLng position;

  const OfficeLocation({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.position,
  });

  // Convert from OfficeModel
  factory OfficeLocation.fromModel(OfficeModel model) {
    return OfficeLocation(
      name: model.name,
      address: model.description.isNotEmpty ? model.description : 'No address provided',
      phone: model.phoneNumber,
      email: model.email,
      position: model.position,
    );
  }
}

class OfficeController extends GetxController {
  final GetOfficesUsecase getOfficesUsecase;
  
  final RxString searchQuery = ''.obs;
  final Rxn<OfficeLocation> selectedOffice = Rxn<OfficeLocation>();
  final RxList<OfficeLocation> _offices = <OfficeLocation>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  OfficeController({required this.getOfficesUsecase});

  @override
  void onInit() {
    super.onInit();
    loadOffices();
  }

  List<OfficeLocation> get offices => _offices;

  LatLng get initialCenter {
    if (_offices.isEmpty) {
      return const LatLng(9.025167, 38.758888); // Default center (Addis Ababa)
    }
    // Calculate center from offices
    double avgLat = _offices.map((o) => o.position.latitude).reduce((a, b) => a + b) / _offices.length;
    double avgLng = _offices.map((o) => o.position.longitude).reduce((a, b) => a + b) / _offices.length;
    return LatLng(avgLat, avgLng);
  }

  List<OfficeLocation> get filteredOffices {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      return _offices;
    }
    return _offices
        .where(
          (office) =>
              office.name.toLowerCase().contains(query) ||
              office.address.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadOffices() async {
    isLoading.value = true;
    errorMessage.value = null;
    
    try {
      final officeModels = await getOfficesUsecase.execute();
      _offices.assignAll(
        officeModels.map((model) => OfficeLocation.fromModel(model)).toList(),
      );
    } catch (e) {
      errorMessage.value = e.toString();
      // Keep empty list on error, or you could show a snackbar
      Get.snackbar(
        'Error',
        'Failed to load offices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void selectOffice(OfficeLocation office) {
    selectedOffice.value = office;
  }

  void clearSelection() {
    selectedOffice.value = null;
  }
}
