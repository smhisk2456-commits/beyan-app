import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Apple iOS yerel akıcı sağa kaydırma (interactive pop gesture / edge swipe to back)
/// ve 120Hz ProMotion uyumlu Cupertino geçişli sayfa rotası.
class LuxuryPageRoute<T> extends CupertinoPageRoute<T> {
  final Widget page;

  LuxuryPageRoute({
    required this.page,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
  }) : super(builder: (_) => RepaintBoundary(child: page));
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
