import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/calendar/screens/hijri_calendar_screen.dart';
import 'package:islamic_app/features/dua/screens/dua_library_screen.dart';
import 'package:islamic_app/features/home/screens/home_screen.dart';
import 'package:islamic_app/features/prayer_times/models/calculation_settings_model.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';
import 'package:islamic_app/features/prayer_times/providers/prayer_time_providers.dart';
import 'package:islamic_app/features/prayer_times/screens/prayer_times_screen.dart';
import 'package:islamic_app/features/prayer_times/services/prayer_time_service.dart';
import 'package:islamic_app/features/quran/screens/surah_list_screen.dart';
import 'package:islamic_app/features/settings/screens/settings_screen.dart';
import 'package:islamic_app/features/widget_service/screens/widget_center_screen.dart';
import 'package:islamic_app/features/zikr/screens/zikirmatik_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iPhone 6s ve sonrası tüm modellerin mantıksal ekran boyutları (pt) ve ölçek oranı.
const _devices = <String, List<double>>{
  'iPhone SE 1 (320x568)': [320, 568, 2],
  'iPhone 6s/7/8/SE2/SE3 (375x667)': [375, 667, 2],
  'iPhone 6s/7/8 Plus (414x736)': [414, 736, 3],
  'iPhone X/XS/11 Pro/12 mini/13 mini (375x812)': [375, 812, 3],
  'iPhone XR/11 (414x896)': [414, 896, 2],
  'iPhone XS Max/11 Pro Max (414x896)': [414, 896, 3],
  'iPhone 12/13/14 (390x844)': [390, 844, 3],
  'iPhone 12/13/14 Pro Max (428x926)': [428, 926, 3],
  'iPhone 14 Pro/15/16 (393x852)': [393, 852, 3],
  'iPhone 14 Plus/15 Plus (430x932)': [430, 932, 3],
  'iPhone 16 Pro (402x874)': [402, 874, 3],
  'iPhone 16 Pro Max (440x956)': [440, 956, 3],
};

// ── Sahte namaz verisi ────────────────────────────────────────────

enum _Scenario { yatsiSirada, aksamSirada, imsakSirada }

class _FakePrayerNotifier extends PrayerTimesNotifier {
  final _Scenario scenario;
  final String city;
  _FakePrayerNotifier(this.scenario, this.city);

  @override
  Future<DailyPrayerTimes> build() async {
    final base = await PrayerTimeService().calculatePrayerTimes(
      location: LocationData(
        latitude: 41.0,
        longitude: 29.0,
        cityName: city,
        isFromGPS: false,
      ),
      method: PrayerCalculationMethod.diyanet,
    );
    final now = DateTime.now();
    List<int> offsetsHours;
    switch (scenario) {
      case _Scenario.yatsiSirada:
        offsetsHours = [-14, -12, -8, -5, -1, 1];
        break;
      case _Scenario.aksamSirada:
        offsetsHours = [-12, -10, -6, -3, 1, 3];
        break;
      case _Scenario.imsakSirada:
        offsetsHours = [-20, -18, -14, -11, -7, -5];
        break;
    }
    const names = PrayerName.values;
    final prayers = <PrayerEntry>[
      for (var i = 0; i < 6; i++)
        PrayerEntry(
          name: names[i],
          time: now.add(Duration(hours: offsetsHours[i])),
        ),
    ];
    return DailyPrayerTimes(
      date: now,
      locationName: city,
      latitude: base.latitude,
      longitude: base.longitude,
      prayers: prayers,
      prayerTimes: base.prayerTimes,
      tomorrowFajr: now.add(const Duration(hours: 8)),
    );
  }
}

// ── Hata toplama ──────────────────────────────────────────────────

final _overflows = <String>{};
final _other = <String>{};
void Function(FlutterErrorDetails)? _original;

void _capture(FlutterErrorDetails d) {
  final text = d.toDiagnosticsNode().toStringDeep(minLevel: DiagnosticLevel.debug);
  final loc = RegExp(r'file:///[^\s]*/(lib/[^\s]+\.dart:\d+)').firstMatch(text);
  final size = RegExp(r'overflowed by [\d.]+ pixels').firstMatch(text);
  if (size != null) {
    _overflows.add('${size.group(0)} @ ${loc?.group(1) ?? '?'}');
  }
}

void _finish(WidgetTester tester, String label) {
  tester.takeException();
  FlutterError.onError = _original;
  if (_overflows.isNotEmpty) {
    final msg = _overflows.join('\n');
    _overflows.clear();
    fail('Taşma bulundu [$label]:\n$msg');
  }
}

Future<void> _pump(
  WidgetTester tester,
  List<double> dev,
  double scale,
  Widget home, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = Size(dev[0] * dev[2], dev[1] * dev[2]);
  tester.view.devicePixelRatio = dev[2];
  _overflows.clear();
  _other.clear();
  _original = FlutterError.onError;
  FlutterError.onError = _capture;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _scrollThrough(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  for (var i = 0; i < 18; i++) {
    await tester.drag(scrollable.first, const Offset(0, -380),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final screens = <String, Widget>{
    'Vakitler': const PrayerTimesScreen(),
    'Kur\'an': const SurahListScreen(),
    'Zikirmatik': const ZikirmatikScreen(),
    'Widget Merkezi': const WidgetCenterScreen(),
    'Ayarlar': const SettingsScreen(),
    'Dua Kütüphanesi': const DuaLibraryScreen(),
    'Hicri Takvim': const HijriCalendarScreen(),
  };

  for (final scale in [1.0, 1.3]) {
    for (final d in _devices.entries) {
      // 1) Namaz kartı + ayet sekmeleri dahil tüm ana sayfa (3 farklı sıradaki namaz)
      for (final sc in _Scenario.values) {
        testWidgets('Ana sayfa (veri dolu, ${sc.name}): ${d.key} x$scale',
            (tester) async {
          await _pump(
            tester,
            d.value,
            scale,
            const HomeScreen(),
            overrides: [
              countdownStringProvider.overrideWith((ref) => Stream.value('1s 36dk kaldı')),
              prayerProgressProvider.overrideWith((ref) => Stream.value(0.45)),
              prayerTimesNotifierProvider.overrideWith(
                () => _FakePrayerNotifier(
                  sc,
                  sc == _Scenario.imsakSirada
                      ? 'Mevcut Konum'
                      : 'Beylikdüzü, İstanbul',
                ),
              ),
            ],
          );
          expect(find.byType(HomeScreen), findsOneWidget);
          _finishCheck(tester, 'ana sayfa üst');
          await _scrollThrough(tester);
          _finish(tester, 'Ana sayfa ${sc.name} ${d.key} x$scale');
        });
      }

      // 2) Diğer ekranlar
      for (final s in screens.entries) {
        testWidgets('${s.key}: ${d.key} x$scale', (tester) async {
          await _pump(
            tester,
            d.value,
            scale,
            s.value,
            overrides: [
              countdownStringProvider.overrideWith((ref) => Stream.value('1s 36dk kaldı')),
              prayerProgressProvider.overrideWith((ref) => Stream.value(0.45)),
              prayerTimesNotifierProvider.overrideWith(
                () => _FakePrayerNotifier(
                    _Scenario.yatsiSirada, 'Beylikdüzü, İstanbul'),
              ),
            ],
          );
          await _scrollThrough(tester);
          _finish(tester, '${s.key} ${d.key} x$scale');
        });
      }
    }
  }
}

void _finishCheck(WidgetTester tester, String label) {
  // Ara kontrol: ilk çizimdeki taşmalar _finish içinde birlikte raporlanır.
}
