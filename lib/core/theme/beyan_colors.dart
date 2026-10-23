import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Palet Duyarlı Renk Motoru
///
/// Uygulamanın tasarımı zümrüt (yeşil) referans tonlarıyla çizilmiştir.
/// Bu motor, her referans tonu seçili paletin renk uzayına (ton / doygunluk /
/// parlaklık) matematiksel olarak taşır. Böylece tema değiştiğinde yalnızca
/// birkaç alan değil, uygulamanın TAMAMI (kartlar, gradyanlar, dock, sayfalar,
/// alt sayfalar, rozetler) tek bir bütün olarak yeni paletine bürünür.
class BeyanColors {
  BeyanColors._();

  static AppThemePalette _palette = AppThemePalette.emerald;
  static final Map<int, Color> _cache = {};

  /// Aktif palet
  static AppThemePalette get palette => _palette;

  /// Aktif paleti değiştirir (önbelleği temizler).
  static void setPalette(AppThemePalette p) {
    if (p == _palette) return;
    _palette = p;
    _cache.clear();
  }

  /// Zümrüt referans tonunu aktif palete uyarlar.
  static Color tone(int argb) {
    if (_palette == AppThemePalette.emerald) return Color(argb);
    return _cache.putIfAbsent(argb, () => toneFor(_palette, argb));
  }

  /// Zümrüt referans tonunu verilen palete uyarlar (önbelleksiz).
  static Color toneFor(AppThemePalette p, int argb) {
    final src = Color(argb);
    if (p == AppThemePalette.emerald) return src;
    final spec = _PaletteSpec.of(p);
    final hsl = HSLColor.fromColor(src);
    final h = hsl.hue, s = hsl.saturation, l = hsl.lightness;
    final alpha = src.a;

    // 1. Zümrüt / camgöbeği ailesi → paletin ana tonu
    if (isGreenFamily(h, s, l)) {
      HSLColor out;
      if (l >= 0.80) {
        // Açık mod zemin tonları
        out = HSLColor.fromAHSL(1, spec.hue, (s * spec.lightTintSat).clamp(0.0, 1.0), l);
      } else if (l >= 0.28) {
        // Parlak vurgu tonları (rozet, ikon, başarı rengi)
        out = HSLColor.fromAHSL(
          1,
          spec.accentHue,
          (s * spec.accentSat).clamp(0.0, 1.0),
          (l * spec.accentLight).clamp(0.0, 0.92),
        );
      } else {
        // Koyu zemin, kart ve gradyan tonları
        out = HSLColor.fromAHSL(
          1,
          spec.hue,
          (s * spec.satMul).clamp(0.0, 1.0),
          (l * spec.lightMul).clamp(0.0, 1.0),
        );
      }
      return out.toColor().withValues(alpha: alpha);
    }

    // 2. Altın ailesi → paletin vurgu metali (şampanya, kehribar, gül altını...)
    if (isGoldFamily(h, s, l)) {
      final out = HSLColor.fromAHSL(
        1,
        (h + spec.goldHueShift) % 360,
        (s * spec.goldSat).clamp(0.0, 1.0),
        (l * spec.goldLight).clamp(0.0, 0.95),
      );
      return out.toColor().withValues(alpha: alpha);
    }

    return src;
  }

  /// Uyarlanacak zümrüt/yeşil ton ailesi mi?
  static bool isGreenFamily(double h, double s, double l) {
    if (s < 0.08) return false;
    if (h >= 115 && h <= 190) return true;
    return false;
  }

  /// Uyarlanacak altın ailesi mi?
  static bool isGoldFamily(double h, double s, double l) {
    return h >= 36 && h <= 52 && s >= 0.35 && l >= 0.20 && l <= 0.80;
  }
}

/// Her paletin renk uzayı tanımı
class _PaletteSpec {
  final double hue;
  final double satMul;
  final double lightMul;
  final double accentHue;
  final double accentSat;
  final double accentLight;
  final double lightTintSat;
  final double goldHueShift;
  final double goldSat;
  final double goldLight;

  const _PaletteSpec({
    required this.hue,
    required this.satMul,
    required this.lightMul,
    required this.accentHue,
    required this.accentSat,
    this.accentLight = 1.0,
    required this.lightTintSat,
    this.goldHueShift = 0,
    this.goldSat = 1.0,
    this.goldLight = 1.0,
  });

  static _PaletteSpec of(AppThemePalette p) {
    switch (p) {
      case AppThemePalette.emerald:
        return const _PaletteSpec(hue: 170, satMul: 1, lightMul: 1, accentHue: 170, accentSat: 1, lightTintSat: 1);
      case AppThemePalette.deepSapphire:
        // Gece göğü safiri + şampanya altın
        return const _PaletteSpec(
          hue: 220, satMul: 0.70, lightMul: 1.10,
          accentHue: 212, accentSat: 0.80, accentLight: 1.05,
          lightTintSat: 0.70,
          goldHueShift: -4, goldSat: 0.72, goldLight: 1.04,
        );
      case AppThemePalette.oledBlack:
        // Zifiri siyah + sıcak kehribar
        return const _PaletteSpec(
          hue: 30, satMul: 0.05, lightMul: 0.55,
          accentHue: 38, accentSat: 0.85, accentLight: 1.1,
          lightTintSat: 0.05,
          goldHueShift: -6, goldSat: 1.0, goldLight: 1.0,
        );
      case AppThemePalette.kaabaSlate:
        // Kâbe örtüsü füme / grafit + antik altın
        return const _PaletteSpec(
          hue: 215, satMul: 0.10, lightMul: 1.18,
          accentHue: 205, accentSat: 0.30, accentLight: 1.1,
          lightTintSat: 0.10,
          goldHueShift: -5, goldSat: 0.62, goldLight: 0.98,
        );
      case AppThemePalette.ottomanBurgundy:
        // Osmanlı bordosu + saray altını
        return const _PaletteSpec(
          hue: 350, satMul: 0.62, lightMul: 1.02,
          accentHue: 352, accentSat: 0.65, accentLight: 1.12,
          lightTintSat: 0.45,
        );
      case AppThemePalette.amethystNight:
        // Seher moru / ametist + gül altını
        return const _PaletteSpec(
          hue: 266, satMul: 0.52, lightMul: 1.12,
          accentHue: 270, accentSat: 0.60, accentLight: 1.15,
          lightTintSat: 0.45,
          goldHueShift: -18, goldSat: 0.62, goldLight: 1.06,
        );
      case AppThemePalette.desertMocha:
        // Medine hurması / kahve + bal altını
        return const _PaletteSpec(
          hue: 24, satMul: 0.40, lightMul: 1.08,
          accentHue: 28, accentSat: 0.55, accentLight: 1.12,
          lightTintSat: 0.35,
          goldHueShift: -2, goldSat: 0.95, goldLight: 1.02,
        );
    }
  }
}
