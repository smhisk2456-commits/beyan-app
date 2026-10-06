import 'package:flutter/material.dart';

/// Ezan makamları ve ses tonu seçenekleri.
enum AdhanMakam {
  /// İstanbul / Hicaz Makamı (Osmanlı Türk ezan geleneği)
  istanbul,

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

  String get title {
    switch (this) {
      case AdhanMakam.istanbul:
        return 'İstanbul (Hicaz)';
      case AdhanMakam.mecca:
        return 'Mekke-i Mükerreme';
      case AdhanMakam.medina:
        return 'Medine-i Münevvere';
      case AdhanMakam.tekbir:
        return 'Sade Kısa Tekbir';
      case AdhanMakam.bell:
        return 'Sade Bildirim Zili';
      case AdhanMakam.silent:
        return 'Sessiz';
    }
  }

  String get description {
    switch (this) {
      case AdhanMakam.istanbul:
        return 'Geleneksel vakarlı Türk ezanı makamı';
      case AdhanMakam.mecca:
        return 'Kâbe-i Muazzama Harem-i Şerif ezanı';
      case AdhanMakam.medina:
        return 'Mescid-i Nebevî huzur veren makamı';
      case AdhanMakam.tekbir:
        return 'Allahu Ekber nidası, kısa ve nezaketli';
      case AdhanMakam.bell:
        return 'Kısa standart bildirim melodi tonu';
      case AdhanMakam.silent:
        return 'Sadece titreşim ve ekran bildirimi';
    }
  }

  IconData get icon {
    switch (this) {
      case AdhanMakam.istanbul:
        return Icons.mosque_outlined;
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

  /// Yerel bildirimlerde çalınacak ses kaynak adı
  String? get soundResourceName {
    switch (this) {
      case AdhanMakam.istanbul:
        return 'adhan_istanbul';
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

  /// Önizleme için ses dosyası veya çevrimdışı fallback URL
  String get previewAudioUrl {
    switch (this) {
      case AdhanMakam.istanbul:
        return 'https://media.sd.ma/assabile/adhan/azan3.mp3';
      case AdhanMakam.mecca:
        return 'https://media.sd.ma/assabile/adhan/azan2.mp3';
      case AdhanMakam.medina:
        return 'https://media.sd.ma/assabile/adhan/azan1.mp3';
      case AdhanMakam.tekbir:
        return 'https://media.sd.ma/assabile/adhan/azan4.mp3';
      case AdhanMakam.bell:
      case AdhanMakam.silent:
        return '';
    }
  }
}
