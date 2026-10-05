/// Kur'an surelerini temsil eden veri modeli.
///
/// Veritabanı tablosu: `surah`
/// ```sql
/// CREATE TABLE surah (
///   id              INTEGER PRIMARY KEY,   -- Sure numarası (1-114)
///   name_arabic     TEXT NOT NULL,         -- Arapça isim  (ör: الفاتحة)
///   name_turkish    TEXT NOT NULL,         -- Türkçe isim  (ör: Fatiha)
///   name_english    TEXT NOT NULL,         -- İngilizce    (ör: The Opening)
///   verse_count     INTEGER NOT NULL,      -- Ayet sayısı
///   revelation_type TEXT NOT NULL          -- 'meccan' | 'medinan'
/// );
/// ```
class Surah {
  /// Sure numarası (1 – 114)
  final int id;

  /// Arapça isim – Amiri fontu ile gösterilmeli
  final String nameArabic;

  /// Türkçe isim
  final String nameTurkish;

  /// İngilizce isim
  final String nameEnglish;

  /// Toplam ayet sayısı
  final int verseCount;

  /// İniş yeri: 'meccan' (Mekke) veya 'medinan' (Medine)
  final String revelationType;

  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameTurkish,
    required this.nameEnglish,
    required this.verseCount,
    required this.revelationType,
  });

  // ── Factory & Serialization ─────────────────────────────────

  /// Veritabanı satırından Surah nesnesi oluşturur.
  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      id: map['id'] as int,
      nameArabic: map['name_arabic'] as String,
      nameTurkish: map['name_turkish'] as String,
      nameEnglish: map['name_english'] as String,
      verseCount: map['verse_count'] as int,
      revelationType: map['revelation_type'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name_arabic': nameArabic,
    'name_turkish': nameTurkish,
    'name_english': nameEnglish,
    'verse_count': verseCount,
    'revelation_type': revelationType,
  };

  // ── Yardımcı Getter'lar ────────────────────────────────────

  /// Surenin Mekke'de mi yoksa Medine'de mi indiğini döner.
  bool get isMeccan => revelationType.toLowerCase() == 'meccan';

  /// Türkçe iniş türü etiketi
  String get revelationLabel => isMeccan ? 'Mekki' : 'Medeni';

  /// Ayet sayısını Türkçe metin olarak döner
  String get verseCountLabel => '$verseCount ayet';

  // ── Eşitlik ────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Surah(id: $id, nameTurkish: $nameTurkish)';
}
