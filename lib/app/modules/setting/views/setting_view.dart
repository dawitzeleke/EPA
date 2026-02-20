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
                              const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: nameController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter your name',
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
                                        'Cancel',
                                        style: TextStyle(
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
                                        final newName = nameController.text.trim();
                                        if (newName.isEmpty) {
                                          Get.snackbar(
                                            'Name required',
                                            'Please enter a valid name to continue.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }

                                        try {
                                          await controller.updateUserName(newName);
                                          Get.back();
                                          Get.snackbar(
                                            'Profile updated',
                                            'Your name has been saved.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            'Update failed',
                                            e.toString().replaceFirst('Exception: ', ''),
                                            snackPosition: SnackPosition.BOTTOM,
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
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
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
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'edit_profile',
                      style: TextStyle(
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
                              const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Current Password',
                                style: TextStyle(
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
                                  hintText: 'Enter current password',
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
                              const Text(
                                'New Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: newController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter new password',
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
                              const Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: confirmController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Confirm new password',
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
                                        'Cancel',
                                        style: TextStyle(
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
                                          Get.snackbar(
                                            'Password required',
                                            'All password fields are required.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }

                                        if (newPwd != confirmPwd) {
                                          Get.snackbar(
                                            'Mismatch',
                                            'New password and confirmation must match.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }

                                        try {
                                          await controller.updatePassword(
                                            currentPwd,
                                            newPwd,
                                            confirmPwd,
                                          );
                                          Get.back();
                                          Get.snackbar(
                                            'Password updated',
                                            'Your password has been changed successfully.',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            'Update failed',
                                            e.toString().replaceFirst('Exception: ', ''),
                                            snackPosition: SnackPosition.BOTTOM,
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
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
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
                      'update_password',
                      style: TextStyle(
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
        title: const Text('Guest',
            style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to login
          Get.toNamed(Routes.LOGIN);
        },
      ),
    );
  }

  // ── Build UI ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Refresh user data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshUserData();
    });

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Settings',
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
                      _buildOptionTile(Icons.language, 'Language',
                          () => Get.toNamed(Routes.LANGUAGE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.help_outline,
                          'FAQ', () => Get.toNamed(Routes.FAQ)),
                      _buildDivider(),
                      _buildOptionTile(Icons.local_post_office, 'Office',
                          () => Get.toNamed(Routes.OFFICE)),
                      _buildDivider(),
                      _buildOptionTile(Icons.privacy_tip_outlined, 'Privacy Policy',
                          () => Get.toNamed(Routes.Privacy_Policy)),
                      _buildDivider(),
                      _buildOptionTile(Icons.description_outlined,
                          'Term and Conditions', () => Get.toNamed(Routes.TERM_AND_CONDITIONS)),
                      _buildDivider(),
                      _buildOptionTile(Icons.info_outline, 'About EPA App',
                          () => Get.toNamed(Routes.ABOUT)),
                      _buildDivider(),
                      _buildOptionTile(Icons.star_rate_outlined, 'Rate Us', () {}),
                      _buildDivider(),
                      
                      _buildOptionTile(Icons.logout, "Logout", () {
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
                                'Are you sure you want to logout?',
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
                                        'Cancel',
                                        style: TextStyle(
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
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(
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
