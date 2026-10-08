import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kullanıcının seçebileceği premium renk paletleri.
enum AppThemePalette {
  /// Klasik zümrüt yeşili ve altın
  emerald,

  /// OLED ekranlar için saf siyah ve amber altın
  oledBlack,

  /// Kâbe mermeri ve örtü hatları (Koyu bazalt füme)
  kaabaSlate,

  /// Gece göğü safiri ve şampanya altın
  deepSapphire,
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
        if (langCode == 'en') return 'Kaaba Slate Grey';
        if (langCode == 'ar') return 'رمادي رخام الكعبة';
        return 'Kâbe Taş Grisi';
      case AppThemePalette.deepSapphire:
        if (langCode == 'en') return 'Deep Sapphire Navy';
        if (langCode == 'ar') return 'الياقوت الكحلي';
        return 'Derin Lacivert';
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
        if (langCode == 'en') return 'Kaaba marble tones, noble slate and gold';
        if (langCode == 'ar') return 'ظلال رخام الكعبة والرمادي الأنيق مع الذهب';
        return 'Kâbe mermeri tonları, asil füme ve altın';
      case AppThemePalette.deepSapphire:
        if (langCode == 'en') return 'Night sky sapphire and champagne gold shimmer';
        if (langCode == 'ar') return 'سماء الليل الكحلية وبريق الذهب الشامباني';
        return 'Gece göğü safiri ve şampanya altın ışıltısı';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFF033E35);
      case AppThemePalette.oledBlack:
        return const Color(0xFF14171A);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFF262A2F);
      case AppThemePalette.deepSapphire:
        return const Color(0xFF0C1B33);
    }
  }

  Color get accentGold {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFFD4AF37);
      case AppThemePalette.oledBlack:
        return const Color(0xFFFFB800);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFFC5A059);
      case AppThemePalette.deepSapphire:
        return const Color(0xFFE5C07B);
    }
  }

  Color get darkBackground {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFF071B18);
      case AppThemePalette.oledBlack:
        return const Color(0xFF000000); // Gerçek OLED Black
      case AppThemePalette.kaabaSlate:
        return const Color(0xFF101214);
      case AppThemePalette.deepSapphire:
        return const Color(0xFF070E1A);
    }
  }

  Color get darkSurface {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFF0D2823);
      case AppThemePalette.oledBlack:
        return const Color(0xFF0B0D0F);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFF181B1E);
      case AppThemePalette.deepSapphire:
        return const Color(0xFF0E1C33);
    }
  }

  Color get darkCard {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFF133630);
      case AppThemePalette.oledBlack:
        return const Color(0xFF13171B);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFF22262B);
      case AppThemePalette.deepSapphire:
        return const Color(0xFF162947);
    }
  }

  Color get lightBackground {
    switch (this) {
      case AppThemePalette.emerald:
        return const Color(0xFFF4F7F5);
      case AppThemePalette.oledBlack:
        return const Color(0xFFF5F6F8);
      case AppThemePalette.kaabaSlate:
        return const Color(0xFFF6F5F2);
      case AppThemePalette.deepSapphire:
        return const Color(0xFFF2F5FA);
    }
  }

  Color get lightSurface => const Color(0xFFFFFFFF);

  Color get lightCard => const Color(0xFFFFFFFF);
}

/// Statik geri uyumluluk renkleri.
abstract class AppColors {
  static const Color primary = Color(0xFF033E35);
  static const Color primaryDark = Color(0xFF012E2B);
  static const Color primaryLight = Color(0xFF095A4D);

  static const Color emerald = Color(0xFF012E2B);
  static const Color emeraldLight = Color(0xFF064E43);
  static const Color teal = Color(0xFF033E35);
  static const Color tealDark = Color(0xFF012E2B);
  static const Color tealLight = Color(0xFF0A685A);
  static const Color green = Color(0xFF1B5E20);
  static const Color greenLight = Color(0xFF43A047);

  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  static const Color darkBackground = Color(0xFF071B18);
  static const Color darkSurface = Color(0xFF0D2823);
  static const Color darkCard = Color(0xFF133630);

  static const Color textPrimary = Color(0xFF11221F);
  static const Color textSecondary = Color(0xFF5B6E6A);
  static const Color textHint = Color(0xFF94A3A0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color arabicText = Color(0xFF11221F);
  static const Color arabicTextDark = Color(0xFFF5EEDB);

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFDF7A);
  static const Color goldDark = Color(0xFFAA8018);
  static const Color divider = Color(0xFFE2EBE8);
  static const Color shadow = Color(0x1A012E2B);
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
      dividerTheme: const DividerThemeData(
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
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
    );
  }
}
