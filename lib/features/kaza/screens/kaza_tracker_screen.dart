import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../../core/utils/navigator_guard.dart';
import '../models/kaza_tracker_model.dart';
import '../providers/kaza_tracker_provider.dart';

/// Lüks Akıllı Kaza Namazı & Oruç Borcu Takipçisi Ekranı
class KazaTrackerScreen extends ConsumerStatefulWidget {
  const KazaTrackerScreen({super.key});

  @override
  ConsumerState<KazaTrackerScreen> createState() => _KazaTrackerScreenState();
}

class _KazaTrackerScreenState extends ConsumerState<KazaTrackerScreen> {
  int _selectedPace = 6; // Varsayılan: Günde 6 vakit (1 tam gün kaza)

  @override
  Widget build(BuildContext context) {
    final kazaState = ref.watch(kazaTrackerProvider);
    final kazaNotifier = ref.read(kazaTrackerProvider.notifier);

    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final bgDark = BeyanColors.tone(0xFF041915);
    final cardBg = BeyanColors.tone(0xFF072620);
    final cardBorder = goldPrimary.withValues(alpha: 0.22);

    final totalRemaining = kazaState.totalRemainingPrayers;
    final totalCompleted = kazaState.completedPrayers;
    final progress = kazaState.progressRatio;
    final estimatedDays = kazaState.estimatedDaysToFinish(_selectedPace);
    final estimatedFormatted = KazaTrackerState.formatEstimatedDuration(estimatedDays);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => BeyanNavigatorGuard.safePop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: goldPrimary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calculate_rounded, color: gold, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'Kaza Namazı Takibi',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          // Geri Al (Undo) Butonu
          if (kazaState.history.isNotEmpty)
            IconButton(
              icon: Icon(Icons.undo_rounded, color: gold, size: 22),
              tooltip: 'Son İşlemi Geri Al',
              onPressed: () {
                HapticFeedback.mediumImpact();
                final success = kazaNotifier.undo();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Son kaza kaydı geri alındı.'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          // Sihirbaz / Yeniden Hesapla
          IconButton(
            icon: Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
            tooltip: 'Borç Hesaplama Sihirbazı',
            onPressed: () => _showCalculationWizard(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            // ── 1. ÖZET & İLERLEME KARTI ─────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BeyanColors.tone(0xFF09332B),
                    BeyanColors.tone(0xFF05201B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalan Toplam Borç',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalRemaining Vakit',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: gold,
                              fontFamily: 'Amiri',
                            ),
                          ),
                          Text(
                            '≈ ${kazaState.remainingDaysOfPrayers} Günlük Kaza',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      // Yüzdelik İlerleme Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: goldPrimary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: goldPrimary.withValues(alpha: 0.35)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '%${(progress * 100).toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: gold,
                              ),
                            ),
                            Text(
                              'Tamamlandı',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // İlerleme Çubuğu
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress > 0 ? progress : 0.005,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(gold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kılınan: $totalCompleted vakit',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      Text(
                        'Oruç Borcu: ${kazaState.remainingFasting} gün',
                        style: TextStyle(fontSize: 11, color: gold.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── 2. TAHMİN MOTORU (SMART PROJECTION ENGINE) ────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: goldPrimary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded, color: gold, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Akıllı Tamamlama Öngörüsü',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Tempo Seçenekleri
                  Row(
                    children: [
                      _paceChip(1, 'Günde 1 Vakit', _selectedPace == 1, () {
                        setState(() => _selectedPace = 1);
                      }),
                      const SizedBox(width: 8),
                      _paceChip(2, 'Günde 2 Vakit', _selectedPace == 2, () {
                        setState(() => _selectedPace = 2);
                      }),
                      const SizedBox(width: 8),
                      _paceChip(6, 'Günde 1 Tam Gün', _selectedPace == 6, () {
                        setState(() => _selectedPace = 6);
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded, color: gold, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                totalRemaining <= 0
                                    ? 'Elhamdülillah, hiçbir kaza borcunuz görünmüyor!'
                                    : 'Bu tempoyla borcunuz $estimatedFormatted sonra biter.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: totalRemaining <= 0 ? Colors.greenAccent : Colors.white,
                                ),
                              ),
                              if (totalRemaining > 0)
                                Text(
                                  'Her gün aksatmadan kaza kılarak huzura kavuşabilirsiniz.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. TEK TIKLA GÜNLÜK TAM KAZA (6 VAKİT) BUTONU ─────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BeyanColors.tone(0xFFD4AF37),
                    BeyanColors.tone(0xFF9E7D20),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: goldPrimary.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    kazaNotifier.markFullDailySetCompleted();
                    _showCelebrationSnackbar(context, '1 Günlük Tam Kaza (6 Vakit) kılındı. Allah kabul etsin! 🤲');
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFF041915), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          '+1 Günlük Tam Kaza Kıldım (6 Vakit)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: BeyanColors.tone(0xFF041915),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── 4. VAKİT KAZA KARTLARI LİSTESİ ──────────────────
            Text(
              'VAKİTLER VE ORUÇ BORCU',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: gold,
              ),
            ),
            const SizedBox(height: 10),

            ...KazaType.values.map((type) {
              final count = kazaState.getCount(type);
              final initialCount = kazaState.getInitialCount(type);
              return _buildKazaCard(
                context: context,
                type: type,
                count: count,
                initialCount: initialCount,
                onAdd: () {
                  HapticFeedback.lightImpact();
                  kazaNotifier.markCompleted(type, amount: 1);
                },
                onManualEdit: () => _showManualEditDialog(context, type, count),
              );
            }),

            const SizedBox(height: 20),

            // ── 5. HADİS-İ ŞERİF & BİLGİLENDİRME KARTI ─────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, color: gold, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Kaza Namazının Önemi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Kim bir namazı unutur veya uyuyup kalırsa, hatırladığı zaman onu kılsın. Zira onun keffâreti ancak budur."',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— Buhârî (Mevâkît 37), Müslim (Mesâcid 314)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paceChip(int pace, String label, bool isSelected, VoidCallback onTap) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? goldPrimary.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? goldPrimary : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? gold : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKazaCard({
    required BuildContext context,
    required KazaType type,
    required int count,
    required int initialCount,
    required VoidCallback onAdd,
    required VoidCallback onManualEdit,
  }) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldPrimary = BeyanColors.tone(0xFFD4AF37);
    final cardBg = BeyanColors.tone(0xFF072620);

    final completedForThis = (initialCount > count) ? (initialCount - count) : 0;
    final ratio = initialCount > 0 ? (completedForThis / initialCount).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: goldPrimary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          // Sol: Vakit Bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type.rakatsInfo,
                        style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Küçük İlerleme Çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(gold),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kılınan: $completedForThis  •  Kalan: $count',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Manuel Sayı Düzenleme İkonu
          IconButton(
            icon: Icon(Icons.edit_note_rounded, color: Colors.white.withValues(alpha: 0.4), size: 22),
            tooltip: 'Sayıyı Düzenle',
            onPressed: onManualEdit,
          ),

          // +1 Kıldım Butonu
          InkWell(
            onTap: count > 0 ? onAdd : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: count > 0
                    ? LinearGradient(
                        colors: [
                          goldPrimary.withValues(alpha: 0.3),
                          goldPrimary.withValues(alpha: 0.15),
                        ],
                      )
                    : null,
                color: count <= 0 ? Colors.white.withValues(alpha: 0.05) : null,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: count > 0 ? goldPrimary.withValues(alpha: 0.6) : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    count > 0 ? Icons.add_task_rounded : Icons.check_circle_outline,
                    color: count > 0 ? gold : Colors.white30,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    count > 0 ? '+1 Kıldım' : 'Bitti',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: count > 0 ? gold : Colors.white30,
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

  void _showCelebrationSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: BeyanColors.tone(0xFF072620),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── SİHİRBAZ MODALİ: YIL VE AY HESABI ───────────────────────
  void _showCalculationWizard(BuildContext context) {
    int years = 1;
    int months = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final gold = BeyanColors.tone(0xFFFFDF7A);
          final goldPrimary = BeyanColors.tone(0xFFD4AF37);
          final cardBg = BeyanColors.tone(0xFF072620);
          final totalDays = (years * 365) + (months * 30);

          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: goldPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: gold, size: 22),
                    const SizedBox(width: 10),
                    const Text(
                      'Kaza Borcu Hesaplama Sihirbazı',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Kılmadığınız tahmini süreyi yıl ve ay olarak seçin. Sistem tüm vakitleri ve Ramazan orucunu otomatik olarak tanımlayacaktır.',
                  style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 20),

                // Yıl Seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kaç Yıl Borcunuz Var?', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (years > 0) setSheetState(() => years--);
                          },
                        ),
                        Text(
                          '$years Yıl',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (years < 80) setSheetState(() => years++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                // Ay Seçimi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ek Kaç Ay?', style: TextStyle(color: Colors.white, fontSize: 14)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (months > 0) setSheetState(() => months--);
                          },
                        ),
                        Text(
                          '$months Ay',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: gold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                          onPressed: () {
                            if (months < 11) setSheetState(() => months++);
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Toplam Hesaplanacak Borç: $totalDays Gün',
                        style: TextStyle(fontWeight: FontWeight.bold, color: gold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Her vakit (Sabah, Öğle, İkindi, Akşam, Yatsı, Vitir) için $totalDays kaza ve ${years * 30} gün oruç eklenecektir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldPrimary,
                    foregroundColor: BeyanColors.tone(0xFF041915),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    ref.read(kazaTrackerProvider.notifier).calculateFromDuration(
                          years: years,
                          months: months,
                        );
                    Navigator.pop(ctx);
                    _showCelebrationSnackbar(context, 'Kaza borçlarınız başarıyla güncellendi.');
                  },
                  child: const Text(
                    'Hesapla ve Başlat',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── MANUEL SAYI DÜZENLEME DİALOGU ──────────────────────────
  void _showManualEditDialog(BuildContext context, KazaType type, int currentCount) {
    final controller = TextEditingController(text: currentCount.toString());
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final cardBg = BeyanColors.tone(0xFF072620);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: gold.withValues(alpha: 0.3)),
        ),
        title: Text(
          '${type.title} Borcu',
          style: TextStyle(color: gold, fontFamily: 'Amiri', fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalan kaza sayısını doğrudan girin:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
            ),
            child: const Text('Kaydet'),
            onPressed: () {
              final val = int.tryParse(controller.text.trim()) ?? currentCount;
              ref.read(kazaTrackerProvider.notifier).setCount(type, val, updateInitial: true);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}
