import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../services/quran_audio_service.dart';
import 'sleep_and_ambience_sheet.dart';

/// Kur'an-ı Kerim Dinleme Mini Oynatıcı Çubuğu
///
/// Performans Optimizasyonu:
/// - Üst bar görünürlüğü [quranAudioProvider.select] ile izole edilmiştir.
/// - Başlık, butonlar ve tekrarlayıcı sadece durum değiştiğinde rebuild olur.
/// - Saniye bazlı ilerleme çubuğu [_PlayerBarProgress] içine izole edilmiştir;
///   böylece tilavet oynatılırken 11 buton ve tüm panel saniyede onlarca kez boş yere yeniden kurulmaz.
class QuranAudioPlayerBar extends ConsumerWidget {
  const QuranAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSurah = ref.watch(
      quranAudioProvider.select((s) => s.currentSurahId != null),
    );
    if (!hasSurah) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF032822) : const Color(0xFFFAFBF9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.5 : 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlayerBarHeader(),
          RepaintBoundary(
            child: _PlayerBarProgress(),
          ),
        ],
      ),
    );
  }
}

class _PlayerBarHeader extends ConsumerWidget {
  const _PlayerBarHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (
      surahName,
      activeVerseNumber,
      reciterName,
      activeWordIndex,
      isWordHighlightEnabled,
      loopRepeatCount,
      hasAmbienceOrSleep,
      isLoading,
      isPlaying,
    ) = ref.watch(
      quranAudioProvider.select((s) => (
        s.currentSurahName ?? 'Surah',
        s.activeVerseNumber,
        s.selectedReciter.nameTr,
        s.activeWordIndex,
        s.isWordHighlightEnabled,
        s.loopRepeatCount,
        s.activeAmbience != null || s.sleepTimerSecondsRemaining != null,
        s.isLoading,
        s.isPlaying,
      )),
    );

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BeyanColors.tone(0xFFD4AF37),
          ),
          child: const Icon(Icons.volume_up_rounded, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeVerseNumber != null
                    ? '${strings.recitationOfSurah(surahName)} • $activeVerseNumber. Âyet'
                    : strings.recitationOfSurah(surahName),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF7A5C0E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                activeWordIndex != null && isWordHighlightEnabled
                    ? '$reciterName • ${strings.wordTrackingBadge}'
                    : reciterName,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Döngü / Ezber Tekrar Modu (1x, 3x, 5x, 10x, ∞)
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.repeat_rounded,
                color: loopRepeatCount > 1 || loopRepeatCount == -1
                    ? BeyanColors.tone(0xFFFFDF7A)
                    : Colors.white60,
                size: 20,
              ),
              if (loopRepeatCount != 1)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    loopRepeatCount == -1 ? '∞' : '${loopRepeatCount}x',
                    style: TextStyle(
                      fontSize: 8.5,
                      color: BeyanColors.tone(0xFFFFDF7A),
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
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            hasAmbienceOrSleep ? Icons.bedtime_rounded : Icons.bedtime_outlined,
            color: hasAmbienceOrSleep ? BeyanColors.tone(0xFFFFDF7A) : Colors.white60,
            size: 19,
          ),
          tooltip: strings.language == AppLanguage.turkish ? 'Manevi Ambiyans & Uyku Modu' : 'Ambience & Sleep Timer',
          onPressed: () => SleepAndAmbienceSheet.show(context, ref),
        ),
        // 10 sn geri
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 21),
          tooltip: strings.seekBackward10s,
          onPressed: () => ref.read(quranAudioProvider.notifier).seekRelative(-10),
        ),
        // Oynat / Duraklat
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: BeyanColors.tone(0xFFFFDF7A)),
                )
              : Icon(
                  isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: BeyanColors.tone(0xFFFFDF7A),
                  size: 31,
                ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(quranAudioProvider.notifier).togglePlayPause();
          },
        ),
        // 10 sn ileri
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 21),
          tooltip: strings.seekForward10s,
          onPressed: () => ref.read(quranAudioProvider.notifier).seekRelative(10),
        ),
        // Kapat
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
          tooltip: strings.closeBtn,
          onPressed: () => ref.read(quranAudioProvider.notifier).stop(),
        ),
      ],
    );
  }
}

class _PlayerBarProgress extends ConsumerWidget {
  const _PlayerBarProgress();

  String _formatDuration(int totalSeconds) {
    final d = Duration(seconds: totalSeconds);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posSecs = ref.watch(quranAudioProvider.select((s) => s.position.inSeconds));
    final durSecs = ref.watch(quranAudioProvider.select((s) => s.duration.inSeconds));

    final totalSecs = durSecs > 0 ? durSecs.toDouble() : 1.0;
    final currSecs = posSecs.toDouble().clamp(0.0, totalSecs);

    return Row(
      children: [
        Text(
          _formatDuration(posSecs),
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              activeTrackColor: BeyanColors.tone(0xFFD4AF37),
              inactiveTrackColor: Colors.white24,
              thumbColor: BeyanColors.tone(0xFFFFDF7A),
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
          _formatDuration(durSecs),
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
