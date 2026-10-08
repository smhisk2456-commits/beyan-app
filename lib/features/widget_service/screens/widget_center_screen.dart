import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../widget_service.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/onboarding_trial_paywall_screen.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../notifications/models/short_verse_notification.dart';

/// Kilit Ekranı Widget Kategorileri
enum WidgetCategoryType {
  quotes, // İslami Sözler, Dua ve Ayet
  dailyVerse, // Günün Ayeti
  prayerTimes, // Namaz Vakitleri
  countdown, // Namaz Geri Sayımı
  hijri, // Hicri Takvim
  sunTimes, // Güneş & Vakit
}

/// Kilit Ekranı Widget Önizleme Söz Modeli
class WidgetPreviewQuote {
  final String referenceTr;
  final String referenceEn;
  final String referenceAr;
  final String arabic;
  final String meaningTr;
  final String meaningEn;
  final String meaningAr;

  const WidgetPreviewQuote({
    required this.referenceTr,
    required this.referenceEn,
    required this.referenceAr,
    required this.arabic,
    required this.meaningTr,
    required this.meaningEn,
    required this.meaningAr,
  });

  String localizedReference(String langCode) {
    if (langCode == 'en') return referenceEn;
    if (langCode == 'ar') return referenceAr;
    return referenceTr;
  }

  String localizedMeaning(String langCode) {
    if (langCode == 'en') return meaningEn;
    if (langCode == 'ar') return meaningAr;
    return meaningTr;
  }
}

