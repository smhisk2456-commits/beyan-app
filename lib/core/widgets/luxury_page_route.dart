import 'package:flutter/material.dart';

/// İpeksi ve lüks açılış animasyonlu rota (Shared Card Zoom & Fade)
class LuxuryPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  LuxuryPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            );
          },
        );
}
