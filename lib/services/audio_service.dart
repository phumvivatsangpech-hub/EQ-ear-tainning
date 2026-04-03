import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/eq_band.dart';
import 'dart:math';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  SoLoud? _soloud;
  SoundHandle? _questionHandle;
  SoundHandle? _originalHandle;
  AudioSource? _questionSource;
  AudioSource? _originalSource;

  bool _isInit = false;
  bool _isPlayingOriginal = false;
  bool _isBypassMyEq = false;
  List<EqBand> _currentBands = [];
  String _currentFilterType = 'bell';
  bool _filtersAdded = false;

  bool get isPlayingOriginal => _isPlayingOriginal;
  bool get isBypassMyEq => _isBypassMyEq;

  Future<void> init() async {
    if (_isInit) return;
    _soloud = SoLoud.instance;
    await _soloud!.init();
    _isInit = true;
  }

  Future<void> loadAudio(String questionPath, String originalPath) async {
    if (!_isInit) await init();

    // Reset to question track on every new level load
    _isPlayingOriginal = false;
    _isBypassMyEq = false;
    _currentBands = [];

    // Clean up previous sources if any
    await disposeAudio();

    try {
      _questionSource = await _soloud!.loadAsset(questionPath);
      _originalSource = await _soloud!.loadAsset(originalPath);
    } catch (e) {
      debugPrint('Error loading audio: $e');
      throw Exception('Failed to load asset: $questionPath or $originalPath. $e');
    }
  }

  Future<void> play() async {
    if (_questionSource == null || _originalSource == null) return;

    try {
      // Pause if already playing to restart or swap
      if (_questionHandle != null) _soloud!.stop(_questionHandle!);
      if (_originalHandle != null) _soloud!.stop(_originalHandle!);

      if (_isPlayingOriginal) {
        _originalHandle = await _soloud!.play(_originalSource!, looping: true);
      } else {
        _questionHandle = await _soloud!.play(_questionSource!, looping: true);
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> toggleOriginal() async {
    if (!_isInit) return;
    _isPlayingOriginal = !_isPlayingOriginal;

    if (!_isPlayingOriginal || _isBypassMyEq) { // "โจทย์" (Problem) is playing or Bypass EQ is enabled, bypass EQ
      if (_filtersAdded) {
        // Bypass both filters by setting Wet to 0
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 0.0);
        _soloud!.setFilterParameter(FilterType.eqFilter, 0, 0.0);
      }
    } else { // "ของฉัน" (My EQ) is playing and NOT bypassed, apply EQ
      if (_currentBands.isNotEmpty) {
        updateEqBands(_currentBands, _currentFilterType);
      }
    }

    await play(); // Re-trigger play to swap sources
    notifyListeners();
  }

  Future<void> toggleBypassMyEq() async {
    if (!_isInit) return;
    _isBypassMyEq = !_isBypassMyEq;
    
    if (_isPlayingOriginal) {
      if (_isBypassMyEq) {
        if (_filtersAdded) {
          _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 0.0);
          _soloud!.setFilterParameter(FilterType.eqFilter, 0, 0.0);
        }
      } else {
        if (_currentBands.isNotEmpty) {
          updateEqBands(_currentBands, _currentFilterType);
        }
      }
    }
    notifyListeners();
  }

  void updateEqBands(List<EqBand> bands, String filterType) {
    _currentBands = bands;
    _currentFilterType = filterType;

    if (!_isInit || _questionHandle == null) return;

    if (!_filtersAdded) {
      try {
        _soloud!.addGlobalFilter(FilterType.biquadResonantFilter);
        _soloud!.addGlobalFilter(FilterType.eqFilter);
        _filtersAdded = true;
      } catch (e) {
        debugPrint('Error adding filters: $e');
      }
    }

    // If playing "โจทย์" (Problem) or Bypass EQ is enabled, ensure bypassed (flat)
    if (!_isPlayingOriginal || _isBypassMyEq) {
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 0.0);
      _soloud!.setFilterParameter(FilterType.eqFilter, 0, 0.0);
      return;
    }

    bool isBiquad = (filterType == 'lowpass' || filterType == 'highpass');
    
    // Set Wet flags appropriately (My EQ is playing)
    _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, isBiquad ? 1.0 : 0.0);
    _soloud!.setFilterParameter(FilterType.eqFilter, 0, isBiquad ? 0.0 : 1.0);

    for (var i = 0; i < bands.length; i++) {
      final band = bands[i];

      if (filterType == 'lowpass') {
        // SoLoud: LOWPASS=0, HIGHPASS=1, BANDPASS=2 | Freq range: 10-8000 Hz
        double clampedFreq = band.frequency.clamp(10.0, 8000.0);
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 1, 0.0); // Type: 0 = Lowpass
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 2, clampedFreq);
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 3, 2.0); // Resonance
      } else if (filterType == 'highpass') {
        double clampedFreq = band.frequency.clamp(10.0, 8000.0);
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 1, 1.0); // Type: 1 = Highpass
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 2, clampedFreq);
        _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 3, 2.0); // Resonance
      } else if (filterType == 'bell' || filterType == 'multi') {
        // Multi-band bell: accumulate gains across all bands FIRST,
        // then write to SoLoud in one pass to avoid overwriting between bands.
        List<double> bandGains = List.filled(8, 1.0); // start flat

        for (var i = 0; i < bands.length; i++) {
          final b = bands[i];
          // SoLoud sqrt-scale mapping: band = sqrt(freq / 22050) * 8
          double cFreq = b.frequency.clamp(20.0, 22050.0);
          double centerBandF = sqrt(cFreq / 22050.0) * 8.0;

          // dB -> linear multiplier (flat = 1.0, max = 4.0)
          double linearGain = pow(10, b.gain / 20).toDouble().clamp(0.0, 4.0);

          // Tight Gaussian bell (sigma=0.8) to avoid spreading harshness
          const double sigma = 0.8;
          for (int bIdx = 0; bIdx < 8; bIdx++) {
            double distance = (bIdx - centerBandF).abs();
            double weight = exp(-0.5 * pow(distance / sigma, 2));
            bandGains[bIdx] = bandGains[bIdx] + (linearGain - bandGains[bIdx]) * weight;
          }
        }

        // Write all 8 bands in one pass
        for (int bIdx = 0; bIdx < 8; bIdx++) {
          _soloud!.setFilterParameter(FilterType.eqFilter, bIdx + 1, bandGains[bIdx].clamp(0.0, 4.0));
        }
        break; // Bell handles all bands internally, stop outer loop
      }
    }
  }


  SoundHandle? _lessonHandle;
  AudioSource? _lessonSource;

  Future<void> playLessonTone(double centerFreq) async {
    if (!_isInit) await init();
    stopLessonTone();

    try {
      _lessonSource ??= await _soloud!.loadAsset('assets/audio/music/music_problem_1.mp3');
      
      // Apply Bandpass filter
      if (!_filtersAdded) {
        _soloud!.addGlobalFilter(FilterType.biquadResonantFilter);
        _soloud!.addGlobalFilter(FilterType.eqFilter);
        _filtersAdded = true;
      }
      
      // Turn off EQ filter, Turn on Biquad as Bandpass
      _soloud!.setFilterParameter(FilterType.eqFilter, 0, 0.0);
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 1.0); // Wet = 1
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 1, 2.0); // 2 = Bandpass
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 2, centerFreq);
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 3, 4.0); // High resonance for isolation
      
      _lessonHandle = await _soloud!.play(_lessonSource!, looping: true);
    } catch (e) {
      debugPrint("Error playing lesson tone: \$e");
    }
  }

  void stopLessonTone() {
    if (_lessonHandle != null) {
      _soloud!.stop(_lessonHandle!);
      _lessonHandle = null;
    }
    if (_isInit && _filtersAdded) {
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 0.0);
    }
  }

  Future<void> disposeAudio() async {
    stopLessonTone();
    if (_questionHandle != null) _soloud?.stop(_questionHandle!);
    if (_originalHandle != null) _soloud?.stop(_originalHandle!);
    if (_questionSource != null) await _soloud?.disposeSource(_questionSource!);
    if (_originalSource != null) await _soloud?.disposeSource(_originalSource!);
    if (_lessonSource != null) await _soloud?.disposeSource(_lessonSource!);
    _questionHandle = null;
    _originalHandle = null;
    _questionSource = null;
    _originalSource = null;
    _lessonSource = null;
  }
}