const Map<String, List<WidgetPreviewQuote>> _categoryQuotes = {
  'all': [
    WidgetPreviewQuote(
      referenceTr: 'Bakara 2:152',
      referenceEn: 'Al-Baqarah 2:152',
      referenceAr: 'البقرة ٢:١٥٢',
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      meaningTr: 'Beni anın ki, ben de sizi anayım.\nBana şükredin, nankörlük etmeyin.',
      meaningEn: 'Remember Me; I will remember you.\nBe grateful to Me and do not deny Me.',
      meaningAr: 'فاذكروني أذكركم واشكروا لي ولا تكفرون',
    ),
    WidgetPreviewQuote(
      referenceTr: 'İnşirâh 94:6',
      referenceEn: 'Ash-Sharh 94:6',
      referenceAr: 'الشرح ٩٤:٦',
      arabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      meaningTr: 'Şüphesiz her güçlükle beraber\nbir kolaylık vardır.',
      meaningEn: 'Indeed, with hardship comes ease.',
      meaningAr: 'إن مع العسر يسراً',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Bakara 2:277',
      referenceEn: 'Al-Baqarah 2:277',
      referenceAr: 'البقرة ٢:٢٧٧',
      arabic: 'إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَأَقَامُوا الصَّلَاةَ',
      meaningTr: 'İman edip iyi işler yapan ve\nnamazı dosdoğru kılanların mükâfatı vardır.',
      meaningEn: 'Those who believe, do righteous deeds and establish prayer will have their reward.',
      meaningAr: 'إن الذين آمنوا وعملوا الصالحات وأقاموا الصلاة لهم أجرهم',
    ),
  ],
  'sabr': [
    WidgetPreviewQuote(
      referenceTr: 'Bakara 2:153',
      referenceEn: 'Al-Baqarah 2:153',
      referenceAr: 'البقرة ٢:١٥٣',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      meaningTr: 'Ey iman edenler! Sabır ve namaz ile Allah\'tan yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.',
      meaningEn: 'O you who believe! Seek help through patience and prayer. Indeed, Allah is with the patient.',
      meaningAr: 'يا أيها الذين آمنوا استعينوا بالصبر والصلاة إن الله مع الصابرين',
    ),
    WidgetPreviewQuote(
      referenceTr: 'İbrâhîm 14:7',
      referenceEn: 'Ibrahim 14:7',
      referenceAr: 'إبراهيم ١٤:٧',
      arabic: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ',
      meaningTr: 'Andolsun, eğer şükrederseniz\nelbette size nimetimi artırırım.',
      meaningEn: 'If you are grateful, I will surely increase you in favor.',
      meaningAr: 'لئن شكرتم لأزيدنكم',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Zümer 39:10',
      referenceEn: 'Az-Zumar 39:10',
      referenceAr: 'الزمر ٣٩:١٠',
      arabic: 'إِنَّمَا يُوَفَّى الصَّابِرُونَ أَجْرَهُم بِغَيْرِ حِسَابٍ',
      meaningTr: 'Yalnızca sabredenlere mükâfatları\nhesapsız olarak tastamam verilecektir.',
      meaningEn: 'Indeed, the patient will be given their reward without measure.',
      meaningAr: 'إنما يوفى الصابرون أجرهم بغير حساب',
    ),
  ],
  'dua': [
    WidgetPreviewQuote(
      referenceTr: 'Bakara 2:201',
      referenceEn: 'Al-Baqarah 2:201',
      referenceAr: 'البقرة ٢:٢٠١',
      arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      meaningTr: 'Rabbimiz! Bize dünyada da iyilik ver, ahirette de iyilik ver ve bizi ateş azabından koru.',
      meaningEn: 'Our Lord, give us in this world good and in the Hereafter good and protect us from the Fire.',
      meaningAr: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Mü\'min 40:60',
      referenceEn: 'Ghafir 40:60',
      referenceAr: 'غافر ٤٠:٦٠',
      arabic: 'وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ',
      meaningTr: 'Rabbiniz buyurdu ki:\nBana dua edin, size icabet edeyim.',
      meaningEn: 'And your Lord says:\nCall upon Me; I will respond to you.',
      meaningAr: 'وقال ربكم ادعوني أستجب لكم',
    ),
    WidgetPreviewQuote(
      referenceTr: 'İbrâhîm 14:40',
      referenceEn: 'Ibrahim 14:40',
      referenceAr: 'إبراهيم ١٤:٤٠',
      arabic: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      meaningTr: 'Rabbim! Beni ve neslimi namazı dosdoğru kılanlardan eyle. Duamı kabul buyur.',
      meaningEn: 'My Lord, make me an establisher of prayer, and from my descendants. Our Lord, accept my prayer.',
      meaningAr: 'رب اجعلني مقيم الصلاة ومن ذريتي ربنا وتقبل دعاء',
    ),
  ],
  'tawakkul': [
    WidgetPreviewQuote(
      referenceTr: 'Talâk 65:3',
      referenceEn: 'At-Talaq 65:3',
      referenceAr: 'الطلاق ٦٥:٣',
      arabic: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      meaningTr: 'Kim Allah\'a tevekkül ederse,\nO kendisine yeter.',
      meaningEn: 'And whoever relies upon Allah – then He is sufficient for him.',
      meaningAr: 'ومن يتوكل على الله فهو حسبه',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Tevbe 9:129',
      referenceEn: 'At-Tawbah 9:129',
      referenceAr: 'التوبة ٩:١٢٩',
      arabic: 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ',
      meaningTr: 'Bana Allah yeter. O\'ndan başka ilah yoktur. Ben yalnız O\'na güvendim.',
      meaningEn: 'Sufficient for me is Allah; there is no deity except Him. On Him I have relied.',
      meaningAr: 'حسبي الله لا إله إلا هو عليه توكلت',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Enfâl 8:2',
      referenceEn: 'Al-Anfal 8:2',
      referenceAr: 'الأنفال ٨:٢',
      arabic: 'وَعَلَىٰ رَبِّهِمْ يَتَوَكَّلُونَ',
      meaningTr: 'Müminler ancak o kimselerdir ki,\nyalnızca Rablerine tevekkül ederler.',
      meaningEn: 'The true believers are those who put their trust solely in their Lord.',
      meaningAr: 'وعلى ربهم يتوكلون',
    ),
  ],
  'akhlaq': [
    WidgetPreviewQuote(
      referenceTr: 'Fussilet 41:34',
      referenceEn: 'Fussilat 41:34',
      referenceAr: 'فصلت ٤١:٣٤',
      arabic: 'ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ فَإِذَا الَّذِي بَيْنَكَ وَبَيْنَهُ عَدَاوَةٌ كَأَنَّهُ وَلِيٌّ حَمِيمٌ',
      meaningTr: 'Kötülüğü en güzel olanla sav. Bir de bakarsın ki seninle arasında düşmanlık bulunan kimse sımsıcak bir dost oluvermiş.',
      meaningEn: 'Repel evil by that which is better; and thereupon the one whom between you and him was enmity will become as a close friend.',
      meaningAr: 'ادفع بالتي هي أحسن فإذا الذي بينك وبينه عداوة كأنه ولي حميم',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Hucurât 49:10',
      referenceEn: 'Al-Hujurat 49:10',
      referenceAr: 'الحجرات ٤٩:١٠',
      arabic: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ',
      meaningTr: 'Şüphesiz müminler ancak kardeştirler.\nÖyleyse kardeşlerinizin arasını düzeltin.',
      meaningEn: 'The believers are but brothers, so make peace between your brothers.',
      meaningAr: 'إنما المؤمنون إخوة فأصلحوا بين أخويكم',
    ),
    WidgetPreviewQuote(
      referenceTr: 'Kalem 68:4',
      referenceEn: 'Al-Qalam 68:4',
      referenceAr: 'القلم ٦٨:٤',
      arabic: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
      meaningTr: 'Ve şüphesiz sen pek yüce bir ahlak üzerindesin.',
      meaningEn: 'And indeed, you are of a great moral character.',
      meaningAr: 'وإنك لعلى خلق عظيم',
    ),
  ],
};

