import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 1. Sisli Cami Sanat Tablosu (Misty Mosque Painter)
class MosqueArtPainter extends CustomPainter {
  const MosqueArtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Gökyüzü Degradesi (Gece mavisinden seher vaktine)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF021B17), Color(0xFF042B24), Color(0xFF0A3B32), Color(0xFF134E42)],
        stops: [0.0, 0.4, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Hilal (Ay)
    final moonCenter = Offset(w * 0.78, h * 0.16);
    final moonRadius = w * 0.07;
    final moonPaint = Paint()..color = const Color(0xFFFFDF7A).withValues(alpha: 0.9);
    final shadowPaint = Paint()..color = const Color(0xFF042B24);

    canvas.drawCircle(moonCenter, moonRadius, moonPaint);
    canvas.drawCircle(Offset(moonCenter.dx + moonRadius * 0.45, moonCenter.dy - moonRadius * 0.15), moonRadius * 0.85, shadowPaint);

    // 3. Yıldız Parıltıları
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final starOffsets = [
      Offset(w * 0.15, h * 0.12),
      Offset(w * 0.35, h * 0.08),
      Offset(w * 0.60, h * 0.14),
      Offset(w * 0.22, h * 0.22),
      Offset(w * 0.85, h * 0.28),
      Offset(w * 0.45, h * 0.18),
    ];
    for (final pos in starOffsets) {
      canvas.drawCircle(pos, 1.5, starPaint);
    }

    // 4. Cami Silüeti (Kubbe ve Minareler - Alt kısım)
    final mosquePaint = Paint()
      ..color = const Color(0xFF011412).withValues(alpha: 0.88);

    final path = Path();
    final baseY = h * 0.92;

    // Zemin
    path.moveTo(0, h);
    path.lineTo(0, baseY);

    // Sol Minare
    final min1X = w * 0.16;
    path.lineTo(min1X - 8, baseY);
    path.lineTo(min1X - 5, h * 0.65);
    path.lineTo(min1X, h * 0.60); // Alem ucu
    path.lineTo(min1X + 5, h * 0.65);
    path.lineTo(min1X + 8, baseY);

    // Sol Küçük Kubbe
    path.quadraticBezierTo(w * 0.32, h * 0.80, w * 0.38, baseY);

    // Büyük Merkez Kubbe
    path.quadraticBezierTo(w * 0.50, h * 0.70, w * 0.62, baseY);

    // Sağ Küçük Kubbe
    path.quadraticBezierTo(w * 0.68, h * 0.80, w * 0.80, baseY);

    // Sağ Minare
    final min2X = w * 0.84;
    path.lineTo(min2X - 8, baseY);
    path.lineTo(min2X - 5, h * 0.65);
    path.lineTo(min2X, h * 0.60);
    path.lineTo(min2X + 5, h * 0.65);
    path.lineTo(min2X + 8, baseY);

    path.lineTo(w, baseY);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, mosquePaint);

    // 5. Alt Kısım Sis / Işık Halesi (Golden Mist)
    final mistPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFD4AF37).withValues(alpha: 0.18),
          const Color(0xFFD4AF37).withValues(alpha: 0.35),
        ],
        stops: const [0.0, 0.6, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25));
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), mistPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. Altın Gün Batımı (Sunset Mosque Painter)
class SunsetMosquePainter extends CustomPainter {
  const SunsetMosquePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gün Batımı Degradesi (Kızıl, turuncu, altın)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2A0845), Color(0xFF641E46), Color(0xFF9E2A2B), Color(0xFFD35400), Color(0xFFF39C12)],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Güneş Halesi
    final sunCenter = Offset(w * 0.5, h * 0.72);
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.8),
          const Color(0xFFFFB300).withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: w * 0.45));
    canvas.drawCircle(sunCenter, w * 0.45, sunPaint);

    // Cami Silüeti (Karanlık Kontrast)
    final silPaint = Paint()..color = const Color(0xFF120308).withValues(alpha: 0.95);
    final path = Path();
    final baseY = h * 0.90;

    path.moveTo(0, h);
    path.lineTo(0, baseY);

    // Minare 1
    path.lineTo(w * 0.20 - 7, baseY);
    path.lineTo(w * 0.20, h * 0.63);
    path.lineTo(w * 0.20 + 7, baseY);

    // Kubbe
    path.quadraticBezierTo(w * 0.5, h * 0.70, w * 0.80 - 7, baseY);

    // Minare 2
    path.lineTo(w * 0.80 - 7, baseY);
    path.lineTo(w * 0.80, h * 0.63);
    path.lineTo(w * 0.80 + 7, baseY);

    path.lineTo(w, baseY);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, silPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. Gece Seması & Hilal (Starry Night Painter)
