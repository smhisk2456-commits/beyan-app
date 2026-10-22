import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/verified_duas_data.dart';
import '../models/dua_model.dart';

/// Favori dua ID'lerini SharedPreferences'ta saklayan Notifier
class FavoriteDuasNotifier extends StateNotifier<Set<String>> {
  static const _key = 'favorite_dua_ids';

  FavoriteDuasNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      state = list.toSet();
    } catch (_) {}
  }

  Future<void> toggleFavorite(String id) async {
    final updated = Set<String>.from(state);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, updated.toList());
    } catch (_) {}
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoriteDuasProvider =
    StateNotifierProvider<FavoriteDuasNotifier, Set<String>>((ref) {
  return FavoriteDuasNotifier();
});

/// Aktif seçili dua kategorisi filtresi (null = hepsi)
final selectedDuaCategoryProvider = StateProvider<DuaCategory?>((ref) => null);

/// Dua arama sorgusu
final duaSearchQueryProvider = StateProvider<String>((ref) => '');

/// Türkçe ve Arapça karakter duyarsız metin normalleştirici
String _normalizeForSearch(String text) {
  var s = text.toLowerCase();
  // Şapkalı harfler
  s = s.replaceAll('â', 'a').replaceAll('Â', 'a')
       .replaceAll('î', 'i').replaceAll('Î', 'i')
       .replaceAll('û', 'u').replaceAll('Û', 'u');
  // Türkçe özel harfleri standartlaştırma
  s = s.replaceAll('ı', 'i').replaceAll('I', 'i').replaceAll('İ', 'i')
       .replaceAll('ğ', 'g').replaceAll('Ğ', 'g')
       .replaceAll('ü', 'u').replaceAll('Ü', 'u')
       .replaceAll('ş', 's').replaceAll('Ş', 's')
       .replaceAll('ö', 'o').replaceAll('Ö', 'o')
       .replaceAll('ç', 'c').replaceAll('Ç', 'c');
  // Noktalama, kesme ve tire işaretlerini boşluğa çevir
  s = s.replaceAll(RegExp(r"['’`\-_/()\[\]\.,:;!?\n\r]"), ' ');
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Filtrelenmiş dua listesi
final filteredDuasListProvider = Provider<List<DuaItem>>((ref) {
  final favorites = ref.watch(favoriteDuasProvider);
  final selectedCat = ref.watch(selectedDuaCategoryProvider);
  final query = ref.watch(duaSearchQueryProvider).trim();

  return verifiedDuasList.map((item) {
    return item.copyWith(isFavorite: favorites.contains(item.id));
  }).where((item) {
    // Kategori filtresi
    if (selectedCat != null && item.category != selectedCat) {
      return false;
    }
    // Arama sorgusu
    if (query.isNotEmpty) {
      // 1. Doğrudan Arapça metin eşleşmesi
      if (item.arabicText.contains(query)) {
        return true;
      }

      final normQuery = _normalizeForSearch(query);
      if (normQuery.isEmpty) return true;

      // 2. Normalleştirilmiş arama havuzu (Başlık, Okunuş, Anlam, İngilizce, Kaynak, Fazilet)
      final combined = _normalizeForSearch(
        '${item.title} ${item.localizedTitle('en')} ${item.transliteration} ${item.turkishMeaning} ${item.localizedMeaning('en')} ${item.reference} ${item.virtueExplanation ?? ''}',
      );

      // Doğrudan alt metin eşleşmesi
      if (combined.contains(normQuery)) {
        return true;
      }

      // Kelime bazlı tam kapsama (örn: "nazar duası", "sınav zihin")
      final queryWords = normQuery.split(' ').where((w) => w.isNotEmpty).toList();
      if (queryWords.length > 1 && queryWords.every((w) => combined.contains(w))) {
        return true;
      }

      return false;
    }
    return true;
  }).toList();
});

/// Günün duası (Tarihe göre deterministik)
final dailyFeaturedDuaProvider = Provider<DuaItem>((ref) {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  final index = dayOfYear % verifiedDuasList.length;
  final favorites = ref.watch(favoriteDuasProvider);
  final dua = verifiedDuasList[index];
  return dua.copyWith(isFavorite: favorites.contains(dua.id));
});
