import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoundPeriodCard extends StatelessWidget {
  final RxString soundPeriod;

  const SoundPeriodCard({super.key, required this.soundPeriod});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Time of Day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final current = soundPeriod.value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => soundPeriod.value = 'Day',
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: current == 'Day'
                              ? AppColors.primary
                              : const Color.fromRGBO(212, 212, 212, 1),
                          width: current == 'Day' ? 1.1 : 1,
                        ),
                        backgroundColor: current == 'Day'
                          ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Day',
                        style: TextStyle(
                          color: current == 'Day'
                              ? AppColors.primary
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => soundPeriod.value = 'Night',
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: current == 'Night'
                              ? AppColors.primary
                              : const Color.fromRGBO(212, 212, 212, 1),
                          width: current == 'Night' ? 1.1 : 1,
                        ),
                        backgroundColor: current == 'Night'
                          ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Night',
                        style: TextStyle(
                          color: current == 'Night'
                              ? AppColors.primary
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
