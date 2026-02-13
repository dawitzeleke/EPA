import 'package:eprs/app/modules/language/controllers/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSelector extends StatelessWidget {
  final double? fontSize;
  final double? iconSize;
  final Color? color;
  final bool usePoppins;

  const LanguageSelector({
    super.key,
    this.fontSize,
    this.iconSize,
    this.color,
    this.usePoppins = true,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController(), permanent: true);

    void showLanguageSheet() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Language'.tr,
                      style: usePoppins
                          ? GoogleFonts.poppins(
                              fontSize: fontSize ?? 14,
                              fontWeight: FontWeight.w600,
                            )
                          : TextStyle(
                              fontSize: fontSize ?? 14,
                              fontWeight: FontWeight.w600,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...languageController.availableLanguages.map((option) {
                  final selected = languageController.isSelected(option.locale);
                  return ListTile(
                    title: Text(option.key.tr),
                    trailing:
                        selected ? const Icon(Icons.check, color: Colors.green) : null,
                    onTap: () {
                      languageController.changeLocale(option.locale);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    }

    return InkWell(
      onTap: showLanguageSheet,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => Text(
                languageController.currentLabel,
                style: usePoppins
                    ? GoogleFonts.poppins(
                        fontSize: fontSize ?? 12,
                        color: color ?? Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      )
                    : TextStyle(
                        fontSize: fontSize ?? 12,
                        color: color ?? Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
              )),
          const SizedBox(width: 6),
          Icon(
            Icons.language,
            color: color ?? Colors.grey.shade700,
            size: iconSize ?? 18,
          ),
        ],
      ),
    );
  }
}
