import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/beyan_colors.dart';

/// 3B Kart Açılımı, Altın Çerçeve Morfu ve 24K Işık Huzmesi Geçişli Lüks Sayfa Rotası
class LuxuryPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  LuxuryPageRoute({required this.page, super.settings})
      : super(
          opaque: false,
          barrierColor: Colors.black.withValues(alpha: 0.55),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutExpo,
              reverseCurve: Curves.easeInCubic,
            );

            return AnimatedBuilder(
              animation: curved,
              builder: (context, _) {
                final t = curved.value.clamp(0.0, 1.0);
                final inv = 1.0 - t;

                // 3B Karttan Tam Ekrana Yayılma (0.78 -> 1.0 ölçek + hafif 3B perspektif eğimi)
                final scale = 0.78 + (0.22 * t);
                final translateY = 64.0 * inv;
                final tiltX = 0.09 * inv;
                final radius = 34.0 * inv;
                final borderOpacity = (math.sin(t * 3.14159) * 0.95).clamp(0.0, 1.0);

                // Diyagonal 24K Altın Işık Huzmesi (Açılış esnasında ekranın üzerinden süzülür)
                final sweepPos = -1.2 + (t * 2.6);

                final matrix = Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..translateByDouble(0.0, translateY, 0.0, 1.0)
                  ..scaleByDouble(scale, scale, 1.0, 1.0)
                  ..rotateX(tiltX);

                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
                    ),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: matrix,
                    child: Container(
                      decoration: radius > 0.5
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(radius),
                              boxShadow: [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35 * borderOpacity),
                                  blurRadius: 36,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6 * t),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            )
                          : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            child,

                            // 24K Altın Işık Süzülmesi (Açılışta kartın üstünden geçen lüks parıltı)
                            if (t > 0.02 && t < 0.97)
                              IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(sweepPos - 0.55, -1.0),
                                      end: Alignment(sweepPos + 0.55, 1.0),
                                      colors: [
                                        Colors.transparent,
                                        BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.16 * inv),
                                        BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.32 * inv),
                                        Colors.white.withValues(alpha: 0.24 * inv),
                                        BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.14 * inv),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.35, 0.48, 0.52, 0.65, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                            // Açılış esnasında parlayan ince 24K altın kenarlık (Tam ekrana oturunca kaybolur)
                            if (radius > 0.8)
                              IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(radius),
                                    border: Border.all(
                                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: borderOpacity),
                                      width: 2.0 * inv + 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
}

/// Dokunulduğunda fiziksel yaylanma ve altın hale tepkisi veren lüks sarmalayıcı
class LuxuryTapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const LuxuryTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<LuxuryTapScale> createState() => _LuxuryTapScaleState();
}

class _LuxuryTapScaleState extends State<LuxuryTapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapCancel: () => _controller.reverse(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
