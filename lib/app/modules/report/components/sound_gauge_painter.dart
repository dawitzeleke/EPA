
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Sound gauge painter: draws semicircle segments and an animated needle.
class SoundGaugePainter extends CustomPainter {
  final double value; // current dB
  final double min;
  final double max;
  final bool active;

  SoundGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height * 0.9);
    final radius = math.min(width, height * 2) * 0.42;

    final baseRect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi; // left
    const sweep = math.pi; // semicircle

    // Track style
    final trackWidth = math.max(8.0, radius * 0.12);
    final separatorWidth = trackWidth * 0.22;

    // Segment colors: green → lightGreen → yellow → orange → red
    final segments = <Color>[
      const Color(0xFF1EAD3D),
      const Color(0xFF90C33F),
      const Color(0xFFFFD63A),
      const Color(0xFFF08A27),
      const Color(0xFFE53935),
    ];

    // Draw segments
    final segCount = segments.length;
    final segSweep = sweep / segCount;
    for (int i = 0; i < segCount; i++) {
      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth
        ..strokeCap = StrokeCap.butt
        ..color = segments[i];

      // add small gap between segments to mimic the image
      final gap = separatorWidth / radius; // radians approximation
      final segStart = start + i * segSweep + (i == 0 ? 0 : gap);
      final segEnd = start + (i + 1) * segSweep - (i == segCount - 1 ? 0 : gap);
      final segAngle = segEnd - segStart;
      canvas.drawArc(baseRect, segStart, segAngle, false, segPaint);
    }

    // Optional: inner thin grey arc for ticks
    final ticksPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFB0BEC5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      start,
      sweep,
      false,
      ticksPaint,
    );

    // Draw tick marks every 10 dB
    for (int t = min.round(); t <= max.round(); t += 10) {
      final ratio = (t - min) / (max - min);
      final angle = start + ratio * sweep;
      final p1 = _polar(center, radius * 0.74, angle);
      final p2 = _polar(center, radius * 0.82, angle);
      final tp = Paint()
        ..color = const Color(0xFF90A4AE)
        ..strokeWidth = t % 20 == 0 ? 2.0 : 1.2;
      canvas.drawLine(p1, p2, tp);
    }

    // Needle
    final clamped = value.isNaN ? min : value.clamp(min, max);
    final ratio = (clamped - min) / (max - min);
    final angle = start + ratio * sweep;
    final needleLen = radius * 0.86;
    final needleBaseLen = radius * 0.12;

    // base shadow
    final shadow = Paint()
      ..color = Colors.black12
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      _polar(center, needleLen, angle),
      shadow,
    );

    final needlePaint = Paint()
      ..color = active ? const Color(0xFF263238) : const Color(0xFF9E9E9E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, _polar(center, needleLen, angle), needlePaint);

    // small counter-weight behind center
    canvas.drawLine(
      center,
      _polar(center, needleBaseLen, angle + math.pi),
      needlePaint,
    );

    // Center knob
    final knob = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(center, trackWidth * 0.45, knob);

    // Value label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${clamped.toStringAsFixed(0)} dB',
        style: const TextStyle(
          color: Color(0xFF073C59),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpOffset = Offset(center.dx - textPainter.width / 2, center.dy - radius * 0.65);
    textPainter.paint(canvas, tpOffset);
  }

  Offset _polar(Offset center, double r, double angle) {
    return Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant SoundGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.active != active;
  }
}

