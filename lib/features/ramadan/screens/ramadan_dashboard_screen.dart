import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';

/// Oruç takibi veri modeli (Bugünkü durum + Toplam/Kaza/Nafile sayacı)
class FastingTrackerData {
  final Set<String> loggedDates;
  final int manualExtraDays;

  const FastingTrackerData({
    required this.loggedDates,
    this.manualExtraDays = 0,
  });

  bool isFastingToday(String todayKey) => loggedDates.contains(todayKey);
  int get totalDays => (loggedDates.length + manualExtraDays).clamp(0, 9999);

  FastingTrackerData copyWith({
    Set<String>? loggedDates,
    int? manualExtraDays,
  }) {
    return FastingTrackerData(
      loggedDates: loggedDates ?? this.loggedDates,
      manualExtraDays: manualExtraDays ?? this.manualExtraDays,
    );
  }
}

/// Oruç takibi SharedPreferences Notifier
final fastingTrackerProvider =
    StateNotifierProvider<FastingTrackerNotifier, FastingTrackerData>((ref) {
  return FastingTrackerNotifier();
});

class FastingTrackerNotifier extends StateNotifier<FastingTrackerData> {
  static const _keyDates = 'ramadan_fasting_days';
  static const _keyManual = 'ramadan_manual_fasting_count';

  FastingTrackerNotifier()
      : super(const FastingTrackerData(loggedDates: {})) {
    _load();
  }

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyDates) ?? [];
      final manual = prefs.getInt(_keyManual) ?? 0;
      state = FastingTrackerData(
        loggedDates: list.toSet(),
        manualExtraDays: manual,
      );
    } catch (_) {}
  }

  Future<void> toggleTodayFasting() async {
    final today = todayKey();
    final updated = Set<String>.from(state.loggedDates);
    if (updated.contains(today)) {
      updated.remove(today);
    } else {
      updated.add(today);
    }
    state = state.copyWith(loggedDates: updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyDates, updated.toList());
    } catch (_) {}
  }

  Future<void> incrementManualDays() async {
    final newManual = state.manualExtraDays + 1;
    state = state.copyWith(manualExtraDays: newManual);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyManual, newManual);
    } catch (_) {}
  }

  Future<void> decrementManualDays() async {
    if (state.totalDays <= 0) return;
    // Eğer manualExtraDays > 0 ise doğrudan onu azalt
    if (state.manualExtraDays > 0) {
      final newManual = state.manualExtraDays - 1;
      state = state.copyWith(manualExtraDays: newManual);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyManual, newManual);
      } catch (_) {}
    } else if (state.loggedDates.isNotEmpty) {
      // Değilse son kaydedilen tarihlerden birini çıkar
      final updated = Set<String>.from(state.loggedDates);
      final lastKey = updated.last;
      updated.remove(lastKey);
      state = state.copyWith(loggedDates: updated);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_keyDates, updated.toList());
      } catch (_) {}
    }
  }
}

/// Ramazan Modu & İftar/Sahur Geri Sayım Ekranı (60 FPS Optimize)
class RamadanDashboardScreen extends ConsumerWidget {
  const RamadanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerData = ref.watch(prayerTimesNotifierProvider).valueOrNull;
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fastingData = ref.watch(fastingTrackerProvider);
    final isFasting = fastingData.isFastingToday(FastingTrackerNotifier.todayKey());
    final totalFastingDays = fastingData.totalDays;

    DateTime? imsakTime;
    DateTime? iftarTime;
    if (prayerData != null) {
      imsakTime = prayerData.fajr.time;
      iftarTime = prayerData.maghrib.time;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.holyRamadan),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          // ── İftar / Sahur Canlı Geri Sayım Kartı (Kendi içinde 1 sn tikler, 60 FPS) ──
          RepaintBoundary(
            child: _LiveIftarCountdown(
              imsakTime: imsakTime,
              iftarTime: iftarTime,
            ),
          ),
          const SizedBox(height: 20),

