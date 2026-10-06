import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Günlük ibadet takip modeli (5 vakit namaz + Kuran + zikir)
class DailyWorshipEntry {
  final String dateKey; // YYYY-MM-DD
  final bool fajr;
  final bool dhuhr;
  final bool asr;
  final bool maghrib;
  final bool isha;
  final bool quran;
  final bool zikr;

  const DailyWorshipEntry({
    required this.dateKey,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.quran = false,
    this.zikr = false,
  });

  int get completedCount {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    if (quran) count++;
    if (zikr) count++;
    return count;
  }

  double get completionRatio => completedCount / 7.0;

  DailyWorshipEntry copyWith({
    bool? fajr,
    bool? dhuhr,
    bool? asr,
    bool? maghrib,
    bool? isha,
    bool? quran,
    bool? zikr,
  }) {
    return DailyWorshipEntry(
      dateKey: dateKey,
      fajr: fajr ?? this.fajr,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      quran: quran ?? this.quran,
      zikr: zikr ?? this.zikr,
    );
  }

  Map<String, dynamic> toMap() => {
    'dateKey': dateKey,
    'fajr': fajr,
    'dhuhr': dhuhr,
    'asr': asr,
    'maghrib': maghrib,
    'isha': isha,
    'quran': quran,
    'zikr': zikr,
  };

  factory DailyWorshipEntry.fromMap(Map<String, dynamic> map) {
    return DailyWorshipEntry(
      dateKey: map['dateKey'] as String,
      fajr: map['fajr'] as bool? ?? false,
      dhuhr: map['dhuhr'] as bool? ?? false,
      asr: map['asr'] as bool? ?? false,
      maghrib: map['maghrib'] as bool? ?? false,
      isha: map['isha'] as bool? ?? false,
      quran: map['quran'] as bool? ?? false,
      zikr: map['zikr'] as bool? ?? false,
    );
  }
}

/// İbadet takip Notifier
class WorshipTrackerNotifier extends StateNotifier<Map<String, DailyWorshipEntry>> {
  static const _prefKey = 'worship_tracker_entries_v1';

  WorshipTrackerNotifier() : super({}) {
    _load();
  }

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefKey);
      if (jsonStr != null) {
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        final map = <String, DailyWorshipEntry>{};
        decoded.forEach((k, v) {
          map[k] = DailyWorshipEntry.fromMap(v as Map<String, dynamic>);
        });
        state = map;
      }
    } catch (_) {}
  }

  DailyWorshipEntry getToday() {
    final key = todayKey();
    return state[key] ?? DailyWorshipEntry(dateKey: key);
  }

  Future<void> toggleHabit({
    required String habitKey, // 'fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'quran', 'zikr'
  }) async {
    final key = todayKey();
    final current = getToday();
    DailyWorshipEntry updated;

    switch (habitKey) {
      case 'fajr':
        updated = current.copyWith(fajr: !current.fajr);
        break;
      case 'dhuhr':
        updated = current.copyWith(dhuhr: !current.dhuhr);
        break;
      case 'asr':
        updated = current.copyWith(asr: !current.asr);
        break;
      case 'maghrib':
        updated = current.copyWith(maghrib: !current.maghrib);
        break;
      case 'isha':
        updated = current.copyWith(isha: !current.isha);
        break;
      case 'quran':
        updated = current.copyWith(quran: !current.quran);
        break;
      case 'zikr':
        updated = current.copyWith(zikr: !current.zikr);
        break;
      default:
        return;
    }

    final newMap = Map<String, DailyWorshipEntry>.from(state);
    newMap[key] = updated;
    state = newMap;

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = <String, dynamic>{};
      newMap.forEach((k, v) => encoded[k] = v.toMap());
      await prefs.setString(_prefKey, json.encode(encoded));
    } catch (_) {}
  }
}

final worshipTrackerProvider =
    StateNotifierProvider<WorshipTrackerNotifier, Map<String, DailyWorshipEntry>>((ref) {
  return WorshipTrackerNotifier();
});
