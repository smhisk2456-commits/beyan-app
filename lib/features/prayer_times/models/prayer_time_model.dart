import 'package:adhan/adhan.dart';

/// Uygulamada kullanılan namaz vakti isimlerini temsil eden enum.
/// [adhan] kütüphanesinin [Prayer] enum'una karşılık gelir.
enum PrayerName {
  fajr(
    turkish: 'İmsak',
    arabic: 'الفجر',
    english: 'Fajr',
    key: 'fajr',
    rakatTotal: 4,
    rakatSummaryTurkish: '4 Rekat (2 Sünnet + 2 Farz)',
    rakatSummaryEnglish: '4 Rakats (2 Sunnah + 2 Fard)',
    rakatSummaryArabic: '٤ ركعات (٢ سنة + ٢ فرض)',
  ),
  sunrise(
    turkish: 'Güneş',
    arabic: 'الشروق',
    english: 'Sunrise',
    key: 'sunrise',
    rakatTotal: 0,
    rakatSummaryTurkish: 'Kerâhet Vakti / Güneş Doğuşu',
    rakatSummaryEnglish: 'Sunrise (Restricted Time)',
    rakatSummaryArabic: 'شروق الشمس (وقت الكراهة)',
  ),
  dhuhr(
    turkish: 'Öğle',
    arabic: 'الظهر',
    english: 'Dhuhr',
    key: 'dhuhr',
    rakatTotal: 10,
    rakatSummaryTurkish: '10 Rekat (4 Sünnet + 4 Farz + 2 Sünnet)',
    rakatSummaryEnglish: '10 Rakats (4 Sunnah + 4 Fard + 2 Sunnah)',
    rakatSummaryArabic: '١٠ ركعات (٤ سنة + ٤ فرض + ٢ سنة)',
  ),
  asr(
    turkish: 'İkindi',
    arabic: 'العصر',
    english: 'Asr',
    key: 'asr',
    rakatTotal: 8,
    rakatSummaryTurkish: '8 Rekat (4 Sünnet + 4 Farz)',
    rakatSummaryEnglish: '8 Rakats (4 Sunnah + 4 Fard)',
    rakatSummaryArabic: '٨ ركعات (٤ سنة + ٤ فرض)',
  ),
  maghrib(
    turkish: 'Akşam',
    arabic: 'المغرب',
    english: 'Maghrib',
    key: 'maghrib',
    rakatTotal: 5,
    rakatSummaryTurkish: '5 Rekat (3 Farz + 2 Sünnet)',
    rakatSummaryEnglish: '5 Rakats (3 Fard + 2 Sunnah)',
    rakatSummaryArabic: '٥ ركعات (٣ فرض + ٢ سنة)',
  ),
  isha(
    turkish: 'Yatsı',
    arabic: 'العشاء',
    english: 'Isha',
    key: 'isha',
    rakatTotal: 13,
    rakatSummaryTurkish: '13 Rekat (4 Sünnet + 4 Farz + 2 Sünnet + 3 Vitir)',
    rakatSummaryEnglish: '13 Rakats (4 Sunnah + 4 Fard + 2 Sunnah + 3 Witr)',
    rakatSummaryArabic: '١٣ ركعة (٤ سنة + ٤ فرض + ٢ سنة + ٣ وتر)',
  );

  /// Türkçe adı
  final String turkish;

  /// Arapça adı – Amiri fontu ile gösterilmeli
  final String arabic;

  /// İngilizce adı
  final String english;

  /// adhan kütüphanesi ile eşleşen key
  final String key;

  /// Toplam rekat sayısı
  final int rakatTotal;

  /// Rekat dökümü (Türkçe)
  final String rakatSummaryTurkish;

  /// Rekat dökümü (İngilizce)
  final String rakatSummaryEnglish;

  /// Rekat dökümü (Arapça)
  final String rakatSummaryArabic;

  const PrayerName({
    required this.turkish,
    required this.arabic,
    required this.english,
    required this.key,
    required this.rakatTotal,
    required this.rakatSummaryTurkish,
    required this.rakatSummaryEnglish,
    required this.rakatSummaryArabic,
  });

