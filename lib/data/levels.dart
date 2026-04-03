import 'dart:math';
import '../models/level_data.dart';
import '../models/eq_band.dart';
import '../models/game_state.dart';

class Levels {
  static final _random = Random();

  static final Map<SoundType, List<String>> _assets = {
    SoundType.vocal: [
      'assets/audio/vocal/level1_original.mp3',
      'assets/audio/vocal/level2_original.mp3',
    ],
    SoundType.music: [
      'assets/audio/music/level1_original.mp3',
      'assets/audio/music/level2_original.mp3',
      'assets/audio/music/level3_original.mp3',
    ],
    SoundType.instrument: [
      'assets/audio/instrument/level1_original.mp3',
      'assets/audio/instrument/level2_original.mp3',
    ],
    SoundType.speech: [
      'assets/audio/speech/level1_original.mp3',
      'assets/audio/speech/level2_original.mp3',
    ],
  };

  static LevelData generateRandomLevel(SoundType type, int levelNumber) {
    final availableAssets = _assets[type] ?? _assets[SoundType.music]!;
    final asset = availableAssets[_random.nextInt(availableAssets.length)];

    // Randomize filter type based on level
    String filterType;
    if (levelNumber == 1) {
      filterType = 'lowpass';
    } else if (levelNumber == 2) {
      filterType = 'highpass';
    } else if (levelNumber <= 4) {
      filterType = 'bell';
    } else {
      filterType = 'multi';
    }

    List<EqBand> answerBands = [];
    String title = '';
    String description = '';

    if (filterType == 'lowpass') {
      double freq = [200.0, 500.0, 1000.0, 2000.0][_random.nextInt(4)];
      answerBands.add(EqBand(frequency: freq, gain: -12, q: 0.7));
      title = 'Low Pass Filter';
      description = 'ตัดความถี่สูงออก เหลือแต่เสียงต่ำ';
    } else if (filterType == 'highpass') {
      double freq = [400.0, 800.0, 1500.0, 3000.0][_random.nextInt(4)];
      answerBands.add(EqBand(frequency: freq, gain: -12, q: 0.7));
      title = 'High Pass Filter';
      description = 'ตัดความถี่ต่ำออก เหลือแต่เสียงสูง';
    } else if (filterType == 'bell') {
      double freq = [100.0, 250.0, 500.0, 1000.0, 2000.0, 4000.0, 8000.0][_random.nextInt(7)];
      double gain = _random.nextBool() ? 12.0 : -12.0;
      answerBands.add(EqBand(frequency: freq, gain: gain, q: 1.0));
      title = gain > 0 ? 'Bell Boost' : 'Bell Cut';
      description = gain > 0 ? 'บูสเสียงย่านความถี่เฉพาะจุด' : 'ตัดเสียงย่านความถี่เฉพาะจุด';
    } else {
      // Multi
      answerBands.add(EqBand(
        frequency: [100.0, 200.0, 500.0][_random.nextInt(3)],
        gain: _random.nextBool() ? 10.0 : -10.0,
        q: 1.0,
      ));
      answerBands.add(EqBand(
        frequency: [2000.0, 4000.0, 8000.0][_random.nextInt(3)],
        gain: _random.nextBool() ? 10.0 : -10.0,
        q: 1.0,
      ));
      title = 'Multi Band';
      description = 'ปรับหลายย่านความถี่พร้อมกัน';
    }

    return LevelData(
      levelNumber: levelNumber,
      title: title,
      description: description,
      audioQuestion: '', // Not used anymore
      audioOriginal: asset,
      filterType: filterType,
      answer: answerBands,
    );
  }

  // Legacy support for other screens if needed
  static List<LevelData> getLevels(SoundType type) {
    return List.generate(5, (i) => generateRandomLevel(type, i + 1));
  }
}