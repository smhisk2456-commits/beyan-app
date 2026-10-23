import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/prayer_times/models/prayer_time_model.dart';
import '../../features/prayer_times/providers/prayer_time_providers.dart';
import 'app_theme.dart';
import 'beyan_colors.dart';

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
    BeyanColors.setPalette(AppThemePalette.emerald);
    _loadFromPrefs();
  }

  /// Namaz vaktine karşılık gelen birleşik uygulama paleti.
  static AppThemePalette paletteForPrayer(
    PrayerName? nextPrayer, {
    AppThemePalette fallback = AppThemePalette.emerald,
  }) {
    switch (nextPrayer) {
      case PrayerName.fajr:
      case PrayerName.isha:
        return AppThemePalette.deepSapphire;
      case PrayerName.sunrise:
      case PrayerName.asr:
        return AppThemePalette.desertMocha;
      case PrayerName.maghrib:
        return AppThemePalette.amethystNight;
      case PrayerName.dhuhr:
        return AppThemePalette.emerald;
      case null:
        return fallback;
    }
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

      BeyanColors.setPalette(palette);
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
    BeyanColors.setPalette(palette);
    state = state.copyWith(palette: palette, isDynamicPrayerTheme: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemePalette, palette.name);
    await prefs.setBool(_keyDynamicPrayerTheme, false);
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

/// Uygulamanın TÜM ekranlarında, alt barda ve kartlarında kullanılan
/// tek ve birleşik aktif renk paleti sağlayıcısı.
/// "Vakte Göre Canlı Tema" açık olduğunda bile tüm sekmeler ve alt bar
/// aynı paleti kullanarak parçalı renk oluşumunu %100 engeller.
final effectivePaletteProvider = Provider<AppThemePalette>((ref) {
  final themeState = ref.watch(themeProvider);
  AppThemePalette resolved = themeState.palette;
  if (themeState.isDynamicPrayerTheme) {
    final prayerAsync = ref.watch(prayerTimesNotifierProvider);
    final nextPrayerEntry = prayerAsync.valueOrNull?.nextPrayerEntry;
    if (nextPrayerEntry != null) {
      final timeUntil = nextPrayerEntry.timeUntil;
      if (!timeUntil.isNegative) {
        final timer = Timer(timeUntil + const Duration(seconds: 1), () {
          ref.invalidateSelf();
        });
        ref.onDispose(() => timer.cancel());
      }
    }
    resolved = ThemeNotifier.paletteForPrayer(
      nextPrayerEntry?.name,
      fallback: themeState.palette,
    );
  }
  BeyanColors.setPalette(resolved);
  return resolved;
});
