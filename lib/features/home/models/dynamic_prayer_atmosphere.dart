import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import '../../prayer_times/models/prayer_time_model.dart';

/// Tüm ana ekranın namaz vaktine göre uyum içinde birlikte değişmesini sağlayan atmosfer modeli
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
    switch (prayer) {
      case PrayerName.fajr: // İmsak / Sabah (Seher Vakti - Mavi/Lacivert Şafak)
        return DynamicPrayerAtmosphere(
          backgroundGradient: [const Color(0xFF030D16), const Color(0xFF071926), const Color(0xFF02080E)],
          cardGradient: [const Color(0xFF0A2234), const Color(0xFF051522), const Color(0xFF0E2C44)],
          appBarColor: const Color(0xFF030D16),
          accentGold: BeyanColors.tone(0xFFFFDF7A),
          glowColor: const Color(0xFF38BDF8),
          cardBorder: const Color(0xFF38BDF8),
          actionCardBg: const Color(0xFF091E2C),
          actionCardBorder: const Color(0xFF13364D),
        );
      case PrayerName.sunrise: // Güneş (İşrak - Altın Doğan Güneş Işığı)
        return DynamicPrayerAtmosphere(
          backgroundGradient: [const Color(0xFF16170D), const Color(0xFF242211), const Color(0xFF0F1008)],
          cardGradient: [const Color(0xFF2F2A15), const Color(0xFF1E1B0D), const Color(0xFF3A341A)],
          appBarColor: const Color(0xFF16170D),
          accentGold: BeyanColors.tone(0xFFFFD54F),
          glowColor: const Color(0xFFFFB74D),
          cardBorder: BeyanColors.tone(0xFFFFD54F),
          actionCardBg: const Color(0xFF221F0F),
          actionCardBorder: const Color(0xFF3F3818),
        );
      case PrayerName.dhuhr: // Öğle (Zümrüt Yeşil & Gün Ortası Işıltısı)
        return DynamicPrayerAtmosphere(
          backgroundGradient: [BeyanColors.tone(0xFF011815), BeyanColors.tone(0xFF02241F), BeyanColors.tone(0xFF01120F)],
          cardGradient: [BeyanColors.tone(0xFF033E35), BeyanColors.tone(0xFF012720), BeyanColors.tone(0xFF06473D)],
          appBarColor: BeyanColors.tone(0xFF011815),
          accentGold: BeyanColors.tone(0xFFFFDF7A),
          glowColor: BeyanColors.tone(0xFF00BFA5),
          cardBorder: BeyanColors.tone(0xFFD4AF37),
          actionCardBg: BeyanColors.tone(0xFF0D2823),
          actionCardBorder: BeyanColors.tone(0xFF133B34),
        );
      case PrayerName.asr: // İkindi (Sıcak İkindi Kehribarı)
        return DynamicPrayerAtmosphere(
          backgroundGradient: [const Color(0xFF16160D), const Color(0xFF232010), const Color(0xFF0F0F08)],
          cardGradient: [const Color(0xFF2D2813), const Color(0xFF1B180B), const Color(0xFF373117)],
          appBarColor: const Color(0xFF16160D),
          accentGold: BeyanColors.tone(0xFFFFDF7A),
          glowColor: BeyanColors.tone(0xFFFFD54F),
          cardBorder: BeyanColors.tone(0xFFEAB308),
          actionCardBg: const Color(0xFF201C0D),
          actionCardBorder: const Color(0xFF3D3414),
        );
      case PrayerName.maghrib: // Akşam (Gurub - Alacakaranlık ve Günbatımı)
        return DynamicPrayerAtmosphere(
          backgroundGradient: [const Color(0xFF170E1A), const Color(0xFF231226), const Color(0xFF0F0811)],
          cardGradient: [const Color(0xFF2C1631), const Color(0xFF1A0B1D), const Color(0xFF391C40)],
          appBarColor: const Color(0xFF170E1A),
          accentGold: BeyanColors.tone(0xFFFFDF7A),
          glowColor: const Color(0xFFFF7043),
          cardBorder: const Color(0xFFF472B6),
          actionCardBg: const Color(0xFF201023),
          actionCardBorder: const Color(0xFF3E1E45),
        );
      case PrayerName.isha: // Yatsı / Gece (Derin Gece ve Yıldızlar)
      default:
        return DynamicPrayerAtmosphere(
          backgroundGradient: [const Color(0xFF03070E), const Color(0xFF06111E), const Color(0xFF020408)],
          cardGradient: [const Color(0xFF081A2D), const Color(0xFF040E19), const Color(0xFF0D243D)],
          appBarColor: const Color(0xFF03070E),
          accentGold: BeyanColors.tone(0xFFFFDF7A),
          glowColor: const Color(0xFF818CF8),
          cardBorder: const Color(0xFF818CF8),
          actionCardBg: const Color(0xFF071524),
          actionCardBorder: const Color(0xFF102842),
        );
    }
  }
}
