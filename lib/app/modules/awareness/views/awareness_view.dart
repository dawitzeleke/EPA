import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/data/models/awareness_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/awareness_controller.dart';
// BottomNavBar provided by app shell; do not include here to prevent recursion.

class AwarenessView extends GetView<AwarenessController> {
  const AwarenessView({super.key});
  
  /// Build network image with fallback URL patterns
  Widget _buildNetworkImageWithFallback(
    String primaryUrl,
    AwarenessModel awareness, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    // For now, just use the primary URL
    // If it fails, we'll need to check with backend team about the correct route
    return Image.network(
      primaryUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (c, e, s) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: (height ?? width ?? 80) * 0.25,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    final isLandscape = width > height;
    final shortestSide = size.shortestSide;

    double clampDouble(double value, double min, double max) {
      if (value < min) return min;
      if (value > max) return max;
      return value;
    }

    // Scale factors driven by media query for smoother responsiveness across phones
    final scale = clampDouble(shortestSide / 400, 0.85, 1.3);
    
    // Responsive dimensions
    // Banner height tuned to match 16:9-ish imagery so cover fit doesn't over-zoom or letterbox
    final bannerHeight = clampDouble(
      width / (16 / 9),
      isLandscape ? 240 : 280,
      isLandscape ? 460 : 540,
    );
    final horizontalPadding = clampDouble(
      (isTablet ? 28 : 18) * scale,
      14,
      32,
    );
    final titleFontSize = clampDouble(
      (isTablet ? 16 : 12) * scale,
      11,
      18,
    );
    final descFontSize = clampDouble(
      (isTablet ? 13 : 11) * scale,
      10,
      16,
    );
    final headerTitleSize = clampDouble(
      (isTablet ? 22 : 16) * scale,
      14,
      26,
    );
    final backIconSize = clampDouble(
      (isTablet ? 28 : 23) * scale,
      20,
      34,
    );

    // Non-overlapping layout: banner then card below it
    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      body: SafeArea(
        // Make the whole page scrollable so the banner, cards and list
        // can all fit on smaller devices without overflow.
        child: RefreshIndicator(
          onRefresh: () => controller.loadAwareness(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner (no overlap)
              SizedBox(
                height: bannerHeight,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFFEFF4F0),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/awareness.png',
                          // Use contain to keep the full image visible without cropping.
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (c, e, s) =>
                              Container(color: Colors.grey[300]),
                        ),
                      ),
                    ),
                    // green gradient at bottom of banner for visual match
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: bannerHeight * 0.3, // Dynamic gradient height
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF10A94E), Color(0x0010A94E)],
                          ),
                        ),
                      ),
                    ),
                    // back arrow + title at bottom-left of banner
                    Positioned(
                      left: isTablet ? 24 : 12,
                      bottom: isTablet ? 32 : 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () { 
                              Get.find<BottomNavController>().resetToHome();
                              },
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.onPrimary,
                              size: backIconSize,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Awareness'.tr,
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: headerTitleSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List of awareness items recreated as a Column so it participates in
              // the outer SingleChildScrollView (avoids nested scrollables).
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.loadAwareness(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.awarenessList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No awareness items available',
                        style: TextStyle(
                          color: Color(0xFF5D5A6B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
                  child: Column(
                    children: List.generate(controller.awarenessList.length, (i) {
                      final awareness = controller.awarenessList[i];
                      final imageUrl = controller.getImageUrl(awareness);
                      final cardImageHeight = clampDouble(
                        isTablet ? width * 0.32 : width * 0.48,
                        160,
                        isTablet ? 280 : 240,
                      );

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == controller.awarenessList.length - 1 ? 24.0 : 18.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE9EEF3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: cardImageHeight,
                                  child: imageUrl.isNotEmpty
                                      ? _buildNetworkImageWithFallback(
                                          imageUrl,
                                          awareness,
                                          width: double.infinity,
                                          height: cardImageHeight,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: cardImageHeight * 0.22,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 18 : 14,
                                  isTablet ? 14 : 12,
                                  isTablet ? 18 : 14,
                                  isTablet ? 12 : 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      awareness.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: titleFontSize,
                                        color: const Color.fromRGBO(0, 0, 0, 1),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() {
                                      final description =
                                          awareness.awarenessDescription.trim();
                                      final isLong = description.length > 160;
                                      final expanded =
                                          controller.isDescriptionExpanded(i);

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            description,
                                            style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  99, 85, 127, 1),
                                              height: 1.45,
                                              fontSize: descFontSize,
                                            ),
                                            maxLines: expanded ? null : 3,
                                            overflow: expanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                          if (isLong)
                                            TextButton(
                                              onPressed: () =>
                                                  controller.toggleDescription(i),
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.only(
                                                    top: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                expanded
                                                    ? 'Show less'.tr
                                                    : 'Read more'.tr,
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize:
                                                      (descFontSize - 0.5)
                                                          .clamp(10, 14),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        ),
      ),
      // Bottom nav provided by app shell; remove the nested bar here.
    );
  }
}
