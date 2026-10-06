import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_strings.dart';
import '../../prayer_times/models/prayer_time_model.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';

/// Ana ekranın üst kısmında yer alan lüks zümrüt & altın namaz vakti kartı.
class PrayerCardWidget extends ConsumerWidget {
  const PrayerCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final countdownAsync = ref.watch(countdownStringProvider);
    final progressAsync = ref.watch(prayerProgressProvider);

    return prayerAsync.when(
      loading: () => _LoadingCard(),
      error: (e, _) => _ErrorCard(message: e.toString()),
      data: (daily) => _PrayerCard(
        daily: daily,
        countdownAsync: countdownAsync,
        progressAsync: progressAsync,
      ),
    );
  }
}

/// Yüklenme sırasında iskelet kart.
class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF012E2B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFDF7A), strokeWidth: 2),
      ),
    );
  }
}

/// Hata durumunda gösterilen kart.
class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF012E2B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(height: 8),
          Text(
            'Namaz vakitleri yüklenemedi: $message',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Ana namaz vakti kartı – zümrüt degrade, 24K altın detaylar, rekat bilgisi.
class _PrayerCard extends ConsumerWidget {
  final DailyPrayerTimes daily;
  final AsyncValue<String> countdownAsync;
  final AsyncValue<double> progressAsync;

  const _PrayerCard({
    required this.daily,
    required this.countdownAsync,
    required this.progressAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final langCode = strings.language.code;
    final next = daily.nextPrayerEntry;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF033E35),
            Color(0xFF01241F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF012E2B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Ana İçerik ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Konum + Tarih satırı
                _LocationRow(daily: daily, language: strings.language),
                const SizedBox(height: 16),

                // Namaz adı + Saat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol: Namaz adları & Rekat bilgisi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.nextPrayer,
                            style: const TextStyle(
                              color: Color(0xFFFFDF7A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            next?.name.localizedName(langCode) ?? '--',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          // İkincil isim (Arapça veya Türkçe)
                          Text(
                            strings.language == AppLanguage.arabic
                                ? (next?.name.turkish ?? '')
                                : (next?.name.arabic ?? ''),
                            style: TextStyle(
                              fontFamily: strings.language == AppLanguage.arabic ? null : 'Amiri',
                              color: Colors.white60,
                              fontSize: 17,
                              height: 1.5,
                            ),
                          ),
                          // ── Rekat Bilgisi Rozeti ─────────────────
                          if (next != null && next.name.rakatTotal > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFFFDF7A).withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.mosque_outlined,
                                    size: 13,
                                    color: Color(0xFFFFDF7A),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      next.name.localizedRakat(langCode),
                                      style: const TextStyle(
                                        color: Color(0xFFFFDF7A),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Sağ: Saat + Countdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          next != null ? _fmt(next.time) : '--:--',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 6),
                        countdownAsync.when(
                          data: (s) => _CountdownBadge(
                            text: '$s ${strings.remainingTime}',
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // İlerleme Çubuğu
                progressAsync.when(
                  data: (p) => _ProgressBar(
                    progress: p,
                    fromLabel: PrayerName.fromAdhan(daily.currentPrayer).localizedName(langCode),
                    toLabel: next?.name.localizedName(langCode) ?? '',
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ── Alt: Tüm Vakitler Mini Listesi ────────────────────
          _MiniPrayerRow(daily: daily, langCode: langCode),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Konum ve tarih satırı.
class _LocationRow extends StatelessWidget {
  final DailyPrayerTimes daily;
  final AppLanguage language;
  const _LocationRow({required this.daily, required this.language});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String dateStr;
    try {
      final localeTag = language == AppLanguage.english
          ? 'en_US'
          : (language == AppLanguage.arabic ? 'ar_SA' : 'tr_TR');
      dateStr = DateFormat('E, d MMM y', localeTag).format(now);
    } catch (_) {
      dateStr = '${now.day}.${now.month}.${now.year}';
    }

    return Row(
      children: [
        const Icon(Icons.location_on_rounded, color: Colors.white60, size: 14),
        const SizedBox(width: 4),
        Text(
          daily.locationName,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          dateStr,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }
}

/// Gerçek zamanlı geri sayım rozeti.
class _CountdownBadge extends StatelessWidget {
  final String text;
  const _CountdownBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDF7A).withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFFFDF7A)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFFFDF7A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mevcut → Sıradaki vakit ilerleme çubuğu.
class _ProgressBar extends StatelessWidget {
  final double progress;
  final String fromLabel;
  final String toLabel;

  const _ProgressBar({
    required this.progress,
    required this.fromLabel,
    required this.toLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFFDF7A),
            ),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fromLabel, style: const TextStyle(color: Colors.white54, fontSize: 11.5)),
            Text(toLabel, style: const TextStyle(color: Color(0xFFFFDF7A), fontSize: 11.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

/// Kartın alt şeridinde tüm vakitlerin mini satırı.
class _MiniPrayerRow extends StatelessWidget {
  final DailyPrayerTimes daily;
  final String langCode;
  const _MiniPrayerRow({required this.daily, required this.langCode});

  @override
  Widget build(BuildContext context) {
    final nextName = daily.nextPrayerEntry?.name;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: daily.prayers
            .where((p) => p.name != PrayerName.sunrise)
            .map((p) => _MiniPrayerItem(
                  entry: p,
                  isActive: p.name == nextName,
                  langCode: langCode,
                ))
            .toList(),
      ),
    );
  }
}

/// Mini vakit satırındaki tek vakit hücresi (Rekat sayısı ile birlikte).
class _MiniPrayerItem extends StatelessWidget {
  final PrayerEntry entry;
  final bool isActive;
  final String langCode;

  const _MiniPrayerItem({
    required this.entry,
    required this.isActive,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final h = entry.time.hour.toString().padLeft(2, '0');
    final m = entry.time.minute.toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD4AF37).withValues(alpha: 0.24) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: const Color(0xFFFFDF7A).withValues(alpha: 0.55), width: 1)
            : null,
      ),
      child: Column(
        children: [
          Text(
            entry.name.localizedName(langCode),
            style: TextStyle(
              color: isActive ? const Color(0xFFFFDF7A) : Colors.white60,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$h:$m',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          // Küçük rekat göstergesi (ör: 4R, 10R, 8R)
          if (entry.name.rakatTotal > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${entry.name.rakatTotal}R',
                style: TextStyle(
                  fontSize: 9,
                  color: isActive ? const Color(0xFFFFDF7A) : Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
