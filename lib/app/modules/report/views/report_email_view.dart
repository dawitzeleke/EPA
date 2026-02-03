import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/report_email_controller.dart';

class ReportEmailView extends GetView<ReportEmailController> {
  const ReportEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered in case of hot-reload edge cases
    if (!Get.isRegistered<ReportEmailController>()) {
      Get.lazyPut<ReportEmailController>(() => ReportEmailController());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: const CustomAppBar(
        title: 'Verify Email',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter your email',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We will send a one-time code to this email to confirm your report.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        filled: true,
                        fillColor: const Color(0xFFF9FBFF),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Obx(
                      () => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'SEND CODE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
