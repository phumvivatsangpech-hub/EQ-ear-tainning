import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../utils/translations.dart';
import '../widgets/epic_background.dart';
import '../services/audio_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final AudioService _audioService = AudioService();
  String? _playingTitle;

  @override
  void dispose() {
    _audioService.stopLessonTone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final isThai = gameProvider.isThai;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          Translations.get('freq_lesson_btn', isThai),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: EpicBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
        children: [
          _buildFreqCard(
            title: 'Sub Bass',
            range: '20 Hz - 60 Hz',
            description: isThai 
              ? 'เสียงที่ต่ำมากจนรู้สึกได้มากกว่าได้ยิน พบในเสียงกลองใหญ่และเบสหนักๆ ถ้ามากไปเสียงจะขุ่น'
              : 'Very low sound felt more than heard. Found in kick drums and heavy bass. Muddies the mix if too much.',
            color: Colors.red,
            icon: Icons.vibration,
            centerFreq: 40.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Bass',
            range: '60 Hz - 250 Hz',
            description: isThai
              ? 'เสียงเบสที่ได้ยินชัดเจน ให้ความอบอุ่นกับเสียง ถ้ามากเกินไปจะทำให้เสียงทื่อและขาดความชัด'
              : 'Clearly audible bass. Adds warmth to sound. Too much makes the sound boxy and lack clarity.',
            color: Colors.orange,
            icon: Icons.music_note,
            centerFreq: 150.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Low Mid',
            range: '250 Hz - 500 Hz',
            description: isThai
              ? 'ย่านที่ทำให้เสียงอู้อี้หรือทึบ มักถูกตัดออกเพื่อให้เสียงโปร่งขึ้น พบในกีตาร์และเปียโน'
              : 'The mud range. Often cut in mixing to clear up the sound. Found in guitars and acoustic pianos.',
            color: Colors.yellow,
            icon: Icons.equalizer,
            centerFreq: 350.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Mid',
            range: '500 Hz - 2 kHz',
            description: isThai
              ? 'ย่านที่หูมนุษย์ไวที่สุด เสียงพูดและร้องอยู่ย่านนี้ การบูสตรงนี้มากไปทำให้เสียงแหลมและแทงหู'
              : 'Most sensitive range for human ears. Speech and vocals dominate here. Boosting causes piercing thinness.',
            color: Colors.green,
            icon: Icons.hearing,
            centerFreq: 1000.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Upper Mid',
            range: '2 kHz - 6 kHz',
            description: isThai
              ? 'ย่านที่ทำให้เสียงชัดและคม การบูสทำให้ได้ยินเสียงชัดขึ้น แต่ถ้ามากไปจะแสบหูฮาร์ช'
              : 'Adds clarity and edge. Boosting increases presence but too much causes harshness and ear fatigue.',
            color: Colors.teal,
            icon: Icons.graphic_eq,
            centerFreq: 4000.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Presence',
            range: '6 kHz - 10 kHz',
            description: isThai
              ? 'ย่านสิแบลนซ์และความสว่างสว่าง ทำให้เสียงสดและอยู่หน้ามิกซ์'
              : 'Sibilance and brightness. Makes the sound crisp and sit at the front of the mix.',
            color: Colors.blue,
            icon: Icons.surround_sound,
            centerFreq: 8000.0,
          ),
          const SizedBox(height: 12),
          _buildFreqCard(
            title: 'Brilliance',
            range: '10 kHz - 20 kHz',
            description: isThai
              ? 'เสียงสูงสุดที่ได้ยิน ให้ประกาย Air กับเสียง ถ้ามากไปเสียงแหลมบาดหูจี่'
              : 'Highest audible range. Adds air and sparkle. Too much causes hissing and shrillness.',
            color: Colors.purple,
            icon: Icons.star,
            centerFreq: 15000.0,
          ),
        ],
      ),
    ),
   );
  }

  Widget _buildFreqCard({
    required String title,
    required String range,
    required String description,
    required Color color,
    required IconData icon,
    required double centerFreq,
  }) {
    final bool isPlaying = _playingTitle == title;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isPlaying ? 0.25 : 0.1), // Highlight when playing
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isPlaying ? 0.8 : 0.3), width: isPlaying ? 2 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(
              isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
              size: 40,
              color: isPlaying ? Colors.redAccent : color,
            ),
            onPressed: () {
              if (isPlaying) {
                _audioService.stopLessonTone();
                setState(() => _playingTitle = null);
              } else {
                _audioService.playLessonTone(centerFreq);
                setState(() => _playingTitle = title);
              }
            },
          ),
        ],
      ),
    );
  }
}