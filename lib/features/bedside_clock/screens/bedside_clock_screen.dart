import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../prayer_times/providers/prayer_time_providers.dart';

enum StandByTheme {
  nightRed('Kırmızı Loş', Color(0xFFFF453A), Color(0x33FF453A)),
  golden('Lüks Altın', Color(0xFFFFDF7A), Color(0x33D4AF37)),
  emerald('Zümrüt Huzur', Color(0xFF2DD4BF), Color(0x3310B981)),
  pureWhite('Saf Beyaz', Color(0xFFF8FAFC), Color(0x22FFFFFF));

  final String label;
  final Color primary;
  final Color glow;

  const StandByTheme(this.label, this.primary, this.glow);
}

/// iOS 18 StandBy & Lüks Başucu Gece Saati
class BedsideClockScreen extends ConsumerStatefulWidget {
  const BedsideClockScreen({super.key});

  @override
  ConsumerState<BedsideClockScreen> createState() => _BedsideClockScreenState();
}

class _BedsideClockScreenState extends ConsumerState<BedsideClockScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();
  bool _isDimmed = false;
  bool _isLandscape = false;
  StandByTheme _theme = StandByTheme.golden;

  @override
  void initState() {
    super.initState();
    // Tam ekran sürükleyici mod
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    // Normal dikey yöne ve sistem çubuklarına dön
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleOrientation() {
    HapticFeedback.mediumImpact();
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _nextTheme() {
    HapticFeedback.lightImpact();
    final nextIndex = (_theme.index + 1) % StandByTheme.values.length;
    setState(() => _theme = StandByTheme.values[nextIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyPrayerTimesProvider);
    final nextPrayer = dailyAsync.valueOrNull?.nextPrayerEntry;
    final countdownAsync = ref.watch(countdownStringProvider);
    final isLandscapeNow = MediaQuery.of(context).orientation == Orientation.landscape || _isLandscape;

    final primaryColor = _isDimmed ? _theme.primary.withValues(alpha: 0.35) : _theme.primary;
    final glowColor = _isDimmed ? Colors.transparent : _theme.glow;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _isDimmed = !_isDimmed);
        },
        child: SafeArea(
          child: Stack(
            children: [
              // ── Üst Araç Çubuğu ───────────────────────────────────
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    // Loşluk Göstergesi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isDimmed ? Icons.bedtime_rounded : Icons.light_mode_rounded,
                            size: 14,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isDimmed ? 'Loş Uyku Modu' : 'Dokun: Loşlaştır',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Renk Teması Değiştirici
                    IconButton(
                      icon: Icon(Icons.palette_outlined, color: primaryColor, size: 22),
                      tooltip: 'Renk Teması (${_theme.label})',
                      onPressed: _nextTheme,
                    ),

                    // Yatay / StandBy Döndürücü
                    IconButton(
                      icon: Icon(
                        isLandscapeNow ? Icons.screen_lock_portrait_rounded : Icons.screen_lock_landscape_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                      tooltip: isLandscapeNow ? 'Dikey Ekrana Geç' : 'Yatay StandBy Moduna Geç',
                      onPressed: _toggleOrientation,
                    ),

                    // Kapat
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 24),
                      tooltip: 'Kapat',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // ── Ana İçerik (Yatay vs Dikey) ─────────────────────────
              Positioned.fill(
                top: 60,
                child: isLandscapeNow
                    ? _buildLandscapeStandBy(nextPrayer, countdownAsync, primaryColor, glowColor)
                    : _buildPortraitDock(nextPrayer, countdownAsync, primaryColor, glowColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 1. GERÇEK APPLE STANDBY WIDESCREEN (YATAY MOD)
  // ════════════════════════════════════════════════════════════════
  Widget _buildLandscapeStandBy(
    dynamic nextPrayer,
    AsyncValue<String> countdownAsync,
    Color primaryColor,
    Color glowColor,
  ) {
    final hours = DateFormat('HH').format(_now);
    final minutes = DateFormat('mm').format(_now);
    final seconds = DateFormat('ss').format(_now);
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_now);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sol Panel: Devasa Apple StandBy Saati
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$hours:$minutes',
                      style: TextStyle(
                        fontSize: 104,
                        fontWeight: FontWeight.w200,
                        color: primaryColor,
                        letterSpacing: -4,
                        height: 1.0,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        shadows: [
                          Shadow(color: glowColor, blurRadius: 32),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      seconds,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                        color: primaryColor.withValues(alpha: 0.75),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: _isDimmed ? 0.3 : 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Bölücü Dikey Çizgi
          Container(
            width: 1,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.1),
          ),

          // Sağ Panel: Namaz Vakti & Gece Âyeti HUD
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sıradaki Vakit HUD Kartı
                if (nextPrayer != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF041C17).withValues(alpha: _isDimmed ? 0.2 : 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mosque_rounded, color: primaryColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIRADAKİ VAKİT: ${nextPrayer.name.turkish.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('HH:mm').format(nextPrayer.time),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                        countdownAsync.when(
                          data: (str) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '⏱ $str kaldı',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Gece Tefekkürü
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '«Gecenin bir kısmında O\'na secde et ve geceleyin O\'nu uzun uzadıya tesbih et.» (İnsân 76:26)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: _isDimmed ? 0.25 : 0.6),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // 2. LÜKS PORTRAIT DOCK (DİKEY MOD)
  // ════════════════════════════════════════════════════════════════
  Widget _buildPortraitDock(
    dynamic nextPrayer,
    AsyncValue<String> countdownAsync,
    Color primaryColor,
    Color glowColor,
  ) {
    final hours = DateFormat('HH').format(_now);
    final minutes = DateFormat('mm').format(_now);
    final seconds = DateFormat('ss').format(_now);
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_now);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Tarih
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: _isDimmed ? 0.3 : 0.65),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Devasa Dijital Saat + Saniye
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$hours:$minutes',
                style: TextStyle(
                  fontSize: 84,
                  fontWeight: FontWeight.w200,
                  color: primaryColor,
                  letterSpacing: -3,
                  height: 1.0,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: [
                    Shadow(color: glowColor, blurRadius: 28),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                seconds,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w300,
                  color: primaryColor.withValues(alpha: 0.75),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Sıradaki Vakit Rozeti
          if (nextPrayer != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF041C17).withValues(alpha: _isDimmed ? 0.25 : 0.85),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mosque_rounded, color: primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Sıradaki: ${nextPrayer.name.turkish}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('HH:mm').format(nextPrayer.time),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  countdownAsync.when(
                    data: (str) => Text(
                      '⏱ Kalan Süre: $str',
                      style: TextStyle(
                        color: primaryColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 48),

          // Gece Tefekkürü
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '«Gecenin bir kısmında O\'na secde et ve geceleyin O\'nu uzun uzadıya tesbih et.»\n— İnsân 76:26',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: _isDimmed ? 0.25 : 0.55),
                fontSize: 13,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
