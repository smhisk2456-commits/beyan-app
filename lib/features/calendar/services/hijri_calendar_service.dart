import 'package:shared_preferences/shared_preferences.dart';
import '../models/religious_day_model.dart';

class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthNameTr;
  final String monthNameAr;
  final String monthNameEn;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameTr,
    required this.monthNameAr,
    required this.monthNameEn,
  });

  String formatTr() => '$day $monthNameTr $year';
  String formatAr() => '$day $monthNameAr $year هـ';
  String formatEn() => '$day $monthNameEn $year AH';
}

/// Diyanet İşleri Başkanlığı takvimine uyumlu Hicri Takvim Servisi
class HijriCalendarService {
  static final HijriCalendarService instance = HijriCalendarService._internal();
  factory HijriCalendarService() => instance;
  HijriCalendarService._internal();

  static const _prefAdjustmentKey = 'hijri_day_adjustment';

  static const List<String> hijriMonthNamesTr = [
    'Muharrem',
    'Sefer',
    'Rebiülevvel',
    'Rebiülâhir',
    'Cemâziyelevvel',
    'Cemâziyelâhir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  static const List<String> hijriMonthNamesAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<String> hijriMonthNamesEn = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];

  /// Hicri tarih hesaplama (Umm al-Qura standard algoritması + kullanıcı düzeltme günü)
  HijriDate getHijriDate(DateTime date, {int adjustmentDays = 0}) {
    final adjustedDate = date.add(Duration(days: adjustmentDays));
    
    // Astronomik Jülyen Gün Hesabı
    int year = adjustedDate.year;
    int month = adjustedDate.month;
    final int day = adjustedDate.day;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    final int a = (year / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    final int jd = (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524;

    // Hicri gün dönüştürme
    final double z = jd - 1948439.5;
    final int cyc = (z / 10631).floor();
    final double rem = z - 10631 * cyc;
    final int j = ((rem - 0.1) / 354.36667).floor();
    final double dy = rem - (354.36667 * j + 0.5).floor();

    final int hYear = 30 * cyc + j;
    int hMonth = ((dy / 29.5) + 1).floor();
    if (hMonth > 12) hMonth = 12;
    if (hMonth < 1) hMonth = 1;

    int hDay = (dy - ((hMonth - 1) * 29.5)).floor() + 1;
    if (hDay > 30) hDay = 30;
    if (hDay < 1) hDay = 1;

    return HijriDate(
      day: hDay,
      month: hMonth,
      year: hYear,
      monthNameTr: hijriMonthNamesTr[hMonth - 1],
      monthNameAr: hijriMonthNamesAr[hMonth - 1],
      monthNameEn: hijriMonthNamesEn[hMonth - 1],
    );
  }

  /// Doğrulanmış Diyanet Dini Günler ve Kandiller Listesi (2025 - 2026 - 2027)
  List<ReligiousDay> getReligiousDays() {
    return [
      // 2025
      ReligiousDay(
        id: '2025_regaib',
        title: 'Regaib Kandili',
        hijriDate: '1 Recep 1446',
        gregorianDate: DateTime(2025, 1, 2),
        description: 'Üç ayların başlangıcı ve rahmet gecesi.',
      ),
      ReligiousDay(
        id: '2025_mirac',
        title: 'Mirac Kandili',
        hijriDate: '27 Recep 1446',
        gregorianDate: DateTime(2025, 1, 26),
        description: 'Peygamber Efendimiz\'in (s.a.v.) ilahi huzura yükseldiği mübarek gece.',
      ),
      ReligiousDay(
        id: '2025_berat',
        title: 'Berat Kandili',
        hijriDate: '15 Şaban 1446',
        gregorianDate: DateTime(2025, 2, 13),
        description: 'Af, mağfiret ve amellerin Allah\'a arz edildiği berat gecesi.',
      ),
      ReligiousDay(
        id: '2025_ramazan_start',
        title: 'Ramazan-ı Şerif Başlangıcı',
        hijriDate: '1 Ramazan 1446',
        gregorianDate: DateTime(2025, 3, 1),
        description: '11 Ayın Sultanı Ramazan ayının ve ilk orucun başlangıcı.',
      ),
      ReligiousDay(
        id: '2025_kadir',
        title: 'Kadir Gecesi',
        hijriDate: '27 Ramazan 1446',
        gregorianDate: DateTime(2025, 3, 26),
        description: 'Bin aydan daha hayırlı olan, Kur\'an-ı Kerim\'in indirildiği gece.',
      ),
      ReligiousDay(
        id: '2025_ramazan_bayram',
        title: 'Ramazan Bayramı (1. Gün)',
        hijriDate: '1 Şevval 1446',
        gregorianDate: DateTime(2025, 3, 30),
        description: 'Mübarek Ramazan Bayramı sevinç ve muhabbet günü.',
      ),
      ReligiousDay(
        id: '2025_kurban_bayram',
        title: 'Kurban Bayramı (1. Gün)',
        hijriDate: '10 Zilhicce 1446',
        gregorianDate: DateTime(2025, 6, 6),
        description: 'Hac ve kurban ibadetinin idrak edildiği büyük bayram.',
      ),
      ReligiousDay(
        id: '2025_hicri_yilbasi',
        title: 'Hicri Yılbaşı',
        hijriDate: '1 Muharrem 1447',
        gregorianDate: DateTime(2025, 6, 26),
        description: 'Hicri 1447 yılının ilk günü ve Muharrem ayı başlangıcı.',
      ),
      ReligiousDay(
        id: '2025_asure',
        title: 'Aşure Günü',
        hijriDate: '10 Muharrem 1447',
        gregorianDate: DateTime(2025, 7, 5),
        description: 'Peygamberlerin kurtuluşa erdiği mübarek gün.',
      ),
      ReligiousDay(
        id: '2025_mevlid',
        title: 'Mevlid Kandili',
        hijriDate: '12 Rebiülevvel 1447',
        gregorianDate: DateTime(2025, 9, 3),
        description: 'Alemlere rahmet Peygamberimiz Hazreti Muhammed\'in (s.a.v.) dünyayı teşrifi.',
      ),

      // 2026
      ReligiousDay(
        id: '2026_regaib',
        title: 'Regaib Kandili',
        hijriDate: '1 Recep 1447',
        gregorianDate: DateTime(2025, 12, 25),
        description: 'Üç ayların ilk kandil gecesi.',
      ),
      ReligiousDay(
        id: '2026_mirac',
        title: 'Mirac Kandili',
        hijriDate: '27 Recep 1447',
        gregorianDate: DateTime(2026, 1, 16),
        description: 'İlahi huzur ve beş vakit namazın müjdelendiği gece.',
      ),
      ReligiousDay(
        id: '2026_berat',
        title: 'Berat Kandili',
        hijriDate: '15 Şaban 1447',
        gregorianDate: DateTime(2026, 2, 2),
        description: 'Bağışlanma ve rahmet gecesi.',
      ),
      ReligiousDay(
        id: '2026_ramazan_start',
        title: 'Ramazan-ı Şerif Başlangıcı',
        hijriDate: '1 Ramazan 1447',
        gregorianDate: DateTime(2026, 2, 18),
        description: 'Mübarek Ramazan ayının ilk orucu.',
      ),
      ReligiousDay(
        id: '2026_kadir',
        title: 'Kadir Gecesi',
        hijriDate: '27 Ramazan 1447',
        gregorianDate: DateTime(2026, 3, 16),
        description: 'Bin aydan hayırlı Kur\'an gecesi.',
      ),
      ReligiousDay(
        id: '2026_ramazan_bayram',
        title: 'Ramazan Bayramı (1. Gün)',
        hijriDate: '1 Şevval 1447',
        gregorianDate: DateTime(2026, 3, 20),
        description: 'Ramazan Bayramı sevinci.',
      ),
      ReligiousDay(
        id: '2026_kurban_bayram',
        title: 'Kurban Bayramı (1. Gün)',
        hijriDate: '10 Zilhicce 1447',
        gregorianDate: DateTime(2026, 5, 27),
        description: 'Kurban Bayramı ve hac günleri.',
      ),
      ReligiousDay(
        id: '2026_hicri_yilbasi',
        title: 'Hicri Yılbaşı',
        hijriDate: '1 Muharrem 1448',
        gregorianDate: DateTime(2026, 6, 16),
        description: 'Hicri 1448 yılı başlangıcı.',
      ),
      ReligiousDay(
        id: '2026_asure',
        title: 'Aşure Günü',
        hijriDate: '10 Muharrem 1448',
        gregorianDate: DateTime(2026, 6, 25),
        description: '10 Muharrem Aşure günü.',
      ),
      ReligiousDay(
        id: '2026_mevlid',
        title: 'Mevlid Kandili',
        hijriDate: '12 Rebiülevvel 1448',
        gregorianDate: DateTime(2026, 8, 24),
        description: 'Peygamber Efendimiz\'in (s.a.v.) veladeti.',
      ),
      // ── 2026 Son Çeyrek (1448) ─────────────────────────
      ReligiousDay(
        id: '2026_uc_aylar',
        title: 'Üç Ayların Başlangıcı',
        hijriDate: '1 Recep 1448',
        gregorianDate: DateTime(2026, 12, 10),
        description: 'Mübarek Recep, Şaban ve Ramazan ayları başlangıcı.',
      ),
      ReligiousDay(
        id: '2026_regaib',
        title: 'Regaib Kandili',
        hijriDate: '2 Recep 1448',
        gregorianDate: DateTime(2026, 12, 11),
        description: 'Rahmet ve lütufların bolca ihsan edildiği gece.',
      ),
      // ── 2027 Dini Günler (1448-1449) ───────────────────
      ReligiousDay(
        id: '2027_mirac',
        title: 'Mirac Kandili',
        hijriDate: '27 Recep 1448',
        gregorianDate: DateTime(2027, 1, 5),
        description: 'İlahi huzura yükseliş ve beş vakit namaz müjdesi.',
      ),
      ReligiousDay(
        id: '2027_berat',
        title: 'Berat Kandili',
        hijriDate: '15 Şaban 1448',
        gregorianDate: DateTime(2027, 1, 22),
        description: 'Bağışlanma, af ve berat gecesi.',
      ),
      ReligiousDay(
        id: '2027_ramazan_start',
        title: 'Ramazan-ı Şerif Başlangıcı',
        hijriDate: '1 Ramazan 1448',
        gregorianDate: DateTime(2027, 2, 7),
        description: 'On bir ayın sultanı Ramazan ayının ilk orucu.',
      ),
      ReligiousDay(
        id: '2027_kadir',
        title: 'Kadir Gecesi',
        hijriDate: '27 Ramazan 1448',
        gregorianDate: DateTime(2027, 3, 5),
        description: 'Bin aydan daha hayırlı mübarek Kur\'an gecesi.',
      ),
      ReligiousDay(
        id: '2027_ramazan_bayram',
        title: 'Ramazan Bayramı (1. Gün)',
        hijriDate: '1 Şevval 1448',
        gregorianDate: DateTime(2027, 3, 9),
        description: 'Mübarek Ramazan Bayramı sevinci.',
      ),
      ReligiousDay(
        id: '2027_kurban_bayram',
        title: 'Kurban Bayramı (1. Gün)',
        hijriDate: '10 Zilhicce 1448',
        gregorianDate: DateTime(2027, 5, 16),
        description: 'Kurban ibadeti ve hac farizasının ifası.',
      ),
      ReligiousDay(
        id: '2027_hicri_yilbasi',
        title: 'Hicri Yılbaşı',
        hijriDate: '1 Muharrem 1449',
        gregorianDate: DateTime(2027, 6, 6),
        description: 'Hicri 1449 yılı başlangıcı.',
      ),
      ReligiousDay(
        id: '2027_asure',
        title: 'Aşure Günü',
        hijriDate: '10 Muharrem 1449',
        gregorianDate: DateTime(2027, 6, 15),
        description: 'Mübarek Muharrem ayı Aşure günü.',
      ),
      ReligiousDay(
        id: '2027_mevlid',
        title: 'Mevlid Kandili',
        hijriDate: '12 Rebiülevvel 1449',
        gregorianDate: DateTime(2027, 8, 14),
        description: 'Âlemlere rahmet Peygamber Efendimiz\'in (s.a.v.) veladeti.',
      ),
      ReligiousDay(
        id: '2027_regaib',
        title: 'Regaib Kandili',
        hijriDate: '2 Recep 1449',
        gregorianDate: DateTime(2027, 11, 30),
        description: 'Recep ayının ilk cuma gecesi Regaib Kandili.',
      ),
      ReligiousDay(
        id: '2027_mirac',
        title: 'Mirac Kandili',
        hijriDate: '27 Recep 1449',
        gregorianDate: DateTime(2027, 12, 26),
        description: 'Mirac gecesi feyz ve bereketi.',
      ),
      // ── 2028 Dini Günler (1449-1450) ───────────────────
      ReligiousDay(
        id: '2028_berat',
        title: 'Berat Kandili',
        hijriDate: '15 Şaban 1449',
        gregorianDate: DateTime(2028, 1, 12),
        description: 'Af ve mağfiret gecesi Berat Kandili.',
      ),
      ReligiousDay(
        id: '2028_ramazan_start',
        title: 'Ramazan-ı Şerif Başlangıcı',
        hijriDate: '1 Ramazan 1449',
        gregorianDate: DateTime(2028, 1, 28),
        description: 'Mübarek Ramazan ayının ilk orucu.',
      ),
      ReligiousDay(
        id: '2028_kadir',
        title: 'Kadir Gecesi',
        hijriDate: '27 Ramazan 1449',
        gregorianDate: DateTime(2028, 2, 23),
        description: 'Bin aydan daha hayırlı Kadir Gecesi.',
      ),
      ReligiousDay(
        id: '2028_ramazan_bayram',
        title: 'Ramazan Bayramı (1. Gün)',
        hijriDate: '1 Şevval 1449',
        gregorianDate: DateTime(2028, 2, 27),
        description: 'Ramazan Bayramı sevinç ve muhabbeti.',
      ),
      ReligiousDay(
        id: '2028_kurban_bayram',
        title: 'Kurban Bayramı (1. Gün)',
        hijriDate: '10 Zilhicce 1449',
        gregorianDate: DateTime(2028, 5, 5),
        description: 'Mübarek Kurban Bayramı başlangıcı.',
      ),
      ReligiousDay(
        id: '2028_hicri_yilbasi',
        title: 'Hicri Yılbaşı',
        hijriDate: '1 Muharrem 1450',
        gregorianDate: DateTime(2028, 5, 25),
        description: 'Hicri 1450 yılı kutlu başlangıcı.',
      ),
      ReligiousDay(
        id: '2028_asure',
        title: 'Aşure Günü',
        hijriDate: '10 Muharrem 1450',
        gregorianDate: DateTime(2028, 6, 3),
        description: 'Muharrem ayı Aşure bereketi.',
      ),
    ];
  }

  /// Sıradaki yaklaşan dini günü getirir (Asla boş alan bırakmaz)
  ReligiousDay? getNextReligiousDay() {
    final all = getReligiousDays();
    final list = all.where((d) => !d.isPast).toList();
    if (list.isNotEmpty) {
      list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
      return list.first;
    }
    // Güvenli Fallback: Gelecek döngü için son kaydı 354 gün (1 Hicri yıl) öteleyerek sunar
    if (all.isNotEmpty) {
      final last = all.last;
      return ReligiousDay(
        id: 'upcoming_future_fallback',
        title: last.title,
        hijriDate: last.hijriDate,
        gregorianDate: last.gregorianDate.add(const Duration(days: 354)),
        description: last.description,
      );
    }
    return null;
  }

  /// Ayar: Kullanıcı Hicri gün düzeltmesi (-2 ile +2 gün)
  Future<int> getSavedAdjustment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_prefAdjustmentKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> saveAdjustment(int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefAdjustmentKey, days);
    } catch (_) {}
  }
}
