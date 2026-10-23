import 'package:flutter/material.dart';

/// Ezan makamları ve ses tonu seçenekleri.
enum AdhanMakam {
  /// Sabah Vakti - Sabâ Makamı (Uyanış ve derin huşû)
  saba,

  /// Öğle Vakti - Rast Makamı (Dirilik, vakar ve neşe)
  rast,

  /// İkindi Vakti - Hicaz / İstanbul Makamı (Geleneksel vakarlı Türk ezanı)
  istanbul,

  /// Akşam Vakti - Segâh Makamı (Günün batışında huzur ve teslimiyet)
  segah,

  /// Yatsı Vakti - Uşşak Makamı (Geceye hazırlayan sükunet ve teskin)
  ussak,

  /// Kâbe-i Muazzama / Mekke-i Mükerreme Makamı
  mecca,

  /// Mescid-i Nebevî / Medine-i Münevvere Makamı
  medina,

  /// Kısa Sade Tekbir (İş ve toplantı ortamları için nezaketli ton)
  tekbir,

  /// Sade Bildirim Zili (Klasik zil)
  bell,

  /// Sessiz (Yalnızca ekran bildirimi ve titreşim)
  silent,
}

extension AdhanMakamExtension on AdhanMakam {
  String get id => name;

  /// Kâbe (Mekke) ve Ravza-i Mutahhara (Medine) makamları Beyân Premium ayrıcalığıdır.
  bool get isPro => this == AdhanMakam.mecca || this == AdhanMakam.medina;

  String get title => localizedTitle('tr');

  String localizedTitle(String langCode) {
    switch (this) {
      case AdhanMakam.saba:
        if (langCode == 'en') return 'Sabâ Makam (Fajr / Dawn)';
        if (langCode == 'ar') return 'مقام الصبا (الفجر)';
        return 'Sabâ Makamı (Sabah)';
      case AdhanMakam.rast:
        if (langCode == 'en') return 'Rast Makam (Dhuhr / Noon)';
        if (langCode == 'ar') return 'مقام الرست (الظهر)';
        return 'Rast Makamı (Öğle)';
      case AdhanMakam.istanbul:
        if (langCode == 'en') return 'Hijaz Makam (Asr / Afternoon)';
        if (langCode == 'ar') return 'مقام الحجاز (العصر)';
        return 'Hicaz Makamı (İkindi)';
      case AdhanMakam.segah:
        if (langCode == 'en') return 'Segâh Makam (Maghrib / Sunset)';
        if (langCode == 'ar') return 'مقام السيكاه (المغرب)';
        return 'Segâh Makamı (Akşam)';
      case AdhanMakam.ussak:
        if (langCode == 'en') return 'Uşşak Makam (Isha / Night)';
        if (langCode == 'ar') return 'مقام العشاق (العشاء)';
        return 'Uşşak Makamı (Yatsı)';
      case AdhanMakam.mecca:
        if (langCode == 'en') return 'Mecca Al-Mukarramah';
        if (langCode == 'ar') return 'مكة المكرمة';
        return 'Mekke-i Mükerreme';
      case AdhanMakam.medina:
        if (langCode == 'en') return 'Medina Al-Munawwarah';
        if (langCode == 'ar') return 'المدينة المنورة';
        return 'Medine-i Münevvere';
      case AdhanMakam.tekbir:
        if (langCode == 'en') return 'Simple Short Takbeer';
        if (langCode == 'ar') return 'تكبير قصير ولطيف';
        return 'Sade Kısa Tekbir';
      case AdhanMakam.bell:
        if (langCode == 'en') return 'Standard Tone';
        if (langCode == 'ar') return 'نغمة تنبيه قياسية';
        return 'Sade Bildirim Zili';
      case AdhanMakam.silent:
        if (langCode == 'en') return 'Silent';
        if (langCode == 'ar') return 'صامت';
        return 'Sessiz';
    }
  }

  String get description => localizedDescription('tr');

