import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/translations.dart';
import '../widgets/epic_background.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isThai = gameProvider.isThai;
    final score = gameProvider.state.score;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EpicBackground(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Trophy icon
              Icon(
                score >= 400 ? Icons.emoji_events : Icons.star,
                size: 100,
                color: score >= 400 ? Colors.yellow : Colors.orange,
              ),

              const SizedBox(height: 24),

              // หัวข้อ
              Text(
                _getTitle(score, isThai),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                Translations.get('result_completed', isThai),
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // กล่องคะแนน
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      Translations.get('total_score', isThai),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Translations.get('out_of_500', isThai),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ปุ่มเล่นอีกครั้ง
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    gameProvider.resetGame();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    Translations.get('back_to_home', isThai),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ปุ่มเล่นใหม่ประเภทเดิม
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    gameProvider.resetGame();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    Translations.get('play_again', isThai),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
       ),
      ),
    );
  }

  String _getTitle(int score, bool isThai) {
    if (score >= 400) return Translations.get('result_trophy_1', isThai);
    if (score >= 300) return Translations.get('result_trophy_2', isThai);
    if (score >= 200) return Translations.get('result_trophy_3', isThai);
    return Translations.get('result_trophy_4', isThai);
  }
}