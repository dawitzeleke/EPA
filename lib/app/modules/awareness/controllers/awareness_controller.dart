import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/data/models/awareness_model.dart';
import 'package:eprs/domain/usecases/get_awareness_usecase.dart';
import 'package:get/get.dart';

class AwarenessController extends GetxController {
  final GetAwarenessUseCase getAwarenessUseCase;

  final RxList<AwarenessModel> awarenessList = <AwarenessModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  AwarenessController({required this.getAwarenessUseCase});

  @override
  void onInit() {
    super.onInit();
    loadAwareness();
  }

  Future<void> loadAwareness() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final awarenessItems = await getAwarenessUseCase.execute();
      awarenessList.assignAll(awarenessItems);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load awareness items: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

 /// Get image URL for an awareness item
String getImageUrl(AwarenessModel awareness) {
  if (awareness.filePath.trim().isEmpty) return '';

  const baseUrl = ApiConstants.fileBaseUrl;

  // Delegate to model helper to build a proper URL
  final imageUrl = awareness.getImageUrl(baseUrl);

  print('Awareness image URL: $imageUrl');
  print('Original file path: ${awareness.filePath}');

  return imageUrl;
}


}
