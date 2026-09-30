import 'dart:math';
import 'package:flutter/material.dart';

class VintageKnobWidget extends StatefulWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final double size;
  final ValueChanged<double> onChanged;
  final bool hasPowerSwitch;
  final bool isPowerOn;
  final VoidCallback? onPowerToggle;

  const VintageKnobWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.size = 72,
    this.hasPowerSwitch = false,
    this.isPowerOn = false,
    this.onPowerToggle,
  });

  @override
  State<VintageKnobWidget> createState() => _VintageKnobWidgetState();
}

class _VintageKnobWidgetState extends State<VintageKnobWidget> {
  double _currentAngle = 0.0;
  double _lastPanY = 0.0;

  @override
  void initState() {
    super.initState();
    _currentAngle = _valueToAngle(widget.value);
  }

  @override
  void didUpdateWidget(covariant VintageKnobWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentAngle = _valueToAngle(widget.value);
    }
  }

  double _valueToAngle(double val) {
    // -135 deg to +135 deg in radians
    const minAngle = -2.35619; // -135 deg
    const maxAngle = 2.35619; // +135 deg
    return minAngle + val.clamp(0.0, 1.0) * (maxAngle - minAngle);
  }

  double _angleToValue(double angle) {
    const minAngle = -2.35619;
    const maxAngle = 2.35619;
    return ((angle - minAngle) / (maxAngle - minAngle)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragStart: (details) {
            _lastPanY = details.localPosition.dy;
          },
          onVerticalDragUpdate: (details) {
            final dy = _lastPanY - details.localPosition.dy;
            _lastPanY = details.localPosition.dy;
            final deltaAngle = dy * 0.035;
            final newAngle = (_currentAngle + deltaAngle).clamp(-2.35619, 2.35619);
            setState(() {
              _currentAngle = newAngle;
            });
            widget.onChanged(_angleToValue(newAngle));
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _VintageKnobPainter(
                angle: _currentAngle,
                hasPowerSwitch: widget.hasPowerSwitch,
                isPowerOn: widget.isPowerOn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFC49E52), // Antique gold text
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        if (widget.hasPowerSwitch) ...[
          const SizedBox(height: 2),
          GestureDetector(
            onTap: widget.onPowerToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isPowerOn ? const Color(0xFF4A100A) : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: widget.isPowerOn ? const Color(0xFFFF5252) : const Color(0xFF555555),
                  width: 1,
                ),
              ),
              child: Text(
                widget.isPowerOn ? 'AÇIK (ON)' : 'KAPALI (OFF)',
                style: TextStyle(
                  color: widget.isPowerOn ? const Color(0xFFFF8A80) : Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VintageKnobPainter extends CustomPainter {
  final double angle;
  final bool hasPowerSwitch;
  final bool isPowerOn;

  _VintageKnobPainter({
    required this.angle,
    required this.hasPowerSwitch,
    required this.isPowerOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer dark fluted bakelite rim
    final bakelitePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF332014),
          const Color(0xFF1F120A),
          const Color(0xFF0F0804),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bakelitePaint);

    // Fluting notches around edge
    const notchCount = 18;
    for (int i = 0; i < notchCount; i++) {
      final a = i * (2 * pi / notchCount);
      final p1 = Offset(center.dx + cos(a) * (radius - 1), center.dy + sin(a) * (radius - 1));
      final p2 = Offset(center.dx + cos(a) * (radius - 5), center.dy + sin(a) * (radius - 5));

      final notchPaint = Paint()
        ..color = const Color(0xFF080402)
        ..strokeWidth = 2.0;
      canvas.drawLine(p1, p2, notchPaint);
    }

    // Inner brass inlay ring
    final brassRing = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFB8860B),
          const Color(0xFFFFE4B5),
          const Color(0xFF8B6508),
          const Color(0xFFFFD700),
          const Color(0xFFB8860B),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.75))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius * 0.75, brassRing);

    // Center polished brass disc
    final centerDisc = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082),
          const Color(0xFFC49E52),
          const Color(0xFF8B6508),
          const Color(0xFF4A3500),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.65));
    canvas.drawCircle(center, radius * 0.65, centerDisc);

    // Rotating pointer line / indicator dot
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final pointerLine = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(0, -radius * 0.82), pointerLine);

    final pointerDot = Paint()..color = const Color(0xFFFF1744); // Red indicator tip
    canvas.drawCircle(Offset(0, -radius * 0.72), 2.2, pointerDot);

    canvas.restore();

    // Specular light reflection on the knob
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(Offset(center.dx - radius * 0.25, center.dy - radius * 0.25), radius * 0.45, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _VintageKnobPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.isPowerOn != isPowerOn ||
        oldDelegate.hasPowerSwitch != hasPowerSwitch;
  }
}
