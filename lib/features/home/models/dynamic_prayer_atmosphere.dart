import 'package:flutter/material.dart';
import 'package:islamic_app/core/theme/app_theme.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import '../../prayer_times/models/prayer_time_model.dart';

/// Tüm uygulamanın ve ana ekranın namaz vaktine göre tek bir bütün olarak
/// (alt bar ve diğer sekmelerle %100 aynı renk uzayında) değişmesini sağlayan atmosfer modeli.
class DynamicPrayerAtmosphere {
  final List<Color> backgroundGradient;
  final List<Color> cardGradient;
  final Color appBarColor;
  final Color accentGold;
  final Color glowColor;
  final Color cardBorder;
  final Color actionCardBg;
  final Color actionCardBorder;

  const DynamicPrayerAtmosphere({
    required this.backgroundGradient,
    required this.cardGradient,
    required this.appBarColor,
    required this.accentGold,
    required this.glowColor,
    required this.cardBorder,
    required this.actionCardBg,
    required this.actionCardBorder,
  });

  static DynamicPrayerAtmosphere forPrayer(PrayerName? prayer) {
    final palette = ThemeNotifier.paletteForPrayer(
      prayer,
      fallback: BeyanColors.palette,
    );
    Color t(int argb) => BeyanColors.toneFor(palette, argb);

    return DynamicPrayerAtmosphere(
      backgroundGradient: [
        palette.darkBackground,
        t(0xFF0A221E),
        t(0xFF041210),
      ],
      cardGradient: palette.prayerCardGradient,
      appBarColor: palette.darkSurface,
      accentGold: palette.accentGoldLight,
      glowColor: palette.prayerCardGlow,
      cardBorder: palette.accentGold,
      actionCardBg: palette.darkSurface,
      actionCardBorder: t(0xFF133B34),
    );
  }
}
