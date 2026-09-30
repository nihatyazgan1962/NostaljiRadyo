import 'package:flutter/material.dart';
import '../models/radio_band.dart';
import '../models/radio_station.dart';

class StationListSheetWidget extends StatelessWidget {
  final RadioBandType currentBand;
  final RadioStation? activeStation;
  final ValueChanged<RadioStation> onStationSelected;

  const StationListSheetWidget({
    super.key,
    required this.currentBand,
    required this.activeStation,
    required this.onStationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allStations = RadioStation.defaultStations;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C120B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0xFFB8860B), width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.menu_book, color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'TARİHİ İSTASYON GÜNLÜĞÜ (LOGBOOK)',
                    style: TextStyle(
                      color: Color(0xFFFFE082),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Uzun (LW), Orta (MW), Kısa (SW) ve FM Dalgalarındaki tarihi istasyonları seçip kadranı otomatik ayarlayabilirsiniz.',
            style: TextStyle(
              color: Color(0xFFC7B299),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable List by Bands
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: RadioBandType.values.map((band) {
                final bandStations = allStations.where((s) => s.band == band).toList();
                return _buildBandSection(context, band, bandStations);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandSection(BuildContext context, RadioBandType band, List<RadioStation> stations) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF26180E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: band == currentBand ? const Color(0xFFB8860B) : const Color(0xFF4A341E),
          width: band == currentBand ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Band Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: band == currentBand ? const Color(0xFF4A2F16) : const Color(0xFF1A1009),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${band.turkishTitle} (${band.internationalTitle})',
                  style: TextStyle(
                    color: band == currentBand ? const Color(0xFFFFD54F) : const Color(0xFFC49E52),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${band.minFrequency.toInt()} - ${band.maxFrequency.toInt()} ${band.unit}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),

          // Stations
          ...stations.map((st) {
            final isCurrent = activeStation?.id == st.id;
            return ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? const Color(0xFFFF5252) : const Color(0xFF3B2515),
                ),
                child: Text(
                  st.frequency >= 100 ? st.frequency.toInt().toString() : st.frequency.toStringAsFixed(1),
                  style: TextStyle(
                    color: isCurrent ? Colors.white : const Color(0xFFFFD54F),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                st.name,
                style: TextStyle(
                  color: isCurrent ? const Color(0xFFFFD54F) : const Color(0xFFFFF8E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${st.cityName} • ${st.genre} (${st.era})',
                style: const TextStyle(
                  color: Color(0xFFB09B82),
                  fontSize: 10,
                ),
              ),
              trailing: isCurrent
                  ? const Icon(Icons.volume_up, color: Color(0xFF00FF66), size: 18)
                  : const Icon(Icons.radio, color: Color(0xFF8B6508), size: 16),
              onTap: () {
                onStationSelected(st);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
