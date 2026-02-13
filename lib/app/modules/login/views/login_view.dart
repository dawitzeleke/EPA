import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eprs/app/modules/status/controllers/status_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/login_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/login_usecase.dart';

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({super.key});

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _reportIdCtrl = TextEditingController();
  bool _remember = false;
  final bool _isSearching = false;

  @override
  void dispose() {    
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _reportIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(loginUseCase: Get.find<LoginUseCase>()));

    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    final args = Get.arguments;
    final isFirstLogin = args is Map && args['firstTimeLogin'] == true;
    final welcomeTitle = isFirstLogin ? 'Welcome'.tr : 'Welcome Back'.tr;
    
    // Responsive calculations
    final isSmall = height < 700;
    final logoHeight = height * 0.22; // 22% of screen height
    final topPadding = MediaQuery.of(context).padding.top + (height * 0.01);
    final betweenFields = height * 0.02; // 2% of screen height
    
    const greenColor = AppColors.primary;
    const blueColor = Color(0xFF0047BA);
    const darkText = Color(0xFF0F3B52);
    const hintText = Color(0xFF9BA5B1);
    const borderColor = Color(0xFFE0E6ED);

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
                horizontal: width * 0.05, // 5% horizontal padding
                vertical: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top right language
                  Align(
                    alignment: Alignment.topRight,
                    child: LanguageSelector(
                      fontSize: isSmall ? 12 : 13,
                      iconSize: isSmall ? 16 : 18,
                    ),
                  ),

                  SizedBox(height: height * 0.02),

                  // Title
                  
                  Text(
                    welcomeTitle,
                    style: GoogleFonts.poppins(
                      fontSize: isSmall ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),

                  SizedBox(height: height * 0.04),

                  // Inputs and actions
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        // Phone field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            border: Border.all(
                              color: borderColor,
                              width: 1.2,
                            ),
                          ),
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(
                              fontSize: isSmall ? 14 : 15,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                                color: darkText,
                              ),
                              hintText: 'Phone Number'.tr,
                              hintStyle: GoogleFonts.poppins(
                                color: hintText,
                                fontSize: isSmall ? 13 : 15,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmall ? 14 : 18,
                                horizontal: 20,
                              ),
                            ),
                            onChanged: (v) =>
                                controller.phoneNumber.value = v,
                          ),
                        ),

                        SizedBox(height: betweenFields),

                        // Password
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                            border: Border.all(
                              color: borderColor,
                              width: 1.2,
                            ),
                          ),
                          child: Obx(() => TextField(
                            controller: _passCtrl,
                            obscureText: controller.obscurePassword.value,
                            style: GoogleFonts.poppins(
                              fontSize: isSmall ? 14 : 15,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: darkText,
                              ),
                              hintText: 'Password'.tr,
                              hintStyle: GoogleFonts.poppins(
                                color: hintText,
                                fontSize: isSmall ? 13 : 15,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmall ? 14 : 18,
                                horizontal: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: hintText,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                            onChanged: (v) => controller.password.value = v,
                          )),
                        ),

                        SizedBox(height: betweenFields),

                        // Remember + Forgot
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _remember = !_remember),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: isSmall ? 18 : 20,
                                      height: isSmall ? 18 : 20,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: hintText,
                                          width: 1.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          4,
                                        ),
                                        color: _remember
                                            ? greenColor
                                            : Colors.transparent,
                                      ),
                                      child: _remember
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Remember Me'.tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmall ? 13 : 14,
                                          color: darkText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password'.tr,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 13 : 14,
                                  color: blueColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: height * 0.05),

                        // Buttons
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: isSmall ? 50 : 56,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.submitLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: controller.isLoading.value
                                    ? SizedBox(
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
                                        'Sign In'.tr,
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmall ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            )),

                        SizedBox(height: 12),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              final box = Get.find<GetStorage>();
                              box.write('username', 'Guest');
                              box.remove('userId');
                              box.remove('phone');

                              Get.offNamed(
                                Routes.HOME,
                                arguments: {
                                  'username': 'Guest',
                                  'phone': '',
                                  'email': '',
                                },
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Continue as Guest'.tr,
                              style: GoogleFonts.poppins(
                                fontSize: isSmall ? 14 : 15,
                                fontWeight: FontWeight.w600,
                                color: hintText,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        RichText(
                          text: TextSpan(
                            text: "Don't have an account?".tr,
                            style: GoogleFonts.poppins(
                              fontSize: isSmall ? 14 : 15,
                              color: hintText,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14 : 15,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: (TapGestureRecognizer()
                                  ..onTap = () => Get.toNamed(Routes.SIGNUP)),
                              ),
                            ],
                          ),
                        ),
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
  
  void _showStatusDialog(BuildContext context, ReportItem item) {
    final currentStatus = item.status;
    final currentTime = (item.time ?? '').trim();
    final currentLine = currentTime.isNotEmpty ? '$currentStatus • $currentTime' : currentStatus;

    final logs = item.activityLogs ?? [];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complaint Status'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF103B52),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status history timeline'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF5C6B7A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${'Current:'.tr} ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF5C6B7A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        currentLine,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF1EAD3D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ..._buildStatusCards(item, logs),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F8A4E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }

  List<Widget> _buildStatusCards(ReportItem item, List<ActivityLog> logs) {
    final entries = <_StatusEntry>[];

    entries.add(_StatusEntry(
      title: item.status,
      date: item.date,
      time: item.time ?? '',
      isCurrent: true,
    ));

    for (final log in logs) {
      entries.add(_StatusEntry(
        title: log.newStatus ?? log.description ?? 'Status Update',
        date: _formatLogDate(log.createdAt),
        time: _formatLogTime(log.createdAt),
        isCurrent: false,
      ));
    }

    return entries.map((e) {
      final bg = e.isCurrent ? const Color(0xFFE8F8EE) : const Color(0xFFE9F0FF);
      final iconBg = e.isCurrent ? const Color(0xFF2F8A4E) : const Color(0xFF3F79E0);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                e.isCurrent ? Icons.check : Icons.radio_button_unchecked,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF103B52),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${e.date}${e.time.isNotEmpty ? ' • ${e.time}' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF5C6B7A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatLogDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return '${_month(parsed.month)} ${parsed.day}, ${parsed.year}';
    }
    return raw;
  }

  String _formatLogTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      final hh = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
      final mm = parsed.minute.toString().padLeft(2, '0');
      final ss = parsed.second.toString().padLeft(2, '0');
      final ampm = parsed.hour >= 12 ? 'PM' : 'AM';
      return '$hh:$mm:$ss $ampm';
    }
    return '';
  }

  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[(m - 1).clamp(0, 11)];
  }
}

class _StatusEntry {
  final String title;
  final String date;
  final String time;
  final bool isCurrent;

  _StatusEntry({required this.title, required this.date, required this.time, required this.isCurrent});
}
