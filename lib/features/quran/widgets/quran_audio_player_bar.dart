import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/quran_audio_service.dart';

/// Kur'an-ı Kerim Dinleme Mini Oynatıcı Çubuğu
class QuranAudioPlayerBar extends ConsumerWidget {
  const QuranAudioPlayerBar({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    if (audioState.currentSurahId == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSecs = audioState.duration.inSeconds > 0 ? audioState.duration.inSeconds.toDouble() : 1.0;
    final currSecs = audioState.position.inSeconds.toDouble().clamp(0.0, totalSecs);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF032822) : const Color(0xFF01362F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(Icons.volume_up_rounded, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${audioState.currentSurahName ?? "Sure"} Tilaveti',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audioState.selectedReciter.nameTr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 10 sn geri
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 22),
                tooltip: '10 Saniye Geri',
                onPressed: () => ref.read(quranAudioProvider.notifier).seekRelative(-10),
              ),
              // Oynat / Duraklat
              IconButton(
                icon: audioState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFDF7A)),
                      )
                    : Icon(
                        audioState.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        color: const Color(0xFFFFDF7A),
                        size: 32,
                      ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(quranAudioProvider.notifier).togglePlayPause();
                },
              ),
              // 10 sn ileri
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 22),
                tooltip: '10 Saniye İleri',
                onPressed: () => ref.read(quranAudioProvider.notifier).seekRelative(10),
              ),
              // Kapat
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                tooltip: 'Kapat',
                onPressed: () => ref.read(quranAudioProvider.notifier).stop(),
              ),
            ],
          ),
          // Süre İlerleme Çubuğu
          Row(
            children: [
              Text(
                _formatDuration(audioState.position),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    activeTrackColor: const Color(0xFFD4AF37),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFFDF7A),
                  ),
                  child: Slider(
                    value: currSecs,
                    min: 0,
                    max: totalSecs,
                    onChanged: (val) {
                      ref.read(quranAudioProvider.notifier).seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(audioState.duration),
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
