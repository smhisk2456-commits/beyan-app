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

  const Verse({
    required this.id,
    required this.surahId,
    required this.verseNumber,
    required this.arabicText,
    this.transliteration,
    required this.turkishMeaning,
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
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'surah_id': surahId,
    'verse_number': verseNumber,
    'arabic_text': arabicText,
    'transliteration': transliteration,
    'turkish_meaning': turkishMeaning,
  };

  // ── Yardımcı Getter'lar ────────────────────────────────────

  /// "Sure:Ayet" formatında referans döner (ör: "2:255")
  String get reference => '$surahId:$verseNumber';

  /// Ayet numarasını Arapça çevre sembolleriyle döner (ör: ﴿٢٥٥﴾)
  String get verseMarker => '﴿$verseNumber﴾';

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
