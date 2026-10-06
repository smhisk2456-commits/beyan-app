import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulamanın renk paleti ve tema tanımları.
/// Yeşil/Teal tonları esas alınmıştır.
abstract class AppColors {
  // ── Primary Palette (Derin Zümrüt Yeşili) ─────────────────────
  static const Color primary = Color(0xFF033E35);
  static const Color primaryDark = Color(0xFF012E2B);
  static const Color primaryLight = Color(0xFF095A4D);

  // ── Emerald & Green Accents ──────────────────────────────────
  static const Color emerald = Color(0xFF012E2B);
  static const Color emeraldLight = Color(0xFF064E43);
  static const Color teal = Color(0xFF033E35);
  static const Color tealDark = Color(0xFF012E2B);
  static const Color tealLight = Color(0xFF0A685A);
  static const Color green = Color(0xFF1B5E20);
  static const Color greenLight = Color(0xFF43A047);

  // ── Background & Surface ─────────────────────────────────────
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // ── Dark Theme (Derin Gece Zümrüdü) ──────────────────────────
  static const Color darkBackground = Color(0xFF071B18);
  static const Color darkSurface = Color(0xFF0D2823);
  static const Color darkCard = Color(0xFF133630);

  // ── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF11221F);
  static const Color textSecondary = Color(0xFF5B6E6A);
  static const Color textHint = Color(0xFF94A3A0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Arabic Text ──────────────────────────────────────────────
  static const Color arabicText = Color(0xFF11221F);
  static const Color arabicTextDark = Color(0xFFF5EEDB);  // Lüks Fildişi ton

  // ── Semantic & Luxury Gold ───────────────────────────────────
  static const Color gold = Color(0xFFD4AF37);            // Asil İslami Altın
  static const Color goldLight = Color(0xFFFFDF7A);       // Parlak Altın Vurgu
  static const Color goldDark = Color(0xFFAA8018);
  static const Color divider = Color(0xFFE2EBE8);
  static const Color shadow = Color(0x1A012E2B);
}

/// Uygulama genelinde kullanılan metin stilleri.
abstract class AppTextStyles {
  /// Arapça metinler için özel stil – Amiri fontu ile
  static TextStyle arabicLarge({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28.0,
    // Harekelerin kesişmemesi için geniş satır yüksekliği
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

  /// Başlık stilleri – Amiri (başlıklar için)
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

/// Ana tema yapılandırması.
abstract class AppTheme {
  // ─────────────────────────── Light Theme ──────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // ── Renk Şeması ─────────────────────────────────────────────
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.primary,
      tertiary: AppColors.gold,
      surface: AppColors.surface,
      error: const Color(0xFFD32F2F),
      brightness: Brightness.light,
    ),

    // ── Scaffold ─────────────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,

    // ── AppBar ───────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.teal,
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

    // ── Card ─────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.cardColor,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // ── Elevated Button ──────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
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

    // ── Text Theme ───────────────────────────────────────────────
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

    // ── Divider ──────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ── Bottom Navigation ────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.textHint,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.lato(fontSize: 12),
    ),

    // ── Input Decoration ─────────────────────────────────────────
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
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
    ),
  );

  // ─────────────────────────── Dark Theme ───────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.tealLight,
      secondary: AppColors.primaryLight,
      tertiary: AppColors.gold,
      surface: AppColors.darkSurface,
      error: const Color(0xFFEF5350),
      brightness: Brightness.dark,
    ),

    scaffoldBackgroundColor: AppColors.darkBackground,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.lato(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    dividerTheme: const DividerThemeData(
      color: Color(0xFF2D4A6A),
      thickness: 1,
      space: 1,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.tealLight,
      unselectedItemColor: Colors.white38,
      elevation: 8,
    ),
  );
}
