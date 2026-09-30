import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/radio_band.dart';
import 'models/radio_station.dart';
import 'services/audio_radio_service.dart';
import 'widgets/band_selector.dart';
import 'widgets/magic_eye_tube.dart';
import 'widgets/photorealistic_radio_view.dart';
import 'widgets/radio_cabinet.dart';
import 'widgets/station_list_sheet.dart';
import 'widgets/tuning_dial.dart';
import 'widgets/vacuum_tubes_view.dart';
import 'widgets/vintage_knob.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const NostaljiRadyoApp());
}

class NostaljiRadyoApp extends StatelessWidget {
  const NostaljiRadyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarihi Masa Radyosu (1938 Superhet)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0805),
        fontFamily: 'serif',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Antique Gold
          secondary: Color(0xFFFF8C00), // Amber Glow
          surface: Color(0xFF1F140C),
        ),
      ),
      home: const VintageRadioScreen(),
    );
  }
}

class VintageRadioScreen extends StatefulWidget {
  const VintageRadioScreen({super.key});

  @override
  State<VintageRadioScreen> createState() => _VintageRadioScreenState();
}

class _VintageRadioScreenState extends State<VintageRadioScreen> {
  late final AudioRadioService _radioService;
  bool _showTubesChassis = true;
  bool _usePhotorealisticView = true;

  @override
  void initState() {
    super.initState();
    _radioService = AudioRadioService();
    _radioService.addListener(_onRadioUpdate);
  }

