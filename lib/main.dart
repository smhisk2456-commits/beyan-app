import 'package:flutter/material.dart';
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
import 'features/monetization/widgets/beyan_banner_ad_widget.dart';

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
    with WidgetsBindingObserver {
  final List<int> _tabHistory = [0];
  int _currentTab = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService.instance.init(ref);
      DeepLinkService.instance.processPending(ref);
    });
  }

  @override
  void dispose() {
    DeepLinkService.instance.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _navigateToTab(int newTab) {
    if (newTab == _currentTab) return;
    setState(() {
      _currentTab = newTab;
      _tabHistory.add(newTab);
    });
    ref.read(selectedTabProvider.notifier).state = newTab;
  }

  void _popToPreviousTab() {
    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      final prevTab = _tabHistory.last;
      setState(() => _currentTab = prevTab);
      ref.read(selectedTabProvider.notifier).state = prevTab;
    } else {
      _navigateToTab(0);
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

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);

    // Dışarıdan veya alt barda dokunarak sekme değişimi tetiklendiğinde
    ref.listen<int>(selectedTabProvider, (prev, next) {
      if (next != _currentTab) {
        _navigateToTab(next);
      }
    });

    return PopScope(
      canPop: _currentTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentTab != 0) {
          _popToPreviousTab();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentTab,
          children: _tabs,
        ),
        bottomNavigationBar: RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BeyanBannerAdWidget(),
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
