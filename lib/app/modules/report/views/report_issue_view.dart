import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:eprs/app/modules/report/views/report_view.dart';

class ReportIssueView extends StatelessWidget {
  const ReportIssueView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <Map<String, dynamic>>[
      {'icon': Icons.air, 'label': 'Air pollution'},
      {'icon': Icons.water, 'label': 'water pollution'},
      {'icon': Icons.grass, 'label': 'Soil pollution'},
      {'icon': Icons.park, 'label': 'Deforestation'},
      {'icon': Icons.factory_outlined, 'label': 'Industrial & Urban'},
      {'icon': Icons.local_fire_department_outlined, 'label': 'Wildlife & Eco'},
      {'icon': Icons.delete_outline, 'label': 'Waste & Pollution'},
      {'icon': Icons.more_horiz, 'label': 'Others'},
    ];

    return Scaffold(
      appBar: CustomAppBar(title: "Report Issue Category"),
        
      backgroundColor: const Color(0xFFF6F6FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3.8,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                          children: categories.map((c) {
                          return _CategoryButton(
                            icon: c['icon'] as IconData,
                            label: c['label'] as String,
                            onTap: () {
                              final label = c['label'] as String;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReportView(reportType: label),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Spacer so the card doesn't sit too close to the bottom nav
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6EEF8)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1976D2), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
