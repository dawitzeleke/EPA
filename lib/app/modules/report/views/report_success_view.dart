import 'package:eprs/app/modules/report/controllers/report_controller.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ReportSuccessView extends StatelessWidget {
  ReportController get controller => Get.find<ReportController>();
  final String reportId;
  final DateTime? dateTime;
  final String? region;
  // final String 
  const ReportSuccessView({super.key, required this.reportId, this.dateTime, this.region});

  // Resolve region value: prefer constructor arg, else try route arguments (GetX or Navigator)
  String? _resolveRegion(BuildContext context) {
    if (_isValidRegion(region)) return region;

    // Try GetX arguments
    try {
      final args = Get.arguments;
      final resolved = _extractRegionFromArgs(args);
      if (_isValidRegion(resolved)) return resolved;
    } catch (_) {}

    // Try Navigator/ModalRoute arguments
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final resolved2 = _extractRegionFromArgs(routeArgs);
    if (_isValidRegion(resolved2)) return resolved2;

    return null;
  }

  // Accept Map or String and try common keys
  String? _extractRegionFromArgs(Object? args) {
    if (args is String) return args;
    if (args is Map) {
      const candidates = [
        'region',
        'regionName',
        'selectedRegion',
        'regionOrCity',
        'city',
        'cityName',
        'region_city',
      ];
      for (final key in candidates) {
        final v = args[key];
        if (v is String && _isValidRegion(v)) return v;
      }
    }
    return null;
  }

  bool _isValidRegion(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    const placeholders = [
      'Select Region / City Administration',
      'Select Region',
      'Select Zone / Sub-City',
      'Select Woreda',
    ];
    return !placeholders.contains(trimmed);
  }

  String? _resolveName() {
    try {
      // Prefer controller if available and populated
      if (Get.isRegistered<ReportController>()) {
        final c = Get.find<ReportController>();
        final n = c.name.value.trim();
        if (n.isNotEmpty) return n;
      }
    } catch (_) {}

    // Fallback to storage keys
    try {
      final box = Get.find<GetStorage>();
      final n = (box.read('username')?.toString() ??
              box.read('fullName')?.toString() ??
              box.read('name')?.toString())
          ?.trim();
      if (n != null && n.isNotEmpty) return n;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dt = dateTime ?? DateTime.now();
    final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    final resolvedRegion = _resolveRegion(context);
    final resolvedName = _resolveName();
    final size = MediaQuery.of(context).size;
    final imageWidth = (size.width * 0.7).clamp(180.0, 360.0);
    final imageHeight = imageWidth * 0.6;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: const AssetImage('assets/logo.png'),
                    height: imageHeight,
                    width: imageWidth,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  // large check icon with circular background
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFFAF3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Successfully Sent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B2035),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // info card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8EEF3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                const Text(
                                  'Report ID:',
                                  style: TextStyle(color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 12),
                                if (resolvedName != null)
                                  const Text('Name', style: TextStyle(color: Color(0xFF6B7280))),
                                if (resolvedName != null) const SizedBox(height: 12),
                                const Text(
                                  'Date & Time:',
                                  style: TextStyle(color: Color(0xFF6B7280)),
                                ),
                                if (resolvedRegion != null) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Region:',
                                    style: TextStyle(color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    reportId,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Color(0xFF0B2035),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (resolvedName != null)
                                    Text(
                                      resolvedName,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Color(0xFF0B2035),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (resolvedName != null) const SizedBox(height: 12),
                                  Text(
                                    formatted,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Color(0xFF0B2035),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (resolvedRegion != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      resolvedRegion,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Color(0xFF0B2035),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed(Routes.HOME);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
