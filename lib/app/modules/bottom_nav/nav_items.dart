import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom navigation uses PNG assets. Place PNG files under
/// `assets/navbarIcons/` (for example `home.png`, `office.png`, ...)
/// and add the folder to `pubspec.yaml` under `flutter.assets:`.
class BottomNavItemData {
  /// Asset filename (without the `assets/navbarIcons/` prefix).
  final String icon;
  final String label;

  const BottomNavItemData({
    required this.icon,
    required this.label,
  });
}

const Color bottomNavActiveColor = AppColors.primary;
const Color bottomNavInactiveColor = Color(0xFFA0E4FF);

const List<BottomNavItemData> bottomNavItems = [
  BottomNavItemData(icon: 'home.png', label: 'Home'),
  // BottomNavItemData(icon: 'office.png', label: 'Office'),
  BottomNavItemData(icon: 'awareness.png', label: 'Awareness'),
  BottomNavItemData(icon: 'status.png', label: 'Status'),
  BottomNavItemData(icon: 'profile.png', label: 'Settings'),
];

