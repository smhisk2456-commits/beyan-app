import '../../notifications/models/short_verse_notification.dart';

/// Kur'an ayetlerini temsil eden veri modeli.
///
/// Veritabanı tablosu: `verse`
/// ```sql
/// CREATE TABLE verse (
///   id               INTEGER PRIMARY KEY AUTOINCREMENT,
///   surah_id         INTEGER NOT NULL,    -- Sure referansı
///   verse_number     INTEGER NOT NULL,    -- Ayet numarası (1'den başlar)
///   arabic_text      TEXT NOT NULL,       -- Arapça metin (hareke dahil)
///   transliteration  TEXT,                -- Okunuş (opsiyonel)
///   turkish_meaning  TEXT NOT NULL,       -- Türkçe meal
///   FOREIGN KEY (surah_id) REFERENCES surah(id)
/// );
/// ```
class Verse {
  /// Veritabanı birincil anahtarı
  final int id;

  /// Ait olduğu surenin numarası (1 – 114)
  final int surahId;

  /// Sure içindeki ayet sırası (1'den başlar)
  final int verseNumber;

  /// Arapça metin – harekeleri tam içermeli.
  /// **Mutlaka Amiri fontu ile render edilmelidir.**
  final String arabicText;

  /// Türkçe okunuş (transliterasyon) – opsiyonel
  final String? transliteration;

  /// Türkçe meal
  final String turkishMeaning;

  /// İngilizce meal (Saheeh International)
  final String? meaningEn;

  /// Fransızca meal (Muhammad Hamidullah)
  final String? meaningFr;

  /// Endonezce meal (Kemenag)
  final String? meaningId;

  /// Arapça tefsir / meal (Al-Muyassar)
  final String? meaningAr;

  /// Almanca meal (Bubenheim & Elyas)
  final String? meaningDe;

  /// Rusça meal (Kuliev)
  final String? meaningRu;

  /// Urduca meal (Jalandhry)
  final String? meaningUr;

  const Verse({
    required this.id,
    required this.surahId,
    required this.verseNumber,
    required this.arabicText,
    this.transliteration,
    required this.turkishMeaning,
    this.meaningEn,
    this.meaningFr,
    this.meaningId,
    this.meaningAr,
    this.meaningDe,
    this.meaningRu,
    this.meaningUr,
  });

  // ── Factory & Serialization ─────────────────────────────────

  /// Veritabanı satırından Verse nesnesi oluşturur.
  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      surahId: map['surah_id'] as int,
      verseNumber: map['verse_number'] as int,
      arabicText: map['arabic_text'] as String,
      transliteration: map['transliteration'] as String?,
      turkishMeaning: map['turkish_meaning'] as String,
      meaningEn: map['meaning_en'] as String?,
      meaningFr: map['meaning_fr'] as String?,
      meaningId: map['meaning_id'] as String?,
      meaningAr: map['meaning_ar'] as String?,
      meaningDe: map['meaning_de'] as String?,
      meaningRu: map['meaning_ru'] as String?,
      meaningUr: map['meaning_ur'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'surah_id': surahId,
    'verse_number': verseNumber,
    'arabic_text': arabicText,
    'transliteration': transliteration,
    'turkish_meaning': turkishMeaning,
    if (meaningEn != null) 'meaning_en': meaningEn,
    if (meaningFr != null) 'meaning_fr': meaningFr,
    if (meaningId != null) 'meaning_id': meaningId,
    if (meaningAr != null) 'meaning_ar': meaningAr,
    if (meaningDe != null) 'meaning_de': meaningDe,
    if (meaningRu != null) 'meaning_ru': meaningRu,
    if (meaningUr != null) 'meaning_ur': meaningUr,
  };

  // ── Yardımcı Getter'lar ────────────────────────────────────

  static final Expando<List<String>> _wordsCache = Expando<List<String>>();

  /// Arapça kelimeleri bellek önbellekli olarak döner (her build'de RegExp çalıştırmaz).
  List<String> get words =>
      _wordsCache[this] ??= arabicText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  /// "Sure:Ayet" formatında referans döner (ör: "2:255")
  String get reference => '$surahId:$verseNumber';

  /// Ayet numarasını Arapça çevre sembolleriyle döner (ör: ﴿٢٥٥﴾)
  String get verseMarker => '﴿$verseNumber﴾';

  /// Seçili dile göre meali döner (önce veritabanındaki yerel dildeki meal, yoksa havuz, yoksa İngilizce/Türkçe)
  String localizedMeaning(String langCode) {
    switch (langCode) {
      case 'tr':
        return turkishMeaning;
      case 'fr':
        if (meaningFr != null && meaningFr!.isNotEmpty) return meaningFr!;
        break;
      case 'en':
        if (meaningEn != null && meaningEn!.isNotEmpty) return meaningEn!;
        break;
      case 'id':
        if (meaningId != null && meaningId!.isNotEmpty) return meaningId!;
        break;
      case 'ar':
        if (meaningAr != null && meaningAr!.isNotEmpty) return meaningAr!;
        break;
      case 'de':
        if (meaningDe != null && meaningDe!.isNotEmpty) return meaningDe!;
        break;
      case 'ru':
        if (meaningRu != null && meaningRu!.isNotEmpty) return meaningRu!;
        break;
      case 'ur':
        if (meaningUr != null && meaningUr!.isNotEmpty) return meaningUr!;
        break;
    }

    // Kısa ayet havuzundan ara
    for (final item in ShortVerseNotification.pool) {
      if (item.verseReference.endsWith(' $surahId:$verseNumber') ||
          item.verseReference.contains(' $surahId:$verseNumber-') ||
          item.verseReference.contains(' $surahId:$verseNumber,')) {
        return item.localizedText(langCode);
      }
    }

    // İngilizce veya Türkçe fallback
    return (meaningEn != null && meaningEn!.isNotEmpty) ? meaningEn! : turkishMeaning;
  }

  // ── Eşitlik ────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Verse &&
          runtimeType == other.runtimeType &&
          surahId == other.surahId &&
          verseNumber == other.verseNumber;

  @override
  int get hashCode => Object.hash(surahId, verseNumber);

  @override
  String toString() => 'Verse($surahId:$verseNumber)';
}
