import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../models/models.dart';
import '../repositories/quran_repository.dart';
import '../repositories/dua_repository.dart';

// ════════════════════════════════════════════════════════════════
// Repository Provider'ları – Bağımlılık enjeksiyonu için
// ════════════════════════════════════════════════════════════════

/// Singleton DatabaseHelper provider'ı
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// QuranRepository provider'ı
final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return QuranRepository(databaseHelper: db);
});

/// DuaRepository provider'ı
final duaRepositoryProvider = Provider<DuaRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return DuaRepository(databaseHelper: db);
});

// ════════════════════════════════════════════════════════════════
// Surah Provider'ları
// ════════════════════════════════════════════════════════════════

/// Tüm 114 sureyi asenkron olarak yükler.
/// Veriler bir kez yüklenir ve cache'lenir (keepAlive).
final allSurahsProvider = FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getAllSurahs();
});

/// ID'ye göre tek bir sure getirir.
final surahByIdProvider = FutureProvider.family<Surah?, int>((ref, id) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getSurahById(id);
});

/// Arama sorgusuna göre filtrelenmiş sure listesi.
final surahSearchProvider = FutureProvider.family<List<Surah>, String>(
  (ref, query) async {
    final repo = ref.watch(quranRepositoryProvider);
    return repo.searchSurahsByName(query);
  },
);

// ════════════════════════════════════════════════════════════════
// Verse Provider'ları
// ════════════════════════════════════════════════════════════════

/// Bir suredeki tüm ayetleri getirir.
/// [surahId] parametre olarak alır.
final versesBySurahProvider = FutureProvider.family<List<Verse>, int>(
  (ref, surahId) async {
    final repo = ref.watch(quranRepositoryProvider);
    return repo.getVersesBySurah(surahId);
  },
);

/// Sure:Ayet referansına göre tek ayet.
final verseByReferenceProvider = FutureProvider.family<
  Verse?,
  ({int surahId, int verseNumber})
>((ref, args) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getVerseByReference(args.surahId, args.verseNumber);
});

// ════════════════════════════════════════════════════════════════
// Günlük Dua / Ayet Provider'ları
// ════════════════════════════════════════════════════════════════

/// Bugünün gününe göre seçilmiş günlük dua.
/// Widget ve ana ekran tarafından kullanılır.
final dailyDuaProvider = FutureProvider<DailyDua?>((ref) async {
  final repo = ref.watch(duaRepositoryProvider);
  return repo.getDailyDua();
});

/// Tüm dua listesi
final allDuasProvider = FutureProvider<List<DailyDua>>((ref) async {
  final repo = ref.watch(duaRepositoryProvider);
  return repo.getAllDuas();
});

// ════════════════════════════════════════════════════════════════
// Arama State Provider'ı
// ════════════════════════════════════════════════════════════════

/// Sure arama kutusunun anlık içeriği.
/// UI tarafından `ref.read(surahSearchQueryProvider.notifier).state = query`
/// şeklinde güncellenir.
final surahSearchQueryProvider = StateProvider<String>((ref) => '');

/// Arama sorgusuna bağlı dinamik sure listesi.
/// Boş sorgu → tüm sureler, dolu sorgu → filtrelenmiş liste.
final filteredSurahsProvider = FutureProvider<List<Surah>>((ref) async {
  final query = ref.watch(surahSearchQueryProvider);
  final repo = ref.watch(quranRepositoryProvider);

  if (query.isEmpty) {
    return repo.getAllSurahs();
  }
  return repo.searchSurahsByName(query);
});
