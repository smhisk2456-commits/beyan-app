import 'package:flutter/material.dart';
import '../data/dua_translations.dart';

enum DuaCategory {
  quranic('Kur\'an-ı Kerim Duaları', 'Quranic Duas', 'أدعية قرآنية', Icons.auto_stories_rounded, 'Âyetü\'l-Kürsî, Fâtiha, İnşirah, Lev Enzelnâ...'),
  prayer('Namaz ve Ezan Duaları', 'Prayer & Adhan', 'أدعية الصلاة والأذان', Icons.mosque_rounded, 'Sübhaneke, Tahiyyat, Salli-Bârik, Kunut, Ezan...'),
  healingProtection('Şifa ve Korunma (Nazar)', 'Healing & Protection', 'الشفاء والتحصين', Icons.health_and_safety_rounded, 'Nazar duası, Şifa duası, İhlâs, Felak, Nâs...'),
  morning('Sabah Duaları', 'Morning', 'أذكار الصباح', Icons.wb_sunny_rounded, 'Sabaha erişme, Seyyidü\'l-İstiğfar, Afiyet niyazı...'),
  evening('Akşam Duaları', 'Evening', 'أذكار المساء', Icons.nights_stay_rounded, 'Akşama giriş, Âmenerresûlü, Gece sığınma...'),
  distress('Sıkıntı, Ferahlık ve Hacet', 'Distress & Relief', 'تفريج الكروب', Icons.spa_rounded, 'Hz. Yunus duası, Hacet, İstihare, Rabbi Yessir...'),
  prophets('Peygamberlerin Duaları', 'Prophetic Duas', 'أدعية الأنبياء', Icons.menu_book_rounded, 'Hz. Musa, Hz. Eyyüb, Hz. Adem, Hz. Yusuf...'),
  dailyLife('Günlük Yaşam ve Bereket', 'Daily Life & Blessings', 'الحياة اليومية والبركة', Icons.home_rounded, 'Ev, cami, abdest, Karınca bereket duası...'),
  sleep('Uyku Öncesi ve Sonrası', 'Sleep', 'أذكار النوم', Icons.bed_rounded, 'Yatış duası, Berâ duası, Uyanma şükrü...'),
  food('Yemek ve Nimet', 'Food & Blessings', 'أدعية الطعام', Icons.restaurant_rounded, 'Sofraya başlama, sofra duası, ikram şükrü...'),
  travel('Yolculuk Duaları', 'Travel', 'أدعية السفر', Icons.explore_rounded, 'Vasıtaya biniş, seferde emniyet, dönüş duası...'),
  gratitudePatience('Şükür ve Sabır', 'Gratitude & Patience', 'الشكر والصبر', Icons.favorite_rounded, 'Nimet şükrü, musibette sabır, Hasbiyallâh...');

  final String trName;
  final String enName;
  final String arName;
  final IconData icon;
  final String subtitleTr;

  const DuaCategory(this.trName, this.enName, this.arName, this.icon, this.subtitleTr);

  String localizedName(String langCode) {
    if (langCode == 'en') return enName;
    if (langCode == 'ar') return arName;
    return trName;
  }

  String localizedSubtitle(String langCode) {
    if (langCode == 'en') {
      switch (this) {
        case DuaCategory.quranic:
          return 'Ayat al-Kursi, Al-Fatiha, Al-Inshirah...';
        case DuaCategory.prayer:
          return 'Subhanaka, Tashahhud, Salawat, Qunut, Adhan...';
        case DuaCategory.healingProtection:
          return 'Evil eye, healing, Al-Ikhlas, Al-Falaq, An-Nas...';
        case DuaCategory.morning:
          return 'Morning supplications, Sayyid al-Istighfar...';
        case DuaCategory.evening:
          return 'Evening remembrance, Amanar-Rasul...';
        case DuaCategory.distress:
          return 'Prophet Yunus dua, relief, Istikhara...';
        case DuaCategory.prophets:
          return 'Duas of Musa, Ayyub, Adam, Yusuf (pbut)...';
        case DuaCategory.dailyLife:
          return 'Home, mosque, wudu, blessing supplications...';
        case DuaCategory.sleep:
          return 'Before sleeping & waking remembrance...';
        case DuaCategory.food:
          return 'Before and after meals, blessings...';
        case DuaCategory.travel:
          return 'Boarding vehicles, safety during journey...';
        case DuaCategory.gratitudePatience:
          return 'Gratitude for blessings, patience in hardship...';
      }
    }
    return subtitleTr;
  }
}

class DuaItem {
  final String id;
  final DuaCategory category;
  final String title;
  final String arabicText;
  final String transliteration;
  final String turkishMeaning;
  final String reference;
  final String? virtueExplanation;
  final bool isFavorite;

