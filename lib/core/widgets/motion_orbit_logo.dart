import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MotionOrbitLogoMark extends StatelessWidget {
  const MotionOrbitLogoMark({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const MotionOrbitLogoPainter(),
    );
  }
}

class MotionOrbitLogoPainter extends CustomPainter {
  const MotionOrbitLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final w = size.width;

    // Center glow
    canvas.drawCircle(
      center,
      w * 0.22,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Orbit ellipse stroke paint
    final orbitPaint = Paint()
      ..color = AppColors.outlineFocus
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.042)
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = AppColors.outlineFocus;

    // Two tilted crossed ellipses (-35 deg and +35 deg)
    for (final angle in [-0.61, 0.61]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: w * 0.76,
          height: w * 0.36,
        ),
        orbitPaint,
      );

      // Orbiting planetary dots along tracks
      if (angle > 0) {
        canvas.drawCircle(
          Offset(w * 0.28, -w * 0.12),
          w * 0.045,
          dotPaint,
        );
      } else {
        canvas.drawCircle(
          Offset(-w * 0.28, w * 0.12),
          w * 0.045,
          dotPaint,
        );
      }

      canvas.restore();
    }

    // Center core: Blue ring & white nucleus
    canvas.drawCircle(center, w * 0.14, Paint()..color = AppColors.primary);
    canvas.drawCircle(center, w * 0.075, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(MotionOrbitLogoPainter oldDelegate) => false;
}

class HeroOrbitBackgroundPainter extends CustomPainter {
  const HeroOrbitBackgroundPainter({required this.isWelcome});
  final bool isWelcome;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.44;

    // Ambient radial pulse backlight
    canvas.drawCircle(
      center,
      r * 0.85,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Middle concentric orbit rings
    canvas.drawCircle(
      center,
      r * 0.95,
      Paint()
        ..color = AppColors.surfaceContainerHigh.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Dashed outer trajectory
    _drawDashedCircle(
      canvas,
      center,
      r,
      Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
      dashCount: 28,
    );

    // Dashed inner trajectory
    _drawDashedCircle(
      canvas,
      center,
      r * 0.72,
      Paint()
        ..color = AppColors.outlineFocus.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
      dashCount: 22,
    );

    // Decorative Orbit Particle Dots
    final dot1 = Paint()..color = AppColors.outlineFocus;
    final dot2 = Paint()..color = AppColors.primary;

    if (isWelcome) {
      canvas.drawCircle(
        Offset(center.dx, center.dy - r),
        3.5,
        dot1,
      );
      canvas.drawCircle(
        Offset(center.dx + r * 0.72, center.dy + r * 0.45),
        2.5,
        dot2,
      );
    } else {
      canvas.drawCircle(
        Offset(center.dx - r * 0.55, center.dy - r * 0.75),
        3.0,
        dot1,
      );
      canvas.drawCircle(
        Offset(center.dx + r * 0.65, center.dy + r * 0.65),
        3.5,
        dot2,
      );
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required int dashCount,
  }) {
    final step = 2 * math.pi / dashCount;
    final sweep = step * 0.45;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(HeroOrbitBackgroundPainter oldDelegate) => false;
}

