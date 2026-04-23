import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/core/theme/app_fonts.dart';
import '../../../widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../bottom_nav/controllers/bottom_nav_controller.dart';
import '../controllers/setting_controller.dart';
import 'package:eprs/app/routes/app_pages.dart';

class SettingView extends GetView<SettingController> {
  const SettingView({super.key});

  // ── Helper for option tiles ────────────────────────────────────────────────
  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          // borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }

  void _showSuccessMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  void _closeDialog(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Build user profile section (when logged in)
  Widget _buildUserProfileSection(BuildContext context) {
    return Column(
      children: [
        // Profile picture
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              controller.userName.value.isNotEmpty
                  ? controller.userName.value[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // User name
        Obx(() => Text(
          controller.userName.value,
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        )),
        const SizedBox(height: 6),
        
        // Phone number
        Obx(() => Text(
          controller.phoneNumber.value.isNotEmpty 
              ? controller.phoneNumber.value 
              : 'No phone number',
          style: TextStyle(
            fontFamily: AppFonts.primaryFont,
            fontSize: 13,
            color: Colors.grey[600],
          ),
        )),
        const SizedBox(height: 16),
        
        // Edit profile & change password buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: () {
                  final nameController =
                      TextEditingController(text: controller.userName.value);

                  final size = MediaQuery.of(context).size;
                  final maxDialogHeight =
                      (size.height * 0.55).clamp(280.0, 520.0);
                  final maxDialogWidth =
                      (size.width * 0.9).clamp(260.0, 520.0);
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.white,
                      insetPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxDialogHeight,
                          maxWidth: maxDialogWidth,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Profile'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Name'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nameController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter your name'.tr,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(closeOverlays: true),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel'.tr,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Obx(() {
                                      final isUpdating = controller.isUpdating.value;
                                      return ElevatedButton(
                                        onPressed: isUpdating
                                            ? null
                                            : () async {
                                                final newName =
                                                    nameController.text.trim();
                                                if (newName.isEmpty) {
                                                  _showErrorMessage(
                                                    context,
                                                    'Please enter a valid name to continue.'.tr,
                                                  );
                                                  return;
                                                }

                                                try {
                                                  final scaffoldContext = Get.context ?? context;
                                                  await controller.updateUserName(
                                                    newName,
                                                  );
                                                  _closeDialog(context);
                                                  await Future<void>.delayed(
                                                    const Duration(milliseconds: 120),
                                                  );
                                                  _showSuccessMessage(
                                                    scaffoldContext,
                                                    'Your name was updated successfully.'.tr,
                                                  );
                                                } catch (e) {
                                                  _showErrorMessage(
                                                    context,
                                                    e.toString().replaceFirst(
                                                      'Exception: ',
                                                      '',
                                                    ),
                                                  );
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: isUpdating
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  'Save'.tr,
                                                  key: const ValueKey('save'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: true,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Edit Profile'.tr,
                      style: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: OutlinedButton(
                onPressed: () {
                  final currentController = TextEditingController();
                  final newController = TextEditingController();
                  final confirmController = TextEditingController();

                  final size = MediaQuery.of(context).size;
                  final maxDialogHeight =
                      (size.height * 0.55).clamp(300.0, 560.0);
                  final maxDialogWidth =
                      (size.width * 0.9).clamp(260.0, 520.0);
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.white,
                      insetPadding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: maxDialogHeight,
                          maxWidth: maxDialogWidth,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Password'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Current Password'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: currentController,
                                autofocus: true,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter current password'.tr,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'New Password'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter new password'.tr,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Confirm Password'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: confirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm new password'.tr,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(closeOverlays: true),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel'.tr,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final currentPwd =
                                            currentController.text.trim();
                                        final newPwd = newController.text.trim();
                                        final confirmPwd =
                                            confirmController.text.trim();

                                        if (currentPwd.isEmpty ||
                                            newPwd.isEmpty ||
                                            confirmPwd.isEmpty) {
                                          _showErrorMessage(
                                            context,
                                            'All password fields are required.'.tr,
                                          );
                                          return;
                                        }

                                        if (newPwd != confirmPwd) {
                                          _showErrorMessage(
                                            context,
                                            'New password and confirmation must match.'.tr,
                                          );
                                          return;
                                        }

                                        try {
                                          final scaffoldContext = Get.context ?? context;
                                          await controller.updatePassword(
                                            currentPwd,
                                            newPwd,
                                            confirmPwd,
                                          );
                                          _closeDialog(context);
                                          await Future<void>.delayed(
                                            const Duration(milliseconds: 120),
                                          );
                                          _showSuccessMessage(
                                            scaffoldContext,
                                            'Your password was updated successfully.'.tr,
                                          );
                                        } catch (e) {
                                          _showErrorMessage(
                                            context,
                                            e.toString().replaceFirst('Exception: ', ''),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Save'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: true,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Update Password'.tr,
                      style: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build guest card (when not logged in)
  Widget _buildGuestCard() {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.onPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person_outline, color: Colors.black),
        ),
        title: Text('Guest'.tr,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to login
          Get.toNamed(Routes.LOGIN);
        },
      ),
    );
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    // Refresh user data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshUserData();
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Settings'.tr,
          showBack: true,
          forceHomeOnBack: true, // ensure back always returns to home shell
        ),

      body: SafeArea(
        child:
        //  Padding(
        //   // padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: 
          Column(
            children: [
              const SizedBox(height: 16),
              // User profile section (only if logged in)
              Obx(() {
                if (controller.isLoggedIn.value) {
                  return _buildUserProfileSection(context);
                } else {
                  return _buildGuestCard();
                }
              }),

              const SizedBox(height: 20),

              // Options list
              Flexible(
                fit: FlexFit.loose,
                child: Material(
                  color: Colors.white,
                  // elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildOptionTile(Icons.language, 'Language'.tr,
                          () => Get.toNamed(Routes.LANGUAGE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.help_outline,
                          'FAQ'.tr, () => Get.toNamed(Routes.FAQ)),
                      _buildDivider(),
                      _buildOptionTile(Icons.local_post_office, 'Office'.tr,
                          () => Get.toNamed(Routes.OFFICE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.privacy_tip_outlined, 'Privacy Policy'.tr,
                          () => Get.toNamed(Routes.Privacy_Policy)),
                      _buildDivider(),
                      _buildOptionTile(Icons.description_outlined,
                          'Terms & Conditions'.tr, () => Get.toNamed(Routes.TERM_AND_CONDITIONS)),
                      _buildDivider(),
                      _buildOptionTile(Icons.info_outline, 'About EPA App'.tr,
                          () => Get.toNamed(Routes.ABOUT)),
                      _buildDivider(),
                      _buildOptionTile(Icons.star_rate_outlined, 'Rate Us'.tr, () {
                        // Open app page on store (placeholder link)
                        const url = 'https://play.google.com/store/apps/details?id=et.aii.eprs';
                        // controller.launchURL(url);
                      }),
                      _buildDivider(),
                      
                      _buildOptionTile(Icons.logout, "Logout".tr, () {
                        // Confirm logout
                        Get.defaultDialog(
                          title: '',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.white,
                          radius: 12,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Are you sure you want to logout?'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: AppColors.primary),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel'.tr,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Reset bottom nav to home tab if controller exists
                                        if (Get.isRegistered<BottomNavController>()) {
                                          try {
                                            final navCtrl = Get.find<BottomNavController>();
                                            navCtrl.resetToHome();
                                          } catch (_) {}
                                        }

                                        // Clear stored data and navigate to splash/login
                                        final box = Get.find<GetStorage>();
                                        await box.erase();

                                        // After clearing storage, navigate to splash screen
                                        Get.offAllNamed(Routes.SPLASH);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'Yes'.tr,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        // ),
      ),
      // BottomNavBar is provided by the top-level shell; remove 
    );
  }
}
