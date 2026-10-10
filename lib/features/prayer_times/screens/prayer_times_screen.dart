import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_constants.dart';
import '../models/prayer_time_model.dart';
import '../providers/prayer_time_providers.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import 'city_selector_sheet.dart';
import '../../settings/screens/settings_screen.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import 'prayer_guide_sheet.dart';

/// Tüm günlük namaz vakitlerini listeleyen tam ekran.
/// Ana ekranın alt kısmında veya ayrı bir sekme olarak kullanılır.
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.tabPrayers),
        actions: [
          // Şehir / Konum Seçici Buton
          IconButton(
            icon: const Icon(Icons.location_on_rounded, color: Color(0xFFFFDF7A)),
            tooltip: strings.language == AppLanguage.turkish
                ? 'Şehir Değiştir'
                : (strings.language == AppLanguage.english ? 'Change City' : 'تغيير المدينة'),
            onPressed: () => CitySelectorSheet.show(context, ref),
          ),
          // Lüks Ayarlar Butonu (Hesaplama Metodu, Ezan Makamları, Bildirimler, Dil vb.)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: strings.settings,
            onPressed: () => SettingsScreen.show(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: prayerAsync.when(
        loading: () => const app_widgets.LoadingWidget(
          message: '...',
        ),
        error: (error, _) => app_widgets.AppErrorWidget(
          message: '$error',
          onRetry: () {
            ref.read(prayerTimesNotifierProvider.notifier).refresh();
          },
        ),
        data: (daily) => _PrayerTimesContent(
          daily: daily,
        ),
      ),
    );
  }
}

/// Namaz vakitleri içerik widget'ı.
class _PrayerTimesContent extends ConsumerWidget {
  final DailyPrayerTimes daily;

  const _PrayerTimesContent({
    required this.daily,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Üst Bilgi Kartı (Konum + Tarih) ──────────────────
          _LocationDateCard(daily: daily, strings: strings),
          const SizedBox(height: 16),

          // ── Sıradaki Vakit Banner ─────────────────────────────
          _NextPrayerBanner(
            daily: daily,
            strings: strings,
          ),
          const SizedBox(height: 20),

          // ── Günlük Vakit Listesi ──────────────────────────────
          app_widgets.SectionHeader(title: strings.dailyPrayers),
          ...daily.prayers.map(
            (entry) => _PrayerTimeCard(
              entry: entry,
              isNext: daily.nextPrayerEntry?.name == entry.name,
              isCurrent: PrayerName.fromAdhan(daily.currentPrayer) == entry.name,
            ),
          ),
          const SizedBox(height: 16),
          const BannerAdWidget(),
          const SizedBox(height: 110),
        ],
      ),
    );
  }
}

/// Konum ve tarih bilgisi kartı.
class _LocationDateCard extends StatelessWidget {
  final DailyPrayerTimes daily;
  final AppStrings strings;
  const _LocationDateCard({required this.daily, required this.strings});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_monthName(now.month, strings.language)} ${now.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.teal, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    daily.locationName == 'Mevcut Konum'
                        ? strings.currentLocation
                        : daily.locationName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // GPS veya varsayılan konum ikonu
            Icon(
              daily.latitude == AppConstants.defaultLatitude
                  ? Icons.location_city_rounded
                  : Icons.gps_fixed_rounded,
              color: AppColors.textHint,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month, AppLanguage lang) {
    if (lang == AppLanguage.english) {
      const months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      return months[month];
    }
    if (lang == AppLanguage.arabic) {
      const months = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return months[month];
    }
    const months = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return months[month];
  }
}

/// Sıradaki namaz vakti banner'ı – büyük countdown ile.
class _NextPrayerBanner extends ConsumerWidget {
  final DailyPrayerTimes daily;
  final AppStrings strings;

