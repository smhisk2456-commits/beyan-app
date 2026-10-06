import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../quran/models/verse.dart';
import '../../quran/widgets/arabic_text_widget.dart';

/// Tek bir ayeti tam olarak gösteren kart widget'ı.
///
/// Katmanlar (yukarıdan aşağı):
///   1. Ayet numarası + Sure referansı (header)
///   2. Arapça metin      → Amiri, RTL, büyük punto, height:2.0
///   3. Türkçe okunuş     → italik, orta punto
///   4. Türkçe meal       → normal, küçük punto
class VerseCard extends StatelessWidget {
  final Verse verse;
  final bool showSurahReference;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.verse,
    this.showSurahReference = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF133B34) : const Color(0xFFE2EBE8),
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF0D2823) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Ayet Header ─────────────────────────────────
              _VerseHeader(verse: verse, isDark: isDark),
              const SizedBox(height: 16),

              // ── Arapça Metin ─────────────────────────────────
              // RTL yönü, Amiri fontu, geniş satır yüksekliği
              ArabicText(
                verse.arabicText,
                fontSize: 26.0,
                lineHeight: 2.1,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 14),

              // Arapça / Latin bölücü çizgi
              Divider(
                color: isDark ? const Color(0xFF1A3D36) : const Color(0xFFE8EEEC),
                thickness: 0.8,
                height: 1,
              ),
              const SizedBox(height: 12),

              // ── Türkçe Okunuş (Transliterasyon) ─────────────
              if (verse.transliteration != null &&
                  verse.transliteration!.isNotEmpty) ...[
                Text(
                  verse.transliteration!,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontStyle: FontStyle.italic,
                    color: isDark
                        ? const Color(0xFF80CBC4)
                        : const Color(0xFF0A685A),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
              ],

              // ── Türkçe Meal ──────────────────────────────────
              Text(
                verse.turkishMeaning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  fontSize: 14.0,
                  color: isDark ? Colors.white70 : const Color(0xFF334E48),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ayet kartının üst kısımdaki numaralı header'ı.
class _VerseHeader extends StatelessWidget {
  final Verse verse;
  final bool isDark;
  const _VerseHeader({required this.verse, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Daire içinde ayet numarası
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '${verse.verseNumber}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF033E35),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Arapça ayet işareti  ﴿٢٥٥﴾
        Text(
          verse.verseMarker,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
            color: isDark ? Colors.white38 : AppColors.textHint,
          ),
          textDirection: TextDirection.rtl,
        ),

        const Spacer(),

        // Sure:Ayet referansı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            verse.reference,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}
