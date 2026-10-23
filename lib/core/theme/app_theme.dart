import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beyan_colors.dart';

/// Kullanıcının seçebileceği premium renk paletleri.
///
/// Her palet, [BeyanColors] motoru üzerinden uygulamanın TÜM yüzeylerine
/// (zemin, kart, gradyan, dock, rozet, alt sayfa) tek bütün olarak uygulanır.
enum AppThemePalette {
  /// Klasik zümrüt yeşili ve altın
  emerald,

  /// OLED ekranlar için saf siyah ve amber altın
  oledBlack,

  /// Kâbe örtüsü füme / grafit ve antik altın
  kaabaSlate,

  /// Gece göğü safiri ve şampanya altın
  deepSapphire,

  /// Osmanlı bordosu ve saray altını
  ottomanBurgundy,

  /// Seher moru (ametist) ve gül altını
  amethystNight,

  /// Medine hurması kahvesi ve bal altını
  desertMocha,
}

extension AppThemePaletteExtension on AppThemePalette {
  String get title => localizedTitle('tr');

  String localizedTitle(String langCode) {
    switch (this) {
      case AppThemePalette.emerald:
        if (langCode == 'en') return 'Emerald & Gold';
        if (langCode == 'ar') return 'الزمرد والذهب';
        return 'Zümrüt & Altın';
      case AppThemePalette.oledBlack:
        if (langCode == 'en') return 'Midnight Black (OLED)';
        if (langCode == 'ar') return 'الأسود الليلي (OLED)';
        return 'Gece Siyahı (OLED)';
      case AppThemePalette.kaabaSlate:
        if (langCode == 'en') return 'Kaaba Graphite';
        if (langCode == 'ar') return 'جرافيت الكعبة';
        return 'Kâbe Füme';
      case AppThemePalette.deepSapphire:
        if (langCode == 'en') return 'Deep Sapphire Navy';
        if (langCode == 'ar') return 'الياقوت الكحلي';
        return 'Derin Lacivert';
      case AppThemePalette.ottomanBurgundy:
        if (langCode == 'en') return 'Ottoman Burgundy';
        if (langCode == 'ar') return 'العنابي العثماني';
        return 'Osmanlı Bordosu';
      case AppThemePalette.amethystNight:
        if (langCode == 'en') return 'Amethyst Dawn';
        if (langCode == 'ar') return 'جمشت السحر';
        return 'Seher Moru';
      case AppThemePalette.desertMocha:
        if (langCode == 'en') return 'Medina Date Mocha';
        if (langCode == 'ar') return 'تمر المدينة';
        return 'Medine Hurması';
    }
  }

  String get description => localizedDescription('tr');

  String localizedDescription(String langCode) {
    switch (this) {
      case AppThemePalette.emerald:
        if (langCode == 'en') return 'Traditional dignified emerald green and noble gold';
        if (langCode == 'ar') return 'الأخضر الزمردي الوقور والذهب الأصيل';
        return 'Geleneksel vakarlı zümrüt yeşili ve asil altın';
      case AppThemePalette.oledBlack:
        if (langCode == 'en') return 'Pure deep black and warm amber, OLED-friendly';
        if (langCode == 'ar') return 'سواد نقي عميق وعنبر دافئ لشاشات أوليد';
        return 'Saf zifiri siyah ve sıcak kehribar, OLED dostu';
      case AppThemePalette.kaabaSlate:
        if (langCode == 'en') return 'Kiswah graphite, steel grey and antique gold';
        if (langCode == 'ar') return 'جرافيت الكسوة والرمادي الفولاذي والذهب العتيق';
        return 'Kâbe örtüsü grafiti, çelik gri ve antik altın';
      case AppThemePalette.deepSapphire:
        if (langCode == 'en') return 'Night sky sapphire and champagne gold shimmer';
        if (langCode == 'ar') return 'سماء الليل الكحلية وبريق الذهب الشامباني';
        return 'Gece göğü safiri ve şampanya altın ışıltısı';
      case AppThemePalette.ottomanBurgundy:
        if (langCode == 'en') return 'Imperial burgundy velvet and palace gold';
        if (langCode == 'ar') return 'المخمل العنابي الإمبراطوري وذهب القصور';
        return 'Saray kadifesi bordo ve Osmanlı altını';
      case AppThemePalette.amethystNight:
        if (langCode == 'en') return 'Pre-dawn amethyst violet and rose gold';
        if (langCode == 'ar') return 'بنفسجي السحر وذهب وردي';
        return 'Seher vaktinin ametist moru ve gül altını';
      case AppThemePalette.desertMocha:
        if (langCode == 'en') return 'Warm date-palm mocha and honey gold';
        if (langCode == 'ar') return 'بني التمر الدافئ وذهب العسل';
        return 'Sıcak hurma kahvesi ve bal altını';
    }
  }

  /// Zümrüt referans tonunu bu palete uyarlar.
  Color _t(int argb) => BeyanColors.toneFor(this, argb);

  Color get primaryColor => _t(0xFF033E35);

  Color get accentGold => _t(0xFFD4AF37);

  Color get accentGoldLight => _t(0xFFFFDF7A);

  Color get darkBackground {
    if (this == AppThemePalette.oledBlack) return const Color(0xFF000000);
    return _t(0xFF071B18);
  }

  Color get darkSurface => _t(0xFF0D2823);

