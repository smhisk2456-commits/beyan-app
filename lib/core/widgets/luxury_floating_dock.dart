import 'dart:ui';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // ── Ana Yüzen Bar Gövdesi ──────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xF0012E2B),
                          Color(0xF8021B17),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF033E35).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 1. Sekme: Ana Sayfa
                          _buildTabItem(
                            index: 0,
                            icon: Icons.explore_rounded,
                            activeIcon: Icons.explore,
                            label: strings.tabHome,
                          ),

                          // 2. Sekme: Vakitler
                          _buildTabItem(
                            index: 1,
                            icon: Icons.access_time_rounded,
                            activeIcon: Icons.access_time_filled_rounded,
                            label: strings.tabPrayers,
                          ),

                          // Merkez buton için boşluk (Kur'an-ı Kerim)
                          const SizedBox(width: 58),

                          // 3. Sekme: Zikirmatik (Index 3)
                          _buildTabItem(
                            index: 3,
                            icon: Icons.fingerprint_rounded,
                            activeIcon: Icons.fingerprint,
                            label: strings.tabZikr,
                          ),

                          // 4. Sekme: Widget & Kilit Ekranı (Index 4)
                          _buildTabItem(
                            index: 4,
                            icon: Icons.widgets_outlined,
                            activeIcon: Icons.widgets_rounded,
                            label: strings.tabWidget,
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
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFFFDF7A).withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: isSelected ? 23 : 21,
              color: isSelected ? const Color(0xFFFFE082) : Colors.white60,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFFFFE082) : Colors.white60,
                letterSpacing: 0.2,
              ),
            ),
          ],
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
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFEA75),
                Color(0xFFD4AF37),
                Color(0xFF996515),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: isSelected ? 0.65 : 0.4),
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
                      ? const [Color(0xFF0A6B5C), Color(0xFF023E36)]
                      : const [Color(0xFF064E43), Color(0xFF012E2B)],
                  center: const Alignment(0.0, -0.2),
                  radius: 0.85,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFFFEA75),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
