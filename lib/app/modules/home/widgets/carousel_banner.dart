import 'package:carousel_slider/carousel_slider.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CarouselBanner extends StatelessWidget {
  final CarouselSliderController carouselController;
  final HomeController controller;

  const CarouselBanner({
    super.key,
    required this.carouselController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isNewsLoading.value) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.imageUrls.isEmpty) {
        return SizedBox(
          height: 220,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'No news available right now. Please check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              onPageChanged: (index, _) {
                controller.currentCarouselIndex.value = index;
              },
            ),
            items: controller.imageUrls.map((url) {
              final caption = controller.imageCaptions[url] ?? '';
              final date = controller.imageDates[url] ?? '';

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      /// ✅ Network vs Asset handling
                      url.startsWith('http')
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            )
                          : Image.asset(
                              url,
                              fit: BoxFit.cover,
                            ),

                      /// Date + City
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),

                      /// Caption Gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primary.withOpacity(0.85),
                                AppColors.primary.withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: Text(
                            caption,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          /// Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.imageUrls.asMap().entries.map((e) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: e.key == controller.currentCarouselIndex.value ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: e.key == controller.currentCarouselIndex.value
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
