import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notifications/services/notification_service.dart';
import 'translations/de_strings.dart';
import 'translations/fr_strings.dart';
import 'translations/id_strings.dart';
import 'translations/ru_strings.dart';
import 'translations/ur_strings.dart';

/// Desteklenen diller
enum AppLanguage {
  turkish('tr', 'Türkçe', 'TR', '🇹🇷'),
  english('en', 'English', 'EN', '🇬🇧'),
  arabic('ar', 'العربية', 'AR', '🇸🇦'),
  indonesian('id', 'Bahasa Indonesia', 'ID', '🇮🇩'),
  french('fr', 'Français', 'FR', '🇫🇷'),
  urdu('ur', 'اردو', 'UR', '🇵🇰'),
  german('de', 'Deutsch', 'DE', '🇩🇪'),
  russian('ru', 'Русский', 'RU', '🇷🇺');

  final String code;
  final String displayName;
  final String shortCode;
  final String flag;

  const AppLanguage(this.code, this.displayName, this.shortCode, this.flag);

  Locale get locale => Locale(code);
  bool get isRTL => this == AppLanguage.arabic || this == AppLanguage.urdu;

  static AppLanguage fromCode(String code) {
    switch (code) {
      case 'en':
        return AppLanguage.english;
      case 'ar':
        return AppLanguage.arabic;
      case 'id':
        return AppLanguage.indonesian;
      case 'fr':
        return AppLanguage.french;
      case 'ur':
        return AppLanguage.urdu;
      case 'de':
        return AppLanguage.german;
      case 'ru':
        return AppLanguage.russian;
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
      // Yeni dilde hem namaz hem ayet bildirimlerini anında yeniden planla
      await NotificationService.instance.scheduleUpcomingPrayers();
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

  String _t(String key, String tr, String en, String ar) {
    switch (language) {
      case AppLanguage.turkish:
        return tr;
      case AppLanguage.english:
        return en;
      case AppLanguage.arabic:
        return ar;
      case AppLanguage.indonesian:
        return idStrings[key] ?? en;
      case AppLanguage.french:
        return frStrings[key] ?? en;
      case AppLanguage.urdu:
        return urStrings[key] ?? ar;
      case AppLanguage.german:
        return deStrings[key] ?? en;
      case AppLanguage.russian:
        return ruStrings[key] ?? en;
    }
  }

  // ── Genel & Başlıklar ──────────────────────────────────────────
  String get appName => 'Beyân';
  String get bismillah => 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  String get bismillahTransliteration => 'Bismillâhirrahmânirrahîm';
  String get done => _t('done', 'Tamam', 'Done', 'تم');
  String get cancel => _t('cancel', 'Vazgeç', 'Cancel', 'إلغاء');
  String get close => _t('close', 'Kapat', 'Close', 'إغلاق');
  String get settings => _t('settings', 'Ayarlar', 'Settings', 'الإعدادات');
  String get languageSelect => _t('languageSelect', 'Dil Seçimi', 'Language', 'اللغة');

  // ── Alt Navigasyon (Dock) ──────────────────────────────────────
  String get tabHome => _t('tabHome', 'Ana Sayfa', 'Home', 'الرئيسية');
  String get tabPrayers => _t('tabPrayers', 'Vakitler', 'Prayers', 'المواقيت');
  String get tabQuran => _t('tabQuran', 'Kur\'an', 'Quran', 'القرآن');
  String get tabZikr => _t('tabZikr', 'Zikirmatik', 'Tasbih', 'المسبحة');
  String get tabWidget => _t('tabWidget', 'Widget', 'Widget', 'الأدوات');

  // ── Hızlı Erişim Butonları ─────────────────────────────────────
  String get actionLastRead => _t('actionLastRead', 'Kaldığım Yer', 'Last Read', 'حيث توقفت');
  String get actionLastReadSub => _t('actionLastReadSub', 'Fâtiha', 'Al-Fatiha', 'الفاتحة');

  String get actionQibla => _t('actionQibla', 'Kıble', 'Qibla', 'القبلة');
  String get actionQiblaSub => _t('actionQiblaSub', '152° GB', '152° SE', '١٥٢° ج.ش');

  String get actionZikr => _t('actionZikr', 'Zikirmatik', 'Tasbih', 'المسبحة');
  String get actionZikrSub => _t('actionZikrSub', 'Tesbihat', 'Dhikr', 'أذكار');

  String get actionWidget => _t('actionWidget', 'Kilit Ekranı', 'Lock Screen', 'شاشة القفل');
  String get actionWidgetSub => _t('actionWidgetSub', 'Canlı Widget', 'Live Widget', 'أداة حية');

  // ── Namaz Vakitleri & Rekatlar ──────────────────────────────────
  String get nextPrayer => _t('nextPrayer', 'Sıradaki Namaz', 'Next Prayer', 'الصلاة القادمة');
  String get currentPrayer => _t('currentPrayer', 'Şu anki vakit', 'Current Prayer', 'الوقت الحالي');
  String get remainingTime => _t('remainingTime', 'kaldı', 'left', 'متبقي');
  String get dailyPrayers => _t('dailyPrayers', 'Günlük Vakitler', 'Daily Times', 'مواقيت اليوم');
  String get updateLocation => _t('updateLocation', 'Konumu Güncelle', 'Update Location', 'تحديث الموقع');
  String get diyanetMethod => _t('diyanetMethod', 'Diyanet Takvimi', 'Diyanet Method', 'تقويم ديانت');
  String get nextPrayerLabel => _t('nextPrayerLabel', 'Sıradaki', 'Next', 'القادمة');
    String prayerTimesLoadError(Object error) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Vakitler yüklenemedi: $error';
      case AppLanguage.english:
        return 'Could not load prayer times: $error';
      case AppLanguage.arabic:
        return 'تعذر تحميل أوقات الصلاة: $error';
      case AppLanguage.indonesian:
        return 'Gagal memuat jadwal sholat: $error';
      case AppLanguage.french:
        return 'Impossible de charger les horaires de prière : $error';
      case AppLanguage.urdu:
        return 'نماز کے اوقات لوڈ نہیں ہو سکے: $error';
      case AppLanguage.german:
        return 'Gebetszeiten konnten nicht geladen werden: $error';
      case AppLanguage.russian:
        return 'Не удалось загрузить время намаза: $error';
    }
  }

  // Namaz İsimleri
  String get prayerNameFajr => _t('prayerNameFajr', 'İmsak', 'Fajr', 'الفجر');
  String get prayerNameSunrise => _t('prayerNameSunrise', 'Güneş', 'Sunrise', 'الشروق');
  String get prayerNameDhuhr => _t('prayerNameDhuhr', 'Öğle', 'Dhuhr', 'الظهر');
  String get prayerNameAsr => _t('prayerNameAsr', 'İkindi', 'Asr', 'العصر');
  String get prayerNameMaghrib => _t('prayerNameMaghrib', 'Akşam', 'Maghrib', 'المغرب');
  String get prayerNameIsha => _t('prayerNameIsha', 'Yatsı', 'Isha', 'العشاء');

  // Kısa namaz ismi kısayolları
  String get fajr => prayerNameFajr;
  String get sunrise => prayerNameSunrise;
  String get dhuhr => prayerNameDhuhr;
  String get asr => prayerNameAsr;
  String get maghrib => prayerNameMaghrib;
  String get isha => prayerNameIsha;

  // Rekat Detayları
  String get rakatFajr => _t('rakatFajr', '4 Rekat (2 Sünnet + 2 Farz)', '4 Rakats (2 Sunnah + 2 Fard)', '٤ ركعات (٢ سنة + ٢ فرض)');

  String get rakatSunrise => _t('rakatSunrise', 'Kerâhet Vakti / Güneş Doğuşu', 'Sunrise (Restricted Time)', 'شروق الشمس (وقت الكراهة)');

  String get rakatDhuhr => _t('rakatDhuhr', '10 Rekat (4 Sünnet + 4 Farz + 2 Sünnet)', '10 Rakats (4 Sunnah + 4 Fard + 2 Sunnah)', '١٠ ركعات (٤ سنة + ٤ فرض + ٢ سنة)');

  String get rakatAsr => _t('rakatAsr', '8 Rekat (4 Sünnet + 4 Farz)', '8 Rakats (4 Sunnah + 4 Fard)', '٨ ركعات (٤ سنة + ٤ فرض)');

  String get rakatMaghrib => _t('rakatMaghrib', '5 Rekat (3 Farz + 2 Sünnet)', '5 Rakats (3 Fard + 2 Sunnah)', '٥ ركعات (٣ فرض + ٢ سنة)');

  String get rakatIsha => _t('rakatIsha', '13 Rekat (4 Sünnet + 4 Farz + 2 Sünnet + 3 Vitir)', '13 Rakats (4 Sunnah + 4 Fard + 2 Sunnah + 3 Witr)', '١٣ ركعة (٤ سنة + ٤ فرض + ٢ سنة + ٣ وتر)');

