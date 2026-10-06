/// Beyân İslami Yaşam Uygulaması - Dua Kütüphanesi Modeli
///
/// 10 Kapsamlı ve Doğrulanmış İslami Dua Kategorisi:
/// Sabah, Akşam, Günlük Yaşam, Yolculuk, Şükür & Sabır,
/// Sıkıntı & Ferahlık, Uyku, Yemek & Nimet, Kur'an Duaları, Peygamber Duaları.
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
