import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../quran/models/surah.dart';
import '../../quran/widgets/arabic_text_widget.dart';

/// Sure listesinde bir satırı gösteren widget.
///
/// Sol taraf: Numaralı sekizgen + Türkçe isim + etiket
/// Sağ taraf: Arapça isim (Amiri fontu)
class SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahListItem({
    super.key,
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2823) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF133B34) : const Color(0xFFE8EEEC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // ── Numara Sekizgeni ──────────────────────────────
                _SurahNumber(number: surah.id, isDark: isDark),
                const SizedBox(width: 14),

                // ── Türkçe İsim + Bilgi Etiketleri ───────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameTurkish,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF11221F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _InfoChip(
                            label: surah.revelationLabel,
                            color: surah.isMeccan
                                ? const Color(0xFF0A685A)
                                : const Color(0xFF996515),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            surah.verseCountLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : const Color(0xFF5B6E6A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Sağ: Arapça İsim ─────────────────────────────
                ArabicText(
                  surah.nameArabic,
                  fontSize: 22.0,
                  lineHeight: 1.8,
                  color: isDark ? const Color(0xFFFFE082) : const Color(0xFF033E35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sure numarası – sekizgen daire içinde gösterilir.
class _SurahNumber extends StatelessWidget {
  final int number;
  final bool isDark;
  const _SurahNumber({required this.number, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _OctagonPainter(
          fillColor: isDark
              ? const Color(0xFFD4AF37).withOpacity(0.12)
              : const Color(0xFF033E35).withOpacity(0.06),
          strokeColor: const Color(0xFFD4AF37).withOpacity(0.65),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: number > 99 ? 11 : 13,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF033E35),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sekizgen şekil — dart:math.cos / sin ile.
class _OctagonPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  const _OctagonPainter({required this.fillColor, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width / 2) - 2;

    final path = Path();
    const sides = 8;
    for (int i = 0; i < sides; i++) {
      // Sekizgen köşeleri: 22.5° offset ile düzgün hizalanır
      final angle = (i * 2 * math.pi / sides) - (math.pi / sides);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_OctagonPainter old) => false;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