  // ── Kur'an & Arama ─────────────────────────────────────────────
  String get quranTitle => _t('quranTitle', 'Kur\'an-ı Kerim', 'The Holy Quran', 'القرآن الكريم');
  String get searchSurahPlaceholder => _t('searchSurahPlaceholder', 'Sure ara... (yasin, ihlas, 36...)', 'Search surah... (yasin, ikhlas, 36...)', 'ابحث عن سورة... (يس، الإخلاص، ٣٦...)');
  String get searchResults => _t('searchResults', 'Arama Sonuçları', 'Search Results', 'نتائج البحث');
  String get noSurahFound => _t('noSurahFound', 'Sure bulunamadı', 'No surah found', 'لم يتم العثور على سورة');
  String get totalSurahs => _t('totalSurahs', '114 Sure', '114 Surahs', '١١٤ سورة');
    String surahBadge(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return '$count ayet';
      case AppLanguage.english:
        return '$count verses';
      case AppLanguage.arabic:
        return '$count آية';
      case AppLanguage.indonesian:
        return '$count ayat';
      case AppLanguage.french:
        return '$count versets';
      case AppLanguage.urdu:
        return '$count آیات';
      case AppLanguage.german:
        return '$count Verse';
      case AppLanguage.russian:
        return '$count аятов';
    }
  }
    String surahNumber(int num) {
    switch (language) {
      case AppLanguage.turkish:
        return '$num. Sure';
      case AppLanguage.english:
        return 'Surah $num';
      case AppLanguage.arabic:
        return 'سورة $num';
      case AppLanguage.indonesian:
        return 'Surah $num';
      case AppLanguage.french:
        return 'Sourate $num';
      case AppLanguage.urdu:
        return 'سورہ $num';
      case AppLanguage.german:
        return 'Sure $num';
      case AppLanguage.russian:
        return 'Сура $num';
    }
  }
  String get makki => _t('makki', 'Mekki', 'Makki', 'مكية');
  String get madani => _t('madani', 'Medeni', 'Madani', 'مدنية');

  // ── Zikirmatik ─────────────────────────────────────────────────
  String get zikirmatikTitle => _t('zikirmatikTitle', 'Zikirmatik', 'Digital Tasbih', 'المسبحة الإلكترونية');
  String get zikirmatikInstruction => _t('zikirmatikInstruction', 'Dokunarak tesbihat çekebilirsiniz', 'Tap circle to count dhikr', 'اضغط على الدائرة للتسبيح');
    String targetLabel(int target) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Hedef: $target';
      case AppLanguage.english:
        return 'Target: $target';
      case AppLanguage.arabic:
        return 'الهدف: $target';
      case AppLanguage.indonesian:
        return 'Target: $target';
      case AppLanguage.french:
        return 'Objectif : $target';
      case AppLanguage.urdu:
        return 'ہدف: $target';
      case AppLanguage.german:
        return 'Ziel: $target';
      case AppLanguage.russian:
        return 'Цель: $target';
    }
  }

  // ── Kıble ──────────────────────────────────────────────────────
  String get qiblaTitle => _t('qiblaTitle', 'Kıble Yönü', 'Qibla Direction', 'اتجاه القبلة');
  String get qiblaAngleText => _t('qiblaAngleText', 'İstanbul için Kıble Açısı: 152° Güneydoğu', 'Qibla Angle for Istanbul: 152° Southeast', 'زاوية القبلة لإسطنبول: ١٥٢° جنوب شرق');
  String get qiblaInstruction => _t('qiblaInstruction', 'Cihazınızı yatay tutarak pusulayı Kâbe yönüne hizalayabilirsiniz.', 'Hold your device flat to align with the Kaaba.', 'أمسك جهازك بشكل أفقي لتوجيه البوصلة نحو الكعبة المشرفة.');

  // ── Kilit Ekranı & Widget ──────────────────────────────────────
  String get widgetCenterTitle => _t('widgetCenterTitle', 'Kilit Ekranı & Widget', 'Lock Screen & Widget', 'شاشة القفل والمصغرات');
  String get widgetPreviewTitle => _t('widgetPreviewTitle', 'Kilit Ekranı Canlı Görünümü', 'Lock Screen Live Preview', 'معاينة شاشة القفل');
  String get widgetIntervalTitle => _t('widgetIntervalTitle', 'Ayet Değişim Sıklığı', 'Verse Refresh Interval', 'تكرار تغيير الآيات');
  String get widgetIntervalDesc => _t('widgetIntervalDesc', 'Kilit ekranınızdaki ve ana ekranınızdaki ayetlerin ne kadar sürede bir otomatik değişeceğini belirleyin:', 'Select how frequently verses update automatically on your lock and home screens:', 'حدد مدى تكرار تغيير الآيات تلقائيًا على شاشة القفل والشاشة الرئيسية:');
  String get refreshVerseNow => _t('refreshVerseNow', 'Hemen Yeni Bir Ayet Yansıt', 'Refresh Verse Now', 'تحديث الآية الآن');
  String get howToAdd => _t('howToAdd', 'Nasıl Eklenir?', 'How to Add?', 'كيفية الإضافة؟');
  String get iphoneGuideTitle => _t('iphoneGuideTitle', 'iPhone Kilit Ekranı', 'iPhone Lock Screen', 'شاشة قفل iPhone');
  String get iphoneGuideDesc => _t('iphoneGuideDesc', 'Kilit ekranına basılı tutun, "Özelleştir" > "Widget Ekle" deyip Beyân uygulamasını seçin.', 'Press & hold lock screen, tap Customize > Add Widgets, and select Beyân.', 'اضغط مطولاً على شاشة القفل، ثم اضغط تخصيص > إضافة أداة، واختر تطبيق بيان.');
  String get androidGuideTitle => _t('androidGuideTitle', 'Android Ana Ekranı', 'Android Home Screen', 'شاشة Android الرئيسية');
  String get androidGuideDesc => _t('androidGuideDesc', 'Ana ekranda boş bir yere basılı tutun, "Widgets" bölümünden Beyân seçin.', 'Long press on home screen, select Widgets, and choose Beyân.', 'اضغط مطولاً على الشاشة الرئيسية، افتح الأدوات (Widgets) واختر بيان.');
    String minutesSuffix(int m) {
    switch (language) {
      case AppLanguage.turkish:
        return '$m Dakika';
      case AppLanguage.english:
        return '$m Minutes';
      case AppLanguage.arabic:
        return '$m دقيقة';
      case AppLanguage.indonesian:
        return '$m Menit';
      case AppLanguage.french:
        return '$m minutes';
      case AppLanguage.urdu:
        return '$m منٹ';
      case AppLanguage.german:
        return '$m Minuten';
      case AppLanguage.russian:
        return '$m минут';
    }
  }
    String minutesShort(int m) {
    switch (language) {
      case AppLanguage.turkish:
        return '$m dk';
      case AppLanguage.english:
        return '$m min';
      case AppLanguage.arabic:
        return '$m د';
      case AppLanguage.indonesian:
        return '$m mnt';
      case AppLanguage.french:
        return '$m min';
      case AppLanguage.urdu:
        return '$m منٹ';
      case AppLanguage.german:
        return '$m Min.';
      case AppLanguage.russian:
        return '$m мин';
    }
  }

  // ── Hızlı Erişim Butonları Ek Çeviriler ────────────────────────
  String get actionPrayersSub => _t('actionPrayersSub', '6 Vakit', '6 Prayers', '٦ مواقيت');
  String get actionQuranSub => _t('actionQuranSub', '114 Sure', '114 Surahs', '١١٤ سورة');
  String get actionDuas => _t('actionDuas', 'Dualar', 'Duas', 'الأدعية');
  String get actionDuasSub => _t('actionDuasSub', 'Kütüphane', 'Library', 'المكتبة');
  String get actionCalendar => _t('actionCalendar', 'Hicri Takvim', 'Hijri Calendar', 'التقويم الهجري');
  String get actionCalendarSub => _t('actionCalendarSub', 'Kandiller', 'Holy Days', 'المناسبات');
  String get actionRamadan => _t('actionRamadan', 'Ramazan', 'Ramadan', 'رمضان');
  String get actionRamadanSub => _t('actionRamadanSub', 'İftar/Sahur', 'Iftar/Suhoor', 'إفطار وسحور');

  // ── Günlük Kartlar ─────────────────────────────────────────────
  String get dailyVerseTitle => _t('dailyVerseTitle', 'Günün Ayet-i Kerimesi', 'Daily Quran Verse', 'آية اليوم');
  String get dailyDuaTitle => _t('dailyDuaTitle', 'Günün Niyazı ve Duası', 'Daily Supplication', 'دعاء اليوم');
  String get allDuasLink => _t('allDuasLink', 'Tüm Dualar ➔', 'All Duas ➔', 'جميع الأدعية ➔');

  // ── Günün Âyeti Bildirimleri ────────────────────────────────────
  String get verseNotifTitle => _t('verseNotifTitle', 'Günün Âyeti & Sure Bildirimleri', 'Daily Verse & Surah Reminders', 'تنبيهات آيات وسور اليوم');
  String get verseNotifDesc => _t('verseNotifDesc', 'Her gün belirlenen saatte ilham veren bir âyet ve tefekkür bildirimi alın', 'Receive inspiring Quranic verses and spiritual reminders daily', 'احصل يوميًا على آيات قرآنية ملهمة وتأملات إيمانية');
  String get verseNotifTime => _t('verseNotifTime', 'Bildirim Saati', 'Reminder Time', 'وقت التنبيه');
  String get verseNotifFrequency => _t('verseNotifFrequency', 'Gönderim Sıklığı', 'Frequency', 'تكرار التنبيه');
  String get verseNotifFreqDaily => _t('verseNotifFreqDaily', 'Günde 1 Kez', 'Once Daily', 'مرة واحدة يومياً');
  String get verseNotifFreqMorningEvening => _t('verseNotifFreqMorningEvening', 'Sabah & Akşam', 'Morning & Evening', 'صباحاً ومساءً');
  String get verseNotifTestBtn => _t('verseNotifTestBtn', 'Âyet Bildirimini Test Et', 'Test Verse Reminder', 'اختبار إشعار الآية');
  String get verseNotifTestSuccess => _t('verseNotifTestSuccess', 'Test âyet bildirimi cihazınıza gönderildi!', 'Test verse notification sent to your device!', 'تم إرسال إشعار الآية التجريبي إلى جهازك!');

  // ── Ana Sayfa Ek Çeviriler ─────────────────────────────────────
  String get continueReadingQuran => _t('continueReadingQuran', 'Kur\'an-ı Kerim Okumaya Devam Et', 'Continue Reading Quran', 'متابعة تلاوة القرآن الكريم');
    String surahVerseLabel(String surahName, int verseNumber) {
    switch (language) {
      case AppLanguage.turkish:
        return '$surahName Suresi • $verseNumber. Âyet';
      case AppLanguage.english:
        return 'Surah $surahName • Verse $verseNumber';
      case AppLanguage.arabic:
        return 'سورة $surahName • آية $verseNumber';
      case AppLanguage.indonesian:
        return 'Surah $surahName • Ayat $verseNumber';
      case AppLanguage.french:
        return 'Sourate $surahName • Verset $verseNumber';
      case AppLanguage.urdu:
        return 'سورہ $surahName • آیت $verseNumber';
      case AppLanguage.german:
        return 'Sure $surahName • Vers $verseNumber';
      case AppLanguage.russian:
        return 'Сура $surahName • Аят $verseNumber';
    }
  }
  String get today => _t('today', 'Bugün!', 'Today!', 'اليوم!');
    String daysRemainingText(int days) {
    switch (language) {
      case AppLanguage.turkish:
        return '$days gün kaldı';
      case AppLanguage.english:
        return '$days days left';
      case AppLanguage.arabic:
        return '$days أيام متبقية';
      case AppLanguage.indonesian:
        return 'Tersisa $days hari';
      case AppLanguage.french:
        return '$days jours restants';
      case AppLanguage.urdu:
        return '$days دن باقی';
      case AppLanguage.german:
        return 'Noch $days Tage';
      case AppLanguage.russian:
        return 'Осталось $days дн.';
    }
  }
  String get calendarArrow => _t('calendarArrow', 'Takvim ➔', 'Calendar ➔', 'التقويم ➔');

  // ── Zikirmatik & İbadet Takibi Ek Çeviriler ──────────────────
  String get tapToCount => _t('tapToCount', 'DOKUN', 'TAP', 'اضغط');
  String get undo => _t('undo', 'Geri Al', 'Undo', 'تراجع');
  String get reset => _t('reset', 'Sıfırla', 'Reset', 'إعادة ضبط');
  String get resetConfirmTitle => _t('resetConfirmTitle', 'Zikri Sıfırla', 'Reset Dhikr', 'إعادة ضبط الذكر');
  String get resetConfirmDesc => _t('resetConfirmDesc', 'Mevcut sayımı ve tur sayısını sıfırlamak istiyor musunuz?', 'Do you want to reset current count and completed laps?', 'هل ترغب في إعادة ضبط العداد الحالي والدورات المكتملة؟');
    String lapsText(int laps) {
    switch (language) {
      case AppLanguage.turkish:
        return '$laps Tur';
      case AppLanguage.english:
        return '$laps Laps';
      case AppLanguage.arabic:
        return '$laps دورات';
      case AppLanguage.indonesian:
        return '$laps Putaran';
      case AppLanguage.french:
        return '$laps tours';
      case AppLanguage.urdu:
        return '$laps چکر';
      case AppLanguage.german:
        return '$laps Runden';
      case AppLanguage.russian:
        return '$laps кругов';
    }
  }
  String get worshipTrackerTab => _t('worshipTrackerTab', 'İbadet Takibi', 'Worship Tracker', 'متابعة العبادات');
  String get addCustomDhikr => _t('addCustomDhikr', 'Özel Zikir Ekle', 'Add Custom Dhikr', 'إضافة ذكر مخصص');
  String get customDhikrTitleHint => _t('customDhikrTitleHint', 'Zikir Başlığı (Örn: Lâ Havle...)', 'Dhikr Title (e.g., La Hawla...)', 'عنوان الذكر (مثل: لا حول ولا قوة...)');
  String get customDhikrMeaningHint => _t('customDhikrMeaningHint', 'Anlamı veya Niyeti', 'Meaning or Intention', 'المعنى أو النية');
  String get add => _t('add', 'Ekle', 'Add', 'إضافة');

  // Dokunma Hissi (Haptic Feedback)
  String get hapticTitle => _t('hapticTitle', 'Titreşim / Dokunuş Hissi', 'Haptic Feedback', 'الاهتزاز اللمسي');
  String get hapticLight => _t('hapticLight', 'Hafif', 'Light', 'خفيف');
  String get hapticMedium => _t('hapticMedium', 'Orta', 'Medium', 'متوسط');
  String get hapticHeavy => _t('hapticHeavy', 'Güçlü', 'Heavy', 'قوي');
  String get hapticOff => _t('hapticOff', 'Kapalı', 'Off', 'إيقاف');

  // Seri ve İbadet Alışkanlıkları
    String streakDaysTitle(int days) {
    switch (language) {
      case AppLanguage.turkish:
        return '$days. Gün Serisi';
      case AppLanguage.english:
        return '$days Days Streak';
      case AppLanguage.arabic:
        return 'سلسلة $days أيام';
      case AppLanguage.indonesian:
        return 'Rangkaian $days Hari';
      case AppLanguage.french:
        return 'Série de $days jours';
      case AppLanguage.urdu:
        return '$days دنوں کا تسلسل';
      case AppLanguage.german:
        return '$days-Tage-Serie';
      case AppLanguage.russian:
        return 'Серия: $days дн.';
    }
  }
  String get startStreak => _t('startStreak', 'Günlük Seri Başlat', 'Start Daily Streak', 'ابدأ السلسلة اليومية');
  String get todayAllTasksDone => _t('todayAllTasksDone', '✨ Bugünkü görevler tamamlandı!', '✨ All tasks completed for today!', '✨ اكتملت جميع مهام اليوم!');
    String remainingTasksText(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Bugün için $count görev kaldı';
      case AppLanguage.english:
        return '$count tasks remaining today';
      case AppLanguage.arabic:
        return 'متبقي اليوم $count مهام';
      case AppLanguage.indonesian:
        return 'Tersisa $count tugas hari ini';
      case AppLanguage.french:
        return '$count tâches restantes aujourd\'hui';
      case AppLanguage.urdu:
        return 'آج کے $count فرائض باقی ہیں';
      case AppLanguage.german:
        return 'Noch $count Aufgaben heute';
      case AppLanguage.russian:
        return 'Осталось $count заданий на сегодня';
    }
  }
    String bestStreakLabel(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return 'En İyi: $count';
      case AppLanguage.english:
        return 'Best: $count';
      case AppLanguage.arabic:
        return 'الأفضل: $count';
      case AppLanguage.indonesian:
        return 'Terbaik: $count';
      case AppLanguage.french:
        return 'Meilleur : $count';
      case AppLanguage.urdu:
        return 'بہترین: $count';
      case AppLanguage.german:
        return 'Rekord: $count';
      case AppLanguage.russian:
        return 'Лучшая: $count';
    }
  }
    String targetMilestoneLabel(String name) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Hedef: $name';
      case AppLanguage.english:
        return 'Target: $name';
      case AppLanguage.arabic:
        return 'الهدف: $name';
      case AppLanguage.indonesian:
        return 'Target: $name';
      case AppLanguage.french:
        return 'Objectif : $name';
      case AppLanguage.urdu:
        return 'ہدف: $name';
      case AppLanguage.german:
        return 'Ziel: $name';
      case AppLanguage.russian:
        return 'Цель: $name';
    }
  }
  String get spiritualRewardsBtn => _t('spiritualRewardsBtn', 'Motive Edici Sureler & Ödüller', 'Spiritual Surahs & Rewards', 'سور التحفيز والجوائز الروحانية');

  // İbadet Başlıkları
  String get habitFajr => _t('habitFajr', 'Sabah Namazı', 'Fajr Prayer', 'صلاة الفجر');
  String get habitDhuhr => _t('habitDhuhr', 'Öğle Namazı', 'Dhuhr Prayer', 'صلاة الظهر');
  String get habitAsr => _t('habitAsr', 'İkindi Namazı', 'Asr Prayer', 'صلاة العصر');
  String get habitMaghrib => _t('habitMaghrib', 'Akşam Namazı', 'Maghrib Prayer', 'صلاة المغرب');
  String get habitIsha => _t('habitIsha', 'Yatsı Namazı', 'Isha Prayer', 'صلاة العشاء');
  String get habitQuran => _t('habitQuran', 'Günlük Kur\'an Tilaveti', 'Daily Quran Recitation', 'تلاوة القرآن اليومية');
  String get habitZikr => _t('habitZikr', 'Günlük Zikir & Tesbihat', 'Daily Dhikr & Tasbih', 'الذكر والتسبيح اليومي');

  // Konum & Rekat & Zaman
  String get currentLocation => _t('currentLocation', 'Mevcut Konum', 'Current Location', 'الموقع الحالي');
    String rakatsCount(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return '$count Rekat';
      case AppLanguage.english:
        return '$count Rakats';
      case AppLanguage.arabic:
        return '$count ركعات';
      case AppLanguage.indonesian:
        return '$count Rakaat';
      case AppLanguage.french:
        return '$count Rakats';
      case AppLanguage.urdu:
        return '$count رکعتیں';
      case AppLanguage.german:
        return '$count Raka\'at';
      case AppLanguage.russian:
        return '$count ракаатов';
    }
  }
  String get rakatsSuffix => _t('rakatsSuffix', 'Rekat', 'Rakats', 'ركعات');

  // 7/7 Görev Kutlama
    String dayTasksCompleted(int day) {
    switch (language) {
      case AppLanguage.turkish:
        return '$day. Gün Görevi Tamamlandı! 🌟';
      case AppLanguage.english:
        return 'Day $day Tasks Completed! 🌟';
      case AppLanguage.arabic:
        return 'اكتملت مهام اليوم $day! 🌟';
      case AppLanguage.indonesian:
        return 'Tugas Hari ke-$day Selesai! 🌟';
      case AppLanguage.french:
        return 'Tâches du jour $day accomplies ! 🌟';
      case AppLanguage.urdu:
        return 'دن $day کے فرائض مکمل ہو گئے! 🌟';
      case AppLanguage.german:
        return 'Aufgaben für Tag $day erledigt! 🌟';
      case AppLanguage.russian:
        return 'Задания дня $day выполнены! 🌟';
    }
  }
  String get allTasksCompletedMessage => _t('allTasksCompletedMessage', 'Elhamdülillah! Bugünün 7 ibadet vazifesini eksiksiz ikmâl ettiniz.', 'Alhamdulillah! You have completed all 7 daily worship duties today.', 'الحمد لله! لقد أتممت مهام العبادة الـ ٧ لليوم على أكمل وجه.');
  String get dailyCompletionVerseBadge => _t('dailyCompletionVerseBadge', 'Günün Tebrik Âyeti', 'Daily Completion Verse', 'آية الإتمام اليومية');
  String get anotherVerse => _t('anotherVerse', 'Başka Âyet', 'Another Verse', 'آية أخرى');

  // Âyet Bildirim Sıklıkları (Saatte 2 kez, Her saat başı vs.)
  String get verseFreq2PerHour => _t('verseFreq2PerHour', 'Saatte 2 Kez (30 dk\'da bir)', '2 times per hour (Every 30 min)', 'مرتان كل ساعة (كل ٣٠ دقيقة)');
  String get verseFreqHourly => _t('verseFreqHourly', 'Her Saat Başı', 'Every Hour', 'كل ساعة');
  String get verseFreq2Hours => _t('verseFreq2Hours', '2 Saatte Bir', 'Every 2 Hours', 'كل ساعتين');
  String get verseFreqDaily => _t('verseFreqDaily', 'Günde 1 Vakit', 'Once Daily', 'مرة واحدة يومياً');
  String get verseFreqMorningEvening => _t('verseFreqMorningEvening', 'Sabah & Akşam', 'Morning & Evening', 'صباحاً ومساءً');

  // Kilit Ekranı Widget Merkezi
  String get lockScreenWidgetsTitle => _t('lockScreenWidgetsTitle', 'Kilit Ekranı Widget\'ları', 'Lock Screen Widgets', 'مصغرات شاشة القفل');
    String trialActiveBanner(int days) {
    switch (language) {
      case AppLanguage.turkish:
        return '3 Günlük Ücretsiz Deneme Aktif ($days Gün Kaldı)';
      case AppLanguage.english:
        return '3-Day Free Trial Active ($days Days Left)';
      case AppLanguage.arabic:
        return 'الفترة التجريبية مجانية لـ ٣ أيام (متبقي $days أيام)';
      case AppLanguage.indonesian:
        return 'Uji Coba Gratis 3 Hari Aktif (Tersisa $days Hari)';
      case AppLanguage.french:
        return 'Essai gratuit de 3 jours actif ($days jours restants)';
      case AppLanguage.urdu:
        return '۳ روزہ مفت ٹرائل فعال ہے ($days دن باقی)';
      case AppLanguage.german:
        return '3 Tage kostenlos testen aktiv (Noch $days Tage)';
      case AppLanguage.russian:
        return 'Бесплатный период 3 дня активен (осталось $days дн.)';
    }
  }
  String get upgrade => _t('upgrade', 'Yükselt >', 'Upgrade >', 'ترقية >');
  String get mockupDate => _t('mockupDate', 'Pazartesi, 6 Haziran', 'Monday, June 6', 'الإثنين، ٦ يونيو');
  String get previewAnotherVerse => _t('previewAnotherVerse', 'Farklı Âyet Önizle', 'Preview Another Verse', 'معاينة آية أخرى');
  String get widgetFeatureTitle => _t('widgetFeatureTitle', 'İslami Sözler, Dua ve Ayet', 'Islamic Quotes, Duas & Verses', 'أقوال إسلامية وأدعية وآيات');
  String get widgetFeatureDesc => _t('widgetFeatureDesc', 'Telefonunuzun kilidini açmadan Kilit Ekranınızda Kur\'an ayetlerini ve İslami alıntıları görüntüleyin.', 'Display Quran verses and Islamic quotes on your Lock Screen without unlocking your phone.', 'اعرض آيات القرآن والأدعية على شاشة القفل دون فتح قفل هاتفك.');
  String get displayCategories => _t('displayCategories', 'Görüntülenecek Kategoriler', 'Display Categories', 'الفئات المعروضة');
  String get allCategories => _t('allCategories', 'Tümü', 'All', 'الكل');
  String get quoteRefreshInterval => _t('quoteRefreshInterval', 'Alıntı Yenileme Sıklığı', 'Quote Refresh Frequency', 'تكرار تحديث الأقوال');
  String get textSize => _t('textSize', 'Metin Boyutu', 'Text Size', 'حجم النص');
  String get fontFamily => _t('fontFamily', 'Yazı Tipi', 'Font Family', 'نوع الخط');
  String get standard => _t('standard', 'Standart', 'Standard', 'قياسي');
  String get features => _t('features', 'Özellikler', 'Features', 'المميزات');
  String get featCountdown => _t('featCountdown', 'Sonraki namaza canlı geri sayım', 'Live countdown to next prayer', 'عد تنازلي مباشر للصلاة القادمة');
  String get featCurrentPrayers => _t('featCurrentPrayers', 'Mevcut ve yaklaşan namazları gösterir', 'Displays current and upcoming prayers', 'عرض الصلوات الحالية والقادمة');
  String get featAutoUpdate => _t('featAutoUpdate', 'Her namaz vaktinde otomatik güncellenir', 'Updates automatically at every prayer time', 'تحديث تلقائي مع دخول كل وقت صلاة');
  String get featBatterySave => _t('featBatterySave', '100% Çevrimdışı ve pil tasarruflu', '100% Offline and battery friendly', '١٠٠٪ بدون إنترنت وموفر للبطارية');
  String get howToAddStep1 => _t('howToAddStep1', 'Uygulamadan çıkın ve kilit ekranınıza gidin (telefonunuzu kilitleyin, ardından kilidini açmadan ekranı uyandırın).', 'Exit the app and go to your lock screen (lock your phone, then wake the screen without unlocking).', 'اخرج من التطبيق وتوجه إلى شاشة القفل (اقفل هاتفك ثم أيقظ الشاشة دون إلغاء القفل).');
  String get howToAddStep2 => _t('howToAddStep2', 'Kilit ekranına basılı tutun ve alttaki \'Özelleştir\' butonuna dokunun.', 'Press and hold your lock screen, then tap the \'Customize\' button at the bottom.', 'اضغط مطولاً على شاشة القفل ثم اضغط زر \'تخصيص\' في الأسفل.');
  String get howToAddStep3 => _t('howToAddStep3', 'Saat alanına veya altına dokunarak \'Beyân\' widget\'ını seçip kilit ekranınıza ekleyin.', 'Tap above or below the clock, select the \'Beyân\' widget, and add it to your lock screen.', 'اضغط على مساحة الساعة واختر أداة \'بيان\' لإضافتها لشاشة القفل.');
  String get notificationSettings => _t('notificationSettings', 'Ezan & Âyet Bildirimleri', 'Prayer & Verse Notifications', 'تنبيهات الأذان والآيات');
  String get verseNotificationsTitle => _t('verseNotificationsTitle', 'Günün Âyeti ve Sure Bildirimleri', 'Daily Verse & Surah Notifications', 'تنبيهات آيات وسور اليوم');

  // ── Paywall & Monetization Localization ──
  String get paywallTitle => _t('paywallTitle', 'Beyân Premium Ayrıcalıkları', 'Beyân Premium Privileges', 'مميزات بيان بريميوم');
  String get paywallSubtitle => _t('paywallSubtitle', 'Kilit ekranı widget\'ları, tarihi ezan makamları ve huşû dolu bir deneyim.', 'Lock screen widgets, historical adhan makams, and a serene worship experience.', 'أدوات شاشة القفل، ومقامات الأذان التاريخية، وتجربة عبادة خاشعة.');
  String get paywallFeatWidgets => _t('paywallFeatWidgets', 'Kilit Ekranı & Ana Ekran Widget\'ları', 'Lock Screen & Home Screen Widgets', 'أدوات شاشة القفل والشاشة الرئيسية');
  String get paywallFeatWidgetsDesc => _t('paywallFeatWidgetsDesc', 'Canlı geri sayım, sonraki namaz vakti ve günün ayeti daima kilit ekranınızda.', 'Live countdown, next prayer time, and verse of the day always on your lock screen.', 'عد تنازلي مباشر، وقت الصلاة القادمة، وآية اليوم دائماً على شاشة القفل.');
  String get paywallFeatMakams => _t('paywallFeatMakams', 'Özel Ezan Makamları & Meşhur Müezzinler', 'Exclusive Adhan Makams & Muezzins', 'مقامات الأذان الحصرية وأشهر المؤذنين');
  String get paywallFeatMakamsDesc => _t('paywallFeatMakamsDesc', 'Mekke, Medine, Kudüs ve İstanbul (Saba, Hicaz, Rast) makamlarıyla vaktinde huzurlu çağrı.', 'Peaceful call to prayer with Mecca, Medina, Jerusalem, and Istanbul makams.', 'نداء الصلاة الخاشع بمقامات مكة والمدينة والقدس وإسطنبول.');
  String get paywallFeatAdFree => _t('paywallFeatAdFree', '%100 Reklamsız & Huşû Dolu', '100% Ad-Free & Serene', '١٠٠٪ خالي من الإعلانات وخاشع');
  String get paywallFeatAdFreeDesc => _t('paywallFeatAdFreeDesc', 'İbadetinizi ve zikrinizi bölen hiçbir reklam afişi olmadan kesintisiz tefekkür.', 'Uninterrupted reflection without any ads disturbing your worship and dhikr.', 'تأمل دون انقطاع ودون أي إعلانات تعكر صفو عبادتك وأذكارك.');
  String get paywallFeatThemes => _t('paywallFeatThemes', 'Özel Mushaf Hatları & OLED Temalar', 'Custom Quran Fonts & OLED Themes', 'خطوط مصحف حصرية ومظاهر شاشات أوليد');
  String get paywallFeatThemesDesc => _t('paywallFeatThemesDesc', 'Gece Siyahı, Kâbe Taş Grisi ve altın varak kaplamalı huzurlu tasarımlar.', 'OLED Midnight Black, Kaaba Slate, and luxury gold leaf accents.', 'الأسود الليلي، رمادي حجر الكعبة، ولمسات ذهبية فاخرة.');
  String get paywallFeatSupport => _t('paywallFeatSupport', 'İslami Yazılıma Hâmî Olun', 'Support Islamic Software Development', 'دعم تطوير البرمجيات الإسلامية');
  String get paywallFeatSupportDesc => _t('paywallFeatSupportDesc', 'Bağımsız Türk yazılımcılarına ve vakıf ruhuna doğrudan destek verin.', 'Directly support independent developers building ad-free Islamic tech.', 'دعم المطورين المستقلين في بناء برمجيات إسلامية نقية.');
  String get paywallActiveDesc => _t('paywallActiveDesc', 'Tüm ayrıcalıklar aktif! Desteğiniz için teşekkür ederiz.', 'All privileges are active! Thank you for your support.', 'جميع الميزات مفعلة! شكرًا لدعمكم الكريم.');
  String get paywallInactiveDesc => _t('paywallInactiveDesc', 'Huzurlu, reklamsız ve ayrıcalıklı bir ibadet deneyimi.', 'Peaceful, ad-free and privileged worship experience.', 'تجربة عبادة هادئة وخالية من الإعلانات ومميزة.');
  String get planYearly => _t('planYearly', 'Yıllık Plan', 'Annual Plan', 'الخطة السنوية');
  String get planLifetime => _t('planLifetime', 'Ömür Boyu Sahip Ol', 'Lifetime Access', 'امتلاك مدى الحياة');
  String get planMonthly => _t('planMonthly', 'Aylık Plan', 'Monthly Plan', 'الخطة الشهرية');
  String get badgeMostPopular => _t('badgeMostPopular', 'EN POPÜLER', 'MOST POPULAR', 'الأكثر طلباً');
  String get badgeBestValue => _t('badgeBestValue', 'EN AVANTAJLI', 'BEST VALUE', 'أفضل قيمة');
  String get badgeFreeTrial => _t('badgeFreeTrial', '3 GÜN ÜCRETSİZ', '3 DAYS FREE', '٣ أيام مجاناً');
  String get badgeNoSubscription => _t('badgeNoSubscription', 'ABONELİK YOK', 'NO SUBSCRIPTION', 'بدون اشتراك');
  String get btnStartTrial => _t('btnStartTrial', '3 Günlük Ücretsiz Denemeyi Başlat', 'Start 3-Day Free Trial', 'ابدأ التجربة المجانية لـ ٣ أيام');
  String get btnBuyLifetime => _t('btnBuyLifetime', 'Ömür Boyu Erişimi Satın Al', 'Get Lifetime Access', 'شراء مدى الحياة');
  String get btnStartMonthly => _t('btnStartMonthly', 'Aylık Aboneliği Başlat', 'Start Monthly Plan', 'بدء الاشتراك الشهري');
  String get noPaymentNow => _t('noPaymentNow', 'Şimdi Ödeme Yok • İstediğin Zaman İptal Et', 'No Payment Now • Cancel Anytime', 'لا تدفع الآن • يمكنك الإلغاء في أي وقت');
  String get oneTimePaymentDesc => _t('oneTimePaymentDesc', 'Tek seferlik ödeme • Sonsuza dek tüm kilitler açık', 'One-time payment • All features unlocked forever', 'دفعة واحدة لمرة واحدة • فتح جميع الميزات إلى الأبد');
  String get restorePurchases => _t('restorePurchases', 'Satın Alımları Geri Yükle', 'Restore Purchases', 'استعادة المشتريات');
  String get privacyPolicy => _t('privacyPolicy', 'Gizlilik Politikası', 'Privacy Policy', 'سياسة الخصوصية');
  String get termsOfUse => _t('termsOfUse', 'Kullanım Şartları (EULA)', 'Terms of Use (EULA)', 'شروط الاستخدام');

  // ── Hicri Takvim & Dini Günler ─────────────────────────────────
  String get hijriCalendarTitle => _t('hijriCalendarTitle', 'Hicri Takvim & Dini Günler', 'Hijri Calendar & Sacred Days', 'التقويم الهجري والأيام الدينية');
  String get hijriAdjustmentTooltip => _t('hijriAdjustmentTooltip', 'Hicri Gün Düzeltmesi', 'Hijri Day Adjustment', 'تعديل اليوم الهجري');
  String get diyanetTakvimi => _t('diyanetTakvimi', 'Diyanet Takvimi', 'Presidency of Religious Affairs', 'تقويم الشؤون الدينية');
    String adjustmentDaysLabel(int days) {
    final sign = days > 0 ? '+$days' : '$days';
    switch (language) {
      case AppLanguage.turkish:
        return 'Düzeltme: $sign gün';
      case AppLanguage.english:
        return 'Adjustment: $sign days';
      case AppLanguage.arabic:
        return 'التعديل: $days يوم';
      case AppLanguage.indonesian:
        return 'Penyesuaian: $sign hari';
      case AppLanguage.french:
        return 'Ajustement : $sign jours';
      case AppLanguage.urdu:
        return 'ترمیم: $sign دن';
      case AppLanguage.german:
        return 'Anpassung: $sign Tage';
      case AppLanguage.russian:
        return 'Коррекция: $sign дн.';
    }
  }
  String get gregorianPrefix => _t('gregorianPrefix', 'Miladi', 'Gregorian', 'الميلادي');
  String get upcomingSacredDays => _t('upcomingSacredDays', 'Yaklaşan Kandiller ve Dini Günler', 'Upcoming Holy Nights & Days', 'المناسبات والأيام الدينية القادمة');
  String get hijriAdjustmentTitle => _t('hijriAdjustmentTitle', 'Hicri Takvim Düzeltmesi', 'Hijri Calendar Adjustment', 'تعديل التقويم الهجري');
  String get hijriAdjustmentDesc => _t('hijriAdjustmentDesc', 'Hilalin yerel gözlemine göre Hicri tarihi +/- 1 veya 2 gün ileri/geri alabilirsiniz.', 'You can adjust the Hijri date by +/- 1 or 2 days according to local moon sighting.', 'يمكنك تعديل التاريخ الهجري بـ +/- يوم أو يومين حسب رؤية الهلال المحلية.');
  String get standardLabel => _t('standardLabel', 'Standart', 'Standard', 'قياسي');
  String get daysRemainingUnit => _t('daysRemainingUnit', 'GÜN', 'DAYS', 'يوم');
  String get todayBadge => _t('todayBadge', 'BUGÜN', 'TODAY', 'اليوم');

  // ── Dua Kütüphanesi ────────────────────────────────────────────
  String get duaLibraryTitle => _t('duaLibraryTitle', 'Dua Kütüphanesi', 'Dua Library', 'مكتبة الأدعية');
  String get duaFilterTooltip => _t('duaFilterTooltip', 'Kategori Filtresi', 'Category Filter', 'تصفية الفئات');
  String get duaSearchHint => _t('duaSearchHint', 'Dua, anlam veya kaynak ara...', 'Search dua, meaning or reference...', 'ابحث عن دعاء أو معنى أو مصدر...');
    String allDuasWithCount(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Tümü ($count)';
      case AppLanguage.english:
        return 'All ($count)';
      case AppLanguage.arabic:
        return 'الكل ($count)';
      case AppLanguage.indonesian:
        return 'Semua ($count)';
      case AppLanguage.french:
        return 'Tout ($count)';
      case AppLanguage.urdu:
        return 'تمام ($count)';
      case AppLanguage.german:
        return 'Alle ($count)';
      case AppLanguage.russian:
        return 'Все ($count)';
    }
  }
  String get noDuaFound => _t('noDuaFound', 'Aramanıza uygun dua bulunamadı', 'No dua found matching your search', 'لم يتم العثور على دعاء مطابق');
  String get addToFavorites => _t('addToFavorites', 'Favorilere Ekle', 'Add to Favorites', 'إضافة إلى المفضلة');
  String get removeFromFavorites => _t('removeFromFavorites', 'Favorilerden Çıkar', 'Remove from Favorites', 'إزالة من المفضلة');
  String get copyAndShare => _t('copyAndShare', 'Kopyala & Paylaş', 'Copy & Share', 'نسخ ومشاركة');
  String get duaCopied => _t('duaCopied', 'Dua panoya kopyalandı', 'Dua copied to clipboard', 'تم نسخ الدعاء إلى الحافظة');
  String get transliterationLabel => _t('transliterationLabel', 'Okunuşu', 'Pronunciation', 'النطق');
  String get meaningLabel => _t('meaningLabel', 'Anlamı', 'Meaning', 'المعنى');
  String get referenceLabel => _t('referenceLabel', 'Kaynak', 'Reference', 'المصدر');
  String get appSignature => _t('appSignature', '— Beyân İslami Yaşam Uygulaması', '— Beyan Islamic Life App', '— تطبيق بيان للحياة الإسلامية');
    String listenSurahRecitation(String surah) {
    switch (language) {
      case AppLanguage.turkish:
        return '$surah Tilavetini Dinle';
      case AppLanguage.english:
        return 'Listen to $surah';
      case AppLanguage.arabic:
        return 'استمع لتلاوة $surah';
      case AppLanguage.indonesian:
        return 'Dengarkan Tilawah $surah';
      case AppLanguage.french:
        return 'Écouter la récitation de $surah';
      case AppLanguage.urdu:
        return 'تلاوت سورہ $surah سنیں';
      case AppLanguage.german:
        return 'Rezitation von Sure $surah anhören';
      case AppLanguage.russian:
        return 'Слушать чтение суры $surah';
    }
  }
  String get pauseRecitation => _t('pauseRecitation', 'Tilaveti Duraklat', 'Pause Recitation', 'إيقاف التلاوة مؤقتاً');
  String get resumeRecitation => _t('resumeRecitation', 'Tilaveti Devam Ettir', 'Resume Recitation', 'استئناف التلاوة');
  String get stopRecitation => _t('stopRecitation', 'Tilaveti Kapat', 'Close Recitation', 'إغلاق التلاوة');

  // ── Kıble Pusulası ─────────────────────────────────────────────
  String get qiblaCompassTitle => _t('qiblaCompassTitle', 'Kıble Pusulası', 'Qibla Compass', 'بوصلة القبلة');
    String kaabaDistance(int km) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Kâbe: $km km';
      case AppLanguage.english:
        return 'Kaaba: $km km';
      case AppLanguage.arabic:
        return 'الكعبة: $km كم';
      case AppLanguage.indonesian:
        return 'Ka\'bah: $km km';
      case AppLanguage.french:
        return 'Kaaba : $km km';
      case AppLanguage.urdu:
        return 'کعبہ: $km کلومیٹر';
      case AppLanguage.german:
        return 'Kaaba: $km km';
      case AppLanguage.russian:
        return 'Кааба: $km км';
    }
  }
  String get compassSensorNotFound => _t('compassSensorNotFound', 'Cihazınızda pusula sensörü (manyetometre) algılanamadı. Kıble açısı referans olarak gösterilmektedir.', 'Compass sensor (magnetometer) not detected on your device. Qibla angle is shown as reference.', 'لم يتم اكتشاف مستشعر البوصلة في جهازك. تظهر زاوية القبلة كمرجع.');
  String get facingQibla => _t('facingQibla', 'Kıbleye Yöneldiniz! 🕋', 'You are facing the Qibla! 🕋', 'أنت باتجاه القبلة! 🕋');
    String turnRightDeg(int deg) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Sağa $deg° dönün';
      case AppLanguage.english:
        return 'Turn right $deg°';
      case AppLanguage.arabic:
        return 'استدر يميناً $deg°';
      case AppLanguage.indonesian:
        return 'Putar ke kanan $deg°';
      case AppLanguage.french:
        return 'Tournez à droite de $deg°';
      case AppLanguage.urdu:
        return 'دائیں جانب $deg° مڑیں';
      case AppLanguage.german:
        return 'Drehe dich $deg° nach rechts';
      case AppLanguage.russian:
        return 'Поверните направо на $deg°';
    }
  }
    String turnLeftDeg(int deg) {
    switch (language) {
      case AppLanguage.turkish:
        return 'Sola $deg° dönün';
      case AppLanguage.english:
        return 'Turn left $deg°';
      case AppLanguage.arabic:
        return 'استدر يساراً $deg°';
      case AppLanguage.indonesian:
        return 'Putar ke kiri $deg°';
      case AppLanguage.french:
        return 'Tournez à gauche de $deg°';
      case AppLanguage.urdu:
        return 'بائیں جانب $deg° مڑیں';
      case AppLanguage.german:
        return 'Drehe dich $deg° nach links';
      case AppLanguage.russian:
        return 'Поверните налево на $deg°';
    }
  }
  String get qiblaAngleTitle => _t('qiblaAngleTitle', 'Kıble Açısı', 'Qibla Angle', 'زاوية القبلة');
  String get clockwiseFromNorth => _t('clockwiseFromNorth', 'Kuzeyden saat yönünde', 'Clockwise from North', 'باتجاه عقارب الساعة من الشمال');
  String get deviceHeadingTitle => _t('deviceHeadingTitle', 'Cihaz Yönü', 'Device Heading', 'اتجاه الجهاز');
  String get compassHoldFlatTip => _t('compassHoldFlatTip', 'Cihazınızı düz bir zeminde veya yatay tutarak kullanınız. Manyetik kılıflar pusulayı etkileyebilir.', 'Hold your device flat. Magnetic cases may affect the compass.', 'أمسك جهازك بشكل مستوٍ. قد تؤثر الأغطية المغناطيسية على البوصلة.');
  String get compassCalibrationTitle => _t('compassCalibrationTitle', 'Pusula Kalibrasyonu', 'Compass Calibration', 'معايرة البوصلة');
  String get compassCalibrationDesc => _t('compassCalibrationDesc', 'Telefon pusulasının doğru çalışması için:\n\n1. Cihazınızı havada yatay tutarak "8" şekli çizecek şekilde birkaç kez sallayınız.\n2. Metal veya mıknatıslı kılıflardan uzak tutunuz.\n3. Elektronik cihazların yanında manyetik sapma oluşabilir.', 'For accurate compass orientation:\n\n1. Wave your phone in a figure-8 motion.\n2. Keep away from magnetic or metal cases.\n3. Avoid electronic devices causing interference.', 'لدقة البوصلة:\n\n١. حرّك هاتفك على شكل رقم ٨ في الهواء عدة مرات.\n٢. ابتعد عن الأغطية المعدنية أو المغناطيسية.\n٣. تجنب الأجهزة الإلكترونية المسببة للتداخل.');
  String get iUnderstand => _t('iUnderstand', 'Anladım', 'Got it', 'فهمت');
  String get compassNorth => _t('compassNorth', 'Kuzey (N)', 'North (N)', 'الشمال (N)');
  String get compassNorthEast => _t('compassNorthEast', 'Kuzeydoğu (NE)', 'Northeast (NE)', 'الشمال الشرقي (NE)');
  String get compassEast => _t('compassEast', 'Doğu (E)', 'East (E)', 'الشرق (E)');
  String get compassSouthEast => _t('compassSouthEast', 'Güneydoğu (SE)', 'Southeast (SE)', 'الجنوب الشرقي (SE)');
  String get compassSouth => _t('compassSouth', 'Güney (S)', 'South (S)', 'الجنوب (S)');
  String get compassSouthWest => _t('compassSouthWest', 'Güneybatı (SW)', 'Southwest (SW)', 'الجنوب الغربي (SW)');
  String get compassWest => _t('compassWest', 'Batı (W)', 'West (W)', 'الغرب (W)');
  String get compassNorthWest => _t('compassNorthWest', 'Kuzeybatı (NW)', 'Northwest (NW)', 'الشمال الغربي (NW)');

  // ── Ramazan Dashboard ──────────────────────────────────────────
  String get holyRamadan => _t('holyRamadan', 'Ramazan-ı Şerif', 'Holy Ramadan', 'رمضان المبارك');
  String get todayFastingStatus => _t('todayFastingStatus', 'Bugünkü Oruç Durumu', 'Today\'s Fasting Status', 'حالة صيام اليوم');
  String get fastingActiveMsg => _t('fastingActiveMsg', 'Bugün oruçlusunuz (Allah kabul etsin)', 'You are fasting today (May Allah accept)', 'أنت صائم اليوم (تقبل الله)');
  String get fastingInactiveMsg => _t('fastingInactiveMsg', 'Oruç tutulmadı olarak işaretli', 'Marked as not fasting', 'غير محدد كصائم');
  String get totalFastingStatus => _t('totalFastingStatus', 'Toplam Oruç Durumu', 'Total Fasting Days', 'إجمالي أيام الصيام');
  String get totalFastingDesc => _t('totalFastingDesc', 'Ramazan, Kaza ve Nafile günleri', 'Ramadan, missed & voluntary fasts', 'أيام رمضان والقضاء والتطوع');
  String get decrementDayTooltip => _t('decrementDayTooltip', '1 Gün Eksilt', 'Decrease 1 Day', 'إنقاص يوم');
  String get incrementDayTooltip => _t('incrementDayTooltip', '1 Gün Ekle', 'Increase 1 Day', 'إضافة يوم');
    String fastingDaysCount(int count) {
    switch (language) {
      case AppLanguage.turkish:
        return '$count gün';
      case AppLanguage.english:
        return '$count days';
      case AppLanguage.arabic:
        return '$count يوم';
      case AppLanguage.indonesian:
        return '$count hari';
      case AppLanguage.french:
        return '$count jours';
      case AppLanguage.urdu:
        return '$count دن';
      case AppLanguage.german:
        return '$count Tage';
      case AppLanguage.russian:
        return '$count дн.';
    }
  }
  String get sunnahRamadanDuas => _t('sunnahRamadanDuas', 'Sünnet İftar & Sahur Duaları', 'Sunnah Iftar & Suhoor Duas', 'أدعية الإفطار والسحور المأثورة');
  String get remainingUntilIftar => _t('remainingUntilIftar', 'İftar Vaktine Kalan Süre', 'Time Remaining Until Iftar', 'الوقت المتبقي حتى الإفطار');
  String get remainingUntilSuhoor => _t('remainingUntilSuhoor', 'Sahur / İmsak Vaktine Kalan', 'Time Remaining Until Suhoor', 'الوقت المتبقي حتى السحور');
  String get remainingUntilTomorrowSuhoor => _t('remainingUntilTomorrowSuhoor', 'Yarınki Sahura Kalan', 'Remaining Until Tomorrow\'s Suhoor', 'المتبقي حتى سحور الغد');
  String get hoursUnit => _t('hoursUnit', 'SAAT', 'HOURS', 'ساعة');
  String get minsUnit => _t('minsUnit', 'DAKİKA', 'MINUTES', 'دقيقة');
  String get secsUnit => _t('secsUnit', 'SANİYE', 'SECONDS', 'ثانية');
  String get imsakSuhoorLabel => _t('imsakSuhoorLabel', 'İmsak (Sahur)', 'Imsak (Suhoor)', 'الإمساك (السحور)');
  String get maghribIftarLabel => _t('maghribIftarLabel', 'Akşam (İftar)', 'Maghrib (Iftar)', 'المغرب (الإفطار)');

  // ── Tema ve Görünüm ────────────────────────────────────────────
  String get appearanceAndTheme => _t('appearanceAndTheme', 'Görünüm & Tema', 'Appearance & Theme', 'المظهر والسمة');
  String get appearanceDesc => _t('appearanceDesc', 'Uygulamanın renk ve karanlık mod tercihlerini özelleştirin', 'Customize color palettes and dark mode preferences', 'خصص خيارات الألوان والوضع الليلي للتطبيق');
  String get appearanceModeSection => _t('appearanceModeSection', 'GÖRÜNÜM MODU', 'APPEARANCE MODE', 'وضع المظهر');
  String get modeLight => _t('modeLight', 'Açık', 'Light', 'فاتح');
  String get modeDark => _t('modeDark', 'Koyu', 'Dark', 'داكن');
  String get modeSystem => _t('modeSystem', 'Sistem', 'System', 'تلقائي');
  String get colorPaletteSection => _t('colorPaletteSection', 'RENK PALETİ', 'COLOR PALETTE', 'لوحة الألوان');

  // ── Bildirim Ayarları ──────────────────────────────────────────
  String get adhanSettingsTitle => _t('adhanSettingsTitle', 'Ezan & Vakit Bildirimleri', 'Adhan & Prayer Alerts', 'تنبيهات الأذان والصلوات');
  String get adhanSettingsDesc => _t('adhanSettingsDesc', 'Namaz vakitlerinde ezan ve uyarı bildirimleri', 'Adhan and notifications at prayer times', 'الأذان والإشعارات في أوقات الصلاة');
  String get permRequiredTitle => _t('permRequiredTitle', 'Cihaz Bildirim İzni Kapalı', 'Device Notifications Disabled', 'إشعارات الجهاز معطلة');
  String get permRequiredDesc => _t('permRequiredDesc', 'Ezan vaktinde bildirim alabilmek için sistem ayarlarından izin vermelisiniz.', 'Enable notifications in system settings to receive adhan alerts.', 'يجب تفعيل الإشعارات في إعدادات النظام لتلقي تنبيهات الأذان.');
  String get grantPermissionBtn => _t('grantPermissionBtn', 'İzin Ver', 'Grant Permission', 'منح الإذن');
  String get allNotifications => _t('allNotifications', 'Tüm Bildirimler', 'All Notifications', 'جميع الإشعارات');
  String get enableAllNotificationsDesc => _t('enableAllNotificationsDesc', 'Ezan ve namaz bildirimlerini etkinleştir', 'Enable prayer and adhan notifications', 'تفعيل إشعارات الأذان والصلاة');
  String get earlyReminderTitle => _t('earlyReminderTitle', '15 Dakika Önce Hatırlat', 'Remind 15 Mins Before', 'تنبيه قبل ١٥ دقيقة');
  String get earlyReminderDesc => _t('earlyReminderDesc', 'Vakit girmeden önce erken uyarı bildirimi', 'Early notification before prayer time begins', 'تنبيه مبكر قبل دخول وقت الصلاة');
  String get adhanMakamToneTitle => _t('adhanMakamToneTitle', 'Ezan Makamı & Ses Tonu', 'Adhan Makam & Tone', 'مقام الأذان والنغمة');
  String get changeBtn => _t('changeBtn', 'Değiştir', 'Change', 'تغيير');
  String get sectionPrayerAlerts => _t('sectionPrayerAlerts', 'VAKİT BİLDİRİMLERİ', 'PRAYER ALERTS', 'تنبيهات الصلوات');
  String get sectionVerseAlerts => _t('sectionVerseAlerts', 'GÜNÜN ÂYETİ VE SURE BİLDİRİMLERİ', 'VERSE & SURAH ALERTS', 'تنبيهات آيات اليوم وسوره');
  String get verseReminderTitle => _t('verseReminderTitle', 'Âyet & Sure Hatırlatıcı', 'Verse & Surah Reminder', 'مذكر الآيات والسور');
  String get verseReminderDesc => _t('verseReminderDesc', 'Her gün tefekkür ve manevi uyanış bildirimi', 'Daily reflection and spiritual inspiration notification', 'إشعار يومي للتأمل والاستلهام الإيماني');
  String get notificationScheduleTitle => _t('notificationScheduleTitle', 'Bildirim Saati / Zamanı', 'Notification Schedule', 'جدول الإشعارات');
  String get testVerseBtn => _t('testVerseBtn', 'Âyet Bildirimini Şimdi Test Et', 'Test Verse Alert Now', 'اختبار إشعار الآية الآن');
  String get testAdhanBtn => _t('testAdhanBtn', 'Ezan Test Bildirimi Gönder', 'Send Test Adhan Alert', 'إرسال إشعار أذان تجريبي');
  String get testVerseSuccessMsg => _t('testVerseSuccessMsg', 'Günün Âyeti test bildirimi cihazınıza gönderildi!', 'Test verse notification sent to your device!', 'تم إرسال إشعار آية تجريبي إلى جهازك!');
  String get testAdhanSuccessMsg => _t('testAdhanSuccessMsg', 'Ezan sesi ve bildirim testi iletildi! (Kilit ekranında duymak için telefonunuzun sessiz anahtarının kapalı olduğundan emin olun).', 'Adhan sound and test notification sent! (Ensure phone silent switch is off to hear on lock screen).', 'تم إرسال صوت الأذان والإشعار التجريبي! (تأكد من إيقاف زر الصامت للهاتف للتشغيل).');
  String get permWarningMsg => _t('permWarningMsg', 'Cihaz bildirim izni kapalı! Lütfen ayarlardan izin verin.', 'Device notifications disabled! Please allow from settings.', 'إشعارات الجهاز معطلة! يرجى السماح بها من الإعدادات.');
  String get fajrDesc => _t('fajrDesc', 'İmsak vakti girdiğinde ezan bildirimi', 'Adhan alert when Fajr begins', 'إشعار الأذان عند دخول وقت الفجر');
  String get sunriseDesc => _t('sunriseDesc', 'Güneş doğuş vakti uyarısı', 'Sunrise time reminder', 'تنبيه وقت شروق الشمس');
  String get dhuhrDesc => _t('dhuhrDesc', 'Öğle ezanı bildirimi', 'Dhuhr adhan notification', 'إشعار أذان الظهر');
  String get asrDesc => _t('asrDesc', 'İkindi ezanı bildirimi', 'Asr adhan notification', 'إشعار أذان العصر');
  String get maghribDesc => _t('maghribDesc', 'Akşam ezanı bildirimi', 'Maghrib adhan notification', 'إشعار أذان المغرب');
  String get ishaDesc => _t('ishaDesc', 'Yatsı ezanı bildirimi', 'Isha adhan notification', 'إشعار أذان العشاء');

  // ── Ezan Makamları Sayfası ────────────────────────────────────
  String get adhanMakamsAndAudio => _t('adhanMakamsAndAudio', 'Ezan Makamları & Ses Tonu', 'Adhan Makams & Tones', 'مقامات الأذان والأصوات');
  String get adhanMakamsDesc => _t('adhanMakamsDesc', 'Namaz vaktinde çalınacak ezan sesini seçin ve dinleyin', 'Select and preview adhan tones for prayer times', 'اختر واستمع لصوت الأذان عند دخول الصلاة');
  String get stopAudio => _t('stopAudio', 'Durdur', 'Stop', 'إيقاف');
  String get listenAudio => _t('listenAudio', 'Dinle', 'Listen', 'استماع');
  String get specialAdhanMakamsPro => _t('specialAdhanMakamsPro', 'Özel Ezan Makamları & Müezzinler', 'Special Adhan Makams & Muezzins', 'مقامات الأذان الخاصة والمؤذنون');
  String get specialAdhanMakamsProDesc => _t('specialAdhanMakamsProDesc', 'Mekke, Medine ve İstanbul ezan makamları', 'Mecca, Medina, and Istanbul adhan tones', 'أذان مكة المكرمة والمدينة المنورة وإسطنبول');
  String get proMakamExclusiveNotice => _t('proMakamExclusiveNotice', 'ezan makamı Beyân Premium ayrıcalığıdır.', 'adhan tone is a Beyân Premium exclusive.', 'متاح حصرياً لمشتركي بيان بريميوم.');
  String get makamProBannerHint => _t('makamProBannerHint', 'Mekke & Medine makamlarını dinleyin; aktif ezan tonu yapmak için Premium\'a geçin.', 'Preview Mecca & Medina adhans; upgrade to Premium to set as your adhan tone.', 'استمع لأذان مكة والمدينة؛ اشترك في بريميوم لتعيينهما كنغمة للأذان.');
  String get unlockMakamWithPremium => _t('unlockMakamWithPremium', 'Premium ile Kilidi Aç', 'Unlock with Premium', 'فتح القفل مع بريميوم');

  // ── Hesaplama Yöntemi & Şehir Seçici ──────────────────────────
  String get calculationMethodTitle => _t('calculationMethodTitle', 'Hesaplama Yöntemi', 'Calculation Method', 'طريقة الحساب');
  String get calculationMethodDesc => _t('calculationMethodDesc', 'Vakit hesaplarında yetkili kurum ve fetva meclisleri', 'Authorized institutions for prayer time calculation', 'الهيئات والمجالس الإفتائية المعتمدة لمواقيت الصلاة');
  String get cityLocationTitle => _t('cityLocationTitle', 'Şehir ve Konum Seçimi', 'Select City & Location', 'اختيار المدينة والموقع');
  String get autoGpsTitle => _t('autoGpsTitle', 'Otomatik GPS Konumu', 'Automatic GPS Location', 'الموقع التلقائي عبر GPS');
  String get autoGpsDesc => _t('autoGpsDesc', 'Cihazınızın anlık konumunu otomatik kullanır', 'Automatically uses your current location', 'يستخدم موقع جهازك الحالي تلقائياً');
  String get searchCityHint => _t('searchCityHint', 'Şehir veya ülke ara...', 'Search city or country...', 'ابحث عن مدينة أو دولة...');

  // ── Kur'an & Okuma ─────────────────────────────────────────────
  String get resumeReading => _t('resumeReading', 'Kaldığım Yerden Devam Et', 'Continue Reading', 'متابعة القراءة من حيث توقفت');
  String get arabicFontSizeTitle => _t('arabicFontSizeTitle', 'Arapça Yazı Boyutu', 'Arabic Font Size', 'حجم الخط العربي');
  String get reciterSelectionTitle => _t('reciterSelectionTitle', 'Kâri (Tilavet Okuyucusu) Seçimi', 'Select Reciter (Qari)', 'اختيار القارئ');
  String get reciterSelectionTooltip => _t('reciterSelectionTooltip', 'Kâri Seçimi', 'Select Reciter', 'اختيار القارئ');
  String get fontSizeTooltip => _t('fontSizeTooltip', 'Yazı Boyutu', 'Font Size', 'حجم الخط');
  String get listenSurahTooltip => _t('listenSurahTooltip', 'Sureyi Dinle', 'Listen to Surah', 'استمع للسورة');
  String get versesLoading => _t('versesLoading', 'Ayetler yükleniyor...', 'Loading verses...', 'جاري تحميل الآيات...');
  String get versesLoadError => _t('versesLoadError', 'Ayetler yüklenemedi.', 'Could not load verses.', 'تعذر تحميل الآيات.');
    String surahNumberBadge(int id) {
    switch (language) {
      case AppLanguage.turkish:
        return '$id. Sure';
      case AppLanguage.english:
        return 'Surah $id';
      case AppLanguage.arabic:
        return 'سورة $id';
      case AppLanguage.indonesian:
        return 'Surah $id';
      case AppLanguage.french:
        return 'Sourate $id';
      case AppLanguage.urdu:
        return 'سورہ $id';
      case AppLanguage.german:
        return 'Sure $id';
      case AppLanguage.russian:
        return 'Сура $id';
    }
  }
  String get lastReadBadge => _t('lastReadBadge', 'KALDIĞIM YER', 'LAST READ', 'حيث توقفت');
  String get saveAsLastRead => _t('saveAsLastRead', 'Kaldığım Yer Olarak Kaydet', 'Save as Last Read', 'حفظ كموضع توقف');
  String get addBookmark => _t('addBookmark', 'Yer İmine Ekle', 'Add to Bookmarks', 'إضافة للإشارات');
  String get removeBookmark => _t('removeBookmark', 'Yer İmini Kaldır', 'Remove Bookmark', 'إزالة الإشارة');
  String get shareVerse => _t('shareVerse', 'Ayeti Paylaş', 'Share Verse', 'مشاركة الآية');
    String verseCopied(String ref) {
    switch (language) {
      case AppLanguage.turkish:
        return '$ref. Ayet kopyalandı';
      case AppLanguage.english:
        return 'Verse $ref copied';
      case AppLanguage.arabic:
        return 'تم نسخ الآية $ref';
      case AppLanguage.indonesian:
        return 'Ayat $ref disalin';
      case AppLanguage.french:
        return 'Verset $ref copié';
      case AppLanguage.urdu:
        return 'آیت $ref کاپی ہو گئی';
      case AppLanguage.german:
        return 'Vers $ref kopiert';
      case AppLanguage.russian:
        return 'Аят $ref скопирован';
    }
  }
  String get seekBackward10s => _t('seekBackward10s', '10 Saniye Geri', 'Rewind 10 Seconds', 'رجوع ١٠ ثوانٍ');
  String get seekForward10s => _t('seekForward10s', '10 Saniye İleri', 'Forward 10 Seconds', 'تقديم ١٠ ثوانٍ');
    String recitationOfSurah(String surah) {
    switch (language) {
      case AppLanguage.turkish:
        return '$surah Tilaveti';
      case AppLanguage.english:
        return 'Recitation of $surah';
      case AppLanguage.arabic:
        return 'تلاوة $surah';
      case AppLanguage.indonesian:
        return 'Tilawah $surah';
      case AppLanguage.french:
        return 'Récitation de $surah';
      case AppLanguage.urdu:
        return 'تلاوت سورہ $surah';
      case AppLanguage.german:
        return 'Rezitation von Sure $surah';
      case AppLanguage.russian:
        return 'Чтение суры $surah';
    }
  }
  String get closeBtn => _t('closeBtn', 'Kapat', 'Close', 'إغلاق');
}




