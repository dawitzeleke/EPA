import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportTypeDescriptionCard extends StatelessWidget {
  final String reportType;

  const ReportTypeDescriptionCard({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    String titleKey;
    String descKey;
    switch (reportType) {
      case 'pollution':
        titleKey = 'Pollution Description';
        descKey = 'pollution_desc_body';
        break;
      case 'waste':
        titleKey = 'Waste Description';
        descKey = 'waste_desc_body';
        break;
      case 'chemical':
        titleKey = 'Chemical / Hazardous Material Description';
        descKey = 'chemical_desc_body';
        break;
      default:
        titleKey = 'Sound Description';
        descKey = 'sound_desc_body';
    }

    return Card(
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleKey.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              descKey.tr,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
