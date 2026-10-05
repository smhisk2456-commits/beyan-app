import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/app_constants.dart';

/// SQLite veritabanı yöneticisi.
///
/// Sorumlulukları:
/// 1. İlk açılışta assets/database/quran.db dosyasını cihazın yerel
///    hafızasına kopyalamak.
/// 2. Uygulama genelinde tek bir [Database] örneği (singleton) sunmak.
/// 3. Ham SQL sorgularını çalıştırmak için erişim noktası sağlamak.
class DatabaseHelper {
  // ── Singleton Pattern ──────────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  /// Veritabanı nesnesini döner; gerekirse önce başlatır.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // ── Başlatma ───────────────────────────────────────────────────

  /// Veritabanını başlatır.
  /// Eğer cihazda yoksa assets'ten kopyalar.
  Future<Database> _initDatabase() async {
    final dbPath = await _getLocalDatabasePath();

    // Assets'ten kopyalama gerekiyor mu?
    final dbFile = File(dbPath);
    // Assets'ten kopyalama gerekiyor mu veya dosya boş mu?
    if (!await dbFile.exists() || (await dbFile.length()) < 10000) {
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await _copyDatabaseFromAssets(dbPath);
    }

    return await openDatabase(
      dbPath,
      readOnly: false,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys=ON;');
      },
    );
  }

  /// Cihazın belgeler dizininde veritabanı dosyasının tam yolunu döner.
  Future<String> _getLocalDatabasePath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return join(documentsDir.path, AppConstants.databaseName);
  }

  /// Assets'teki quran.db dosyasını cihazın yerel hafızasına kopyalar.
  ///
  /// Bu işlem uygulama ilk kez açıldığında bir kez gerçekleşir.
  /// Sonraki açılışlarda doğrudan yerel dosya kullanılır.
  Future<void> _copyDatabaseFromAssets(String destinationPath) async {
    try {
      // Assets'ten ikili veriyi oku
      final ByteData data = await rootBundle.load(
        AppConstants.databaseAssetPath,
      );

      // Hedef klasörün varlığını garanti et
      final parentDir = Directory(dirname(destinationPath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Dosyayı diske yaz
      final buffer = data.buffer;
      await File(destinationPath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    } catch (e) {
      throw DatabaseException(
        'Veritabanı assets\'ten kopyalanamadı: $e\n'
        'Lütfen assets/database/quran.db dosyasının mevcut olduğunu doğrulayın.',
      );
    }
  }

  // ── Sorgu Yardımcıları ────────────────────────────────────────

  /// Genel SELECT sorgusu çalıştırır.
  Future<List<Map<String, dynamic>>> query({
    required String table,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Ham SQL sorgusu çalıştırır.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  /// Tek bir kayıt döner; bulunamazsa null.
  Future<Map<String, dynamic>?> queryFirst({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final results = await query(
      table: table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Bir tablodaki toplam kayıt sayısını döner.
  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table ${where != null ? "WHERE $where" : ""}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── Kaynak Temizleme ──────────────────────────────────────────

  /// Veritabanı bağlantısını kapatır.
  /// Normalde çağrılması gerekmez; uygulama kapatıldığında OS halleder.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}

/// Veritabanına özgü hata sınıfı.
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
