import 'eq_band.dart';

class LevelData {
  final int levelNumber;
  final String title;
  final String description;
  final String audioQuestion;
  final String audioOriginal;
  final List<EqBand> answer;
  final String filterType;

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.audioQuestion,
    required this.audioOriginal,
    required List<EqBand> answer,
    required this.filterType,
  }) : answer = List<EqBand>.from(answer);
}