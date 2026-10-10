import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';

/// iOS StandBy / Başucu Gece Saati Modu
class BedsideClockScreen extends ConsumerStatefulWidget {
  const BedsideClockScreen({super.key});

  @override
  ConsumerState<BedsideClockScreen> createState() => _BedsideClockScreenState();
}

class _BedsideClockScreenState extends ConsumerState<BedsideClockScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _isDimmed = false; // Gece göz yormayan ekstra loşluk modu

  @override
  void initState() {
    super.initState();
    // Tam ekran deneyimi için sistem çubuklarını gizle
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    // Sistem çubuklarını geri getir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyPrayerTimesProvider);
    final nextPrayer = dailyAsync.valueOrNull?.nextPrayerEntry;
    final countdownAsync = ref.watch(countdownStringProvider);

    final timeFormat = DateFormat('HH:mm');
    final secondsFormat = DateFormat('ss');
    final dateFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');

    final glowColor = _isDimmed
        ? const Color(0xFF8A7320)
        : const Color(0xFFFFDF7A);
    final baseTextColor = _isDimmed ? Colors.white38 : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Dokunulduğunda parlaklığı kıs/aç
          HapticFeedback.selectionClick();
          setState(() => _isDimmed = !_isDimmed);
        },
        child: SafeArea(
          child: Stack(
            children: [
              // Kapat butonu (Sağ Üst)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 28),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Kapat',
                ),
              ),

              // Loşluk İpucu (Sol Üst)
              Positioned(
                top: 20,
                left: 20,
                child: Row(
                  children: [
                    Icon(
                      _isDimmed ? Icons.bedtime_rounded : Icons.brightness_medium_rounded,
                      color: Colors.white38,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isDimmed ? 'Gece Loş Modu Açık' : 'Dokunarak Loşlaştır',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Ana Saat ve Vakit Bilgileri
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tarih
                      Text(
                        dateFormat.format(_now),
                        style: TextStyle(
                          color: baseTextColor.withValues(alpha: 0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Devasa Dijital Saat + Saniye
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeFormat.format(_now),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 88,
                              fontWeight: FontWeight.w200,
                              color: glowColor,
                              letterSpacing: -2,
                              shadows: [
                                Shadow(
                                  color: glowColor.withValues(alpha: _isDimmed ? 0.2 : 0.6),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            secondsFormat.format(_now),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: glowColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sıradaki Vakit Rozeti
                      if (nextPrayer != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF022B24).withValues(alpha: _isDimmed ? 0.3 : 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: glowColor.withValues(alpha: _isDimmed ? 0.2 : 0.5),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mosque_rounded,
                                    size: 16,
                                    color: glowColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sıradaki: ${nextPrayer.name.turkish}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: glowColor.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormat('HH:mm').format(nextPrayer.time),
                                    style: TextStyle(
                                      color: glowColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              countdownAsync.when(
                                data: (str) => Text(
                                  '⏱ Kalan Süre: $str',
                                  style: TextStyle(
                                    color: glowColor.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 36),

                      // Gece Ayeti
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          '«Gecenin bir kısmında O\'na secde et ve geceleyin O\'nu uzun uzadıya tesbih et.»\n— İnsân 76:26',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: _isDimmed ? 0.25 : 0.55),
                            fontSize: 12.5,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
