import 'dart:ui';
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
import '../../widget_service/screens/widget_center_screen.dart';
import '../widgets/prayer_card_widget.dart';

/// Ana Ekran – Beyân lüks İslami arayüzü (Kur'an listesi menüden kaldırılmış ferah tasarım).
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Lüks İslami AppBar ────────────────────────────────
          const _IslamicAppBar(),

          // ── Namaz Vakti Kartı (Zümrüt & Altın) ─────────────────
          const SliverToBoxAdapter(child: PrayerCardWidget()),

          // ── Hızlı Erişim Butonları (Vakitler, Kıble, Zikirmatik, Widget)
          SliverToBoxAdapter(
            child: _QuickActionGrid(
              onOpenPrayers: () {
                // Vakitler sekmesine geç
                ref.read(selectedTabProvider.notifier).state = 1;
              },
              onOpenQibla: () => _showQiblaDialog(context, strings),
              onOpenZikr: () {
                // Zikirmatik sekmesine geç (Index 3)
                ref.read(selectedTabProvider.notifier).state = 3;
              },
              onOpenWidget: () {
                // Widget sekmesine geç (Index 4)
                ref.read(selectedTabProvider.notifier).state = 4;
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
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: _DailyVerseCompactCard(),
            ),
          ),

          // Alt boşluk (Yüzen lüks dock için ferah alan)
          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }

  void _showQiblaDialog(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? const Color(0xFF0D2823)
            : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore_rounded, color: Color(0xFFD4AF37)),
            ),
            const SizedBox(width: 12),
            Text(strings.actionQibla, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                gradient: const RadialGradient(
                  colors: [Color(0xFF033E35), Color(0xFF01201D)],
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation_rounded, color: Color(0xFFFFDF7A), size: 36),
                    SizedBox(height: 4),
                    Text(
                      '152°',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${strings.actionQibla}: 152° Güney-Güneydoğu (İstanbul / Türkiye)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.close, style: const TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
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
            color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
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
                      ? const Color(0xFFD4AF37).withOpacity(isDark ? 0.12 : 0.08)
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
                    // İkon / Rozet
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
                              : const Color(0xFFD4AF37).withOpacity(0.2),
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

                    // İsim & Rekat
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

                    // Saat
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
          color: const Color(0xFFD4AF37).withOpacity(0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
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
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Hızlı Erişim Butonları Grid
// ════════════════════════════════════════════════════════════════

class _QuickActionGrid extends ConsumerWidget {
  final VoidCallback onOpenPrayers;
  final VoidCallback onOpenQibla;
  final VoidCallback onOpenZikr;
  final VoidCallback onOpenWidget;

  const _QuickActionGrid({
    required this.onOpenPrayers,
    required this.onOpenQibla,
    required this.onOpenZikr,
    required this.onOpenWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
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
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
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
                    color: const Color(0xFF033E35).withOpacity(isDark ? 0.35 : 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
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
      backgroundColor: const Color(0xFF01201D),
      centerTitle: false,
      toolbarHeight: 60,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFDF7A).withOpacity(0.5),
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
        // Dil Seçici Buton
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showLanguageSelectorSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
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
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: strings.settings,
          onPressed: () => showWidgetSettings(context),
        ),
      ],
    );
  }
}
