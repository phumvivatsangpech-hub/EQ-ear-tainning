import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/translations.dart';
import '../widgets/epic_background.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({Key? key}) : super(key: key);

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Provider.of<GameProvider>(context).isThai;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(Translations.get('manual_title', isThai), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: EpicBackground(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              Translations.get('manual_welcome', isThai),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Translations.get('manual_desc', isThai),
              style: const TextStyle(fontSize: 16, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            _buildSection(
              Translations.get('manual_section1_title', isThai),
              Translations.get('manual_section1_desc', isThai),
              Icons.track_changes,
              Colors.greenAccent,
            ),

            _buildSection(
              Translations.get('manual_section2_title', isThai),
              Translations.get('manual_section2_desc', isThai),
              Icons.play_circle_filled,
              Colors.blueAccent,
            ),

            _buildSection(
              Translations.get('manual_section3_title', isThai),
              Translations.get('manual_section3_desc', isThai),
              Icons.power_settings_new,
              Colors.redAccent,
            ),

            _buildSection(
              Translations.get('manual_section4_title', isThai),
              Translations.get('manual_section4_desc', isThai),
              Icons.insights,
              Colors.yellowAccent,
            ),

            _buildSection(
              Translations.get('manual_section5_title', isThai),
              Translations.get('manual_section5_desc', isThai),
              Icons.fact_check,
              Colors.orangeAccent,
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(Translations.get('manual_got_it', isThai), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
