import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../../../main.dart';

/// Lüks İslami Animasyonlu Açılış (Splash) Ekranı.
/// Yenilenen HD Beyân logosu, altın parıltı aurası ve Besmele-i Şerif içerir.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _haloPulse;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  Timer? _navigationTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('>>> SPLASH SCREEN INIT STARTED');

    // 1. Giriş Animasyonu (Logo büyüme ve beliriş)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // 2. Altın Işık Aurası Nefes Animasyonu (Sürekli yumuşak nabız)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _haloPulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 3. Yazı ve Besmele Belirme Animasyonu
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animasyon zincirini başlat
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    _entranceController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      _textController.forward();
    }

    // 3.2 saniye sonra ana menüye zarif geçiş yap (veya ekrana dokunulduğunda)
    _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
      _navigateToHome();
    });

    // Widget'a tıklanarak açılmışsa uzun süre bekletmeden hemen ana menüye geç
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null && mounted && !_navigated) {
        _navigationTimer?.cancel();
        _navigationTimer = Timer(const Duration(milliseconds: 300), () {
          _navigateToHome();
        });
      }
    });
  }

  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> SPLASH SCREEN BUILD CALLED');
    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToHome();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.25,
              colors: [
                Color(0xFF13151E),
                Color(0xFF0A0C10),
                Color(0xFF07080A),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Arka Plan Yumuşak Şampanya Altın Işık Aurası (Breathing Halo) ──
              AnimatedBuilder(
                animation: _haloPulse,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _haloPulse.value,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF0D399).withValues(alpha: 0.28),
                            const Color(0xFFD4AF37).withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── İçerik: Logo + Beyân + Besmele ──
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // 1. Logo ve Parıltılı Çerçeve
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoFade.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 154,
                        height: 154,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          border: Border.all(
                            color: const Color(0xFFF0D399).withValues(alpha: 0.75),
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF0D399).withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 154,
                            height: 154,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. Uygulama Adı & Besmele-i Şerif
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textFade,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Beyân Başlığı
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFFFF2D4),
                                Color(0xFFF0D399),
                                Color(0xFFC8A765),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Text(
                              'Beyân',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3.2,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // İnce Altın Ayraç
                          Container(
                            width: 64,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFF0D399),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Sade ve Zarif Alt Başlık
                          Text(
                            'VAKİTLER • KUR\'AN • MANEVİYAT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.8,
                              color: const Color(0xFFF0D399).withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Alt Zarafet Göstergesi
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: index == 1 ? 18 : 6,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: index == 1
                                      ? const Color(0xFFF0D399)
                                      : const Color(0xFFF0D399).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                        ],
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
}
