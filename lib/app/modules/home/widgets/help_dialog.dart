import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showHelpDialog() {
  Get.dialog(
    AlertDialog(
      title: const Text('Help & Support'),
      content: const Text(
        'Need help? Contact our support team or check the FAQ section.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.dialog(
            const AlertDialog(title: Text('FAQ'), content: Text('Coming soon')),
          ),
          child: const Text('FAQ'),
        ),
        TextButton(
          onPressed: () => Get.dialog(
            const AlertDialog(
              title: Text('Contact'),
              content: Text('support@epaproject.com'),
            ),
          ),
          child: const Text('Contact'),
        ),
        TextButton(onPressed: () => Get.back(), child: const Text('Close')),
      ],
    ),
  );
}
