import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/widgets/luxury_floating_dock.dart';
import 'package:islamic_app/features/home/screens/home_screen.dart';
import 'package:islamic_app/features/prayer_times/screens/nafila_prayers_sheet.dart';

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

/// Çerçeve hatalarını toplar; taşmaların kaynak satırını da kaydeder.
final _errors = <String>[];
void Function(FlutterErrorDetails)? _original;

void _capture(FlutterErrorDetails d) {
  final text = d.toDiagnosticsNode().toStringDeep(minLevel: DiagnosticLevel.debug);
  final loc = RegExp(r'(\w+):file:///[^\s]*/(lib/[^\s]+\.dart:\d+)')
      .firstMatch(text);
  final size = RegExp(r'overflowed by [\d.]+ pixels').firstMatch(text);
  _errors.add('${size?.group(0) ?? d.exceptionAsString().split('\n').first}'
      ' @ ${loc?.group(2) ?? '?'}');
}

void _expectNoErrors() {
  FlutterError.onError = _original;
  if (_errors.isNotEmpty) {
    final msg = _errors.toSet().join('\n');
    _errors.clear();
    fail('Taşma/hata bulundu:\n$msg');
  }
}

Future<void> _pump(WidgetTester tester, double w, double h, double dpr,
    double scale, Widget home) async {
  tester.view.physicalSize = Size(w * dpr, h * dpr);
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
  _errors.clear();
  _original = FlutterError.onError;
  FlutterError.onError = _capture;

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  for (final scale in [1.0, 1.3]) {
    for (final entry in _devices.entries) {
      final name = entry.key;
      final w = entry.value[0];
      final h = entry.value[1];
      final dpr = entry.value[2];

      testWidgets('Ana sayfa taşma yok: $name (yazı x$scale)', (tester) async {
        await _pump(tester, w, h, dpr, scale, const HomeScreen());
        _expectNoErrors();
      });

      testWidgets('Nafile namazlar taşma yok: $name (yazı x$scale)',
          (tester) async {
        await _pump(
          tester,
          w,
          h,
          dpr,
          scale,
          Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () => NafilaPrayersSheet.show(ctx),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pump(const Duration(seconds: 1));
        _expectNoErrors();
      });

      testWidgets('Lüks Alt Bar (Dock) taşma ve kırpılma yok: $name (yazı x$scale)',
          (tester) async {
        await _pump(
          tester,
          w,
          h,
          dpr,
          scale,
          Scaffold(
            bottomNavigationBar: LuxuryFloatingDock(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        );
        _expectNoErrors();
        expect(find.text('Widget'), findsOneWidget);
        expect(find.text('Zikirmatik'), findsOneWidget);
      });
    }
  }
}


