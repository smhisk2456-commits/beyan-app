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
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF030D16), Color(0xFF071926), Color(0xFF02080E)],
          cardGradient: [Color(0xFF0A2234), Color(0xFF051522), Color(0xFF0E2C44)],
          appBarColor: Color(0xFF030D16),
          accentGold: Color(0xFFFFDF7A),
          glowColor: Color(0xFF38BDF8),
          cardBorder: Color(0xFF38BDF8),
          actionCardBg: Color(0xFF091E2C),
          actionCardBorder: Color(0xFF13364D),
        );
      case PrayerName.sunrise: // Güneş (İşrak - Altın Doğan Güneş Işığı)
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF16170D), Color(0xFF242211), Color(0xFF0F1008)],
          cardGradient: [Color(0xFF2F2A15), Color(0xFF1E1B0D), Color(0xFF3A341A)],
          appBarColor: Color(0xFF16170D),
          accentGold: Color(0xFFFFD54F),
          glowColor: Color(0xFFFFB74D),
          cardBorder: Color(0xFFFFD54F),
          actionCardBg: Color(0xFF221F0F),
          actionCardBorder: Color(0xFF3F3818),
        );
      case PrayerName.dhuhr: // Öğle (Zümrüt Yeşil & Gün Ortası Işıltısı)
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF011815), Color(0xFF02241F), Color(0xFF01120F)],
          cardGradient: [Color(0xFF033E35), Color(0xFF012720), Color(0xFF06473D)],
          appBarColor: Color(0xFF011815),
          accentGold: Color(0xFFFFDF7A),
          glowColor: Color(0xFF00BFA5),
          cardBorder: Color(0xFFD4AF37),
          actionCardBg: Color(0xFF0D2823),
          actionCardBorder: Color(0xFF133B34),
        );
      case PrayerName.asr: // İkindi (Sıcak İkindi Kehribarı)
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF16160D), Color(0xFF232010), Color(0xFF0F0F08)],
          cardGradient: [Color(0xFF2D2813), Color(0xFF1B180B), Color(0xFF373117)],
          appBarColor: Color(0xFF16160D),
          accentGold: Color(0xFFFFDF7A),
          glowColor: Color(0xFFFFD54F),
          cardBorder: Color(0xFFEAB308),
          actionCardBg: Color(0xFF201C0D),
          actionCardBorder: Color(0xFF3D3414),
        );
      case PrayerName.maghrib: // Akşam (Gurub - Alacakaranlık ve Günbatımı)
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF170E1A), Color(0xFF231226), Color(0xFF0F0811)],
          cardGradient: [Color(0xFF2C1631), Color(0xFF1A0B1D), Color(0xFF391C40)],
          appBarColor: Color(0xFF170E1A),
          accentGold: Color(0xFFFFDF7A),
          glowColor: Color(0xFFFF7043),
          cardBorder: Color(0xFFF472B6),
          actionCardBg: Color(0xFF201023),
          actionCardBorder: Color(0xFF3E1E45),
        );
      case PrayerName.isha: // Yatsı / Gece (Derin Gece ve Yıldızlar)
      default:
        return const DynamicPrayerAtmosphere(
          backgroundGradient: [Color(0xFF03070E), Color(0xFF06111E), Color(0xFF020408)],
          cardGradient: [Color(0xFF081A2D), Color(0xFF040E19), Color(0xFF0D243D)],
          appBarColor: Color(0xFF03070E),
          accentGold: Color(0xFFFFDF7A),
          glowColor: Color(0xFF818CF8),
          cardBorder: Color(0xFF818CF8),
          actionCardBg: Color(0xFF071524),
          actionCardBorder: Color(0xFF102842),
        );
    }
  }
}
