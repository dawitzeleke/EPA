import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bottom_nav_controller.dart';
import '../nav_items.dart';

class BottomNavBarFooter extends StatelessWidget {
  const BottomNavBarFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BottomNavController>();

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: bottomNavActiveColor,
        borderRadius: BorderRadius.only(
          // topLeft: Radius.circular(16),
          // topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          bottomNavItems.length,
          (index) => Expanded(
            child: _BottomNavItemButton(
              index: index,
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemButton extends StatelessWidget {
  final int index;
  final BottomNavController controller;

  const _BottomNavItemButton({
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final data = bottomNavItems[index];

    return Obx(() {
      final isSelected = controller.currentIndex.value == index;

      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => controller.changePage(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                
                child: Image.asset(
                  'assets/navbarIcons/${data.icon}',
                  color: isSelected ?  bottomNavInactiveColor : AppColors.onPrimary,
                  width: isSelected ? 22 : 24,
                  height: isSelected ? 22 : 24,
                )
              ),
              const SizedBox(height: 4),
              Text(
                data.label.tr,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? bottomNavInactiveColor : AppColors.onPrimary,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

