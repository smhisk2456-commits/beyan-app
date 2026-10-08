import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notifications/services/notification_service.dart';

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
      // Yeni dilde ayet bildirimlerini anında yeniden planla
      await NotificationService.instance.scheduleDailyVerseNotifications();
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
  String prayerTimesLoadError(Object error) => language == AppLanguage.turkish
      ? 'Vakitler yüklenemedi: $error'
      : (language == AppLanguage.english ? 'Could not load prayer times: $error' : 'تعذر تحميل أوقات الصلاة: $error');

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

  // Kısa namaz ismi kısayolları
  String get fajr => prayerNameFajr;
  String get sunrise => prayerNameSunrise;
  String get dhuhr => prayerNameDhuhr;
  String get asr => prayerNameAsr;
  String get maghrib => prayerNameMaghrib;
  String get isha => prayerNameIsha;

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

  // ── Paywall & Monetization Localization ──
  String get paywallTitle => language == AppLanguage.turkish
      ? 'Beyân Premium Ayrıcalıkları'
      : (language == AppLanguage.english
          ? 'Beyân Premium Privileges'
          : 'مميزات بيان بريميوم');
  String get paywallSubtitle => language == AppLanguage.turkish
      ? 'Kilit ekranı widget\'ları, tarihi ezan makamları ve huşû dolu bir deneyim.'
      : (language == AppLanguage.english
          ? 'Lock screen widgets, historical adhan makams, and a serene worship experience.'
          : 'أدوات شاشة القفل، ومقامات الأذان التاريخية، وتجربة عبادة خاشعة.');
  String get paywallFeatWidgets => language == AppLanguage.turkish
      ? 'Kilit Ekranı & Ana Ekran Widget\'ları'
      : (language == AppLanguage.english
          ? 'Lock Screen & Home Screen Widgets'
          : 'أدوات شاشة القفل والشاشة الرئيسية');
  String get paywallFeatWidgetsDesc => language == AppLanguage.turkish
      ? 'Canlı geri sayım, sonraki namaz vakti ve günün ayeti daima kilit ekranınızda.'
      : (language == AppLanguage.english
          ? 'Live countdown, next prayer time, and verse of the day always on your lock screen.'
          : 'عد تنازلي مباشر، وقت الصلاة القادمة، وآية اليوم دائماً على شاشة القفل.');
  String get paywallFeatMakams => language == AppLanguage.turkish
      ? 'Özel Ezan Makamları & Meşhur Müezzinler'
      : (language == AppLanguage.english
          ? 'Exclusive Adhan Makams & Muezzins'
          : 'مقامات الأذان الحصرية وأشهر المؤذنين');
  String get paywallFeatMakamsDesc => language == AppLanguage.turkish
      ? 'Mekke, Medine, Kudüs ve İstanbul (Saba, Hicaz, Rast) makamlarıyla vaktinde huzurlu çağrı.'
      : (language == AppLanguage.english
          ? 'Peaceful call to prayer with Mecca, Medina, Jerusalem, and Istanbul makams.'
          : 'نداء الصلاة الخاشع بمقامات مكة والمدينة والقدس وإسطنبول.');
  String get paywallFeatAdFree => language == AppLanguage.turkish
      ? '%100 Reklamsız & Huşû Dolu'
      : (language == AppLanguage.english
          ? '100% Ad-Free & Serene'
          : '١٠٠٪ خالي من الإعلانات وخاشع');
  String get paywallFeatAdFreeDesc => language == AppLanguage.turkish
      ? 'İbadetinizi ve zikrinizi bölen hiçbir reklam afişi olmadan kesintisiz tefekkür.'
      : (language == AppLanguage.english
          ? 'Uninterrupted reflection without any ads disturbing your worship and dhikr.'
          : 'تأمل دون انقطاع ودون أي إعلانات تعكر صفو عبادتك وأذكارك.');
  String get paywallFeatThemes => language == AppLanguage.turkish
      ? 'Özel Mushaf Hatları & OLED Temalar'
      : (language == AppLanguage.english
          ? 'Custom Quran Fonts & OLED Themes'
          : 'خطوط مصحف حصرية ومظاهر شاشات أوليد');
  String get paywallFeatThemesDesc => language == AppLanguage.turkish
      ? 'Gece Siyahı, Kâbe Taş Grisi ve altın varak kaplamalı huzurlu tasarımlar.'
      : (language == AppLanguage.english
          ? 'OLED Midnight Black, Kaaba Slate, and luxury gold leaf accents.'
          : 'الأسود الليلي، رمادي حجر الكعبة، ولمسات ذهبية فاخرة.');
  String get planYearly => language == AppLanguage.turkish
      ? 'Yıllık Plan'
      : (language == AppLanguage.english ? 'Annual Plan' : 'الخطة السنوية');
  String get planLifetime => language == AppLanguage.turkish
      ? 'Ömür Boyu Sahip Ol'
      : (language == AppLanguage.english ? 'Lifetime Access' : 'امتلاك مدى الحياة');
  String get planMonthly => language == AppLanguage.turkish
      ? 'Aylık Plan'
      : (language == AppLanguage.english ? 'Monthly Plan' : 'الخطة الشهرية');
  String get badgeMostPopular => language == AppLanguage.turkish
      ? 'EN POPÜLER'
      : (language == AppLanguage.english ? 'MOST POPULAR' : 'الأكثر طلباً');
  String get badgeBestValue => language == AppLanguage.turkish
      ? 'EN AVANTAJLI'
      : (language == AppLanguage.english ? 'BEST VALUE' : 'أفضل قيمة');
  String get badgeFreeTrial => language == AppLanguage.turkish
      ? '3 GÜN ÜCRETSİZ'
      : (language == AppLanguage.english ? '3 DAYS FREE' : '٣ أيام مجاناً');
  String get badgeNoSubscription => language == AppLanguage.turkish
      ? 'ABONELİK YOK'
      : (language == AppLanguage.english ? 'NO SUBSCRIPTION' : 'بدون اشتراك');
  String get btnStartTrial => language == AppLanguage.turkish
      ? '3 Günlük Ücretsiz Denemeyi Başlat'
      : (language == AppLanguage.english ? 'Start 3-Day Free Trial' : 'ابدأ التجربة المجانية لـ ٣ أيام');
  String get btnBuyLifetime => language == AppLanguage.turkish
      ? 'Ömür Boyu Erişimi Satın Al'
      : (language == AppLanguage.english ? 'Get Lifetime Access' : 'شراء مدى الحياة');
  String get btnStartMonthly => language == AppLanguage.turkish
      ? 'Aylık Aboneliği Başlat'
      : (language == AppLanguage.english ? 'Start Monthly Plan' : 'بدء الاشتراك الشهري');
  String get noPaymentNow => language == AppLanguage.turkish
      ? 'Şimdi Ödeme Yok • İstediğin Zaman İptal Et'
      : (language == AppLanguage.english
          ? 'No Payment Now • Cancel Anytime'
          : 'لا تدفع الآن • يمكنك الإلغاء في أي وقت');
  String get oneTimePaymentDesc => language == AppLanguage.turkish
      ? 'Tek seferlik ödeme • Sonsuza dek tüm kilitler açık'
      : (language == AppLanguage.english
          ? 'One-time payment • All features unlocked forever'
          : 'دفعة واحدة لمرة واحدة • فتح جميع الميزات إلى الأبد');
  String get restorePurchases => language == AppLanguage.turkish
      ? 'Satın Alımları Geri Yükle'
      : (language == AppLanguage.english ? 'Restore Purchases' : 'استعادة المشتريات');
  String get privacyPolicy => language == AppLanguage.turkish
      ? 'Gizlilik Politikası'
      : (language == AppLanguage.english ? 'Privacy Policy' : 'سياسة الخصوصية');
  String get termsOfUse => language == AppLanguage.turkish
      ? 'Kullanım Şartları (EULA)'
      : (language == AppLanguage.english ? 'Terms of Use (EULA)' : 'شروط الاستخدام');

  // ── Hicri Takvim & Dini Günler ─────────────────────────────────
  String get hijriCalendarTitle => language == AppLanguage.turkish
      ? 'Hicri Takvim & Dini Günler'
      : (language == AppLanguage.english
          ? 'Hijri Calendar & Sacred Days'
          : 'التقويم الهجري والأيام الدينية');
  String get hijriAdjustmentTooltip => language == AppLanguage.turkish
      ? 'Hicri Gün Düzeltmesi'
      : (language == AppLanguage.english ? 'Hijri Day Adjustment' : 'تعديل اليوم الهجري');
  String get diyanetTakvimi => language == AppLanguage.turkish
      ? 'Diyanet Takvimi'
      : (language == AppLanguage.english ? 'Presidency of Religious Affairs' : 'تقويم الشؤون الدينية');
  String adjustmentDaysLabel(int days) => language == AppLanguage.turkish
      ? 'Düzeltme: ${days > 0 ? "+$days" : days} gün'
      : (language == AppLanguage.english
          ? 'Adjustment: ${days > 0 ? "+$days" : days} days'
          : 'التعديل: $days يوم');
  String get gregorianPrefix => language == AppLanguage.turkish
      ? 'Miladi'
      : (language == AppLanguage.english ? 'Gregorian' : 'الميلادي');
  String get upcomingSacredDays => language == AppLanguage.turkish
      ? 'Yaklaşan Kandiller ve Dini Günler'
      : (language == AppLanguage.english
          ? 'Upcoming Holy Nights & Days'
          : 'المناسبات والأيام الدينية القادمة');
  String get hijriAdjustmentTitle => language == AppLanguage.turkish
      ? 'Hicri Takvim Düzeltmesi'
      : (language == AppLanguage.english ? 'Hijri Calendar Adjustment' : 'تعديل التقويم الهجري');
  String get hijriAdjustmentDesc => language == AppLanguage.turkish
      ? 'Hilalin yerel gözlemine göre Hicri tarihi +/- 1 veya 2 gün ileri/geri alabilirsiniz.'
      : (language == AppLanguage.english
          ? 'You can adjust the Hijri date by +/- 1 or 2 days according to local moon sighting.'
          : 'يمكنك تعديل التاريخ الهجري بـ +/- يوم أو يومين حسب رؤية الهلال المحلية.');
  String get standardLabel => language == AppLanguage.turkish
      ? 'Standart'
      : (language == AppLanguage.english ? 'Standard' : 'قياسي');
  String get daysRemainingUnit => language == AppLanguage.turkish
      ? 'GÜN'
      : (language == AppLanguage.english ? 'DAYS' : 'يوم');
  String get todayBadge => language == AppLanguage.turkish
      ? 'BUGÜN'
      : (language == AppLanguage.english ? 'TODAY' : 'اليوم');

  // ── Dua Kütüphanesi ────────────────────────────────────────────
  String get duaLibraryTitle => language == AppLanguage.turkish
      ? 'Dua Kütüphanesi'
      : (language == AppLanguage.english ? 'Dua Library' : 'مكتبة الأدعية');
  String get duaFilterTooltip => language == AppLanguage.turkish
      ? 'Kategori Filtresi'
      : (language == AppLanguage.english ? 'Category Filter' : 'تصفية الفئات');
  String get duaSearchHint => language == AppLanguage.turkish
      ? 'Dua, anlam veya kaynak ara...'
      : (language == AppLanguage.english
          ? 'Search dua, meaning or reference...'
          : 'ابحث عن دعاء أو معنى أو مصدر...');
  String allDuasWithCount(int count) => language == AppLanguage.turkish
      ? 'Tümü ($count)'
      : (language == AppLanguage.english ? 'All ($count)' : 'الكل ($count)');
  String get noDuaFound => language == AppLanguage.turkish
      ? 'Aramanıza uygun dua bulunamadı'
      : (language == AppLanguage.english ? 'No dua found matching your search' : 'لم يتم العثور على دعاء مطابق');
  String get addToFavorites => language == AppLanguage.turkish
      ? 'Favorilere Ekle'
      : (language == AppLanguage.english ? 'Add to Favorites' : 'إضافة إلى المفضلة');
  String get removeFromFavorites => language == AppLanguage.turkish
      ? 'Favorilerden Çıkar'
      : (language == AppLanguage.english ? 'Remove from Favorites' : 'إزالة من المفضلة');
  String get copyAndShare => language == AppLanguage.turkish
      ? 'Kopyala & Paylaş'
      : (language == AppLanguage.english ? 'Copy & Share' : 'نسخ ومشاركة');
  String get duaCopied => language == AppLanguage.turkish
      ? 'Dua panoya kopyalandı'
      : (language == AppLanguage.english ? 'Dua copied to clipboard' : 'تم نسخ الدعاء إلى الحافظة');
  String get transliterationLabel => language == AppLanguage.turkish
      ? 'Okunuşu'
      : (language == AppLanguage.english ? 'Pronunciation' : 'النطق');
  String get meaningLabel => language == AppLanguage.turkish
      ? 'Anlamı'
      : (language == AppLanguage.english ? 'Meaning' : 'المعنى');
  String get referenceLabel => language == AppLanguage.turkish
      ? 'Kaynak'
      : (language == AppLanguage.english ? 'Reference' : 'المصدر');
  String get appSignature => language == AppLanguage.turkish
      ? '— Beyân İslami Yaşam Uygulaması'
      : (language == AppLanguage.english ? '— Beyan Islamic Life App' : '— تطبيق بيان للحياة الإسلامية');
  String listenSurahRecitation(String surah) => language == AppLanguage.turkish
      ? '$surah Tilavetini Dinle'
      : (language == AppLanguage.english ? 'Listen to $surah' : 'استمع لتلاوة $surah');
  String get pauseRecitation => language == AppLanguage.turkish
      ? 'Tilaveti Duraklat'
      : (language == AppLanguage.english ? 'Pause Recitation' : 'إيقاف التلاوة مؤقتاً');
  String get resumeRecitation => language == AppLanguage.turkish
      ? 'Tilaveti Devam Ettir'
      : (language == AppLanguage.english ? 'Resume Recitation' : 'استئناف التلاوة');
  String get stopRecitation => language == AppLanguage.turkish
      ? 'Tilaveti Kapat'
      : (language == AppLanguage.english ? 'Close Recitation' : 'إغلاق التلاوة');

  // ── Kıble Pusulası ─────────────────────────────────────────────
  String get qiblaCompassTitle => language == AppLanguage.turkish
      ? 'Kıble Pusulası'
      : (language == AppLanguage.english ? 'Qibla Compass' : 'بوصلة القبلة');
  String kaabaDistance(int km) => language == AppLanguage.turkish
      ? 'Kâbe: $km km'
      : (language == AppLanguage.english ? 'Kaaba: $km km' : 'الكعبة: $km كم');
  String get compassSensorNotFound => language == AppLanguage.turkish
      ? 'Cihazınızda pusula sensörü (manyetometre) algılanamadı. Kıble açısı referans olarak gösterilmektedir.'
      : (language == AppLanguage.english
          ? 'Compass sensor (magnetometer) not detected on your device. Qibla angle is shown as reference.'
          : 'لم يتم اكتشاف مستشعر البوصلة في جهازك. تظهر زاوية القبلة كمرجع.');
  String get facingQibla => language == AppLanguage.turkish
      ? 'Kıbleye Yöneldiniz! 🕋'
      : (language == AppLanguage.english ? 'You are facing the Qibla! 🕋' : 'أنت باتجاه القبلة! 🕋');
  String turnRightDeg(int deg) => language == AppLanguage.turkish
      ? 'Sağa $deg° dönün'
      : (language == AppLanguage.english ? 'Turn right $deg°' : 'استدر يميناً $deg°');
  String turnLeftDeg(int deg) => language == AppLanguage.turkish
      ? 'Sola $deg° dönün'
      : (language == AppLanguage.english ? 'Turn left $deg°' : 'استدر يساراً $deg°');
  String get qiblaAngleTitle => language == AppLanguage.turkish
      ? 'Kıble Açısı'
      : (language == AppLanguage.english ? 'Qibla Angle' : 'زاوية القبلة');
  String get clockwiseFromNorth => language == AppLanguage.turkish
      ? 'Kuzeyden saat yönünde'
      : (language == AppLanguage.english ? 'Clockwise from North' : 'باتجاه عقارب الساعة من الشمال');
  String get deviceHeadingTitle => language == AppLanguage.turkish
      ? 'Cihaz Yönü'
      : (language == AppLanguage.english ? 'Device Heading' : 'اتجاه الجهاز');
  String get compassHoldFlatTip => language == AppLanguage.turkish
      ? 'Cihazınızı düz bir zeminde veya yatay tutarak kullanınız. Manyetik kılıflar pusulayı etkileyebilir.'
      : (language == AppLanguage.english
          ? 'Hold your device flat. Magnetic cases may affect the compass.'
          : 'أمسك جهازك بشكل مستوٍ. قد تؤثر الأغطية المغناطيسية على البوصلة.');
  String get compassCalibrationTitle => language == AppLanguage.turkish
      ? 'Pusula Kalibrasyonu'
      : (language == AppLanguage.english ? 'Compass Calibration' : 'معايرة البوصلة');
  String get compassCalibrationDesc => language == AppLanguage.turkish
      ? 'Telefon pusulasının doğru çalışması için:\n\n1. Cihazınızı havada yatay tutarak "8" şekli çizecek şekilde birkaç kez sallayınız.\n2. Metal veya mıknatıslı kılıflardan uzak tutunuz.\n3. Elektronik cihazların yanında manyetik sapma oluşabilir.'
      : (language == AppLanguage.english
          ? 'For accurate compass orientation:\n\n1. Wave your phone in a figure-8 motion.\n2. Keep away from magnetic or metal cases.\n3. Avoid electronic devices causing interference.'
          : 'لدقة البوصلة:\n\n١. حرّك هاتفك على شكل رقم ٨ في الهواء عدة مرات.\n٢. ابتعد عن الأغطية المعدنية أو المغناطيسية.\n٣. تجنب الأجهزة الإلكترونية المسببة للتداخل.');
  String get iUnderstand => language == AppLanguage.turkish
      ? 'Anladım'
      : (language == AppLanguage.english ? 'Got it' : 'فهمت');
  String get compassNorth => language == AppLanguage.turkish
      ? 'Kuzey (N)'
      : (language == AppLanguage.english ? 'North (N)' : 'الشمال (N)');
  String get compassNorthEast => language == AppLanguage.turkish
      ? 'Kuzeydoğu (NE)'
      : (language == AppLanguage.english ? 'Northeast (NE)' : 'الشمال الشرقي (NE)');
  String get compassEast => language == AppLanguage.turkish
      ? 'Doğu (E)'
      : (language == AppLanguage.english ? 'East (E)' : 'الشرق (E)');
  String get compassSouthEast => language == AppLanguage.turkish
      ? 'Güneydoğu (SE)'
      : (language == AppLanguage.english ? 'Southeast (SE)' : 'الجنوب الشرقي (SE)');
  String get compassSouth => language == AppLanguage.turkish
      ? 'Güney (S)'
      : (language == AppLanguage.english ? 'South (S)' : 'الجنوب (S)');
  String get compassSouthWest => language == AppLanguage.turkish
      ? 'Güneybatı (SW)'
      : (language == AppLanguage.english ? 'Southwest (SW)' : 'الجنوب الغربي (SW)');
  String get compassWest => language == AppLanguage.turkish
      ? 'Batı (W)'
      : (language == AppLanguage.english ? 'West (W)' : 'الغرب (W)');
  String get compassNorthWest => language == AppLanguage.turkish
      ? 'Kuzeybatı (NW)'
      : (language == AppLanguage.english ? 'Northwest (NW)' : 'الشمال الغربي (NW)');

  // ── Ramazan Dashboard ──────────────────────────────────────────
  String get holyRamadan => language == AppLanguage.turkish
      ? 'Ramazan-ı Şerif'
      : (language == AppLanguage.english ? 'Holy Ramadan' : 'رمضان المبارك');
  String get todayFastingStatus => language == AppLanguage.turkish
      ? 'Bugünkü Oruç Durumu'
      : (language == AppLanguage.english ? 'Today\'s Fasting Status' : 'حالة صيام اليوم');
  String get fastingActiveMsg => language == AppLanguage.turkish
      ? 'Bugün oruçlusunuz (Allah kabul etsin)'
      : (language == AppLanguage.english
          ? 'You are fasting today (May Allah accept)'
          : 'أنت صائم اليوم (تقبل الله)');
  String get fastingInactiveMsg => language == AppLanguage.turkish
      ? 'Oruç tutulmadı olarak işaretli'
      : (language == AppLanguage.english ? 'Marked as not fasting' : 'غير محدد كصائم');
  String get totalFastingStatus => language == AppLanguage.turkish
      ? 'Toplam Oruç Durumu'
      : (language == AppLanguage.english ? 'Total Fasting Days' : 'إجمالي أيام الصيام');
  String get totalFastingDesc => language == AppLanguage.turkish
      ? 'Ramazan, Kaza ve Nafile günleri'
      : (language == AppLanguage.english
          ? 'Ramadan, missed & voluntary fasts'
          : 'أيام رمضان والقضاء والتطوع');
  String get decrementDayTooltip => language == AppLanguage.turkish
      ? '1 Gün Eksilt'
      : (language == AppLanguage.english ? 'Decrease 1 Day' : 'إنقاص يوم');
  String get incrementDayTooltip => language == AppLanguage.turkish
      ? '1 Gün Ekle'
      : (language == AppLanguage.english ? 'Increase 1 Day' : 'إضافة يوم');
  String fastingDaysCount(int count) => language == AppLanguage.turkish
      ? '$count gün'
      : (language == AppLanguage.english ? '$count days' : '$count يوم');
  String get sunnahRamadanDuas => language == AppLanguage.turkish
      ? 'Sünnet İftar & Sahur Duaları'
      : (language == AppLanguage.english ? 'Sunnah Iftar & Suhoor Duas' : 'أدعية الإفطار والسحور المأثورة');
  String get remainingUntilIftar => language == AppLanguage.turkish
      ? 'İftar Vaktine Kalan Süre'
      : (language == AppLanguage.english ? 'Time Remaining Until Iftar' : 'الوقت المتبقي حتى الإفطار');
  String get remainingUntilSuhoor => language == AppLanguage.turkish
      ? 'Sahur / İmsak Vaktine Kalan'
      : (language == AppLanguage.english ? 'Time Remaining Until Suhoor' : 'الوقت المتبقي حتى السحور');
  String get remainingUntilTomorrowSuhoor => language == AppLanguage.turkish
      ? 'Yarınki Sahura Kalan'
      : (language == AppLanguage.english ? 'Remaining Until Tomorrow\'s Suhoor' : 'المتبقي حتى سحور الغد');
  String get hoursUnit => language == AppLanguage.turkish
      ? 'SAAT'
      : (language == AppLanguage.english ? 'HOURS' : 'ساعة');
  String get minsUnit => language == AppLanguage.turkish
      ? 'DAKİKA'
      : (language == AppLanguage.english ? 'MINUTES' : 'دقيقة');
  String get secsUnit => language == AppLanguage.turkish
      ? 'SANİYE'
      : (language == AppLanguage.english ? 'SECONDS' : 'ثانية');
  String get imsakSuhoorLabel => language == AppLanguage.turkish
      ? 'İmsak (Sahur)'
      : (language == AppLanguage.english ? 'Imsak (Suhoor)' : 'الإمساك (السحور)');
  String get maghribIftarLabel => language == AppLanguage.turkish
      ? 'Akşam (İftar)'
      : (language == AppLanguage.english ? 'Maghrib (Iftar)' : 'المغرب (الإفطار)');

  // ── Tema ve Görünüm ────────────────────────────────────────────
  String get appearanceAndTheme => language == AppLanguage.turkish
      ? 'Görünüm & Tema'
      : (language == AppLanguage.english ? 'Appearance & Theme' : 'المظهر والسمة');
  String get appearanceDesc => language == AppLanguage.turkish
      ? 'Uygulamanın renk ve karanlık mod tercihlerini özelleştirin'
      : (language == AppLanguage.english
          ? 'Customize color palettes and dark mode preferences'
          : 'خصص خيارات الألوان والوضع الليلي للتطبيق');
  String get appearanceModeSection => language == AppLanguage.turkish
      ? 'GÖRÜNÜM MODU'
      : (language == AppLanguage.english ? 'APPEARANCE MODE' : 'وضع المظهر');
  String get modeLight => language == AppLanguage.turkish
      ? 'Açık'
      : (language == AppLanguage.english ? 'Light' : 'فاتح');
  String get modeDark => language == AppLanguage.turkish
      ? 'Koyu'
      : (language == AppLanguage.english ? 'Dark' : 'داكن');
  String get modeSystem => language == AppLanguage.turkish
      ? 'Sistem'
      : (language == AppLanguage.english ? 'System' : 'تلقائي');
  String get colorPaletteSection => language == AppLanguage.turkish
      ? 'RENK PALETİ'
      : (language == AppLanguage.english ? 'COLOR PALETTE' : 'لوحة الألوان');

  // ── Bildirim Ayarları ──────────────────────────────────────────
  String get adhanSettingsTitle => language == AppLanguage.turkish
      ? 'Ezan & Vakit Bildirimleri'
      : (language == AppLanguage.english ? 'Adhan & Prayer Alerts' : 'تنبيهات الأذان والصلوات');
  String get adhanSettingsDesc => language == AppLanguage.turkish
      ? 'Namaz vakitlerinde ezan ve uyarı bildirimleri'
      : (language == AppLanguage.english
          ? 'Adhan and notifications at prayer times'
          : 'الأذان والإشعارات في أوقات الصلاة');
  String get permRequiredTitle => language == AppLanguage.turkish
      ? 'Cihaz Bildirim İzni Kapalı'
      : (language == AppLanguage.english ? 'Device Notifications Disabled' : 'إشعارات الجهاز معطلة');
  String get permRequiredDesc => language == AppLanguage.turkish
      ? 'Ezan vaktinde bildirim alabilmek için sistem ayarlarından izin vermelisiniz.'
      : (language == AppLanguage.english
          ? 'Enable notifications in system settings to receive adhan alerts.'
          : 'يجب تفعيل الإشعارات في إعدادات النظام لتلقي تنبيهات الأذان.');
  String get grantPermissionBtn => language == AppLanguage.turkish
      ? 'İzin Ver'
      : (language == AppLanguage.english ? 'Grant Permission' : 'منح الإذن');
  String get allNotifications => language == AppLanguage.turkish
      ? 'Tüm Bildirimler'
      : (language == AppLanguage.english ? 'All Notifications' : 'جميع الإشعارات');
  String get enableAllNotificationsDesc => language == AppLanguage.turkish
      ? 'Ezan ve namaz bildirimlerini etkinleştir'
      : (language == AppLanguage.english
          ? 'Enable prayer and adhan notifications'
          : 'تفعيل إشعارات الأذان والصلاة');
  String get earlyReminderTitle => language == AppLanguage.turkish
      ? '15 Dakika Önce Hatırlat'
      : (language == AppLanguage.english ? 'Remind 15 Mins Before' : 'تنبيه قبل ١٥ دقيقة');
  String get earlyReminderDesc => language == AppLanguage.turkish
      ? 'Vakit girmeden önce erken uyarı bildirimi'
      : (language == AppLanguage.english
          ? 'Early notification before prayer time begins'
          : 'تنبيه مبكر قبل دخول وقت الصلاة');
  String get adhanMakamToneTitle => language == AppLanguage.turkish
      ? 'Ezan Makamı & Ses Tonu'
      : (language == AppLanguage.english ? 'Adhan Makam & Tone' : 'مقام الأذان والنغمة');
  String get changeBtn => language == AppLanguage.turkish
      ? 'Değiştir'
      : (language == AppLanguage.english ? 'Change' : 'تغيير');
  String get sectionPrayerAlerts => language == AppLanguage.turkish
      ? 'VAKİT BİLDİRİMLERİ'
      : (language == AppLanguage.english ? 'PRAYER ALERTS' : 'تنبيهات الصلوات');
  String get sectionVerseAlerts => language == AppLanguage.turkish
      ? 'GÜNÜN ÂYETİ VE SURE BİLDİRİMLERİ'
      : (language == AppLanguage.english ? 'VERSE & SURAH ALERTS' : 'تنبيهات آيات اليوم وسوره');
  String get verseReminderTitle => language == AppLanguage.turkish
      ? 'Âyet & Sure Hatırlatıcı'
      : (language == AppLanguage.english ? 'Verse & Surah Reminder' : 'مذكر الآيات والسور');
  String get verseReminderDesc => language == AppLanguage.turkish
      ? 'Her gün tefekkür ve manevi uyanış bildirimi'
      : (language == AppLanguage.english
          ? 'Daily reflection and spiritual inspiration notification'
          : 'إشعار يومي للتأمل والاستلهام الإيماني');
  String get notificationScheduleTitle => language == AppLanguage.turkish
      ? 'Bildirim Saati / Zamanı'
      : (language == AppLanguage.english ? 'Notification Schedule' : 'جدول الإشعارات');
  String get testVerseBtn => language == AppLanguage.turkish
      ? 'Âyet Bildirimini Şimdi Test Et'
      : (language == AppLanguage.english ? 'Test Verse Alert Now' : 'اختبار إشعار الآية الآن');
  String get testAdhanBtn => language == AppLanguage.turkish
      ? 'Ezan Test Bildirimi Gönder'
      : (language == AppLanguage.english ? 'Send Test Adhan Alert' : 'إرسال إشعار أذان تجريبي');
  String get testVerseSuccessMsg => language == AppLanguage.turkish
      ? 'Günün Âyeti test bildirimi cihazınıza gönderildi!'
      : (language == AppLanguage.english
          ? 'Test verse notification sent to your device!'
          : 'تم إرسال إشعار آية تجريبي إلى جهازك!');
  String get testAdhanSuccessMsg => language == AppLanguage.turkish
      ? 'Test bildirimi cihazınıza gönderildi!'
      : (language == AppLanguage.english
          ? 'Test notification sent to your device!'
          : 'تم إرسال الإشعار التجريبي إلى جهازك!');
  String get permWarningMsg => language == AppLanguage.turkish
      ? 'Cihaz bildirim izni kapalı! Lütfen ayarlardan izin verin.'
      : (language == AppLanguage.english
          ? 'Device notifications disabled! Please allow from settings.'
          : 'إشعارات الجهاز معطلة! يرجى السماح بها من الإعدادات.');
  String get fajrDesc => language == AppLanguage.turkish
      ? 'İmsak vakti girdiğinde ezan bildirimi'
      : (language == AppLanguage.english
          ? 'Adhan alert when Fajr begins'
          : 'إشعار الأذان عند دخول وقت الفجر');
  String get sunriseDesc => language == AppLanguage.turkish
      ? 'Güneş doğuş vakti uyarısı'
      : (language == AppLanguage.english ? 'Sunrise time reminder' : 'تنبيه وقت شروق الشمس');
  String get dhuhrDesc => language == AppLanguage.turkish
      ? 'Öğle ezanı bildirimi'
      : (language == AppLanguage.english ? 'Dhuhr adhan notification' : 'إشعار أذان الظهر');
  String get asrDesc => language == AppLanguage.turkish
      ? 'İkindi ezanı bildirimi'
      : (language == AppLanguage.english ? 'Asr adhan notification' : 'إشعار أذان العصر');
  String get maghribDesc => language == AppLanguage.turkish
      ? 'Akşam ezanı bildirimi'
      : (language == AppLanguage.english ? 'Maghrib adhan notification' : 'إشعار أذان المغرب');
  String get ishaDesc => language == AppLanguage.turkish
      ? 'Yatsı ezanı bildirimi'
      : (language == AppLanguage.english ? 'Isha adhan notification' : 'إشعار أذان العشاء');

  // ── Ezan Makamları Sayfası ────────────────────────────────────
  String get adhanMakamsAndAudio => language == AppLanguage.turkish
      ? 'Ezan Makamları & Ses Tonu'
      : (language == AppLanguage.english ? 'Adhan Makams & Tones' : 'مقامات الأذان والأصوات');
  String get adhanMakamsDesc => language == AppLanguage.turkish
      ? 'Namaz vaktinde çalınacak ezan sesini seçin ve dinleyin'
      : (language == AppLanguage.english
          ? 'Select and preview adhan tones for prayer times'
          : 'اختر واستمع لصوت الأذان عند دخول الصلاة');
  String get stopAudio => language == AppLanguage.turkish
      ? 'Durdur'
      : (language == AppLanguage.english ? 'Stop' : 'إيقاف');
  String get listenAudio => language == AppLanguage.turkish
      ? 'Dinle'
      : (language == AppLanguage.english ? 'Listen' : 'استماع');
  String get specialAdhanMakamsPro => language == AppLanguage.turkish
      ? 'Özel Ezan Makamları & Müezzinler'
      : (language == AppLanguage.english
          ? 'Special Adhan Makams & Muezzins'
          : 'مقامات الأذان الخاصة والمؤذنون');
  String get specialAdhanMakamsProDesc => language == AppLanguage.turkish
      ? 'Mekke, Medine ve İstanbul ezan makamları'
      : (language == AppLanguage.english
          ? 'Mecca, Medina, and Istanbul adhan tones'
          : 'أذان مكة المكرمة والمدينة المنورة وإسطنبول');
  String get proMakamExclusiveNotice => language == AppLanguage.turkish
      ? 'ezan makamı Beyân Premium ayrıcalığıdır.'
      : (language == AppLanguage.english
          ? 'adhan tone is a Beyân Premium exclusive.'
          : 'متاح حصرياً لمشتركي بيان بريميوم.');
  String get makamProBannerHint => language == AppLanguage.turkish
      ? 'Mekke & Medine makamlarını dinleyin; aktif ezan tonu yapmak için Premium\'a geçin.'
      : (language == AppLanguage.english
          ? 'Preview Mecca & Medina adhans; upgrade to Premium to set as your adhan tone.'
          : 'استمع لأذان مكة والمدينة؛ اشترك في بريميوم لتعيينهما كنغمة للأذان.');
  String get unlockMakamWithPremium => language == AppLanguage.turkish
      ? 'Premium ile Kilidi Aç'
      : (language == AppLanguage.english
          ? 'Unlock with Premium'
          : 'فتح القفل مع بريميوم');

  // ── Hesaplama Yöntemi & Şehir Seçici ──────────────────────────
  String get calculationMethodTitle => language == AppLanguage.turkish
      ? 'Hesaplama Yöntemi'
      : (language == AppLanguage.english ? 'Calculation Method' : 'طريقة الحساب');
  String get calculationMethodDesc => language == AppLanguage.turkish
      ? 'Vakit hesaplarında yetkili kurum ve fetva meclisleri'
      : (language == AppLanguage.english
          ? 'Authorized institutions for prayer time calculation'
          : 'الهيئات والمجالس الإفتائية المعتمدة لمواقيت الصلاة');
  String get cityLocationTitle => language == AppLanguage.turkish
      ? 'Şehir ve Konum Seçimi'
      : (language == AppLanguage.english ? 'Select City & Location' : 'اختيار المدينة والموقع');
  String get autoGpsTitle => language == AppLanguage.turkish
      ? 'Otomatik GPS Konumu'
      : (language == AppLanguage.english ? 'Automatic GPS Location' : 'الموقع التلقائي عبر GPS');
  String get autoGpsDesc => language == AppLanguage.turkish
      ? 'Cihazınızın anlık konumunu otomatik kullanır'
      : (language == AppLanguage.english
          ? 'Automatically uses your current location'
          : 'يستخدم موقع جهازك الحالي تلقائياً');
  String get searchCityHint => language == AppLanguage.turkish
      ? 'Şehir veya ülke ara...'
      : (language == AppLanguage.english ? 'Search city or country...' : 'ابحث عن مدينة أو دولة...');

  // ── Kur'an & Okuma ─────────────────────────────────────────────
  String get resumeReading => language == AppLanguage.turkish
      ? 'Kaldığım Yerden Devam Et'
      : (language == AppLanguage.english ? 'Continue Reading' : 'متابعة القراءة من حيث توقفت');
  String get arabicFontSizeTitle => language == AppLanguage.turkish
      ? 'Arapça Yazı Boyutu'
      : (language == AppLanguage.english ? 'Arabic Font Size' : 'حجم الخط العربي');
  String get reciterSelectionTitle => language == AppLanguage.turkish
      ? 'Kâri (Tilavet Okuyucusu) Seçimi'
      : (language == AppLanguage.english ? 'Select Reciter (Qari)' : 'اختيار القارئ');
  String get reciterSelectionTooltip => language == AppLanguage.turkish
      ? 'Kâri Seçimi'
      : (language == AppLanguage.english ? 'Select Reciter' : 'اختيار القارئ');
  String get fontSizeTooltip => language == AppLanguage.turkish
      ? 'Yazı Boyutu'
      : (language == AppLanguage.english ? 'Font Size' : 'حجم الخط');
  String get listenSurahTooltip => language == AppLanguage.turkish
      ? 'Sureyi Dinle'
      : (language == AppLanguage.english ? 'Listen to Surah' : 'استمع للسورة');
  String get versesLoading => language == AppLanguage.turkish
      ? 'Ayetler yükleniyor...'
      : (language == AppLanguage.english ? 'Loading verses...' : 'جاري تحميل الآيات...');
  String get versesLoadError => language == AppLanguage.turkish
      ? 'Ayetler yüklenemedi.'
      : (language == AppLanguage.english ? 'Could not load verses.' : 'تعذر تحميل الآيات.');
  String surahNumberBadge(int id) => language == AppLanguage.turkish
      ? '$id. Sure'
      : (language == AppLanguage.english ? 'Surah $id' : 'سورة $id');
  String get lastReadBadge => language == AppLanguage.turkish
      ? 'KALDIĞIM YER'
      : (language == AppLanguage.english ? 'LAST READ' : 'حيث توقفت');
  String get saveAsLastRead => language == AppLanguage.turkish
      ? 'Kaldığım Yer Olarak Kaydet'
      : (language == AppLanguage.english ? 'Save as Last Read' : 'حفظ كموضع توقف');
  String get addBookmark => language == AppLanguage.turkish
      ? 'Yer İmine Ekle'
      : (language == AppLanguage.english ? 'Add to Bookmarks' : 'إضافة للإشارات');
  String get removeBookmark => language == AppLanguage.turkish
      ? 'Yer İmini Kaldır'
      : (language == AppLanguage.english ? 'Remove Bookmark' : 'إزالة الإشارة');
  String get shareVerse => language == AppLanguage.turkish
      ? 'Ayeti Paylaş'
      : (language == AppLanguage.english ? 'Share Verse' : 'مشاركة الآية');
  String verseCopied(String ref) => language == AppLanguage.turkish
      ? '$ref. Ayet kopyalandı'
      : (language == AppLanguage.english ? 'Verse $ref copied' : 'تم نسخ الآية $ref');
  String get seekBackward10s => language == AppLanguage.turkish
      ? '10 Saniye Geri'
      : (language == AppLanguage.english ? 'Rewind 10 Seconds' : 'رجوع ١٠ ثوانٍ');
  String get seekForward10s => language == AppLanguage.turkish
      ? '10 Saniye İleri'
      : (language == AppLanguage.english ? 'Forward 10 Seconds' : 'تقديم ١٠ ثوانٍ');
  String recitationOfSurah(String surah) => language == AppLanguage.turkish
      ? '$surah Tilaveti'
      : (language == AppLanguage.english ? 'Recitation of $surah' : 'تلاوة $surah');
  String get closeBtn => language == AppLanguage.turkish
      ? 'Kapat'
      : (language == AppLanguage.english ? 'Close' : 'إغلاق');
}




