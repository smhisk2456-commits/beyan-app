import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import '../../quran/models/surah.dart';

/// Sure listesinde bir satırı gösteren yüksek performanslı (120 FPS optimize) widget.
class SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;
  final String langCode;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
    this.langCode = 'tr',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF0D2823) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE5ECE9),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  // ── Numara Rozeti (Hafif ve Geometrik) ─────────────
                  _SurahNumber(number: surah.id, isDark: isDark),
                  const SizedBox(width: 13),

                  // ── Dil Bazlı İsim + Bilgi Etiketleri ─────────────
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah.localizedName(langCode),
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : BeyanColors.tone(0xFF11221F),
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _InfoChip(
                              label: surah.localizedRevelation(langCode),
                              color: surah.isMeccan
                                  ? BeyanColors.tone(0xFF0A685A)
                                  : BeyanColors.tone(0xFF996515),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              surah.localizedVerseCount(langCode),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white54 : BeyanColors.tone(0xFF5B6E6A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Sağ: Arapça İsim (Hafif Amiri Tipografisi) ──────
                  Text(
                    surah.nameArabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20.0,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: isDark ? BeyanColors.tone(0xFFFFE082) : BeyanColors.tone(0xFF033E35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sure numarası – hafif altın vurgulu köşeli rozet
class _SurahNumber extends StatelessWidget {
  final int number;
  final bool isDark;
  const _SurahNumber({required this.number, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12)
            : BeyanColors.tone(0xFF033E35).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.65),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: number > 99 ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF033E35),
          ),
        ),
      ),
    );
  }
}

/// Mekki/Medeni bilgi etiketi.
class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;
  const _InfoChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