  String localizedDescription(String langCode) {
    switch (this) {
      case AdhanMakam.saba:
        if (langCode == 'en') return 'Contemplative and serene dawn awakening';
        if (langCode == 'ar') return 'نغم الفجر الخاشع الرقيق';
        return 'Ruhu uyandıran hüzünlü ve derin huşû makamı';
      case AdhanMakam.rast:
        if (langCode == 'en') return 'Dignified, energetic and vibrant midday call';
        if (langCode == 'ar') return 'وقار ونشاط نداء منتصف النهار';
        return 'Öğle vaktinin dinçlik ve vakar veren makamı';
      case AdhanMakam.istanbul:
        if (langCode == 'en') return 'Traditional dignified Turkish adhan makam';
        if (langCode == 'ar') return 'مقام الأذان التركي الوقور الأصيل';
        return 'Geleneksel vakarlı Türk ezanı makamı';
      case AdhanMakam.segah:
        if (langCode == 'en') return 'Peaceful sunset submission and majesty';
        if (langCode == 'ar') return 'خشوع وسكون وقت الغروب';
        return 'Gün batımında huzur ve teslimiyet makamı';
      case AdhanMakam.ussak:
        if (langCode == 'en') return 'Calming, tranquil night preparation';
        if (langCode == 'ar') return 'سكينة وهدوء الليل';
        return 'Geceye hazırlayan dinlendirici sükûnet makamı';
      case AdhanMakam.mecca:
        if (langCode == 'en') return 'Adhan of the Grand Mosque of Mecca';
        if (langCode == 'ar') return 'أذان المسجد الحرام بمكة المكرمة';
        return 'Kâbe-i Muazzama Harem-i Şerif ezanı';
      case AdhanMakam.medina:
        if (langCode == 'en') return 'Serene adhan of the Prophet\'s Mosque';
        if (langCode == 'ar') return 'أذان المسجد النبوي الشريف الخاشع';
        return 'Mescid-i Nebevî huzur veren makamı';
      case AdhanMakam.tekbir:
        if (langCode == 'en') return 'Gentle and brief Allahu Akbar call';
        if (langCode == 'ar') return 'نداء الله أكبر، موجز وخفيف';
        return 'Allahu Ekber nidası, kısa ve nezaketli';
      case AdhanMakam.bell:
        if (langCode == 'en') return 'Short gentle chime notification';
        if (langCode == 'ar') return 'نغمة تنبيه هادئة وقصيرة';
        return 'Kısa standart bildirim melodi tonu';
      case AdhanMakam.silent:
        if (langCode == 'en') return 'Vibration and screen alert only';
        if (langCode == 'ar') return 'اهتزاز وإشعار على الشاشة فقط';
        return 'Sadece titreşim ve ekran bildirimi';
    }
  }

  String? get vakitTag {
    switch (this) {
      case AdhanMakam.saba:
        return 'Sabah';
      case AdhanMakam.rast:
        return 'Öğle';
      case AdhanMakam.istanbul:
        return 'İkindi';
      case AdhanMakam.segah:
        return 'Akşam';
      case AdhanMakam.ussak:
        return 'Yatsı';
      case AdhanMakam.mecca:
      case AdhanMakam.medina:
        return 'Haremeyn';
      case AdhanMakam.tekbir:
        return 'Kısa';
      case AdhanMakam.bell:
      case AdhanMakam.silent:
        return null;
    }
  }

  IconData get icon {
    switch (this) {
      case AdhanMakam.saba:
        return Icons.wb_twilight_rounded;
      case AdhanMakam.rast:
        return Icons.wb_sunny_rounded;
      case AdhanMakam.istanbul:
        return Icons.mosque_outlined;
      case AdhanMakam.segah:
        return Icons.nights_stay_rounded;
      case AdhanMakam.ussak:
        return Icons.bedtime_rounded;
      case AdhanMakam.mecca:
        return Icons.location_city_rounded;
      case AdhanMakam.medina:
        return Icons.star_half_rounded;
      case AdhanMakam.tekbir:
        return Icons.record_voice_over_outlined;
      case AdhanMakam.bell:
        return Icons.notifications_none_rounded;
      case AdhanMakam.silent:
        return Icons.notifications_off_outlined;
    }
  }

  /// Yerel bildirimlerde çalınacak ses kaynak adı (uzantısız)
  String? get soundResourceName {
    switch (this) {
      case AdhanMakam.saba:
      case AdhanMakam.istanbul:
      case AdhanMakam.ussak:
        return 'adhan_istanbul';
      case AdhanMakam.rast:
      case AdhanMakam.segah:
      case AdhanMakam.mecca:
        return 'adhan_mecca';
      case AdhanMakam.medina:
        return 'adhan_medina';
      case AdhanMakam.tekbir:
        return 'adhan_tekbir';
      case AdhanMakam.bell:
      case AdhanMakam.silent:
        return null;
    }
  }

  /// Çevrimdışı yerel ses dosyası yolu (assets/audio/)
  String get assetPath {
    switch (this) {
      case AdhanMakam.saba:
      case AdhanMakam.istanbul:
      case AdhanMakam.ussak:
        return 'audio/adhan_istanbul.mp3';
      case AdhanMakam.rast:
      case AdhanMakam.mecca:
        return 'audio/adhan_mecca.mp3';
      case AdhanMakam.segah:
      case AdhanMakam.medina:
        return 'audio/adhan_medina.mp3';
      case AdhanMakam.tekbir:
        return 'audio/adhan_tekbir.mp3';
      case AdhanMakam.bell:
      case AdhanMakam.silent:
        return '';
    }
  }

  /// Önizleme için ses dosyası yolu (Çevrimdışı yerel asset)
  String get previewAudioUrl => assetPath;
}
