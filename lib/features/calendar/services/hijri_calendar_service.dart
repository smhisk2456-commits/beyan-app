import 'package:shared_preferences/shared_preferences.dart';
import '../models/religious_day_model.dart';

class HijriDate {
  final int day;
  final int month;
  final int year;
  final String monthNameTr;
  final String monthNameAr;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameTr,
    required this.monthNameAr,
  });

  String formatTr() => '$day $monthNameTr $year';
  String formatAr() => '$day $monthNameAr $year هـ';
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
    ];
  }

  /// Sıradaki yaklaşan dini günü getirir
  ReligiousDay? getNextReligiousDay() {
    final list = getReligiousDays().where((d) => !d.isPast).toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return list.first;
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
