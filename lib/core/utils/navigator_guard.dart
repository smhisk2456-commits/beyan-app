import 'package:flutter/material.dart';

/// Beyân Navigasyon Koruyucu (Black Screen / Double-Pop Guard).
/// Aşağı kaydırma (drag / overscroll) veya hızlı çift tıklama sırasında
/// alttaki ana ekranın (MainNavigation / root route) yanlışlıkla pop edilip
/// siyah ekrana düşmesini %100 engeller.
class BeyanNavigatorGuard {
  BeyanNavigatorGuard._();

  static DateTime? _lastDragPopTime;
  static final Set<Route<dynamic>> _poppingRoutes = <Route<dynamic>>{};

  /// Sürükleme (drag handle) veya liste başından aşağı çekme (overscroll) ile
  /// açılır pencereleri güvenli şekilde tek seferde kapatır.
  static void safePopOnDrag(BuildContext context) {
    if (!context.mounted) return;

    final now = DateTime.now();
    if (_lastDragPopTime != null &&
        now.difference(_lastDragPopTime!).inMilliseconds < 650) {
      return;
    }

    final nav = Navigator.maybeOf(context);
    if (nav == null || !nav.canPop()) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isFirst) {
      if (!route.isCurrent || _poppingRoutes.contains(route)) {
        return;
      }
      _poppingRoutes.add(route);
      route.popped.whenComplete(() => _poppingRoutes.remove(route));
    }

    _lastDragPopTime = now;
    nav.pop();
  }

  /// Normal kapatma butonları için kök ekranı (isFirst / tek rota) asla kapatmayan güvenli pop.
  static void safePop(BuildContext context, [dynamic result]) {
    if (!context.mounted) return;
    final nav = Navigator.maybeOf(context);
    if (nav == null || !nav.canPop()) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isFirst) {
      if (!route.isCurrent || _poppingRoutes.contains(route)) {
        return;
      }
      _poppingRoutes.add(route);
      route.popped.whenComplete(() => _poppingRoutes.remove(route));
    }

    nav.pop(result);
  }

  /// ScrollView / ListView en üstteyken parmakla aşağı çekildiğinde (overscroll)
  /// güvenli şekilde sheet'i kapatır.
  static bool handleOverscrollDismiss(
    ScrollUpdateNotification notification,
    BuildContext context,
  ) {
    // Sadece kullanıcının parmağı ekranda aktif olarak aşağı çekerken (dragDetails != null)
    // ve en üstten en az 55 piksel aşağı esnetildiğinde tetikle.
    if (notification.dragDetails != null &&
        notification.metrics.pixels < -55 &&
        notification.scrollDelta != null &&
        notification.scrollDelta! < -4) {
      safePopOnDrag(context);
      return true;
    }
    return false;
  }
}
