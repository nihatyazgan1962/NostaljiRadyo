import 'dart:math';
import 'package:flutter/material.dart';

class RadioCabinetWidget extends StatelessWidget {
  final Widget child;
  final bool isPowered;
  final double signalStrength;
  final bool antennaExtended;
  final VoidCallback onToggleAntenna;

  const RadioCabinetWidget({
    super.key,
    required this.child,
    required this.isPowered,
    required this.signalStrength,
    required this.antennaExtended,
    required this.onToggleAntenna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        // Authentic dark walnut & mahogany polished wood finish
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF532813), // Rich mahogany highlight
            Color(0xFF38190B),
            Color(0xFF260F06),
            Color(0xFF1B0A04),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 35,
            spreadRadius: 8,
            offset: const Offset(0, 16),
          ),
          const BoxShadow(
            color: Color(0xFF6E3619),
            blurRadius: 2,
            spreadRadius: 1,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B5A2B), // Wood rim bevel
          width: 5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Decorative Wood Crown & Telescopic Antenna
          _buildCabinetTopBar(),

          // Main Cabinet Interior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Top Speaker Section with Vintage Woven Cloth & Brass Badge
                _buildSpeakerGrilleSection(),
                const SizedBox(height: 14),

                // Main Controls (Dial, Magic Eye, Band Selector, Knobs)
                child,
              ],
            ),
          ),

          // Bottom Wooden Plinth Feet
          _buildCabinetFeet(),
        ],
      ),
    );
  }

  Widget _buildCabinetTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF220E06),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFB8860B), // Brass inlay strip
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Vintage Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFB8860B),
                ),
                child: const Icon(
                  Icons.radio,
                  size: 14,
                  color: Color(0xFF260F06),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'YAZGAN BİLEŞİM • SUPERHET MODEL 1938',
                style: TextStyle(
                  color: Color(0xFFE5C158),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),

          // Antenna Switch / Indicator
          InkWell(
            onTap: onToggleAntenna,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: antennaExtended ? const Color(0xFF2E4C20) : const Color(0xFF4A1A1A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: antennaExtended ? const Color(0xFF76FF03) : const Color(0xFFFF5252),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    antennaExtended ? Icons.cell_tower : Icons.signal_cellular_off,
                    size: 13,
                    color: antennaExtended ? const Color(0xFFB2FF59) : const Color(0xFFFF8A80),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    antennaExtended ? 'ANTEN AÇIK' : 'ANTEN KAPALI',
                    style: TextStyle(
                      color: antennaExtended ? const Color(0xFFB2FF59) : const Color(0xFFFF8A80),
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerGrilleSection() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8B6508), // Brass frame
          width: 3.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Custom Acoustic Fabric Weave Painter
            CustomPaint(
              size: const Size(double.infinity, 110),
              painter: _VintageFabricSpeakerPainter(
                isPowered: isPowered,
                signalStrength: signalStrength,
              ),
            ),

            // Brass Brand Emblem
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1B0D05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 1.8,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'YAZGAN BİLEŞİM • KLASİK MASA RADYOSU',
                style: TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabinetFeet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSingleFoot(),
          Container(
            height: 4,
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFB8860B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildSingleFoot(),
        ],
      ),
    );
  }

  Widget _buildSingleFoot() {
    return Container(
      width: 42,
      height: 12,
      decoration: BoxDecoration(
        color: const Color(0xFF140803),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFB8860B),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _VintageFabricSpeakerPainter extends CustomPainter {
  final bool isPowered;
  final double signalStrength;

  _VintageFabricSpeakerPainter({
    required this.isPowered,
    required this.signalStrength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Vintage acoustic tweed / jute cloth weave
    final bg = Paint()..color = const Color(0xFF2A1C12);
    canvas.drawRect(Offset.zero & size, bg);

    // Warm tube lamp backlight glow through cloth when powered
    if (isPowered) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF8C00).withValues(alpha: 0.25 + 0.15 * signalStrength),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.45));
      canvas.drawRect(Offset.zero & size, glowPaint);
    }

    // Grid cross-hatch fabric texture
    final warpPaint = Paint()
      ..color = const Color(0xFF423020).withValues(alpha: 0.8)
      ..strokeWidth = 1.2;

    final weftPaint = Paint()
      ..color = const Color(0xFF1B1109).withValues(alpha: 0.9)
      ..strokeWidth = 1.2;

    const spacing = 5.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), warpPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), weftPaint);
    }

    // Wooden vertical grille bars (classic 1930s-1940s grille louvers)
    final barPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF6B3E1E),
          Color(0xFF381F0D),
          Color(0xFF1F1005),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 6.0;

    final barPositions = [
      size.width * 0.18,
      size.width * 0.28,
      size.width * 0.72,
      size.width * 0.82,
    ];

    for (final bx in barPositions) {
      canvas.drawLine(Offset(bx, 0), Offset(bx, size.height), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VintageFabricSpeakerPainter oldDelegate) {
    return oldDelegate.isPowered != isPowered || oldDelegate.signalStrength != signalStrength;
  }
}
