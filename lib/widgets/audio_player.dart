import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class DualAudioPlayer extends StatefulWidget {
  final String questionPath;
  final String originalPath;

  const DualAudioPlayer({
    Key? key,
    required this.questionPath,
    required this.originalPath,
  }) : super(key: key);

  @override
  State<DualAudioPlayer> createState() => _DualAudioPlayerState();
}

class _DualAudioPlayerState extends State<DualAudioPlayer> {
  late AudioPlayer _questionPlayer;
  late AudioPlayer _originalPlayer;
  bool _isPlayingOriginal = false;

  @override
  void initState() {
    super.initState();
    _questionPlayer = AudioPlayer();
    _originalPlayer = AudioPlayer();
    _setupPlayers();
  }

  Future<void> _setupPlayers() async {
    try {
      await _questionPlayer.setAsset(widget.questionPath);
      await _questionPlayer.setLoopMode(LoopMode.one);
      await _questionPlayer.play();

      await _originalPlayer.setAsset(widget.originalPath);
      await _originalPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _toggleOriginal() async {
    try {
      if (_isPlayingOriginal) {
        final position = _originalPlayer.position;
        _originalPlayer.pause();
        _questionPlayer.seek(position);
        _questionPlayer.play();
        setState(() => _isPlayingOriginal = false);
      } else {
        final position = _questionPlayer.position;
        _questionPlayer.pause();
        _originalPlayer.seek(position);
        _originalPlayer.play();
        setState(() => _isPlayingOriginal = true);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _questionPlayer.dispose();
    _originalPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isPlayingOriginal
                ? Colors.orange.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_up,
                color: _isPlayingOriginal ? Colors.orange : Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _isPlayingOriginal
                    ? 'กำลังเล่น: ของฉัน'
                    : 'กำลังเล่น: โจทย์',
                style: TextStyle(
                  color: _isPlayingOriginal ? Colors.orange : Colors.blue,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: _toggleOriginal,
          icon: Icon(
            _isPlayingOriginal ? Icons.music_note : Icons.person,
            color: Colors.white,
          ),
          label: Text(
            _isPlayingOriginal ? 'กลับไปฟังโจทย์' : 'ฟังของฉัน',
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPlayingOriginal
                ? Colors.blue.withOpacity(0.8)
                : Colors.orange.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}