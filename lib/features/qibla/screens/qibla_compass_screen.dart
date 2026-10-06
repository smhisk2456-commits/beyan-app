import 'dart:async';
import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../../prayer_times/services/prayer_time_service.dart';

/// Lüks & Canlı Sensörlü Kıble Pusulası Ekranı
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSub;

  double? _heading;
  double _qiblaAngle = 152.0; // Varsayılan İstanbul
  double _distanceKm = 2418.0;
  String _cityName = 'İstanbul';
  bool _loadingLocation = true;
  bool _hasCompassSensor = true;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndQibla();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndQibla() async {
    try {
      final loc = await PrayerTimeService().getCurrentLocation();
      final coordinates = Coordinates(loc.latitude, loc.longitude);
      final qibla = Qibla(coordinates);

      final distance = Geolocator.distanceBetween(
            loc.latitude,
            loc.longitude,
            Qibla.MAKKAH.latitude,
            Qibla.MAKKAH.longitude,
          ) /
          1000.0;

      if (mounted) {
        setState(() {
          _qiblaAngle = qibla.direction;
          _distanceKm = distance;
          _cityName = loc.cityName;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Kıble konumu hesaplama hatası: $e');
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _startCompass() {
    if (FlutterCompass.events == null) {
      setState(() => _hasCompassSensor = false);
      return;
    }

    _compassSub = FlutterCompass.events!.listen((event) {
      if (!mounted) return;
      final h = event.heading;
      if (h == null) return;

      // Normalizasyon 0..360
      final normalizedHeading = (h + 360) % 360;

      // Kıble ile açı farkı (-180..180)
      double diff = (_qiblaAngle - normalizedHeading + 360) % 360;
      if (diff > 180) diff -= 360;

      final isAligned = diff.abs() <= 3.5;

      // Hizalandığında titreşim ver
      if (isAligned && !_wasAligned) {
        HapticFeedback.heavyImpact();
      }
      _wasAligned = isAligned;

      setState(() {
        _heading = normalizedHeading;
      });
    }, onError: (_) {
      if (mounted) setState(() => _hasCompassSensor = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentHeading = _heading ?? 0.0;
    double diff = (_qiblaAngle - currentHeading + 360) % 360;
    if (diff > 180) diff -= 360;
    final isAligned = diff.abs() <= 3.5;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF011815) : const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kıble Pusulası',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFD4AF37)),
            onPressed: _showCalibrationInfo,
          ),
        ],
      ),
      body: SafeArea(
        child: _loadingLocation
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // Şehir & Mesafe Bilgi Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D2823)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: Color(0xFFD4AF37), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            _cityName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Kâbe: ${_distanceKm.toStringAsFixed(0)} km',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (!_hasCompassSensor) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade900.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Cihazınızda pusula sensörü (manyetometre) algılanamadı. Kıble açısı referans olarak gösterilmektedir.',
                                style: TextStyle(fontSize: 11, color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Hizalanma Durum Başlığı
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? const Color(0xFF0F5A47)
                            : (isDark ? const Color(0xFF0B221E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAligned
                              ? const Color(0xFFFFDF7A)
                              : const Color(0xFFD4AF37).withValues(alpha: 0.25),
                          width: isAligned ? 1.5 : 1,
                        ),
                        boxShadow: isAligned
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                            color: isAligned ? const Color(0xFFFFDF7A) : const Color(0xFFD4AF37),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isAligned
                                ? 'Kıbleye Yöneldiniz! 🕋'
                                : (diff > 0
                                    ? 'Sağa ${diff.round()}° dönün'
                                    : 'Sola ${(-diff).round()}° dönün'),
                            style: TextStyle(
                              color: isAligned ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── LÜKS DÖNEN PUSULA KADRANI ─────────────────
                    SizedBox(
                      width: 290,
                      height: 290,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Dış Parıltı Halkası
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 290,
                            height: 290,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  isAligned
                                      ? const Color(0xFF034A3E).withValues(alpha: 0.9)
                                      : (isDark ? const Color(0xFF052B25) : Colors.white),
                                  isDark ? const Color(0xFF011A16) : Colors.grey.shade100,
                                ],
                              ),
                              border: Border.all(
                                color: isAligned
                                    ? const Color(0xFFFFDF7A)
                                    : const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                width: isAligned ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isAligned
                                      ? const Color(0xFFD4AF37).withValues(alpha: 0.45)
                                      : Colors.black.withValues(alpha: 0.2),
                                  blurRadius: isAligned ? 24 : 14,
                                  spreadRadius: isAligned ? 4 : 1,
                                ),
                              ],
                            ),
                          ),

                          // Dönen Pusula Diski (Cihaz yönüne göre ters döner: -heading)
                          Transform.rotate(
                            angle: -currentHeading * (math.pi / 180),
                            child: CustomPaint(
                              size: const Size(280, 280),
                              painter: _CompassDialPainter(isDark: isDark),
                            ),
                          ),

                          // Kâbe İbresi ve İkonu (Diske göre Kıble açısında durur: _qiblaAngle - currentHeading)
                          Transform.rotate(
                            angle: (_qiblaAngle - currentHeading) * (math.pi / 180),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF011C18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFDF7A),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFFD4AF37),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '🕋',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Container(
                                  width: 3,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFDF7A), Colors.transparent],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Sabit Cihaz Ön İbresi (Tepe oku)
                          Positioned(
                            top: 4,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFDF7A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_drop_down,
                                  size: 14, color: Colors.black),
                            ),
                          ),

                          // Merkez Göbek
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFF7A5F12)],
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${currentHeading.round()}°',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Detaylı Bilgi Kartları ───────────────────────
                    Row(
                      children: [
                        _buildInfoCard(
                          title: 'Kıble Açısı',
                          value: '${_qiblaAngle.round()}°',
                          subtitle: 'Kuzeyden saat yönünde',
                          icon: Icons.explore_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          title: 'Cihaz Yönü',
                          value: '${currentHeading.round()}°',
                          subtitle: _getCompassDirection(currentHeading),
                          icon: Icons.navigation_rounded,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Kalibrasyon İpucu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0D2823).withValues(alpha: 0.6)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.screen_rotation_rounded,
                              color: Color(0xFFD4AF37), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cihazınızı düz bir zeminde veya yatay tutarak kullanınız. Manyetik kılıflar pusulayı etkileyebilir.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF071F1B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCompassDirection(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'Kuzey (N)';
    if (deg >= 22.5 && deg < 67.5) return 'Kuzeydoğu (NE)';
    if (deg >= 67.5 && deg < 112.5) return 'Doğu (E)';
    if (deg >= 112.5 && deg < 157.5) return 'Güneydoğu (SE)';
    if (deg >= 157.5 && deg < 202.5) return 'Güney (S)';
    if (deg >= 202.5 && deg < 247.5) return 'Güneybatı (SW)';
    if (deg >= 247.5 && deg < 292.5) return 'Batı (W)';
    return 'Kuzeybatı (NW)';
  }

  void _showCalibrationInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF071F1B),
        title: const Row(
          children: [
            Icon(Icons.compass_calibration_rounded, color: Color(0xFFD4AF37)),
            SizedBox(width: 10),
            Text('Pusula Kalibrasyonu', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Telefon pusulasının doğru çalışması için:\n\n'
          '1. Cihazınızı havada yatay tutarak "8" şekli çizecek şekilde birkaç kez sallayınız.\n'
          '2. Metal veya mıknatıslı kılıflardan uzak tutunuz.\n'
          '3. Elektronik cihazların (laptop, mikrodalga vb.) yanında manyetik sapma oluşabilir.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}

/// Dönen pusula kadranı çizicisi (Dereceler, N, E, S, W ve çizgiler)
class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  _CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    final majorTickPaint = Paint()
      ..color = const Color(0xFFFFDF7A)
      ..strokeWidth = 2.0;

    // 360 derece işaretleri (her 10 derecede bir çizgi, her 30 derecede büyük çizgi)
    for (int deg = 0; deg < 360; deg += 5) {
      final angle = deg * (math.pi / 180);
      final isMajor = deg % 30 == 0;
      final isCardinal = deg % 90 == 0;
      final tickLength = isCardinal ? 14.0 : (isMajor ? 10.0 : 5.0);

      final p1 = Offset(
        center.dx + (radius - 12) * math.sin(angle),
        center.dy - (radius - 12) * math.cos(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 12 - tickLength) * math.sin(angle),
        center.dy - (radius - 12 - tickLength) * math.cos(angle),
      );

      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : tickPaint);
    }

    // Ana Yön Yazıları (N, E, S, W)
    final directions = {'K': 0, 'D': 90, 'G': 180, 'B': 270};
    for (final entry in directions.entries) {
      final angle = entry.value * (math.pi / 180);
      final offset = Offset(
        center.dx + (radius - 36) * math.sin(angle),
        center.dy - (radius - 36) * math.cos(angle),
      );

      final isNorth = entry.key == 'K';
      final textSpan = TextSpan(
        text: entry.key,
        style: TextStyle(
          color: isNorth ? const Color(0xFFFF4D4D) : const Color(0xFFFFDF7A),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
