import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import '../controllers/signup_otp_controller.dart';

class SignupOtpView extends GetView<SignupOtpController> {
  const SignupOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isSmall = height < 700;
    final horizontalPadding = width * 0.06;
    final verticalPadding = isSmall ? 16.0 : 24.0;
    final titleFontSize = isSmall ? 14.0 : 16.0;
    final otpBoxSize = ((width - (horizontalPadding * 2) - 40) / 6)
        .clamp(42.0, 56.0);
    final spacingLg = isSmall ? 18.0 : 28.0;
    final spacingSm = isSmall ? 6.0 : 8.0;

    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      appBar: const CustomAppBar(
        title: 'OTP Verification',
        subtitle: 'Verify your Phone Number',
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hidden input to use system keypad
            SizedBox(
              height: 0,
              width: 0,
              child: TextField(
                controller: controller.otpTextController,
                focusNode: controller.otpFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.length > 6) {
                    controller.otpTextController.text = value.substring(0, 6);
                    controller.otpTextController.selection =
                        TextSelection.fromPosition(
                      const TextPosition(offset: 6),
                    );
                  }
                  controller.code.value =
                      controller.otpTextController.text.trim();
                },
              ),
            ),
            // Center everything except keypad
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 8,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Verify OTP',
                              style: TextStyle(
                                fontSize: isSmall ? 22 : 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacingSm),
                            Text(
                              'Enter the 6-digit code sent to ${controller.phone}.',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                height: 1.5,
                                color: const Color(0xFF222222),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: spacingLg),

                            // OTP boxes
                            Obx(
                              () => Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(6, (i) {
                                  final code = controller.code.value;
                                  final digit = (i < code.length) ? code[i] : '';
                                  final isFocused =
                                      i == code.length && code.length < 6;
                                  return _otpBox(
                                    digit,
                                    isFocused,
                                    otpBoxSize,
                                    isSmall,
                                    onTap: () => controller.otpFocusNode.requestFocus(),
                                  );
                                }),
                              ),
                            ),

                            SizedBox(height: spacingLg),
                            Obx(
                              () => Center(
                                child: Column(
                                  children: [
                                    const Text(
                                      "Didn't receive code?",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    SizedBox(height: spacingSm),
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

                            SizedBox(height: spacingLg),

                            Obx(
                              () => SizedBox(
                                height: isSmall ? 48 : 52,
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
                                          'Verify OTP',
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
                  );
                },
              ),
            ),

            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(
    String digit,
    bool focused,
    double size,
    bool isSmall, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size + (isSmall ? 8 : 12),
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
            style: TextStyle(
              fontSize: isSmall ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  
}

