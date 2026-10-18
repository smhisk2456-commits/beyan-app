import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ElifBaProgressState {
  final int totalXp;
  final int streakDays;
  final Set<String> completedLessonIds;

  const ElifBaProgressState({
    this.totalXp = 0,
    this.streakDays = 1,
    this.completedLessonIds = const {},
  });

  ElifBaProgressState copyWith({
    int? totalXp,
    int? streakDays,
    Set<String>? completedLessonIds,
  }) {
    return ElifBaProgressState(
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
    );
  }
}

class ElifBaProgressNotifier extends StateNotifier<ElifBaProgressState> {
  static const String _keyXp = 'elif_ba_total_xp';
  static const String _keyStreak = 'elif_ba_streak_days';
  static const String _keyCompleted = 'elif_ba_completed_lessons';

  ElifBaProgressNotifier() : super(const ElifBaProgressState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final xp = prefs.getInt(_keyXp) ?? 0;
      final streak = prefs.getInt(_keyStreak) ?? 1;
      final completed = prefs.getStringList(_keyCompleted)?.toSet() ?? {};

      state = ElifBaProgressState(
        totalXp: xp,
        streakDays: streak,
        completedLessonIds: completed,
      );
    } catch (_) {}
  }

  Future<void> completeLesson(String lessonId, int earnedXp) async {
    try {
      final updatedCompleted = Set<String>.from(state.completedLessonIds)..add(lessonId);
      final updatedXp = state.totalXp + earnedXp;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyXp, updatedXp);
      await prefs.setStringList(_keyCompleted, updatedCompleted.toList());

      state = state.copyWith(
        totalXp: updatedXp,
        completedLessonIds: updatedCompleted,
      );
    } catch (_) {}
  }
}

final elifBaProgressProvider =
    StateNotifierProvider<ElifBaProgressNotifier, ElifBaProgressState>((ref) {
  return ElifBaProgressNotifier();
});
