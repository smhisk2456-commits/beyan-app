import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../models/adhan_makam.dart';
import '../services/adhan_audio_player_service.dart';

/// Ezan Okunurken Uygulama İçinde Görüntülenen Kayan Durdurma Paneli
class AdhanAudioPlayerBar extends ConsumerWidget {
  const AdhanAudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhanAsync = ref.watch(adhanPlayingProvider);
    final currentMakam = adhanAsync.valueOrNull ?? AdhanAudioPlayerService.instance.currentlyPlaying;
    if (currentMakam == null || currentMakam == AdhanMakam.silent) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1505), const Color(0xFF032822)]
              : [const Color(0xFFFFF7E6), const Color(0xFFE8F5EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFDF7A),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ezan İkonu
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFDF7A),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🕌',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Başlık ve İpucu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentMakam.localizedTitle(strings.language.code)} Ezanı Okunuyor',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF0F5A47),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Kilit tuşuna basarak da susturabilirsiniz',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : const Color(0xFF4A5568),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Durdur Butonu
          InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              AdhanAudioPlayerService.instance.stop();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stop_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Durdur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
