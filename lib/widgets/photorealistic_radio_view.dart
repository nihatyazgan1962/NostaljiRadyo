import 'package:flutter/material.dart';
import '../models/radio_band.dart';
import '../models/radio_station.dart';
import '../services/audio_radio_service.dart';
import 'band_selector.dart';
import 'vintage_knob.dart';

class PhotorealisticRadioWidget extends StatelessWidget {
  final AudioRadioService radioService;
  final VoidCallback onOpenLogbook;
  final VoidCallback onToggleChassis;

  const PhotorealisticRadioWidget({
    super.key,
    required this.radioService,
    required this.onOpenLogbook,
    required this.onToggleChassis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 620),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.95),
            blurRadius: 35,
            spreadRadius: 8,
            offset: const Offset(0, 16),
          ),
          if (radioService.isPoweredOn)
            BoxShadow(
              color: const Color(0xFFFF8C00).withValues(alpha: 0.2),
              blurRadius: 40,
              spreadRadius: 6,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Top Bar with Brand Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E0E06),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFB8860B), width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB8860B),
                        ),
                        child: const Icon(Icons.radio, size: 14, color: Color(0xFF1E0E06)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'YAZGAN BİLEŞİM • MODEL 1938',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: radioService.toggleAntenna,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: radioService.antennaExtended ? const Color(0xFF2E4C20) : const Color(0xFF4A1A1A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: radioService.antennaExtended ? const Color(0xFF76FF03) : const Color(0xFFFF5252),
                        ),
                      ),
                      child: Text(
                        radioService.antennaExtended ? '📡 ANTEN: AÇIK' : '📡 ANTEN: KAPALI',
                        style: TextStyle(
                          color: radioService.antennaExtended ? const Color(0xFFB2FF59) : const Color(0xFFFF8A80),
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Photorealistic Radio Image Chassis with Interactive Overlays
            Stack(
              alignment: Alignment.center,
              children: [
                // Base HD Photo
                Image.asset(
                  'assets/images/retro_radio.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'retro_radio.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, err, st) => Container(
                        height: 380,
                        color: const Color(0xFF2E1307),
                        child: const Center(
                          child: Text(
                            'Yazgan Bileşim Nostalji Radyosu',
                            style: TextStyle(color: Color(0xFFFFD700)),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Dark Screen / Off Filter when Power is OFF
                if (!radioService.isPoweredOn)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),

                // Warm Bulb Backlight Glow over the Dial Area
                if (radioService.isPoweredOn && radioService.dialLightOn)
                  Positioned(
                    top: 155,
                    left: 100,
                    right: 100,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            const Color(0xFFFF9900).withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // Interactive Dial Touch Overlay with Moving Red Needle
                Positioned(
                  top: 155,
                  left: 110,
                  right: 140,
                  height: 85,
                  child: LayoutBuilder(
                    builder: (dialContext, constraints) {
                      final dialW = constraints.maxWidth;
                      void handleX(double localX) {
                        final normX = (localX / dialW).clamp(0.0, 1.0);
                        final band = radioService.currentBand;
                        final newFreq = band.minFrequency + normX * (band.maxFrequency - band.minFrequency);
                        radioService.setFrequency(newFreq);
                      }

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onHorizontalDragUpdate: (details) => handleX(details.localPosition.dx),
                        onTapDown: (details) => handleX(details.localPosition.dx),
                        child: CustomPaint(
                          size: Size(dialW, constraints.maxHeight),
                          painter: _PhotorealisticNeedlePainter(
                            activeBand: radioService.currentBand,
                            currentFrequency: radioService.frequency,
                            isPowered: radioService.isPoweredOn,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Glowing Green EM80 Magic Eye Tube Overlay
                if (radioService.isPoweredOn)
                  Positioned(
                    top: 175,
                    right: 118,
                    width: 38,
                    height: 38,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF66).withValues(
                                alpha: (0.4 + 0.5 * radioService.magicEyeConvergence).clamp(0.1, 0.95),
                              ),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Live Radio Status Info Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF140904),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${radioService.currentBand.turkishTitle} (${radioService.currentBand.internationalTitle})',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          radioService.currentStation != null
                              ? '${radioService.currentStation!.name} [${radioService.currentStation!.cityName}]'
                              : (radioService.isPoweredOn ? 'Frekans Taranıyor... (Atmosferik Parazit)' : 'Cihaz Kapalı'),
                          style: TextStyle(
                            color: radioService.isPoweredOn ? const Color(0xFFFFF8E1) : Colors.grey,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        radioService.frequency >= 100
                            ? '${radioService.frequency.toStringAsFixed(0)} ${radioService.currentBand.unit}'
                            : '${radioService.frequency.toStringAsFixed(2)} ${radioService.currentBand.unit}',
                        style: const TextStyle(
                          color: Color(0xFFFFE57F),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('SİNYAL: ', style: TextStyle(color: Colors.grey, fontSize: 8)),
                          _buildSignalIndicator(radioService.signalStrength, radioService.isPoweredOn),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Control Deck (Band Keys & Rotary Knobs)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1B0F08),
              child: Column(
                children: [
                  // Piano Band Keys
                  BandSelectorWidget(
                    activeBand: radioService.currentBand,
                    onBandSelected: (band) => radioService.setBand(band),
                  ),
                  const SizedBox(height: 12),

                  // Rotary Knobs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Power & Volume
                      VintageKnobWidget(
                        label: 'GÜÇ / SES',
                        value: radioService.volume,
                        hasPowerSwitch: true,
                        isPowerOn: radioService.isPoweredOn,
                        onPowerToggle: radioService.togglePower,
                        onChanged: (val) => radioService.setVolume(val),
                      ),
                      // Tone Filter
                      VintageKnobWidget(
                        label: 'TON (TİZ/BAS)',
                        value: radioService.tone,
                        onChanged: (val) => radioService.setTone(val),
                      ),
                      // Frequency Tuning
                      VintageKnobWidget(
                        label: 'İNCE AYAR',
                        value: ((radioService.frequency - radioService.currentBand.minFrequency) /
                                (radioService.currentBand.maxFrequency - radioService.currentBand.minFrequency))
                            .clamp(0.0, 1.0),
                        onChanged: (val) {
                          final newFreq = radioService.currentBand.minFrequency +
                              val * (radioService.currentBand.maxFrequency - radioService.currentBand.minFrequency);
                          radioService.setFrequency(newFreq);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalIndicator(double strength, bool isPowered) {
    const totalBars = 5;
    final activeCount = isPowered ? (strength * totalBars).round() : 0;

    return Row(
      children: List.generate(totalBars, (index) {
        final isActive = index < activeCount;
        return Container(
          width: 3.5,
          height: 6.0 + index * 2.0,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: isActive ? (index >= 4 ? const Color(0xFF00E676) : const Color(0xFFFFD54F)) : const Color(0xFF332517),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _PhotorealisticNeedlePainter extends CustomPainter {
  final RadioBandType activeBand;
  final double currentFrequency;
  final bool isPowered;

  _PhotorealisticNeedlePainter({
    required this.activeBand,
    required this.currentFrequency,
    required this.isPowered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fraction = ((currentFrequency - activeBand.minFrequency) /
            (activeBand.maxFrequency - activeBand.minFrequency))
        .clamp(0.0, 1.0);

    final needleX = fraction * size.width;

    // Glowing red needle on top of photo dial
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF1744),
          Color(0xFFFF5252),
          Color(0xFFD50000),
        ],
      ).createShader(Rect.fromLTWH(needleX - 1.5, 0, 3, size.height))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    if (isPowered) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFF1744).withValues(alpha: 0.6)
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawLine(Offset(needleX, 0), Offset(needleX, size.height), glowPaint);
    }

    canvas.drawLine(Offset(needleX, 0), Offset(needleX, size.height), needlePaint);
  }

  @override
  bool shouldRepaint(covariant _PhotorealisticNeedlePainter oldDelegate) {
    return oldDelegate.currentFrequency != currentFrequency ||
        oldDelegate.activeBand != activeBand ||
        oldDelegate.isPowered != isPowered;
  }
}
