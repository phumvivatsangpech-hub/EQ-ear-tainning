import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../utils/translations.dart';
import '../widgets/epic_background.dart';
import 'game_screen.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isThai = gameProvider.isThai;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          Translations.get('select_category_title', isThai),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: EpicBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translations.get('select_category_title', isThai),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Translations.get('select_subtitle', isThai),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              _buildSoundCard(
                context,
                type: SoundType.vocal,
                title: Translations.get('sound_vocal', isThai).split('\n').first,
                subtitle: Translations.get('sound_vocal', isThai).split('\n').last,
                icon: Icons.mic,
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildSoundCard(
                context,
                type: SoundType.music,
                title: Translations.get('sound_music', isThai).split('\n').first,
                subtitle: Translations.get('sound_music', isThai).split('\n').last,
                icon: Icons.music_note,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildSoundCard(
                context,
                type: SoundType.instrument,
                title: Translations.get('sound_instrument', isThai).split('\n').first,
                subtitle: Translations.get('sound_instrument', isThai).split('\n').last,
                icon: Icons.piano,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildSoundCard(
                context,
                type: SoundType.speech,
                title: Translations.get('sound_speech', isThai).split('\n').first,
                subtitle: Translations.get('sound_speech', isThai).split('\n').last,
                icon: Icons.record_voice_over,
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundCard(
    BuildContext context, {
    required SoundType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final gameProvider = Provider.of<GameProvider>(context);

    return GestureDetector(
      onTap: () {
        gameProvider.selectSound(type);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}