import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LabeledTextFieldCard extends StatelessWidget {
  final String title;
  final int maxLines;
  final TextEditingController? controller;
  final bool requiredField;

  const LabeledTextFieldCard({
    super.key,
    required this.title,
    this.maxLines = 1,
    this.controller,
    this.requiredField = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (requiredField) ...[
                  const SizedBox(width: 6),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintStyle: const TextStyle(fontSize: 13),
                fillColor: const Color.fromRGBO(202, 213, 226, 0.2),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(212, 212, 212, 1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(212, 212, 212, 1),
                    width: 0.4,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(212, 212, 212, 1),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
