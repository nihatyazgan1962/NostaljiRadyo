import 'package:flutter/material.dart';
import '../models/radio_band.dart';
import '../models/radio_station.dart';

class TuningDialWidget extends StatelessWidget {
  final RadioBandType activeBand;
  final double currentFrequency;
  final bool isPowered;
  final bool dialLightOn;
  final Function(double newFreq) onFrequencyChanged;

  const TuningDialWidget({
    super.key,
    required this.activeBand,
    required this.currentFrequency,
    required this.isPowered,
    required this.dialLightOn,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dialWidth = constraints.maxWidth;
        final dialHeight = 165.0;

        return Container(
          width: dialWidth,
          height: dialHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF140D07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFB8860B), // Antique gold brass trim
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.9),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              if (isPowered && dialLightOn)
                BoxShadow(
                  color: const Color(0xFFFF9900).withValues(alpha: 0.25),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final normalizedX = (details.localPosition.dx / dialWidth).clamp(0.05, 0.95);
                final fraction = (normalizedX - 0.05) / 0.90;
                final newFreq = activeBand.minFrequency + fraction * (activeBand.maxFrequency - activeBand.minFrequency);
                onFrequencyChanged(newFreq);
              },
              onTapDown: (details) {
                final normalizedX = (details.localPosition.dx / dialWidth).clamp(0.05, 0.95);
                final fraction = (normalizedX - 0.05) / 0.90;
                final newFreq = activeBand.minFrequency + fraction * (activeBand.maxFrequency - activeBand.minFrequency);
                onFrequencyChanged(newFreq);
              },
              child: Stack(
                children: [
                  // Backlight & Glass Scale Painter
                  CustomPaint(
                    size: Size(dialWidth, dialHeight),
                    painter: _TuningDialPainter(
                      activeBand: activeBand,
                      currentFrequency: currentFrequency,
                      isPowered: isPowered,
                      dialLightOn: dialLightOn,
                    ),
                  ),

                  // Moving Brass/Red Needle
                  CustomPaint(
                    size: Size(dialWidth, dialHeight),
                    painter: _NeedlePainter(
                      activeBand: activeBand,
                      currentFrequency: currentFrequency,
                      isPowered: isPowered,
                    ),
                  ),

                  // Glass reflection overlay
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TuningDialPainter extends CustomPainter {
  final RadioBandType activeBand;
  final double currentFrequency;
  final bool isPowered;
  final bool dialLightOn;

  _TuningDialPainter({
    required this.activeBand,
    required this.currentFrequency,
    required this.isPowered,
    required this.dialLightOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background vintage glass / dark amber tint
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: isPowered && dialLightOn
            ? [
                const Color(0xFF422108), // Warm incandescent bulb glow
                const Color(0xFF261204),
                const Color(0xFF120701),
              ]
            : [
                const Color(0xFF1B140E),
                const Color(0xFF0F0B07),
                const Color(0xFF080604),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Warm glow lamp bulbs behind scale
    if (isPowered && dialLightOn) {
      final bulbGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB347).withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.25, size.height * 0.5), radius: 80));
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.5), 80, bulbGlow);

      final bulbGlow2 = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB347).withValues(alpha: 0.45),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.5), radius: 80));
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), 80, bulbGlow2);
    }

    // Draw 4 Band Tracks: FM, SW, MW, LW
    final tracks = [
      RadioBandType.fm,
      RadioBandType.kisaDalga,
      RadioBandType.ortaDalga,
      RadioBandType.uzunDalga,
    ];

    const topPadding = 16.0;
    const trackHeight = 32.0;

    for (int i = 0; i < tracks.length; i++) {
      final band = tracks[i];
      final y = topPadding + i * trackHeight;
      final isActive = band == activeBand;

      _drawBandTrack(canvas, size, band, y, isActive);
    }

    // Outer vintage scale frame line
    final borderLine = Paint()
      ..color = const Color(0xFF7A5920).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(Rect.fromLTWH(8, 8, size.width - 16, size.height - 16), borderLine);
  }

  void _drawBandTrack(Canvas canvas, Size size, RadioBandType band, double y, bool isActive) {
    final startX = size.width * 0.08;
    final endX = size.width * 0.92;
    final trackWidth = endX - startX;

    final primaryColor = isActive && isPowered && dialLightOn
        ? const Color(0xFFFFD54F) // Bright golden amber
        : (isPowered && dialLightOn
            ? const Color(0xFF9E7B38).withValues(alpha: 0.7)
            : const Color(0xFF5A4622).withValues(alpha: 0.4));

    final textColor = isActive && isPowered && dialLightOn
        ? const Color(0xFFFFE57F)
        : (isPowered && dialLightOn
            ? const Color(0xFFC49E52).withValues(alpha: 0.7)
            : const Color(0xFF6B5328).withValues(alpha: 0.45));

    // Band title label on the left (e.g. FM, SW, MW, LW)
    final labelSpan = TextSpan(
      text: _getShortBandCode(band),
      style: TextStyle(
        color: isActive && isPowered ? const Color(0xFFFF8F00) : textColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(canvas, Offset(8, y + 2));

    // Track baseline
    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(startX, y + 12), Offset(endX, y + 12), linePaint);

    // Station markers and frequency ticks
    final stations = RadioStation.defaultStations.where((s) => s.band == band).toList();

    // Scale ticks
    final tickCount = 10;
    for (int t = 0; t <= tickCount; t++) {
      final fraction = t / tickCount;
      final x = startX + fraction * trackWidth;
      final freqVal = band.minFrequency + fraction * (band.maxFrequency - band.minFrequency);
      final isMajor = t % 2 == 0;

      final tickPaint = Paint()
        ..color = primaryColor.withValues(alpha: isMajor ? 0.8 : 0.4)
        ..strokeWidth = isMajor ? 1.4 : 0.8;
      canvas.drawLine(
        Offset(x, y + (isMajor ? 7 : 10)),
        Offset(x, y + 15),
        tickPaint,
      );

      if (isMajor && (size.width > 340 || t % 4 == 0)) {
        final freqText = freqVal >= 100 ? freqVal.toInt().toString() : freqVal.toStringAsFixed(1);
        final freqSpan = TextSpan(
          text: freqText,
          style: TextStyle(
            color: textColor,
            fontSize: 7.5,
            fontFamily: 'monospace',
          ),
        );
        final freqPainter = TextPainter(
          text: freqSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        freqPainter.paint(canvas, Offset(x - freqPainter.width / 2, y + 16));
      }
    }

    // Historical City/Station Markers along this track
    for (final st in stations) {
      final fraction = (st.frequency - band.minFrequency) / (band.maxFrequency - band.minFrequency);
      final x = startX + fraction.clamp(0.0, 1.0) * trackWidth;

      // Small diamond marker
      final markerPaint = Paint()
        ..color = isActive ? const Color(0xFFFF5252) : const Color(0xFFB76E79).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(x, y + 12);
      path.lineTo(x - 2.5, y + 9);
      path.lineTo(x, y + 6);
      path.lineTo(x + 2.5, y + 9);
      path.close();
      canvas.drawPath(path, markerPaint);

      // Station City Name
      if (isActive && size.width > 280) {
        final citySpan = TextSpan(
          text: st.cityName.split('-').first.trim(),
          style: TextStyle(
            color: isPowered ? const Color(0xFFFFF8E1) : Colors.grey.shade600,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        );
        final cityPainter = TextPainter(
          text: citySpan,
          textDirection: TextDirection.ltr,
        )..layout();
        cityPainter.paint(canvas, Offset(x - cityPainter.width / 2, y - 1));
      }
    }
  }

  String _getShortBandCode(RadioBandType b) {
    switch (b) {
      case RadioBandType.uzunDalga:
        return 'LW';
      case RadioBandType.ortaDalga:
        return 'MW';
      case RadioBandType.kisaDalga:
        return 'SW';
      case RadioBandType.fm:
        return 'FM';
    }
  }

  @override
  bool shouldRepaint(covariant _TuningDialPainter oldDelegate) {
    return oldDelegate.activeBand != activeBand ||
        oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.isPowered != isPowered ||
        oldDelegate.dialLightOn != dialLightOn;
  }
}

class _NeedlePainter extends CustomPainter {
  final RadioBandType activeBand;
  final double currentFrequency;
  final bool isPowered;

  _NeedlePainter({
    required this.activeBand,
    required this.currentFrequency,
    required this.isPowered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startX = size.width * 0.08;
    final endX = size.width * 0.92;
    final trackWidth = endX - startX;

    final fraction = ((currentFrequency - activeBand.minFrequency) /
            (activeBand.maxFrequency - activeBand.minFrequency))
        .clamp(0.0, 1.0);

    final needleX = startX + fraction * trackWidth;

    // Glowing red/brass needle line
    final needleShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(needleX + 1.5, 10), Offset(needleX + 1.5, size.height - 10), needleShadow);

    final needlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF1744), // Bright red needle
          Color(0xFFFF5252),
          Color(0xFFD50000),
        ],
      ).createShader(Rect.fromLTWH(needleX - 1.5, 8, 3, size.height - 16))
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(needleX, 8), Offset(needleX, size.height - 8), needlePaint);

    // Top and bottom pointer brass weights
    final brassCap = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(needleX, 10), 3.5, brassCap);
    canvas.drawCircle(Offset(needleX, size.height - 10), 3.5, brassCap);
  }

  @override
  bool shouldRepaint(covariant _NeedlePainter oldDelegate) {
    return oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.activeBand != activeBand ||
        oldDelegate.isPowered != isPowered;
  }
}
