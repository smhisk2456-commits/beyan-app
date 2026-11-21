import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';

/// Beyân - Yeniden Tasarlanmış Lüks Yüzen Navigasyon Menüsü.
class LuxuryFloatingDock extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LuxuryFloatingDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgGradient = LinearGradient(
      colors: isDark
          ? [
              BeyanColors.tone(0xFF012E2B).withValues(alpha: 0.88),
              BeyanColors.tone(0xFF021B17).withValues(alpha: 0.94),
            ]
          : [
              const Color(0xFFFFFFFF).withValues(alpha: 0.90),
              BeyanColors.tone(0xFFF1F6F3).withValues(alpha: 0.95),
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final borderColor = BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.4 : 0.35);

    final shadows = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: BeyanColors.tone(0xFF033E35).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: BeyanColors.tone(0xFF033E35).withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -1),
            ),
          ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // ── Ana Yüzen Bar Gövdesi (iOS 18 Buzlu Cam / Glassmorphism) ──
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: bgGradient,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: borderColor,
                        width: 1.2,
                      ),
                      boxShadow: shadows,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          // 1. Sekme: Ana Sayfa
                          Expanded(
                            child: _buildTabItem(
                              index: 0,
                              icon: Icons.explore_rounded,
                              activeIcon: Icons.explore,
                              label: strings.tabHome,
                              isDark: isDark,
                            ),
                          ),

                          // 2. Sekme: Vakitler
                          Expanded(
                            child: _buildTabItem(
                              index: 1,
                              icon: Icons.access_time_rounded,
                              activeIcon: Icons.access_time_filled_rounded,
                              label: strings.tabPrayers,
                              isDark: isDark,
                            ),
                          ),

                          // Merkez buton için boşluk (Kur'an-ı Kerim)
                          const SizedBox(width: 58),

                          // 3. Sekme: Zikirmatik (Index 3)
                          Expanded(
                            child: _buildTabItem(
                              index: 3,
                              icon: Icons.fingerprint_rounded,
                              activeIcon: Icons.fingerprint,
                              label: strings.tabZikr,
                              isDark: isDark,
                            ),
                          ),

                          // 4. Sekme: Widget & Kilit Ekranı (Index 4)
                          Expanded(
                            child: _buildTabItem(
                              index: 4,
                              icon: Icons.widgets_outlined,
                              activeIcon: Icons.widgets_rounded,
                              label: strings.tabWidget,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Merkez Yükseltilmiş Kur'an Mührü (Index 2) ──────
              Positioned(
                top: -8,
                child: _buildCenterSeal(context, strings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sekme butonu widget'ı
  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = currentIndex == index;
    final unselectedColor = isDark ? Colors.white60 : BeyanColors.tone(0xFF4A605B);
    final selectedIconColor = isDark ? BeyanColors.tone(0xFFFFE082) : BeyanColors.tone(0xFF02362E);
    final selectedTextColor = isDark ? BeyanColors.tone(0xFFFFE082) : BeyanColors.tone(0xFF02362E);

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 4 : 2,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.18 : 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.55),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Aktif sekme altın spot ışığı hüzmesi (Spotlight Glow)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isSelected ? 18 : 0,
                height: isSelected ? 2.2 : 0,
                margin: EdgeInsets.only(bottom: isSelected ? 2.5 : 0),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFFFDF7A),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.75),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ]
                      : null,
                ),
              ),
              Icon(
                isSelected ? activeIcon : icon,
                size: isSelected ? 21 : 20,
                color: isSelected ? selectedIconColor : unselectedColor,
              ),
              const SizedBox(height: 2.5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? selectedTextColor : unselectedColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Merkezde yükseltilmiş altın & zümrüt Kur'an-ı Kerim mührü (Index 2)
  Widget _buildCenterSeal(BuildContext context, AppStrings strings) {
    final isSelected = currentIndex == 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap(2); // Kur'an-ı Kerim sekmesi
      },
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: strings.tabQuran,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isSelected ? 62 : 58,
          height: isSelected ? 62 : 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                BeyanColors.tone(0xFFFFEA75),
                BeyanColors.tone(0xFFD4AF37),
                BeyanColors.tone(0xFF996515),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isSelected ? 0.65 : 0.4),
                blurRadius: isSelected ? 20 : 16,
                offset: const Offset(0, 4),
                spreadRadius: isSelected ? 3 : 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isSelected
                      ? [BeyanColors.tone(0xFF0A6B5C), BeyanColors.tone(0xFF023E36)]
                      : [BeyanColors.tone(0xFF064E43), BeyanColors.tone(0xFF012E2B)],
                  center: const Alignment(0.0, -0.2),
                  radius: 0.85,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _RubElHizbSealPainter(
                          color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: isSelected ? 0.34 : 0.20),
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.menu_book_rounded,
                    color: BeyanColors.tone(0xFFFFEA75),
                    size: 25,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ortadaki Kur'an-ı Kerim mührü için ince İslami Sekizgen Yıldız (Rub el Hizb ۞) işlemeli halka
class _RubElHizbSealPainter extends CustomPainter {
  final Color color;
  const _RubElHizbSealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.39;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    // İki adet 45° döndürülmüş kare ile klasik Rub el Hizb (۞) sekizgeni
    for (int k = 0; k < 2; k++) {
      final angleOffset = k * (math.pi / 4);
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final a = angleOffset + i * (math.pi / 2);
        final pt = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RubElHizbSealPainter oldDelegate) =>
      oldDelegate.color != color;
}