/// Kilit Ekranı & Widget Yönetim ve Özelleştirme Merkezi
class WidgetCenterScreen extends ConsumerStatefulWidget {
  const WidgetCenterScreen({super.key});

  @override
  ConsumerState<WidgetCenterScreen> createState() => _WidgetCenterScreenState();
}


class _WidgetCenterScreenState extends ConsumerState<WidgetCenterScreen> {
  WidgetCategoryType _selectedCategory = WidgetCategoryType.quotes;

  // Özelleştirme ayarları (Artık standart kodlarla saklanır)
  String _selectedQuoteCategory = 'all';
  String _verseViewMode = 'meal_only';
  String _refreshInterval = '1h';
  String _textSize = 'standard';
  String _fontFamily = 'standard';

  int _quoteIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedQuoteCategory = prefs.getString('widget_quote_category') ?? 'all';
      _verseViewMode = prefs.getString('widget_verse_view') ?? 'meal_only';
      _refreshInterval = prefs.getString('widget_refresh_interval') ?? '1h';
      _textSize = prefs.getString('widget_text_size') ?? 'standard';
      _fontFamily = prefs.getString('widget_font_family') ?? 'standard';

      // Eski Türkçe ayar değerlerini yeni standart kodlara dönüştür
      if (_selectedQuoteCategory == 'Tümü') _selectedQuoteCategory = 'all';
      if (_selectedQuoteCategory == 'Sabır ve Şükür') _selectedQuoteCategory = 'sabr';
      if (_selectedQuoteCategory == 'Dualar') _selectedQuoteCategory = 'dua';
      if (_selectedQuoteCategory == 'İman ve Tevekkül') _selectedQuoteCategory = 'tawakkul';
      if (_selectedQuoteCategory == 'Ahlak') _selectedQuoteCategory = 'akhlaq';

      if (_verseViewMode == 'Yalnızca Meal') _verseViewMode = 'meal_only';
      if (_verseViewMode == 'Arapça + Meal') _verseViewMode = 'arabic_meal';
      if (_verseViewMode == 'Yalnızca Arapça') _verseViewMode = 'arabic_only';

      if (_refreshInterval == '15 Dakika') _refreshInterval = '15m';
      if (_refreshInterval == '30 Dakika') _refreshInterval = '30m';
      if (_refreshInterval == 'Her saat') _refreshInterval = '1h';
      if (_refreshInterval == 'Her gün') _refreshInterval = '1d';

      if (_textSize == 'Küçük') _textSize = 'small';
      if (_textSize == 'Standart') _textSize = 'standard';
      if (_textSize == 'Büyük') _textSize = 'large';

