import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/signup_usecase.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SignUpController extends GetxController {
  final SignupUseCase signupUseCase;

  SignUpController({required this.signupUseCase});

  final fullName = ''.obs;
  final password = ''.obs;
  final email = ''.obs;
  final phoneNumber = ''.obs;
  final confirmPassword = ''.obs;
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Handle signup submission
  Future<void> signUp() async {
    // Validate inputs
    if (fullName.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Full Name',
        'Please enter your full name to continue',
      );
      return;
    }

    if (email.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Email',
        'Please enter your email to continue',
      );
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.value.trim())) {
      _showErrorDialog(
        'Invalid Email',
        'Please enter a valid email address',
      );
      return;
    }

    if (phoneNumber.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Phone Number',
        'Please enter your phone number to continue',
      );
      return;
    }

    // Validate Ethiopian phone number format
    final isValidPhone = RegExp(r'^09\d{8}$').hasMatch(phoneNumber.value.trim());
    if (!isValidPhone) {
      _showErrorDialog(
        'Invalid Phone Number',
        'Please enter a valid Ethiopian phone number (e.g. 0912345678)',
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

    if (password.value.length < 6) {
      _showErrorDialog(
        'Weak Password',
        'Password must be at least 6 characters long',
      );
      return;
    }

    if (confirmPassword.value.trim().isEmpty) {
      _showErrorDialog(
        'Missing Password Confirmation',
        'Please confirm your password',
      );
      return;
    }

    if (password.value != confirmPassword.value) {
      _showErrorDialog(
        'Password Mismatch',
        'Passwords do not match. Please try again.',
      );
      return;
    }

    // Set loading state
    isLoading.value = true;

    try {
      // Call use case
      final response = await signupUseCase.execute(
        fullName: fullName.value,
        email: email.value,
        phoneNumber: phoneNumber.value,
        password: password.value,
        confirmPassword: confirmPassword.value,
      );

      // Check if signup was successful
      // If we reach here without exception, signup was successful
      // Navigate to OTP verification page
      Get.toNamed(
        Routes.SIGNUP_OTP,
        arguments: {
          'email': email.value,
          'phone': phoneNumber.value,
        },
      );

      // Show success message
      Get.snackbar(
        'Success',
        response.message ?? 'Account created successfully! Please check your email for OTP.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      // Handle errors
      _showErrorDialog(
        'Signup Error',
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
