enum SoundType {
  vocal,       // เสียงร้อง
  music,       // เพลง
  instrument,  // เสียงดนตรี
  speech,      // เสียงพูด
}

class GameState {
  final SoundType selectedSound;  // ประเภทเสียงที่เลือก
  final int currentLevel;         // level ปัจจุบัน
  final int score;                // คะแนนรวม
  final bool isCompleted;         // จบ level นี้แล้วหรือยัง

  GameState({
    this.selectedSound = SoundType.vocal,
    this.currentLevel = 1,
    this.score = 0,
    this.isCompleted = false,
  });

  // คัดลอก GameState และเปลี่ยนค่าบางอย่าง
  GameState copyWith({
    SoundType? selectedSound,
    int? currentLevel,
    int? score,
    bool? isCompleted,
  }) {
    return GameState(
      selectedSound: selectedSound ?? this.selectedSound,
      currentLevel: currentLevel ?? this.currentLevel,
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}