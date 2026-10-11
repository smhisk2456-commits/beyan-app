import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';
import '../../qibla/screens/qibla_compass_screen.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../dua/screens/dua_library_screen.dart';
import '../../dua/providers/dua_providers.dart';
import '../../calendar/screens/hijri_calendar_screen.dart';
import '../../calendar/services/hijri_calendar_service.dart';
import '../../ramadan/screens/ramadan_dashboard_screen.dart';
import '../../quran/providers/quran_reading_providers.dart';
import '../../quran/providers/quran_providers.dart';
import '../../quran/screens/surah_detail_screen.dart';
import '../../quran/models/surah.dart';
import '../../notifications/models/short_verse_notification.dart';
import '../widgets/prayer_card_widget.dart';
import '../../settings/screens/settings_screen.dart';
import '../../spiritual_healing/models/mood_verse_model.dart';
import '../../spiritual_healing/screens/mood_verse_sheet.dart';
import '../../mosque_finder/screens/nearby_mosques_screen.dart';
import '../../widget_service/services/live_activity_service.dart';

/// Ana Ekran – Beyân lüks İslami kontrol merkezi.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Dynamic Island & Live Activity auto-sync
    ref.listen<AsyncValue<DailyPrayerTimes>>(prayerTimesNotifierProvider, (_, nextState) {
      nextState.whenData((daily) {
        final nextPrayer = daily.nextPrayerEntry;
        if (nextPrayer != null) {
          final h = nextPrayer.time.hour.toString().padLeft(2, '0');
          final m = nextPrayer.time.minute.toString().padLeft(2, '0');
          final progress = ref.read(prayerProgressProvider).valueOrNull ?? 0.0;
          LiveActivityService.instance.syncWithNextPrayer(
            prayerName: nextPrayer.name.turkish,
            prayerTime: '$h:$m',
            targetDate: nextPrayer.time,
            progress: progress,
          );
        }
      });
    });

    final strings = ref.watch(appStringsProvider);
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final lastRead = ref.watch(lastReadProvider);
    final allSurahs = ref.watch(allSurahsProvider).valueOrNull ?? [];
    final nextReligiousDay = HijriCalendarService.instance.getNextReligiousDay();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Lüks İslami AppBar ────────────────────────────────
          const _IslamicAppBar(),

          // ── Yaklaşan Dini Gün / Kandil Bildirimi ────────────────
          if (nextReligiousDay != null)
            SliverToBoxAdapter(
              child: _UpcomingReligiousDayBanner(day: nextReligiousDay),
            ),

          // ── Namaz Vakti Kartı (Zümrüt & Altın) ─────────────────
          const SliverToBoxAdapter(child: PrayerCardWidget()),

          // ── Son Okunan Kur'an'a Devam Etme Kartı ────────────────
          if (lastRead != null)
            SliverToBoxAdapter(
              child: _LastReadQuranCard(
                lastRead: lastRead,
                allSurahs: allSurahs,
              ),
            ),

          // ── Hızlı Erişim Butonları (Genişletilmiş İslami Matris) ───
          SliverToBoxAdapter(
            child: _QuickActionGrid(
              onOpenPrayers: () => ref.read(selectedTabProvider.notifier).state = 1,
              onOpenQibla: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
                );
              },
              onOpenZikr: () => ref.read(selectedTabProvider.notifier).state = 3,
              onOpenWidget: () => ref.read(selectedTabProvider.notifier).state = 4,
              onOpenQuran: () => ref.read(selectedTabProvider.notifier).state = 2,
              onOpenDuas: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DuaLibraryScreen()),
                );
              },
              onOpenCalendar: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
                );
              },
              onOpenRamadan: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RamadanDashboardScreen()),
                );
              },
            ),
          ),

          // ── "Bugün Kalbin Nasıl Hissediyor?" (Ruh Haline Göre Âyet & Şifa) ───
          const SliverToBoxAdapter(
            child: _SpiritualMoodsSection(),
          ),

          // ── Yakındaki Camiler & Harita Navigasyonu ───────────
          const SliverToBoxAdapter(
            child: _NearbyMosquesCard(),
          ),

          // ── Günlük Vakitler & Rekat Bilgileri Başlığı ─────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
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
                    strings.tabPrayers,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      strings.diyanetMethod,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Günlük Vakit Kartları (Rekat Bilgileri ile) ────────
          prayerAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  strings.prayerTimesLoadError(e),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
            data: (daily) => SliverToBoxAdapter(
              child: _DailyPrayersCardList(daily: daily),
            ),
          ),

          // ── Günün Ayeti (Zarif & Kompakt Kart) ────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: _DailyVerseCompactCard(),
            ),
          ),

          // ── Günün Doğrulanmış Duası Kartı ──────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: _DailyFeaturedDuaCard(),
            ),
          ),

          // ── Saygılı Alt Banner Reklam (Premium'da otomatik gizlenir) ──
          const SliverToBoxAdapter(
            child: BannerAdWidget(),
          ),

          // Alt boşluk (Yüzen lüks dock için ferah alan)
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Yaklaşan Mübarek Gün / Kandil Şeridi
// ════════════════════════════════════════════════════════════════

