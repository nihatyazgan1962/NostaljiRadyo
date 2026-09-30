import 'dart:math';
import 'package:flutter/material.dart';

class VacuumTubesViewWidget extends StatelessWidget {
  final bool isPowered;
  final bool isWarmingUp;

  const VacuumTubesViewWidget({
    super.key,
    required this.isPowered,
    required this.isWarmingUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF100A06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF6B4C1B),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VAKUM TÜPLERİ ŞASİSİ (VALVE / VACUUM TUBES)',
                style: TextStyle(
                  color: Color(0xFFC49E52),
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                isPowered ? (isWarmingUp ? 'ISINIYOR...' : 'SICAK: 6.3V') : 'SOĞUK',
                style: TextStyle(
                  color: isPowered ? const Color(0xFFFFAB40) : Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _SingleVacuumTube(code: 'ECH81', role: 'Frekans Karıştırıcı', height: 48, width: 22),
              _SingleVacuumTube(code: 'EF89', role: 'Ara Frekans (IF)', height: 44, width: 20),
              _SingleVacuumTube(code: 'EABC80', role: 'Dedektör & Ses', height: 46, width: 21),
              _SingleVacuumTube(code: 'EL84', role: 'Güç Çıkışı (Amfi)', height: 54, width: 25),
              _SingleVacuumTube(code: 'EZ80', role: 'Doğrultucu', height: 48, width: 22),
            ],
          ),
        ],
      ),
    );
  }
}

class _SingleVacuumTube extends StatelessWidget {
  final String code;
  final String role;
  final double height;
  final double width;

  const _SingleVacuumTube({
    required this.code,
    required this.role,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isPowered = (context.findAncestorWidgetOfExactType<VacuumTubesViewWidget>())?.isPowered ?? false;

    return Tooltip(
      message: '$code - $role',
      child: Column(
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(4)),
              color: const Color(0xFF1C130D),
              border: Border.all(
                color: const Color(0xFF888888).withValues(alpha: 0.4),
                width: 1.0,
              ),
              boxShadow: [
                if (isPowered)
                  BoxShadow(
                    color: const Color(0xFFFF5722).withValues(alpha: 0.45),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Internal anode plate
                Container(
                  width: width * 0.6,
                  height: height * 0.6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Glowing Filament
                if (isPowered)
                  Container(
                    width: 4,
                    height: height * 0.45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFFF3D00),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                // Glass reflection
                Positioned(
                  top: 2,
                  left: 2,
                  bottom: 2,
                  child: Container(
                    width: 2.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            code,
            style: const TextStyle(
              color: Color(0xFFC49E52),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
