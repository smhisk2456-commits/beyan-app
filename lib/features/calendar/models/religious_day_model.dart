/// Beyân - Dini Günler ve Kandiller Modeli
/// Diyanet İşleri Başkanlığı takvimine tam uyumlu dini günler.
class ReligiousDay {
  final String id;
  final String title;
  final String? titleEn;
  final String? titleAr;
  final String hijriDate;
  final DateTime gregorianDate;
  final String description;
  final bool isMajor; // Kandil veya Bayram mı

  const ReligiousDay({
    required this.id,
    required this.title,
    this.titleEn,
    this.titleAr,
    required this.hijriDate,
    required this.gregorianDate,
    required this.description,
    this.isMajor = true,
  });

  /// Dile göre başlık döner (İngilizce, Arapça, Türkçe)
  String localizedTitle(String langCode) {
    if (langCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    if (langCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    if (langCode == 'en') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'Beginning of Three Sacred Months';
      if (title.contains('Regaib')) return 'Regaib Night';
      if (title.contains('Mirac')) return 'Miraj Night';
      if (title.contains('Berat')) return 'Berat Night';
      if (title.contains('Ramazan-ı Şerif Başlangıcı') || title.contains('Ramazan Başlangıcı')) return 'Start of Ramadan';
      if (title.contains('Kadir')) return 'Night of Power (Laylat al-Qadr)';
      if (title.contains('Ramazan Bayramı')) return 'Eid al-Fitr';
      if (title.contains('Kurban Bayramı')) return 'Eid al-Adha';
      if (title.contains('Hicri Yılbaşı')) return 'Islamic New Year';
      if (title.contains('Aşure')) return 'Day of Ashura';
      if (title.contains('Mevlid')) return 'Mawlid al-Nabi';
    } else if (langCode == 'ar') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'بداية الأشهر الحرم';
      if (title.contains('Regaib')) return 'ليلة الرغائب';
      if (title.contains('Mirac')) return 'ليلة الإسراء والمعراج';
      if (title.contains('Berat')) return 'ليلة النصف من شعبان';
      if (title.contains('Ramazan-ı Şerif Başlangıcı') || title.contains('Ramazan Başlangıcı')) return 'بداية شهر رمضان';
      if (title.contains('Kadir')) return 'ليلة القدر';
      if (title.contains('Ramazan Bayramı')) return 'عيد الفطر المبارك';
      if (title.contains('Kurban Bayramı')) return 'عيد الأضحى المبارك';
      if (title.contains('Hicri Yılbaşı')) return 'رأس السنة الهجرية';
      if (title.contains('Aşure')) return 'يوم عاشوراء';
      if (title.contains('Mevlid')) return 'المولد النبوي الشريف';
    }
    return title;
  }

  /// Kalan gün sayısı
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(gregorianDate.year, gregorianDate.month, gregorianDate.day);
    return target.difference(today).inDays;
  }

  /// Geçmiş gün mü
  bool get isPast => daysRemaining < 0;

  /// Bugün mü
  bool get isToday => daysRemaining == 0;
}
