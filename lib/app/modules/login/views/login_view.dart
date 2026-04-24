import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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
  bool _isSearching = false;

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
    final welcomeTitle = 'Welcome'.tr;

    // Responsive calculations
    final isSmall = height < 700;
    final logoHeight = height * 0.22; // 22% of screen height
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
                  Image.asset(
                    'assets/logo.png',
                    height: logoHeight,
                  ),

                  // Track Report Status card
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isSmall ? 10 : 12),
                      margin: EdgeInsets.only(top: height * 0.01),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Track Report Status'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: isSmall ? 10 : 12,
                              fontWeight: FontWeight.w600,
                              color: darkText,
                            ),
                          ),
                          SizedBox(height: isSmall ? 8 : 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _reportIdCtrl,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmall ? 12 : 13,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter Report ID'.tr,
                                      hintStyle: TextStyle(
                                        fontSize: isSmall ? 10 : 11,
                                        color: hintText,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: isSmall ? 5 : 9,
                                        horizontal: 12,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: borderColor,
                                          width: 1.1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: greenColor,
                                          width: 1.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isSearching
                                      ? null
                                      : () async {
                                          final id = _reportIdCtrl.text.trim();
                                          if (id.isEmpty) {
                                            Get.snackbar(
                                              'Report ID'.tr,
                                              'Please enter a Report ID'.tr,
                                              snackPosition: SnackPosition.BOTTOM,
                                            );
                                            return;
                                          }
                                          setState(() => _isSearching = true);
                                          final statusController =
                                              Get.isRegistered<StatusController>()
                                                  ? Get.find<StatusController>()
                                                  : Get.put(StatusController());
                                          final result = await statusController
                                              .fetchComplaintByReportId(id);
                                          if (!mounted) return;
                                          setState(() => _isSearching = false);
                                          if (result == null) {
                                            Get.snackbar(
                                              'Not found'.tr,
                                              '${'No complaint found for'.tr} $id',
                                              snackPosition: SnackPosition.BOTTOM,
                                            );
                                            return;
                                          }

                                          _showStatusDialog(context, result);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isSmall ? 12 : 16,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    _isSearching ? '...' : 'Search'.tr,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmall ? 11 : 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.04),

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
                    constraints: const BoxConstraints(maxWidth: 600),
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
                            onChanged: (v) => controller.phoneNumber.value = v,
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
                                    onPressed:
                                        controller.togglePasswordVisibility,
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
                                        borderRadius: BorderRadius.circular(4),
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
                                    const SizedBox(width: 8),
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
                                  disabledBackgroundColor:
                                      AppColors.primary.withValues(alpha: 0.6),
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
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
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

                        const SizedBox(height: 12),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              final box = Get.find<GetStorage>();
                              box.write('username', 'Guest');
                              box.remove('userId');
                              box.remove('phone');
                              // Ensure guest flow does not reuse a previous authenticated session
                              box.remove('auth_token');
                              box.remove('access_token');
                              box.remove('token');
                              box.remove('refresh_token');

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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
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
    final logs = List<ActivityLog>.from(item.activityLogs ?? []);
    final currentStatusLabel = _formatStatusLabel(item.status);
    final submittedLabel = _formatSubmittedDate(item.createdAt, item.date);
    final trackingId = (item.reportId ?? item.id ?? item.title).trim().isEmpty
        ? 'N/A'
        : (item.reportId ?? item.id ?? item.title);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 20,
            vertical: isMobile ? 12 : 20,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isMobile ? screenWidth - 20 : 760,
              maxHeight: isMobile ? screenHeight * 0.92 : 760,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 14 : 24,
                    isMobile ? 14 : 24,
                    isMobile ? 10 : 18,
                    isMobile ? 12 : 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E9C71),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Request Status Timeline'.tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: isMobile ? 24 : 28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      Text(
                        '${'Tracking ID:'.tr} $trackingId',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isMobile ? 10 : 16),
                      if (isMobile)
                        Column(
                          children: [
                            _buildTopInfoCard(
                              title: 'Submitted'.tr,
                              value: submittedLabel,
                              icon: Icons.event_note_outlined,
                              isMobile: true,
                            ),
                            const SizedBox(height: 10),
                            _buildTopInfoCard(
                              title: 'Current Status'.tr,
                              value: currentStatusLabel,
                              icon: _statusIcon(item.status),
                              isMobile: true,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: _buildTopInfoCard(
                                title: 'Submitted'.tr,
                                value: submittedLabel,
                                icon: Icons.event_note_outlined,
                                isMobile: false,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildTopInfoCard(
                                title: 'Current Status'.tr,
                                value: currentStatusLabel,
                                icon: _statusIcon(item.status),
                                isMobile: false,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 10 : 24,
                      isMobile ? 10 : 16,
                      isMobile ? 10 : 24,
                      isMobile ? 6 : 10,
                    ),
                    color: const Color(0xFFF6F8FA),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _buildStatusCards(item, logs, isMobile: isMobile),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 22,
                    isMobile ? 10 : 14,
                    isMobile ? 12 : 22,
                    isMobile ? 12 : 22,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined,
                                    color: Color(0xFF45866E), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Secure Tracking Portal'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF62707D),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(text: trackingId));
                                      if (!context.mounted) return;
                                      Get.snackbar(
                                        'Copied'.tr,
                                        'Tracking ID copied'.tr,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFDFE5EA)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    child: Text(
                                      'Copy ID'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF556270),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2F8A4E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    child: Text(
                                      'Done'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, color: Color(0xFF45866E), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Secure Tracking Portal'.tr,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: const Color(0xFF62707D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: trackingId));
                                if (!context.mounted) return;
                                Get.snackbar(
                                  'Copied'.tr,
                                  'Tracking ID copied'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFDFE5EA)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              ),
                              child: Text(
                                'Copy ID'.tr,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF556270),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F8A4E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                              ),
                              child: Text(
                                'Done'.tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

    Widget _buildTopInfoCard({required String title, required String value, required IconData icon, required bool isMobile}) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 14,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 6),
            Row(
              children: [
                Icon(icon, color: Colors.white, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    List<_StatusEntry> _buildTimelineEntries(ReportItem item, List<ActivityLog> logs) {
      final entries = <_StatusEntry>[];
      final seenKeys = <String>{};

      final sorted = List<ActivityLog>.from(logs)
        ..sort((a, b) {
          final aMs = DateTime.tryParse(a.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
          final bMs = DateTime.tryParse(b.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
          return aMs.compareTo(bMs);
        });

      for (final log in sorted) {
        final raw = (log.newStatus ?? '').trim();
        if (raw.isEmpty) continue;
        final key = _normalizeStatus(raw);
        if (seenKeys.contains(key)) continue;
        seenKeys.add(key);
        final label = _formatStatusLabel(raw);
        final timeLabel = _formatLogDateTime(log.createdAt);
        entries.add(_StatusEntry(
          title: label,
          dateTime: timeLabel,
          key: key,
          isCurrent: false,
        ));
      }

      final currentKey = _normalizeStatus(item.status);

      if (entries.isEmpty) {
        entries.add(_StatusEntry(
          title: _formatStatusLabel(item.status),
          dateTime: _buildDateTimeLine(item.date, item.time),
          key: currentKey,
          isCurrent: true,
        ));
        return entries;
      }

      var currentIndex = -1;
      for (var i = entries.length - 1; i >= 0; i--) {
        if (entries[i].key == currentKey) {
          currentIndex = i;
          break;
        }
      }

      if (currentIndex == -1) {
        entries.add(_StatusEntry(
          title: _formatStatusLabel(item.status),
          dateTime: _buildDateTimeLine(item.date, item.time),
          key: currentKey,
          isCurrent: true,
        ));
      } else {
        entries[currentIndex] = _StatusEntry(
          title: entries[currentIndex].title,
          dateTime: entries[currentIndex].dateTime,
          key: entries[currentIndex].key,
          isCurrent: true,
        );
      }

      return entries;
    }

    List<Widget> _buildStatusCards(ReportItem item, List<ActivityLog> logs, {required bool isMobile}) {
      final entries = _buildTimelineEntries(item, logs);

      return List.generate(entries.length, (index) {
        final e = entries[index];
        final visual = _statusVisual(e.key);
        final isLast = index == entries.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isMobile ? 34 : 42,
              child: Column(
                children: [
                  Container(
                    width: isMobile ? 28 : 34,
                    height: isMobile ? 28 : 34,
                    decoration: BoxDecoration(
                      color: e.isCurrent ? const Color(0xFF17B58E) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD2D8DE),
                        width: isMobile ? 1.5 : 2,
                      ),
                    ),
                    child: Icon(
                      _statusIcon(e.key),
                      color: e.isCurrent ? Colors.white : const Color(0xFF92A1AF),
                      size: isMobile ? 16 : 19,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: isMobile ? 54 : 58,
                      color: const Color(0xFFD5DCE3),
                    ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 14,
                  vertical: isMobile ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5EAF0)),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: visual.chipBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              e.title,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: visual.chipText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.dateTime,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF5B6C7C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: visual.chipBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              e.title,
                              style: GoogleFonts.poppins(
                                color: visual.chipText,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              e.dateTime,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF5B6C7C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      });
    }

    String _normalizeStatus(String raw) {
      final normalized = raw.trim().toLowerCase().replaceAll('_', ' ').replaceAll(RegExp(r'\s+'), ' ');
      if (normalized == 'complete' || normalized == 'completed') return 'closed';
      return normalized;
    }

    String _formatStatusLabel(String raw) {
      final key = _normalizeStatus(raw);
      switch (key) {
        case 'under review':
          return 'Under Review';
        case 'under investigation':
          return 'Under Investigation';
        case 'verified':
          return 'Verified';
        case 'closed':
          return 'Closed';
        case 'rejected':
          return 'Rejected';
        case 'pending':
          return 'Pending';
        default:
          return key
              .split(' ')
              .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' ');
      }
    }

    IconData _statusIcon(String raw) {
      final key = _normalizeStatus(raw);
      switch (key) {
        case 'under review':
          return Icons.schedule_rounded;
        case 'verified':
          return Icons.check_circle_outline;
        case 'under investigation':
          return Icons.shield_outlined;
        case 'closed':
          return Icons.assignment_turned_in_outlined;
        case 'rejected':
          return Icons.cancel_outlined;
        default:
          return Icons.radio_button_unchecked;
      }
    }

    _StatusVisual _statusVisual(String key) {
      switch (_normalizeStatus(key)) {
        case 'under review':
          return const _StatusVisual(chipBg: Color(0xFFDCE8FF), chipText: Color(0xFF2D59C1));
        case 'verified':
          return const _StatusVisual(chipBg: Color(0xFFD8F3E5), chipText: Color(0xFF10784A));
        case 'under investigation':
          return const _StatusVisual(chipBg: Color(0xFFECDDFA), chipText: Color(0xFF7B3EB5));
        case 'closed':
          return const _StatusVisual(chipBg: Color(0xFFE8EEF4), chipText: Color(0xFF203040));
        case 'rejected':
          return const _StatusVisual(chipBg: Color(0xFFFADDDD), chipText: Color(0xFF9E2E2E));
        default:
          return const _StatusVisual(chipBg: Color(0xFFF0F2F5), chipText: Color(0xFF516171));
      }
    }

    String _formatLogDateTime(String? raw) {
      if (raw == null || raw.trim().isEmpty) return '';
      final parsed = DateTime.tryParse(raw.trim());
      if (parsed == null) return raw;
      final dt = parsed.toLocal();
      final hh = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mm = dt.minute.toString().padLeft(2, '0');
      final ss = dt.second.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.month}/${dt.day}/${dt.year}, $hh:$mm:$ss $ampm';
    }

    String _buildDateTimeLine(String date, String? time) {
      final t = (time ?? '').trim();
      if (date.trim().isEmpty) return t;
      if (t.isEmpty) return date;
      return '$date, $t';
    }

    String _formatSubmittedDate(String? rawCreatedAt, String fallbackDate) {
      final parsed = rawCreatedAt == null ? null : DateTime.tryParse(rawCreatedAt);
      if (parsed != null) {
        final dt = parsed.toLocal();
        return '${dt.month}/${dt.day}/${dt.year}';
      }
      return fallbackDate;
    }

  }

  class _StatusVisual {
    final Color chipBg;
    final Color chipText;

    const _StatusVisual({required this.chipBg, required this.chipText});
  }

  class _StatusEntry {
    final String title;
    final String dateTime;
    final String key;
    final bool isCurrent;

    _StatusEntry({required this.title, required this.dateTime, required this.key, required this.isCurrent});
  }
