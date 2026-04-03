import 'package:flutter/material.dart';
import '../services/audio_service.dart';

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
  final AudioService _audioService = AudioService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onAudioStateChanged);
    // Auto-start playing the question track immediately
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupAudio());
  }

  Future<void> _setupAudio() async {
    try {
      if (mounted) setState(() { _isLoading = true; _errorMessage = null; });
      await _audioService.init();
      await _audioService.loadAudio(widget.questionPath, widget.originalPath);
      await _audioService.play();
    } catch (e) {
      debugPrint('Audio Setup Error: $e');
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onAudioStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _audioService.removeListener(_onAudioStateChanged);
    _audioService.disposeAudio(); // Stop audio and free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading Audio Engine...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Audio Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _setupAudio, child: const Text('Retry'))
          ],
        ),
      );
    }

    final isPlayingOriginal = _audioService.isPlayingOriginal;
    final isBypassMyEq = _audioService.isBypassMyEq;

    return Column(
      children: [
        Text(
          'Original File: ${widget.originalPath.split('/').last}',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPlayingOriginal
                ? Colors.orange.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_up,
                color: isPlayingOriginal ? Colors.orange : Colors.blue,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isPlayingOriginal
                    ? (isBypassMyEq ? 'กำลังเล่น: ของฉัน (Bypass EQ)' : 'กำลังเล่น: ของฉัน (EQ)')
                    : 'กำลังเล่น: โจทย์',
                style: TextStyle(
                  color: isPlayingOriginal ? Colors.orange : Colors.blue,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _audioService.toggleOriginal(),
              icon: Icon(
                isPlayingOriginal ? Icons.music_note : Icons.person,
                color: Colors.white,
              ),
              label: Text(
                isPlayingOriginal ? 'กลับไปฟังโจทย์' : 'ฟังของฉัน',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlayingOriginal
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
            
            if (isPlayingOriginal) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _audioService.toggleBypassMyEq(),
                icon: Icon(
                  isBypassMyEq ? Icons.check_box : Icons.check_box_outline_blank,
                  color: Colors.white,
                ),
                label: const Text(
                  'Bypass EQ',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBypassMyEq
                      ? Colors.red.withOpacity(0.8)
                      : Colors.grey.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}