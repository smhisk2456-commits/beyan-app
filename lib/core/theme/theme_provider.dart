import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Tema ve palet durumunu temsil eden model.
@immutable
class ThemeState {
  final ThemeMode mode;
  final AppThemePalette palette;
  final bool isDynamicPrayerTheme;

  const ThemeState({
    required this.mode,
    required this.palette,
    this.isDynamicPrayerTheme = false,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    AppThemePalette? palette,
    bool? isDynamicPrayerTheme,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
      isDynamicPrayerTheme: isDynamicPrayerTheme ?? this.isDynamicPrayerTheme,
    );
  }
}

/// Tema ve Renk Paletini yöneten Riverpod StateNotifier.
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _keyThemeMode = 'beyan_theme_mode';
  static const String _keyThemePalette = 'beyan_theme_palette';
  static const String _keyDynamicPrayerTheme = 'beyan_dynamic_prayer_theme';

  ThemeNotifier()
      : super(const ThemeState(
          mode: ThemeMode.system,
          palette: AppThemePalette.emerald,
          isDynamicPrayerTheme: false,
        )) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_keyThemeMode);
      final paletteStr = prefs.getString(_keyThemePalette);
      final dynamicPrayerTheme = prefs.getBool(_keyDynamicPrayerTheme) ?? false;

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

      state = ThemeState(
        mode: mode,
        palette: palette,
        isDynamicPrayerTheme: dynamicPrayerTheme,
      );
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

  Future<void> setDynamicPrayerTheme(bool enabled) async {
    state = state.copyWith(isDynamicPrayerTheme: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDynamicPrayerTheme, enabled);
  }
}

/// Tema durumu sağlayıcısı
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
