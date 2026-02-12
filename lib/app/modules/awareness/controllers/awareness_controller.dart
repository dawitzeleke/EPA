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
      errorMessage.value = _cleanErrorMessage(e);
      Get.snackbar(
        'Error',
        'Failed to load awareness items: ${_cleanErrorMessage(e)}',
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

  String _cleanErrorMessage(Object error) {
    final text = error.toString();
    final cleaned = text
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp(r'^DioException[^:]*:\s*'), '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }


}
