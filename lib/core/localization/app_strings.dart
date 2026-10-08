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

  // ── Hızlı Erişim Butonları Ek Çeviriler ────────────────────────
  String get actionPrayersSub => language == AppLanguage.turkish
      ? '6 Vakit'
      : (language == AppLanguage.english ? '6 Prayers' : '٦ مواقيت');
  String get actionQuranSub => language == AppLanguage.turkish
      ? '114 Sure'
      : (language == AppLanguage.english ? '114 Surahs' : '١١٤ سورة');
  String get actionDuas => language == AppLanguage.turkish
      ? 'Dualar'
      : (language == AppLanguage.english ? 'Duas' : 'الأدعية');
  String get actionDuasSub => language == AppLanguage.turkish
      ? 'Kütüphane'
      : (language == AppLanguage.english ? 'Library' : 'المكتبة');
  String get actionCalendar => language == AppLanguage.turkish
      ? 'Hicri Takvim'
      : (language == AppLanguage.english ? 'Hijri Calendar' : 'التقويم الهجري');
  String get actionCalendarSub => language == AppLanguage.turkish
      ? 'Kandiller'
      : (language == AppLanguage.english ? 'Holy Days' : 'المناسبات');
  String get actionRamadan => language == AppLanguage.turkish
      ? 'Ramazan'
      : (language == AppLanguage.english ? 'Ramadan' : 'رمضان');
  String get actionRamadanSub => language == AppLanguage.turkish
      ? 'İftar/Sahur'
      : (language == AppLanguage.english ? 'Iftar/Suhoor' : 'إفطار وسحور');

  // ── Günlük Kartlar ─────────────────────────────────────────────
  String get dailyVerseTitle => language == AppLanguage.turkish
      ? 'Günün Ayet-i Kerimesi'
      : (language == AppLanguage.english ? 'Daily Quran Verse' : 'آية اليوم');
  String get dailyDuaTitle => language == AppLanguage.turkish
      ? 'Günün Niyazı ve Duası'
      : (language == AppLanguage.english ? 'Daily Supplication' : 'دعاء اليوم');
  String get allDuasLink => language == AppLanguage.turkish
      ? 'Tüm Dualar ➔'
      : (language == AppLanguage.english ? 'All Duas ➔' : 'جميع الأدعية ➔');

  // ── Günün Âyeti Bildirimleri ────────────────────────────────────
  String get verseNotifTitle => language == AppLanguage.turkish
      ? 'Günün Âyeti & Sure Bildirimleri'
      : (language == AppLanguage.english
          ? 'Daily Verse & Surah Reminders'
          : 'تنبيهات آيات وسور اليوم');
  String get verseNotifDesc => language == AppLanguage.turkish
      ? 'Her gün belirlenen saatte ilham veren bir âyet ve tefekkür bildirimi alın'
      : (language == AppLanguage.english
          ? 'Receive inspiring Quranic verses and spiritual reminders daily'
          : 'احصل يوميًا على آيات قرآنية ملهمة وتأملات إيمانية');
  String get verseNotifTime => language == AppLanguage.turkish
      ? 'Bildirim Saati'
      : (language == AppLanguage.english ? 'Reminder Time' : 'وقت التنبيه');
  String get verseNotifFrequency => language == AppLanguage.turkish
      ? 'Gönderim Sıklığı'
      : (language == AppLanguage.english ? 'Frequency' : 'تكرار التنبيه');
  String get verseNotifFreqDaily => language == AppLanguage.turkish
      ? 'Günde 1 Kez'
      : (language == AppLanguage.english ? 'Once Daily' : 'مرة واحدة يومياً');
  String get verseNotifFreqMorningEvening => language == AppLanguage.turkish
      ? 'Sabah & Akşam'
      : (language == AppLanguage.english ? 'Morning & Evening' : 'صباحاً ومساءً');
  String get verseNotifTestBtn => language == AppLanguage.turkish
      ? 'Âyet Bildirimini Test Et'
      : (language == AppLanguage.english ? 'Test Verse Reminder' : 'اختبار إشعار الآية');
  String get verseNotifTestSuccess => language == AppLanguage.turkish
      ? 'Test âyet bildirimi cihazınıza gönderildi!'
      : (language == AppLanguage.english
          ? 'Test verse notification sent to your device!'
          : 'تم إرسال إشعار الآية التجريبي إلى جهازك!');

  // ── Ana Sayfa Ek Çeviriler ─────────────────────────────────────
  String get continueReadingQuran => language == AppLanguage.turkish
      ? 'Kur\'an-ı Kerim Okumaya Devam Et'
      : (language == AppLanguage.english
          ? 'Continue Reading Quran'
          : 'متابعة تلاوة القرآن الكريم');
  String surahVerseLabel(String surahName, int verseNumber) =>
      language == AppLanguage.turkish
          ? '$surahName Suresi • $verseNumber. Âyet'
          : (language == AppLanguage.english
              ? 'Surah $surahName • Verse $verseNumber'
              : 'سورة $surahName • آية $verseNumber');
  String get today => language == AppLanguage.turkish
      ? 'Bugün!'
      : (language == AppLanguage.english ? 'Today!' : 'اليوم!');
  String daysRemainingText(int days) => language == AppLanguage.turkish
      ? '$days gün kaldı'
      : (language == AppLanguage.english
          ? '$days days left'
          : '$days أيام متبقية');
  String get calendarArrow => language == AppLanguage.turkish
      ? 'Takvim ➔'
      : (language == AppLanguage.english ? 'Calendar ➔' : 'التقويم ➔');

  // ── Zikirmatik & İbadet Takibi Ek Çeviriler ──────────────────
  String get tapToCount => language == AppLanguage.turkish
      ? 'DOKUN'
      : (language == AppLanguage.english ? 'TAP' : 'اضغط');
  String get undo => language == AppLanguage.turkish
      ? 'Geri Al'
      : (language == AppLanguage.english ? 'Undo' : 'تراجع');
  String get reset => language == AppLanguage.turkish
      ? 'Sıfırla'
      : (language == AppLanguage.english ? 'Reset' : 'إعادة ضبط');
  String get resetConfirmTitle => language == AppLanguage.turkish
      ? 'Zikri Sıfırla'
      : (language == AppLanguage.english ? 'Reset Dhikr' : 'إعادة ضبط الذكر');
  String get resetConfirmDesc => language == AppLanguage.turkish
      ? 'Mevcut sayımı ve tur sayısını sıfırlamak istiyor musunuz?'
      : (language == AppLanguage.english
          ? 'Do you want to reset current count and completed laps?'
          : 'هل ترغب في إعادة ضبط العداد الحالي والدورات المكتملة؟');
  String lapsText(int laps) => language == AppLanguage.turkish
      ? '$laps Tur'
      : (language == AppLanguage.english ? '$laps Laps' : '$laps دورات');
  String get worshipTrackerTab => language == AppLanguage.turkish
      ? 'İbadet Takibi'
      : (language == AppLanguage.english ? 'Worship Tracker' : 'متابعة العبادات');
  String get addCustomDhikr => language == AppLanguage.turkish
      ? 'Özel Zikir Ekle'
      : (language == AppLanguage.english ? 'Add Custom Dhikr' : 'إضافة ذكر مخصص');
  String get customDhikrTitleHint => language == AppLanguage.turkish
      ? 'Zikir Başlığı (Örn: Lâ Havle...)'
      : (language == AppLanguage.english
          ? 'Dhikr Title (e.g., La Hawla...)'
          : 'عنوان الذكر (مثل: لا حول ولا قوة...)');
  String get customDhikrMeaningHint => language == AppLanguage.turkish
      ? 'Anlamı veya Niyeti'
      : (language == AppLanguage.english
          ? 'Meaning or Intention'
          : 'المعنى أو النية');
  String get add => language == AppLanguage.turkish
      ? 'Ekle'
      : (language == AppLanguage.english ? 'Add' : 'إضافة');

  // Dokunma Hissi (Haptic Feedback)
  String get hapticTitle => language == AppLanguage.turkish
      ? 'Titreşim / Dokunuş Hissi'
      : (language == AppLanguage.english ? 'Haptic Feedback' : 'الاهتزاز اللمسي');
  String get hapticLight => language == AppLanguage.turkish
      ? 'Hafif'
      : (language == AppLanguage.english ? 'Light' : 'خفيف');
  String get hapticMedium => language == AppLanguage.turkish
      ? 'Orta'
      : (language == AppLanguage.english ? 'Medium' : 'متوسط');
  String get hapticHeavy => language == AppLanguage.turkish
      ? 'Güçlü'
      : (language == AppLanguage.english ? 'Heavy' : 'قوي');
  String get hapticOff => language == AppLanguage.turkish
      ? 'Kapalı'
      : (language == AppLanguage.english ? 'Off' : 'إيقاف');

  // Seri ve İbadet Alışkanlıkları
  String streakDaysTitle(int days) => language == AppLanguage.turkish
      ? '$days. Gün Serisi'
      : (language == AppLanguage.english
          ? '$days Days Streak'
          : 'سلسلة $days أيام');
  String get startStreak => language == AppLanguage.turkish
      ? 'Günlük Seri Başlat'
      : (language == AppLanguage.english ? 'Start Daily Streak' : 'ابدأ السلسلة اليومية');
  String get todayAllTasksDone => language == AppLanguage.turkish
      ? '✨ Bugünkü görevler tamamlandı!'
      : (language == AppLanguage.english
          ? '✨ All tasks completed for today!'
          : '✨ اكتملت جميع مهام اليوم!');
  String remainingTasksText(int count) => language == AppLanguage.turkish
      ? 'Bugün için $count görev kaldı'
      : (language == AppLanguage.english
          ? '$count tasks remaining today'
          : 'متبقي اليوم $count مهام');
  String bestStreakLabel(int count) => language == AppLanguage.turkish
      ? 'En İyi: $count'
      : (language == AppLanguage.english ? 'Best: $count' : 'الأفضل: $count');
  String targetMilestoneLabel(String name) => language == AppLanguage.turkish
      ? 'Hedef: $name'
      : (language == AppLanguage.english ? 'Target: $name' : 'الهدف: $name');
  String get spiritualRewardsBtn => language == AppLanguage.turkish
      ? 'Motive Edici Sureler & Ödüller'
      : (language == AppLanguage.english
          ? 'Spiritual Surahs & Rewards'
          : 'سور التحفيز والجوائز الروحانية');

  // İbadet Başlıkları
  String get habitFajr => language == AppLanguage.turkish
      ? 'Sabah Namazı'
      : (language == AppLanguage.english ? 'Fajr Prayer' : 'صلاة الفجر');
  String get habitDhuhr => language == AppLanguage.turkish
      ? 'Öğle Namazı'
      : (language == AppLanguage.english ? 'Dhuhr Prayer' : 'صلاة الظهر');
  String get habitAsr => language == AppLanguage.turkish
      ? 'İkindi Namazı'
      : (language == AppLanguage.english ? 'Asr Prayer' : 'صلاة العصر');
  String get habitMaghrib => language == AppLanguage.turkish
      ? 'Akşam Namazı'
      : (language == AppLanguage.english ? 'Maghrib Prayer' : 'صلاة المغرب');
  String get habitIsha => language == AppLanguage.turkish
      ? 'Yatsı Namazı'
      : (language == AppLanguage.english ? 'Isha Prayer' : 'صلاة العشاء');
  String get habitQuran => language == AppLanguage.turkish
      ? 'Günlük Kur\'an Tilaveti'
      : (language == AppLanguage.english ? 'Daily Quran Recitation' : 'تلاوة القرآن اليومية');
  String get habitZikr => language == AppLanguage.turkish
      ? 'Günlük Zikir & Tesbihat'
      : (language == AppLanguage.english ? 'Daily Dhikr & Tasbih' : 'الذكر والتسبيح اليومي');

  // Konum & Rekat & Zaman
  String get currentLocation => language == AppLanguage.turkish
      ? 'Mevcut Konum'
      : (language == AppLanguage.english ? 'Current Location' : 'الموقع الحالي');
  String rakatsCount(int count) => language == AppLanguage.turkish
      ? '$count Rekat'
      : (language == AppLanguage.english ? '$count Rakats' : '$count ركعات');
  String get rakatsSuffix => language == AppLanguage.turkish
      ? 'Rekat'
      : (language == AppLanguage.english ? 'Rakats' : 'ركعات');

  // 7/7 Görev Kutlama
  String dayTasksCompleted(int day) => language == AppLanguage.turkish
      ? '$day. Gün Görevi Tamamlandı! 🌟'
      : (language == AppLanguage.english
          ? 'Day $day Tasks Completed! 🌟'
          : 'اكتملت مهام اليوم $day! 🌟');
  String get allTasksCompletedMessage => language == AppLanguage.turkish
      ? 'Elhamdülillah! Bugünün 7 ibadet vazifesini eksiksiz ikmâl ettiniz.'
      : (language == AppLanguage.english
          ? 'Alhamdulillah! You have completed all 7 daily worship duties today.'
          : 'الحمد لله! لقد أتممت مهام العبادة الـ ٧ لليوم على أكمل وجه.');
  String get dailyCompletionVerseBadge => language == AppLanguage.turkish
      ? 'Günün Tebrik Âyeti'
      : (language == AppLanguage.english ? 'Daily Completion Verse' : 'آية الإتمام اليومية');
  String get anotherVerse => language == AppLanguage.turkish
      ? 'Başka Âyet'
      : (language == AppLanguage.english ? 'Another Verse' : 'آية أخرى');

  // Âyet Bildirim Sıklıkları (Saatte 2 kez, Her saat başı vs.)
  String get verseFreq2PerHour => language == AppLanguage.turkish
      ? 'Saatte 2 Kez (30 dk\'da bir)'
      : (language == AppLanguage.english
          ? '2 times per hour (Every 30 min)'
          : 'مرتان كل ساعة (كل ٣٠ دقيقة)');
  String get verseFreqHourly => language == AppLanguage.turkish
      ? 'Her Saat Başı'
      : (language == AppLanguage.english ? 'Every Hour' : 'كل ساعة');
  String get verseFreq2Hours => language == AppLanguage.turkish
      ? '2 Saatte Bir'
      : (language == AppLanguage.english ? 'Every 2 Hours' : 'كل ساعتين');
  String get verseFreqDaily => language == AppLanguage.turkish
      ? 'Günde 1 Vakit'
      : (language == AppLanguage.english ? 'Once Daily' : 'مرة واحدة يومياً');
  String get verseFreqMorningEvening => language == AppLanguage.turkish
      ? 'Sabah & Akşam'
      : (language == AppLanguage.english ? 'Morning & Evening' : 'صباحاً ومساءً');

  // Kilit Ekranı Widget Merkezi
  String get lockScreenWidgetsTitle => language == AppLanguage.turkish
      ? 'Kilit Ekranı Widget\'ları'
      : (language == AppLanguage.english
          ? 'Lock Screen Widgets'
          : 'مصغرات شاشة القفل');
  String trialActiveBanner(int days) => language == AppLanguage.turkish
      ? '3 Günlük Ücretsiz Deneme Aktif ($days Gün Kaldı)'
      : (language == AppLanguage.english
          ? '3-Day Free Trial Active ($days Days Left)'
          : 'الفترة التجريبية مجانية لـ ٣ أيام (متبقي $days أيام)');
  String get upgrade => language == AppLanguage.turkish
      ? 'Yükselt >'
      : (language == AppLanguage.english ? 'Upgrade >' : 'ترقية >');
  String get mockupDate => language == AppLanguage.turkish
      ? 'Pazartesi, 6 Haziran'
      : (language == AppLanguage.english ? 'Monday, June 6' : 'الإثنين، ٦ يونيو');
  String get previewAnotherVerse => language == AppLanguage.turkish
      ? 'Farklı Âyet Önizle'
      : (language == AppLanguage.english ? 'Preview Another Verse' : 'معاينة آية أخرى');
  String get widgetFeatureTitle => language == AppLanguage.turkish
      ? 'İslami Sözler, Dua ve Ayet'
      : (language == AppLanguage.english
          ? 'Islamic Quotes, Duas & Verses'
          : 'أقوال إسلامية وأدعية وآيات');
  String get widgetFeatureDesc => language == AppLanguage.turkish
      ? 'Telefonunuzun kilidini açmadan Kilit Ekranınızda Kur\'an ayetlerini ve İslami alıntıları görüntüleyin.'
      : (language == AppLanguage.english
          ? 'Display Quran verses and Islamic quotes on your Lock Screen without unlocking your phone.'
          : 'اعرض آيات القرآن والأدعية على شاشة القفل دون فتح قفل هاتفك.');
  String get displayCategories => language == AppLanguage.turkish
      ? 'Görüntülenecek Kategoriler'
      : (language == AppLanguage.english ? 'Display Categories' : 'الفئات المعروضة');
  String get allCategories => language == AppLanguage.turkish
      ? 'Tümü'
      : (language == AppLanguage.english ? 'All' : 'الكل');
  String get quoteRefreshInterval => language == AppLanguage.turkish
      ? 'Alıntı Yenileme Sıklığı'
      : (language == AppLanguage.english ? 'Quote Refresh Frequency' : 'تكرار تحديث الأقوال');
  String get textSize => language == AppLanguage.turkish
      ? 'Metin Boyutu'
      : (language == AppLanguage.english ? 'Text Size' : 'حجم النص');
  String get fontFamily => language == AppLanguage.turkish
      ? 'Yazı Tipi'
      : (language == AppLanguage.english ? 'Font Family' : 'نوع الخط');
  String get standard => language == AppLanguage.turkish
      ? 'Standart'
      : (language == AppLanguage.english ? 'Standard' : 'قياسي');
  String get features => language == AppLanguage.turkish
      ? 'Özellikler'
      : (language == AppLanguage.english ? 'Features' : 'المميزات');
  String get featCountdown => language == AppLanguage.turkish
      ? 'Sonraki namaza canlı geri sayım'
      : (language == AppLanguage.english
          ? 'Live countdown to next prayer'
          : 'عد تنازلي مباشر للصلاة القادمة');
  String get featCurrentPrayers => language == AppLanguage.turkish
      ? 'Mevcut ve yaklaşan namazları gösterir'
      : (language == AppLanguage.english
          ? 'Displays current and upcoming prayers'
          : 'عرض الصلوات الحالية والقادمة');
  String get featAutoUpdate => language == AppLanguage.turkish
      ? 'Her namaz vaktinde otomatik güncellenir'
      : (language == AppLanguage.english
          ? 'Updates automatically at every prayer time'
          : 'تحديث تلقائي مع دخول كل وقت صلاة');
  String get featBatterySave => language == AppLanguage.turkish
      ? '100% Çevrimdışı ve pil tasarruflu'
      : (language == AppLanguage.english
          ? '100% Offline and battery friendly'
          : '١٠٠٪ بدون إنترنت وموفر للبطارية');
  String get howToAddStep1 => language == AppLanguage.turkish
      ? 'Uygulamadan çıkın ve kilit ekranınıza gidin (telefonunuzu kilitleyin, ardından kilidini açmadan ekranı uyandırın).'
      : (language == AppLanguage.english
          ? 'Exit the app and go to your lock screen (lock your phone, then wake the screen without unlocking).'
          : 'اخرج من التطبيق وتوجه إلى شاشة القفل (اقفل هاتفك ثم أيقظ الشاشة دون إلغاء القفل).');
  String get howToAddStep2 => language == AppLanguage.turkish
      ? 'Kilit ekranına basılı tutun ve alttaki \'Özelleştir\' butonuna dokunun.'
      : (language == AppLanguage.english
          ? 'Press and hold your lock screen, then tap the \'Customize\' button at the bottom.'
          : 'اضغط مطولاً على شاشة القفل ثم اضغط زر \'تخصيص\' في الأسفل.');
  String get howToAddStep3 => language == AppLanguage.turkish
      ? 'Saat alanına veya altına dokunarak \'Beyân\' widget\'ını seçip kilit ekranınıza ekleyin.'
      : (language == AppLanguage.english
          ? 'Tap above or below the clock, select the \'Beyân\' widget, and add it to your lock screen.'
          : 'اضغط على مساحة الساعة واختر أداة \'بيان\' لإضافتها لشاشة القفل.');
  String get notificationSettings => language == AppLanguage.turkish
      ? 'Ezan & Âyet Bildirimleri'
      : (language == AppLanguage.english
          ? 'Prayer & Verse Notifications'
          : 'تنبيهات الأذان والآيات');
  String get verseNotificationsTitle => language == AppLanguage.turkish
      ? 'Günün Âyeti ve Sure Bildirimleri'
      : (language == AppLanguage.english
          ? 'Daily Verse & Surah Notifications'
          : 'تنبيهات آيات وسور اليوم');
}