  const DuaItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.turkishMeaning,
    required this.reference,
    this.virtueExplanation,
    this.isFavorite = false,
  });

  DuaItem copyWith({
    String? id,
    DuaCategory? category,
    String? title,
    String? arabicText,
    String? transliteration,
    String? turkishMeaning,
    String? reference,
    String? virtueExplanation,
    bool? isFavorite,
  }) {
    return DuaItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      turkishMeaning: turkishMeaning ?? this.turkishMeaning,
      reference: reference ?? this.reference,
      virtueExplanation: virtueExplanation ?? this.virtueExplanation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category.name,
    'title': title,
    'arabic_text': arabicText,
    'transliteration': transliteration,
    'turkish_meaning': turkishMeaning,
    'reference': reference,
    'virtue_explanation': virtueExplanation,
    'is_favorite': isFavorite ? 1 : 0,
  };

  String localizedTitle(String langCode) {
    final entry = kDuaTranslations[id];
    if (entry != null) {
      if (langCode == 'ar' && entry.titleAr.isNotEmpty) return entry.titleAr;
      if (langCode != 'tr' && entry.titleEn.isNotEmpty) return entry.titleEn;
    }
    return title;
  }

  String localizedMeaning(String langCode) {
    final entry = kDuaTranslations[id];
    if (entry != null) {
      if (langCode == 'ar' && entry.meaningAr.isNotEmpty) return entry.meaningAr;
      if (langCode != 'tr' && entry.meaningEn.isNotEmpty) return entry.meaningEn;
    }
    return turkishMeaning;
  }

  String localizedReference(String langCode) {
    final entry = kDuaTranslations[id];
    if (entry != null) {
      if (langCode == 'ar' && entry.referenceAr.isNotEmpty) return entry.referenceAr;
      if (langCode != 'tr' && entry.referenceEn.isNotEmpty) return entry.referenceEn;
    }
    if (langCode == 'ar') {
      return _translateReferenceToAr(reference);
    } else if (langCode != 'tr') {
      return _translateReferenceToEn(reference);
    }
    return reference;
  }

  static String _translateReferenceToEn(String ref) {
    return ref
        .replaceAll('Sahih-i Müslim', 'Sahih Muslim')
        .replaceAll('Sahih-i Buhari', 'Sahih al-Bukhari')
        .replaceAll('Sünen-i Tirmizi', 'Jami` at-Tirmidhi')
        .replaceAll('Tirmizi', 'Jami` at-Tirmidhi')
        .replaceAll('Sünen-i Ebu Davud', 'Sunan Abi Dawud')
        .replaceAll('Ebu Davud', 'Sunan Abi Dawud')
        .replaceAll('Sünen-i İbni Mace', 'Sunan Ibn Majah')
        .replaceAll('İbni Mace', 'Sunan Ibn Majah')
        .replaceAll('Müsned-i Ahmed', 'Musnad Ahmad')
        .replaceAll('Ayetler', 'Verses')
        .replaceAll('Ayet', 'Verse')
        .replaceAll('Suresi', 'Surah');
  }

  static String _translateReferenceToAr(String ref) {
    return ref
        .replaceAll('Sahih-i Müslim', 'صحيح مسلم')
        .replaceAll('Sahih-i Buhari', 'صحيح البخاري')
        .replaceAll('Sünen-i Tirmizi', 'جامع الترمذي')
        .replaceAll('Tirmizi', 'جامع الترمذي')
        .replaceAll('Sünen-i Ebu Davud', 'سنن أبي داود')
        .replaceAll('Ebu Davud', 'سنن أبي داود')
        .replaceAll('Sünen-i İbni Mace', 'سنن ابن ماجه')
        .replaceAll('İbni Mace', 'سنن ابن ماجه')
        .replaceAll('Müsned-i Ahmed', 'مسند أحمد')
        .replaceAll('Ayetler', 'الآيات')
        .replaceAll('Ayet', 'آية')
        .replaceAll('Suresi', 'سورة');
  }

  factory DuaItem.fromMap(Map<String, dynamic> map) {
    final catName = map['category'] as String?;
    final category = DuaCategory.values.firstWhere(
      (c) => c.name == catName,
      orElse: () => DuaCategory.dailyLife,
    );

    return DuaItem(
      id: map['id']?.toString() ?? '',
      category: category,
      title: map['title'] as String? ?? '',
      arabicText: map['arabic_text'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      turkishMeaning: map['turkish_meaning'] as String? ?? '',
      reference: map['reference'] as String? ?? '',
      virtueExplanation: map['virtue_explanation'] as String?,
      isFavorite: (map['is_favorite'] == 1 || map['is_favorite'] == true),
    );
  }
}
