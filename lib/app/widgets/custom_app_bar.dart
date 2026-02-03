import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/app/routes/app_pages.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final double height;
  final bool showBack;
  final bool forceHomeOnBack;
  final bool showHelp;
  final String? helpRoute;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 64,
    this.showBack = true,
    this.forceHomeOnBack = false,
    this.showHelp = false,
    this.helpRoute,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBack)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
                    onPressed: () {
                      if (forceHomeOnBack && Get.isRegistered<BottomNavController>()) {
                        Get.find<BottomNavController>().resetToHome();
                        final navigator = Navigator.of(context);
                        navigator.popUntil((route) => route.settings.name == null || route.settings.name == Routes.HOME || route.isFirst);
                        return;
                      }

                      // Try Flutter Navigator first (for nested navigators in bottom nav)
                      final navigator = Navigator.of(context);
                      if (navigator.canPop()) {
                        navigator.pop();
                        return;
                      }

                      // Try GetX navigation (for routes navigated via GetX)
                      // Get.back() will handle errors gracefully, so we can call it directly
                      if (Get.key.currentState?.canPop() ?? false) {
                        Get.back();
                        return;
                      }

                      // Last resort: try Get.back() anyway (it might work)
                      try {
                        Get.back();
                      } catch (_) {
                        // If Get.back() fails, try to go to home
                        if (Get.isRegistered<BottomNavController>()) {
                          Get.find<BottomNavController>().resetToHome();
                        }
                      }
                    },
                  ),

                const SizedBox(width: 4),

                // Title area with optional inline help icon (keeps icon next to title)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          ],
                        ),
                      ),

                      if (showHelp)
                        IconButton(
                          icon: const Icon(Icons.help_outlined, color: AppColors.onPrimary),
                          onPressed: () {
                            if (helpRoute != null) {
                              Get.toNamed(helpRoute!);
                              return;
                            }
                            // default help destination: FAQ, fallback to Contact Us
                            try {
                              Get.toNamed(Routes.FAQ);
                              return;
                            } catch (_) {
                              Get.toNamed(Routes.CONTACT_US);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
