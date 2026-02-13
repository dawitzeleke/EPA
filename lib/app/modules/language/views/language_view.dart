import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';



class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Language'.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: controller.availableLanguages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final option = controller.availableLanguages[index];
                return Obx(() {
                  final selected = controller.isSelected(option.locale);
                  return ListTile(
                    title: Text(option.key.tr),
                    trailing: selected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      controller.changeLocale(option.locale);
                      Get.back();
                    },
                  );
                });
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          Get.isRegistered<BottomNavController>() ? const BottomNavBarFooter() : null,
    );
  }
}
