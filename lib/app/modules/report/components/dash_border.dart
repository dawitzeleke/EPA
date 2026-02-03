import 'package:flutter/material.dart';
// /// Draws a rounded dashed border around [child].
class DashedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 6,
    this.color = const Color(0xFFBFCFE0),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        color: color,
        borderRadius: borderRadius,
      ),
      child: Padding(padding: const EdgeInsets.all(4.0), child: child),
    );
  }
}


class _DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;

  _DashedRectPainter({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          end.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = distance + dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
