import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../main.dart';
import '../../quran/repositories/quran_repository.dart';
import '../../quran/screens/surah_detail_screen.dart';
import '../../../core/widgets/luxury_page_route.dart';
import '../models/prayer_how_to_model.dart';
import '../models/prayer_time_model.dart';

/// Namaz Rekat Adımı Modeli
class PrayerRakatStep {
  final String title;
  final String type;
  final String detail;

  const PrayerRakatStep({
    required this.title,
    required this.type,
    required this.detail,
  });
}

/// Namazda Okunacak Tavsiye Sûre / Âyet Modeli
class PrayerRecommendedSurah {
  final int surahId;
  final int? verseNumber;
  final String name;
  final String arabicName;
  final String note;
  final bool isFeatured;

  const PrayerRecommendedSurah({
    required this.surahId,
    this.verseNumber,
    required this.name,
    required this.arabicName,
    required this.note,
    this.isFeatured = false,
  });
}

/// Namaz Rehberi & Rekat Bilgisi Modal Bottom Sheet
class PrayerGuideSheet extends ConsumerStatefulWidget {
  final PrayerName prayerName;
  final DateTime? prayerTime;

  const PrayerGuideSheet({
    super.key,
    required this.prayerName,
    this.prayerTime,
  });

  static void show(
    BuildContext context,
    WidgetRef ref,
    PrayerName prayerName, [
    DateTime? prayerTime,
  ]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrayerGuideSheet(
        prayerName: prayerName,
        prayerTime: prayerTime,
      ),
    );
  }

  @override
  ConsumerState<PrayerGuideSheet> createState() => _PrayerGuideSheetState();
}

