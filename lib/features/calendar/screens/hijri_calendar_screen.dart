import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/religious_day_model.dart';
import '../services/hijri_calendar_service.dart';

final hijriAdjustmentProvider = StateNotifierProvider<HijriAdjustmentNotifier, int>((ref) {
  return HijriAdjustmentNotifier();
});

class HijriAdjustmentNotifier extends StateNotifier<int> {
  HijriAdjustmentNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    state = await HijriCalendarService.instance.getSavedAdjustment();
  }

  Future<void> setAdjustment(int days) async {
    state = days;
    await HijriCalendarService.instance.saveAdjustment(days);
  }
}

/// Hicri Takvim ve Dini Günler Ekranı
class HijriCalendarScreen extends ConsumerWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adjustment = ref.watch(hijriAdjustmentProvider);
    final now = DateTime.now();
    final hijriDate = HijriCalendarService.instance.getHijriDate(now, adjustmentDays: adjustment);
    final allDays = HijriCalendarService.instance.getReligiousDays();
    final upcomingDays = allDays.where((d) => !d.isPast).toList()
      ..sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hicri Takvim & Dini Günler'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Color(0xFFFFDF7A)),
            tooltip: 'Hicri Gün Düzeltmesi',
            onPressed: () => _showAdjustmentDialog(context, ref, adjustment),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // ── Bugünün Hicri Tarih Kartı ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF012E2B),
                  Color(0xFF034A3E),
                  Color(0xFF021E1B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Diyanet Takvimi',
                        style: TextStyle(
                          color: Color(0xFFFFDF7A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (adjustment != 0)
                      Text(
                        'Düzeltme: ${adjustment > 0 ? "+$adjustment" : adjustment} gün',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  hijriDate.formatAr(),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFDF7A),
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 6),
                Text(
                  hijriDate.formatTr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Miladi: ${now.day}.${now.month.toString().padLeft(2, '0')}.${now.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Başlık: Yaklaşan Mübarek Gün ve Geceler ───────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Yaklaşan Kandiller ve Dini Günler',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Dini Gün Kartları ─────────────────────────────────────────
          ...upcomingDays.map((item) {
            return _ReligiousDayCard(item: item, isDark: isDark);
          }),
        ],
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context, WidgetRef ref, int current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF032B25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
        title: const Text(
          'Hicri Takvim Düzeltmesi',
          style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hilalin yerel gözlemine göre Hicri tarihi +/- 1 veya 2 gün ileri/geri alabilirsiniz.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [-2, -1, 0, 1, 2].map((d) {
                final isSel = current == d;
                return ChoiceChip(
                  label: Text(d == 0 ? '0 (Standart)' : (d > 0 ? '+$d gün' : '$d gün')),
                  selected: isSel,
                  selectedColor: const Color(0xFFD4AF37),
                  onSelected: (_) {
                    ref.read(hijriAdjustmentProvider.notifier).setAdjustment(d);
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ReligiousDayCard extends StatelessWidget {
  final ReligiousDay item;
  final bool isDark;

  const _ReligiousDayCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = item.daysRemaining;
    final isToday = item.isToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF06221D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFFDF7A)
              : const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
          width: isToday ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol İkon / Sayaç Rozeti
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Center(
              child: isToday
                  ? const Icon(Icons.star_rounded, color: Colors.black87, size: 26)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$days',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const Text(
                          'GÜN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF033E35),
                        ),
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BUGÜN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.hijriDate} • ${item.gregorianDate.day}.${item.gregorianDate.month.toString().padLeft(2, '0')}.${item.gregorianDate.year}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