          // ── Oruç Takibi ve Sayacı Kartı (+ / - Butonlu) ─────────────────────
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
                // 1. Satır: Bugünkü Oruç Switch
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFFD4AF37),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.todayFastingStatus,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF033E35),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isFasting ? strings.fastingActiveMsg : strings.fastingInactiveMsg,
                            style: TextStyle(
                              fontSize: 12,
                              color: isFasting
                                  ? const Color(0xFFD4AF37)
                                  : (isDark ? Colors.white60 : Colors.black54),
                              fontWeight: isFasting ? FontWeight.w600 : FontWeight.normal,
                            ),
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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),

                // 2. Satır: Toplam Oruç Sayacı (+ ve - Butonları)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.totalFastingStatus,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF033E35),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.totalFastingDesc,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // + / - Sayacı Butonları
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF012C28) : const Color(0xFFF0F5F3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            iconSize: 20,
                            color: totalFastingDays > 0
                                ? const Color(0xFFD4AF37)
                                : Colors.grey.shade400,
                            tooltip: strings.decrementDayTooltip,
                            onPressed: totalFastingDays > 0
                                ? () {
                                    HapticFeedback.lightImpact();
                                    ref.read(fastingTrackerProvider.notifier).decrementManualDays();
                                  }
                                : null,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 44),
                            alignment: Alignment.center,
                            child: Text(
                              strings.fastingDaysCount(totalFastingDays),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            iconSize: 20,
                            color: const Color(0xFFD4AF37),
                            tooltip: strings.incrementDayTooltip,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              ref.read(fastingTrackerProvider.notifier).incrementManualDays();
                            },
                          ),
                        ],
                      ),
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
              Text(
                strings.sunnahRamadanDuas,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.2),
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
          const SizedBox(height: 12),

          _buildDuaTile(
            title: 'Sahurda Bereket ve Teheccüd Niyazı',
            arabic: 'يَرْحَمُ اللَّهُ الْمُتَسَحِّرِينَ',
            transliteration: 'Yerhamullâhu\'l-mütesahhirîn.',
            meaning: 'Allah sahur yapanlara merhamet eylesin.',
            reference: 'Müsned-i Ahmed (3/12)',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // ── Banner Reklam Alanı ───────────────────────────────────────
          const BannerAdWidget(),
        ],
      ),
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
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meaning,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kaynak: $reference',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Yalnızca saniyeleri tikleyen bağımsız geri sayım bileşeni (60 FPS için izole)
class _LiveIftarCountdown extends ConsumerStatefulWidget {
  final DateTime? imsakTime;
  final DateTime? iftarTime;

  const _LiveIftarCountdown({
    required this.imsakTime,
    required this.iftarTime,
  });

  @override
  ConsumerState<_LiveIftarCountdown> createState() => _LiveIftarCountdownState();
}

class _LiveIftarCountdownState extends ConsumerState<_LiveIftarCountdown> {
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
    final strings = ref.watch(appStringsProvider);
    final now = DateTime.now();
    bool isWaitingForIftar = false;
    Duration countdown = Duration.zero;
    String countdownTitle = strings.remainingUntilIftar;

    final imsakTime = widget.imsakTime;
    final iftarTime = widget.iftarTime;

    if (imsakTime != null && iftarTime != null) {
      if (now.isBefore(imsakTime)) {
        isWaitingForIftar = false;
        countdownTitle = strings.remainingUntilSuhoor;
        countdown = imsakTime.difference(now);
      } else if (now.isBefore(iftarTime)) {
        isWaitingForIftar = true;
        countdownTitle = strings.remainingUntilIftar;
        countdown = iftarTime.difference(now);
      } else {
        final tomorrowImsak = imsakTime.add(const Duration(days: 1));
        isWaitingForIftar = false;
        countdownTitle = strings.remainingUntilTomorrowSuhoor;
        countdown = tomorrowImsak.difference(now);
      }
    }

    final hours = countdown.inHours.toString().padLeft(2, '0');
    final minutes = (countdown.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (countdown.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
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
              _buildTimeUnit(hours, strings.hoursUnit),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(':', style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              _buildTimeUnit(minutes, strings.minsUnit),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(':', style: TextStyle(color: Color(0xFFFFDF7A), fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              _buildTimeUnit(seconds, strings.secsUnit),
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
                    Text(strings.imsakSuhoorLabel, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
                    Text(strings.maghribIftarLabel, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
    );
  }

  static Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
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
}
