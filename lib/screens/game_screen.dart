import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/eq_band.dart';
import '../data/levels.dart';
import '../widgets/eq_graph.dart';
import '../widgets/audio_player.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<EqBand> _userBands;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _initUserBands();
  }

  void _initUserBands() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentLevel = _getCurrentLevel(gameProvider);

    setState(() {
      _userBands = List<EqBand>.from(
        currentLevel.answer.map((band) {
          return EqBand(
            frequency: (band as EqBand).frequency,
            gain: 0,
            q: band.q,
          );
        }).toList(),
      );
      _showAnswer = false;
    });
  }

  dynamic _getCurrentLevel(GameProvider gameProvider) {
    final soundType = gameProvider.state.selectedSound;
    final levelIndex = gameProvider.state.currentLevel - 1;
    final levels = Levels.getLevels(soundType);
    return levels[levelIndex];
  }

  void _confirmAnswer() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentLevel = _getCurrentLevel(gameProvider);

    int score = gameProvider.calculateScore(
      List<EqBand>.from(currentLevel.answer),
      _userBands,
    );

    gameProvider.addScore(score);
    gameProvider.completeLevel();

    setState(() => _showAnswer = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          score >= 80
              ? '🎉 ยอดเยี่ยม!'
              : score >= 50
                  ? '👍 ดีมาก!'
                  : '💪 ลองใหม่อีกครั้ง!',
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'คะแนน: $score / 100',
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
            onPressed: () {
              Navigator.pop(context);
              _goNextLevel(gameProvider);
            },
            child: const Text(
              'Level ถัดไป',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _goNextLevel(GameProvider gameProvider) {
    final levels = Levels.getLevels(gameProvider.state.selectedSound);

    if (gameProvider.state.currentLevel >= levels.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultScreen()),
      );
    } else {
      gameProvider.nextLevel();
      _initUserBands();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final currentLevel = _getCurrentLevel(gameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Level ${gameProvider.state.currentLevel} — ${currentLevel.title}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'คะแนน: ${gameProvider.state.score}',
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
                currentLevel.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: EqGraph(
                bands: _userBands,
                onBandsChanged: (newBands) {
                  setState(() => _userBands = newBands);
                },
                interactive: !_showAnswer,
                filterType: currentLevel.filterType,
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มเล่นเสียง 2 ปุ่ม
            DualAudioPlayer(
              key: ValueKey(gameProvider.state.currentLevel),
              questionPath: currentLevel.audioQuestion,
              originalPath: currentLevel.audioOriginal,
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
                  child: const Text(
                    'ยืนยันคำตอบ',
                    style: TextStyle(
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
    );
  }
}