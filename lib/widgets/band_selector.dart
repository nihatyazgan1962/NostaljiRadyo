import 'package:flutter/material.dart';
import '../models/radio_band.dart';

class BandSelectorWidget extends StatelessWidget {
  final RadioBandType activeBand;
  final ValueChanged<RadioBandType> onBandSelected;

  const BandSelectorWidget({
    super.key,
    required this.activeBand,
    required this.onBandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E130B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF8B6508),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DALGA SEÇİCİ (WAVE BAND SELECTOR)',
            style: TextStyle(
              color: Color(0xFFC49E52),
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: RadioBandType.values.map((band) {
              final isSelected = band == activeBand;
              return _buildVintagePianoKey(band, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVintagePianoKey(RadioBandType band, bool isSelected) {
    return GestureDetector(
      onTap: () => onBandSelected(band),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 68,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? [
                    const Color(0xFFC49E52),
                    const Color(0xFF8B6508),
                    const Color(0xFF5A4004),
                  ]
                : [
                    const Color(0xFFE8DCC4), // Vintage Ivory / Bakelite piano key
                    const Color(0xFFD0C0A2),
                    const Color(0xFFA89474),
                  ],
          ),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF4A3525),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9900).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(1, 3),
                    blurRadius: 4,
                  ),
                ],
        ),
        transform: isSelected ? Matrix4.translationValues(0, 3, 0) : Matrix4.identity(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getShortName(band),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFF8E1) : const Color(0xFF2E1C0C),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _getSubCode(band),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFECB3) : const Color(0xFF6D533B),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getShortName(RadioBandType band) {
    switch (band) {
      case RadioBandType.uzunDalga:
        return 'UZUN';
      case RadioBandType.ortaDalga:
        return 'ORTA';
      case RadioBandType.kisaDalga:
        return 'KISA';
      case RadioBandType.fm:
        return 'FM';
    }
  }

  String _getSubCode(RadioBandType band) {
    switch (band) {
      case RadioBandType.uzunDalga:
        return 'LW (150k)';
      case RadioBandType.ortaDalga:
        return 'MW (AM)';
      case RadioBandType.kisaDalga:
        return 'SW (MHz)';
      case RadioBandType.fm:
        return 'UKW (MHz)';
    }
  }
}
