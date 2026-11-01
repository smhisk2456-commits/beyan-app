import '../../../core/localization/app_strings.dart';

/// Önemli ve Nafile Namaz Kategorisi
enum NafilaCategory {
  spiritualNight, // Gece & Kalbi Yöneliş (Teveccüh, Teheccüd)
  dailySunnah,    // Gün İçi Sünnet & Fazilet (Kuşluk, Evvabin)
  hacetGuidance,  // Hacet, İstihare & Dilek
  repentance,     // Tövbe, Şükür & Manevi Arınma
  specialOccasion,// Tesbih, Cuma, Bayram, Mescid, Küsuf, Sefer
}

extension NafilaCategoryExtension on NafilaCategory {
  String localizedName(AppLanguage lang) {
    switch (this) {
      case NafilaCategory.spiritualNight:
        return lang == AppLanguage.turkish ? 'Gece & Kalbî Teveccüh' : 'Night & Devotion';
      case NafilaCategory.dailySunnah:
        return lang == AppLanguage.turkish ? 'Günlük Müstehap & Vakit' : 'Daily Sunnah & Duha';
      case NafilaCategory.hacetGuidance:
        return lang == AppLanguage.turkish ? 'Dilek, Hacet & İstihâre' : 'Need & Guidance';
      case NafilaCategory.repentance:
        return lang == AppLanguage.turkish ? 'Tövbe, Şükür & Arınma' : 'Repentance & Gratitude';
      case NafilaCategory.specialOccasion:
        return lang == AppLanguage.turkish ? 'Özel Vakitler & Mescid' : 'Special & Occasions';
    }
  }
}

/// Namazda veya namazdan sonra okunacak özel dua modeli
class NafilaSpecialDua {
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String? note;

  const NafilaSpecialDua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.note,
  });
}

/// Tek bir rekat veya kılınış adımı
class NafilaStep {
  final String title;
  final String description;
  final String? recitationArabic;
  final String? recitationTranslit;
  final String? recitationMeaning;
  final String? note;

  const NafilaStep({
    required this.title,
    required this.description,
    this.recitationArabic,
    this.recitationTranslit,
    this.recitationMeaning,
    this.note,
  });
}

/// Önemli & Nafile Namaz Detay Modeli
class NafilaPrayer {
  final String id;
  final String title;
  final String arabicTitle;
  final NafilaCategory category;
  final String rakats;
  final String timing;
  final String conditions;
  final String virtues;
  final String niyyah;
  final String shortSummary;
  final List<NafilaStep> steps;
  final List<NafilaSpecialDua> specialDuas;
  final List<String> recommendedSurahs;
  final bool isFeatured;

  const NafilaPrayer({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.category,
    required this.rakats,
    required this.timing,
    required this.conditions,
    required this.virtues,
    required this.niyyah,
    required this.shortSummary,
    required this.steps,
    this.specialDuas = const [],
    this.recommendedSurahs = const [],
    this.isFeatured = false,
  });
}
