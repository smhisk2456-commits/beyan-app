import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../../core/services/app_review_service.dart';
import '../../zikr/models/worship_tracker_model.dart';

/// Apple Fitness & Duolingo Tarzı 3'lü Lüks İbadet Halkası ve Günlük Seri Kartı
class WorshipRingsCard extends ConsumerStatefulWidget {
  const WorshipRingsCard({super.key});

  @override
  ConsumerState<WorshipRingsCard> createState() => _WorshipRingsCardState();
}

class _WorshipRingsCardState extends ConsumerState<WorshipRingsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayWorshipEntryProvider);
    final streak = ref.watch(worshipStreakProvider);
    final notifier = ref.read(worshipTrackerProvider.notifier);

    // Namaz sayısı (0 - 5)
    int prayerCount = 0;
    if (today.fajr) prayerCount++;
    if (today.dhuhr) prayerCount++;
    if (today.asr) prayerCount++;
    if (today.maghrib) prayerCount++;
    if (today.isha) prayerCount++;

    final prayerProgress = (prayerCount / 5.0).clamp(0.0, 1.0);
    final quranProgress = today.quran ? 1.0 : 0.0;
    final zikrProgress = today.zikr ? 1.0 : 0.0;
    final completedCount = today.completedCount;

    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final cardBg = BeyanColors.tone(0xFF072620);
    final isAllDone = today.isFullyCompleted;

    // Dinamik Manevi Motivasyon Başlığı
    String motivationText;
    if (isAllDone) {
      motivationText = '🌟 Elhamdülillah! Tüm halkalar tamamlandı.';
    } else if (completedCount >= 4) {
      motivationText = 'Halkalarını kapatmaya çok az kaldı, maşallah!';
    } else if (completedCount > 0) {
      motivationText = 'Güzel bir başlangıç, ibadetlerini tamamla.';
    } else {
      motivationText = 'Güne niyetle başla, bugün halkalarını kapat.';
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final ringSize = isCompact ? 76.0 : 96.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: 8,
      ),
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardBg,
            BeyanColors.tone(0xFF041A16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAllDone
              ? goldPrimary.withValues(alpha: 0.6)
              : goldPrimary.withValues(alpha: 0.22),
          width: isAllDone ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ÜST BAŞLIK & SERİ BİLGİSİ ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: goldPrimary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.donut_large_rounded, color: gold, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'GÜNLÜK İBADET HALKALARI',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Seri Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6D00).withValues(alpha: 0.25),
                      const Color(0xFFFF9100).withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${streak.currentStreak} Gün Seri',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB74D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── HALKALAR VE İBADET DURUMU (YAN YANA) ──────────────
          Row(
            children: [
              // 3'lü İç İçe Halka (CustomPainter)
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size(ringSize, ringSize),
                          painter: _AppleFitnessRingsPainter(
                            prayerProgress: prayerProgress * _animController.value,
                            quranProgress: quranProgress * _animController.value,
                            zikrProgress: zikrProgress * _animController.value,
                            isCompact: isCompact,
                          ),
                        );
                      },
                    ),
                    // Merkeze Ateş / Yüzde
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isAllDone ? '🌟' : '🔥',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '$completedCount/7',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Sağ Taraf: Halkaların Lejantı & Açıklaması
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motivationText,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isAllDone ? gold : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ringLegendRow(
                      color: const Color(0xFF00E676),
                      label: 'Namaz',
                      progressText: '$prayerCount / 5 Vakit',
                    ),
                    const SizedBox(height: 4),
                    _ringLegendRow(
                      color: const Color(0xFFFFD54F),
                      label: 'Kur\'an-ı Kerim',
                      progressText: today.quran ? 'Okundu' : 'Bekliyor',
                    ),
                    const SizedBox(height: 4),
                    _ringLegendRow(
                      color: const Color(0xFFFF5252),
                      label: 'Zikir & Tesbih',
                      progressText: today.zikr ? 'Tamamlandı' : 'Bekliyor',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── HIZLI DOKUNMATİK VAKİT ÇİPLERİ ────────────────────
          // Kullanıcı tek tıkla kıldığı namazı işaretler ve halka anında büyür!
          Row(
            children: [
              _prayerChip('Sabah', today.fajr, () => _toggle(notifier, 'fajr')),
              const SizedBox(width: 6),
              _prayerChip('Öğle', today.dhuhr, () => _toggle(notifier, 'dhuhr')),
              const SizedBox(width: 6),
              _prayerChip('İkindi', today.asr, () => _toggle(notifier, 'asr')),
              const SizedBox(width: 6),
              _prayerChip('Akşam', today.maghrib, () => _toggle(notifier, 'maghrib')),
              const SizedBox(width: 6),
              _prayerChip('Yatsı', today.isha, () => _toggle(notifier, 'isha')),
            ],
          ),

          const SizedBox(height: 8),

          // Kur'an & Zikir Hızlı Çipleri
          Row(
            children: [
              Expanded(
                child: _habitChip(
                  icon: Icons.menu_book_rounded,
                  label: 'Kur\'an Okudum',
                  isDone: today.quran,
                  activeColor: const Color(0xFFFFD54F),
                  onTap: () => _toggle(notifier, 'quran'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _habitChip(
                  icon: Icons.fingerprint_rounded,
                  label: 'Zikir Çektim',
                  isDone: today.zikr,
                  activeColor: const Color(0xFFFF5252),
                  onTap: () => _toggle(notifier, 'zikr'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggle(WorshipTrackerNotifier notifier, String key) {
    HapticFeedback.lightImpact();
    notifier.toggleHabit(habitKey: key);
    _animController.forward(from: 0.6);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        final entry = ref.read(todayWorshipEntryProvider);
        if (entry.isFullyCompleted) {
          AppReviewService.instance.requestReviewIfAppropriate();
        }
      }
    });
  }

  Widget _ringLegendRow({
    required Color color,
    required String label,
    required String progressText,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              progressText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _prayerChip(String name, bool isDone, VoidCallback onTap) {
    const activeGreen = Color(0xFF00E676);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: isDone
                ? activeGreen.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone
                  ? activeGreen.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.08),
              width: isDone ? 1.4 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                size: 13,
                color: isDone ? activeGreen : Colors.white38,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? Colors.white : Colors.white60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _habitChip({
    required IconData icon,
    required String label,
    required bool isDone,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isDone
              ? activeColor.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone
                ? activeColor.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
            width: isDone ? 1.3 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : icon,
              size: 14,
              color: isDone ? activeColor : Colors.white54,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                    color: isDone ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Apple Fitness Tarzı 3'lü Eşmerkezli Halka Painter'ı
class _AppleFitnessRingsPainter extends CustomPainter {
  final double prayerProgress;
  final double quranProgress;
  final double zikrProgress;
  final bool isCompact;

  _AppleFitnessRingsPainter({
    required this.prayerProgress,
    required this.quranProgress,
    required this.zikrProgress,
    this.isCompact = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = isCompact ? 5.2 : 6.8;
    final ringSpacing = isCompact ? 6.8 : 8.8;

    // Dış Halka: Namaz (Yeşil)
    final r1 = (size.width / 2) - strokeWidth / 2;
    _drawRing(
      canvas,
      center,
      r1,
      strokeWidth,
      const Color(0xFF00E676),
      const Color(0xFF00BFA5),
      prayerProgress,
    );

    // Orta Halka: Kur'an (Altın)
    final r2 = r1 - ringSpacing;
    _drawRing(
      canvas,
      center,
      r2,
      strokeWidth,
      const Color(0xFFFFD54F),
      const Color(0xFFFF9800),
      quranProgress,
    );

    // İç Halka: Zikir (Kırmızı/Mercan)
    final r3 = r2 - ringSpacing;
    _drawRing(
      canvas,
      center,
      r3,
      strokeWidth,
      const Color(0xFFFF5252),
      const Color(0xFFD50000),
      zikrProgress,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    Color startColor,
    Color endColor,
    double progress,
  ) {
    if (radius <= 0) return;

    // 1. Arka Plan Sönük İzi
    final bgPaint = Paint()
      ..color = startColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0.0) return;

    // 2. Renkli İlerleme Arkı
    final sweepAngle = (2 * math.pi * progress).clamp(0.01, 2 * math.pi);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [startColor, endColor],
    );

    final progressPaint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // 12 yönünden başla
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AppleFitnessRingsPainter oldDelegate) {
    return oldDelegate.prayerProgress != prayerProgress ||
        oldDelegate.quranProgress != quranProgress ||
        oldDelegate.zikrProgress != zikrProgress;
  }
}
