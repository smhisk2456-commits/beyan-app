import '../data/dua_translations.dart';

enum DuaCategory {
  morning('Sabah Duaları', 'Morning', 'أذكار الصباح'),
  evening('Akşam Duaları', 'Evening', 'أذكار المساء'),
  dailyLife('Günlük Yaşam', 'Daily Life', 'أدعية الحياة اليومية'),
  travel('Yolculuk', 'Travel', 'أدعية السفر'),
  gratitudePatience('Şükür ve Sabır', 'Gratitude & Patience', 'الشكر والصبر'),
  distress('Sıkıntı ve Ferahlık', 'Distress & Relief', 'تفريج الكروب'),
  sleep('Uyku Öncesi ve Sonrası', 'Sleep', 'أذكار النوم'),
  food('Yemek ve Nimet', 'Food & Blessings', 'أدعية الطعام'),
  quranic('Kur\'an-ı Kerim Duaları', 'Quranic Duas', 'أدعية قرآنية'),
  prophets('Peygamberlerin Duaları', 'Prophetic Duas', 'أدعية الأنبياء');

  final String trName;
  final String enName;
  final String arName;

  const DuaCategory(this.trName, this.enName, this.arName);

  String localizedName(String langCode) {
    if (langCode == 'en') return enName;
    if (langCode == 'ar') return arName;
    return trName;
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
      if (langCode == 'en' && entry.titleEn.isNotEmpty) return entry.titleEn;
      if (langCode == 'ar' && entry.titleAr.isNotEmpty) return entry.titleAr;
    }
    return title;
  }

  String localizedMeaning(String langCode) {
    final entry = kDuaTranslations[id];
    if (entry != null) {
      if (langCode == 'en' && entry.meaningEn.isNotEmpty) return entry.meaningEn;
      if (langCode == 'ar' && entry.meaningAr.isNotEmpty) return entry.meaningAr;
    }
    return turkishMeaning;
  }

  String localizedReference(String langCode) {
    final entry = kDuaTranslations[id];
    if (entry != null) {
      if (langCode == 'en' && entry.referenceEn.isNotEmpty) return entry.referenceEn;
      if (langCode == 'ar' && entry.referenceAr.isNotEmpty) return entry.referenceAr;
    }
    if (langCode == 'en') {
      return _translateReferenceToEn(reference);
    } else if (langCode == 'ar') {
      return _translateReferenceToAr(reference);
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
