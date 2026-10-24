import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geomag/geomag.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../prayer_times/services/prayer_time_service.dart';

/// Lüks & Canlı Sensörlü Kıble Pusulası Ekranı
class QiblaCompassScreen extends ConsumerStatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  ConsumerState<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends ConsumerState<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSub;

  double? _heading;
  double _smoothedHeading = 0.0;
  bool _isAligned = false;
  double _qiblaAngle = 152.0; // Varsayılan İstanbul
  double _distanceKm = 2418.0;
  String _cityName = 'İstanbul';
  double _magneticDeclination = 0.0; // Coğrafi manyetik sapma açısı (WMM)
  bool _loadingLocation = true;
  bool _hasCompassSensor = true;
  bool _isFallbackLocation = false;
  bool _wasAligned = false;
  int? _lastProximityBucket;

  late final AnimationController _lockPulseController;
  late final Animation<double> _lockPulseScale;

  @override
  void initState() {
    super.initState();
    _lockPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lockPulseScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
    ]).animate(_lockPulseController);
    _initLocationAndQibla();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _lockPulseController.dispose();
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

      // Dünya Manyetik Modeli (WMM) ile gerçek coğrafi sapma açısını hesapla
      double declination = 0.0;
      try {
        final geoMag = GeoMag();
        final magResult = geoMag.calculate(loc.latitude, loc.longitude);
        declination = magResult.dec;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _qiblaAngle = qibla.direction;
          _distanceKm = distance;
          _cityName = loc.cityName;
          _isFallbackLocation = !loc.isFromGPS;
          _magneticDeclination = declination;
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

      // Manyetik Sapma (Magnetic Declination) düzeltmesi:
      // Telefonun manyetik pusula başlığını Coğrafi Gerçek Kuzey'e dönüştürür (Adhan kıble açısıyla tam uyum)
      final trueHeading = (h + _magneticDeclination + 360) % 360;
      if (_heading == null) {
        _smoothedHeading = trueHeading;
      } else {
        // Dairesel low-pass filtre (0-360 geçişlerini sarsıntısız yumuşatır)
        _smoothedHeading = _smoothedHeading + 0.30 * (((trueHeading - _smoothedHeading + 540) % 360) - 180);
        _smoothedHeading = (_smoothedHeading + 360) % 360;
      }

      // Kıble ile açı farkı (-180..180)
      double diff = (_qiblaAngle - _smoothedHeading + 360) % 360;
      if (diff > 180) diff -= 360;

      // Histerezisli kilitlenme: Kilitlenme <= 3.0°, kilit çözülmesi > 5.0° (haptik titreşim patlamasını önler)
      final aligned = _wasAligned ? diff.abs() <= 5.0 : diff.abs() <= 3.0;

      // Yaklaşma haptik geri bildirimi (Kıbleye yaklaştıkça artan Apple Taptic tıkırtıları)
      if (!aligned && diff.abs() <= 15.0) {
        final bucket = (diff.abs() / 3.0).floor();
        if (_lastProximityBucket != bucket) {
          _lastProximityBucket = bucket;
          HapticFeedback.selectionClick();
        }
      } else if (!aligned) {
        _lastProximityBucket = null;
      }

      // Kâbe yönüne tam oturup kilitlendiğinde tok çift Taptic Engine patlaması ("Klik!" hissi)
      if (aligned && !_wasAligned) {
        _lastProximityBucket = null;
        _lockPulseController.forward(from: 0.0);
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 75), () {
          HapticFeedback.mediumImpact();
        });
      }
      _wasAligned = aligned;

      setState(() {
        _heading = _smoothedHeading;
        _isAligned = aligned;
      });
    }, onError: (_) {
      if (mounted) setState(() => _hasCompassSensor = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentHeading = _heading ?? 0.0;
    double diff = (_qiblaAngle - currentHeading + 360) % 360;
    if (diff > 180) diff -= 360;
    final isAligned = _isAligned;

    return Scaffold(
      backgroundColor: isDark ? BeyanColors.tone(0xFF011815) : BeyanColors.tone(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: BeyanColors.tone(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings.qiblaCompassTitle,
          style: TextStyle(
            color: BeyanColors.tone(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: BeyanColors.tone(0xFFD4AF37)),
            onPressed: () => _showCalibrationInfo(strings),
          ),
        ],
      ),
      body: SafeArea(
        child: _loadingLocation
            ? Center(
                child: CircularProgressIndicator(color: BeyanColors.tone(0xFFD4AF37)),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    if (_isFallbackLocation) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_off_rounded, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                strings.language == AppLanguage.turkish
                                    ? 'Konum izni alınamadı (Varsayılan İstanbul). Tam hassasiyet için konum iznini açın.'
                                    : 'Location unavailable (Showing Istanbul). Enable GPS for precise Qibla.',
                                style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.w500),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Geolocator.openAppSettings(),
                              child: Text(
                                strings.language == AppLanguage.turkish ? 'Aç' : 'Open',
                                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Şehir & Mesafe Bilgi Rozeti
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? BeyanColors.tone(0xFF0D2823)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
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
                          Icon(Icons.location_on_rounded,
                              color: BeyanColors.tone(0xFFD4AF37), size: 16),
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
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            strings.kaabaDistance(_distanceKm.round()),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_magneticDeclination.abs() > 0.01) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.explore_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 13),
                            const SizedBox(width: 5),
                            Text(
                              strings.language == AppLanguage.turkish
                                  ? 'Manyetik Sapma: ${_magneticDeclination >= 0 ? '+' : ''}${_magneticDeclination.toStringAsFixed(1)}° (Gerçek Kuzey)'
                                  : 'True North Declination: ${_magneticDeclination >= 0 ? '+' : ''}${_magneticDeclination.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF034A3E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    if (!_hasCompassSensor) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade900.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                strings.compassSensorNotFound,
                                style: const TextStyle(fontSize: 11, color: Colors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Hizalanma Durum Başlığı (Kâbe'ye Kilitlenme Rozeti)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? BeyanColors.tone(0xFF0F5A47)
                            : (isDark ? BeyanColors.tone(0xFF0B221E) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAligned
                              ? BeyanColors.tone(0xFFFFDF7A)
                              : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                          width: isAligned ? 2.0 : 1,
                        ),
                        boxShadow: isAligned
                            ? [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAligned ? Icons.lock_rounded : Icons.explore_rounded,
                            color: isAligned ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFFD4AF37),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isAligned
                                ? (strings.language == AppLanguage.turkish
                                    ? 'KIBLEYE KİLİTLENDİ (0°)'
                                    : strings.facingQibla)
                                : (diff > 0
                                    ? strings.turnRightDeg(diff.round())
                                    : strings.turnLeftDeg((-diff).round())),
                            style: TextStyle(
                              color: isAligned ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: isAligned ? 0.8 : 0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── LÜKS DÖNEN PUSULA KADRANI (Kilitlenme Yaylanmalı) ─────
                    ScaleTransition(
                      scale: _lockPulseScale,
                      child: SizedBox(
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
                                      ? BeyanColors.tone(0xFF034A3E).withValues(alpha: 0.9)
                                      : (isDark ? BeyanColors.tone(0xFF052B25) : Colors.white),
                                  isDark ? BeyanColors.tone(0xFF011A16) : Colors.grey.shade100,
                                ],
                              ),
                              border: Border.all(
                                color: isAligned
                                    ? BeyanColors.tone(0xFFFFDF7A)
                                    : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                                width: isAligned ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isAligned
                                      ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.45)
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
                              painter: _CompassDialPainter(
                                isDark: isDark,
                                isTurkish: strings.language == AppLanguage.turkish,
                              ),
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
                                    color: BeyanColors.tone(0xFF011C18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: BeyanColors.tone(0xFFFFDF7A),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: BeyanColors.tone(0xFFD4AF37),
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
                                    gradient: LinearGradient(
                                      colors: [BeyanColors.tone(0xFFFFDF7A), Colors.transparent],
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
                              decoration: BoxDecoration(
                                color: BeyanColors.tone(0xFFFFDF7A),
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
                              gradient: RadialGradient(
                                colors: [BeyanColors.tone(0xFFD4AF37), BeyanColors.tone(0xFF7A5F12)],
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
                  ),

                    const SizedBox(height: 32),

                    // ── Detaylı Bilgi Kartları ───────────────────────
                    Row(
                      children: [
                        _buildInfoCard(
                          title: strings.qiblaAngleTitle,
                          value: '${_qiblaAngle.round()}°',
                          subtitle: strings.clockwiseFromNorth,
                          icon: Icons.explore_rounded,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildInfoCard(
                          title: strings.deviceHeadingTitle,
                          value: '${currentHeading.round()}°',
                          subtitle: _getCompassDirection(currentHeading, strings),
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
                            ? BeyanColors.tone(0xFF0D2823).withValues(alpha: 0.6)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.screen_rotation_rounded,
                              color: BeyanColors.tone(0xFFD4AF37), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              strings.compassHoldFlatTip,
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
          color: isDark ? BeyanColors.tone(0xFF071F1B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
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
                Icon(icon, color: BeyanColors.tone(0xFFD4AF37), size: 16),
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

  String _getCompassDirection(double deg, AppStrings strings) {
    if (deg >= 337.5 || deg < 22.5) return strings.compassNorth;
    if (deg >= 22.5 && deg < 67.5) return strings.compassNorthEast;
    if (deg >= 67.5 && deg < 112.5) return strings.compassEast;
    if (deg >= 112.5 && deg < 157.5) return strings.compassSouthEast;
    if (deg >= 157.5 && deg < 202.5) return strings.compassSouth;
    if (deg >= 202.5 && deg < 247.5) return strings.compassSouthWest;
    if (deg >= 247.5 && deg < 292.5) return strings.compassWest;
    return strings.compassNorthWest;
  }

  void _showCalibrationInfo(AppStrings strings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: BeyanColors.tone(0xFF071F1B),
        title: Row(
          children: [
            Icon(Icons.compass_calibration_rounded, color: BeyanColors.tone(0xFFD4AF37)),
            const SizedBox(width: 10),
            Text(strings.compassCalibrationTitle, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          strings.compassCalibrationDesc,
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(strings.iUnderstand, style: TextStyle(color: BeyanColors.tone(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}

/// Dönen pusula kadranı çizicisi (Dereceler, N, E, S, W ve çizgiler)
class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  final bool isTurkish;
  _CompassDialPainter({required this.isDark, required this.isTurkish});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    final majorTickPaint = Paint()
      ..color = BeyanColors.tone(0xFFFFDF7A)
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

    // Ana Yön Yazıları (N, E, S, W veya K, D, G, B)
    final directions = isTurkish
        ? {'K': 0, 'D': 90, 'G': 180, 'B': 270}
        : {'N': 0, 'E': 90, 'S': 180, 'W': 270};

    for (final entry in directions.entries) {
      final angle = entry.value * (math.pi / 180);
      final offset = Offset(
        center.dx + (radius - 36) * math.sin(angle),
        center.dy - (radius - 36) * math.cos(angle),
      );

      final isNorth = entry.key == 'K' || entry.key == 'N';
      final textSpan = TextSpan(
        text: entry.key,
        style: TextStyle(
          color: isNorth ? const Color(0xFFFF4D4D) : BeyanColors.tone(0xFFFFDF7A),
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
      oldDelegate.isDark != isDark || oldDelegate.isTurkish != isTurkish;
}

