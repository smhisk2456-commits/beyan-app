import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/dynamic_prayer_atmosphere.dart';
import '../../../main.dart';
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
import '../../quran/screens/thematic_atlas_screen.dart';
import '../../../core/widgets/luxury_page_route.dart';
import 'package:share_plus/share_plus.dart';
import '../../prayer_times/screens/wudu_guide_sheet.dart';
import '../../zikr/screens/zikirmatik_screen.dart';

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
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final lastRead = ref.watch(lastReadProvider);
    final allSurahs = ref.watch(allSurahsProvider).valueOrNull ?? [];
    final nextReligiousDay = HijriCalendarService.instance.getNextReligiousDay();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    // Cuma atmosferi: Perşembe akşamı (17:00'den itibaren cuma gecesi) ve Cuma gününün tamamında aktiftir
    final isFriday = (now.weekday == DateTime.thursday && now.hour >= 17) ||
                     (now.weekday == DateTime.friday);

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

            // ── Hızlı Erişim Butonları (Tek Sıra 4 Odaklı Araç) ───
            SliverToBoxAdapter(
              child: _QuickActionGrid(
                atmosphere: atmosphere,
                onOpenQibla: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: const QiblaCompassScreen()),
                  );
                },
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

            // ── Keşfet & İslami Rehber Hub (2x3 Bento Grid) ────────
            SliverToBoxAdapter(
              child: _SpiritualLifeHub(atmosphere: atmosphere),
            ),

            // ── "Bugün Kalbin Nasıl Hissediyor?" (Ruh Haline Göre Âyet & Şifa) ───
            // ignore: prefer_const_constructors
            SliverToBoxAdapter(
              // ignore: prefer_const_constructors
              child: _SpiritualMoodsSection(),
            ),

            // ── Günün Manevi İlhamı (Âyet & Doğrulanmış Dua) ────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: _DailyInspirationCard(),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              BeyanColors.tone(0xFF023F36),
              BeyanColors.tone(0xFF01241E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.6),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır: Rozet + Başlık + Cuma İkonu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
                  ),
                  child: const Text('🕌', style: TextStyle(fontSize: 20)),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lang == AppLanguage.turkish ? 'MÜBAREK VAKİT' : 'SUNNAH',
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang == AppLanguage.turkish
                            ? 'Cuma, üzerine güneşin doğduğu en hayırlı gündür.'
                            : 'Friday is the best day upon which the sun has risen.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Fazilet & Tavsiye Kutusu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16, color: BeyanColors.tone(0xFFFFDF7A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang == AppLanguage.turkish
                          ? 'Cuma Sünnetleri: Kehf Sûresi tilaveti, bolca Salavât-ı Şerîfe ve Cuma guslü.'
                          : 'Sunnahs of Friday: Reciting Surah Al-Kahf, abundant Salawat, and Ghusl.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Aksiyon Butonları (Kehf Oku, Salavat, Tebrik Paylaş, Cuma Guslü)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 1. Kehf Suresi Oku
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.menu_book_rounded, size: 15),
                  label: Text(
                    lang == AppLanguage.turkish ? 'Kehf Sûresi (18)' : 'Surah Al-Kahf',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
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
                ),

                // 2. Salavât Getir
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      LuxuryPageRoute(
                        page: const ZikirmatikScreen(),
                      ),
                    );
                  },
                  icon: const Text('📿', style: TextStyle(fontSize: 13)),
                  label: Text(
                    lang == AppLanguage.turkish ? 'Salavât Sayacı' : 'Salawat',
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // 3. Cuma Tebriği Paylaş
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Hayırlı Cumalar! 🌙\n\n'
                            '"Üzerine güneşin doğduğu en hayırlı gün Cuma günüdür." (Müslim, Cum‘a 18)\n\n'
                            'Cumanız mübarek, dualarınız ve ibadetleriniz kabul olsun.\n\n'
                            '— Beyân: Namaz Vakitleri & Kur\'an ile paylaşıldı.',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 14, color: Colors.white70),
                  label: Text(
                    lang == AppLanguage.turkish ? 'Tebrik Paylaş' : 'Share Greeting',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // 4. Cuma Guslü ve Abdest
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    WuduGuideSheet.show(context, 1);
                  },
                  icon: const Text('💧', style: TextStyle(fontSize: 13)),
                  label: Text(
                    lang == AppLanguage.turkish ? 'Cuma Guslü' : 'Ghusl',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
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
// Keşfet & İslami Yaşam Hub (2x3 Bento Grid)
// ════════════════════════════════════════════════════════════════

class _SpiritualLifeHub extends ConsumerWidget {
  final DynamicPrayerAtmosphere? atmosphere;
  const _SpiritualLifeHub({this.atmosphere});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = DateTime.now().hour;
    final isMorning = hour >= 4 && hour < 15;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bölüm Başlığı
          Row(
            children: [
              Container(
                width: 3.5,
                height: 16,
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Keşfet & İslami Yaşam',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: isDark ? Colors.white : BeyanColors.tone(0xFF012E2B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '6 Rehber',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2x3 Kompakt Bento Matrisi
          // 1. Sıra: Beyân AI + Sesli Elif-Bâ
          Row(
            children: [
              Expanded(
                child: _HubCard(
                  title: 'Beyân AI',
                  subtitle: 'Manevi Rehber & Tefsir',
                  badge: 'YAPAY ZEKA ✨',
                  icon: Icons.auto_awesome_rounded,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      LuxuryPageRoute(page: const AiAssistantScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HubCard(
                  title: 'Sesli Elif-Bâ',
                  subtitle: 'Çocuk & Başlangıç',
                  badge: 'SESLİ 🎯',
                  icon: Icons.menu_book_rounded,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      LuxuryPageRoute(page: const ElifBaHubScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Sıra: Abdest Rehberi + Tematik Kur'an Fihristi
          Row(
            children: [
              Expanded(
                child: _HubCard(
                  title: 'Abdest Rehberi',
                  subtitle: 'Namaz, Gusül & Teyemmüm',
                  badge: 'GÖRSEL 💧',
                  icon: Icons.water_drop_rounded,
                  isDark: isDark,
                  onTap: () => WuduGuideSheet.show(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HubCard(
                  title: 'Tematik Kur\'an',
                  subtitle: '12 Konu & Hayat Âyetleri',
                  badge: 'FİHRİST 📖',
                  icon: Icons.explore_rounded,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      LuxuryPageRoute(page: const ThematicAtlasScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Sıra: Sabah/Akşam Virdi + Yakındaki Camiler
          Row(
            children: [
              Expanded(
                child: _HubCard(
                  title: isMorning ? 'Sabah Virdi' : 'Akşam Virdi',
                  subtitle: isMorning ? 'Koruyucu Dualar (3 Dk)' : 'Akşam Duaları (3 Dk)',
                  badge: isMorning ? 'SABAH 🌅' : 'AKŞAM 🌙',
                  icon: isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      LuxuryPageRoute(page: MorningEveningAdhkarScreen(initialIsMorning: isMorning)),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HubCard(
                  title: 'Yakındaki Camiler',
                  subtitle: 'En Yakın Mescidler & GPS',
                  badge: 'HARİTA 📍',
                  icon: Icons.mosque_rounded,
                  isDark: isDark,
                  accentColor: const Color(0xFF34D399),
                  onTap: () {
                    Navigator.push(
                      context,
                      LuxuryPageRoute(page: const NearbyMosquesScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color? accentColor;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final primaryAccent = accentColor ?? BeyanColors.tone(0xFFD4AF37);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      BeyanColors.tone(0xFF062923),
                      BeyanColors.tone(0xFF031A16),
                    ]
                  : [
                      const Color(0xFFF6FAF8),
                      Colors.white,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryAccent.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryAccent.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, color: primaryAccent, size: 17),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: primaryAccent.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? gold : BeyanColors.tone(0xFF01362F),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : BeyanColors.tone(0xFF052B24),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Günün Manevi İlhamı (Âyet & Doğrulanmış Dua Birleşik Lüks Kart)
// ════════════════════════════════════════════════════════════════

class _DailyInspirationCard extends ConsumerStatefulWidget {
  const _DailyInspirationCard();

  @override
  ConsumerState<_DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends ConsumerState<_DailyInspirationCard> {
  int _tabIndex = 0; // 0: Âyet-i Kerîme, 1: Günün Duası

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final todayVerseIndex = (now.year * 365 + dayOfYear) % ShortVerseNotification.pool.length;
    final verse = ShortVerseNotification.pool[todayVerseIndex];
    final dua = ref.watch(dailyFeaturedDuaProvider);

    return Container(
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
        borderRadius: BorderRadius.circular(22),
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
          // Segmented Tab Switcher (Âyet-i Kerîme / Günün Duası)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabIndex = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _tabIndex == 0 ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 14,
                              color: _tabIndex == 0 ? Colors.black87 : BeyanColors.tone(0xFFFFDF7A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.dailyVerseTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _tabIndex == 0 ? Colors.black87 : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tabIndex = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _tabIndex == 1 ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: _tabIndex == 1 ? Colors.black87 : BeyanColors.tone(0xFFFFDF7A),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              strings.dailyDuaTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _tabIndex == 1 ? Colors.black87 : Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İçerik: Tab 0 (Günün Ayeti) veya Tab 1 (Günün Duası)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: _tabIndex == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 8),
                      Text(
                        verse.localizedText(strings.language.code),
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              verse.localizedReference(strings.language.code),
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(selectedTabProvider.notifier).state = 2; // Kur'an Sekmesi
                            },
                            child: Row(
                              children: [
                                Text(
                                  strings.tabQuran,
                                  style: TextStyle(
                                    color: BeyanColors.tone(0xFFFFDF7A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 13, color: BeyanColors.tone(0xFFFFDF7A)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 8),
                      Text(
                        dua.localizedMeaning(strings.language.code),
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              dua.localizedReference(strings.language.code),
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                LuxuryPageRoute(page: const DuaLibraryScreen()),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  strings.allDuasLink,
                                  style: TextStyle(
                                    color: BeyanColors.tone(0xFFFFDF7A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 13, color: BeyanColors.tone(0xFFFFDF7A)),
                              ],
                            ),
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
}

// ════════════════════════════════════════════════════════════════
// Hızlı Erişim Butonları (Kompakt Tek Sıra - 4 Odaklı Araç)
// ════════════════════════════════════════════════════════════════

class _QuickActionGrid extends ConsumerWidget {
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenDuas;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenRamadan;
  final DynamicPrayerAtmosphere? atmosphere;

  const _QuickActionGrid({
    required this.onOpenQibla,
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
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