class _UpcomingReligiousDayBanner extends ConsumerWidget {
  final dynamic day; // ReligiousDay

  const _UpcomingReligiousDayBanner({required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final days = day.daysRemaining as int;
    final isToday = day.isToday as bool;
    final statusText = isToday ? strings.today : strings.daysRemainingText(days);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF03312B), Color(0xFF01241F)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.black, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${day.localizedTitle(strings.language.code)} • $statusText',
                  style: const TextStyle(
                    color: Color(0xFFFFDF7A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                strings.calendarArrow,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Son Okunan Kur'an'a Devam Etme Kartı
// ════════════════════════════════════════════════════════════════

class _LastReadQuranCard extends ConsumerWidget {
  final LastReadPosition lastRead;
  final List<Surah> allSurahs;

  const _LastReadQuranCard({required this.lastRead, required this.allSurahs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          final targetSurah = allSurahs.firstWhere(
            (s) => s.id == lastRead.surahId,
            orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
              id: 1,
              nameArabic: 'الفاتحة',
              nameTurkish: 'Fâtiha',
              nameEnglish: 'Al-Fatiha',
              revelationType: 'meccan',
              verseCount: 7,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahDetailScreen(
                surah: targetSurah,
                initialScrollToVerse: lastRead.verseNumber,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF012E2B), Color(0xFF02463B)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: Color(0xFFFFDF7A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.continueReadingQuran,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.surahVerseLabel(lastRead.surahName, lastRead.verseNumber),
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFDF7A), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Günün Vakitleri ve Rekat Detayları Listesi
// ════════════════════════════════════════════════════════════════

class _DailyPrayersCardList extends ConsumerWidget {
  final DailyPrayerTimes daily;
  const _DailyPrayersCardList({required this.daily});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final prayerService = ref.watch(prayerTimeServiceProvider);
    final prayers = daily.prayers;
    final nextPrayer = daily.nextPrayerEntry;

    final rekatMap = {
      PrayerName.fajr: strings.rakatFajr,
      PrayerName.sunrise: strings.rakatSunrise,
      PrayerName.dhuhr: strings.rakatDhuhr,
      PrayerName.asr: strings.rakatAsr,
      PrayerName.maghrib: strings.rakatMaghrib,
      PrayerName.isha: strings.rakatIsha,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF071F1B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: prayers.map((p) {
              final isNext = nextPrayer?.name == p.name;
              final rekatText = rekatMap[p.name] ?? '';
              final timeStr = prayerService.formatTime(p.time);
              final localizedName = p.name.localizedName(strings.language.code);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isNext
                      ? const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.12 : 0.08)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isNext
                            ? const Color(0xFFD4AF37)
                            : (isDark ? const Color(0xFF0F322C) : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNext
                              ? const Color(0xFFFFDF7A)
                              : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.name.arabic,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isNext
                                ? Colors.black87
                                : (isDark ? const Color(0xFFFFDF7A) : AppColors.teal),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                localizedName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (isNext) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    strings.nextPrayerLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rekatText,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                        color: isNext
                            ? const Color(0xFFD4AF37)
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Günün Ayeti Kompakt Lüks Kartı
// ════════════════════════════════════════════════════════════════

class _DailyVerseCompactCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);
    final now = DateTime.now();
    final todayVerseIndex = (now.year * 365 + now.day) % ShortVerseNotification.pool.length;
    final verse = ShortVerseNotification.pool[todayVerseIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF012E2B),
            const Color(0xFF023E36),
            isDark ? const Color(0xFF011C19) : const Color(0xFF012723),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFFFDF7A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.dailyVerseTitle,
                style: const TextStyle(
                  color: Color(0xFFFFDF7A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                verse.localizedReference(strings.language.code),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            verse.arabicText,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              height: 1.6,
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            verse.localizedText(strings.language.code),
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Günün Doğrulanmış Duası Kartı
// ════════════════════════════════════════════════════════════════

class _DailyFeaturedDuaCard extends ConsumerWidget {
  const _DailyFeaturedDuaCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dua = ref.watch(dailyFeaturedDuaProvider);
    final strings = ref.watch(appStringsProvider);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuaLibraryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF02362F), Color(0xFF012620)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    color: Color(0xFFFFDF7A),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.dailyDuaTitle,
                  style: const TextStyle(
                    color: Color(0xFFFFDF7A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  strings.allDuasLink,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dua.arabicText,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 17,
                height: 1.6,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 6),
            Text(
              dua.localizedMeaning(strings.language.code),
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dua.localizedReference(strings.language.code),
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Hızlı Erişim Butonları Grid (Çift Sıra İslami Matris)
// ════════════════════════════════════════════════════════════════

class _QuickActionGrid extends ConsumerWidget {
  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenZikr;
  final VoidCallback onOpenWidget;
  final VoidCallback onOpenQuran;
  final VoidCallback onOpenDuas;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenRamadan;

  const _QuickActionGrid({
    required this.onOpenPrayers,
    required this.onOpenQibla,
    required this.onOpenZikr,
    required this.onOpenWidget,
    required this.onOpenQuran,
    required this.onOpenDuas,
    required this.onOpenCalendar,
    required this.onOpenRamadan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // 1. Sıra
          Row(
            children: [
              _ActionCard(
                icon: Icons.access_time_filled_rounded,
                title: strings.tabPrayers,
                subtitle: strings.actionPrayersSub,
                onTap: onOpenPrayers,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.explore_rounded,
                title: strings.actionQibla,
                subtitle: strings.actionQiblaSub,
                onTap: onOpenQibla,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.fingerprint_rounded,
                title: strings.actionZikr,
                subtitle: strings.actionZikrSub,
                onTap: onOpenZikr,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.widgets_rounded,
                title: strings.actionWidget,
                subtitle: strings.actionWidgetSub,
                onTap: onOpenWidget,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 2. Sıra (Kur'an, Dualar, Hicri Takvim, Ramazan)
          Row(
            children: [
              _ActionCard(
                icon: Icons.menu_book_rounded,
                title: strings.tabQuran,
                subtitle: strings.actionQuranSub,
                onTap: onOpenQuran,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.auto_stories_rounded,
                title: strings.actionDuas,
                subtitle: strings.actionDuasSub,
                onTap: onOpenDuas,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: strings.actionCalendar,
                subtitle: strings.actionCalendarSub,
                onTap: onOpenCalendar,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.nights_stay_rounded,
                title: strings.actionRamadan,
                subtitle: strings.actionRamadanSub,
                onTap: onOpenRamadan,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isDark ? const Color(0xFF0D2823) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF133B34)
                    : const Color(0xFFE2EBE8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF033E35).withValues(alpha: isDark ? 0.35 : 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF11221F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Lüks İslami AppBar
// ════════════════════════════════════════════════════════════════

class _IslamicAppBar extends ConsumerWidget {
  const _IslamicAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? const Color(0xFF01201D),
      centerTitle: false,
      toolbarHeight: 60,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFDF7A).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.nights_stay_rounded,
              color: Color(0xFFFFDF7A),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Beyân',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        // Beyân Premium Rozeti
        IconButton(
          icon: Icon(
            ref.watch(premiumProvider).isPremium
                ? Icons.workspace_premium_rounded
                : Icons.workspace_premium_outlined,
            color: const Color(0xFFFFDF7A),
          ),
          tooltip: 'Beyân Premium',
          onPressed: () => PremiumPaywallSheet.show(context),
        ),
        // Lüks Ayarlar Butonu (Tek & Ferah)
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: strings.settings,
          onPressed: () => SettingsScreen.show(context),
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// "Bugün Kalbin Nasıl Hissediyor?" Ruh Haline Göre Âyet & Şifa
// ════════════════════════════════════════════════════════════════

class _SpiritualMoodsSection extends ConsumerWidget {
  const _SpiritualMoodsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language.code;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = strings.language == AppLanguage.english
        ? 'How is your heart feeling today?'
        : (strings.language == AppLanguage.arabic ? 'كيف يشعر قلبك اليوم؟' : 'Bugün Kalbin Nasıl Hissediyor?');

    final subtitle = strings.language == AppLanguage.english
        ? 'Tap for Quranic healing, prophetic dua & reflection'
        : (strings.language == AppLanguage.arabic ? 'آيات وأدعية شافية تناسب مشاعرك' : 'Ruh haline özel âyet-i kerîme, dua ve şifâ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF032620) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFFDF7A),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFDF7A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Duygu Çipleri (Pills)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: MoodVerseData.list.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => MoodVerseSheet.show(context, item),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? item.accentColor.withValues(alpha: 0.12)
                              : item.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.accentColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              item.localizedTitle(lang),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Yakındaki Camiler Hızlı Erişim Kartı
// ════════════════════════════════════════════════════════════════

class _NearbyMosquesCard extends ConsumerWidget {
  const _NearbyMosquesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyMosquesScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF02322C), const Color(0xFF01201D)]
                    : [const Color(0xFFF0FDF4), const Color(0xFFDCFCE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: isDark ? 0.4 : 0.6),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mosque_rounded,
                      color: Color(0xFF34D399),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            strings.language == AppLanguage.english
                                ? 'Nearby Mosques'
                                : (strings.language == AppLanguage.arabic ? 'المساجد القريبة' : 'Yakındaki Camiler'),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF064E3B),
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34D399).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'GPS & Harita',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        strings.language == AppLanguage.english
                            ? 'Find nearest mosques, walking distance & Apple Maps route'
                            : (strings.language == AppLanguage.arabic
                                ? 'ابحث عن أقرب المساجد ووقت المشي والاتجاهات'
                                : 'En yakın mescidleri gör, yürüme mesafesi ve rota al'),
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF047857),
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF34D399),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