class StarryNightPainter extends CustomPainter {
  const StarryNightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Derin Gece Degradesi
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Yıldızlar
    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * w;
      final y = random.nextDouble() * h * 0.85;
      final radius = 0.8 + random.nextDouble() * 1.5;
      starPaint.color = Colors.white.withValues(alpha: 0.3 + random.nextDouble() * 0.7);
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Parıldayan Büyük Hilal
    final moonCenter = Offset(w * 0.5, h * 0.16);
    final moonR = w * 0.10;

    // Ay Halesi (Glow)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFDF7A).withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonR * 2.2));
    canvas.drawCircle(moonCenter, moonR * 2.2, glowPaint);

    // Hilal Çizimi
    final moonPaint = Paint()..color = const Color(0xFFFFDF7A);
    final cutPaint = Paint()..color = const Color(0xFF040A1A);

    canvas.drawCircle(moonCenter, moonR, moonPaint);
    canvas.drawCircle(Offset(moonCenter.dx + moonR * 0.5, moonCenter.dy - moonR * 0.15), moonR * 0.85, cutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Kâbe-i Muazzama & Altın Hat (Kaaba Painter)
class KaabaArtPainter extends CustomPainter {
  const KaabaArtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arka Plan: Kutsal Mermer & Gece
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF031411), Color(0xFF06231E), Color(0xFF02100E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Kâbe Silüeti (Küp)
    final kaabaW = w * 0.42;
    final kaabaH = w * 0.46;
    final kaabaLeft = (w - kaabaW) / 2;
    final kaabaTop = h * 0.68;

    // Işık Halesi
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFDF7A).withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w / 2, kaabaTop + kaabaH / 2), radius: kaabaW * 1.4));
    canvas.drawCircle(Offset(w / 2, kaabaTop + kaabaH / 2), kaabaW * 1.4, auraPaint);

    // Kâbe Gövdesi (Siyah Kisve)
    final kaabaPaint = Paint()..color = const Color(0xFF0A0A0A);
    final kaabaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(kaabaLeft, kaabaTop, kaabaW, kaabaH),
      const Radius.circular(8),
    );
    canvas.drawRRect(kaabaRect, kaabaPaint);

    // Altın Kuşak (Kiswa Altın Hattı)
    final goldBandPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawRect(
      Rect.fromLTWH(kaabaLeft, kaabaTop + kaabaH * 0.22, kaabaW, kaabaH * 0.12),
      goldBandPaint,
    );

    // İkinci ince altın şerit
    final thinGoldPaint = Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.8);
    canvas.drawRect(
      Rect.fromLTWH(kaabaLeft, kaabaTop + kaabaH * 0.38, kaabaW, kaabaH * 0.03),
      thinGoldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 5. Osmanlı Mihrabı & Tezhip (Sacred Arch Painter)
class IslamicArchPainter extends CustomPainter {
  const IslamicArchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arka plan: Zümrüt & Damask
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF04382F), Color(0xFF01201B), Color(0xFF011411)],
        center: Alignment.center,
        radius: 0.85,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Altın Mihrap Kemeri Çizimi
    final archPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final margin = w * 0.08;
    final archTop = h * 0.14;
    final archBottom = h * 0.88;

    final archPath = Path();
    archPath.moveTo(margin, archBottom);
    archPath.lineTo(margin, archTop + w * 0.35);

    // Sivri Kemer Eğrisi (Pointed Arch)
    archPath.quadraticBezierTo(margin, archTop, w / 2, archTop * 0.8);
    archPath.quadraticBezierTo(w - margin, archTop, w - margin, archTop + w * 0.35);

    archPath.lineTo(w - margin, archBottom);

    canvas.drawPath(archPath, archPaint);

    // İç İnce Çerçeve
    final innerPaint = Paint()
      ..color = const Color(0xFFFFDF7A).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final inMargin = margin + 8;
    final inArchPath = Path();
    inArchPath.moveTo(inMargin, archBottom - 8);
    inArchPath.lineTo(inMargin, archTop + w * 0.35);
    inArchPath.quadraticBezierTo(inMargin, archTop + 8, w / 2, archTop * 0.8 + 8);
    inArchPath.quadraticBezierTo(w - inMargin, archTop + 8, w - inMargin, archTop + w * 0.35);
    inArchPath.lineTo(w - inMargin, archBottom - 8);

    canvas.drawPath(inArchPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
