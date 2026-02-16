import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/login_usecase.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var phoneNumber = ''.obs;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Handle login submission
  Future<void> submitLogin() async {
    // Validate inputs
    if (phoneNumber.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Phone Number',
        'Please enter your phone number to continue',
      );
      return;
    }

    if (password.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Password',
        'Please enter your password to continue',
      );
      return;
    }

    // Set loading state
    isLoading.value = true;

    try {
      // Call use case
      final response = await loginUseCase.execute(
        phone_number: phoneNumber.value,
        password: password.value,
      );

      // Check if login was successful
      if (response.success) {
        // Save user data to GetStorage for easy access
        

        final storage = Get.find<GetStorage>();
        if (response.username != null) {
          storage.write('username', response.username);
        }
        final phoneResp = response.phone_number;
        if (phoneResp != null && phoneResp.trim().isNotEmpty) {
          storage.write('phone', phoneResp.trim());
          storage.write('phone_number', phoneResp.trim());
        }
        if (response.userId != null) {
          storage.write('userId', response.userId);
        }

        // Navigate to home screen
        Get.offNamed(
          Routes.HOME,
          arguments: {
            'username': response.username ?? 'Guest',
            'phone': response.phone_number ?? '',
            'phone_number': phoneNumber.value,
          },
        );

        // Show success message
        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        _showErrorDialog(
          'Login Failed',
          response.message ?? 'Invalid credentials. Please try again.',
        );
      }
    } catch (e) {
      // Handle errors
      _showErrorDialog(
        'Login Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  /// Show error dialog
  void _showErrorDialog(String title, String message) {
    Get.defaultDialog(
      title: '',
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      backgroundColor: Colors.white,
      radius: 12,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '⚠️ $title',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
