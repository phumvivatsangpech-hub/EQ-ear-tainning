import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/eq_band.dart';
import 'dart:math';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  SoLoud? _soloud;
  SoundHandle? _audioHandle;
  AudioSource? _audioSource;
  AudioData? _audioData;

  bool _isInit = false;
  bool _isPlayingOriginal = false;
  bool _isBypassMyEq = false;
  List<EqBand> _currentBands = [];
  String _currentFilterType = 'bell';
  
  List<EqBand> _targetBands = [];
  String _targetFilterType = 'bell';

  bool _filtersAdded = false;

  bool get isPlayingOriginal => _isPlayingOriginal;
  bool get isBypassMyEq => _isBypassMyEq;

  // New method to fetch FFT
  List<double> getFft() {
    if (!_isInit || _soloud == null || _audioHandle == null || _audioData == null) {
      return List<double>.filled(256, 0.0);
    }
    try {
      _audioData!.updateSamples();
      return List<double>.generate(256, (i) => _audioData!.getLinearFft(SampleLinear(i)));
    } catch (e) {
      return List<double>.filled(256, 0.0);
    }
  }

  Future<void> init() async {
    if (_isInit) return;
    _soloud = SoLoud.instance;
    await _soloud!.init();
    _soloud!.setVisualizationEnabled(true);
    _audioData = AudioData(GetSamplesKind.linear);
    _isInit = true;
  }

  Future<void> loadAudio(String audioPath) async {
    if (!_isInit) await init();

    // Reset states
    _isPlayingOriginal = false; // Start by listening to the problem
    _isBypassMyEq = false;
    _currentBands = [];

    await disposeAudio(); // Keep lesson tone out of this unless needed

    try {
      _audioSource = await _soloud!.loadAsset(audioPath);
    } catch (e) {
      debugPrint('Error loading audio: $e');
      throw Exception('Failed to load asset: $audioPath. $e');
    }
  }

  Future<void> play() async {
    if (_audioSource == null) return;

    try {
      if (_audioHandle == null) {
        _audioHandle = await _soloud!.play(_audioSource!, looping: true);
      }
      _applyCurrentState();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> toggleOriginal() async {
    if (!_isInit) return;
    _isPlayingOriginal = !_isPlayingOriginal;
    _applyCurrentState();
    notifyListeners();
  }

  Future<void> toggleBypassMyEq() async {
    if (!_isInit) return;
    _isBypassMyEq = !_isBypassMyEq;
    _applyCurrentState();
    notifyListeners();
  }

  void updateTargetBands(List<EqBand> bands, String filterType) {
    _targetBands = bands;
    _targetFilterType = filterType;
    if (!_isPlayingOriginal) {
      _applyCurrentState();
    }
  }

  void updateEqBands(List<EqBand> bands, String filterType) {
    _currentBands = bands;
    _currentFilterType = filterType;
    if (_isPlayingOriginal && !_isBypassMyEq) {
      _applyCurrentState();
    }
  }

  void _applyCurrentState() {
    if (!_isInit || _audioHandle == null) return;

    if (!_filtersAdded) {
      try {
        _soloud!.addGlobalFilter(FilterType.biquadResonantFilter);
        _soloud!.addGlobalFilter(FilterType.eqFilter);
        _filtersAdded = true;
      } catch (e) {
        debugPrint('Error adding filters: $e');
      }
    }

    if (!_isPlayingOriginal) {
      // Listen to Target (Problem)
      _applyFilters(_targetBands, _targetFilterType);
    } else if (_isPlayingOriginal && _isBypassMyEq) {
      // Listen Mine Bypass (Flat / Wet=0)
      _soloud!.setFilterParameter(FilterType.biquadResonantFilter, 0, 0.0);
      _soloud!.setFilterParameter(FilterType.eqFilter, 0, 0.0);
    } else {
      // Listen Mine (User EQ)
      _applyFilters(_currentBands, _currentFilterType);
    }
  }

  void _applyFilters(List<EqBand> bands, String filterType) {
    if (bands.isEmpty) return;

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
      _lessonSource ??= await _soloud!.loadAsset('assets/audio/music/level1_original.mp3');
      
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
    if (_audioHandle != null) _soloud?.stop(_audioHandle!);
    if (_audioSource != null) await _soloud?.disposeSource(_audioSource!);
    if (_lessonSource != null) await _soloud?.disposeSource(_lessonSource!);
    _audioHandle = null;
    _audioSource = null;
    _lessonSource = null;
  }

  @override
  void dispose() {
    _audioData?.dispose();
    super.dispose();
  }
}
