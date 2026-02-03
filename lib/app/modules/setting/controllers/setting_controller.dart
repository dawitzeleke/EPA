import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/domain/usecases/update_profile_usecase.dart';

class SettingController extends GetxController {
  final UpdateProfileUseCase updateProfileUseCase;

  SettingController({required this.updateProfileUseCase});

  final count = 0.obs;
  
  // User data
  var userName = ''.obs;
  var phoneNumber = ''.obs;
  var isLoggedIn = false.obs;
  var userId = ''.obs;
  var isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final storage = Get.find<GetStorage>();
    final token = storage.read('auth_token');
    
    isLoggedIn.value = token != null && token.toString().isNotEmpty;
    print('Loaded token: $token');
    if (isLoggedIn.value) {
      userName.value = storage.read('username') ?? 
                       storage.read('full_name') ?? 
                       'User';

      final storedPhone = storage.read('phone');
      final storedPhoneNumber = storage.read('phone_number');
      print("Stored phone: $storedPhone");
      print("Stored phone_number: $storedPhoneNumber");
      // Prefer the first non-empty value
      phoneNumber.value = (storedPhone is String && storedPhone.trim().isNotEmpty)
          ? storedPhone.trim()
          : (storedPhoneNumber is String && storedPhoneNumber.trim().isNotEmpty)
              ? storedPhoneNumber.trim()
              : '';

      userId.value = storage.read('userId') ?? storage.read('user_id') ?? '';
    }
  }

  void refreshUserData() {
    _loadUserData();
  }

  Future<void> updateUserName(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty');
    }

    if (userId.value.trim().isEmpty) {
      throw Exception('Missing user id');
    }

    isUpdating.value = true;
    try {
      final response = await updateProfileUseCase.execute(
        id: userId.value,
        fullName: trimmed,
      );

      final updatedName = response.fullName?.isNotEmpty == true
          ? response.fullName!.trim()
          : trimmed;

      userName.value = updatedName;

      final storage = Get.find<GetStorage>();
      await storage.write('username', updatedName);
      await storage.write('full_name', updatedName);

      if (response.success != true) {
        throw Exception(response.message ?? 'Profile update failed');
      }
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (userId.value.trim().isEmpty) {
      throw Exception('Missing user id');
    }

    final effectiveName = userName.value.trim().isNotEmpty
        ? userName.value.trim()
        : 'User';

    isUpdating.value = true;
    try {
      final response = await updateProfileUseCase.execute(
        id: userId.value,
        fullName: effectiveName,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response.success != true) {
        throw Exception(response.message ?? 'Password update failed');
      }
    } finally {
      isUpdating.value = false;
    }
  }

  void increment() => count.value++;
}
