import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/beyan_colors.dart';
import 'core/theme/theme_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/prayer_times/providers/prayer_time_providers.dart';
import 'features/prayer_times/screens/prayer_times_screen.dart';
import 'features/quran/screens/surah_list_screen.dart';
import 'features/zikr/screens/zikirmatik_screen.dart';
import 'features/widget_service/widget_service.dart';
import 'features/widget_service/background_task_manager.dart';

import 'features/widget_service/screens/widget_center_screen.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/monetization/services/ad_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'features/monetization/services/premium_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/quran/widgets/quran_audio_player_bar.dart';
import 'features/notifications/widgets/adhan_audio_player_bar.dart';
import 'core/widgets/luxury_floating_dock.dart';
import 'core/services/deep_link_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Audio Session Ayarı (iOS Sessiz Mod Desteği & Hoparlör Yönlendirmesi)
  try {
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  } catch (e) {
    debugPrint('AudioPlayer global audio context hatası: $e');
  }

  // İnternet olmasa da çevrimdışı (offline) yerel fontları kullan:
  GoogleFonts.config.allowRuntimeFetching = false;

  // Tarih formatları (Tüm desteklenen diller için)
  for (final loc in [
    'tr',
    'tr_TR',
    'en',
    'en_US',
    'ar',
    'ar_SA',
    'id',
    'id_ID',
    'fr',
    'fr_FR',
    'de',
    'de_DE',
    'ru',
    'ru_RU',
    'ur',
    'ur_PK'
  ]) {
    try {
      await initializeDateFormatting(loc, null);
    } catch (_) {}
  }

  // Native servisleri arka planda (non-blocking ve izole) başlat:
  Future.microtask(() async {
    // 1. Widget Servisi
    try {
      await WidgetService.initialize();
      WidgetService().updateAllWidgets();
    } catch (e) {
      debugPrint('WidgetService başlatma hatası: $e');
    }

    // 2. Arka Plan Görevleri (Android WorkManager)
    try {
      final taskManager = BackgroundTaskManager();
      await taskManager.initialize();
      await taskManager.scheduleWidgetUpdate();
    } catch (e) {
      debugPrint('BackgroundTaskManager başlatma hatası (iOS veya kısıtlı ortam): $e');
    }

    // 3. Ezan ve Vakit Bildirim Servisi
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.scheduleUpcomingPrayers();
      await NotificationService.instance.scheduleDailyVerseNotifications();
    } catch (e) {
      debugPrint('NotificationService başlatma hatası: $e');
    }

    // 4. Premium & Reklam Servisleri
    try {
      await PremiumService.instance.initialize();
      await AdService.instance.initialize();
    } catch (e) {
      debugPrint('Monetization servisleri başlatma hatası: $e');
    }
  });

  runApp(const ProviderScope(child: IslamicApp()));
}

