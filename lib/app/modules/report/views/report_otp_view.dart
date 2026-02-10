import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import '../controllers/report_otp_controller.dart';

class ReportOtpView extends GetView<ReportOtpController> {
  const ReportOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered (helps when hot-reload left state inconsistent)
    if (!Get.isRegistered<ReportOtpController>()) {
      Get.lazyPut<ReportOtpController>(() => ReportOtpController());
    }

    final phoneText = controller.phone.isNotEmpty
      ? controller.phone
      : 'your phone number';
    final size = MediaQuery.of(context).size;
    final boxSize = ((size.width - 80) / 6).clamp(48.0, 64.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6FA),
      appBar: const CustomAppBar(
        title: 'OTP',
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => controller.toggleKeypad(false),
        child: Column(
          children: [
            // Scrollable content to avoid overflow on small screens
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: size.height * 0.45),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'We sent a one-time code to $phoneText. Check your phone and enter the code below.',
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF222222),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 22),

                        // OTP boxes
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (i) {
                              final code = controller.code.value;
                              final digit = (i < code.length) ? code[i] : '';
                              final isFocused = i == code.length && code.length < 6;
                              return _otpBox(digit, isFocused, boxSize);
                            }),
                          ),
                        ),

                        const SizedBox(height: 22),
                        Obx(
                          () => Center(
                            child: Column(
                              children: [
                                const Text(
                                  "Didn't receive code?",
                                  style: TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                controller.seconds.value > 0
                                    ? RichText(
                                        text: TextSpan(
                                          text: 'You can resend code in ',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '${controller.seconds.value}s',
                                              style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: (controller.isResending.value || controller.isLoading.value)
                                            ? null
                                            : controller.resendOtp,
                                        child: controller.isResending.value
                                            ? const SizedBox(
                                                height: 16,
                                                width: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                                                ),
                                              )
                                            : const Text(
                                                'Resend code',
                                                style: TextStyle(
                                                  color: Color(0xFF3B82F6),
                                                ),
                                              ),
                                      ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Obx(
                          () => SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: (controller.code.value.length == 6 && !controller.isLoading.value)
                                  ? controller.verifyOtp
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'CONFIRM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Show keypad only when active
            Obx(
              () => controller.showKeypad.value
                  ? _keypad(controller, size)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(String digit, bool focused, double boxSize) {
    return GestureDetector(
      onTap: () => controller.toggleKeypad(true),
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused ? const Color(0xFF3B82F6) : const Color(0xFFE6E9EF),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad(ReportOtpController controller, Size size) {
    final labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '⌫'];
    final keypadHeight = (size.height * 0.38).clamp(240.0, 320.0);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      // Constrain keypad height to avoid unbounded/overflow during hot-reload or
      // unexpected layout changes. Adjust height as needed for different screens.
      child: SizedBox(
        height: keypadHeight,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            for (final label in labels)
              GestureDetector(
                onTap: () {
                  if (label == '⌫') {
                    controller.backspace();
                  } else if (label == '*') {
                    // no operation
                  } else {
                    controller.append(label);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: label == '⌫'
                        ? const Icon(
                            Icons.backspace_outlined,
                            size: 26,
                            color: Colors.black54,
                          )
                        : Text(
                            label,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
