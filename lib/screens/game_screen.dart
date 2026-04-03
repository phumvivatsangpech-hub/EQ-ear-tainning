import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_provider.dart';
import '../models/eq_band.dart';
import '../models/level_data.dart';
import '../data/levels.dart';
import '../widgets/eq_graph.dart';
import '../widgets/audio_player.dart';
import 'result_screen.dart';
import '../widgets/epic_background.dart';
import '../utils/translations.dart';
import '../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<EqBand> _userBands = [];
  bool _showAnswer = false;
  LevelData? _currentLevel;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupLevel());
  }

  void _setupLevel() {
    if (!mounted) return;
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    
    final levelData = Levels.generateRandomLevel(
      gameProvider.state.selectedSound,
      gameProvider.state.currentLevel,
    );
    
    setState(() {
      _currentLevel = levelData;
      _showAnswer = false;
      _initUserBands(levelData);
    });

    // Push the target bands to AudioService
    AudioService().updateTargetBands(levelData.answer, levelData.filterType);
  }

  void _initUserBands(LevelData level) {
    _userBands = List<EqBand>.from(
      level.answer.map((band) {
        final b = band;
        double randomFreq;
        double randomGain;

        if (level.filterType == 'lowpass' || level.filterType == 'highpass') {
          final freqOptions = [50.0, 100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0, 10000.0];
          freqOptions.removeWhere((f) => (f - b.frequency).abs() < b.frequency * 0.5);
          randomFreq = freqOptions[_random.nextInt(freqOptions.length)];
          randomGain = 0;
        } else {
          final freqOptions = [100.0, 200.0, 500.0, 1000.0, 2000.0, 5000.0, 8000.0];
          freqOptions.removeWhere((f) => (f - b.frequency).abs() < b.frequency * 0.3);
          randomFreq = freqOptions[_random.nextInt(freqOptions.length)];

          double gain;
          do {
            gain = (_random.nextDouble() * 24 - 12);
          } while ((gain - b.gain).abs() < 4);
          randomGain = gain;
        }

        return EqBand(
          frequency: randomFreq,
          gain: randomGain,
          q: b.q,
        );
      }).toList(),
    );

    // Update AudioService with initial user bands
    AudioService().updateEqBands(_userBands, level.filterType);
  }

  void _confirmAnswer() {
    if (_currentLevel == null) return;
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    int score = gameProvider.calculateScore(
      List<EqBand>.from(_currentLevel!.answer),
      _userBands,
      _currentLevel!.filterType,
    );

    gameProvider.addScore(score);
    gameProvider.completeLevel();

    setState(() => _showAnswer = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isThai = Provider.of<GameProvider>(context, listen: false).isThai;
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(
            score >= 80
                ? Translations.get('great_job', isThai)
                : score >= 50
                    ? Translations.get('very_good', isThai)
                    : Translations.get('try_again', isThai),
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${Translations.get('score_text', isThai)} $score / 100',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                Translations.get('btn_view_answer_graph', isThai),
                style: const TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _goNextLevel();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                Translations.get('btn_next_level', isThai).replaceAll(' ➡️', ''),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goNextLevel() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (gameProvider.state.currentLevel >= 10) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    } else {
      gameProvider.nextLevel();
      _setupLevel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isThai = gameProvider.isThai;

    if (_currentLevel == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return EpicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            '${Translations.get('level_prefix', isThai)} ${gameProvider.state.currentLevel} — ${_currentLevel!.title}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${Translations.get('score_text', isThai)} ${gameProvider.state.score}',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentLevel!.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: EqGraph(
                  bands: _userBands,
                  answerBands: _showAnswer ? List<EqBand>.from(_currentLevel!.answer) : null,
                  onBandsChanged: (newBands) {
                    setState(() => _userBands = newBands);
                  },
                  interactive: !_showAnswer,
                  filterType: _currentLevel!.filterType,
                ),
              ),
              const SizedBox(height: 16),
              DualAudioPlayer(
                key: ValueKey(gameProvider.state.currentLevel),
                originalPath: _currentLevel!.audioOriginal,
              ),
              const SizedBox(height: 16),
              if (!_showAnswer)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      Translations.get('btn_confirm_answer', isThai),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      Translations.get('btn_next_level', isThai),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}