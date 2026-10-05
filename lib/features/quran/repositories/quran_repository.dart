import '../../../core/database/database_helper.dart';
import '../models/models.dart';

/// Kur'an surelerine ait tüm veritabanı işlemlerini yönetir.
///
/// Bu sınıf, [DatabaseHelper] ile UI katmanı arasında bir soyutlama
/// katmanı oluşturur. Tüm veriler offline SQLite'tan okunur.
class QuranRepository {
  final DatabaseHelper _db;

  QuranRepository({DatabaseHelper? databaseHelper})
      : _db = databaseHelper ?? DatabaseHelper();

  // ── Sureler ───────────────────────────────────────────────────

  /// Tüm 114 sureyi sıra numarasına göre döner.
  Future<List<Surah>> getAllSurahs() async {
    final rows = await _db.query(
      table: 'surah',
      orderBy: 'id ASC',
    );
    return rows.map(Surah.fromMap).toList();
  }

  /// ID ile tek bir sure döner; bulunamazsa null.
  Future<Surah?> getSurahById(int surahId) async {
    final row = await _db.queryFirst(
      table: 'surah',
      where: 'id = ?',
      whereArgs: [surahId],
    );
    return row != null ? Surah.fromMap(row) : null;
  }

  /// Sure adına göre Türkçe, Arapça, İngilizce ve fonetik arama yapar (aksansız ve büyük/küçük harf duyarsız).
  Future<List<Surah>> searchSurahsByName(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return getAllSurahs();

    final normalized = _normalizeSearchKey(cleanQuery);

    final rows = await _db.query(
      table: 'surah',
      where: 'search_key LIKE ? OR name_turkish LIKE ? OR name_arabic LIKE ? OR name_english LIKE ?',
      whereArgs: ['%$normalized%', '%$cleanQuery%', '%$cleanQuery%', '%$cleanQuery%'],
      orderBy: 'id ASC',
    );
    return rows.map(Surah.fromMap).toList();
  }

  static String _normalizeSearchKey(String s) {
    const trMap = {
      'ı': 'i', 'İ': 'i', 'I': 'i',
      'ş': 's', 'Ş': 's',
      'ğ': 'g', 'Ğ': 'g',
      'ç': 'c', 'Ç': 'c',
      'ö': 'o', 'Ö': 'o',
      'ü': 'u', 'Ü': 'u',
      'â': 'a', 'Â': 'a',
      'î': 'i', 'Î': 'i',
      'û': 'u', 'Û': 'u',
    };
    var res = s.toLowerCase();
    trMap.forEach((k, v) => res = res.replaceAll(k.toLowerCase(), v));
    return res.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// Mekki veya Medeni sureleri filtreler.
  Future<List<Surah>> getSurahsByRevelationType(String type) async {
    final rows = await _db.query(
      table: 'surah',
      where: 'LOWER(revelation_type) = ?',
      whereArgs: [type.toLowerCase()],
      orderBy: 'id ASC',
    );
    return rows.map(Surah.fromMap).toList();
  }

  /// Toplam sure sayısını döner (normalde 114).
  Future<int> getSurahCount() => _db.count('surah');

  // ── Ayetler ───────────────────────────────────────────────────

  /// Belirli bir sureye ait tüm ayetleri döner.
  Future<List<Verse>> getVersesBySurah(int surahId) async {
    final rows = await _db.query(
      table: 'verse',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'verse_number ASC',
    );
    return rows.map(Verse.fromMap).toList();
  }

  /// Belirli bir sureden belirli bir sayfa kadar ayet döner (lazy loading).
  Future<List<Verse>> getVersesBySurahPaginated({
    required int surahId,
    required int limit,
    required int offset,
  }) async {
    final rows = await _db.query(
      table: 'verse',
      where: 'surah_id = ?',
      whereArgs: [surahId],
      orderBy: 'verse_number ASC',
      limit: limit,
      offset: offset,
    );
    return rows.map(Verse.fromMap).toList();
  }

  /// Sure:Ayet referansıyla tek bir ayet döner (ör: surah=2, verse=255).
  Future<Verse?> getVerseByReference(int surahId, int verseNumber) async {
    final row = await _db.queryFirst(
      table: 'verse',
      where: 'surah_id = ? AND verse_number = ?',
      whereArgs: [surahId, verseNumber],
    );
    return row != null ? Verse.fromMap(row) : null;
  }

  /// Arapça veya Türkçe metin içinde arama yapar.
  Future<List<Verse>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await _db.rawQuery(
      '''
      SELECT v.*, s.name_turkish AS surah_name
      FROM verse v
      JOIN surah s ON v.surah_id = s.id
      WHERE v.arabic_text LIKE ? OR v.turkish_meaning LIKE ?
      ORDER BY v.surah_id ASC, v.verse_number ASC
      LIMIT 50
      ''',
      ['%$query%', '%$query%'],
    );
    return rows.map(Verse.fromMap).toList();
  }

  /// Belirtilen surenin toplam ayet sayısını döner.
  Future<int> getVerseCountForSurah(int surahId) => _db.count(
    'verse',
    where: 'surah_id = ?',
    whereArgs: [surahId],
  );

  /// Rastgele bir ayet döner (günlük ayet özelliği için).
  Future<Verse?> getRandomVerse() async {
    final rows = await _db.rawQuery(
      'SELECT * FROM verse ORDER BY RANDOM() LIMIT 1',
    );
    return rows.isNotEmpty ? Verse.fromMap(rows.first) : null;
  }

  /// Rastgele n adet ayet getirir (Widget döngüsü için).
  Future<List<Verse>> getRandomVerses(int limit) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM verse ORDER BY RANDOM() LIMIT ?',
      [limit],
    );
    return rows.map((m) => Verse.fromMap(m)).toList();
  }
}

