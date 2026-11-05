import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_constants.dart';
import '../models/kaza_tracker_model.dart';

class KazaTrackerNotifier extends StateNotifier<KazaTrackerState> {
  static const String _prefsKey = 'beyan_kaza_tracker_v1';

  KazaTrackerNotifier() : super(KazaTrackerState.empty()) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_prefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        state = KazaTrackerState.fromJson(jsonStr);
        await _syncToWidget();
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, state.toJson());
      await _syncToWidget();
    } catch (_) {}
  }

  Future<void> _syncToWidget() async {
    try {
      await HomeWidget.setAppGroupId(AppConstants.appGroupId);
      await HomeWidget.saveWidgetData<int>('widget_kaza_total', state.totalRemainingPrayers);
      await HomeWidget.saveWidgetData<int>('widget_kaza_fajr', state.getCount(KazaType.fajr));
      await HomeWidget.saveWidgetData<int>('widget_kaza_dhuhr', state.getCount(KazaType.dhuhr));
      await HomeWidget.saveWidgetData<int>('widget_kaza_asr', state.getCount(KazaType.asr));
      await HomeWidget.saveWidgetData<int>('widget_kaza_maghrib', state.getCount(KazaType.maghrib));
      await HomeWidget.saveWidgetData<int>('widget_kaza_isha', state.getCount(KazaType.isha));
      await HomeWidget.saveWidgetData<int>('widget_kaza_vitr', state.getCount(KazaType.witr));
      await HomeWidget.saveWidgetData<int>('widget_kaza_fasting', state.getCount(KazaType.fasting));

      final summary = 'S:${state.getCount(KazaType.fajr)} Ö:${state.getCount(KazaType.dhuhr)} İ:${state.getCount(KazaType.asr)} A:${state.getCount(KazaType.maghrib)} Y:${state.getCount(KazaType.isha)}';
      await HomeWidget.saveWidgetData<String>('widget_kaza_summary', summary);

      await HomeWidget.updateWidget(
        name: 'BeyanKazaWidget',
        iOSName: 'BeyanKazaWidget',
      );
    } catch (_) {}
  }

  /// 1 Vakit Kaza Kılındı: Kalan borç 1 azalır
  void markCompleted(KazaType type, {int amount = 1}) {
    final current = state.getCount(type);
    if (current <= 0) return;

    final newRemaining = Map<KazaType, int>.from(state.remaining);
    final decremented = (current - amount).clamp(0, 999999);
    newRemaining[type] = decremented;

    final newHistory = List<KazaHistoryEntry>.from(state.history)
      ..add(
        KazaHistoryEntry(
          type: type,
          change: -amount,
          timestamp: DateTime.now(),
        ),
      );

    // Geçmişi son 50 işlemle sınırla
    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(
      remaining: newRemaining,
      history: newHistory,
    );
    _saveToPrefs();
  }

  /// 1 Günlük Tam Kaza Kılındı: 6 vaktin tamamından (Sabah, Öğle, İkindi, Akşam, Yatsı, Vitir) 1'er adet düşer!
  void markFullDailySetCompleted() {
    final newRemaining = Map<KazaType, int>.from(state.remaining);
    bool changed = false;

    for (final type in KazaType.values) {
      if (type.isPrayer) {
        final current = newRemaining[type] ?? 0;
        if (current > 0) {
          newRemaining[type] = current - 1;
          changed = true;
        }
      }
    }

    if (!changed) return;

    final newHistory = List<KazaHistoryEntry>.from(state.history)
      ..add(
        KazaHistoryEntry(
          type: KazaType.fajr,
          change: -6,
          timestamp: DateTime.now(),
          isFullDailySet: true,
        ),
      );

    if (newHistory.length > 50) {
      newHistory.removeAt(0);
    }

    state = state.copyWith(
      remaining: newRemaining,
      history: newHistory,
    );
    _saveToPrefs();
  }

  /// Kaza sayısını doğrudan belirleme veya artırma
  void setCount(KazaType type, int count, {bool updateInitial = false}) {
    final newRemaining = Map<KazaType, int>.from(state.remaining);
    final newInitial = Map<KazaType, int>.from(state.initial);

    newRemaining[type] = count.clamp(0, 999999);
    if (updateInitial || count > (newInitial[type] ?? 0)) {
      newInitial[type] = count;
    }

    state = state.copyWith(
      remaining: newRemaining,
      initial: newInitial,
    );
    _saveToPrefs();
  }

  /// Süreye (Yıl, Ay, Gün) göre otomatik kaza hesabı
  /// Örneğin: 2 Yıl 3 Ay kaza borcu girildiğinde;
  /// Toplam Gün = (2 * 365) + (3 * 30) = 820 gün
  /// Her 6 vakit kaza namazı için 820'şer vakit borç yazılır.
  void calculateFromDuration({
    required int years,
    required int months,
    int days = 0,
    int? customFastingDays,
  }) {
    final totalDays = (years * 365) + (months * 30) + days;
    if (totalDays <= 0) return;

    final newRemaining = <KazaType, int>{};
    final newInitial = <KazaType, int>{};

    for (final type in KazaType.values) {
      if (type.isPrayer) {
        newRemaining[type] = totalDays;
        newInitial[type] = totalDays;
      }
    }

    // Oruç borcu (Varsayılan olarak yıl sayısı kadar Ramazan ayı: Yıl * 30 gün)
    final fasting = customFastingDays ?? (years * 30);
    newRemaining[KazaType.fasting] = fasting;
    newInitial[KazaType.fasting] = fasting;

    state = KazaTrackerState(
      remaining: newRemaining,
      initial: newInitial,
      dailyGoalPrayers: state.dailyGoalPrayers,
      history: const [],
    );
    _saveToPrefs();
  }

  /// Son yapılan işlemi geri al (Undo)
  bool undo() {
    if (state.history.isEmpty) return false;

    final newHistory = List<KazaHistoryEntry>.from(state.history);
    final lastAction = newHistory.removeLast();

    final newRemaining = Map<KazaType, int>.from(state.remaining);

    if (lastAction.isFullDailySet) {
      // 1 tam günlük kaza geri alınır (her vakit +1 eklenir)
      for (final type in KazaType.values) {
        if (type.isPrayer) {
          newRemaining[type] = (newRemaining[type] ?? 0) + 1;
        }
      }
    } else {
      // Tekil işlem geri alınır
      final current = newRemaining[lastAction.type] ?? 0;
      newRemaining[lastAction.type] = (current - lastAction.change).clamp(0, 999999);
    }

    state = state.copyWith(
      remaining: newRemaining,
      history: newHistory,
    );
    _saveToPrefs();
    return true;
  }

  /// Günlük kaza hedefini güncelle (Örn: Günde 2 vakit veya 6 vakit)
  void setDailyGoal(int goal) {
    state = state.copyWith(dailyGoalPrayers: goal.clamp(1, 60));
    _saveToPrefs();
  }

  /// Tüm verileri sıfırla
  void reset() {
    state = KazaTrackerState.empty();
    _saveToPrefs();
  }
}

final kazaTrackerProvider =
    StateNotifierProvider<KazaTrackerNotifier, KazaTrackerState>((ref) {
  return KazaTrackerNotifier();
});
