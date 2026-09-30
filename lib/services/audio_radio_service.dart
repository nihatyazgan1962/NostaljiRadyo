import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/radio_band.dart';
import '../models/radio_station.dart';

class AudioRadioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _staticPlayer = AudioPlayer();
  String _activePlayingUrl = '';
  bool _isStaticPlaying = false;

  bool _isPoweredOn = false;
  bool _isWarmingUp = false;
  bool _dialLightOn = true;
  bool _antennaExtended = true;
  
  RadioBandType _currentBand = RadioBandType.fm;
  double _frequency = 92.0; // Starts at Kral FM (92.0 FM)
  double _volume = 0.80;
  double _tone = 0.65; // Vintage warm vacuum tube tone

  double _signalStrength = 0.0;
  RadioStation? _currentStation;
  String _audioStatusMessage = 'Cihaz Kapalı';

  Timer? _warmupTimer;
  Timer? _staticFluctuationTimer;
  double _staticFluctuation = 0.0;

  final List<RadioStation> _allStations = RadioStation.defaultStations;

  AudioRadioService() {
    _startStaticFluctuations();
    _recalculateSignal();
  }

  // Getters
  bool get isPoweredOn => _isPoweredOn;
  bool get isWarmingUp => _isWarmingUp;
  bool get dialLightOn => _dialLightOn;
  bool get antennaExtended => _antennaExtended;
  RadioBandType get currentBand => _currentBand;
  double get frequency => _frequency;
  double get volume => _volume;
  double get tone => _tone;
  double get signalStrength => _signalStrength;
  RadioStation? get currentStation => _currentStation;
  String get audioStatusMessage => _audioStatusMessage;

  // Between 0.0 (perfect tune) and 1.0 (pure static white noise)
  double get staticNoiseLevel {
    if (!_isPoweredOn || _isWarmingUp) return 0.0;
    final baseStatic = (1.0 - _signalStrength).clamp(0.05, 1.0);
    final antennaBonus = _antennaExtended ? 0.0 : 0.2;
    return (baseStatic + antennaBonus + _staticFluctuation * 0.1).clamp(0.0, 1.0) * _volume;
  }

  // Magic Eye Tube Aperture (0.0 = fully open/no signal, 1.0 = fully closed/strongest green beam)
  double get magicEyeConvergence {
    if (!_isPoweredOn || _isWarmingUp) return 0.0;
    return _signalStrength.clamp(0.05, 0.98);
  }

  List<RadioStation> get stationsInCurrentBand {
    return _allStations.where((s) => s.band == _currentBand).toList();
  }

  // Power Toggle with authentic Tube Warm-up behavior
  void togglePower() {
    _isPoweredOn = !_isPoweredOn;
    if (_isPoweredOn) {
      _stopStreamingAudio();
      _updateStaticSound();
      _isWarmingUp = true;
      _audioStatusMessage = 'Vakum Lambaları Isınıyor...';
      notifyListeners();

      _warmupTimer?.cancel();
      _warmupTimer = Timer(const Duration(milliseconds: 1800), () {
        _isWarmingUp = false;
        _recalculateSignal();
        notifyListeners();
      });
    } else {
      _warmupTimer?.cancel();
      _isWarmingUp = false;
      _audioStatusMessage = 'Cihaz Kapalı';
      _currentStation = null;
      _signalStrength = 0.0;
      _stopStreamingAudio();
      _updateStaticSound();
      notifyListeners();
    }
  }

  void toggleDialLight() {
    _dialLightOn = !_dialLightOn;
    notifyListeners();
  }

  void toggleAntenna() {
    _antennaExtended = !_antennaExtended;
    _recalculateSignal();
    notifyListeners();
  }

  void setBand(RadioBandType newBand) {
    if (_currentBand == newBand) return;
    _currentBand = newBand;
    // Set frequency to middle or default first station of the selected band
    final stations = stationsInCurrentBand;
    if (stations.isNotEmpty) {
      _frequency = stations.first.frequency;
    } else {
      _frequency = (_currentBand.minFrequency + _currentBand.maxFrequency) / 2;
    }
    _recalculateSignal();
    notifyListeners();
  }

  void setFrequency(double newFreq) {
    _frequency = newFreq.clamp(_currentBand.minFrequency, _currentBand.maxFrequency);
    _recalculateSignal();
    notifyListeners();
  }

  void tuneRelative(double delta) {
    setFrequency(_frequency + delta * _currentBand.step);
  }

  void tuneToStation(RadioStation station) {
    _currentBand = station.band;
    _frequency = station.frequency;
    _recalculateSignal();
    notifyListeners();
  }

  void setVolume(double val) {
    _volume = val.clamp(0.0, 1.0);
    _updatePlaybackVolume();
    notifyListeners();
  }

  void setTone(double val) {
    _tone = val.clamp(0.0, 1.0);
    notifyListeners();
  }

  void _recalculateSignal() {
    if (!_isPoweredOn || _isWarmingUp) {
      _signalStrength = 0.0;
      _currentStation = null;
      _stopStreamingAudio();
      return;
    }

    final stations = stationsInCurrentBand;
    RadioStation? closestStation;
    double maxMatchStrength = 0.0;

    // Tolerance band depends on frequency scale type (wider capture for easier tuning)
    double tolerance = _currentBand == RadioBandType.kisaDalga
        ? 0.35
        : (_currentBand == RadioBandType.fm ? 0.65 : (_currentBand == RadioBandType.uzunDalga ? 9.0 : 25.0));

    for (final station in stations) {
      final diff = (station.frequency - _frequency).abs();
      if (diff <= tolerance) {
        // Gaussian bell curve falloff
        final strength = exp(-0.5 * pow(diff / (tolerance * 0.45), 2));
        if (strength > maxMatchStrength) {
          maxMatchStrength = strength;
          closestStation = station;
        }
      }
    }

    // Apply antenna effect
    if (!_antennaExtended) {
      maxMatchStrength *= 0.65;
    }

    _signalStrength = maxMatchStrength;
    _currentStation = maxMatchStrength > 0.45 ? closestStation : null;

    if (_currentStation != null) {
      if (_signalStrength > 0.85) {
        _audioStatusMessage = 'Yayın Net: ${_currentStation!.name} (${_currentStation!.cityName})';
      } else {
        _audioStatusMessage = 'Cızırtılı Alış: ${_currentStation!.name}';
      }
      _syncStreamingAudio(_currentStation!, _signalStrength);
    } else {
      _audioStatusMessage = 'Frekans Taranıyor (${_currentBand.turkishTitle}) - Atmosferik Parazit';
      _stopStreamingAudio();
    }
    _updateStaticSound();
  }

  void _updateStaticSound() {
    if (!_isPoweredOn || _isWarmingUp) {
      if (_isStaticPlaying) {
        _isStaticPlaying = false;
        _staticPlayer.stop().catchError((_) {});
      }
      return;
    }

    // Static is loud when not tuned to a station, and fades away when tuned
    final baseStaticVolume = (1.0 - _signalStrength * 0.90).clamp(0.06, 1.0);
    final effectiveStaticVolume = (baseStaticVolume * _volume * 0.45).clamp(0.0, 1.0);

    if (!_isStaticPlaying) {
      _isStaticPlaying = true;
      _staticPlayer.setReleaseMode(ReleaseMode.loop);
      _staticPlayer.setVolume(effectiveStaticVolume);
      _staticPlayer.play(AssetSource('audio/radio_static.wav')).catchError((_) {});
    } else {
      _staticPlayer.setVolume(effectiveStaticVolume);
    }
  }

  void _syncStreamingAudio(RadioStation station, double signal) {
    final effectiveVolume = (_volume * signal).clamp(0.0, 1.0);
    if (_activePlayingUrl != station.streamUrl) {
      _activePlayingUrl = station.streamUrl;
      _audioPlayer.setVolume(effectiveVolume);
      _audioPlayer.play(UrlSource(station.streamUrl)).catchError((_) {});
    } else {
      _audioPlayer.setVolume(effectiveVolume);
    }
  }

  void _updatePlaybackVolume() {
    if (_currentStation != null && _isPoweredOn && !_isWarmingUp) {
      final effectiveVolume = (_volume * _signalStrength).clamp(0.0, 1.0);
      _audioPlayer.setVolume(effectiveVolume);
    }
    _updateStaticSound();
  }

  void _stopStreamingAudio() {
    if (_activePlayingUrl.isNotEmpty) {
      _activePlayingUrl = '';
      _audioPlayer.stop().catchError((_) {});
    }
  }

  void _startStaticFluctuations() {
    _staticFluctuationTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (_isPoweredOn) {
        _staticFluctuation = (Random().nextDouble() - 0.5) * 0.2;
        if (!_isWarmingUp) {
          _updateStaticSound();
        }
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _warmupTimer?.cancel();
    _staticFluctuationTimer?.cancel();
    _audioPlayer.dispose();
    _staticPlayer.dispose();
    super.dispose();
  }
}
