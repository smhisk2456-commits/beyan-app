import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Tema ve palet durumunu temsil eden model.
@immutable
class ThemeState {
  final ThemeMode mode;
  final AppThemePalette palette;

  const ThemeState({
    required this.mode,
    required this.palette,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    AppThemePalette? palette,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
    );
  }
}

/// Tema ve Renk Paletini yöneten Riverpod StateNotifier.
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _keyThemeMode = 'beyan_theme_mode';
  static const String _keyThemePalette = 'beyan_theme_palette';

  ThemeNotifier()
      : super(const ThemeState(
          mode: ThemeMode.system,
          palette: AppThemePalette.emerald,
        )) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_keyThemeMode);
      final paletteStr = prefs.getString(_keyThemePalette);

      ThemeMode mode = ThemeMode.system;
      if (modeStr == 'light') mode = ThemeMode.light;
      if (modeStr == 'dark') mode = ThemeMode.dark;

      AppThemePalette palette = AppThemePalette.emerald;
      if (paletteStr != null) {
        palette = AppThemePalette.values.firstWhere(
          (p) => p.name == paletteStr,
          orElse: () => AppThemePalette.emerald,
        );
      }

      state = ThemeState(mode: mode, palette: palette);
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await prefs.setString(_keyThemeMode, modeStr);
  }

  Future<void> setPalette(AppThemePalette palette) async {
    state = state.copyWith(palette: palette);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemePalette, palette.name);
  }
}

/// Tema durumu sağlayıcısı
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
