import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import '../controllers/signup_otp_controller.dart';

class SignupOtpView extends GetView<SignupOtpController> {
  const SignupOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      appBar: const CustomAppBar(
        title: 'OTP Verification',
        subtitle: 'Verify your email',
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => controller.toggleKeypad(false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Center everything except keypad
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'We have sent the OTP verification code to ${controller.email}. Check your email and enter the code below.',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF222222),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // OTP boxes
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (i) {
                            final code = controller.code.value;
                            final digit = (i < code.length) ? code[i] : '';
                            final isFocused =
                                i == code.length && code.length < 6;
                            return _otpBox(digit, isFocused);
                          }),
                        ),
                      ),

                      const SizedBox(height: 28),
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
                                            text:
                                                '${controller.seconds.value}s',
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : controller.resendOtp,
                                      child: const Text(
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

                      const SizedBox(height: 28),

                      Obx(
                        () => SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (controller.code.value.length == 6 &&
                                    !controller.isLoading.value)
                                ? controller.verifyOtp
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'CONFIRM',
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
            ),

            // Show keypad only when active
            Obx(
              () => controller.showKeypad.value
                  ? _keypad(controller)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(String digit, bool focused) {
    return GestureDetector(
      onTap: () => controller.toggleKeypad(true),
      child: Container(
        width: 50,
        height: 60,
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad(SignupOtpController controller) {
    final labels = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '⌫'];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: SizedBox(
        height: 300,
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

