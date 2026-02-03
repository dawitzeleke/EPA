import 'package:flutter/material.dart';

class ReportTypeDescriptionCard extends StatelessWidget {
  final String reportType;

  const ReportTypeDescriptionCard({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    String title;
    String desc;
    switch (reportType) {
      case 'pollution':
        title = 'Pollution Description';
        desc =
            'Describe the pollution observed (air, water, or soil), its source, and any visible impact on the environment or public health.';
        break;
      case 'waste':
        title = 'Waste Description';
        desc =
            'Describe the type of waste (household, industrial, construction), exact location, and whether it is actively being dumped or is an abandoned pile.';
        break;
      case 'chemical':
        title = 'Chemical / Hazardous Material Description';
        desc =
            'Provide details on the chemical or hazardous material (labels if visible), estimated quantity, and any immediate danger (smoke, spills, fumes). Avoid close contact.';
        break;
      default:
        title = 'Sound Description';
        desc =
            'Provide a clear description of the issue, including location, time observed, and any other details that can help inspection teams.';
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
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
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
