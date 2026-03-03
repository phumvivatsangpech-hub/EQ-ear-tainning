import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/eq_band.dart';
import '../data/levels.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState();

  GameState get state => _state;

  void selectSound(SoundType type) {
    _state = _state.copyWith(
      selectedSound: type,
      currentLevel: 1,
      score: 0,
    );
    notifyListeners();
  }

  void addScore(int points) {
    _state = _state.copyWith(
      score: _state.score + points,
    );
    notifyListeners();
  }

  void nextLevel() {
    _state = _state.copyWith(
      currentLevel: _state.currentLevel + 1,
      isCompleted: false,
    );
    notifyListeners();
  }

  void completeLevel() {
    _state = _state.copyWith(isCompleted: true);
    notifyListeners();
  }

  void resetGame() {
    _state = GameState();
    notifyListeners();
  }

  int calculateScore(List<EqBand> answer, List<EqBand> userAnswer) {
    if (answer.length != userAnswer.length) return 0;

    // ดึง filterType ของ level ปัจจุบัน
    final levels = Levels.getLevels(_state.selectedSound);
    final currentLevel = levels[_state.currentLevel - 1];
    final filterType = currentLevel.filterType;

    double totalError = 0;

    for (int i = 0; i < answer.length; i++) {
      double freqError = (answer[i].frequency - userAnswer[i].frequency).abs();

      if (filterType == 'lowpass' || filterType == 'highpass') {
        // Low/High Pass คิดแค่ frequency อย่างเดียว
        // ถ้าต่างกันไม่เกิน 100Hz ถือว่าเกือบถูก
        totalError += freqError / 500;
      } else {
        // Bell และ Multi คิดทั้ง frequency และ gain
        double gainError = (answer[i].gain - userAnswer[i].gain).abs();
        totalError += freqError / 1000 + gainError / 12;
      }
    }

    int score = (100 - totalError * 50).clamp(0, 100).toInt();
    return score;
  }
}