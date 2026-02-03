import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                  title: 'Report',
                  icon: 'assets/report.svg',
                  bg: Color(0xFFDCFCE7),
                ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                title: 'Awareness',
                icon: 'assets/awareness.svg',
                bg: Color(0xFFFDE68A),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color bg;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 28,
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF22C55E),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              title == 'Report' ? 'Submit an issue' : 'Learn & stay alert',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}
