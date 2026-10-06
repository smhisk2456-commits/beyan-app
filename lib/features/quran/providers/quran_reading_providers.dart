import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Son okunan yer modeli
class LastReadPosition {
  final int surahId;
  final String surahName;
  final int verseNumber;
  final DateTime timestamp;

  const LastReadPosition({
    required this.surahId,
    required this.surahName,
    required this.verseNumber,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'surahId': surahId,
    'surahName': surahName,
    'verseNumber': verseNumber,
    'timestamp': timestamp.toIso8601String(),
  };

  factory LastReadPosition.fromMap(Map<String, dynamic> map) {
    return LastReadPosition(
      surahId: map['surahId'] as int? ?? 1,
      surahName: map['surahName'] as String? ?? 'Fâtiha',
      verseNumber: map['verseNumber'] as int? ?? 1,
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Son okunan yer Notifier
class LastReadNotifier extends StateNotifier<LastReadPosition?> {
  static const _surahIdKey = 'quran_last_read_surah_id';
  static const _surahNameKey = 'quran_last_read_surah_name';
  static const _verseNumKey = 'quran_last_read_verse_num';
  static const _timeKey = 'quran_last_read_time';

  LastReadNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final surahId = prefs.getInt(_surahIdKey);
      if (surahId != null) {
        state = LastReadPosition(
          surahId: surahId,
          surahName: prefs.getString(_surahNameKey) ?? 'Fâtiha',
          verseNumber: prefs.getInt(_verseNumKey) ?? 1,
          timestamp: DateTime.tryParse(prefs.getString(_timeKey) ?? '') ?? DateTime.now(),
        );
      }
    } catch (_) {}
  }

  Future<void> savePosition({
    required int surahId,
    required String surahName,
    required int verseNumber,
  }) async {
    final now = DateTime.now();
    state = LastReadPosition(
      surahId: surahId,
      surahName: surahName,
      verseNumber: verseNumber,
      timestamp: now,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_surahIdKey, surahId);
      await prefs.setString(_surahNameKey, surahName);
      await prefs.setInt(_verseNumKey, verseNumber);
      await prefs.setString(_timeKey, now.toIso8601String());
    } catch (_) {}
  }
}

final lastReadProvider =
    StateNotifierProvider<LastReadNotifier, LastReadPosition?>((ref) {
  return LastReadNotifier();
});

/// Arapça Yazı Boyutu Notifier (varsayılan 26.0)
class ArabicFontSizeNotifier extends StateNotifier<double> {
  static const _key = 'quran_arabic_font_size';

  ArabicFontSizeNotifier() : super(26.0) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final size = prefs.getDouble(_key);
      if (size != null) state = size;
    } catch (_) {}
  }

  Future<void> setFontSize(double size) async {
    state = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_key, size);
    } catch (_) {}
  }
}

final arabicFontSizeProvider =
    StateNotifierProvider<ArabicFontSizeNotifier, double>((ref) {
  return ArabicFontSizeNotifier();
});

/// Favori / Yer İmi Ayetler Notifier: "surahId:verseNumber" seti
class BookmarkedVersesNotifier extends StateNotifier<Set<String>> {
  static const _key = 'quran_bookmarked_verses';

  BookmarkedVersesNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> toggleBookmark(int surahId, int verseNumber) async {
    final key = '$surahId:$verseNumber';
    final updated = Set<String>.from(state);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, updated.toList());
    } catch (_) {}
  }

  bool isBookmarked(int surahId, int verseNumber) {
    return state.contains('$surahId:$verseNumber');
  }
}

final bookmarkedVersesProvider =
    StateNotifierProvider<BookmarkedVersesNotifier, Set<String>>((ref) {
  return BookmarkedVersesNotifier();
});