  void _onRadioUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _radioService.removeListener(_onRadioUpdate);
    _radioService.dispose();
    super.dispose();
  }

  void _openStationLogbook() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.75,
        child: StationListSheetWidget(
          currentBand: _radioService.currentBand,
          activeStation: _radioService.currentStation,
          onStationSelected: (station) {
            _radioService.tuneToStation(station);
          },
        ),
      ),
    );
  }

  void _openHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF24150C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFB8860B), width: 2),
        ),
        title: Row(
          children: const [
            Icon(Icons.history_edu, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text(
              'İlk Masa Radyolarının Tarihi',
              style: TextStyle(color: Color(0xFFFFE082), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '1930\'lu ve 1940\'lı yıllarda evlerin baş köşesinde yer alan lambalı masa radyoları (Cathedral & Tabletop Superheterodyne), haber alma ve eğlencenin tek penceresiydi.',
                style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 12.5, height: 1.4),
              ),
              SizedBox(height: 10),
              Text(
                '📻 DALGA TÜRLERİ:',
                style: TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '• UZUN DALGA (LW): Kıta çapında binlerce kilometreye ulaşan düşük frekanslı tarihi yayınlar (TRT Polatlı, Droitwich).\n'
                '• ORTA DALGA (MW/AM): Şehir ve bölge istasyonlarının vazgeçilmezi (İstanbul, Çukurova, Antalya Radyoları).\n'
                '• KISA DALGA (SW): Atmosferin İyonosfer tabakasından yansıyarak kıtalararası haber taşıyan yayınlar (BBC, Amerika\'nın Sesi, Moskova).\n'
                '• FM (UKW): 1950\'lerden sonra gelişen yüksek ses kaliteli ultra kısa dalgalar.',
                style: TextStyle(color: Color(0xFFC7B299), fontSize: 11.5, height: 1.45),
              ),
              SizedBox(height: 10),
              Text(
                '👁️ SİHİRLİ GÖZ (MAGIC EYE TUBE):',
                style: TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Kullanıcının istasyona tam ince ayar yapabilmesi için tasarlanmış yeşil fosforlu katot ışınlı EM80/6E5 lambasıdır. Sinyal netleştikçe yeşil ışık kanatları birleşir.',
                style: TextStyle(color: Color(0xFFC7B299), fontSize: 11.5, height: 1.4),
              ),
              SizedBox(height: 10),
              Text(
                '👨‍💻 GELİŞTİRİCİ: Yazgan Bileşim',
                style: TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Bu antika masa radyosu deneyimi Yazgan Bileşim tarafından Flutter mimarisiyle tasarlanmıştır.',
                style: TextStyle(color: Color(0xFFE8DCC4), fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('KAPAT', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Warm vintage room / wooden desk ambient wallpaper
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Color(0xFF24140B),
              Color(0xFF140B06),
              Color(0xFF070402),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Quick Action Bar
                  _buildTopControlBar(),
                  const SizedBox(height: 10),

                  // The Master Vintage Radio Cabinet (Photorealistic or Custom Craft)
                  if (_usePhotorealisticView)
                    PhotorealisticRadioWidget(
                      radioService: _radioService,
                      onOpenLogbook: _openStationLogbook,
                      onToggleChassis: () {
                        setState(() {
                          _showTubesChassis = !_showTubesChassis;
                        });
                      },
                    )
                  else
                    RadioCabinetWidget(
                      isPowered: _radioService.isPoweredOn,
                      signalStrength: _radioService.signalStrength,
                      antennaExtended: _radioService.antennaExtended,
                      onToggleAntenna: _radioService.toggleAntenna,
                      child: Column(
                      children: [
                        // Live Digital/Frequency Status Banner
                        _buildRadioStatusBanner(),
                        const SizedBox(height: 10),

                        // Center Scale Row with Magic Eye Tube + Tuning Dial
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Glowing Green Magic Eye Tube
                            Column(
                              children: [
                                MagicEyeTubeWidget(
                                  convergence: _radioService.magicEyeConvergence,
                                  isPowered: _radioService.isPoweredOn,
                                  isWarmingUp: _radioService.isWarmingUp,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'SİHİRLİ GÖZ\n(MAGIC EYE)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFC49E52),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),

                            // Large Tuning Dial Glass
                            Expanded(
                              child: TuningDialWidget(
                                activeBand: _radioService.currentBand,
                                currentFrequency: _radioService.frequency,
                                isPowered: _radioService.isPoweredOn,
                                dialLightOn: _radioService.dialLightOn,
                                onFrequencyChanged: (newFreq) {
                                  _radioService.setFrequency(newFreq);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Mechanical Band Selector (UZUN / ORTA / KISA / FM)
                        BandSelectorWidget(
                          activeBand: _radioService.currentBand,
                          onBandSelected: (newBand) {
                            _radioService.setBand(newBand);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Trio of Skeuomorphic Rotary Knobs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // 1. Power & Volume Knob
                            VintageKnobWidget(
                              label: 'GÜÇ / SES',
                              value: _radioService.volume,
                              hasPowerSwitch: true,
                              isPowerOn: _radioService.isPoweredOn,
                              onPowerToggle: _radioService.togglePower,
                              onChanged: (val) {
                                _radioService.setVolume(val);
                              },
                            ),

                            // 2. Tone / Bass Filter Knob
                            VintageKnobWidget(
                              label: 'TON (TİZ/BAS)',
                              value: _radioService.tone,
                              onChanged: (val) {
                                _radioService.setTone(val);
                              },
                            ),

                            // 3. Fine Tuning Knob
                            VintageKnobWidget(
                              label: 'İNCE AYAR',
                              value: ((_radioService.frequency - _radioService.currentBand.minFrequency) /
                                      (_radioService.currentBand.maxFrequency - _radioService.currentBand.minFrequency))
                                  .clamp(0.0, 1.0),
                              onChanged: (val) {
                                final newFreq = _radioService.currentBand.minFrequency +
                                    val * (_radioService.currentBand.maxFrequency - _radioService.currentBand.minFrequency);
                                _radioService.setFrequency(newFreq);
                              },
                            ),
                          ],
                        ),

                        // Vacuum Tubes Chassis View (collapsible)
                        if (_showTubesChassis) ...[
                          const SizedBox(height: 14),
                          VacuumTubesViewWidget(
                            isPowered: _radioService.isPoweredOn,
                            isWarmingUp: _radioService.isWarmingUp,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Footer historical subtitle
                  const Text(
                    '1930\'lar Klasiği Ahşap Masa Radyosu • Uzun (LW) • Orta (MW) • Kısa (SW) • FM\nGeliştirici: Yazgan Bileşim',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8D7355),
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopControlBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 580),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF190F09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5A3E20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Station Logbook Button
          TextButton.icon(
            icon: const Icon(Icons.library_music, size: 16, color: Color(0xFFFFD700)),
            label: const Text(
              'İSTASYON GÜNLÜĞÜ',
              style: TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold),
            ),
            onPressed: _openStationLogbook,
          ),

          // Photo / Vector View Toggle
          IconButton(
            tooltip: _usePhotorealisticView ? 'Fotoğraf Modu (Aktif)' : 'Vektör Kasa Modu (Aktif)',
            icon: Icon(
              _usePhotorealisticView ? Icons.photo_camera : Icons.draw,
              color: const Color(0xFFFFD54F),
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _usePhotorealisticView = !_usePhotorealisticView;
              });
            },
          ),

          // Tube Chassis Toggle
          IconButton(
            tooltip: 'Tüp Şasisini Göster/Gizle',
            icon: Icon(
              _showTubesChassis ? Icons.remove_red_eye : Icons.visibility_off,
              color: const Color(0xFFFFB300),
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _showTubesChassis = !_showTubesChassis;
              });
            },
          ),

          // Dial Backlight Toggle
          IconButton(
            tooltip: 'Kadran Işığı',
            icon: Icon(
              _radioService.dialLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              color: _radioService.dialLightOn ? const Color(0xFFFFD54F) : Colors.grey,
              size: 18,
            ),
            onPressed: _radioService.toggleDialLight,
          ),

          // History Information
          IconButton(
            tooltip: 'Radyo Tarihçesi',
            icon: const Icon(Icons.info_outline, color: Color(0xFFC49E52), size: 18),
            onPressed: _openHistoryDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioStatusBanner() {
    final isPowered = _radioService.isPoweredOn;
    final isWarming = _radioService.isWarmingUp;
    final station = _radioService.currentStation;
    final band = _radioService.currentBand;
    final freq = _radioService.frequency;
    final signal = _radioService.signalStrength;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF140D07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF5A4122),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Frequency & Band Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isPowered
                          ? Colors.grey
                          : (isWarming
                              ? const Color(0xFFFF9100)
                              : (station != null ? const Color(0xFF00E676) : const Color(0xFFFF5252))),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${band.turkishTitle} (${band.internationalTitle})',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                station != null ? '${station.name} [${station.cityName}]' : _radioService.audioStatusMessage,
                style: TextStyle(
                  color: isPowered ? const Color(0xFFFFF8E1) : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Right: Exact Frequency & Signal meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                freq >= 100 ? '${freq.toStringAsFixed(0)} ${band.unit}' : '${freq.toStringAsFixed(2)} ${band.unit}',
                style: const TextStyle(
                  color: Color(0xFFFFE57F),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text('SİNYAL: ', style: TextStyle(color: Colors.grey, fontSize: 8)),
                  _buildSignalBars(isPowered ? signal : 0.0),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignalBars(double strength) {
    const totalBars = 5;
    final activeCount = (strength * totalBars).round();

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
