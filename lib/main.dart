import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/localization/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/prayer_times/screens/prayer_times_screen.dart';
import 'features/quran/screens/surah_list_screen.dart';
import 'features/zikr/screens/zikirmatik_screen.dart';
import 'features/widget_service/widget_service.dart';
import 'features/widget_service/background_task_manager.dart';

import 'features/widget_service/screens/widget_center_screen.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/splash/screens/splash_screen.dart';
import 'core/widgets/luxury_floating_dock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // İnternet olmasa da çevrimdışı (offline) yerel fontları kullan:
  GoogleFonts.config.allowRuntimeFetching = false;

  // Tarih formatları
  await initializeDateFormatting('tr_TR', null);
  await initializeDateFormatting('en_US', null);
  await initializeDateFormatting('ar_SA', null);

  // Native servisleri arka planda (non-blocking) başlat:
  Future.microtask(() async {
    try {
      await WidgetService.initialize();
      final taskManager = BackgroundTaskManager();
      await taskManager.initialize();
      await taskManager.scheduleWidgetUpdate();
      WidgetService().updateAllWidgets();

      // Ezan ve Vakit Bildirim Servisi
      await NotificationService.instance.initialize();
      await NotificationService.instance.scheduleUpcomingPrayers();
    } catch (_) {}
  });

  runApp(const ProviderScope(child: IslamicApp()));
}

/// Ana uygulama widget'ı.
class IslamicApp extends ConsumerWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);

    return MaterialApp(
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
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Modern Floating Curved Bottom Navigation Bar
// ════════════════════════════════════════════════════════════════

final selectedTabProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  static const _screens = [
    HomeScreen(),
    PrayerTimesScreen(),
    SurahListScreen(),
    ZikirmatikScreen(),
    WidgetCenterScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: selectedTab,
        children: _screens,
      ),
      bottomNavigationBar: LuxuryFloatingDock(
        currentIndex: selectedTab,
        onTap: (i) => ref.read(selectedTabProvider.notifier).state = i,
      ),
    );
  }
}
