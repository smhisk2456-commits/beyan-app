import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kur'an-ı Kerim Cüz Bilgisi
class QuranJuzInfo {
  final int juzNumber;
  final String startSurah;
  final int startAyah;
  final int startPage;
  final int endPage;

  const QuranJuzInfo({
    required this.juzNumber,
    required this.startSurah,
    required this.startAyah,
    required this.startPage,
    required this.endPage,
  });

  int get pageCount => (endPage - startPage) + 1;
}

/// Standart 30 Cüz Listesi (Mushaf Sayfa Aralıklarıyla)
final List<QuranJuzInfo> quranJuzList = [
  const QuranJuzInfo(juzNumber: 1, startSurah: 'Fâtiha', startAyah: 1, startPage: 1, endPage: 21),
  const QuranJuzInfo(juzNumber: 2, startSurah: 'Bakara', startAyah: 142, startPage: 22, endPage: 41),
  const QuranJuzInfo(juzNumber: 3, startSurah: 'Bakara', startAyah: 253, startPage: 42, endPage: 61),
  const QuranJuzInfo(juzNumber: 4, startSurah: 'Âl-i İmrân', startAyah: 93, startPage: 62, endPage: 81),
  const QuranJuzInfo(juzNumber: 5, startSurah: 'Nisâ', startAyah: 24, startPage: 82, endPage: 101),
  const QuranJuzInfo(juzNumber: 6, startSurah: 'Nisâ', startAyah: 148, startPage: 102, endPage: 121),
  const QuranJuzInfo(juzNumber: 7, startSurah: 'Mâide', startAyah: 82, startPage: 122, endPage: 141),
  const QuranJuzInfo(juzNumber: 8, startSurah: 'En\'âm', startAyah: 111, startPage: 142, endPage: 161),
  const QuranJuzInfo(juzNumber: 9, startSurah: 'A\'râf', startAyah: 88, startPage: 162, endPage: 181),
  const QuranJuzInfo(juzNumber: 10, startSurah: 'Enfâl', startAyah: 41, startPage: 182, endPage: 201),
  const QuranJuzInfo(juzNumber: 11, startSurah: 'Tevbe', startAyah: 93, startPage: 202, endPage: 221),
  const QuranJuzInfo(juzNumber: 12, startSurah: 'Hûd', startAyah: 6, startPage: 222, endPage: 241),
  const QuranJuzInfo(juzNumber: 13, startSurah: 'Yûsuf', startAyah: 53, startPage: 242, endPage: 261),
  const QuranJuzInfo(juzNumber: 14, startSurah: 'Hicr', startAyah: 1, startPage: 262, endPage: 281),
  const QuranJuzInfo(juzNumber: 15, startSurah: 'İsrâ', startAyah: 1, startPage: 282, endPage: 301),
  const QuranJuzInfo(juzNumber: 16, startSurah: 'Kehf', startAyah: 75, startPage: 302, endPage: 321),
  const QuranJuzInfo(juzNumber: 17, startSurah: 'Enbiyâ', startAyah: 1, startPage: 322, endPage: 341),
  const QuranJuzInfo(juzNumber: 18, startSurah: 'Mü\'minûn', startAyah: 1, startPage: 342, endPage: 361),
  const QuranJuzInfo(juzNumber: 19, startSurah: 'Furkân', startAyah: 21, startPage: 362, endPage: 381),
  const QuranJuzInfo(juzNumber: 20, startSurah: 'Neml', startAyah: 56, startPage: 382, endPage: 401),
  const QuranJuzInfo(juzNumber: 21, startSurah: 'Ankebût', startAyah: 46, startPage: 402, endPage: 421),
  const QuranJuzInfo(juzNumber: 22, startSurah: 'Ahzâb', startAyah: 31, startPage: 422, endPage: 441),
  const QuranJuzInfo(juzNumber: 23, startSurah: 'Yâsîn', startAyah: 28, startPage: 442, endPage: 461),
  const QuranJuzInfo(juzNumber: 24, startSurah: 'Zümer', startAyah: 32, startPage: 462, endPage: 481),
  const QuranJuzInfo(juzNumber: 25, startSurah: 'Fussilet', startAyah: 47, startPage: 482, endPage: 501),
  const QuranJuzInfo(juzNumber: 26, startSurah: 'Ahkâf', startAyah: 1, startPage: 502, endPage: 521),
  const QuranJuzInfo(juzNumber: 27, startSurah: 'Zâriyât', startAyah: 31, startPage: 522, endPage: 541),
  const QuranJuzInfo(juzNumber: 28, startSurah: 'Mücâdele', startAyah: 1, startPage: 542, endPage: 561),
  const QuranJuzInfo(juzNumber: 29, startSurah: 'Mülk', startAyah: 1, startPage: 562, endPage: 581),
  const QuranJuzInfo(juzNumber: 30, startSurah: 'Nebe', startAyah: 1, startPage: 582, endPage: 604),
];

/// Hatim Takip Durumu
class KhatamProgressState {
  final Set<int> completedJuzs;

  const KhatamProgressState({required this.completedJuzs});

  bool isCompleted(int juzNumber) => completedJuzs.contains(juzNumber);
  int get completedCount => completedJuzs.length;
  double get percentage => (completedCount / 30.0).clamp(0.0, 1.0);
  bool get isEntireQuranCompleted => completedCount == 30;
}

/// Hatim Takip State Notifier
class KhatamProgressNotifier extends StateNotifier<KhatamProgressState> {
  static const _keyCompleted = 'beyan_khatam_completed_juzs';

  KhatamProgressNotifier() : super(const KhatamProgressState(completedJuzs: {})) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyCompleted) ?? [];
      final set = list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
      state = KhatamProgressState(completedJuzs: set);
    } catch (_) {}
  }

  Future<void> toggleJuz(int juzNumber) async {
    final updated = Set<int>.from(state.completedJuzs);
    if (updated.contains(juzNumber)) {
      updated.remove(juzNumber);
    } else {
      updated.add(juzNumber);
    }
    state = KhatamProgressState(completedJuzs: updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyCompleted,
        updated.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  Future<void> resetAll() async {
    state = const KhatamProgressState(completedJuzs: {});
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCompleted);
    } catch (_) {}
  }
}

final khatamProgressProvider =
    StateNotifierProvider<KhatamProgressNotifier, KhatamProgressState>((ref) {
  return KhatamProgressNotifier();
});
