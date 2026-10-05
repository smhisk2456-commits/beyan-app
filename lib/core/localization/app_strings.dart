import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Desteklenen diller
enum AppLanguage {
  turkish('tr', 'Türkçe', 'TR', '🇹🇷'),
  english('en', 'English', 'EN', '🇬🇧'),
  arabic('ar', 'العربية', 'AR', '🇸🇦');

  final String code;
  final String displayName;
  final String shortCode;
  final String flag;

  const AppLanguage(this.code, this.displayName, this.shortCode, this.flag);

  Locale get locale => Locale(code);
  bool get isRTL => this == AppLanguage.arabic;

  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'ar':
        return AppLanguage.arabic;
      case 'tr':
      default:
        return AppLanguage.turkish;
    }
  }
}

/// Dil durum yöneticisi (StateNotifier)
class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const _prefKey = 'selected_app_language';

  LanguageNotifier() : super(AppLanguage.turkish) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        state = AppLanguage.fromCode(code);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {}
  }
}

/// Uygulama dili Riverpod Provider'ı
final appLanguageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

/// Aktif çeviri nesnesi provider'ı
final appStringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});

/// Tüm uygulama metinlerini çok dilli (TR / EN / AR) olarak sunan sınıf.
class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  // ── Genel & Başlıklar ──────────────────────────────────────────
  String get appName => 'Beyân';
  String get bismillah => 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  String get bismillahTransliteration => 'Bismillâhirrahmânirrahîm';
  String get done => language == AppLanguage.turkish
      ? 'Tamam'
      : (language == AppLanguage.english ? 'Done' : 'تم');
  String get cancel => language == AppLanguage.turkish
      ? 'Vazgeç'
      : (language == AppLanguage.english ? 'Cancel' : 'إلغاء');
  String get close => language == AppLanguage.turkish
      ? 'Kapat'
      : (language == AppLanguage.english ? 'Close' : 'إغلاق');
  String get settings => language == AppLanguage.turkish
      ? 'Ayarlar'
      : (language == AppLanguage.english ? 'Settings' : 'الإعدادات');
  String get languageSelect => language == AppLanguage.turkish
      ? 'Dil Seçimi'
      : (language == AppLanguage.english ? 'Language' : 'اللغة');

  // ── Alt Navigasyon (Dock) ──────────────────────────────────────
  String get tabHome => language == AppLanguage.turkish
      ? 'Ana Sayfa'
      : (language == AppLanguage.english ? 'Home' : 'الرئيسية');
  String get tabPrayers => language == AppLanguage.turkish
      ? 'Vakitler'
      : (language == AppLanguage.english ? 'Prayers' : 'المواقيت');
  String get tabQuran => language == AppLanguage.turkish
      ? 'Kur\'an'
      : (language == AppLanguage.english ? 'Quran' : 'القرآن');
  String get tabZikr => language == AppLanguage.turkish
      ? 'Zikirmatik'
      : (language == AppLanguage.english ? 'Tasbih' : 'المسبحة');
  String get tabWidget => language == AppLanguage.turkish
      ? 'Widget'
      : (language == AppLanguage.english ? 'Widget' : 'الأدوات');

  // ── Hızlı Erişim Butonları ─────────────────────────────────────
  String get actionLastRead => language == AppLanguage.turkish
      ? 'Kaldığım Yer'
      : (language == AppLanguage.english ? 'Last Read' : 'حيث توقفت');
  String get actionLastReadSub => language == AppLanguage.turkish
      ? 'Fâtiha'
      : (language == AppLanguage.english ? 'Al-Fatiha' : 'الفاتحة');

  String get actionQibla => language == AppLanguage.turkish
      ? 'Kıble'
      : (language == AppLanguage.english ? 'Qibla' : 'القبلة');
  String get actionQiblaSub => language == AppLanguage.turkish
      ? '152° GB'
      : (language == AppLanguage.english ? '152° SE' : '١٥٢° ج.ش');

  String get actionZikr => language == AppLanguage.turkish
      ? 'Zikirmatik'
      : (language == AppLanguage.english ? 'Tasbih' : 'المسبحة');
  String get actionZikrSub => language == AppLanguage.turkish
      ? 'Tesbihat'
      : (language == AppLanguage.english ? 'Dhikr' : 'أذكار');

  String get actionWidget => language == AppLanguage.turkish
      ? 'Kilit Ekranı'
      : (language == AppLanguage.english ? 'Lock Screen' : 'شاشة القفل');
  String get actionWidgetSub => language == AppLanguage.turkish
      ? 'Canlı Widget'
      : (language == AppLanguage.english ? 'Live Widget' : 'أداة حية');

  // ── Namaz Vakitleri & Rekatlar ──────────────────────────────────
  String get nextPrayer => language == AppLanguage.turkish
      ? 'Sıradaki Namaz'
      : (language == AppLanguage.english ? 'Next Prayer' : 'الصلاة القادمة');
  String get currentPrayer => language == AppLanguage.turkish
      ? 'Şu anki vakit'
      : (language == AppLanguage.english ? 'Current Prayer' : 'الوقت الحالي');
  String get remainingTime => language == AppLanguage.turkish
      ? 'kaldı'
      : (language == AppLanguage.english ? 'left' : 'متبقي');
  String get dailyPrayers => language == AppLanguage.turkish
      ? 'Günlük Vakitler'
      : (language == AppLanguage.english ? 'Daily Times' : 'مواقيت اليوم');
  String get updateLocation => language == AppLanguage.turkish
      ? 'Konumu Güncelle'
      : (language == AppLanguage.english ? 'Update Location' : 'تحديث الموقع');
  String get diyanetMethod => language == AppLanguage.turkish
      ? 'Diyanet Takvimi'
      : (language == AppLanguage.english ? 'Diyanet Method' : 'تقويم ديانت');
  String get nextPrayerLabel => language == AppLanguage.turkish
      ? 'Sıradaki'
      : (language == AppLanguage.english ? 'Next' : 'القادمة');

  // Namaz İsimleri
  String get prayerNameFajr => language == AppLanguage.turkish
      ? 'İmsak'
      : (language == AppLanguage.english ? 'Fajr' : 'الفجر');
  String get prayerNameSunrise => language == AppLanguage.turkish
      ? 'Güneş'
      : (language == AppLanguage.english ? 'Sunrise' : 'الشروق');
  String get prayerNameDhuhr => language == AppLanguage.turkish
      ? 'Öğle'
      : (language == AppLanguage.english ? 'Dhuhr' : 'الظهر');
  String get prayerNameAsr => language == AppLanguage.turkish
      ? 'İkindi'
      : (language == AppLanguage.english ? 'Asr' : 'العصر');
  String get prayerNameMaghrib => language == AppLanguage.turkish
      ? 'Akşam'
      : (language == AppLanguage.english ? 'Maghrib' : 'المغرب');
  String get prayerNameIsha => language == AppLanguage.turkish
      ? 'Yatsı'
      : (language == AppLanguage.english ? 'Isha' : 'العشاء');

  // Rekat Detayları
  String get rakatFajr => language == AppLanguage.turkish
      ? '4 Rekat (2 Sünnet + 2 Farz)'
      : (language == AppLanguage.english
          ? '4 Rakats (2 Sunnah + 2 Fard)'
          : '٤ ركعات (٢ سنة + ٢ فرض)');

  String get rakatSunrise => language == AppLanguage.turkish
      ? 'Kerâhet Vakti / Güneş Doğuşu'
      : (language == AppLanguage.english
          ? 'Sunrise (Restricted Time)'
          : 'شروق الشمس (وقت الكراهة)');

  String get rakatDhuhr => language == AppLanguage.turkish
      ? '10 Rekat (4 Sünnet + 4 Farz + 2 Sünnet)'
      : (language == AppLanguage.english
          ? '10 Rakats (4 Sunnah + 4 Fard + 2 Sunnah)'
          : '١٠ ركعات (٤ سنة + ٤ فرض + ٢ سنة)');

  String get rakatAsr => language == AppLanguage.turkish
      ? '8 Rekat (4 Sünnet + 4 Farz)'
      : (language == AppLanguage.english
          ? '8 Rakats (4 Sunnah + 4 Fard)'
          : '٨ ركعات (٤ سنة + ٤ فرض)');

  String get rakatMaghrib => language == AppLanguage.turkish
      ? '5 Rekat (3 Farz + 2 Sünnet)'
      : (language == AppLanguage.english
          ? '5 Rakats (3 Fard + 2 Sunnah)'
          : '٥ ركعات (٣ فرض + ٢ سنة)');

  String get rakatIsha => language == AppLanguage.turkish
      ? '13 Rekat (4 Sünnet + 4 Farz + 2 Sünnet + 3 Vitir)'
      : (language == AppLanguage.english
          ? '13 Rakats (4 Sunnah + 4 Fard + 2 Sunnah + 3 Witr)'
          : '١٣ ركعة (٤ سنة + ٤ فرض + ٢ سنة + ٣ وتر)');

  // ── Kur'an & Arama ─────────────────────────────────────────────
  String get quranTitle => language == AppLanguage.turkish
      ? 'Kur\'an-ı Kerim'
      : (language == AppLanguage.english ? 'The Holy Quran' : 'القرآن الكريم');
  String get searchSurahPlaceholder => language == AppLanguage.turkish
      ? 'Sure ara... (yasin, ihlas, 36...)'
      : (language == AppLanguage.english
          ? 'Search surah... (yasin, ikhlas, 36...)'
          : 'ابحث عن سورة... (يس، الإخلاص، ٣٦...)');
  String get searchResults => language == AppLanguage.turkish
      ? 'Arama Sonuçları'
      : (language == AppLanguage.english ? 'Search Results' : 'نتائج البحث');
  String get noSurahFound => language == AppLanguage.turkish
      ? 'Sure bulunamadı'
      : (language == AppLanguage.english ? 'No surah found' : 'لم يتم العثور على سورة');
  String get totalSurahs => language == AppLanguage.turkish
      ? '114 Sure'
      : (language == AppLanguage.english ? '114 Surahs' : '١١٤ سورة');
  String surahBadge(int count) => language == AppLanguage.turkish
      ? '$count ayet'
      : (language == AppLanguage.english ? '$count verses' : '$count آية');
  String surahNumber(int num) => language == AppLanguage.turkish
      ? '$num. Sure'
      : (language == AppLanguage.english ? 'Surah $num' : 'سورة $num');
  String get makki => language == AppLanguage.turkish
      ? 'Mekki'
      : (language == AppLanguage.english ? 'Makki' : 'مكية');
  String get madani => language == AppLanguage.turkish
      ? 'Medeni'
      : (language == AppLanguage.english ? 'Madani' : 'مدنية');

  // ── Zikirmatik ─────────────────────────────────────────────────
  String get zikirmatikTitle => language == AppLanguage.turkish
      ? 'Zikirmatik'
      : (language == AppLanguage.english ? 'Digital Tasbih' : 'المسبحة الإلكترونية');
  String get zikirmatikInstruction => language == AppLanguage.turkish
      ? 'Dokunarak tesbihat çekebilirsiniz'
      : (language == AppLanguage.english
          ? 'Tap circle to count dhikr'
          : 'اضغط على الدائرة للتسبيح');
  String targetLabel(int target) => language == AppLanguage.turkish
      ? 'Hedef: $target'
      : (language == AppLanguage.english ? 'Target: $target' : 'الهدف: $target');

  // ── Kıble ──────────────────────────────────────────────────────
  String get qiblaTitle => language == AppLanguage.turkish
      ? 'Kıble Yönü'
      : (language == AppLanguage.english ? 'Qibla Direction' : 'اتجاه القبلة');
  String get qiblaAngleText => language == AppLanguage.turkish
      ? 'İstanbul için Kıble Açısı: 152° Güneydoğu'
      : (language == AppLanguage.english
          ? 'Qibla Angle for Istanbul: 152° Southeast'
          : 'زاوية القبلة لإسطنبول: ١٥٢° جنوب شرق');
  String get qiblaInstruction => language == AppLanguage.turkish
      ? 'Cihazınızı yatay tutarak pusulayı Kâbe yönüne hizalayabilirsiniz.'
      : (language == AppLanguage.english
          ? 'Hold your device flat to align with the Kaaba.'
          : 'أمسك جهازك بشكل أفقي لتوجيه البوصلة نحو الكعبة المشرفة.');

  // ── Kilit Ekranı & Widget ──────────────────────────────────────
  String get widgetCenterTitle => language == AppLanguage.turkish
      ? 'Kilit Ekranı & Widget'
      : (language == AppLanguage.english
          ? 'Lock Screen & Widget'
          : 'شاشة القفل والمصغرات');
  String get widgetPreviewTitle => language == AppLanguage.turkish
      ? 'Kilit Ekranı Canlı Görünümü'
      : (language == AppLanguage.english
          ? 'Lock Screen Live Preview'
          : 'معاينة شاشة القفل');
  String get widgetIntervalTitle => language == AppLanguage.turkish
      ? 'Ayet Değişim Sıklığı'
      : (language == AppLanguage.english
          ? 'Verse Refresh Interval'
          : 'تكرار تغيير الآيات');
  String get widgetIntervalDesc => language == AppLanguage.turkish
      ? 'Kilit ekranınızdaki ve ana ekranınızdaki ayetlerin ne kadar sürede bir otomatik değişeceğini belirleyin:'
      : (language == AppLanguage.english
          ? 'Select how frequently verses update automatically on your lock and home screens:'
          : 'حدد مدى تكرار تغيير الآيات تلقائيًا على شاشة القفل والشاشة الرئيسية:');
  String get refreshVerseNow => language == AppLanguage.turkish
      ? 'Hemen Yeni Bir Ayet Yansıt'
      : (language == AppLanguage.english
          ? 'Refresh Verse Now'
          : 'تحديث الآية الآن');
  String get howToAdd => language == AppLanguage.turkish
      ? 'Nasıl Eklenir?'
      : (language == AppLanguage.english ? 'How to Add?' : 'كيفية الإضافة؟');
  String get iphoneGuideTitle => language == AppLanguage.turkish
      ? 'iPhone Kilit Ekranı'
      : (language == AppLanguage.english
          ? 'iPhone Lock Screen'
          : 'شاشة قفل iPhone');
  String get iphoneGuideDesc => language == AppLanguage.turkish
      ? 'Kilit ekranına basılı tutun, "Özelleştir" > "Widget Ekle" deyip Beyân uygulamasını seçin.'
      : (language == AppLanguage.english
          ? 'Press & hold lock screen, tap Customize > Add Widgets, and select Beyân.'
          : 'اضغط مطولاً على شاشة القفل، ثم اضغط تخصيص > إضافة أداة، واختر تطبيق بيان.');
  String get androidGuideTitle => language == AppLanguage.turkish
      ? 'Android Ana Ekranı'
      : (language == AppLanguage.english
          ? 'Android Home Screen'
          : 'شاشة Android الرئيسية');
  String get androidGuideDesc => language == AppLanguage.turkish
      ? 'Ana ekranda boş bir yere basılı tutun, "Widgets" bölümünden Beyân seçin.'
      : (language == AppLanguage.english
          ? 'Long press on home screen, select Widgets, and choose Beyân.'
          : 'اضغط مطولاً على الشاشة الرئيسية، افتح الأدوات (Widgets) واختر بيان.');
  String minutesSuffix(int m) => language == AppLanguage.turkish
      ? '$m Dakika'
      : (language == AppLanguage.english ? '$m Minutes' : '$m دقيقة');
  String minutesShort(int m) => language == AppLanguage.turkish
      ? '$m dk'
      : (language == AppLanguage.english ? '$m min' : '$m د');
}