      if (_fontFamily == 'Standart') _fontFamily = 'standard';
      if (_fontFamily == 'Zarif (Lato)') _fontFamily = 'lato';
      if (_fontFamily == 'Klasik (Amiri)') _fontFamily = 'amiri';

      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, String value, Function(String) updater) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    setState(() => updater(value));
    HapticFeedback.lightImpact();

    // Widget verilerini arka planda güncelle (kullanıcının erişimi varsa)
    final premiumState = ref.read(premiumProvider);
    if (premiumState.hasWidgetAccess) {
      await WidgetService().updateAllWidgets();
    }
  }

  String _getLocalizedVerseView(String mode, AppLanguage lang) {
    if (mode == 'meal_only' || mode == 'Yalnızca Meal') {
      return lang == AppLanguage.english ? 'Translation Only' : (lang == AppLanguage.arabic ? 'الترجمة فقط' : 'Yalnızca Meal');
    }
    if (mode == 'arabic_meal' || mode == 'Arapça + Meal') {
      return lang == AppLanguage.english ? 'Arabic + Translation' : (lang == AppLanguage.arabic ? 'العربية + الترجمة' : 'Arapça + Meal');
    }
    if (mode == 'arabic_only' || mode == 'Yalnızca Arapça') {
      return lang == AppLanguage.english ? 'Arabic Only' : (lang == AppLanguage.arabic ? 'العربية فقط' : 'Yalnızca Arapça');
    }
    return mode;
  }

  String _getLocalizedRefreshInterval(String interval, AppLanguage lang) {
    if (interval == '15m' || interval == '15 Dakika') {
      return lang == AppLanguage.english ? '15 Minutes' : (lang == AppLanguage.arabic ? '١٥ دقيقة' : '15 Dakika');
    }
    if (interval == '30m' || interval == '30 Dakika') {
      return lang == AppLanguage.english ? '30 Minutes' : (lang == AppLanguage.arabic ? '٣٠ دقيقة' : '30 Dakika');
    }
    if (interval == '1h' || interval == 'Her saat') {
      return lang == AppLanguage.english ? 'Every Hour' : (lang == AppLanguage.arabic ? 'كل ساعة' : 'Her saat');
    }
    if (interval == '1d' || interval == 'Her gün') {
      return lang == AppLanguage.english ? 'Daily' : (lang == AppLanguage.arabic ? 'يومياً' : 'Her gün');
    }
    return interval;
  }

  String _getLocalizedCategory(String cat, AppLanguage lang) {
    if (cat == 'all' || cat == 'Tümü') {
      return lang == AppLanguage.english ? 'All' : (lang == AppLanguage.arabic ? 'الكل' : 'Tümü');
    }
    if (cat == 'sabr' || cat == 'Sabır ve Şükür') {
      return lang == AppLanguage.english ? 'Patience & Gratitude' : (lang == AppLanguage.arabic ? 'الصبر والشكر' : 'Sabır ve Şükür');
    }
    if (cat == 'dua' || cat == 'Dualar') {
      return lang == AppLanguage.english ? 'Supplications' : (lang == AppLanguage.arabic ? 'الأدعية' : 'Dualar');
    }
    if (cat == 'tawakkul' || cat == 'İman ve Tevekkül') {
      return lang == AppLanguage.english ? 'Faith & Trust' : (lang == AppLanguage.arabic ? 'الإيمان والتوكل' : 'İman ve Tevekkül');
    }
    if (cat == 'akhlaq' || cat == 'Ahlak') {
      return lang == AppLanguage.english ? 'Morals & Ethics' : (lang == AppLanguage.arabic ? 'الأخلاق' : 'Ahlak');
    }
    return cat;
  }

  String _getLocalizedTextSize(String size, AppLanguage lang) {
    if (size == 'small' || size == 'Küçük') {
      return lang == AppLanguage.english ? 'Small' : (lang == AppLanguage.arabic ? 'صغير' : 'Küçük');
    }
    if (size == 'standard' || size == 'Standart') {
      return lang == AppLanguage.english ? 'Standard' : (lang == AppLanguage.arabic ? 'قياسي' : 'Standart');
    }
    if (size == 'large' || size == 'Büyük') {
      return lang == AppLanguage.english ? 'Large' : (lang == AppLanguage.arabic ? 'كبير' : 'Büyük');
    }
    return size;
  }

  String _getLocalizedFontFamily(String font, AppLanguage lang) {
    if (font == 'standard' || font == 'Standart') {
      return lang == AppLanguage.english ? 'Standard' : (lang == AppLanguage.arabic ? 'قياسي' : 'Standart');
    }
    if (font == 'lato' || font == 'Zarif (Lato)') {
      return lang == AppLanguage.english ? 'Elegant (Lato)' : (lang == AppLanguage.arabic ? 'أنيق (لاتو)' : 'Zarif (Lato)');
    }
    if (font == 'amiri' || font == 'Klasik (Amiri)') {
      return lang == AppLanguage.english ? 'Classical (Amiri)' : (lang == AppLanguage.arabic ? 'كلاسيكي (أميري)' : 'Klasik (Amiri)');
    }
    return font;
  }

  void _showOptionSheet<T>({
    required String title,
    required List<String> options,
    required String currentValue,
    String Function(String)? labelBuilder,
    required Function(String) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF07211C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final displayLabel = labelBuilder != null ? labelBuilder(opt) : opt;
                final isSelected = opt == currentValue || (labelBuilder != null && (labelBuilder(opt) == currentValue || opt == currentValue));
                return ListTile(
                  title: Text(
                    displayLabel,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: Color(0xFFD4AF37))
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelected(opt);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final strings = ref.watch(appStringsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF051C17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF051C17),
        elevation: 0,
        title: Text(
          strings.lockScreenWidgetsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 3 Günlük Deneme / Premium Durum Şeridi ────────────────
                  _buildTrialStatusBanner(premiumState, strings),

                  const SizedBox(height: 16),

                  // ── Yatay Kategori İkon Seçici (6 İkon) ───────────────────
                  _buildCategoryIconsBar(),

                  const SizedBox(height: 24),

                  // ── Gerçekçi Kilit Ekranı Canlı Önizlemesi (9:41) ──────────
                  _buildLockScreenPhoneMockup(strings),

                  const SizedBox(height: 24),

                  // ── Başlık ve Açıklama ───────────────────────────────────
                  _buildWidgetTitleAndDescription(strings),

                  const SizedBox(height: 20),

                  // ── Özelleştirilebilir Seçenekler Listesi ─────────────────
                  _buildCustomizationOptionsCard(strings),

                  const SizedBox(height: 24),

                  // ── Özellikler (Yeşil Onay İşaretleri) ────────────────────
                  _buildFeaturesCard(strings),

                  const SizedBox(height: 24),

                  // ── Nasıl Eklenir Adımları ────────────────────────────────
                  _buildHowToAddGuide(strings),

                  const SizedBox(height: 20),

                  // Alt banner reklam
                  const BannerAdWidget(),
                ],
              ),
            ),
    );
  }

  // ── 3 Günlük Deneme Durum Şeridi ───────────────────────────────────────────
  Widget _buildTrialStatusBanner(PremiumState premiumState, AppStrings strings) {
    if (premiumState.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFDF7A), size: 18),
            SizedBox(width: 8),
            Text(
              '★ Beyân Premium: Sınırsız Widget Erişimi',
              style: TextStyle(
                color: Color(0xFFFFDF7A),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      );
    }

    if (premiumState.isTrialActive) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => OnboardingTrialPaywallScreen.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F3E33),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Color(0xFF2DD4BF), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.trialActiveBanner(premiumState.trialDaysRemaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                strings.upgrade,
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Deneme süresi doldu
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => OnboardingTrialPaywallScreen.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade900.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.amber.shade600,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '3 Günlük Deneme Süresi Doldu • Widget için Premium\'a Geçin',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.amber, size: 12),
          ],
        ),
      ),
    );
  }

  // ── 6 İkonlu Yatay Kategori Çubuğu (Screenshots 2-5 üst kısmı) ─────────────
  Widget _buildCategoryIconsBar() {
    final categories = [
      (WidgetCategoryType.quotes, Icons.format_quote_rounded),
      (WidgetCategoryType.dailyVerse, Icons.menu_book_rounded),
      (WidgetCategoryType.prayerTimes, Icons.access_time_rounded),
      (WidgetCategoryType.countdown, Icons.timer_outlined),
      (WidgetCategoryType.hijri, Icons.nightlight_round),
      (WidgetCategoryType.sunTimes, Icons.wb_sunny_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: categories.map((item) {
          final isSelected = _selectedCategory == item.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = item.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF0E2C24),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF34D399)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  item.$2,
                  color: isSelected ? Colors.white : Colors.white60,
                  size: 22,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Gerçekçi iPhone Kilit Ekranı Önizlemesi ────────────────────────────────
  Widget _buildLockScreenPhoneMockup(AppStrings strings) {
    final asrLabel = strings.language == AppLanguage.english
        ? 'Asr: 2:15:30'
        : (strings.language == AppLanguage.arabic ? 'العصر: 2:15:30' : 'İkindi: 2:15:30');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFF041713),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Kilit Ekranı Tarihi veya Kompakt Satır Widget'ı ───────────────
          if (_selectedCategory == WidgetCategoryType.countdown) ...[
            // Screenshot 5: "Pazartesi, 6 Haziran | ⏱️ İkindi: 2:15:30"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  strings.mockupDate,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '|',
                  style: TextStyle(color: Colors.white38),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  asrLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ] else ...[
            Text(
              strings.mockupDate,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          const SizedBox(height: 6),

          // ── Büyük Saat: "9:41" ───────────────────────────────────────────
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 76,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 14),

          // ── Kilit Ekranı Saat Altı Widget Alanı ───────────────────────────
          _buildActiveWidgetPreviewContent(),

          // ── Önizlemede Farklı Âyet Gösterme Butonu ───────────────────────
          if (_selectedCategory == WidgetCategoryType.quotes ||
              _selectedCategory == WidgetCategoryType.dailyVerse) ...[
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _quoteIndex++);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shuffle_rounded, color: Color(0xFFFFDF7A), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      strings.previewAnotherVerse,
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
          ],
        ],
      ),
    );
  }

  // ── Font Boyutu Hesaplayıcıları (_textSize) ───────────────────────────────
  double get _previewTitleFontSize {
    switch (_textSize) {
      case 'Küçük':
        return 11.0;
      case 'Büyük':
        return 15.0;
      case 'Standart':
      default:
        return 13.0;
    }
  }

  double get _previewBodyFontSize {
    switch (_textSize) {
      case 'Küçük':
        return 11.0;
      case 'Büyük':
        return 15.0;
      case 'Standart':
      default:
        return 12.5;
    }
  }

  double get _previewArabicFontSize {
    switch (_textSize) {
      case 'Küçük':
        return 14.5;
      case 'Büyük':
        return 21.0;
      case 'Standart':
      default:
        return 17.5;
    }
  }

  String? get _previewFontFamily {
    switch (_fontFamily) {
      case 'Klasik (Amiri)':
        return 'Amiri';
      case 'Zarif (Lato)':
        return 'Lato';
      default:
        return null;
    }
  }

  // Kategori bazlı aktif ayet verisi
  WidgetPreviewQuote _getCurrentQuote() {
    final list = _categoryQuotes[_selectedQuoteCategory] ??
        _categoryQuotes['all'] ??
        _categoryQuotes.values.first;
    return list[_quoteIndex % list.length];
  }

  Widget _buildQuotePreviewWidget({
    required String reference,
    required String arabic,
    required String meaning,
  }) {
    final showArabic = _verseViewMode == 'arabic_meal' ||
        _verseViewMode == 'arabic_only' ||
        _verseViewMode == 'Arapça + Meal' ||
        _verseViewMode == 'Yalnızca Arapça';
    final showMeal = _verseViewMode == 'meal_only' ||
        _verseViewMode == 'arabic_meal' ||
        _verseViewMode == 'Yalnızca Meal' ||
        _verseViewMode == 'Arapça + Meal';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sûre Referansı
          Text(
            reference,
            style: TextStyle(
              color: const Color(0xFFFFDF7A),
              fontWeight: FontWeight.bold,
              fontSize: _previewTitleFontSize,
              fontFamily: _previewFontFamily,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Arapça Metin (Varsa)
          if (showArabic) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: _previewArabicFontSize,
                  height: 1.45,
                  color: Colors.white,
                ),
              ),
            ),
            if (showMeal) const SizedBox(height: 4),
          ],

          // Meal (Varsa)
          if (showMeal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                meaning,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: _previewBodyFontSize,
                  fontFamily: _previewFontFamily,
                  height: 1.3,
                  fontStyle: (_verseViewMode == 'arabic_meal' || _verseViewMode == 'Arapça + Meal') ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Aktif Kategoriye Göre Widget Önizleme İçeriği
  Widget _buildActiveWidgetPreviewContent() {
    final strings = ref.watch(appStringsProvider);
    final langCode = strings.language.code;

    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        final quote = _getCurrentQuote();
        return _buildQuotePreviewWidget(
          reference: quote.localizedReference(langCode),
          arabic: quote.arabic,
          meaning: quote.localizedMeaning(langCode),
        );

      case WidgetCategoryType.dailyVerse:
        final verse = ShortVerseNotification.pool[0];
        return _buildQuotePreviewWidget(
          reference: verse.localizedReference(langCode),
          arabic: verse.arabicText,
          meaning: verse.localizedText(langCode),
        );

      case WidgetCategoryType.prayerTimes:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.85 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Colors.white70, size: 13 * timeScale),
                  const SizedBox(width: 4),
                  Text('${strings.dhuhr} 12:30 PM', style: TextStyle(color: Colors.white70, fontSize: 11 * timeScale, fontFamily: _previewFontFamily)),
                  const SizedBox(width: 8),
                  Icon(Icons.wb_twilight_rounded, color: Colors.white70, size: 13 * timeScale),
                  const SizedBox(width: 4),
                  Text('${strings.asr} 3:45 PM', style: TextStyle(color: Colors.white70, fontSize: 11 * timeScale, fontFamily: _previewFontFamily)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '2:15:30',
                style: TextStyle(
                  fontSize: 26 * timeScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontFamily: _previewFontFamily,
                ),
              ),
            ],
          ),
        );

      case WidgetCategoryType.countdown:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            strings.language == AppLanguage.english
                ? '2 hrs 15 mins until Asr prayer'
                : (strings.language == AppLanguage.arabic
                    ? 'ساعتان و١٥ دقيقة حتى صلاة العصر'
                    : 'İkindi vaktine 2 saat 15 dk kaldı'),
            style: TextStyle(color: Colors.white70, fontSize: 12 * timeScale, fontFamily: _previewFontFamily),
          ),
        );

      case WidgetCategoryType.hijri:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              Text(
                strings.language == AppLanguage.english
                    ? '🌙 18 Ramadan 1447'
                    : (strings.language == AppLanguage.arabic
                        ? '🌙 ١٨ رمضان ١٤٤٧'
                        : '🌙 18 Ramazan 1447'),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13 * timeScale, fontFamily: _previewFontFamily),
              ),
              const SizedBox(height: 2),
              Text(
                strings.language == AppLanguage.english
                    ? '9 Days to Laylat al-Qadr'
                    : (strings.language == AppLanguage.arabic
                        ? '٩ أيام حتى ليلة القدر'
                        : 'Kadir Gecesine 9 Gün Kaldı'),
                style: TextStyle(color: Colors.white70, fontSize: 11.5 * timeScale, fontFamily: _previewFontFamily),
              ),
            ],
          ),
        );

      case WidgetCategoryType.sunTimes:
        final timeScale = (_textSize == 'small' || _textSize == 'Küçük') ? 0.9 : ((_textSize == 'large' || _textSize == 'Büyük') ? 1.25 : 1.0);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 16 * timeScale),
              const SizedBox(width: 6),
              Text(
                strings.language == AppLanguage.english
                    ? 'Sunrise: 05:42 • Ishraq: 06:27'
                    : (strings.language == AppLanguage.arabic
                        ? 'الشروق: ٠٥:٤٢ • الإشراق: ٠٦:٢٧'
                        : 'Güneş: 05:42 • İşrak: 06:27'),
                style: TextStyle(color: Colors.white, fontSize: 12 * timeScale, fontWeight: FontWeight.w600, fontFamily: _previewFontFamily),
              ),
            ],
          ),
        );
    }
  }


  // ── Başlık & Açıklama Metni ───────────────────────────────────────────────
  Widget _buildWidgetTitleAndDescription(AppStrings strings) {
    String title;
    String desc;

    switch (_selectedCategory) {
      case WidgetCategoryType.quotes:
        title = strings.widgetFeatureTitle;
        desc = strings.widgetFeatureDesc;
        break;
      case WidgetCategoryType.dailyVerse:
        title = strings.language == AppLanguage.english
            ? 'Daily Verse'
            : (strings.language == AppLanguage.arabic ? 'آية اليوم' : 'Günün Ayeti');
        desc = strings.language == AppLanguage.english
            ? 'Receive a new inspiring Quran verse automatically every day.'
            : (strings.language == AppLanguage.arabic
                ? 'احصل على آية قرآنية ملهمة جديدة تلقائياً كل يوم.'
                : 'Her gün otomatik olarak yeni bir ilham verici Kur\'an ayeti alın.');
        break;
      case WidgetCategoryType.prayerTimes:
        title = strings.language == AppLanguage.english
            ? 'Prayer Times'
            : (strings.language == AppLanguage.arabic ? 'مواقيت الصلاة' : 'Namaz Vakitleri');
        desc = strings.language == AppLanguage.english
            ? 'View current and upcoming prayer times with a live countdown timer.'
            : (strings.language == AppLanguage.arabic
                ? 'عرض مواقيت الصلاة الحالية والقادمة مع عداد تنازلي مباشر.'
                : 'Canlı geri sayım sayacıyla mevcut ve yaklaşan namaz vakitlerini görün.');
        break;
      case WidgetCategoryType.countdown:
        title = strings.language == AppLanguage.english
            ? 'Prayer Countdown'
            : (strings.language == AppLanguage.arabic ? 'العد التنازلي للصلاة' : 'Namaz Geri Sayımı');
        desc = strings.language == AppLanguage.english
            ? 'Compact inline widget showing live countdown to the next prayer. Appears right on your lock screen.'
            : (strings.language == AppLanguage.arabic
                ? 'مصغر مضمن يعرض العد التنازلي للصلاة القادمة على شاشة القفل.'
                : 'Bir sonraki namazı canlı geri sayımla gösteren kompakt satır içi widget. Kilit Ekranınızda tarihin üzerinde görünür.');
        break;
      case WidgetCategoryType.hijri:
        title = strings.language == AppLanguage.english
            ? 'Hijri Calendar & Holy Days'
            : (strings.language == AppLanguage.arabic ? 'التقويم الهجري والمناسبات' : 'Hicri Takvim & Kandiller');
        desc = strings.language == AppLanguage.english
            ? 'Track Hijri date, blessed nights, and Islamic holidays instantly on your lock screen.'
            : (strings.language == AppLanguage.arabic
                ? 'تابع التاريخ الهجري والمناسبات الإسلامية فوراً من شاشة القفل.'
                : 'Hicri tarih, mübarek kandiller ve dini bayramları kilit ekranınızdan anlık takip edin.');
        break;
      case WidgetCategoryType.sunTimes:
        title = strings.language == AppLanguage.english
            ? 'Sunrise & Ishraq'
            : (strings.language == AppLanguage.arabic ? 'الشروق والإشراق' : 'Güneş & Kerahat Vakti');
        desc = strings.language == AppLanguage.english
            ? 'Monitor sunrise and Ishraq prayer times directly on your lock screen.'
            : (strings.language == AppLanguage.arabic
                ? 'راقب وقت شروق الشمس والإشراق مباشرة على شاشة قفلك.'
                : 'Güneş doğuşunu, kerahat çıkışını ve işrak vaktini kilit ekranınızda izleyin.');
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── Özelleştirilebilir Seçenekler Kartı (Screenshots 2-3) ───────────────────
  Widget _buildCustomizationOptionsCard(AppStrings strings) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A241F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 1. Görüntülenecek Kategoriler (Yalnızca Quotes için)
          if (_selectedCategory == WidgetCategoryType.quotes) ...[
            _buildOptionTile(
              title: strings.displayCategories,
              value: _getLocalizedCategory(_selectedQuoteCategory, strings.language),
              onTap: () => _showOptionSheet(
                title: strings.displayCategories,
                options: const ['all', 'sabr', 'dua', 'tawakkul', 'akhlaq'],
                currentValue: _selectedQuoteCategory,
                labelBuilder: (c) => _getLocalizedCategory(c, strings.language),
                onSelected: (val) => _savePreference('widget_quote_category', val, (v) => _selectedQuoteCategory = v),
              ),
            ),
            _buildDivider(),
          ],

          // 2. Ayet Görünümü
          if (_selectedCategory == WidgetCategoryType.quotes ||
              _selectedCategory == WidgetCategoryType.dailyVerse) ...[
            _buildOptionTile(
              title: strings.language == AppLanguage.english ? 'Verse View' : (strings.language == AppLanguage.arabic ? 'عرض الآية' : 'Ayet Görünümü'),
              value: _getLocalizedVerseView(_verseViewMode, strings.language),
              onTap: () => _showOptionSheet(
                title: strings.language == AppLanguage.english ? 'Verse View' : (strings.language == AppLanguage.arabic ? 'عرض الآية' : 'Ayet Görünümü'),
                options: const ['meal_only', 'arabic_meal', 'arabic_only'],
                currentValue: _verseViewMode,
                labelBuilder: (v) => _getLocalizedVerseView(v, strings.language),
                onSelected: (val) => _savePreference('widget_verse_view', val, (v) => _verseViewMode = v),
              ),
            ),
            _buildDivider(),
          ],

          // 3. Alıntı Yenileme Sıklığı
          _buildOptionTile(
            title: strings.quoteRefreshInterval,
            value: _getLocalizedRefreshInterval(_refreshInterval, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.quoteRefreshInterval,
              options: const ['15m', '30m', '1h', '1d'],
              currentValue: _refreshInterval,
              labelBuilder: (i) => _getLocalizedRefreshInterval(i, strings.language),
              onSelected: (val) => _savePreference('widget_refresh_interval', val, (v) => _refreshInterval = v),
            ),
          ),
          _buildDivider(),

          // 4. Metin Boyutu
          _buildOptionTile(
            title: strings.textSize,
            value: _getLocalizedTextSize(_textSize, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.textSize,
              options: const ['small', 'standard', 'large'],
              currentValue: _textSize,
              labelBuilder: (s) => _getLocalizedTextSize(s, strings.language),
              onSelected: (val) => _savePreference('widget_text_size', val, (v) => _textSize = v),
            ),
          ),
          _buildDivider(),

          // 5. Yazı Tipi
          _buildOptionTile(
            title: strings.fontFamily,
            value: _getLocalizedFontFamily(_fontFamily, strings.language),
            onTap: () => _showOptionSheet(
              title: strings.fontFamily,
              options: const ['standard', 'lato', 'amiri'],
              currentValue: _fontFamily,
              labelBuilder: (f) => _getLocalizedFontFamily(f, strings.language),
              onSelected: (val) => _savePreference('widget_font_family', val, (v) => _fontFamily = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white38,
            size: 13,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.white.withValues(alpha: 0.08),
      indent: 16,
      endIndent: 16,
    );
  }

  // ── Özellikler Listesi (Screenshots 3-4) ──────────────────────────────────
  Widget _buildFeaturesCard(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.features,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildFeatureItem(strings.featCountdown),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featCurrentPrayers),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featAutoUpdate),
              const SizedBox(height: 12),
              _buildFeatureItem(strings.featBatterySave),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: Color(0xFF032620),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Nasıl Eklenir Adımları (Screenshots 4-5) ──────────────────────────────
  Widget _buildHowToAddGuide(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.howToAdd,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A241F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildStepItem(
                number: '1',
                text: strings.howToAddStep1,
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '2',
                text: strings.howToAddStep2,
              ),
              const SizedBox(height: 14),
              _buildStepItem(
                number: '3',
                text: strings.howToAddStep3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF032620),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
