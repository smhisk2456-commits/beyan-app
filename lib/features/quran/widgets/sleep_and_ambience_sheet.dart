import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../services/quran_audio_service.dart';

/// Manevi Ambiyans & Uyku Zamanlayıcısı Modal Sayfası
class SleepAndAmbienceSheet extends ConsumerWidget {
  const SleepAndAmbienceSheet({super.key});

  static Future<void> show(BuildContext context, [WidgetRef? ref]) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const SleepAndAmbienceSheet(),
    );
    // Sekme/Modal kapatıldığında Kur'an tilaveti çalmıyorsa ambiyans sesini anında durdur
    if (ref != null) {
      final audioState = ref.read(quranAudioProvider);
      if (!audioState.isPlaying && audioState.activeAmbience != null) {
        await ref.read(quranAudioProvider.notifier).setAmbience(null);
      }
    }
  }

  String _formatSeconds(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    final audioNotifier = ref.read(quranAudioProvider.notifier);
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF03221C) : BeyanColors.tone(0xFF01362F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 25,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tutamaç (Aşağı kaydırarak veya dokunarak kapatma)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! > 6) {
                Navigator.pop(context);
              }
            },
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Başlık
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BeyanColors.tone(0xFFD4AF37),
                ),
                child: Icon(Icons.bedtime_rounded, color: BeyanColors.tone(0xFF012E2B), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.language == AppLanguage.turkish
                          ? 'Manevi Ambiyans & Uyku Modu'
                          : 'Sleep & Spiritual Ambience',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: BeyanColors.tone(0xFFFFDF7A),
                      ),
                    ),
                    Text(
                      strings.language == AppLanguage.turkish
                          ? 'Kur\'an tilavetine huzur veren ortam sesleri eşlik etsin'
                          : 'Peaceful background ambience & gentle sleep timer',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 1. Gerçek Doğa Ambiyansı Seçimi ────────────────────────────────
          Text(
            strings.language == AppLanguage.turkish
                ? 'Gerçek Doğa Ambiyansı (Yüksek Kalite Kayıt)'
                : 'Authentic Nature Ambience (HD Recordings)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _AmbienceChip(
                label: strings.language == AppLanguage.turkish ? 'Kapalı' : 'Off',
                icon: Icons.volume_off_rounded,
                isSelected: audioState.activeAmbience == null,
                onTap: () {
                  HapticFeedback.lightImpact();
                  audioNotifier.setAmbience(null);
                },
              ),
              const SizedBox(width: 6),
              _AmbienceChip(
                label: strings.language == AppLanguage.turkish ? '🌧️ Yağmur' : '🌧️ Rain',
                icon: Icons.water_drop_rounded,
                isSelected: audioState.activeAmbience == 'rain',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (audioState.activeAmbience == 'rain') {
                    audioNotifier.setAmbience(null);
                  } else {
                    audioNotifier.setAmbience('rain');
                  }
                },
              ),
              const SizedBox(width: 6),
              _AmbienceChip(
                label: strings.language == AppLanguage.turkish ? '🌊 Dalga' : '🌊 Waves',
                icon: Icons.waves_rounded,
                isSelected: audioState.activeAmbience == 'waves',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (audioState.activeAmbience == 'waves') {
                    audioNotifier.setAmbience(null);
                  } else {
                    audioNotifier.setAmbience('waves');
                  }
                },
              ),
              const SizedBox(width: 6),
              _AmbienceChip(
                label: strings.language == AppLanguage.turkish ? '🍃 Esinti' : '🍃 Breeze',
                icon: Icons.air_rounded,
                isSelected: audioState.activeAmbience == 'breeze',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (audioState.activeAmbience == 'breeze') {
                    audioNotifier.setAmbience(null);
                  } else {
                    audioNotifier.setAmbience('breeze');
                  }
                },
              ),
              const SizedBox(width: 6),
              _AmbienceChip(
                label: strings.language == AppLanguage.turkish ? '🌌 Gece' : '🌌 Night',
                icon: Icons.nights_stay_rounded,
                isSelected: audioState.activeAmbience == 'night',
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (audioState.activeAmbience == 'night') {
                    audioNotifier.setAmbience(null);
                  } else {
                    audioNotifier.setAmbience('night');
                  }
                },
              ),
            ],
          ),

          // Ambiyans Ses Seviyesi Sliderı
          if (audioState.activeAmbience != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.volume_down_rounded, color: Colors.white60, size: 18),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: BeyanColors.tone(0xFFD4AF37),
                      inactiveTrackColor: Colors.white24,
                      thumbColor: BeyanColors.tone(0xFFFFDF7A),
                    ),
                    child: Slider(
                      value: audioState.ambienceVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (val) => audioNotifier.setAmbienceVolume(val),
                    ),
                  ),
                ),
                const Icon(Icons.volume_up_rounded, color: Colors.white60, size: 18),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // ── 1.5 Uyku Öncesi Huzur Sûreleri (İnternetten Canlı Tilavet) ──
          Text(
            strings.language == AppLanguage.turkish
                ? 'Uyku Öncesi Huzur Tilaveti (Tek Dokunuşla Dinle)'
                : 'Bedtime Peaceful Recitation (One-Tap Stream)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final item in const [
                  (id: 67, name: 'Mülk Sûresi', sub: 'Kabir & Gece Koruyucusu'),
                  (id: 36, name: 'Yâsîn Sûresi', sub: 'Kur\'an\'ın Kalbi'),
                  (id: 55, name: 'Rahmân Sûresi', sub: 'İlahi Huzur & Şifa'),
                  (id: 56, name: 'Vâkıa Sûresi', sub: 'Bereket & Sekînet'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (audioState.currentSurahId == item.id) {
                          audioNotifier.togglePlayPause();
                        } else {
                          audioNotifier.playSurah(item.id, item.name);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: audioState.currentSurahId == item.id && audioState.isPlaying
                              ? BeyanColors.tone(0xFFD4AF37)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: audioState.currentSurahId == item.id && audioState.isPlaying
                                ? BeyanColors.tone(0xFFFFDF7A)
                                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              audioState.currentSurahId == item.id && audioState.isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 20,
                              color: audioState.currentSurahId == item.id && audioState.isPlaying
                                  ? BeyanColors.tone(0xFF012E2B)
                                  : BeyanColors.tone(0xFFFFDF7A),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: audioState.currentSurahId == item.id && audioState.isPlaying
                                        ? BeyanColors.tone(0xFF012E2B)
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  item.sub,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: audioState.currentSurahId == item.id && audioState.isPlaying
                                        ? BeyanColors.tone(0xFF012E2B).withValues(alpha: 0.8)
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 0.8),
          const SizedBox(height: 14),

          // ── 2. Otomatik Uyku Zamanlayıcısı ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.language == AppLanguage.turkish ? 'Uyku Zamanlayıcısı' : 'Sleep Timer',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (audioState.sleepTimerSecondsRemaining != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BeyanColors.tone(0xFFFFDF7A), width: 1),
                  ),
                  child: Text(
                    '⏳ ${_formatSeconds(audioState.sleepTimerSecondsRemaining!)}',
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Zamanlayıcı Butonları
          Row(
            children: [
              for (final mins in [15, 30, 45, 60]) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: audioState.sleepTimerMinutes == mins
                            ? BeyanColors.tone(0xFFD4AF37)
                            : Colors.transparent,
                        foregroundColor: audioState.sleepTimerMinutes == mins
                            ? BeyanColors.tone(0xFF012E2B)
                            : Colors.white,
                        side: BorderSide(
                          color: audioState.sleepTimerMinutes == mins
                              ? BeyanColors.tone(0xFFFFDF7A)
                              : Colors.white24,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        audioNotifier.startSleepTimer(mins);
                      },
                      child: Text(
                        '$mins ${strings.language == AppLanguage.turkish ? 'Dk' : 'm'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: audioState.sleepTimerMinutes == mins
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (audioState.sleepTimerMinutes != null) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  audioNotifier.cancelSleepTimer();
                },
                icon: const Icon(Icons.timer_off_rounded, size: 16, color: Color(0xFFFF8A80)),
                label: Text(
                  strings.language == AppLanguage.turkish ? 'Zamanlayıcıyı İptal Et' : 'Cancel Timer',
                  style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),
          Text(
            strings.language == AppLanguage.turkish
                ? 'Süre dolduğunda tilavet ve ambiyans son 15 saniyede yavaşça kısılarak (fade-out) kendiliğinden kapanır.'
                : 'Audio gently fades out during the final 15 seconds to ensure peaceful sleep.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _AmbienceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmbienceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? BeyanColors.tone(0xFFD4AF37) : Colors.white10,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? BeyanColors.tone(0xFFFFDF7A) : Colors.white24,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? BeyanColors.tone(0xFF012E2B) : Colors.white70,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? BeyanColors.tone(0xFF012E2B) : Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
