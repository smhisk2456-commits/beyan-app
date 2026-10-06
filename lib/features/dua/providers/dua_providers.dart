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

/// Filtrelenmiş dua listesi
final filteredDuasListProvider = Provider<List<DuaItem>>((ref) {
  final favorites = ref.watch(favoriteDuasProvider);
  final selectedCat = ref.watch(selectedDuaCategoryProvider);
  final query = ref.watch(duaSearchQueryProvider).trim().toLowerCase();

  return verifiedDuasList.map((item) {
    return item.copyWith(isFavorite: favorites.contains(item.id));
  }).where((item) {
    // Kategori filtresi
    if (selectedCat != null && item.category != selectedCat) {
      return false;
    }
    // Arama sorgusu
    if (query.isNotEmpty) {
      final inTitle = item.title.toLowerCase().contains(query);
      final inMeaning = item.turkishMeaning.toLowerCase().contains(query);
      final inRef = item.reference.toLowerCase().contains(query);
      final inArabic = item.arabicText.contains(query);
      return inTitle || inMeaning || inRef || inArabic;
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
