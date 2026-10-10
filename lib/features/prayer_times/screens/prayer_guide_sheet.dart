import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../main.dart';
import '../../quran/repositories/quran_repository.dart';
import '../../quran/screens/surah_detail_screen.dart';
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
class PrayerGuideSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = _getSteps(prayerName, lang);
    final featuredSurahs = _getFeaturedSurahs(prayerName, lang);
    final generalSurahs = _getGeneralPrayerSurahs(lang);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF02211C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1.8),
        ),
        boxShadow: [
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
                color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004D40), Color(0xFF00241E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFFFFDF7A).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _prayerIcon(prayerName),
                        color: const Color(0xFFFFDF7A),
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
                                color: const Color(0xFFFFDF7A).withValues(alpha: 0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _headerSubtitle(prayerName, lang),
                          style: TextStyle(
                            color: const Color(0xFFFFDF7A).withValues(alpha: 0.9),
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
                  // ── 1. Rekat Dağılımı ve Kılınış Düzeni ─────────────
                  _buildSectionHeader(
                    icon: Icons.format_list_numbered_rounded,
                    title: lang == AppLanguage.english
                        ? 'Rakats & Order of Prayer'
                        : (lang == AppLanguage.arabic ? 'ترتيب الركعات وكيفية الصلاة' : 'Rekat Düzeni & Kılınış Sırası'),
                  ),
                  const SizedBox(height: 8),
                  ...steps.map((step) => _buildStepCard(step, isDark)),

                  const SizedBox(height: 20),

                  // ── 2. Bu Vakte Özel Faziletli Sûre ve Âyetler ──────
                  if (featuredSurahs.isNotEmpty) ...[
                    _buildSectionHeader(
                      icon: Icons.stars_rounded,
                      title: lang == AppLanguage.english
                          ? 'Special Recommended Surahs & Verses'
                          : (lang == AppLanguage.arabic ? 'سور وآيات مستحبة لهذا الوقت' : 'Bu Vakte Özel Faziletli Sûre ve Âyetler'),
                      badge: lang == AppLanguage.english ? 'Tap to Read' : (lang == AppLanguage.arabic ? 'اضغط للقراءة' : 'Dokununca Açılır'),
                    ),
                    const SizedBox(height: 8),
                    ...featuredSurahs.map((item) => _buildSurahCard(context, ref, item, isFeatured: true)),
                    const SizedBox(height: 20),
                  ],

                  // ── 3. Namaz Sûreleri (Zamm-ı Sûreler) ───────────────
                  _buildSectionHeader(
                    icon: Icons.menu_book_rounded,
                    title: lang == AppLanguage.english
                        ? 'Surahs Recited in Prayer (Zamm-i Surah)'
                        : (lang == AppLanguage.arabic ? 'قصار السور التي تقرأ في الصلاة' : 'Namazda Okunan Zamm-ı Sûreler'),
                    badge: lang == AppLanguage.english ? '10 Short Surahs' : (lang == AppLanguage.arabic ? '١٠ سور قصيرة' : '10 Namaz Sûresi'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lang == AppLanguage.english
                        ? 'Tap any surah to open its full recitation and meaning directly in the Holy Quran tab.'
                        : (lang == AppLanguage.arabic
                            ? 'اضغط على أي سورة لفتحها مباشرة في مصحف التطبيق مع التلاوة والتفسير.'
                            : 'Fâtiha\'dan sonra okunan bu sûrelerden birine dokunarak Kur\'an-ı Kerim sayfasında anında açabilirsiniz.'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...generalSurahs.map((item) => _buildSurahCard(context, ref, item)),
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
        Icon(icon, size: 17, color: const Color(0xFFFFDF7A)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFDF7A),
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
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFDF7A).withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFFFFDF7A),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStepCard(PrayerRakatStep step, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF042F28),
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
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFFFFDF7A),
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
                        style: const TextStyle(
                          color: Color(0xFFFFDF7A),
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
        color: isFeatured ? const Color(0xFF053E34) : const Color(0xFF042F28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFeatured
              ? const Color(0xFFFFDF7A).withValues(alpha: 0.45)
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
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.07),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: isFeatured ? 0.8 : 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${item.surahId}',
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
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
                              color: const Color(0xFFFFDF7A).withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.note,
                        style: TextStyle(
                          color: isFeatured
                              ? const Color(0xFFFFDF7A).withValues(alpha: 0.88)
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
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: Color(0xFFFFDF7A),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFFFDF7A),
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
        MaterialPageRoute(
          builder: (_) => SurahDetailScreen(
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
      return lang == AppLanguage.english
          ? 'Sunrise (Restricted Time) • Duha/Ishraq Prayer'
          : (lang == AppLanguage.arabic ? 'وقت الكراهة • صلاة الضحى والإشراق' : 'Kerâhet Vakti • Kuşluk / İşrak Namazı');
    }
    return p.localizedRakat(lang.code);
  }

  List<PrayerRakatStep> _getSteps(PrayerName p, AppLanguage lang) {
    switch (p) {
      case PrayerName.fajr:
        return [
          const PrayerRakatStep(
            title: '2 Rekat Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Peygamber Efendimiz (s.a.v.)\'in en çok önem verdiği sünnettir. 1. rekatta Kâfirûn, 2. rekatta İhlâs sûreleri tavsiye edilir.',
          ),
          const PrayerRakatStep(
            title: '2 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: 'Kıraati cehrî (açıktan) okunan farz namazdır. Cemaatle veya münferit kılınır.',
          ),
        ];

      case PrayerName.sunrise:
        return [
          const PrayerRakatStep(
            title: 'Kerâhet Vakti (Namaz Kılınmaz)',
            type: 'Mekruh Vakit',
            detail: 'Güneş doğarken ve doğduktan sonraki ilk 40-45 dakika içinde farz veya nafile namaz kılmak mekruhtur.',
          ),
          const PrayerRakatStep(
            title: 'İşrak & Kuşluk (Duhâ) Namazı',
            type: 'Nafile (2 - 8 Rekat)',
            detail: 'Güneş bir mızrak boyu yükseldikten (doğuşundan ~45 dk sonra) zeval vaktine kadar kılınan çok faziletli nafile namazdır.',
          ),
        ];

      case PrayerName.dhuhr:
        return [
          const PrayerRakatStep(
            title: '4 Rekat İlk Sünnet',
            type: 'Müekkede Sünnet',
            detail: '1. oturuşta sadece Ettehiyyâtü okunup 3. rekata kalkılır. 3. ve 4. rekatlarda Fâtiha ve zamm-ı sûre okunur.',
          ),
          const PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: 'Farzın 3. ve 4. rekatlarında sadece Fâtiha sûresi okunur, zamm-ı sûre eklenmez.',
          ),
          const PrayerRakatStep(
            title: '2 Rekat Son Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Sabah namazının sünneti gibi kılınan iki rekatlık müekked sünnettir.',
          ),
        ];

      case PrayerName.asr:
        return [
          const PrayerRakatStep(
            title: '4 Rekat Sünnet',
            type: 'Gayr-i Müekkede',
            detail: '1. oturuşta Ettehiyyâtü ile birlikte Salli ve Bârik duaları da okunur. 3. rekata kalkınca Sübhaneke ve Eûzü-Besmele ile başlanır.',
          ),
          const PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: '3. ve 4. rekatlarında sadece Fâtiha okunur. Vaktin fazileti ikindi vaktinin korunmasındadır (Salât-ı Vüstâ).',
          ),
        ];

      case PrayerName.maghrib:
        return [
          const PrayerRakatStep(
            title: '3 Rekat Farz',
            type: 'Farz-ı Ayn (Önce Kılınır)',
            detail: 'Akşam namazında önce farz kılınır. 1. ve 2. rekatta Fâtiha ve zamm-ı sûre; 3. rekatta sadece Fâtiha okunur.',
          ),
          const PrayerRakatStep(
            title: '2 Rekat Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Farzdan hemen sonra kılınır. Kâfirûn ve İhlâs sûreleri tavsiye edilir.',
          ),
        ];

      case PrayerName.isha:
        return [
          const PrayerRakatStep(
            title: '4 Rekat İlk Sünnet',
            type: 'Gayr-i Müekkede Sünnet',
            detail: 'İkindi sünneti gibidir; 1. oturuşta Salli-Bârik okunur, 3. rekata kalkınca Sübhaneke ile başlanır.',
          ),
          const PrayerRakatStep(
            title: '4 Rekat Farz',
            type: 'Farz-ı Ayn',
            detail: '3. ve 4. rekatlarında sadece Fâtiha okunur.',
          ),
          const PrayerRakatStep(
            title: '2 Rekat Son Sünnet',
            type: 'Müekkede Sünnet',
            detail: 'Farzın ardından kılınan iki rekatlık sünnettir.',
          ),
          const PrayerRakatStep(
            title: '3 Rekat Vitir Namazı',
            type: 'Vacip Namaz (Kunût ile)',
            detail: '3. rekatta Fâtiha ve zamm-ı sûre okunduktan sonra eller kulaklara kaldırılıp tekbir alınır ve Kunût duaları okunur.',
          ),
        ];
    }
  }

  List<PrayerRecommendedSurah> _getFeaturedSurahs(PrayerName p, AppLanguage lang) {
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

  List<PrayerRecommendedSurah> _getGeneralPrayerSurahs(AppLanguage lang) {
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
}
