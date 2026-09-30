import 'dart:math';
import 'package:flutter/material.dart';

class MagicEyeTubeWidget extends StatelessWidget {
  final double convergence; // 0.0 to 1.0 (signal strength)
  final bool isPowered;
  final bool isWarmingUp;

  const MagicEyeTubeWidget({
    super.key,
    required this.convergence,
    required this.isPowered,
    required this.isWarmingUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF140F0A),
        border: Border.all(
          color: const Color(0xFF8B6508), // Brass bezel
          width: 3.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(2, 3),
          ),
          if (isPowered && !isWarmingUp)
            BoxShadow(
              color: const Color(0xFF00FF66).withValues(alpha: 0.35 * (0.5 + 0.5 * convergence)),
              blurRadius: 18,
              spreadRadius: 4,
            ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _MagicEyePainter(
            convergence: convergence,
            isPowered: isPowered,
            isWarmingUp: isWarmingUp,
          ),
        ),
      ),
    );
  }
}

class _MagicEyePainter extends CustomPainter {
  final double convergence;
  final bool isPowered;
  final bool isWarmingUp;

  _MagicEyePainter({
    required this.convergence,
    required this.isPowered,
    required this.isWarmingUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Dark tube interior
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D180F),
          const Color(0xFF050805),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    if (!isPowered) {
      // Off state: dark faint phosphor
      final offPaint = Paint()
        ..color = const Color(0xFF1E3825).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.85, offPaint);
      _drawTubeCenterCap(canvas, center, radius);
      _drawGlassReflections(canvas, size, radius);
      return;
    }

    if (isWarmingUp) {
      // Filament orange glow heating up
      final warmupPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF6600).withValues(alpha: 0.7),
            const Color(0x33FF2200),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius * 0.7, warmupPaint);
      _drawTubeCenterCap(canvas, center, radius);
      _drawGlassReflections(canvas, size, radius);
      return;
    }

    // Active Green Phosphor Fan
    // The magic eye aperture angle narrows as signal converges (signal strength high)
    // Gap angle from 75 degrees down to 4 degrees
    final maxGap = 80.0 * (pi / 180);
    final minGap = 5.0 * (pi / 180);
    final currentGap = maxGap - (maxGap - minGap) * convergence.clamp(0.0, 1.0);

    final phosphorPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF33FF88),
          const Color(0xFF00DD44),
          const Color(0xFF008822),
          const Color(0xFF003311),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Top and bottom glowing sectors
    final path = Path();
    // Right wing
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      -pi / 2 + currentGap / 2,
      pi - currentGap,
      true,
    );
    path.lineTo(center.dx, center.dy);
    path.close();

    // Left wing
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius * 0.88),
      pi / 2 + currentGap / 2,
      pi - currentGap,
      true,
    );
    path.lineTo(center.dx, center.dy);
    path.close();

    canvas.drawPath(path, phosphorPaint);

    // Dynamic bright edge glow on the closing petals
    final edgePaint = Paint()
      ..color = const Color(0xFFE0FFE8).withValues(alpha: 0.85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, edgePaint);

    // Center cathode shadow cap
    _drawTubeCenterCap(canvas, center, radius);

    // Glass glare / specular highlight
    _drawGlassReflections(canvas, size, radius);
  }

  void _drawTubeCenterCap(Canvas canvas, Offset center, double radius) {
    // Metal center electrode
    final capPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4A4A4A),
          const Color(0xFF1F1F1F),
          Colors.black,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.32));
    canvas.drawCircle(center, radius * 0.32, capPaint);

    // Center brass point
    final brassPin = Paint()..color = const Color(0xFFB8860B);
    canvas.drawCircle(center, radius * 0.1, brassPin);
  }

  void _drawGlassReflections(Canvas canvas, Size size, double radius) {
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.38, size.height * 0.32),
        width: radius * 1.1,
        height: radius * 0.65,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MagicEyePainter oldDelegate) {
    return oldDelegate.convergence != convergence ||
        oldDelegate.isPowered != isPowered ||
        oldDelegate.isWarmingUp != isWarmingUp;
  }
}
