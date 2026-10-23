import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/dynamic_prayer_atmosphere.dart';
import '../../../main.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';
import '../../qibla/screens/qibla_compass_screen.dart';
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
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../elif_ba/screens/elif_ba_hub_screen.dart';
import '../../dua/screens/morning_evening_adhkar_screen.dart';
import '../../../core/widgets/luxury_page_route.dart';

/// Ana Ekran – Beyân lüks İslami kontrol merkezi.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final strings = ref.watch(appStringsProvider);
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final lastRead = ref.watch(lastReadProvider);
    final allSurahs = ref.watch(allSurahsProvider).valueOrNull ?? [];
    final nextReligiousDay = HijriCalendarService.instance.getNextReligiousDay();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFriday = DateTime.now().weekday == DateTime.friday;

    final nextPrayer = prayerAsync.valueOrNull?.nextPrayerEntry?.name;
    final atmosphere = (themeState.isDynamicPrayerTheme && isDark)
        ? DynamicPrayerAtmosphere.forPrayer(nextPrayer)
        : null;

    final scaffoldBg = isDark ? effectivePalette.darkBackground : effectivePalette.lightBackground;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Container(
        decoration: atmosphere != null
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: atmosphere.backgroundGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Lüks İslami AppBar ────────────────────────────────
            _IslamicAppBar(atmosphere: atmosphere),

            // ── Cuma Tebriği & Kehf Sûresi Sünneti Kartı ────────────
            if (isFriday)
              SliverToBoxAdapter(
                child: _FridayKahfBanner(
                  allSurahs: allSurahs,
                  atmosphere: atmosphere,
                ),
              ),

            // ── Yaklaşan Dini Gün / Kandil Bildirimi ────────────────
            if (nextReligiousDay != null)
              SliverToBoxAdapter(
                child: _UpcomingReligiousDayBanner(
                  day: nextReligiousDay,
                  atmosphere: atmosphere,
                ),
              ),

            // ── Namaz Vakti Kartı (Zümrüt & Altın) ─────────────────
            // ignore: prefer_const_constructors
            SliverToBoxAdapter(child: PrayerCardWidget()),

            // ── Son Okunan Kur'an'a Devam Etme Kartı ────────────────
            if (lastRead != null)
              SliverToBoxAdapter(
                child: _LastReadQuranCard(
                  lastRead: lastRead,
                  allSurahs: allSurahs,
                  atmosphere: atmosphere,
                ),
              ),

            // ── Hızlı Erişim Butonları (Genişletilmiş İslami Matris) ───
            SliverToBoxAdapter(
              child: _QuickActionGrid(
                atmosphere: atmosphere,
                onOpenPrayers: () => ref.read(selectedTabProvider.notifier).state = 1,
                onOpenQibla: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: const QiblaCompassScreen()),
                  );
                },
                onOpenZikr: () => ref.read(selectedTabProvider.notifier).state = 3,
                onOpenWidget: () => ref.read(selectedTabProvider.notifier).state = 4,
                onOpenQuran: () => ref.read(selectedTabProvider.notifier).state = 2,
                onOpenDuas: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: const DuaLibraryScreen()),
                  );
                },
                onOpenCalendar: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: const HijriCalendarScreen()),
                  );
                },
                onOpenRamadan: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: const RamadanDashboardScreen()),
                  );
                },
            ),
          ),

          // ── Beyân AI & Sesli Elif-Bâ Öne Çıkan Kartları ────────
          // ignore: prefer_const_constructors
          SliverToBoxAdapter(
            // ignore: prefer_const_constructors
            child: _SpotlightFeatureCards(),
          ),

          // ── 🌅 Sabah & Akşam Duaları Eşlikçisi (Hısnu'l-Müslim) ───
          SliverToBoxAdapter(
            child: _MorningEveningAdhkarBanner(atmosphere: atmosphere),
          ),

          // ── "Bugün Kalbin Nasıl Hissediyor?" (Ruh Haline Göre Âyet & Şifa) ───
          // ignore: prefer_const_constructors
          SliverToBoxAdapter(
            // ignore: prefer_const_constructors
            child: _SpiritualMoodsSection(),
          ),

          // ── Yakındaki Camiler & Harita Navigasyonu ───────────
          // ignore: prefer_const_constructors
          SliverToBoxAdapter(
            // ignore: prefer_const_constructors
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
                      color: BeyanColors.tone(0xFFD4AF37),
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
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      strings.diyanetMethod,
                      style: TextStyle(
                        fontSize: 11,
                        color: BeyanColors.tone(0xFFD4AF37),
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
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(color: BeyanColors.tone(0xFFD4AF37)),
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
          // ignore: prefer_const_constructors
          SliverToBoxAdapter(
            // ignore: prefer_const_constructors
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              // ignore: prefer_const_constructors
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
    ),
  );
}
}

