import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/term_and_conditions_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';

class TermAndConditionsView extends GetView<TermAndConditionsController> {
  const TermAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final paragraphStyle = TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4);

    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      appBar: CustomAppBar(
        title: 'Term and Conditions'.tr,
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Effective Date: [Month, Day, Year]'.tr, titleStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to the Clean Ethiopia App. Please read these Terms and Conditions carefully before using our services.'.tr,
                    style: paragraphStyle,
                  ),
                  const SizedBox(height: 16),

                  _numberedSection(
                    1,
                    'Acceptance of Terms'.tr,
                    'By accessing or using the Clean Ethiopia application, you agree to comply with these Terms and all applicable laws and regulations. If you do not agree, please do not use the application.'.tr,
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSection(
                    2,
                    'Purpose of the App'.tr,
                    'This app is designed to help citizens report environmental violations such as pollution, illegal dumping, and deforestation. EPA staff will review, verify, and take necessary action based on the reports submitted.'.tr,
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSectionWithBullets(
                    3,
                    'User Responsibilities'.tr,
                    'By using this app, you agree to:'.tr,
                    [
                      'Provide accurate and truthful information.'.tr,
                      'Avoid uploading harmful, false, or illegal content.'.tr,
                      'Respect other users and public privacy.'.tr,
                      'Use the platform only for environmental reporting purposes.'.tr
                    ],
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSectionWithBullets(
                    4,
                    'Prohibited Actions'.tr,
                    'You are strictly prohibited from:'.tr,
                    [
                      'Submitting false or misleading reports.'.tr,
                      'Misusing the app for political or personal disputes.'.tr,
                      'Uploading offensive, violent, or copyrighted material.'.tr
                    ],
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSection(
                    5,
                    'Intellectual Property'.tr,
                    'All design, content, and software used in the Clean Ethiopia app are property of the Environmental Protection Authority. You may not copy, modify, or redistribute without written permission.'.tr,
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSectionWithBullets(
                    6,
                    'Limitation of Liability'.tr,
                    'The Environmental Protection Authority is not responsible for:'.tr,
                    [
                      'Technical issues or service interruptions.'.tr,
                      'Actions taken by third parties based on submitted reports.'.tr,
                      'Any loss or damage arising from misuse of the app.'.tr
                    ],
                    titleStyle,
                    paragraphStyle,
                  ),

                  _numberedSection(
                    7,
                    'Account and Data'.tr,
                    'You are responsible for keeping your login details secure. If you suspect unauthorized access, notify the support team immediately.'.tr,
                    titleStyle,
                    paragraphStyle,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Contact'.tr,
                    style: titleStyle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'For questions about these Terms, please contact the Environmental Protection Authority through the Contact Us option in the Settings screen.'.tr,
                    style: paragraphStyle,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarFooter(),
    );
  }

  Widget _sectionTitle(String text, TextStyle style) {
    return Text(text, style: style);
  }

  Widget _numberedSection(int number, String heading, String body, TextStyle headingStyle, TextStyle paragraphStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. $heading', style: headingStyle),
          const SizedBox(height: 6),
          Text(body, style: paragraphStyle),
        ],
      ),
    );
  }

  Widget _numberedSectionWithBullets(int number, String heading, String intro, List<String> bullets, TextStyle headingStyle, TextStyle paragraphStyle) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. $heading', style: headingStyle),
          const SizedBox(height: 6),
          Text(intro, style: paragraphStyle),
          const SizedBox(height: 8),
          ...bullets.map((b) => _bulletRow(b, paragraphStyle)),
        ],
      ),
    );
  }

  Widget _bulletRow(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: Colors.deepPurpleAccent),
          ),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