class _PrayerGuideSheetState extends ConsumerState<PrayerGuideSheet> {
  bool _isHowToExpanded = false;
  bool _isZammiSurahsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final prayerName = widget.prayerName;
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = _getSteps(prayerName, lang);
    final featuredSurahs = _getFeaturedSurahs(prayerName, lang);
    final generalSurahs = _getGeneralPrayerSurahs(lang);
    final howToSteps = PrayerHowToGuide.steps(prayerName, lang);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF02211C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üst Tutma Çubuğu (Drag Handle)
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 4.5,
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),

            // Başlık Barı (Namaz İsmi + Rozet + Kapat Butonu)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [BeyanColors.tone(0xFF004D40), BeyanColors.tone(0xFF00241E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _prayerIcon(prayerName),
                        color: BeyanColors.tone(0xFFFFDF7A),
                        size: 22,
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
                              prayerName.localizedName(strings.language.code),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              prayerName.arabic,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _headerSubtitle(prayerName, lang),
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),

            // İçerik Listesi (Kaydırılabilir)
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                children: [
                  // ── 0. Namaz Nasıl Kılınır? (Çentikli Açılır/Kapanır) ─────────────
                  _buildCollapsibleSectionHeader(
                    icon: Icons.self_improvement_rounded,
                    title: _howToTitle(lang),
                    subtitle: PrayerHowToGuide.exampleCaption(prayerName, lang),
                    badge: _howToBadge(lang, howToSteps.length),
                    isExpanded: _isHowToExpanded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isHowToExpanded = !_isHowToExpanded;
                      });
                    },
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...howToSteps.asMap().entries.map(
                                (e) => _buildHowToStepCard(e.key + 1, e.value, lang),
                              ),
                        ],
                      ),
                    ),
                    crossFadeState: _isHowToExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 260),
                  ),

                  const SizedBox(height: 18),

                  // ── 1. Rekat Dağılımı ve Kılınış Düzeni ─────────────
                  _buildSectionHeader(
                    icon: Icons.format_list_numbered_rounded,
                    title: strings.rakatsAndOrderTitle,
                  ),
                  const SizedBox(height: 8),
                  ...steps.map((step) => _buildStepCard(step, isDark)),

                  const SizedBox(height: 18),

                  // ── 2. Bu Vakte Özel Faziletli Sûre ve Âyetler ──────
                  if (featuredSurahs.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.stars_rounded,
                      title: strings.recommendedSurahsTitle,
                      badge: strings.tapToReadBadge,
                    ),
                    const SizedBox(height: 8),
                    ...featuredSurahs.map((item) => _buildSurahCard(context, ref, item, isFeatured: true)),
                    const SizedBox(height: 18),
                  ],

                  // ── 3. Namaz Sûreleri (Zamm-ı Sûreler - Çentikli Açılır/Kapanır) ───────────────
                  _buildCollapsibleSectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: strings.surahsRecitedInPrayerTitle,
                    subtitle: strings.prayerSurahTapHint,
                    badge: strings.tenShortSurahsBadge,
                    isExpanded: _isZammiSurahsExpanded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isZammiSurahsExpanded = !_isZammiSurahsExpanded;
                      });
                    },
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...generalSurahs.map((item) => _buildSurahCard(context, ref, item)),
                        ],
                      ),
                    ),
                    crossFadeState: _isZammiSurahsExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 260),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? badge,
  }) {
    return Row(
      children: [
        Icon(icon, size: 17, color: BeyanColors.tone(0xFFFFDF7A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: BeyanColors.tone(0xFFFFDF7A),
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: BeyanColors.tone(0xFFFFDF7A),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsibleSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isExpanded ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded
                ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5)
                : Colors.white12,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
              ),
              child: Icon(icon, size: 18, color: BeyanColors.tone(0xFFFFDF7A)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Çentik (Açılır / Kapanır Ok Animasyonu)
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: BeyanColors.tone(0xFFFFDF7A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _howToTitle(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.turkish:
        return 'Namaz Nasıl Kılınır?';
      case AppLanguage.indonesian:
        return 'Tata Cara Shalat';
      case AppLanguage.arabic:
        return 'كيفية أداء الصلاة';
      default:
        return 'How to Pray';
    }
  }

  String _howToBadge(AppLanguage lang, int count) {
    switch (lang) {
      case AppLanguage.turkish:
        return '$count Adım';
      case AppLanguage.indonesian:
        return '$count Langkah';
      case AppLanguage.arabic:
        return '$count خطوة';
      default:
        return '$count Steps';
    }
  }

  Widget _buildHowToStepCard(int index, PrayerHowToStep step, AppLanguage lang) {
    final hasDetails = step.hasRecitation || step.note != null;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
            border: Border.all(
              color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                color: BeyanColors.tone(0xFFFFDF7A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11.8,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final decoration = BoxDecoration(
      color: BeyanColors.tone(0xFF042F28),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
    );

    if (!hasDetails) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
        decoration: decoration,
        child: header,
      );
    }

    final readLabel = switch (lang) {
      AppLanguage.turkish => 'Okunuşu ve anlamı için dokun',
      AppLanguage.indonesian => 'Ketuk untuk bacaan & arti',
      AppLanguage.arabic => 'اضغط لعرض النص',
      _ => 'Tap for recitation & meaning',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // ExpansionTile'ın varsayılan ayırıcı çizgilerini gizle
        data: ThemeData(dividerColor: Colors.transparent, splashColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: BeyanColors.tone(0xFFFFDF7A),
          collapsedIconColor: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.7),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                padding: const EdgeInsets.only(left: 36, top: 6),
                child: Text(
                  readLabel,
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.75),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            if (step.arabic != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFF021A16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  step.arabic!,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: BeyanColors.tone(0xFFFFDF7A),
                    fontSize: 19,
                    height: 1.9,
                  ),
                ),
              ),
            if (step.transliteration != null) ...[
              const SizedBox(height: 10),
              _buildHowToLabeledText(
                switch (lang) {
                  AppLanguage.turkish => 'Okunuşu',
                  AppLanguage.indonesian => 'Bacaan',
                  _ => 'Transliteration',
                },
                step.transliteration!,
                italic: true,
              ),
            ],
            if (step.meaning != null) ...[
              const SizedBox(height: 10),
              _buildHowToLabeledText(
                switch (lang) {
                  AppLanguage.turkish => 'Anlamı',
                  AppLanguage.indonesian => 'Arti',
                  _ => 'Meaning',
                },
                step.meaning!,
              ),
            ],
            if (step.note != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: BeyanColors.tone(0xFFFFDF7A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.note!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHowToLabeledText(String label, String text, {bool italic = false}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: BeyanColors.tone(0xFFFFDF7A),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.45,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(PrayerRakatStep step, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF042F28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.check_rounded,
              color: BeyanColors.tone(0xFFFFDF7A),
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        step.type,
                        style: TextStyle(
                          color: BeyanColors.tone(0xFFFFDF7A),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (step.detail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.detail,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(
    BuildContext context,
    WidgetRef ref,
    PrayerRecommendedSurah item, {
    bool isFeatured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isFeatured ? BeyanColors.tone(0xFF053E34) : BeyanColors.tone(0xFF042F28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFeatured
              ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.08),
          width: isFeatured ? 1.2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openSurahInQuran(context, ref, item.surahId, item.verseNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // Sûre No Rozeti
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFeatured
                        ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.07),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isFeatured ? 0.8 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${item.surahId}',
                      style: TextStyle(
                        color: BeyanColors.tone(0xFFFFDF7A),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // İsim ve Not
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.arabicName,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 14,
                              color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.note,
                        style: TextStyle(
                          color: isFeatured
                              ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.88)
                              : Colors.white.withValues(alpha: 0.68),
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Kur'an'da Aç Aksiyon İkonu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: BeyanColors.tone(0xFFFFDF7A),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: BeyanColors.tone(0xFFFFDF7A),
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSurahInQuran(
    BuildContext context,
    WidgetRef ref,
    int surahId, [
    int? verseNumber,
  ]) async {
    HapticFeedback.mediumImpact();
    final surah = await QuranRepository().getSurahById(surahId);
    if (surah != null && context.mounted) {
      // Bottom sheet'i kapat
      Navigator.of(context).pop();

      // Kur'an Sekmesine Geçiş Yap (Tab 2)
      ref.read(selectedTabProvider.notifier).state = 2;

      // Kök ekrana dön ve Kur'an Detay Sayfasını Aç
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).push(
        LuxuryPageRoute(
          page: SurahDetailScreen(
            surah: surah,
            initialScrollToVerse: verseNumber,
          ),
        ),
      );
    }
  }

  IconData _prayerIcon(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return Icons.nights_stay_rounded;
      case PrayerName.sunrise:
        return Icons.wb_sunny_rounded;
      case PrayerName.dhuhr:
        return Icons.wb_sunny_outlined;
      case PrayerName.asr:
        return Icons.wb_cloudy_rounded;
      case PrayerName.maghrib:
        return Icons.wb_twilight_rounded;
      case PrayerName.isha:
        return Icons.bedtime_rounded;
    }
  }

  String _headerSubtitle(PrayerName p, AppLanguage lang) {
    if (p == PrayerName.sunrise) {
      if (lang == AppLanguage.turkish) {
        return 'Kerâhet Vakti • Kuşluk / İşrak Namazı';
      }
      if (lang == AppLanguage.arabic) {
        return 'وقت الكراهة • صلاة الضحى والإشراق';
      }
      if (lang == AppLanguage.indonesian) {
        return 'Waktu Terlarang Shalat • Shalat Dhuha / Isyraq';
      }
      return 'Sunrise (Restricted Time) • Duha/Ishraq Prayer';
    }
    return p.localizedRakat(lang.code);
  }

  List<PrayerRakatStep> _getSteps(PrayerName p, AppLanguage lang) {
    if (lang == AppLanguage.turkish) {
      return _getStepsTr(p);
    } else if (lang == AppLanguage.indonesian) {
      return _getStepsId(p);
    } else if (lang == AppLanguage.arabic) {
      return _getStepsAr(p);
    } else {
      return _getStepsEn(p);
    }
  }

  List<PrayerRakatStep> _getStepsTr(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRakatStep(
            title: '2 Rekat Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Peygamber Efendimiz (s.a.v.)\'in en çok önem verdiği sünnettir. 1. rekatta Kâfirûn, 2. rekatta İhlâs sûreleri tavsiye edilir.',
          ),
          PrayerRakatStep(
            title: '2 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: 'Kıraati cehrî (açıktan) okunan farz namazdır. Cemaatle veya münferit kılınır.',
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRakatStep(
            title: 'Kerâhet Vakti (Namaz Kılınmaz)',
            type: 'Mekruh Vakit',
            detail: 'Güneş doğarken ve doğduktan sonraki ilk 40-45 dakika içinde farz veya nafile namaz kılmak mekruhtur.',
          ),
          PrayerRakatStep(
            title: 'İşrak & Kuşluk (Duhâ) Namazı',
            type: 'Nafile (2 - 8 Rekat)',
            detail: 'Güneş bir mızrak boyu yükseldikten (doğuşundan ~45 dk sonra) zeval vaktine kadar kılınan çok faziletli nafile namazdır.',
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRakatStep(
            title: '4 Rekat İlk Sünnet',
            type: 'Müekkede Sünnet',
            detail: '1. oturuşta sadece Ettehiyyâtü okunup 3. rekata kalkılır. 3. ve 4. rekatlarda Fâtiha ve zamm-ı sûre okunur.',
          ),
          PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: 'Farzın 3. ve 4. rekatlarında sadece Fâtiha sûresi okunur, zamm-ı sûre eklenmez.',
          ),
          PrayerRakatStep(
            title: '2 Rekat Son Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Sabah namazının sünneti gibi kılınan iki rekatlık müekked sünnettir.',
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRakatStep(
            title: '4 Rekat Sünnet',
            type: 'Gayr-i Müekkede',
            detail: '1. oturuşta Ettehiyyâtü ile birlikte Salli ve Bârik duaları da okunur. 3. rekata kalkınca Sübhaneke ve Eûzü-Besmele ile başlanır.',
          ),
          PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: '3. ve 4. rekatlarında sadece Fâtiha okunur. Vaktin fazileti ikindi vaktinin korunmasındadır (Salât-ı Vüstâ).',
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRakatStep(
            title: '3 Rekat Farz',
            type: 'Farz-ı Ayn (Önce Kılınır)',
            detail: 'Akşam namazında önce farz kılınır. 1. ve 2. rekatta Fâtiha ve zamm-ı sûre; 3. rekatta sadece Fâtiha okunur.',
          ),
          PrayerRakatStep(
            title: '2 Rekat Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Farzdan hemen sonra kılınır. Kâfirûn ve İhlâs sûreleri tavsiye edilir.',
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRakatStep(
            title: '4 Rekat İlk Sünnet',
            type: 'Gayr-i Müekkede Sünnet',
            detail: 'İkindi sünneti gibidir; 1. oturuşta Salli-Bârik okunur, 3. rekata kalkınca Sübhaneke ile başlanır.',
          ),
          PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: '3. ve 4. rekatlarında sadece Fâtiha okunur.',
          ),
          PrayerRakatStep(
            title: '2 Rekat Son Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Farzın ardından kılınan iki rekatlık sünnettir.',
          ),
          PrayerRakatStep(
            title: '3 Rekat Vitir Namazı',
            type: 'Vacip Namaz (Kunût ile)',
            detail: '3. rekatta Fâtiha ve zamm-ı sûre okunduktan sonra eller kulaklara kaldırılıp tekbir alınır ve Kunût duaları okunur.',
          ),
        ];
    }
  }

  List<PrayerRakatStep> _getStepsId(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRakatStep(
            title: '2 Rakaat Sunnah Subuh',
            type: 'Sunnah Muakkadah',
            detail: 'Sunnah yang sangat ditekankan oleh Rasulullah ﷺ. Dianjurkan membaca surat Al-Kafirun pada rakaat pertama dan Al-Ikhlas pada rakaat kedua.',
          ),
          PrayerRakatStep(
            title: '2 Rakaat Fardhu Subuh',
            type: 'Fardhu Ain',
            detail: 'Shalat fardhu dengan bacaan keras (jahri). Dikerjakan berjamaah atau sendiri.',
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRakatStep(
            title: 'Waktu Terlarang (Dilarang Shalat)',
            type: 'Waktu Makruh',
            detail: 'Makruh melakukan shalat fardhu atau sunnah saat matahari terbit hingga 40-45 menit pertama.',
          ),
          PrayerRakatStep(
            title: 'Shalat Isyraq & Dhuha',
            type: 'Sunnah (2 - 8 Rakaat)',
            detail: 'Shalat sunnah yang sangat utama dikerjakan setelah matahari naik setinggi tombak hingga sebelum waktu zawal.',
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRakatStep(
            title: '4 Rakaat Sunnah Qabliyah',
            type: 'Sunnah Muakkadah',
            detail: 'Pada tasyahud awal hanya membaca At-Tahiyyat lalu berdiri ke rakaat ketiga. Membaca Al-Fatihah dan surat pada setiap rakaat.',
          ),
          PrayerRakatStep(
            title: '4 Rakaat Fardhu Dzuhur',
            type: 'Fardhu Ain',
            detail: 'Pada rakaat ke-3 dan ke-4 hanya membaca surat Al-Fatihah.',
          ),
          PrayerRakatStep(
            title: '2 Rakaat Sunnah Ba\'diyah',
            type: 'Sunnah Muakkadah',
            detail: 'Dua rakaat sunnah muakkadah yang dikerjakan setelah shalat fardhu Dzuhur.',
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRakatStep(
            title: '4 Rakaat Sunnah Qabliyah',
            type: 'Sunnah Ghairu Muakkadah',
            detail: 'Dianjurkan dikerjakan sebelum shalat fardhu Ashar.',
          ),
          PrayerRakatStep(
            title: '4 Rakaat Fardhu Ashar',
            type: 'Fardhu Ain',
            detail: 'Hanya membaca Al-Fatihah pada rakaat ke-3 dan ke-4. Merupakan Shalat Wustha.',
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRakatStep(
            title: '3 Rakaat Fardhu Maghrib',
            type: 'Fardhu Ain (Didahulukan)',
            detail: 'Dikerjakan terlebih dahulu. Rakaat 1 & 2 membaca Al-Fatihah dan surat; rakaat 3 hanya Al-Fatihah.',
          ),
          PrayerRakatStep(
            title: '2 Rakaat Sunnah Ba\'diyah',
            type: 'Sunnah Muakkadah',
            detail: 'Dikerjakan setelah shalat fardhu. Dianjurkan membaca surat Al-Kafirun dan Al-Ikhlas.',
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRakatStep(
            title: '4 Rakaat Sunnah Qabliyah',
            type: 'Sunnah Ghairu Muakkadah',
            detail: 'Sunnah sebelum fardhu Isya.',
          ),
          PrayerRakatStep(
            title: '4 Rakaat Fardhu Isya',
            type: 'Fardhu Ain',
            detail: 'Hanya membaca Al-Fatihah pada rakaat ke-3 dan ke-4.',
          ),
          PrayerRakatStep(
            title: '2 Rakaat Sunnah Ba\'diyah',
            type: 'Sunnah Muakkadah',
            detail: 'Dua rakaat sunnah muakkadah setelah shalat fardhu Isya.',
          ),
          PrayerRakatStep(
            title: '3 Rakaat Shalat Witir',
            type: 'Sunnah Muakkadah / Wajib',
            detail: 'Shalat penutup malam dengan membaca doa Qunut pada rakaat terakhir.',
          ),
        ];
    }
  }

  List<PrayerRakatStep> _getStepsEn(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRakatStep(
            title: '2 Sunnah Rakats',
            type: 'Emphasized Sunnah (Mu\'akkadah)',
            detail: 'The most emphasized sunnah by the Prophet (pbuh). Reciting Al-Kafirun in 1st rakat and Al-Ikhlas in 2nd rakat is recommended.',
          ),
          PrayerRakatStep(
            title: '2 Fard Rakats',
            type: 'Obligatory (Fard Ayn)',
            detail: 'Recited aloud (Jahri). Prayed in congregation or individually.',
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRakatStep(
            title: 'Restricted Time (No Prayer)',
            type: 'Disliked (Makruh) Time',
            detail: 'It is disliked to pray fard or nafl prayers during sunrise and for ~40-45 minutes after.',
          ),
          PrayerRakatStep(
            title: 'Ishraq & Duha Prayer',
            type: 'Voluntary (2 - 8 Rakats)',
            detail: 'Highly virtuous prayer performed from ~45 min after sunrise until before zenith (zawal).',
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRakatStep(
            title: '4 Initial Sunnah Rakats',
            type: 'Emphasized Sunnah',
            detail: 'In the first sitting only Tashahhud is recited before standing for the 3rd rakat.',
          ),
          PrayerRakatStep(
            title: '4 Fard Rakats',
            type: 'Obligatory (Fard Ayn)',
            detail: 'Only Surah Al-Fatiha is recited in the 3rd and 4th rakats.',
          ),
          PrayerRakatStep(
            title: '2 Final Sunnah Rakats',
            type: 'Emphasized Sunnah',
            detail: 'Two emphasized sunnah rakats prayed after the obligatory prayer.',
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRakatStep(
            title: '4 Sunnah Rakats',
            type: 'Non-Emphasized Sunnah',
            detail: 'Recommended voluntary prayer before the obligatory Asr prayer.',
          ),
          PrayerRakatStep(
            title: '4 Fard Rakats',
            type: 'Obligatory (Fard Ayn)',
            detail: 'Only Surah Al-Fatiha is recited in the 3rd and 4th rakats (Salat al-Wusta).',
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRakatStep(
            title: '3 Fard Rakats',
            type: 'Obligatory (Prayed First)',
            detail: 'Obligatory prayer is prayed first. Surah recitation in rakats 1 & 2; only Fatiha in rakat 3.',
          ),
          PrayerRakatStep(
            title: '2 Sunnah Rakats',
            type: 'Emphasized Sunnah',
            detail: 'Prayed immediately after Fard. Surahs Al-Kafirun and Al-Ikhlas are recommended.',
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRakatStep(
            title: '4 Initial Sunnah Rakats',
            type: 'Non-Emphasized Sunnah',
            detail: 'Voluntary prayer before the obligatory Isha prayer.',
          ),
          PrayerRakatStep(
            title: '4 Fard Rakats',
            type: 'Obligatory (Fard Ayn)',
            detail: 'Only Surah Al-Fatiha is recited in the 3rd and 4th rakats.',
          ),
          PrayerRakatStep(
            title: '2 Final Sunnah Rakats',
            type: 'Emphasized Sunnah',
            detail: 'Two emphasized sunnah rakats prayed after Fard.',
          ),
          PrayerRakatStep(
            title: '3 Witr Rakats',
            type: 'Wajib / Emphasized Night Prayer',
            detail: 'Night prayer concluded with Qunut supplication in the third rakat.',
          ),
        ];
    }
  }

  List<PrayerRakatStep> _getStepsAr(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRakatStep(
            title: 'ركعتان سنة الفجر',
            type: 'سنة مؤكدة',
            detail: 'أكد السنن النبوية، يستحب قراءة سورة الكافرون في الأولى والإخلاص في الثانية.',
          ),
          PrayerRakatStep(
            title: 'ركعتان فرض الفجر',
            type: 'فرض عين',
            detail: 'صلاة جهرية تقام جماعة أو منفرداً.',
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRakatStep(
            title: 'وقت الكراهة (تنهى الصلاة فيه)',
            type: 'وقت مكروه',
            detail: 'يكره أداء الصلاة عند شروق الشمس ولمدة ٤٠-٤٥ دقيقة بعده.',
          ),
          PrayerRakatStep(
            title: 'صلاة الإشراق والضحى',
            type: 'نافلة (٢ - ٨ ركعات)',
            detail: 'صلاة مباركة تؤدى بعد ارتفاع الشمس قيد رمح حتى قبل الزوال.',
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRakatStep(
            title: '٤ ركعات سنة قبلية',
            type: 'سنة مؤكدة',
            detail: 'في التشهد الأول يقرأ التحيات فقط ثم يقوم للركعة الثالثة.',
          ),
          PrayerRakatStep(
            title: '٤ ركعات فرض الظهر',
            type: 'فرض عين',
            detail: 'تقرأ الفاتحة فقط في الركعتين الثالثة والرابعة.',
          ),
          PrayerRakatStep(
            title: 'ركعتان سنة بعدية',
            type: 'سنة مؤكدة',
            detail: 'ركعتان مباركتان تؤديان بعد فرض الظهر.',
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRakatStep(
            title: '٤ ركعات سنة قبلية',
            type: 'سنة غير مؤكدة',
            detail: 'سنة مستحبة قبل صلاة العصر.',
          ),
          PrayerRakatStep(
            title: '٤ ركعات فرض العصر',
            type: 'فرض عين',
            detail: 'تقرأ الفاتحة فقط في الركعتين الثالثة والرابعة (الصلاة الوسطى).',
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRakatStep(
            title: '٣ ركعات فرض المغرب',
            type: 'فرض عين (يقدم أولاً)',
            detail: 'يقدم الفرض أولاً، الفاتحة وسورة في الأولى والثانية، وفاتحة فقط في الثالثة.',
          ),
          PrayerRakatStep(
            title: 'ركعتان سنة بعدية',
            type: 'سنة مؤكدة',
            detail: 'تؤدى بعد الفرض مباشرة، يستحب الكافرون والإخلاص.',
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRakatStep(
            title: '٤ ركعات سنة قبلية',
            type: 'سنة غير مؤكدة',
            detail: 'تؤدى قبل فرض العشاء.',
          ),
          PrayerRakatStep(
            title: '٤ ركعات فرض العشاء',
            type: 'فرض عين',
            detail: 'تقرأ الفاتحة فقط في الركعتين الثالثة والرابعة.',
          ),
          PrayerRakatStep(
            title: 'ركعتان سنة بعدية',
            type: 'سنة مؤكدة',
            detail: 'ركعتان بعد الفرض.',
          ),
          PrayerRakatStep(
            title: '٣ ركعات صلاة الوتر',
            type: 'سنة مؤكدة / واجب مع القنوت',
            detail: 'ختام صلاة الليل مع دعاء القنوت في الركعة الثالثة.',
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahs(PrayerName p, AppLanguage lang) {
    if (lang == AppLanguage.turkish) {
      return _getFeaturedSurahsTr(p);
    } else if (lang == AppLanguage.indonesian) {
      return _getFeaturedSurahsId(p);
    } else if (lang == AppLanguage.arabic) {
      return _getFeaturedSurahsAr(p);
    } else {
      return _getFeaturedSurahsEn(p);
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahsTr(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRecommendedSurah(
            surahId: 59,
            verseNumber: 22,
            name: 'Haşr (Hüvallahüllezi)',
            arabicName: 'الحشر',
            note: 'Sabah namazı sonrası okuyana yetmiş bin melek dua eder (Hadis-i Şerif).',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 36,
            verseNumber: 1,
            name: 'Yâsîn Sûresi',
            arabicName: 'يس',
            note: 'Kur\'an-ı Kerim\'in kalbi; sabah vaktinde okunması tavsiye edilir.',
            isFeatured: true,
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRecommendedSurah(
            surahId: 93,
            verseNumber: 1,
            name: 'Duhâ Sûresi',
            arabicName: 'الضحى',
            note: 'Kuşluk vaktinde okunması çok faziletlidir; huzur ve kolaylık müjdesidir.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 91,
            verseNumber: 1,
            name: 'Şems Sûresi',
            arabicName: 'الشمس',
            note: 'Güneşin aydınlığı ve nefsi arındırma şuuru.',
            isFeatured: true,
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRecommendedSurah(
            surahId: 48,
            verseNumber: 27,
            name: 'Fetih Sûresi (Lekad Sadaka)',
            arabicName: 'الفتح',
            note: 'Öğle namazı sonrasında okunması müstehap görülen aşr-ı şerif.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 108,
            verseNumber: 1,
            name: 'Kevser Sûresi',
            arabicName: 'الكوثر',
            note: 'Öğle sünnetlerinde sıkça okunan tükenmez bereket sûresi.',
            isFeatured: true,
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRecommendedSurah(
            surahId: 78,
            verseNumber: 1,
            name: 'Nebe\' (Amme) Sûresi',
            arabicName: 'النبأ',
            note: 'İkindi namazından sonra her gün okunması sünnet ve faziletlidir.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 103,
            verseNumber: 1,
            name: 'Asr Sûresi',
            arabicName: 'العصر',
            note: 'İkindi vaktinin ve ömrün kıymetini bildiren eşsiz sûre.',
            isFeatured: true,
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRecommendedSurah(
            surahId: 56,
            verseNumber: 1,
            name: 'Vâkıa Sûresi',
            arabicName: 'الواقعة',
            note: 'Akşam namazından sonra okuyana fakirlik isabet etmez (Hadis-i Şerif).',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 94,
            verseNumber: 1,
            name: 'İnşirâh Sûresi',
            arabicName: 'الشرح',
            note: 'Gönül darlığını gideren, her zorlukla bir kolaylık müjdeleyen sûre.',
            isFeatured: true,
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRecommendedSurah(
            surahId: 2,
            verseNumber: 285,
            name: 'Âmene\'r-Resûlü (Bakara 285-286)',
            arabicName: 'البقرة',
            note: 'Yatsıdan sonra gece okuyana her türlü kötülükten korunmaya yeter (Hadis-i Şerif).',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 67,
            verseNumber: 1,
            name: 'Mülk (Tebâreke) Sûresi',
            arabicName: 'الملك',
            note: 'Kabir azabından korur; her gece yatsı sonrası okunması sünnettir.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 32,
            verseNumber: 1,
            name: 'Secde Sûresi',
            arabicName: 'السجدة',
            note: 'Peygamber Efendimiz\'in yatsıdan sonra okumadan uyumadığı sûre.',
            isFeatured: true,
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahsId(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRecommendedSurah(
            surahId: 59,
            verseNumber: 22,
            name: 'Surat Al-Hasyr (Ayat 22-24)',
            arabicName: 'الحشر',
            note: 'Dianjurkan dibaca setelah shalat Subuh; 70.000 malaikat mendoakan pembacanya.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 36,
            verseNumber: 1,
            name: 'Surat Yasin',
            arabicName: 'يس',
            note: 'Jantung Al-Qur\'an; sangat dianjurkan dibaca di waktu pagi.',
            isFeatured: true,
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRecommendedSurah(
            surahId: 93,
            verseNumber: 1,
            name: 'Surat Ad-Duha',
            arabicName: 'الضحى',
            note: 'Sangat utama dibaca di waktu Dhuha; membawa ketenteraman dan kelapangan.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 91,
            verseNumber: 1,
            name: 'Surat Asy-Syams',
            arabicName: 'الشمس',
            note: 'Mengingatkan cahaya matahari dan kesucian jiwa.',
            isFeatured: true,
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRecommendedSurah(
            surahId: 48,
            verseNumber: 27,
            name: 'Surat Al-Fath',
            arabicName: 'الفتح',
            note: 'Dianjurkan dibaca setelah shalat Dzuhur.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 108,
            verseNumber: 1,
            name: 'Surat Al-Kausar',
            arabicName: 'الكوثر',
            note: 'Surat keberkahan yang sering dibaca dalam shalat sunnah.',
            isFeatured: true,
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRecommendedSurah(
            surahId: 78,
            verseNumber: 1,
            name: 'Surat An-Naba',
            arabicName: 'النبأ',
            note: 'Dianjurkan dibaca setiap hari setelah shalat Ashar.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 103,
            verseNumber: 1,
            name: 'Surat Al-Asr',
            arabicName: 'العصر',
            note: 'Mengingatkan pentingnya waktu Ashar dan nilai umur manusia.',
            isFeatured: true,
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRecommendedSurah(
            surahId: 56,
            verseNumber: 1,
            name: 'Surat Al-Waqi\'ah',
            arabicName: 'الواقعة',
            note: 'Barang siapa membacanya setelah Maghrib, dijauhkan dari kefakiran.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 94,
            verseNumber: 1,
            name: 'Surat Al-Insyirah',
            arabicName: 'الشرح',
            note: 'Melapangkan dada dan menjanjikan kemudahan bersama kesulitan.',
            isFeatured: true,
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRecommendedSurah(
            surahId: 2,
            verseNumber: 285,
            name: 'Al-Baqarah (Ayat 285-286)',
            arabicName: 'البقرة',
            note: 'Membacanya di malam hari setelah Isya mencukupi dari segala keburukan.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 67,
            verseNumber: 1,
            name: 'Surat Al-Mulk',
            arabicName: 'الملك',
            note: 'Melindungi dari siksa kubur; sunnah dibaca setiap malam setelah Isya.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 32,
            verseNumber: 1,
            name: 'Surat As-Sajdah',
            arabicName: 'السجدة',
            note: 'Surat yang senantiasa dibaca Rasulullah ﷺ sebelum tidur.',
            isFeatured: true,
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahsEn(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRecommendedSurah(
            surahId: 59,
            verseNumber: 22,
            name: 'Al-Hashr (Verses 22-24)',
            arabicName: 'الحشر',
            note: 'Recited after Fajr; 70,000 angels pray for the reciter (Hadith).',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 36,
            verseNumber: 1,
            name: 'Surah Ya-Sin',
            arabicName: 'يس',
            note: 'Heart of the Quran; recommended to recite in the morning.',
            isFeatured: true,
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRecommendedSurah(
            surahId: 93,
            verseNumber: 1,
            name: 'Surah Ad-Duha',
            arabicName: 'الضحى',
            note: 'Virtuous at Duha time; glad tidings of peace and relief.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 91,
            verseNumber: 1,
            name: 'Surah Ash-Shams',
            arabicName: 'الشمس',
            note: 'Reflects the light of the sun and purification of the soul.',
            isFeatured: true,
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRecommendedSurah(
            surahId: 48,
            verseNumber: 27,
            name: 'Surah Al-Fath',
            arabicName: 'الفتح',
            note: 'Recommended recitation after Dhuhr prayer.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 108,
            verseNumber: 1,
            name: 'Surah Al-Kawthar',
            arabicName: 'الكوثر',
            note: 'Abundant blessing frequently recited in sunnah prayers.',
            isFeatured: true,
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRecommendedSurah(
            surahId: 78,
            verseNumber: 1,
            name: 'Surah An-Naba',
            arabicName: 'النبأ',
            note: 'Virtuous sunnah to recite daily after Asr prayer.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 103,
            verseNumber: 1,
            name: 'Surah Al-Asr',
            arabicName: 'العصر',
            note: 'Emphasizes the sanctity of time and value of life.',
            isFeatured: true,
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRecommendedSurah(
            surahId: 56,
            verseNumber: 1,
            name: 'Surah Al-Waqi\'ah',
            arabicName: 'الواقعة',
            note: 'Reciting after Maghrib protects against poverty (Hadith).',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 94,
            verseNumber: 1,
            name: 'Surah Al-Inshirah',
            arabicName: 'الشرح',
            note: 'Brings solace to the heart and ease with hardship.',
            isFeatured: true,
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRecommendedSurah(
            surahId: 2,
            verseNumber: 285,
            name: 'Al-Baqarah (285-286)',
            arabicName: 'البقرة',
            note: 'Sufficient protection when recited at night after Isha.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 67,
            verseNumber: 1,
            name: 'Surah Al-Mulk',
            arabicName: 'الملك',
            note: 'Protects from the punishment of the grave; recited each night.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 32,
            verseNumber: 1,
            name: 'Surah As-Sajdah',
            arabicName: 'السجدة',
            note: 'The Prophet (pbuh) would not sleep without reciting it.',
            isFeatured: true,
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahsAr(PrayerName p) {
    switch (p) {
      case PrayerName.fajr:
        return const [
          PrayerRecommendedSurah(
            surahId: 59,
            verseNumber: 22,
            name: 'سورة الحشر (أواخر السورة)',
            arabicName: 'الحشر',
            note: 'يستحب قراءتها بعد صلاة الفجر، تصلي عليه سبعون ألف ملك.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 36,
            verseNumber: 1,
            name: 'سورة يس',
            arabicName: 'يس',
            note: 'قلب القرآن، يستحب تلاوتها في الصباح الباكر.',
            isFeatured: true,
          ),
        ];
      case PrayerName.sunrise:
        return const [
          PrayerRecommendedSurah(
            surahId: 93,
            verseNumber: 1,
            name: 'سورة الضحى',
            arabicName: 'الضحى',
            note: 'مستحبة في وقت الضحى، بشارة باليسر والطمأنينة.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 91,
            verseNumber: 1,
            name: 'سورة الشمس',
            arabicName: 'الشمس',
            note: 'تذكير بضياء الشمس وتزكية النفس.',
            isFeatured: true,
          ),
        ];
      case PrayerName.dhuhr:
        return const [
          PrayerRecommendedSurah(
            surahId: 48,
            verseNumber: 27,
            name: 'سورة الفتح',
            arabicName: 'الفتح',
            note: 'يستحب قراءتها بعد صلاة الظهر.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 108,
            verseNumber: 1,
            name: 'سورة الكوثر',
            arabicName: 'الكوثر',
            note: 'سورة البركة وكثرة الخير، تقرأ في السنن.',
            isFeatured: true,
          ),
        ];
      case PrayerName.asr:
        return const [
          PrayerRecommendedSurah(
            surahId: 78,
            verseNumber: 1,
            name: 'سورة النبأ',
            arabicName: 'النبأ',
            note: 'سنة مباركة ومستحبة بعد صلاة العصر.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 103,
            verseNumber: 1,
            name: 'سورة العصر',
            arabicName: 'العصر',
            note: 'تذكير بقيمة الوقت وحفظ الأوقات.',
            isFeatured: true,
          ),
        ];
      case PrayerName.maghrib:
        return const [
          PrayerRecommendedSurah(
            surahId: 56,
            verseNumber: 1,
            name: 'سورة الواقعة',
            arabicName: 'الواقعة',
            note: 'من قرأها بعد المغرب لم تصبه فاقة أبداً.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 94,
            verseNumber: 1,
            name: 'سورة الشرح',
            arabicName: 'الشرح',
            note: 'شرح للصدور وتيسير لكل عسير.',
            isFeatured: true,
          ),
        ];
      case PrayerName.isha:
        return const [
          PrayerRecommendedSurah(
            surahId: 2,
            verseNumber: 285,
            name: 'آمن الرسول (البقرة ٢٨٥-٢٨٦)',
            arabicName: 'البقرة',
            note: 'من قرأهما في ليلة كفتاه من كل شر.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 67,
            verseNumber: 1,
            name: 'سورة الملك (التبارك)',
            arabicName: 'الملك',
            note: 'تنجي من عذاب القبر، سنة كل ليلة بعد العشاء.',
            isFeatured: true,
          ),
          PrayerRecommendedSurah(
            surahId: 32,
            verseNumber: 1,
            name: 'سورة السجدة',
            arabicName: 'السجدة',
            note: 'كان النبي ﷺ لا ينام حتى يقرأها.',
            isFeatured: true,
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahs(AppLanguage lang) {
    if (lang == AppLanguage.turkish) {
      return _getGeneralPrayerSurahsTr();
    } else if (lang == AppLanguage.indonesian) {
      return _getGeneralPrayerSurahsId();
    } else if (lang == AppLanguage.arabic) {
      return _getGeneralPrayerSurahsAr();
    } else {
      return _getGeneralPrayerSurahsEn();
    }
  }

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahsTr() {
    return const [
      PrayerRecommendedSurah(
        surahId: 1,
        verseNumber: 1,
        name: 'Fâtiha Sûresi',
        arabicName: 'الفاتحة',
        note: 'Namazın her rekatında okunması vacip olan Ümmü\'l-Kitap (Kitabın Anası).',
      ),
      PrayerRecommendedSurah(
        surahId: 105,
        verseNumber: 1,
        name: 'Fil Sûresi',
        arabicName: 'الفيل',
        note: '1. Rekat zamm-ı sûresi; Kâbe\'yi koruyan ilahi kudretin hatırlatılması.',
      ),
      PrayerRecommendedSurah(
        surahId: 106,
        verseNumber: 1,
        name: 'Kureyş Sûresi',
        arabicName: 'قريش',
        note: 'Emniyet, rızık ve şükür sûresi.',
      ),
      PrayerRecommendedSurah(
        surahId: 107,
        verseNumber: 1,
        name: 'Mâ\'ûn Sûresi',
        arabicName: 'الماعون',
        note: 'İbadette samimiyet ve yardımlaşma ahlakı.',
      ),
      PrayerRecommendedSurah(
        surahId: 108,
        verseNumber: 1,
        name: 'Kevser Sûresi',
        arabicName: 'الكوثر',
        note: 'En kısa sûre; tükenmez hayır ve namaza davet.',
      ),
      PrayerRecommendedSurah(
        surahId: 109,
        verseNumber: 1,
        name: 'Kâfirûn Sûresi',
        arabicName: 'الكافرون',
        note: 'Tevhid manifestosu; sünnet namazlarında sıklıkla okunur.',
      ),
      PrayerRecommendedSurah(
        surahId: 110,
        verseNumber: 1,
        name: 'Nasr Sûresi',
        arabicName: 'النصر',
        note: 'İlahi yardım, fetih ve istiğfar öğüdü.',
      ),
      PrayerRecommendedSurah(
        surahId: 111,
        verseNumber: 1,
        name: 'Tebbet (Mesed) Sûresi',
        arabicName: 'المسد',
        note: 'Hakkı inkar edenlerin hüsranı.',
      ),
      PrayerRecommendedSurah(
        surahId: 112,
        verseNumber: 1,
        name: 'İhlâs Sûresi',
        arabicName: 'الإخلاص',
        note: 'Kur\'an\'ın üçte birine denk olan saf tevhid sûresi.',
      ),
      PrayerRecommendedSurah(
        surahId: 113,
        verseNumber: 1,
        name: 'Felak Sûresi',
        arabicName: 'الفلق',
        note: 'Sabahın aydınlığına ve şerlerden Allah\'a sığınma (Muavvizeteyn).',
      ),
      PrayerRecommendedSurah(
        surahId: 114,
        verseNumber: 1,
        name: 'Nâs Sûresi',
        arabicName: 'الناس',
        note: 'İnsanların Rabbine vesveselerden sığınma sûresi.',
      ),
    ];
  }

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahsId() {
    return const [
      PrayerRecommendedSurah(
        surahId: 1,
        verseNumber: 1,
        name: 'Surat Al-Fatihah',
        arabicName: 'الفاتحة',
        note: 'Wajib dibaca pada setiap rakaat shalat (Ummul Kitab).',
      ),
      PrayerRecommendedSurah(
        surahId: 105,
        verseNumber: 1,
        name: 'Surat Al-Fil',
        arabicName: 'الفيل',
        note: 'Mengingatkan kekuasaan ilahi yang melindungi Ka\'bah.',
      ),
      PrayerRecommendedSurah(
        surahId: 106,
        verseNumber: 1,
        name: 'Surat Quraisy',
        arabicName: 'قريش',
        note: 'Surat ketenteraman, rezeki, dan rasa syukur.',
      ),
      PrayerRecommendedSurah(
        surahId: 107,
        verseNumber: 1,
        name: 'Surat Al-Ma\'un',
        arabicName: 'الماعون',
        note: 'Keikhlasan dalam beribadah dan kepedulian sosial.',
      ),
      PrayerRecommendedSurah(
        surahId: 108,
        verseNumber: 1,
        name: 'Surat Al-Kausar',
        arabicName: 'الكوثر',
        note: 'Surat terpendek; kebaikan melimpah dan ajakan shalat.',
      ),
      PrayerRecommendedSurah(
        surahId: 109,
        verseNumber: 1,
        name: 'Surat Al-Kafirun',
        arabicName: 'الكافرون',
        note: 'Manifestasi tauhid; sering dibaca dalam shalat sunnah.',
      ),
      PrayerRecommendedSurah(
        surahId: 110,
        verseNumber: 1,
        name: 'Surat An-Nasr',
        arabicName: 'النصر',
        note: 'Pertolongan Allah, kemenangan besar, dan istighfar.',
      ),
      PrayerRecommendedSurah(
        surahId: 111,
        verseNumber: 1,
        name: 'Surat Al-Lahab',
        arabicName: 'المسد',
        note: 'Kerugian bagi orang-orang yang menentang kebenaran.',
      ),
      PrayerRecommendedSurah(
        surahId: 112,
        verseNumber: 1,
        name: 'Surat Al-Ikhlas',
        arabicName: 'الإخلاص',
        note: 'Kemurnian tauhid; sebanding sepertiga Al-Qur\'an.',
      ),
      PrayerRecommendedSurah(
        surahId: 113,
        verseNumber: 1,
        name: 'Surat Al-Falaq',
        arabicName: 'الفلق',
        note: 'Memohon perlindungan dari kejahatan waktu subuh.',
      ),
      PrayerRecommendedSurah(
        surahId: 114,
        verseNumber: 1,
        name: 'Surat An-Nas',
        arabicName: 'الناس',
        note: 'Perlindungan kepada Pemelihara manusia dari bisikan jahat.',
      ),
    ];
  }

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahsEn() {
    return const [
      PrayerRecommendedSurah(
        surahId: 1,
        verseNumber: 1,
        name: 'Surah Al-Fatiha',
        arabicName: 'الفاتحة',
        note: 'Obligatory recitation in every rakat (The Mother of the Book).',
      ),
      PrayerRecommendedSurah(
        surahId: 105,
        verseNumber: 1,
        name: 'Surah Al-Fil',
        arabicName: 'الفيل',
        note: 'Reminder of divine protection over the Holy Kaaba.',
      ),
      PrayerRecommendedSurah(
        surahId: 106,
        verseNumber: 1,
        name: 'Surah Quraysh',
        arabicName: 'قريش',
        note: 'Surah of peace, sustenance, and gratitude.',
      ),
      PrayerRecommendedSurah(
        surahId: 107,
        verseNumber: 1,
        name: 'Surah Al-Ma\'un',
        arabicName: 'الماعون',
        note: 'Sincerity in worship and helping those in need.',
      ),
      PrayerRecommendedSurah(
        surahId: 108,
        verseNumber: 1,
        name: 'Surah Al-Kawthar',
        arabicName: 'الكوثر',
        note: 'The shortest surah; abundant good and call to prayer.',
      ),
      PrayerRecommendedSurah(
        surahId: 109,
        verseNumber: 1,
        name: 'Surah Al-Kafirun',
        arabicName: 'الكافرون',
        note: 'Declaration of monotheism; frequently read in sunnah.',
      ),
      PrayerRecommendedSurah(
        surahId: 110,
        verseNumber: 1,
        name: 'Surah An-Nasr',
        arabicName: 'النصر',
        note: 'Divine victory, help, and glorification.',
      ),
      PrayerRecommendedSurah(
        surahId: 111,
        verseNumber: 1,
        name: 'Surah Al-Masad',
        arabicName: 'المسد',
        note: 'The loss of those who oppose the truth.',
      ),
      PrayerRecommendedSurah(
        surahId: 112,
        verseNumber: 1,
        name: 'Surah Al-Ikhlas',
        arabicName: 'الإخلاص',
        note: 'Purity of faith; equals one third of the Quran.',
      ),
      PrayerRecommendedSurah(
        surahId: 113,
        verseNumber: 1,
        name: 'Surah Al-Falaq',
        arabicName: 'الفلق',
        note: 'Seeking refuge in the Lord of dawn from all evil.',
      ),
      PrayerRecommendedSurah(
        surahId: 114,
        verseNumber: 1,
        name: 'Surah An-Nas',
        arabicName: 'الناس',
        note: 'Seeking refuge in the Lord of mankind from whisperers.',
      ),
    ];
  }

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahsAr() {
    return const [
      PrayerRecommendedSurah(
        surahId: 1,
        verseNumber: 1,
        name: 'سورة الفاتحة',
        arabicName: 'الفاتحة',
        note: 'واجبة القراءة في كل ركعة (أم الكتاب).',
      ),
      PrayerRecommendedSurah(
        surahId: 105,
        verseNumber: 1,
        name: 'سورة الفيل',
        arabicName: 'الفيل',
        note: 'تذكير بقدرة الله في حماية الكعبة المشرفة.',
      ),
      PrayerRecommendedSurah(
        surahId: 106,
        verseNumber: 1,
        name: 'سورة قريش',
        arabicName: 'قريش',
        note: 'سورة الأمان والرزق والشكر.',
      ),
      PrayerRecommendedSurah(
        surahId: 107,
        verseNumber: 1,
        name: 'سورة الماعون',
        arabicName: 'الماعون',
        note: 'الإخلاص في العبادة والتكافل الاجتماعي.',
      ),
      PrayerRecommendedSurah(
        surahId: 108,
        verseNumber: 1,
        name: 'سورة الكوثر',
        arabicName: 'الكوثر',
        note: 'أقصر سور القرآن؛ الخير الكثير والدعوة للصلاة.',
      ),
      PrayerRecommendedSurah(
        surahId: 109,
        verseNumber: 1,
        name: 'سورة الكافرون',
        arabicName: 'الكافرون',
        note: 'إعلان التوحيد؛ تقرأ كثيراً في السنن.',
      ),
      PrayerRecommendedSurah(
        surahId: 110,
        verseNumber: 1,
        name: 'سورة النصر',
        arabicName: 'النصر',
        note: 'نصر الله والفتح والاستغفار.',
      ),
      PrayerRecommendedSurah(
        surahId: 111,
        verseNumber: 1,
        name: 'سورة المسد',
        arabicName: 'المسد',
        note: 'خسران من عاند الحق وكذب به.',
      ),
      PrayerRecommendedSurah(
        surahId: 112,
        verseNumber: 1,
        name: 'سورة الإخلاص',
        arabicName: 'الإخلاص',
        note: 'إخلاص التوحيد؛ تعدل ثلث القرآن الكريم.',
      ),
      PrayerRecommendedSurah(
        surahId: 113,
        verseNumber: 1,
        name: 'سورة الفلق',
        arabicName: 'الفلق',
        note: 'الاستعاذة برب الفلق من شرور المخلوقات.',
      ),
      PrayerRecommendedSurah(
        surahId: 114,
        verseNumber: 1,
        name: 'سورة الناس',
        arabicName: 'الناس',
        note: 'الاستعاذة برب الناس من الوسواس الخناس.',
      ),
    ];
  }
}