  const _NextPrayerBanner({
    required this.daily,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = daily.nextPrayerEntry;
    final service = _PrayerTimeServiceHelper();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tealDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Sıradaki Namaz Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFDF7A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.nextPrayer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (next != null && next.name.rakatTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    strings.rakatsCount(next.name.rakatTotal),
                    style: const TextStyle(
                      color: Color(0xFFFFDF7A),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next?.name.localizedName(strings.language.code) ?? '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Arapça isim
                    Text(
                      next?.name.arabic ?? '',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white60,
                        fontSize: 17,
                        height: 1.4,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Vakit saati
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    next != null ? service.fmt(next.time) : '--:--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Gerçek zamanlı countdown (İzole edilmiş Consumer ve RepaintBoundary)
                  RepaintBoundary(
                    child: Consumer(
                      builder: (context, ref, _) {
                        final countdownAsync = ref.watch(countdownStringProvider);
                        final s = ref.watch(appStringsProvider);
                        return countdownAsync.when(
                          data: (str) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '⏱ $str ${s.remainingTime}',
                              style: const TextStyle(
                                color: Color(0xFFFFDF7A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Rekat Ayrıntı Rozeti (Dokunulduğunda namaz rehberini açar)
          if (next != null && next.name.rakatTotal > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => PrayerGuideSheet.show(context, ref, next.name, next.time),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFFDF7A).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mosque_rounded,
                      size: 13,
                      color: Color(0xFFFFDF7A),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        next.name.localizedRakat(strings.language.code),
                        style: const TextStyle(
                          color: Color(0xFFFFDF7A),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: Color(0xFFFFDF7A),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Canlı ve Aktif İlerleme Çizelgesi (İzole edilmiş Consumer)
          RepaintBoundary(
            child: Consumer(
              builder: (context, ref, _) {
                final progressAsync = ref.watch(prayerProgressProvider);
                final progress = (progressAsync.valueOrNull ?? 0.0).clamp(0.0, 1.0);
                final percent = (progress * 100).toInt();

                return GestureDetector(
                  onTap: () {
                    if (next != null) {
                      PrayerGuideSheet.show(context, ref, next.name, next.time);
                    }
                  },
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, _) {
                              return FractionallySizedBox(
                                widthFactor: val.clamp(0.01, 1.0),
                                child: Container(
                                  height: 7,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD4AF37), Color(0xFFFFDF7A), Color(0xFFFFF3B0)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFDF7A).withValues(alpha: 0.45),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                daily.localizedCurrentPrayerName(strings.language.code),
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFDF7A).withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '%$percent',
                              style: const TextStyle(
                                color: Color(0xFFFFDF7A),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                next?.name.localizedName(strings.language.code) ?? '',
                                style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFFFDF7A).withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek bir namaz vakti satırı kartı.
class _PrayerTimeCard extends ConsumerWidget {
  final PrayerEntry entry;
  final bool isNext;
  final bool isCurrent;

  const _PrayerTimeCard({
    required this.entry,
    required this.isNext,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final helper = _PrayerTimeServiceHelper();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Aktif/sıradaki vakit için farklı stil
    Color cardColor;
    if (isNext) {
      cardColor = AppColors.teal.withValues(alpha: isDark ? 0.25 : 0.12);
    } else if (isCurrent) {
      cardColor = AppColors.gold.withValues(alpha: isDark ? 0.2 : 0.1);
    } else {
      cardColor = Theme.of(context).cardColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(color: AppColors.teal.withValues(alpha: 0.5), width: 1.5)
            : isCurrent
                ? Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1)
                : null,
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => PrayerGuideSheet.show(context, ref, entry.name, entry.time),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // İkon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _iconBgColor(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isNext ? AppColors.teal : (isCurrent ? AppColors.gold : Colors.grey.withValues(alpha: 0.3)),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.name.arabic,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        color: _iconTextColor(),
                        height: 1.6,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Namaz adı ve Rekat Bilgisi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.name.localizedName(strings.language.code),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                color: isNext ? AppColors.teal : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                strings.currentPrayer,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isNext)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                strings.nextPrayer,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Rekat Bilgisi & Rehber İpucu
                      Row(
                        children: [
                          const Icon(
                            Icons.mosque_rounded,
                            size: 12,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              entry.name.localizedRakat(strings.language.code),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF8C6D08),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 13,
                            color: const Color(0xFFFFDF7A).withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Saat
                Text(
                  helper.fmt(entry.time),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w300,
                    color: isNext
                        ? AppColors.teal
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _iconBgColor(bool isDark) {
    if (isNext) return AppColors.teal.withValues(alpha: 0.2);
    if (isCurrent) return AppColors.gold.withValues(alpha: 0.2);
    return isDark ? Colors.white10 : Colors.grey.shade100;
  }

  Color _iconTextColor() {
    if (isNext) return AppColors.teal;
    if (isCurrent) return AppColors.gold;
    return AppColors.textSecondary;
  }
}

// Küçük yardımcı – servis import'u olmadan saat formatlamak için
class _PrayerTimeServiceHelper {
  String fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}