/// Ana uygulama widget'ı.
class IslamicApp extends ConsumerWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final themeState = ref.watch(themeProvider);
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);

    return MaterialApp(
      navigatorKey: DeepLinkService.navigatorKey,
      title: 'Beyân',
      debugShowCheckedModeBanner: false,
      locale: currentLang.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('ar'),
        Locale('id'),
        Locale('fr'),
        Locale('ur'),
        Locale('de'),
        Locale('ru'),
      ],
      themeAnimationDuration: Duration.zero,
      theme: AppTheme.buildTheme(effectivePalette, isDark: false),
      darkTheme: AppTheme.buildTheme(effectivePalette, isDark: true),
      themeMode: themeState.mode,
      home: const SplashScreen(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Modern Floating Curved Bottom Navigation Bar
// ════════════════════════════════════════════════════════════════

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late Animation<double> _slideAnimation;

  final List<int> _tabHistory = [0];
  int _currentTab = 0;
  int _targetTab = 0;
  bool _isBackTransition = false;
  bool _isInteractiveDragging = false;
  double _dragProgress = 0.0;

  final List<GlobalKey> _tabKeys = List.generate(5, (_) => GlobalKey());
  Widget _tab(int i) => RepaintBoundary(key: _tabKeys[i], child: _tabs[i]);

  static const List<Widget> _tabs = [
    HomeScreen(key: PageStorageKey('tab_home')),
    PrayerTimesScreen(key: PageStorageKey('tab_prayer')),
    SurahListScreen(key: PageStorageKey('tab_quran')),
    ZikirmatikScreen(key: PageStorageKey('tab_zikr')),
    WidgetCenterScreen(key: PageStorageKey('tab_widget')),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.instance.init(ref);
      DeepLinkService.instance.processPending(ref);
      _checkLaunchPaywall();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    DeepLinkService.instance.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _navigateToTab(int newTab, {bool isBack = false}) {
    if (newTab == _currentTab) return;
    if (_animController.isAnimating) return;

    final goingBack = isBack || (newTab == 0 && _currentTab != 0) || (newTab < _currentTab);
    setState(() {
      _targetTab = newTab;
      _isBackTransition = goingBack;
      _isInteractiveDragging = false;
      _dragProgress = 0.0;
    });

    _animController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _currentTab = newTab;
        if (goingBack) {
          if (_tabHistory.length > 1) {
            _tabHistory.removeLast();
          } else {
            _tabHistory.clear();
            _tabHistory.add(0);
          }
        } else {
          _tabHistory.add(newTab);
        }
      });
      _animController.reset();
      if (ref.read(selectedTabProvider) != newTab) {
        ref.read(selectedTabProvider.notifier).state = newTab;
      }
    });
  }

  void _popToPreviousTab() {
    if (_animController.isAnimating || _isInteractiveDragging) return;
    int prevTab = 0;
    if (_tabHistory.length > 1) {
      prevTab = _tabHistory[_tabHistory.length - 2];
    }
    _navigateToTab(prevTab, isBack: true);
  }

  void _onEdgeDragStart(DragStartDetails details) {
    if (_currentTab == 0 || _animController.isAnimating) return;

    int prevTab = 0;
    if (_tabHistory.length > 1) {
      prevTab = _tabHistory[_tabHistory.length - 2];
    }

    setState(() {
      _isInteractiveDragging = true;
      _targetTab = prevTab;
      _isBackTransition = true;
      _dragProgress = 0.0;
    });
  }

  void _onEdgeDragUpdate(DragUpdateDetails details, double screenWidth, {bool isRtl = false}) {
    if (!_isInteractiveDragging) return;
    final rawDelta = details.primaryDelta ?? 0;
    final delta = isRtl ? -rawDelta : rawDelta;
    setState(() {
      _dragProgress = (_dragProgress + (delta / screenWidth)).clamp(0.0, 1.0);
    });
  }

  void _onEdgeDragEnd(DragEndDetails details, {bool isRtl = false}) {
    if (!_isInteractiveDragging) return;
    final rawVelocity = details.primaryVelocity ?? 0;
    final velocity = isRtl ? -rawVelocity : rawVelocity;
    final shouldPop = _dragProgress > 0.28 || velocity > 320;

    if (shouldPop) {
      HapticFeedback.lightImpact();
      _animController.duration = Duration(
        milliseconds: ((1.0 - _dragProgress) * 220).round().clamp(80, 220),
      );
      _slideAnimation = Tween<double>(begin: _dragProgress, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _currentTab = _targetTab;
          if (_tabHistory.length > 1) {
            _tabHistory.removeLast();
          } else {
            _tabHistory.clear();
            _tabHistory.add(0);
          }
          _isInteractiveDragging = false;
          _dragProgress = 0.0;
        });
        _animController.reset();
        _animController.duration = const Duration(milliseconds: 280);
        _slideAnimation = CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        );
        ref.read(selectedTabProvider.notifier).state = _currentTab;
      });
    } else {
      _animController.duration = Duration(
        milliseconds: (_dragProgress * 180).round().clamp(60, 180),
      );
      _slideAnimation = Tween<double>(begin: _dragProgress, end: 0.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() {
          _isInteractiveDragging = false;
          _dragProgress = 0.0;
        });
        _animController.reset();
        _animController.duration = const Duration(milliseconds: 280);
        _slideAnimation = CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // iOS uyku sonrası gün değişimi kontrolü:
      // Eğer hafızadaki vakitler bugüne ait değilse hemen taze vakitleri hesapla
      final currentDaily = ref.read(prayerTimesNotifierProvider).valueOrNull;
      final now = DateTime.now();
      if (currentDaily == null ||
          currentDaily.date.year != now.year ||
          currentDaily.date.month != now.month ||
          currentDaily.date.day != now.day) {
        ref.read(prayerTimesNotifierProvider.notifier).refresh();
      } else {
        NotificationService.instance.scheduleUpcomingPrayers();
        NotificationService.instance.scheduleDailyVerseNotifications();
        WidgetService().updateAllWidgets();
      }
    }
  }

  Future<void> _checkLaunchPaywall() async {
    // v1.0 sürümünde tüm özellikler ücretsizdir; açılışta paywall gösterilmez
    return;
  }

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);

    // Dışarıdan veya alt barda dokunarak sekme değişimi tetiklendiğinde
    ref.listen<int>(selectedTabProvider, (prev, next) {
      if (next != _currentTab && !_isInteractiveDragging && !_animController.isAnimating) {
        _navigateToTab(next);
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: _currentTab == 0 && !_animController.isAnimating && !_isInteractiveDragging,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentTab != 0) {
          _popToPreviousTab();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final double progress = _isInteractiveDragging
                ? _dragProgress
                : (_animController.isAnimating ? _slideAnimation.value : 0.0);
            final bool isTransitioning = _isInteractiveDragging || _animController.isAnimating;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Tüm sekmelerin durumunu (scroll, timer vb.) koruyan ana katman
                if (!isTransitioning)
                  for (int i = 0; i < _tabs.length; i++)
                    Offstage(
                      offstage: i != _currentTab,
                      child: TickerMode(
                        enabled: i == _currentTab,
                        child: _tab(i),
                      ),
                    ),

                // 2. Geçiş Anında: Arka Plandaki Sekme (iOS Parallaks ve Scrim Efekti)
                if (isTransitioning) ...[
                  // Geçişe katılmayan diğer 3 sekmenin de ağaçta state'ini koruyarak kalması:
                  for (int i = 0; i < _tabs.length; i++)
                    if (i != (_isBackTransition ? _targetTab : _currentTab) &&
                        i != (_isBackTransition ? _currentTab : _targetTab))
                      Offstage(
                        offstage: true,
                        child: TickerMode(
                          enabled: false,
                          child: _tab(i),
                        ),
                      ),

                  Builder(
                    builder: (context) {
                      final isRtl = Directionality.of(context) == TextDirection.rtl;
                      final sign = isRtl ? -1.0 : 1.0;
                      final bottomIndex = _isBackTransition ? _targetTab : _currentTab;
                      final bottomOffsetFactor = _isBackTransition
                          ? -0.25 * (1.0 - progress)
                          : -0.25 * progress;
                      final scrimOpacity = _isBackTransition
                          ? (0.22 * (1.0 - progress)).clamp(0.0, 0.22)
                          : (0.22 * progress).clamp(0.0, 0.22);

                      return Transform.translate(
                        offset: Offset(sign * bottomOffsetFactor * screenWidth, 0),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _tab(bottomIndex),
                            if (scrimOpacity > 0.01)
                              IgnorePointer(
                                child: Container(
                                  color: Colors.black.withValues(alpha: scrimOpacity),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 3. Geçiş Anında: Ön Plandaki Sekme (iOS Sağa Kayma ve Sol Kenar Gölgesi)
                  Builder(
                    builder: (context) {
                      final isRtl = Directionality.of(context) == TextDirection.rtl;
                      final sign = isRtl ? -1.0 : 1.0;
                      final topIndex = _isBackTransition ? _currentTab : _targetTab;
                      final topOffsetFactor = _isBackTransition
                          ? progress
                          : (1.0 - progress);

                      return Transform.translate(
                        offset: Offset(sign * topOffsetFactor * screenWidth, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: (0.32 * (1.0 - progress)).clamp(0.0, 0.32),
                                ),
                                blurRadius: 22,
                                spreadRadius: 1,
                                offset: Offset(sign * -8, 0),
                              ),
                            ],
                          ),
                          child: _tab(topIndex),
                        ),
                      );
                    },
                  ),
                ],

                // 4. Apple iOS Kenardan Sağa Çekerek Geri Dönme Dokunma Alanı (Edge Swipe Recognizer)
                if (_currentTab != 0)
                  Builder(
                    builder: (context) {
                      final isRtl = Directionality.of(context) == TextDirection.rtl;
                      return Positioned(
                        top: 0,
                        bottom: 0,
                        left: isRtl ? null : 0,
                        right: isRtl ? 0 : null,
                        width: 36,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragStart: _onEdgeDragStart,
                          onHorizontalDragUpdate: (d) => _onEdgeDragUpdate(d, screenWidth, isRtl: isRtl),
                          onHorizontalDragEnd: (d) => _onEdgeDragEnd(d, isRtl: isRtl),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdhanAudioPlayerBar(),
              const QuranAudioPlayerBar(),
              LuxuryFloatingDock(
                currentIndex: _currentTab,
                onTap: (i) => _navigateToTab(i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
