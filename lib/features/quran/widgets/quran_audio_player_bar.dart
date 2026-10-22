import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../services/quran_audio_service.dart';
import 'sleep_and_ambience_sheet.dart';

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
    final strings = ref.watch(appStringsProvider);
    if (audioState.currentSurahId == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSecs = audioState.duration.inSeconds > 0 ? audioState.duration.inSeconds.toDouble() : 1.0;
    final currSecs = audioState.position.inSeconds.toDouble().clamp(0.0, totalSecs);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                      audioState.activeVerseNumber != null
                          ? '${strings.recitationOfSurah(audioState.currentSurahName ?? 'Surah')} • ${audioState.activeVerseNumber}. Âyet'
                          : strings.recitationOfSurah(audioState.currentSurahName ?? 'Surah'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      audioState.activeWordIndex != null && audioState.isWordHighlightEnabled
                          ? '${audioState.selectedReciter.nameTr} • ${strings.wordTrackingBadge}'
                          : audioState.selectedReciter.nameTr,
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
              // Döngü / Ezber Tekrar Modu (1x, 3x, 5x, 10x, ∞)
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.repeat_rounded,
                      color: audioState.loopRepeatCount > 1 || audioState.loopRepeatCount == -1
                          ? const Color(0xFFFFDF7A)
                          : Colors.white60,
                      size: 21,
                    ),
                    if (audioState.loopRepeatCount != 1)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Text(
                          audioState.loopRepeatCount == -1 ? '∞' : '${audioState.loopRepeatCount}x',
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: Color(0xFFFFDF7A),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: strings.language == AppLanguage.turkish ? 'Ezber / Döngü Tekrarı' : 'Loop & Memorization Repeat',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ref.read(quranAudioProvider.notifier).cycleLoopRepeat();
                },
              ),
              // Manevi Ambiyans & Uyku Zamanlayıcısı
              IconButton(
                icon: Icon(
                  audioState.activeAmbience != null || audioState.sleepTimerSecondsRemaining != null
                      ? Icons.bedtime_rounded
                      : Icons.bedtime_outlined,
                  color: audioState.activeAmbience != null || audioState.sleepTimerSecondsRemaining != null
                      ? const Color(0xFFFFDF7A)
                      : Colors.white60,
                  size: 20,
                ),
                tooltip: strings.language == AppLanguage.turkish ? 'Manevi Ambiyans & Uyku Modu' : 'Ambience & Sleep Timer',
                onPressed: () => SleepAndAmbienceSheet.show(context),
              ),
              // 10 sn geri
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 22),
                tooltip: strings.seekBackward10s,
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
                tooltip: strings.seekForward10s,
                onPressed: () => ref.read(quranAudioProvider.notifier).seekRelative(10),
              ),
              // Kapat
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                tooltip: strings.closeBtn,
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
