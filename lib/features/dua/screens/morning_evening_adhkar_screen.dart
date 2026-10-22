import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/acoustic_audio_service.dart';
import '../models/morning_evening_adhkar_model.dart';

/// Sabah & Akşam Duaları Eşlikçisi (Hısnu'l-Müslim Akışı)
class MorningEveningAdhkarScreen extends ConsumerStatefulWidget {
  final bool? initialIsMorning;

  const MorningEveningAdhkarScreen({super.key, this.initialIsMorning});

  @override
  ConsumerState<MorningEveningAdhkarScreen> createState() => _MorningEveningAdhkarScreenState();
}

class _MorningEveningAdhkarScreenState extends ConsumerState<MorningEveningAdhkarScreen>
    with SingleTickerProviderStateMixin {
  late bool _isMorning;
  int _currentIndex = 0;
  int _currentCount = 0;
  bool _isCompleted = false;

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.initialIsMorning != null) {
      _isMorning = widget.initialIsMorning!;
    } else {
      final hour = DateTime.now().hour;
      _isMorning = hour >= 4 && hour < 15;
    }

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  List<AdhkarItem> get _currentList {
    return verifiedMorningEveningAdhkar.where((item) {
      if (_isMorning) {
        return item.timeType == AdhkarTimeType.morning || item.timeType == AdhkarTimeType.both;
      } else {
        return item.timeType == AdhkarTimeType.evening || item.timeType == AdhkarTimeType.both;
      }
    }).toList();
  }

  void _onTapCounter() {
    final list = _currentList;
    if (_currentIndex >= list.length) return;
    final item = list[_currentIndex];

    AcousticAudioService.instance.playKukaBeadSound();
    HapticFeedback.selectionClick();

    setState(() {
      _currentCount++;
      if (_currentCount >= item.targetCount) {
        // Hedef tamamlandı
        HapticFeedback.mediumImpact();
        _shimmerController.forward(from: 0.0);

        Future.delayed(const Duration(milliseconds: 380), () {
          if (!mounted) return;
          if (_currentIndex < list.length - 1) {
            setState(() {
              _currentIndex++;
              _currentCount = 0;
            });
          } else {
            setState(() {
              _isCompleted = true;
            });
            HapticFeedback.heavyImpact();
          }
        });
      }
    });
  }

  void _switchMode(bool isMorning) {
    if (_isMorning == isMorning) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isMorning = isMorning;
      _currentIndex = 0;
      _currentCount = 0;
      _isCompleted = false;
    });
  }

  void _nextDua() {
    final list = _currentList;
    if (_currentIndex < list.length - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex++;
        _currentCount = 0;
      });
    }
  }

  void _prevDua() {
    if (_currentIndex > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex--;
        _currentCount = 0;
      });
    }
  }

  void _restart() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = 0;
      _currentCount = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language.code;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _currentList;

    return Scaffold(
      backgroundColor: isDark ? BeyanColors.tone(0xFF021B16) : BeyanColors.tone(0xFFF3F7F5),
      appBar: AppBar(
        title: Text(
          strings.language == AppLanguage.turkish
              ? 'Hısnu\'l-Müslim Virdi'
              : (strings.language == AppLanguage.arabic ? 'أذكار الصباح والمساء' : 'Daily Adhkar Flow'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: strings.reset,
            onPressed: _restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst Sabah / Akşam Segment Seçici ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? BeyanColors.tone(0xFF042B23) : BeyanColors.tone(0xFFE2EEEA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _switchMode(true),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _isMorning ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_sunny_rounded,
                                size: 16,
                                color: _isMorning ? Colors.black87 : (isDark ? Colors.white60 : Colors.black54),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                strings.language == AppLanguage.turkish ? 'Sabah Duaları' : 'Morning Adhkar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _isMorning ? Colors.black87 : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _switchMode(false),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: !_isMorning ? BeyanColors.tone(0xFFD4AF37) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 16,
                                color: !_isMorning ? Colors.black87 : (isDark ? Colors.white60 : Colors.black54),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                strings.language == AppLanguage.turkish ? 'Akşam Duaları' : 'Evening Adhkar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !_isMorning ? Colors.black87 : (isDark ? Colors.white70 : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Story Tarzı İlerleme Çubukları ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: List.generate(list.length, (idx) {
                  final isDone = idx < _currentIndex || _isCompleted;
                  final isCurrent = idx == _currentIndex && !_isCompleted;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDone
                            ? BeyanColors.tone(0xFFFFDF7A)
                            : (isCurrent
                                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.8)
                                : (isDark ? Colors.white12 : Colors.black12)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // ── Ana İçerik Kartı ─────────────────────────────────────
            Expanded(
              child: _isCompleted
                  ? _buildCompletionState(strings, isDark)
                  : _buildAdhkarContent(list[_currentIndex], strings, isDark, lang),
            ),

            // ── Alt Sayaç & Gezinme Barı ──────────────────────────────
            if (!_isCompleted) _buildBottomControls(list[_currentIndex], strings, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhkarContent(AdhkarItem item, AppStrings strings, bool isDark, String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? BeyanColors.tone(0xFF04261F) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.4 : 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Başlık & Kaynak
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.localizedTitle(lang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BeyanColors.tone(0xFFFFDF7A),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${_currentList.length}',
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Arapça Metin
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? BeyanColors.tone(0xFF021B16) : BeyanColors.tone(0xFFF7FAF9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item.arabicText,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  height: 2.1,
                  fontWeight: FontWeight.w600,
                  color: BeyanColors.tone(0xFFFFDF7A),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),

            const SizedBox(height: 14),

            // Okunuş (Transliterasyon)
            Text(
              item.transliteration,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: isDark ? BeyanColors.tone(0xFF80CBC4) : BeyanColors.tone(0xFF0A685A),
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: isDark ? Colors.white12 : Colors.black12, thickness: 0.8),
            const SizedBox(height: 10),

            // Meal
            Text(
              item.localizedMeaning(lang),
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : BeyanColors.tone(0xFF1E2E2B),
              ),
            ),

            const SizedBox(height: 14),

            // Fazilet ve Hadis Kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? BeyanColors.tone(0xFF06332A) : BeyanColors.tone(0xFFEBF4F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        strings.language == AppLanguage.turkish ? 'Manevi Mükafatı' : 'Virtue & Blessing',
                        style: TextStyle(
                          color: BeyanColors.tone(0xFFFFDF7A),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.source,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.localizedVirtue(lang),
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: isDark ? Colors.white70 : BeyanColors.tone(0xFF23443E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(AdhkarItem item, AppStrings strings, bool isDark) {
    final progress = item.targetCount > 0 ? (_currentCount / item.targetCount).clamp(0.0, 1.0) : 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Row(
        children: [
          // Önceki
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            tooltip: strings.language == AppLanguage.turkish ? 'Önceki' : 'Previous',
            onPressed: _currentIndex > 0 ? _prevDua : null,
          ),

          const SizedBox(width: 8),

          // ── Merkez Lüks Dokunma Butonu ──────────────────────
          Expanded(
            child: GestureDetector(
              onTap: _onTapCounter,
              child: AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, _) {
                  return Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [BeyanColors.tone(0xFF04584C), BeyanColors.tone(0xFF012E2B)],
                        radius: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFD4AF37),
                        width: 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // İlerleme Doldurması
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: MediaQuery.of(context).size.width * 0.65 * progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),

                        // Altın Işık Süzülmesi
                        if (_shimmerController.isAnimating)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Transform.rotate(
                                angle: _shimmerAnimation.value * math.pi,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.45),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Sayaç Metni
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 22),
                            const SizedBox(width: 10),
                            Text(
                              '$_currentCount / ${item.targetCount}',
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              strings.language == AppLanguage.turkish ? 'Dokun' : 'Tap',
                              style: TextStyle(
                                fontSize: 13,
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Sonraki
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            tooltip: strings.language == AppLanguage.turkish ? 'Sonraki' : 'Next',
            onPressed: _currentIndex < _currentList.length - 1 ? _nextDua : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionState(AppStrings strings, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFD4AF37)],
                ),
              ),
              child: Icon(Icons.check_rounded, color: BeyanColors.tone(0xFF012E2B), size: 52),
            ),
            const SizedBox(height: 24),
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Elhamdülillâh!\nVirdiniz Tamamlandı'
                  : 'Alhamdulillah!\nAdhkar Completed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BeyanColors.tone(0xFFFFDF7A),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Gününüz ilahi muhafaza, huzur ve bereketle dolsun. Allah kabul eylesin.'
                  : 'May your day be blessed with divine protection and tranquility.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: Text(strings.language == AppLanguage.turkish ? 'Ana Sayfaya Dön' : 'Return Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BeyanColors.tone(0xFFD4AF37),
                foregroundColor: BeyanColors.tone(0xFF012E2B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
