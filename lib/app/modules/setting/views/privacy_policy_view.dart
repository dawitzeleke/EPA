

import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1F8), // subtle purple background
      appBar: const CustomAppBar(title: 'Privacy Policy'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('1. Introduction'),
                  _sectionParagraph(
                      'Clean Ethiopia ("we," "our," "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard the information you provide when using our mobile application or web system. By using this app, you agree to the terms of this Privacy Policy.'),

                  _sectionTitle('2. Information We Collect'),
                  _bulletedParagraph([
                    'Personal Information: such as your name, phone number, and location (when provided).',
                    'Report Details: description, media uploads (photo, video, audio, or documents).',
                    'Location Data: if you enable GPS to help identify environmental violation sites.',
                    'Device Information: including device type and operating system (for app performance).',
                  ]),

                  _sectionTitle('3. How We Use Your Information'),
                  _bulletedParagraph([
                    'Process and manage your environmental violation reports.',
                    'Communicate updates about the status of your reports.',
                    'Improve our service, system performance, and reporting accuracy.',
                    'Generate anonymized analytics to support research and decision-making.',
                  ]),

                  _sectionTitle('4. Information Sharing'),
                  _sectionParagraph(
                      'Your personal data will not be shared with unauthorized parties. Data may only be shared with authorized EPA departments and stakeholders involved in report investigation, and law enforcement agencies when required by law.'),

                  _sectionTitle('5. Data Security'),
                  _sectionParagraph(
                      'We apply security measures such as encryption, role-based access, and audit logs to protect your data from unauthorized access, loss, or misuse.'),

                  _sectionTitle('6. User Choices'),
                  _sectionParagraph(
                      'You can choose to report anonymously. You can request data deletion or correction by contacting us at: [support@epa.gov.et]'),

                  _sectionTitle('7. Policy Updates'),
                  _sectionParagraph(
                      'We may update this Privacy Policy occasionally. Changes will be posted in the app with a revised "Effective Date."'),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarFooter(),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }

  Widget _sectionParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Color(0xFF6F5B86), height: 1.5),
      ),
    );
  }

  Widget _bulletedParagraph(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 12.0),
                        child: Icon(Icons.circle, size: 8, color: Color(0xFF7B6FA9)),
                      ),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF6F5B86), height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}