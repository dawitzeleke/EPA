import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/login_usecase.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
class LoginController extends GetxController {
  final LoginUseCase loginUseCase;

  LoginController({required this.loginUseCase});

  var email = ''.obs;
  var password = ''.obs;
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var phoneNumber = ''.obs;
  var resetPhoneNumber = ''.obs;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  var isSendingOtp = false.obs;
  var isResettingPassword = false.obs;
  var resetOtp = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  Future<bool> sendOTP() async {
    if (resetPhoneNumber.value.trim().isEmpty) {
      _showErrorDialog('Missing Phone Number', 'Please enter your phone number.');
      return false;
    }

    isSendingOtp.value = true;
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://eprs.epa.gov.et/api/customer-accounts/request-password-otp',
        data: {'phone_number': resetPhoneNumber.value.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _showErrorDialog('Error', 'Failed to send OTP. Please try again.');
        return false;
      }
    } catch (e) {
      _showErrorDialog('Error', 'An error occurred. Please try again.');
      return false;
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<bool> resetPassword() async {
    if (resetOtp.value.trim().isEmpty || newPassword.value.trim().isEmpty || confirmPassword.value.trim().isEmpty) {
      _showErrorDialog('Error', 'Please fill all fields.');
      return false;
    }

    if (newPassword.value != confirmPassword.value) {
      _showErrorDialog('Error', 'Passwords do not match.');
      return false;
    }

    isResettingPassword.value = true;
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://eprs.epa.gov.et/api/customer-accounts/reset-password-otp',
        data: {
          'phone_number': resetPhoneNumber.value.trim(),
          'otp': resetOtp.value.trim(),
          'newPassword': newPassword.value.trim(),
          'confirmPassword': confirmPassword.value.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        _showErrorDialog('Error', 'Failed to reset password.');
        return false;
      }
    } catch (e) {
      _showErrorDialog('Error', 'An error occurred. Please try again.');
      return false;
    } finally {
      isResettingPassword.value = false;
    }
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

        // Ensure the app lands on Home tab after login.
        if (Get.isRegistered<BottomNavController>()) {
          Get.find<BottomNavController>().resetToHome();
        }

        // Navigate to home screen and clear intermediate history
        // (e.g., when login was opened from Settings).
        Get.offAllNamed(
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
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back(closeOverlays: true);
                  return;
                }

                final context = Get.overlayContext;
                if (context != null && Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
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
