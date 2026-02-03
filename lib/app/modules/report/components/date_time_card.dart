import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateTimeCard extends StatelessWidget {
  final Rxn<DateTime> selectedDate;
  final Rxn<TimeOfDay> selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const DateTimeCard({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text(
                  'Time and Date',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final d = selectedDate.value;
                    final label = d == null
                        ? 'Select Date'
                        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                    return OutlinedButton(
                      onPressed: onPickDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFFD4D4D4)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: d == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() {
                    final t = selectedTime.value;
                    String label;
                    if (t == null) {
                      label = 'Select Time';
                    } else {
                      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                      final minute = t.minute.toString().padLeft(2, '0');
                      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
                      label = '$hour:$minute $period';
                    }
                    return OutlinedButton(
                      onPressed: onPickTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Color(0xFFD4D4D4)),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: t == null
                              ? Colors.grey.shade600
                              : Colors.black87,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