  Color get darkCard => _t(0xFF133630);

  /// Namaz vakti ana kartı için palete özel uyumlu lüks gradyan
  List<Color> get prayerCardGradient => [
        _t(0xFF02362E),
        _t(0xFF01201B),
        _t(0xFF03443A),
      ];

  /// Namaz vakti ana kartı için ışıltı rengi
  Color get prayerCardGlow {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFF00BFA5);
      case AppThemePalette.oledBlack:
        return const Color(0xFFFFB800);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFFC5A059);
      case AppThemePalette.deepSapphire:
        return const Color(0xFF5C8DF0);
      case AppThemePalette.ottomanBurgundy:
        return const Color(0xFFE0526B);
      case AppThemePalette.amethystNight:
        return const Color(0xFFA77BF3);
      case AppThemePalette.desertMocha:
        return const Color(0xFFE0A15A);
    }
  }

  /// Tema seçicide önizleme için 3 tonlu gradyan
  List<Color> get previewGradient => [
        darkBackground,
        darkCard,
        primaryColor,
      ];

  Color get lightBackground => _t(0xFFF4F7F5);

  Color get lightSurface => const Color(0xFFFFFFFF);

  Color get lightCard => const Color(0xFFFFFFFF);
}

/// Palet duyarlı geri uyumluluk renkleri.
abstract class AppColors {
  static Color get primary => BeyanColors.tone(0xFF033E35);
  static Color get primaryDark => BeyanColors.tone(0xFF012E2B);
  static Color get primaryLight => BeyanColors.tone(0xFF095A4D);

  static Color get emerald => BeyanColors.tone(0xFF012E2B);
  static Color get emeraldLight => BeyanColors.tone(0xFF064E43);
  static Color get teal => BeyanColors.tone(0xFF033E35);
  static Color get tealDark => BeyanColors.tone(0xFF012E2B);
  static Color get tealLight => BeyanColors.tone(0xFF0A685A);
  static Color get green => BeyanColors.tone(0xFF1B5E20);
  static const Color greenLight = Color(0xFF43A047);

  static Color get background => BeyanColors.tone(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  static Color get darkBackground => BeyanColors.palette.darkBackground;
  static Color get darkSurface => BeyanColors.tone(0xFF0D2823);
  static Color get darkCard => BeyanColors.tone(0xFF133630);

  static const Color textPrimary = Color(0xFF11221F);
  static const Color textSecondary = Color(0xFF5B6E6A);
  static const Color textHint = Color(0xFF94A3A0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color arabicText = Color(0xFF11221F);
  static const Color arabicTextDark = Color(0xFFF5EEDB);

  static Color get gold => BeyanColors.tone(0xFFD4AF37);
  static Color get goldLight => BeyanColors.tone(0xFFFFDF7A);
  static Color get goldDark => BeyanColors.tone(0xFFAA8018);
  static Color get divider => BeyanColors.tone(0xFFE2EBE8);
  static Color get shadow => BeyanColors.tone(0x1A012E2B);
}

/// Tipografi
abstract class AppTextStyles {
  static TextStyle arabicLarge({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28.0,
    height: 2.0,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.arabicText,
    letterSpacing: 0.5,
  );

  static TextStyle arabicMedium({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22.0,
    height: 2.0,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.arabicText,
    letterSpacing: 0.5,
  );

  static TextStyle arabicSmall({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18.0,
    height: 1.8,
    fontWeight: FontWeight.normal,
    color: color ?? AppColors.arabicText,
  );

  static TextStyle headingLarge({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle headingMedium({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: color ?? AppColors.textPrimary,
    height: 1.4,
  );
}

/// Dinamik ve Palet Duyarlı Tema Fabrikası.
abstract class AppTheme {
  /// Varsayılan Light Theme
  static ThemeData get lightTheme => buildTheme(AppThemePalette.emerald, isDark: false);

  /// Varsayılan Dark Theme
  static ThemeData get darkTheme => buildTheme(AppThemePalette.emerald, isDark: true);

  /// Seçili palete göre tema inşa eder.
  static ThemeData buildTheme(AppThemePalette palette, {required bool isDark}) {
    if (isDark) {
      return _buildDarkTheme(palette);
    } else {
      return _buildLightTheme(palette);
    }
  }

  static ThemeData _buildLightTheme(AppThemePalette palette) {
    final primary = palette.primaryColor;
    final gold = palette.accentGold;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primary,
        tertiary: gold,
        surface: palette.lightSurface,
        error: const Color(0xFFD32F2F),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: palette.lightBackground,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: palette.lightCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: GoogleFonts.latoTextTheme().copyWith(
        displayLarge: GoogleFonts.lato(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.lato(
          fontSize: 12,
          color: AppColors.textHint,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: gold.withValues(alpha: 0.45), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme(AppThemePalette palette) {
    final bg = palette.darkBackground;
    final surface = palette.darkSurface;
    final card = palette.darkCard;
    final gold = palette.accentGold;
    final primary = palette.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: gold,
        secondary: primary,
        tertiary: gold,
        surface: surface,
        error: const Color(0xFFEF5350),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: bg,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: gold),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: gold.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.lato(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: GoogleFonts.lato(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white38,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BeyanColors.toneFor(palette, 0xFF0A382E),
        contentTextStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: gold.withValues(alpha: 0.55), width: 1.2),
        ),
      ),
    );
  }
}
