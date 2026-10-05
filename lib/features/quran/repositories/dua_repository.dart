import '../../../core/database/database_helper.dart';
import '../models/models.dart';

/// Günlük dua ve zikirler için veritabanı işlemlerini yönetir.
///
/// [daily_dua] tablosundan okuma yapar; mock veri kullanılmaz.
class DuaRepository {
  final DatabaseHelper _db;

  DuaRepository({DatabaseHelper? databaseHelper})
      : _db = databaseHelper ?? DatabaseHelper();

  // ── Tüm Dualar ───────────────────────────────────────────────

  /// Tüm dua ve zikirleri döner.
  Future<List<DailyDua>> getAllDuas() async {
    final rows = await _db.query(
      table: 'daily_dua',
      orderBy: 'id ASC',
    );
    return rows.map(DailyDua.fromMap).toList();
  }

  /// ID ile tek bir dua döner; bulunamazsa null.
  Future<DailyDua?> getDuaById(int id) async {
    final row = await _db.queryFirst(
      table: 'daily_dua',
      where: 'id = ?',
      whereArgs: [id],
    );
    return row != null ? DailyDua.fromMap(row) : null;
  }

  // ── Günlük Ayet Mantığı ────────────────────────────────────

  /// Bugünün tarihine göre deterministik "günlük dua" seçer.
  ///
  /// Mantık: toplamDua % toplamDuaSayısı = bugünün index'i
  /// Böylece her gün farklı ama öngörülebilir bir dua gösterilir.
  Future<DailyDua?> getDailyDua() async {
    final totalCount = await _db.count('daily_dua');
    if (totalCount == 0) return null;

    // Yılın kaçıncı günü olduğunu index olarak kullan
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    final index = dayOfYear % totalCount;

    final rows = await _db.query(
      table: 'daily_dua',
      orderBy: 'id ASC',
      limit: 1,
      offset: index,
    );
    return rows.isNotEmpty ? DailyDua.fromMap(rows.first) : null;
  }

  /// Rastgele bir dua döner.
  Future<DailyDua?> getRandomDua() async {
    final rows = await _db.rawQuery(
      'SELECT * FROM daily_dua ORDER BY RANDOM() LIMIT 1',
    );
    return rows.isNotEmpty ? DailyDua.fromMap(rows.first) : null;
  }

  /// Toplam dua sayısını döner.
  Future<int> getDuaCount() => _db.count('daily_dua');

  /// Türkçe anlam veya referans alanında arama yapar.
  Future<List<DailyDua>> searchDuas(String query) async {
    if (query.trim().isEmpty) return getAllDuas();

    final rows = await _db.query(
      table: 'daily_dua',
      where: 'turkish_meaning LIKE ? OR reference LIKE ? OR arabic_text LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return rows.map(DailyDua.fromMap).toList();
  }
}
