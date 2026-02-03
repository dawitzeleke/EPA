import 'package:flutter/material.dart';

class StatusChecker extends StatelessWidget {
  const StatusChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final codeCtrl = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check Your Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
          ),
          child: TextField(
            controller: codeCtrl,
            decoration: const InputDecoration(
              hintText: 'Enter report code',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: Icon(Icons.search, color: Color(0xFF22C55E)),
            ),
          ),
        ),
      ],
    );
  }
}
