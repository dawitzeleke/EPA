import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/signup_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/signup_usecase.dart';

class SignUpOverlay extends StatefulWidget {
  const SignUpOverlay({super.key});

  @override
  State<SignUpOverlay> createState() => _SignUpOverlayState();
}

class _SignUpOverlayState extends State<SignUpOverlay> {
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _confirmPassCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get controller from GetX (it should be registered via binding)
    final controller = Get.isRegistered<SignUpController>()
        ? Get.find<SignUpController>()
        : Get.put(SignUpController(signupUseCase: Get.find<SignupUseCase>()));
    
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Responsive calculations
    final isSmall = height < 700;
    final logoHeight = height * 0.15; // Smaller than login due to more fields
    final betweenFields = height * 0.015; // Slightly tighter spacing

    const greenColor = AppColors.primary;
    const hintText = Color(0xFF9BA5B1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFFF8FAFB),
                  Color(0xFFF5F7FA),
                  Color(0xFFF8FAFB),
                ],
                center: Alignment.topCenter,
                radius: 1.2,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: LanguageSelector(
                      fontSize: isSmall ? 12 : 13,
                      iconSize: isSmall ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Image.asset(
                    'assets/logo.png',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    'Create EPA PASS Account'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // Full Name Input
                        _buildTextField(
                          controller: _nameCtrl,
                          hint: 'Full Name'.tr,
                          icon: Icons.person_outline,
                          isSmall: isSmall,
                          onChanged: (v) => controller.fullName.value = v,
                        ),
                        SizedBox(height: betweenFields),

                        // Email Input
                        _buildTextField(
                          controller: _emailCtrl,
                          hint: 'Email'.tr,
                          icon: Icons.email_outlined,
                          isSmall: isSmall,
                          inputType: TextInputType.emailAddress,
                          onChanged: (v) => controller.email.value = v,
                        ),
                        SizedBox(height: betweenFields),

                        // Phone Number Input
                        _buildTextField(
                          controller: _phoneCtrl,
                          hint: 'Phone Number'.tr,
                          icon: Icons.phone_outlined,
                          isSmall: isSmall,
                          inputType: TextInputType.phone,
                          onChanged: (v) => controller.phoneNumber.value = v,
                        ),
                        SizedBox(height: betweenFields),

                        // Password Input
                        Obx(() => _buildTextField(
                          controller: _passCtrl,
                          hint: 'Password'.tr,
                          icon: Icons.lock_outline,
                          isSmall: isSmall,
                          isPassword: true,
                          obscureText: controller.obscurePassword.value,
                          onToggleVisibility: controller.togglePasswordVisibility,
                          onChanged: (v) => controller.password.value = v,
                        )),
                        SizedBox(height: betweenFields),

                        // Confirm Password Input
                        Obx(() => _buildTextField(
                          controller: _confirmPassCtrl,
                          hint: 'Password Confirmation'.tr,
                          icon: Icons.lock_outline,
                          isSmall: isSmall,
                          isPassword: true,
                          obscureText: controller.obscureConfirmPassword.value,
                          onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                          onChanged: (v) => controller.confirmPassword.value = v,
                        )),
                        
                        SizedBox(height: height * 0.05),

                        // Buttons
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: isSmall ? 50 : 56,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: greenColor.withValues(alpha: 0.6),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                : Text(
                                    'Continue'.tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmall ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        )),
                        
                        const SizedBox(height: 20),
                        
                        // Sign In link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: isSmall ? 13 : 14,
                                color: hintText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed(Routes.LOGIN),
                              child: Text(
                                'Sign In'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 13 : 14,
                                  color: greenColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isSmall,
    required Function(String) onChanged,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    const darkText = Color(0xFF0F3B52);
    const hintText = Color(0xFF9BA5B1);
    const borderColor = Color(0xFFE0E6ED);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        border: Border.all(
          color: borderColor,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(fontSize: isSmall ? 14 : 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: darkText),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: hintText,
            fontSize: isSmall ? 13 : 15,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmall ? 14 : 18,
            horizontal: 20,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: hintText,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