  /// Dile göre isim
  String localizedName(String langCode) {
    switch (langCode) {
      case 'en':
        return english;
      case 'ar':
        return arabic;
      case 'id':
        switch (this) {
          case PrayerName.fajr: return 'Subuh';
          case PrayerName.sunrise: return 'Terbit';
          case PrayerName.dhuhr: return 'Dzuhur';
          case PrayerName.asr: return 'Ashar';
          case PrayerName.maghrib: return 'Maghrib';
          case PrayerName.isha: return 'Isya';
        }
      case 'fr':
        switch (this) {
          case PrayerName.fajr: return 'Fajr';
          case PrayerName.sunrise: return 'Lever du soleil';
          case PrayerName.dhuhr: return 'Dhuhr';
          case PrayerName.asr: return 'Asr';
          case PrayerName.maghrib: return 'Maghrib';
          case PrayerName.isha: return 'Isha';
        }
      case 'ur':
        switch (this) {
          case PrayerName.fajr: return 'فجر';
          case PrayerName.sunrise: return 'طلوع آفتاب';
          case PrayerName.dhuhr: return 'ظہر';
          case PrayerName.asr: return 'عصر';
          case PrayerName.maghrib: return 'مغرب';
          case PrayerName.isha: return 'عشاء';
        }
      case 'de':
        switch (this) {
          case PrayerName.fajr: return 'Fadschr';
          case PrayerName.sunrise: return 'Sonnenaufgang';
          case PrayerName.dhuhr: return 'Dhuhr';
          case PrayerName.asr: return 'Asr';
          case PrayerName.maghrib: return 'Maghrib';
          case PrayerName.isha: return 'Ischa';
        }
      case 'ru':
        switch (this) {
          case PrayerName.fajr: return 'Фаджр';
          case PrayerName.sunrise: return 'Восход';
          case PrayerName.dhuhr: return 'Зухр';
          case PrayerName.asr: return 'Аср';
          case PrayerName.maghrib: return 'Магриб';
          case PrayerName.isha: return 'Иша';
        }
      case 'tr':
      default:
        return turkish;
    }
  }

  /// Dile göre rekat açıklaması
  String localizedRakat(String langCode) {
    switch (langCode) {
      case 'en':
        return rakatSummaryEnglish;
      case 'ar':
        return rakatSummaryArabic;
      case 'id':
        switch (this) {
          case PrayerName.fajr: return '4 Rakaat (2 Sunnah + 2 Fardhu)';
          case PrayerName.sunrise: return 'Waktu Terbit / Karahah';
          case PrayerName.dhuhr: return '10 Rakaat (4 Sunnah + 4 Fardhu + 2 Sunnah)';
          case PrayerName.asr: return '8 Rakaat (4 Sunnah + 4 Fardhu)';
          case PrayerName.maghrib: return '5 Rakaat (3 Fardhu + 2 Sunnah)';
          case PrayerName.isha: return '13 Rakaat (4 Sunnah + 4 Fardhu + 2 Sunnah + 3 Witir)';
        }
      case 'fr':
        switch (this) {
          case PrayerName.fajr: return '4 Rakats (2 Sounnah + 2 Fard)';
          case PrayerName.sunrise: return 'Lever du soleil (Temps restreint)';
          case PrayerName.dhuhr: return '10 Rakats (4 Sounnah + 4 Fard + 2 Sounnah)';
          case PrayerName.asr: return '8 Rakats (4 Sounnah + 4 Fard)';
          case PrayerName.maghrib: return '5 Rakats (3 Fard + 2 Sounnah)';
          case PrayerName.isha: return '13 Rakats (4 Sounnah + 4 Fard + 2 Sounnah + 3 Witr)';
        }
      case 'ur':
        switch (this) {
          case PrayerName.fajr: return '۴ رکعت (۲ سنت + ۲ فرض)';
          case PrayerName.sunrise: return 'طلوع آفتاب / وقت کراہت';
          case PrayerName.dhuhr: return '۱۰ رکعت (۴ سنت + ۴ فرض + ۲ سنت)';
          case PrayerName.asr: return '۸ رکعت (۴ سنت + ۴ فرض)';
          case PrayerName.maghrib: return '۵ رکعت (۳ فرض + ۲ سنت)';
          case PrayerName.isha: return '۱۳ رکعت (۴ سنت + ۴ فرض + ۲ سنت + ۳ وتر)';
        }
      case 'de':
        switch (this) {
          case PrayerName.fajr: return '4 Raka\'at (2 Sunnah + 2 Fard)';
          case PrayerName.sunrise: return 'Sonnenaufgang (Eingeschränkte Zeit)';
          case PrayerName.dhuhr: return '10 Raka\'at (4 Sunnah + 4 Fard + 2 Sunnah)';
          case PrayerName.asr: return '8 Raka\'at (4 Sunnah + 4 Fard)';
          case PrayerName.maghrib: return '5 Raka\'at (3 Fard + 2 Sunnah)';
          case PrayerName.isha: return '13 Raka\'at (4 Sunnah + 4 Fard + 2 Sunnah + 3 Witr)';
        }
      case 'ru':
        switch (this) {
          case PrayerName.fajr: return '4 ракаата (2 сунна + 2 фард)';
          case PrayerName.sunrise: return 'Восход солнца (время карахата)';
          case PrayerName.dhuhr: return '10 ракаатов (4 сунна + 4 фард + 2 сунна)';
          case PrayerName.asr: return '8 ракаатов (4 сунна + 4 фард)';
          case PrayerName.maghrib: return '5 ракаатов (3 фард + 2 сунна)';
          case PrayerName.isha: return '13 ракаатов (4 сунна + 4 фард + 2 сунна + 3 витр)';
        }
      case 'tr':
      default:
        return rakatSummaryTurkish;
    }
  }

