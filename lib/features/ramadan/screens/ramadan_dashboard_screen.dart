import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';

/// Oruç takibi SharedPreferences Notifier
final fastingTrackerProvider =
    StateNotifierProvider<FastingTrackerNotifier, Set<String>>((ref) {
  return FastingTrackerNotifier();
});

class FastingTrackerNotifier extends StateNotifier<Set<String>> {
  static const _key = 'ramadan_fasting_days';

  FastingTrackerNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  bool isFastingToday() {
    return state.contains(_todayKey());
  }

  Future<void> toggleTodayFasting() async {
    final today = _todayKey();
    final updated = Set<String>.from(state);
    if (updated.contains(today)) {
      updated.remove(today);
    } else {
      updated.add(today);
    }
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, updated.toList());
    } catch (_) {}
  }
}

/// Ramazan Modu & İftar/Sahur Geri Sayım Ekranı
class RamadanDashboardScreen extends ConsumerStatefulWidget {
  const RamadanDashboardScreen({super.key});

  @override
  ConsumerState<RamadanDashboardScreen> createState() =>
      _RamadanDashboardScreenState();
}

class _RamadanDashboardScreenState extends ConsumerState<RamadanDashboardScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerData = ref.watch(prayerTimesNotifierProvider).valueOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFasting = ref.watch(fastingTrackerProvider.notifier).isFastingToday();
    final totalFastingDays = ref.watch(fastingTrackerProvider).length;

    // Sahur (İmsak) & İftar (Akşam) hesapları
    DateTime? imsakTime;
    DateTime? iftarTime;
    if (prayerData != null) {
      imsakTime = prayerData.fajr.time;
      iftarTime = prayerData.maghrib.time;
    }

    final now = DateTime.now();
    bool isWaitingForIftar = false;
    Duration countdown = Duration.zero;
    String countdownTitle = 'İftara Kalan Süre';

    if (imsakTime != null && iftarTime != null) {
      if (now.isBefore(imsakTime)) {
        // İmsak öncesi -> Sahura kalan süre
        isWaitingForIftar = false;
        countdownTitle = 'Sahur / İmsak Vaktine Kalan';
        countdown = imsakTime.difference(now);
      } else if (now.isBefore(iftarTime)) {
        // İmsak ile Akşam arası -> İftara kalan süre
        isWaitingForIftar = true;
        countdownTitle = 'İftar Vaktine Kalan Süre';
        countdown = iftarTime.difference(now);
      } else {
        // İftar geçti -> Bir sonraki günün imsakı
        final tomorrowImsak = imsakTime.add(const Duration(days: 1));
        isWaitingForIftar = false;
        countdownTitle = 'Yarınki Sahura Kalan';
        countdown = tomorrowImsak.difference(now);
      }
    }

    final hours = countdown.inHours.toString().padLeft(2, '0');
    final minutes = (countdown.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (countdown.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ramazan-ı Şerif'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // ── İftar / Sahur Canlı Geri Sayım Kartı ───────────────────────
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF012C28),
                  Color(0xFF034A3E),
                  Color(0xFF011C1A),
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
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isWaitingForIftar ? Icons.wb_twilight_rounded : Icons.nightlight_round,
                      color: const Color(0xFFFFDF7A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      countdownTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFDF7A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Dijital Geri Sayım Göstergesi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeUnit(hours, 'SAAT'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(':', style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    _buildTimeUnit(minutes, 'DAKİKA'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(':', style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                    _buildTimeUnit(seconds, 'SANİYE'),
                  ],
                ),
                const SizedBox(height: 18),
                // İmsak ve İftar Saatleri Barı
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('İmsak (Sahur)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            imsakTime != null
                                ? '${imsakTime.hour.toString().padLeft(2, '0')}:${imsakTime.minute.toString().padLeft(2, '0')}'
                                : '--:--',
                            style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: Colors.white24),
                      Column(
                        children: [
                          const Text('Akşam (İftar)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            iftarTime != null
                                ? '${iftarTime.hour.toString().padLeft(2, '0')}:${iftarTime.minute.toString().padLeft(2, '0')}'
                                : '--:--',
                            style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Oruç Takibi Kartı ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF06221D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFD4AF37), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bugünkü Oruç Durumu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF033E35),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Toplam kaydedilen oruç: $totalFastingDays gün',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isFasting,
                      activeTrackColor: const Color(0xFF033E35),
                      activeThumbColor: const Color(0xFFD4AF37),
                      onChanged: (_) {
                        HapticFeedback.lightImpact();
                        ref.read(fastingTrackerProvider.notifier).toggleTodayFasting();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Doğrulanmış İftar ve Sahur Duaları ─────────────────────────
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
                'Sünnet İftar & Sahur Duaları',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildDuaTile(
            title: 'Hz. Peygamber\'in (s.a.v.) İftar Duası',
            arabic: 'اللَّهُمَّ لَكَ صُمْتُ، وَعَلَى رِزْقِكَ أَفْطَرْتُ',
            transliteration: 'Allâhümme leke sumtü ve alâ rızkıke eftartü.',
            meaning: 'Allah\'ım! Senin rızan için oruç tuttum ve Senin rızkınla iftar ettim.',
            reference: 'Sünen-i Ebu Davud (2358)',
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildDuaTile(
            title: 'Susuzluk Gidip Damarlar Islandığında',
            arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
            transliteration: 'Zehebe\'z-zama\' vebtelleti\'l-urûk, ve sebete\'l-ecru inşâallâh.',
            meaning: 'Susuzluk gitti, damarlar ıslandı ve inşallah mükâfat kesinleşti.',
            reference: 'Sünen-i Ebu Davud (2357)',
            isDark: isDark,
          ),

          const SizedBox(height: 16),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  static Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFDF7A),
              fontFeatures: [],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  static Widget _buildDuaTile({
    required String title,
    required String arabic,
    required String transliteration,
    required String meaning,
    required String reference,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF06221D) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF033E35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            arabic,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: Color(0xFFFFDF7A),
              height: 1.6,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            transliteration,
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            meaning,
            style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            'Kaynak: $reference',
            style: const TextStyle(fontSize: 11, color: Color(0xFFD4AF37), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
