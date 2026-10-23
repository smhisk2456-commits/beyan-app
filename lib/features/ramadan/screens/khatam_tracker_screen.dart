import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/khatam_tracker_model.dart';

/// Ramazan ve Günlük Kur'an Hatim Takipçisi (30 Cüz Takip Ekranı)
class KhatamTrackerScreen extends ConsumerWidget {
  const KhatamTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final khatamState = ref.watch(khatamProgressProvider);
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = themeState.palette.accentGold;

    final completedCount = khatamState.completedCount;
    final percentage = (khatamState.percentage * 100).toInt();

    return Scaffold(
      backgroundColor: isDark ? BeyanColors.tone(0xFF011815) : BeyanColors.tone(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '30 Günde Hatim Takipçisi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : BeyanColors.tone(0xFF033E35),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Hatim Duası',
            icon: Icon(Icons.menu_book_rounded, color: gold),
            onPressed: () => _showKhatamDuaDialog(context, isDark, gold),
          ),
          IconButton(
            tooltip: 'Sıfırla',
            icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white60 : Colors.black45),
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Genel İlerleme Özeti Kartı ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [BeyanColors.tone(0xFF062A24), BeyanColors.tone(0xFF011815)]
                    : [BeyanColors.tone(0xFF0F5A47), BeyanColors.tone(0xFF063A2D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: gold.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                        const Text(
                          'Hatim İlerlemesi',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedCount / 30 Cüz',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gold, width: 1),
                      ),
                      child: Text(
                        '%$percentage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // İlerleme Çubuğu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: khatamState.percentage,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(gold),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        khatamState.isEntireQuranCompleted
                            ? 'Tebrikler! Hatm-i Şerif\'i tamamladınız. Hatim duasını yapmayı unutmayın.'
                            : 'Günde 1 cüz okuyarak Ramazan Bayramı\'na hatimle ulaşabilirsiniz.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Başlık ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '30 Cüz Listesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : BeyanColors.tone(0xFF033E35),
                ),
              ),
              Text(
                'Okuduğunuz cüze dokunun',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 30 Cüz Kartları Grid / Listesi ───────────────────────────
          ...quranJuzList.map((juz) {
            final isDone = khatamState.isCompleted(juz.juzNumber);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDone
                    ? (isDark ? BeyanColors.tone(0xFF0A332A) : BeyanColors.tone(0xFFE8F5EE))
                    : (isDark ? BeyanColors.tone(0xFF06221D) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDone
                      ? BeyanColors.tone(0xFF2E7D32)
                      : (isDark ? Colors.white12 : Colors.grey.shade200),
                  width: isDone ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? BeyanColors.tone(0xFF2E7D32) : gold.withValues(alpha: 0.15),
                    border: Border.all(
                      color: isDone ? BeyanColors.tone(0xFF66BB6A) : gold,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${juz.juzNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.white : gold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${juz.juzNumber}. Cüz (${juz.startSurah})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : BeyanColors.tone(0xFF033E35),
                  ),
                ),
                subtitle: Text(
                  'Başlangıç: ${juz.startSurah} ${juz.startAyah}. Âyet • Sayfa ${juz.startPage} - ${juz.endPage} (${juz.pageCount} Sayfa)',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                trailing: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(khatamProgressProvider.notifier).toggleJuz(juz.juzNumber);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDone ? BeyanColors.tone(0xFF2E7D32) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone ? BeyanColors.tone(0xFF2E7D32) : gold.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                          color: isDone ? Colors.white : gold,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDone ? 'Okundu' : 'Tamamla',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.white : gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showKhatamDuaDialog(BuildContext context, bool isDark, Color gold) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? BeyanColors.tone(0xFF06221D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.menu_book_rounded, color: gold, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Hatm-i Şerif Duası',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : BeyanColors.tone(0xFFF4F7F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'صَدَقَ اللهُ الْعَظِيمُ وَبَلَّغَ رَسُولُهُ الْكَرِيمُ\n\n'
                  '«اَللَّهُمَّ ارْحَمْنَا بِالْقُرْآنِ، وَاجْعَلْهُ لَنَا إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً. '
                  'اَللَّهُمَّ ذَكِّرْنَا مِنْهُ مَا نَسِينَا، وَعَلِّمْنَا مِنْهُ مَا جَهِلْنَا، '
                  'وَارْزُقْنَا تِلاَوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ، '
                  'وَاجْعَلْهُ لَنَا حُجَّةً يَا رَبَّ الْعَالَمِينَ.»',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.8,
                    color: BeyanColors.tone(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Türkçe Meali:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '«Allah\'ım! Bize Kur\'an ile merhamet et. Onu bizim için bir rehber, nur, hidayet ve rahmet kıl. '
                'Allah\'ım! Ondan unuttuklarımızı bize hatırlat, bilmediklerimizi bize öğret. '
                'Gece saatlerinde ve gündüzün etrafında onu okumayı bize nasip eyle ve onu lehimize delil kıl ey Âlemlerin Rabbi!»',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Kapat', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hatmi Sıfırla'),
        content: const Text('Tüm cüz ilerlemeniz sıfırlanacaktır. Yeni bir hatme başlamak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              ref.read(khatamProgressProvider.notifier).resetAll();
              Navigator.pop(ctx);
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