  /// adhan [Prayer] enum'undan dönüştürür.
  static PrayerName fromAdhan(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:    return PrayerName.fajr;
      case Prayer.sunrise: return PrayerName.sunrise;
      case Prayer.dhuhr:   return PrayerName.dhuhr;
      case Prayer.asr:     return PrayerName.asr;
      case Prayer.maghrib: return PrayerName.maghrib;
      case Prayer.isha:    return PrayerName.isha;
      case Prayer.none:    return PrayerName.isha; // gece yarısı sonrası
    }
  }
}

/// Tek bir namaz vaktini temsil eden veri sınıfı.
class PrayerEntry {
  /// Namaz adı (enum)
  final PrayerName name;

  /// Hesaplanan vakit (yerel saat dilimiyle)
  final DateTime time;

  const PrayerEntry({required this.name, required this.time});

  /// Namaz henüz geçmedi mi?
  bool get isFuture => time.isAfter(DateTime.now());

  /// Bu vaktin üzerinden ne kadar geçti / ne kadar kaldı.
  Duration get timeUntil {
    final diff = time.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  String toString() => 'PrayerEntry(${name.turkish}: $time)';
}

/// Günün tüm namaz vakitlerini ve meta verilerini tutan model.
class DailyPrayerTimes {
  /// Hesaplama tarihi
  final DateTime date;

  /// Konum adı (ör: "İstanbul" veya koordinatlar)
  final String locationName;

  /// Hesaplama için kullanılan enlem
  final double latitude;

  /// Hesaplama için kullanılan boylam
  final double longitude;

  /// 6 vakit listesi (İmsak → Yatsı)
  final List<PrayerEntry> prayers;

  /// adhan nesnesi – ileri sorgulamalar için
  final PrayerTimes prayerTimes;

  /// Yarının astronomik kesin İmsak (Fajr) vakti (opsiyonel – Yatsı sonrası kesin hesaplama için)
  final DateTime? tomorrowFajr;

  const DailyPrayerTimes({
    required this.date,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.prayers,
    required this.prayerTimes,
    this.tomorrowFajr,
  });

  // ── Kolaylık Getter'ları ──────────────────────────────────

  PrayerEntry get fajr    => prayers[0];
  PrayerEntry get sunrise => prayers[1];
  PrayerEntry get dhuhr   => prayers[2];
  PrayerEntry get asr     => prayers[3];
  PrayerEntry get maghrib => prayers[4];
  PrayerEntry get isha    => prayers[5];

  /// Şu anki vakti döner ([adhan] kullanılır).
  Prayer get currentPrayer => prayerTimes.currentPrayer();

  /// Sıradaki namaz vakti [PrayerEntry]'i döner.
  /// Eğer günün tüm vakitleri geçmişse (ör: Yatsı sonrası), yarının İmsak vaktini döner.
  PrayerEntry? get nextPrayerEntry {
    final now = DateTime.now();
    for (final p in prayers) {
      if (p.time.isAfter(now)) {
        return p;
      }
    }
    // Tüm vakitler geçmiş -> Yarının İmsak vakti (kesin astronomik veya +24s emniyeti)
    return PrayerEntry(
      name: PrayerName.fajr,
      time: tomorrowFajr ?? fajr.time.add(const Duration(days: 1)),
    );
  }

  /// Sıradaki vakte kalan süre.
  Duration get timeUntilNextPrayer {
    final now = DateTime.now();
    final next = nextPrayerEntry;
    if (next == null) return Duration.zero;
    final diff = next.time.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Şimdiki ve sıradaki vaktin Türkçe adları
  String get currentPrayerName {
    final now = DateTime.now();
    PrayerEntry? current;
    for (final p in prayers) {
      if (p.time.isBefore(now)) {
        current = p;
      }
    }
    return current?.name.turkish ?? 'Yatsı';
  }

  String get nextPrayerName => nextPrayerEntry?.name.turkish ?? 'İmsak';

  PrayerEntry? get currentPrayerEntry {
    final now = DateTime.now();
    PrayerEntry? current;
    for (final p in prayers) {
      if (p.time.isBefore(now)) {
        current = p;
      }
    }
    return current;
  }

  String localizedCurrentPrayerName(String langCode) {
    return currentPrayerEntry?.name.localizedName(langCode) ??
        (langCode == 'en' ? 'Isha' : (langCode == 'ar' ? 'العشاء' : 'Yatsı'));
  }

  String localizedNextPrayerName(String langCode) {
    return nextPrayerEntry?.name.localizedName(langCode) ??
        (langCode == 'en' ? 'Fajr' : (langCode == 'ar' ? 'الفجر' : 'İmsak'));
  }
}

/// Konum verisi – GPS veya varsayılan İstanbul
class LocationData {
  final double latitude;
  final double longitude;
  final String cityName;

  /// true → GPS'ten alındı, false → varsayılan (İstanbul)
  final bool isFromGPS;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.isFromGPS,
  });

  @override
  String toString() =>
      'LocationData($cityName, $latitude, $longitude, GPS: $isFromGPS)';
}
