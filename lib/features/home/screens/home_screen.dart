import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';
import '../../qibla/screens/qibla_compass_screen.dart';
import '../../notifications/screens/notification_settings_sheet.dart';
import '../../../core/theme/screens/theme_selection_sheet.dart';
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
import '../widgets/prayer_card_widget.dart';

/// Ana Ekran – Beyân lüks İslami kontrol merkezi.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
                  'Vakitler yüklenemedi: $e',
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

class _UpcomingReligiousDayBanner extends StatelessWidget {
  final dynamic day; // ReligiousDay

  const _UpcomingReligiousDayBanner({required this.day});

  @override
  Widget build(BuildContext context) {
    final days = day.daysRemaining as int;
    final isToday = day.isToday as bool;

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
                  '${day.title} • ${isToday ? "Bugün!" : "$days gün kaldı"}',
                  style: const TextStyle(
                    color: Color(0xFFFFDF7A),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                'Takvim ➔',
                style: TextStyle(color: Colors.white70, fontSize: 11),
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

class _LastReadQuranCard extends StatelessWidget {
  final LastReadPosition lastRead;
  final List<Surah> allSurahs;

  const _LastReadQuranCard({required this.lastRead, required this.allSurahs});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Kur\'an-ı Kerim Okumaya Devam Et',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFDF7A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lastRead.surahName} Suresi • ${lastRead.verseNumber}. Ayet',
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

class _DailyVerseCompactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const Text(
                'Günün Ayet-i Kerimesi',
                style: TextStyle(
                  color: Color(0xFFFFDF7A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              const Text(
                'İsrâ 78',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'أَقِمِ ٱلصَّلَوٰةَ لِدُلُوكِ ٱلشَّمْسِ إِلَىٰ غَسَقِ ٱلَّيْلِ وَقُرْءَانَ ٱلْفَجْرِ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              height: 1.6,
              color: Colors.white,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            'Güneşin batıya kaymasından gecenin kararmasına kadar namazı kıl; bir de sabah namazını. Çünkü sabah namazı şahitlidir.',
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
                const Text(
                  'Günün Niyazı ve Duası',
                  style: TextStyle(
                    color: Color(0xFFFFDF7A),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Tüm Dualar ➔',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
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
              dua.turkishMeaning,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dua.reference,
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
                subtitle: '6 Vakit',
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
                subtitle: '114 Sure',
                onTap: onOpenQuran,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.auto_stories_rounded,
                title: 'Dualar',
                subtitle: '10 Kategori',
                onTap: onOpenDuas,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Hicri Takvim',
                subtitle: 'Kandiller',
                onTap: onOpenCalendar,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _ActionCard(
                icon: Icons.nights_stay_rounded,
                title: 'Ramazan',
                subtitle: 'İftar/Sahur',
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
    final currentLang = ref.watch(appLanguageProvider);

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
        // Beyân Premium Üyelik Butonu
        IconButton(
          icon: Icon(
            ref.watch(premiumProvider).isPremium
                ? Icons.workspace_premium_rounded
                : Icons.workspace_premium_outlined,
            color: const Color(0xFFFFDF7A),
          ),
          tooltip: ref.watch(premiumProvider).isPremium ? 'Beyân Premium' : 'Premium & Reklamsız',
          onPressed: () => PremiumPaywallSheet.show(context),
        ),
        // Tema Seçici Butonu
        IconButton(
          icon: const Icon(Icons.palette_outlined, color: Color(0xFFFFDF7A)),
          tooltip: 'Görünüm & Tema',
          onPressed: () => ThemeSelectionSheet.show(context),
        ),
        // Dil Seçici Buton
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showLanguageSelectorSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentLang.flag, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    currentLang.shortCode,
                    style: const TextStyle(
                      color: Color(0xFFFFDF7A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Ezan Bildirim Ayarları Butonu
        IconButton(
          icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFFDF7A)),
          tooltip: 'Ezan Bildirimleri',
          onPressed: () => NotificationSettingsSheet.show(context),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: strings.settings,
          onPressed: () => showWidgetSettings(context),
        ),
      ],
    );
  }
}
