/// Günlük dua ve zikirleri temsil eden veri modeli.
///
/// Veritabanı tablosu: `daily_dua`
/// ```sql
/// CREATE TABLE daily_dua (
///   id               INTEGER PRIMARY KEY AUTOINCREMENT,
///   arabic_text      TEXT NOT NULL,    -- Arapça metin (hareke dahil)
///   transliteration  TEXT,             -- Türkçe okunuş (opsiyonel)
///   turkish_meaning  TEXT NOT NULL,    -- Türkçe anlamı
///   reference        TEXT NOT NULL     -- Kaynak (ör: "Bakara 255" veya "Buhari")
/// );
/// ```
class DailyDua {
  /// Veritabanı birincil anahtarı
  final int id;

  /// Arapça metin – harekeleri tam içermeli.
  /// **Amiri fontu ile render edilmelidir.**
  final String arabicText;

  /// Türkçe okunuş (transliterasyon) – opsiyonel
  final String? transliteration;

  /// Türkçe anlam
  final String turkishMeaning;

  /// Kaynak bilgisi (ör: "Bakara Suresi, 255. Ayet" veya "Sahih-i Buhari")
  final String reference;

  const DailyDua({
    required this.id,
    required this.arabicText,
    this.transliteration,
    required this.turkishMeaning,
    required this.reference,
  });

  // ── Factory & Serialization ─────────────────────────────────

  /// Veritabanı satırından DailyDua nesnesi oluşturur.
  factory DailyDua.fromMap(Map<String, dynamic> map) {
    return DailyDua(
      id: map['id'] as int,
      arabicText: map['arabic_text'] as String,
      transliteration: map['transliteration'] as String?,
      turkishMeaning: map['turkish_meaning'] as String,
      reference: map['reference'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'arabic_text': arabicText,
    'transliteration': transliteration,
    'turkish_meaning': turkishMeaning,
    'reference': reference,
  };

  // ── Eşitlik ────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyDua && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DailyDua(id: $id, reference: $reference)';
}
