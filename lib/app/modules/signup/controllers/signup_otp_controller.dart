import 'dart:async';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/verify_otp_usecase.dart';
import 'package:eprs/domain/usecases/resend_otp_usecase.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SignupOtpController extends GetxController {
  final VerifyOtpUseCase verifyOtpUseCase;
  final ResendOtpUseCase resendOtpUseCase;
  final String email;
  final String phone;

  SignupOtpController({
    required this.verifyOtpUseCase,
    required this.resendOtpUseCase,
    required this.email,
    this.phone = '',
  });

  var code = ''.obs;
  var seconds = 60.obs;
  var showKeypad = false.obs;
  var isLoading = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    seconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value <= 0) {
        t.cancel();
        update();
      } else {
        seconds.value--;
      }
    });
  }

  void append(String d) {
    if (code.value.length >= 6) return;
    code.value += d;
  }

  void backspace() {
    if (code.value.isEmpty) return;
    code.value = code.value.substring(0, code.value.length - 1);
  }

  void toggleKeypad(bool visible) {
    showKeypad.value = visible;
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (code.value.length < 6) {
      _showErrorDialog(
        'Incomplete OTP',
        'Please enter the complete 6-digit OTP code',
      );
      return;
    }

    // Set loading state
    isLoading.value = true;

    try {
      // Call use case
      final response = await verifyOtpUseCase.execute(
        email: email,
        otp: code.value,
      );

      // If we reach here without exception, verification was successful
      // Save user data to GetStorage (token is already saved by repository)
      final storage = Get.find<GetStorage>();
      if (response.username != null) {
        storage.write('username', response.username);
      }
      if (response.email != null) {
        storage.write('email', response.email);
      }
      if (phone.isNotEmpty) {
        storage.write('phone', phone);
        storage.write('phone_number', phone);
      }
      if (response.userId != null) {
        storage.write('userId', response.userId);
      }

      // Show success message first
      Get.snackbar(
        'Success',
        response.message ?? 'Account verified successfully! Please login to continue.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Navigate to login page after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(
          Routes.LOGIN,
          arguments: {
            'firstTimeLogin': true,
          },
        );
      });
    } catch (e) {
      // Handle errors
      _showErrorDialog(
        'Verification Error',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      // Reset loading state
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    // Set loading state
    isLoading.value = true;

    try {
      // Call use case
      final success = await resendOtpUseCase.execute(email);

      if (success) {
        // Reset timer
        startTimer();
        // Clear current code
        code.value = '';

        // Show success message
        Get.snackbar(
          'Success',
          'OTP has been resent to your email',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      // Handle errors
      _showErrorDialog(
        'Resend Error',
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

