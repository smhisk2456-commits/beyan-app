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

  /// Dile göre başlık döner
  String localizedTitle(String langCode) {
    if (langCode == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    if (langCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) {
      return titleAr!;
    }
    if (langCode == 'id') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'Awal 3 Bulan Mulia';
      if (title.contains('Regaib')) return 'Malam Raghaib';
      if (title.contains('Mirac')) return 'Isra dan Mi\'raj';
      if (title.contains('Berat')) return 'Malam Nisfu Sya\'ban';
      if (title.contains('Ramazan-ı Şerif Başlangıcı') || title.contains('Ramazan Başlangıcı')) return 'Awal Ramadhan';
      if (title.contains('Kadir')) return 'Malam Lailatul Qadr';
      if (title.contains('Ramazan Bayramı')) return 'Hari Raya Idul Fitri';
      if (title.contains('Kurban Bayramı')) return 'Hari Raya Idul Adha';
      if (title.contains('Hicri Yılbaşı')) return 'Tahun Baru Hijriah';
      if (title.contains('Aşure')) return 'Hari Asyura';
      if (title.contains('Mevlid')) return 'Maulid Nabi Muhammad';
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
    } else if (langCode != 'tr') {
      // en, fr, de, ru, ur vb. yabancı diller
      if (title.contains('Üç Ayların Başlangıcı')) return 'Beginning of Sacred Months';
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
    }
    return title;
  }

  /// Dile göre açıklama döner
  String localizedDescription(String langCode) {
    if (langCode == 'id') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'Awal bulan-bulan penuh berkah: Rajab, Sya\'ban, dan Ramadhan.';
      if (title.contains('Regaib')) return 'Malam Jumat pertama bulan Rajab; malam karunia dan doa mustajab.';
      if (title.contains('Mirac')) return 'Peringatan Isra Mi\'raj Nabi Muhammad SAW dan diturunkannya perintah sholat 5 waktu.';
      if (title.contains('Berat')) return 'Malam ke-15 bulan Sya\'ban; malam pengampunan dosa dan rahmat Allah.';
      if (title.contains('Ramazan')) return 'Hari pertama bulan suci puasa, Al-Qur\'an, dan ibadah malam.';
      if (title.contains('Kadir')) return 'Malam yang lebih mulia dari seribu bulan; malam turunnya Al-Qur\'an.';
      if (title.contains('Ramazan Bayramı')) return 'Hari kemenangan Idul Fitri setelah sebulan penuh berpuasa.';
      if (title.contains('Kurban Bayramı')) return 'Hari Raya Qurban dan pelaksanaan ibadah puncak Haji.';
      if (title.contains('Hicri Yılbaşı')) return 'Peringatan hijrah Nabi dari Makkah ke Madinah; 1 Muharram.';
      if (title.contains('Aşure')) return '10 Muharram; hari kemenangan Nabi Musa AS dan peristiwa bersejarah para Nabi.';
      if (title.contains('Mevlid')) return 'Peringatan kelahiran baginda Rasulullah Muhammad SAW.';
    } else if (langCode == 'ar') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'بداية الأشهر المباركة: رجب، شعبان، ورمضان.';
      if (title.contains('Regaib')) return 'أول ليلة جمعة من شهر رجب؛ ليلة النفحات والتقرب إلى الله.';
      if (title.contains('Mirac')) return 'ذكرى إسراء ومعراج النبي ﷺ وفرض الصلوات الخمس.';
      if (title.contains('Berat')) return 'ليلة النصف من شعبان؛ ليلة المغفرة والرحمة الإلهية.';
      if (title.contains('Ramazan')) return 'أول أيام شهر الصيام والقيام ونزول القرآن الكريم.';
      if (title.contains('Kadir')) return 'ليلة خير من ألف شهر نزل فيها القرآن الكريم.';
      if (title.contains('Ramazan Bayramı')) return 'عيد الفطر المبارك؛ فرحة إتمام الصيام وشكر النعم.';
      if (title.contains('Kurban Bayramı')) return 'عيد الأضحى المبارك وشعائر الحج وذبح الأضاحي.';
      if (title.contains('Hicri Yılbaşı')) return 'ذكرى الهجرة النبوية الشريفة وأول شهر محرم.';
      if (title.contains('Aşure')) return 'اليوم العاشر من محرم؛ يوم نجاة نبي الله موسى عليه السلام.';
      if (title.contains('Mevlid')) return 'ذكرى المولد النبوي الشريف لسيد الخلق محمد ﷺ.';
    } else if (langCode != 'tr') {
      if (title.contains('Üç Ayların Başlangıcı')) return 'The beginning of the blessed months of Rajab, Shaban, and Ramadan.';
      if (title.contains('Regaib')) return 'The first Friday night of Rajab; a night of divine gifts and prayers.';
      if (title.contains('Mirac')) return 'The ascension of the Prophet Muhammad (pbuh) into the heavens; the gift of 5 daily prayers.';
      if (title.contains('Berat')) return 'The 15th night of Shaban; night of forgiveness and divine decrees.';
      if (title.contains('Ramazan')) return 'The first day of the holy month of fasting, reflection, and the Quran.';
      if (title.contains('Kadir')) return 'The night better than a thousand months; revelation of the Holy Quran.';
      if (title.contains('Ramazan Bayramı')) return 'The blessed celebration completing the month of fasting and charity.';
      if (title.contains('Kurban Bayramı')) return 'Feast of the Sacrifice and the pinnacle of the Hajj pilgrimage.';
      if (title.contains('Hicri Yılbaşı')) return 'Commemoration of the Hijrah from Mecca to Medina; 1st of Muharram.';
      if (title.contains('Aşure')) return '10th of Muharram; day of deliverance of Prophet Moses and historical miracles.';
      if (title.contains('Mevlid')) return 'The blessed birth of Prophet Muhammad (peace and blessings be upon him).';
    }
    return description;
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
