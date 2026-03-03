import '../models/level_data.dart';
import '../models/eq_band.dart';
import '../models/game_state.dart';

class Levels {
  static List<LevelData> vocal = [
    LevelData(
      levelNumber: 1,
      title: 'Low Pass Filter',
      description: 'ตัดความถี่สูงออก เหลือแต่เสียงต่ำ',
      audioQuestion: 'assets/audio/vocal/level1_question.mp3',
      audioOriginal: 'assets/audio/vocal/level1_original.mp3',
      filterType: 'lowpass',
      answer: <EqBand>[
        EqBand(frequency: 500, gain: -12, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 2,
      title: 'High Pass Filter',
      description: 'ตัดความถี่ต่ำออก เหลือแต่เสียงสูง',
      audioQuestion: 'assets/audio/vocal/level2_question.mp3',
      audioOriginal: 'assets/audio/vocal/level2_original.mp3',
      filterType: 'highpass',
      answer: <EqBand>[
        EqBand(frequency: 800, gain: -12, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 3,
      title: 'Bell Boost',
      description: 'บูสเสียงกลางแบบ Bell curve',
      audioQuestion: 'assets/audio/vocal/level3_question.mp3',
      audioOriginal: 'assets/audio/vocal/level3_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 1000, gain: 6, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 4,
      title: 'Bell Cut',
      description: 'ตัดเสียงกลางแบบ Bell curve',
      audioQuestion: 'assets/audio/vocal/level4_question.mp3',
      audioOriginal: 'assets/audio/vocal/level4_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 3000, gain: -12, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 5,
      title: 'Multi Band',
      description: 'ปรับหลาย band พร้อมกัน',
      audioQuestion: 'assets/audio/vocal/level5_question.mp3',
      audioOriginal: 'assets/audio/vocal/level5_original.mp3',
      filterType: 'multi',
      answer: <EqBand>[
        EqBand(frequency: 200, gain: -12, q: 1.0),
        EqBand(frequency: 3000, gain: 6, q: 1.0),
      ],
    ),
  ];

  static List<LevelData> music = [
    LevelData(
      levelNumber: 1,
      title: 'Low Pass Filter',
      description: 'ตัดความถี่สูงออก เหลือแต่เสียงต่ำ',
      audioQuestion: 'assets/audio/music/level1_question.mp3',
      audioOriginal: 'assets/audio/music/level1_original.mp3',
      filterType: 'lowpass',
      answer: <EqBand>[
        EqBand(frequency: 800, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 2,
      title: 'High Pass Filter',
      description: 'ตัดความถี่ต่ำออก เหลือแต่เสียงสูง',
      audioQuestion: 'assets/audio/music/level2_question.mp3',
      audioOriginal: 'assets/audio/music/level2_original.mp3',
      filterType: 'highpass',
      answer: <EqBand>[
        EqBand(frequency: 600, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 3,
      title: 'Bell Boost',
      description: 'บูสเสียงสูงแบบ Bell curve',
      audioQuestion: 'assets/audio/music/level3_question.mp3',
      audioOriginal: 'assets/audio/music/level3_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 5000, gain: 6, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 4,
      title: 'Bell Cut',
      description: 'ตัดเสียงต่ำกลางแบบ Bell curve',
      audioQuestion: 'assets/audio/music/level4_question.mp3',
      audioOriginal: 'assets/audio/music/level4_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 500, gain: -6, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 5,
      title: 'Multi Band',
      description: 'ปรับหลาย band พร้อมกัน',
      audioQuestion: 'assets/audio/music/level5_question.mp3',
      audioOriginal: 'assets/audio/music/level5_original.mp3',
      filterType: 'multi',
      answer: <EqBand>[
        EqBand(frequency: 100, gain: 6, q: 0.7),
        EqBand(frequency: 8000, gain: -6, q: 1.0),
      ],
    ),
  ];

  static List<LevelData> instrument = [
    LevelData(
      levelNumber: 1,
      title: 'Low Pass Filter',
      description: 'ตัดความถี่สูงออก เหลือแต่เสียงต่ำ',
      audioQuestion: 'assets/audio/instrument/level1_question.mp3',
      audioOriginal: 'assets/audio/instrument/level1_original.mp3',
      filterType: 'lowpass',
      answer: <EqBand>[
        EqBand(frequency: 1000, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 2,
      title: 'High Pass Filter',
      description: 'ตัดความถี่ต่ำออก เหลือแต่เสียงสูง',
      audioQuestion: 'assets/audio/instrument/level2_question.mp3',
      audioOriginal: 'assets/audio/instrument/level2_original.mp3',
      filterType: 'highpass',
      answer: <EqBand>[
        EqBand(frequency: 400, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 3,
      title: 'Bell Boost',
      description: 'บูสเสียงกลางสูงแบบ Bell curve',
      audioQuestion: 'assets/audio/instrument/level3_question.mp3',
      audioOriginal: 'assets/audio/instrument/level3_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 2000, gain: 8, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 4,
      title: 'Bell Cut',
      description: 'ตัดเสียงต่ำแบบ Bell curve',
      audioQuestion: 'assets/audio/instrument/level4_question.mp3',
      audioOriginal: 'assets/audio/instrument/level4_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 200, gain: -8, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 5,
      title: 'Multi Band',
      description: 'ปรับหลาย band พร้อมกัน',
      audioQuestion: 'assets/audio/instrument/level5_question.mp3',
      audioOriginal: 'assets/audio/instrument/level5_original.mp3',
      filterType: 'multi',
      answer: <EqBand>[
        EqBand(frequency: 500, gain: 6, q: 1.0),
        EqBand(frequency: 5000, gain: -6, q: 1.0),
      ],
    ),
  ];

  static List<LevelData> speech = [
    LevelData(
      levelNumber: 1,
      title: 'Low Pass Filter',
      description: 'ตัดความถี่สูงออก เหลือแต่เสียงต่ำ',
      audioQuestion: 'assets/audio/speech/level1_question.mp3',
      audioOriginal: 'assets/audio/speech/level1_original.mp3',
      filterType: 'lowpass',
      answer: <EqBand>[
        EqBand(frequency: 600, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 2,
      title: 'High Pass Filter',
      description: 'ตัดความถี่ต่ำออก เหลือแต่เสียงสูง',
      audioQuestion: 'assets/audio/speech/level2_question.mp3',
      audioOriginal: 'assets/audio/speech/level2_original.mp3',
      filterType: 'highpass',
      answer: <EqBand>[
        EqBand(frequency: 300, gain: -12, q: 0.7),
      ],
    ),
    LevelData(
      levelNumber: 3,
      title: 'Bell Boost',
      description: 'บูสเสียงกลางแบบ Bell curve',
      audioQuestion: 'assets/audio/speech/level3_question.mp3',
      audioOriginal: 'assets/audio/speech/level3_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 1500, gain: 6, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 4,
      title: 'Bell Cut',
      description: 'ตัดเสียงกลางแบบ Bell curve',
      audioQuestion: 'assets/audio/speech/level4_question.mp3',
      audioOriginal: 'assets/audio/speech/level4_original.mp3',
      filterType: 'bell',
      answer: <EqBand>[
        EqBand(frequency: 2000, gain: -6, q: 1.0),
      ],
    ),
    LevelData(
      levelNumber: 5,
      title: 'Multi Band',
      description: 'ปรับหลาย band พร้อมกัน',
      audioQuestion: 'assets/audio/speech/level5_question.mp3',
      audioOriginal: 'assets/audio/speech/level5_original.mp3',
      filterType: 'multi',
      answer: <EqBand>[
        EqBand(frequency: 300, gain: -6, q: 0.7),
        EqBand(frequency: 2000, gain: 6, q: 1.0),
      ],
    ),
  ];

  static List<LevelData> getLevels(SoundType type) {
    switch (type) {
      case SoundType.vocal:
        return vocal;
      case SoundType.music:
        return music;
      case SoundType.instrument:
        return instrument;
      case SoundType.speech:
        return speech;
    }
  }
}