// ─────────────────────────────────────────────────────────────────────────────
//  home_view.dart
// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav is implemented as a separate shell. Do not import the shell here to avoid
// recursive widget construction (the shell instantiates these pages).
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/app/modules/home/widgets/carousel_banner.dart';
import 'package:eprs/core/enums/report_type_enum.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/app/widgets/language_selector.dart';
// quick_actions and status_checker widgets were intentionally removed from
// this view to match the requested layout; keep their files intact in the
// project in case other screens use them.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eprs/app/routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Carousel page controller
  @override
  Widget build(BuildContext context) {
    // Ensure HomeController is available (defensive in case route bindings weren't set)
    if (!Get.isRegistered<HomeController>()) {
      Get.put(
        HomeController(
          getNewsUseCase: Get.find(),
        ),
        permanent: true,
      );
    }
    // If username is passed from auth flow or stored, sync into controller
    try {
      final args = Get.arguments;
      if (args != null && args is Map && args['username'] is String) {
        final argName = args['username'] as String;
        if (argName.isNotEmpty && controller.userName.value != argName) {
          controller.userName.value = argName;
        }
      }
    } catch (_) {}
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header (green banner like the design)
            _buildHeader(controller),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  CarouselBanner(
                    carouselController: controller.carouselCtrl,
                    controller: controller,
                  ),
                  const SizedBox(height: 18),

                  _buildCheckStatusSection(controller),
                  const SizedBox(height: 18),

                  // Report grid
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report'.tr,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        // Lower aspect ratio -> taller & wider tiles (images scale with the tile)
                        childAspectRatio: 1.4,
                        children: [
                          _ReportTile(
                            image: "assets/pollution.png",
                            url: Routes.REPORT,
                            reportType: ReportTypeEnum.pollution.name,
                          ),
                          // _ReportTile(image: "assets/waste.png", url: Routes.REPORT, reportType: ReportTypeEnum.waste.name),
                          // _ReportTile(image: "assets/chemical.png", url: Routes.REPORT, reportType: ReportTypeEnum.chemical.name),
                          _ReportTile(
                            image: "assets/sound.png",
                            url: Routes.REPORT,
                            reportType: ReportTypeEnum.sound.name,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
  // BottomNavBar is provided by the top-level shell. Do not include it here.
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String image;
  final String url;
  final String reportType;
  const _ReportTile({required this.image, required this.url, required this.reportType});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          // Get pollution category ID from controller
          final homeController = Get.find<HomeController>();
          final categoryId = homeController.getPollutionCategoryId(reportType);
          
          print('📤 Navigating to report:');
          print('   - Report Type: $reportType');
          print('   - Category ID: ${categoryId ?? "NOT FOUND"}');
          
          if (categoryId == null) {
            print('⚠️ Warning: No category ID found for "$reportType"');
            print('   Available categories: ${homeController.pollutionCategories.keys.toList()}');
          }
          
          // Push onto the nearest Navigator (the nested navigator created by the shell)
          Get.toNamed("/report", arguments: {
            'reportType': reportType,
            if (categoryId != null) 'pollutionCategoryId': categoryId,
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            image,
            fit: BoxFit.contain, // avoid zooming in; keep full image visible
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

 Widget _buildHeader(HomeController controller) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 60, // Reduced height for header
        padding: const EdgeInsets.symmetric(horizontal: 10), // Add horizontal padding
        child: Stack(
          children: [
            // Welcome text (reads userName from HomeController)
            Positioned(
              top: 20,
              left: 15, // Position from container start
              right: 120, // Leave space for icons on the right
              child: SizedBox(
                height: 20,
                child: Obx(() {
                  final name = controller.userName.value;
                  return Text(
                    'Welcome, ${name.isNotEmpty ? name : 'Guest'}',
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle text overflow
                    maxLines: 1,
                  );
                }),
              ),
            ),

            // Language selector positioned at specified location
            Positioned(
              top: 10, // Adjusted for smaller header
              right: -15, // Shift slightly more to the right edge
              child: SizedBox(
                width: 60,
                height: 35,
                child: const LanguageSelector(
                  usePoppins: false,
                  fontSize: 12,
                  iconSize: 20,
                  color: Color(0xFF073C59),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildCheckStatusSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Check Your Status" title
        Text(
          'Track Report Status'.tr,

          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.accentBlue,
          ),
        ),
        const SizedBox(height: 10),
        
        // White card with rounded corners containing the search section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const SizedBox(height: 12),
              
              // Text field with trailing icon
              Obx(() => Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.reportIdController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Report ID'.tr,
                          hintStyle: TextStyle(
                              color: AppColors.accentBlue,
                            fontSize: 12,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (value) {
                          controller.searchReportById(value);
                        },
                        enabled: !controller.isSearchingReport.value,
                      ),
                    ),
                    if (controller.isSearchingReport.value)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      InkWell(
                        onTap: () {
                          controller.searchReportById(controller.reportIdController.text);
                        },
                        child: Icon(
                          Icons.search,
                          color: AppColors.tertiary,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }