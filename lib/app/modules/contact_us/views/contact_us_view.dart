import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/contact_us_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/app/modules/bottom_nav/widgets/bottom_nav_footer.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController(text: '');
    final addressController = TextEditingController();

    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F2F4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(8),
      ),
      hintStyle: TextStyle(color: Colors.grey[400]),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      appBar: const CustomAppBar(
        title: 'Contact Us',
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer name',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: fieldDecoration.copyWith(hintText: 'Eg. Abebe'),
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Phone number',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: const Icon(Icons.call, color: Colors.black54),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: const Text('+251', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE6E6E6)),
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Phone number',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressController,
                        decoration: fieldDecoration.copyWith(hintText: 'Eg. Abebe'),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            final address = addressController.text.trim();
                            // Simple validation
                            if (name.isEmpty && phone.isEmpty && address.isEmpty) {
                              Get.snackbar('Missing', 'Please provide at least one field', snackPosition: SnackPosition.BOTTOM);
                              return;
                            }
                            Get.snackbar('Sent', 'Your message has been submitted', snackPosition: SnackPosition.BOTTOM);
                            nameController.clear();
                            phoneController.clear();
                            addressController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10A94E),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('SEND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 220),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarFooter(),
    );
  }
}
