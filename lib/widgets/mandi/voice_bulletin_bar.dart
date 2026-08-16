import 'package:flutter/material.dart';
import '../../services/tts_service.dart';

class VoiceBulletinBar extends StatelessWidget {
  const VoiceBulletinBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TtsService();

    return ValueListenableBuilder<TtsAudioState>(
      valueListenable: tts.stateNotifier,
      builder: (context, state, _) {
        if (state == TtsAudioState.stopped) {
          return const SizedBox.shrink();
        }

        final isPlaying = state == TtsAudioState.playing;

        return ValueListenableBuilder<String>(
          valueListenable: tts.currentTitleNotifier,
          builder: (context, title, _) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade900.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Animated Speaker / Waveform Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.graphic_eq_rounded : Icons.pause_rounded,
                        color: Colors.amberAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Status
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isPlaying ? Colors.amberAccent : Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPlaying ? 'ऑडियो बुलेटिन चल रहा है...' : 'ऑडियो रुका हुआ है',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            title.isNotEmpty ? title : 'दैनिक मंडी भाव',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Play / Pause Toggle
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        if (isPlaying) {
                          tts.pause();
                        } else {
                          tts.resume();
                        }
                      },
                      tooltip: isPlaying ? 'रोकें (Pause)' : 'सुनाएं (Play)',
                    ),
                    // Close / Stop Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => tts.stop(),
                      tooltip: 'बंद करें (Stop)',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