// ════════════════════════════════════════════════════════════════
// Yaklaşan Mübarek Gün / Kandil Şeridi
// ════════════════════════════════════════════════════════════════

class _UpcomingReligiousDayBanner extends ConsumerWidget {
  final dynamic day; // ReligiousDay
  final DynamicPrayerAtmosphere? atmosphere;

  const _UpcomingReligiousDayBanner({required this.day, this.atmosphere});

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
            LuxuryPageRoute(page: const HijriCalendarScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: atmosphere != null
                  ? atmosphere!.cardGradient
                  : [BeyanColors.tone(0xFF03312B), BeyanColors.tone(0xFF01241F)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (atmosphere?.cardBorder ?? BeyanColors.tone(0xFFD4AF37)).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.black, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${day.localizedTitle(strings.language.code)} • $statusText',
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A),
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
// Cuma Tebriği & Kehf Sûresi Sünneti Kartı
// ════════════════════════════════════════════════════════════════

class _FridayKahfBanner extends ConsumerWidget {
  final List<Surah> allSurahs;
  final DynamicPrayerAtmosphere? atmosphere;

  const _FridayKahfBanner({required this.allSurahs, this.atmosphere});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              BeyanColors.tone(0xFF02362F),
              BeyanColors.tone(0xFF01201B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: BeyanColors.tone(0xFFFFDF7A), width: 1),
              ),
              child: const Text('🕌', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang == AppLanguage.turkish
                            ? 'Hayırlı Cumalar 🌙'
                            : (lang == AppLanguage.arabic ? 'جمعة مباركة 🌙' : 'Jummah Mubarak 🌙'),
                        style: TextStyle(
                          color: BeyanColors.tone(0xFFFFDF7A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          lang == AppLanguage.turkish ? 'Cuma Sünneti' : 'Sunnah',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lang == AppLanguage.turkish
                        ? 'Kehf Sûresi\'ni okumayı unutmayın'
                        : (lang == AppLanguage.arabic
                            ? 'قراءة سورة الكهف نور بين الجمعتين'
                            : 'Don\'t forget to recite Surah Al-Kahf'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                final kahfSurah = allSurahs.firstWhere(
                  (s) => s.id == 18,
                  orElse: () => const Surah(
                    id: 18,
                    nameArabic: 'الكهف',
                    nameTurkish: 'Kehf',
                    nameEnglish: 'The Cave',
                    verseCount: 110,
                    revelationType: 'meccan',
                  ),
                );
                Navigator.push(
                  context,
                  LuxuryPageRoute(
                    page: SurahDetailScreen(surah: kahfSurah),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BeyanColors.tone(0xFFD4AF37),
                foregroundColor: BeyanColors.tone(0xFF01201D),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                lang == AppLanguage.turkish ? 'Oku ➔' : (lang == AppLanguage.arabic ? 'اقرأ ➔' : 'Read ➔'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
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
  final DynamicPrayerAtmosphere? atmosphere;

  const _LastReadQuranCard({
    required this.lastRead,
    required this.allSurahs,
    this.atmosphere,
  });

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
            LuxuryPageRoute(
              page: SurahDetailScreen(
                surah: targetSurah,
                initialScrollToVerse: lastRead.verseNumber,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: atmosphere != null
                  ? atmosphere!.cardGradient
                  : [BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF02463B)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
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
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.continueReadingQuran,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BeyanColors.tone(0xFFFFDF7A),
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
              Icon(Icons.arrow_forward_ios_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 14),
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
          color: isDark ? BeyanColors.tone(0xFF071F1B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
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
                      ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.12 : 0.08)
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
                            ? BeyanColors.tone(0xFFD4AF37)
                            : (isDark ? BeyanColors.tone(0xFF0F322C) : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNext
                              ? BeyanColors.tone(0xFFFFDF7A)
                              : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
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
                                : (isDark ? BeyanColors.tone(0xFFFFDF7A) : AppColors.teal),
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
                                    color: BeyanColors.tone(0xFFD4AF37),
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
                            ? BeyanColors.tone(0xFFD4AF37)
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
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final todayVerseIndex = (now.year * 365 + dayOfYear) % ShortVerseNotification.pool.length;
    final verse = ShortVerseNotification.pool[todayVerseIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BeyanColors.tone(0xFF012E2B),
            BeyanColors.tone(0xFF023E36),
            isDark ? BeyanColors.tone(0xFF011C19) : BeyanColors.tone(0xFF012723),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
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
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: BeyanColors.tone(0xFFFFDF7A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strings.dailyVerseTitle,
                style: TextStyle(
                  color: BeyanColors.tone(0xFFFFDF7A),
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
          LuxuryPageRoute(page: const DuaLibraryScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BeyanColors.tone(0xFF02362F), BeyanColors.tone(0xFF012620)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
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
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite_outline_rounded,
                    color: BeyanColors.tone(0xFFFFDF7A),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.dailyDuaTitle,
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A),
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
              style: TextStyle(
                color: BeyanColors.tone(0xFFD4AF37),
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
// Öne Çıkan Lüks Özellik Kartları (Beyân AI & Sesli Elif-Bâ)
// ════════════════════════════════════════════════════════════════

class _SpotlightFeatureCards extends StatelessWidget {
  const _SpotlightFeatureCards();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      child: Row(
        children: [
          // Beyân AI Manevi Rehber Kartı
          Expanded(
            child: _SpotlightCard(
              title: 'Beyân AI',
              subtitle: 'Manevi Rehber & Tefsir',
              badge: 'YENİ ✨',
              icon: Icons.auto_awesome_rounded,
              gradientColors: isDark
                  ? [BeyanColors.tone(0xFF04382F), BeyanColors.tone(0xFF021F1A)]
                  : [BeyanColors.tone(0xFFE8F6F0), Colors.white],
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  LuxuryPageRoute(page: const AiAssistantScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Sesli Elif-Bâ Kartı
          Expanded(
            child: _SpotlightCard(
              title: 'Sesli Elif-Bâ',
              subtitle: 'Çocuk & Başlangıç Talimi',
              badge: 'EĞLENCELİ 🎯',
              icon: Icons.menu_book_rounded,
              gradientColors: isDark
                  ? [BeyanColors.tone(0xFF0C3D32), BeyanColors.tone(0xFF031E18)]
                  : [const Color(0xFFFBF4DF), Colors.white],
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  LuxuryPageRoute(page: const ElifBaHubScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MorningEveningAdhkarBanner extends StatelessWidget {
  final DynamicPrayerAtmosphere? atmosphere;
  const _MorningEveningAdhkarBanner({this.atmosphere});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isMorning = hour >= 4 && hour < 15;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              LuxuryPageRoute(page: MorningEveningAdhkarScreen(initialIsMorning: isMorning)),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMorning
                    ? (isDark
                        ? [BeyanColors.tone(0xFF04483D), BeyanColors.tone(0xFF012C25)]
                        : [BeyanColors.tone(0xFFE2F3ED), Colors.white])
                    : (isDark
                        ? [BeyanColors.tone(0xFF012E27), BeyanColors.tone(0xFF001915)]
                        : [BeyanColors.tone(0xFFE7ECEB), Colors.white]),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFD4AF37)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: BeyanColors.tone(0xFF012E2B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isMorning ? '🌅 Sabah Virdi' : '🌙 Akşam Virdi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF01362F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Hısnu\'l-Müslim',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: BeyanColors.tone(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isMorning
                            ? 'Güne ilahi muhafaza ve koruyucu dualarla başlayın (3 Dk)'
                            : 'Günün yorgunluğunu akşam dualarıyla arındırın (3 Dk)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : BeyanColors.tone(0xFF334E48),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: BeyanColors.tone(0xFFD4AF37),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _SpotlightCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFB8860B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: BeyanColors.tone(0xFF01201B), size: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFFFDF7A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: BeyanColors.tone(0xFF012E2B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : Colors.black54,
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
  final DynamicPrayerAtmosphere? atmosphere;

  const _QuickActionGrid({
    required this.onOpenPrayers,
    required this.onOpenQibla,
    required this.onOpenZikr,
    required this.onOpenWidget,
    required this.onOpenQuran,
    required this.onOpenDuas,
    required this.onOpenCalendar,
    required this.onOpenRamadan,
    this.atmosphere,
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
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.explore_rounded,
                title: strings.actionQibla,
                subtitle: strings.actionQiblaSub,
                onTap: onOpenQibla,
                isDark: isDark,
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.fingerprint_rounded,
                title: strings.actionZikr,
                subtitle: strings.actionZikrSub,
                onTap: onOpenZikr,
                isDark: isDark,
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.widgets_rounded,
                title: strings.actionWidget,
                subtitle: strings.actionWidgetSub,
                onTap: onOpenWidget,
                isDark: isDark,
                atmosphere: atmosphere,
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
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.auto_stories_rounded,
                title: strings.actionDuas,
                subtitle: strings.actionDuasSub,
                onTap: onOpenDuas,
                isDark: isDark,
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: strings.actionCalendar,
                subtitle: strings.actionCalendarSub,
                onTap: onOpenCalendar,
                isDark: isDark,
                atmosphere: atmosphere,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.nights_stay_rounded,
                title: strings.actionRamadan,
                subtitle: strings.actionRamadanSub,
                onTap: onOpenRamadan,
                isDark: isDark,
                atmosphere: atmosphere,
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
  final DynamicPrayerAtmosphere? atmosphere;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    this.atmosphere,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = atmosphere?.actionCardBg ?? (isDark ? BeyanColors.tone(0xFF0D2823) : Colors.white);
    final borderColor = atmosphere != null
        ? atmosphere!.actionCardBorder.withValues(alpha: 0.6)
        : (isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE2EBE8));
    final iconColor = atmosphere?.accentGold ?? BeyanColors.tone(0xFFD4AF37);

    return Expanded(
      child: Material(
        color: bgColor,
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
                color: borderColor,
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
                    color: iconColor.withValues(alpha: isDark ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : BeyanColors.tone(0xFF11221F),
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
  final DynamicPrayerAtmosphere? atmosphere;
  const _IslamicAppBar({this.atmosphere});

  String _getSpiritualGreeting(AppStrings strings) {
    final now = DateTime.now();
    if (now.weekday == DateTime.friday) {
      return strings.language == AppLanguage.turkish ? 'Cumanız Mübarek Olsun 🕊️' : 'Jummah Mubarak 🕊️';
    }
    final hour = now.hour;
    if (hour >= 4 && hour < 11) {
      return strings.language == AppLanguage.turkish ? 'Hayırlı Sabahlar 🌅' : 'Good Morning 🌅';
    } else if (hour >= 11 && hour < 17) {
      return strings.language == AppLanguage.turkish ? 'Hayırlı Günler 🌿' : 'Blessed Day 🌿';
    } else if (hour >= 17 && hour < 21) {
      return strings.language == AppLanguage.turkish ? 'Hayırlı Akşamlar 🌇' : 'Good Evening 🌇';
    } else {
      return strings.language == AppLanguage.turkish ? 'Hayırlı Geceler 🌙' : 'Peaceful Night 🌙';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return SliverAppBar(
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: atmosphere?.appBarColor ?? (Theme.of(context).appBarTheme.backgroundColor ?? BeyanColors.tone(0xFF01201D)),
      centerTitle: false,
      toolbarHeight: 64,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                  blurRadius: 6,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Beyân',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  height: 1.1,
                ),
              ),
              Text(
                _getSpiritualGreeting(strings),
                style: TextStyle(
                  color: BeyanColors.tone(0xFFFFDF7A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
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

    final title = strings.howIsHeartToday;
    final subtitle = strings.howIsHeartSubtitle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF032620) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
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
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: BeyanColors.tone(0xFFFFDF7A),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFFFDF7A),
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
              LuxuryPageRoute(page: const NearbyMosquesScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [BeyanColors.tone(0xFF02322C), BeyanColors.tone(0xFF01201D)]
                    : [BeyanColors.tone(0xFFF0FDF4), BeyanColors.tone(0xFFDCFCE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BeyanColors.tone(0xFF34D399).withValues(alpha: isDark ? 0.4 : 0.6),
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
                    color: BeyanColors.tone(0xFF34D399).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BeyanColors.tone(0xFF34D399).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mosque_rounded,
                      color: BeyanColors.tone(0xFF34D399),
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
                            strings.nearbyMosques,
                            style: TextStyle(
                              color: isDark ? Colors.white : BeyanColors.tone(0xFF064E3B),
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFF34D399).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              strings.gpsAndMap,
                              style: TextStyle(
                                color: BeyanColors.tone(0xFF059669),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        strings.nearbyMosquesSubtitle,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : BeyanColors.tone(0xFF047857),
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: BeyanColors.tone(0xFF34D399),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

