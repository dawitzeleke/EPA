import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/faq_controller.dart';

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});
  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': '1. What is the Clean Ethiopia App?'.tr,
        'a': 'The Clean Ethiopia App is a civic reporting tool that allows citizens to report violations, track reports, and access services from the civil registration and citizenship agency.'.tr
      },
      {'q': '2. Who can use this app?'.tr, 'a': 'Any citizen or resident can use the app to report and follow up on community issues.'.tr},
      {
        'q': '3. How do I report a violation?'.tr,
        'a': 'Open the report form, provide details, attach photos if available, and submit. You will get a tracking number.'.tr
      },
      {
        'q': '4. Can I submit a report anonymously?'.tr,
        'a': 'Yes. You can report without revealing your identity. Simply choose the "Report Anonymously" option before submitting.'.tr
      },
      {'q': '5. How can I track my report?'.tr, 'a': 'Use the tracking number provided after submission to check status in the Status tab.'.tr},
      {'q': '6. What types of violations can I report?'.tr, 'a': 'You can report various civic and public service violations. Consult the FAQ categories for details.'.tr},
      {'q': '7. What happens after I submit a report?'.tr, 'a': 'The agency reviews the report and takes appropriate action; you can follow progress via the Status screen.'.tr},
    ];

    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      appBar: CustomAppBar(title: 'FAQ'.tr),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Material(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: faqs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = faqs[index];
                        return ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          title: Text(item['q'] ?? ''),
                          trailing: const Icon(Icons.keyboard_arrow_down),
                          children: [
                            Text(item['a'] ?? '', style: const TextStyle(color: Colors.black87)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarFooter(),
    );
  }
}
