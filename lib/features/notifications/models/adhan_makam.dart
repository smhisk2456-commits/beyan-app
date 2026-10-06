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

  /// Yerel bildirimlerde çalınacak ses kaynak adı (uzantısız)
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

  /// Çevrimdışı yerel ses dosyası yolu (assets/audio/)
  String get assetPath {
    switch (this) {
      case AdhanMakam.istanbul:
        return 'audio/adhan_istanbul.mp3';
      case AdhanMakam.mecca:
        return 'audio/adhan_mecca.mp3';
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
