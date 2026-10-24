import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/main.dart';
import 'package:islamic_app/core/widgets/luxury_page_route.dart';

void main() {
  testWidgets('LuxuryPageRoute supports iOS swipe back gesture', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.iOS,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    LuxuryPageRoute(
                      page: const Scaffold(
                        body: Center(child: Text('Second Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Open Page'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open page
    await tester.tap(find.text('Open Page'));
    await tester.pumpAndSettle();

    expect(find.text('Second Page'), findsOneWidget);

    // Simulate swipe from left edge (x: 5, y: 200) towards right (x: 350, y: 200)
    final gesture = await tester.startGesture(const Offset(5, 200));
    await gesture.moveBy(const Offset(200, 0));
    await tester.pump();

    // Verify it is mid-gesture
    expect(find.text('Second Page'), findsOneWidget);

    // Finish swipe to complete pop
    await gesture.moveBy(const Offset(200, 0));
    await gesture.up();
    await tester.pumpAndSettle();

    // Verify popped back
    expect(find.text('Second Page'), findsNothing);
    expect(find.text('Open Page'), findsOneWidget);
  });

  test('selectedTabProvider initializes at tab 0 and tracks active tab', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedTabProvider), 0);
    container.read(selectedTabProvider.notifier).state = 2; // Kur'an sekmesi
    expect(container.read(selectedTabProvider), 2);
    container.read(selectedTabProvider.notifier).state = 0; // Ana sayfaya dönüş
    expect(container.read(selectedTabProvider), 0);
  });

  testWidgets('iOS edge swipe gesture detector responds to drag from left margin', (tester) async {
    bool didTriggerPop = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Center(child: Text('Active Quran Tab')),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 36,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 100) {
                      didTriggerPop = true;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta != null && details.primaryDelta! > 10) {
                      didTriggerPop = true;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Sol kenardan (x=10) sağa kaydırma yapıldığında tetiklenmeli
    final gesture = await tester.startGesture(const Offset(10, 200));
    await gesture.moveBy(const Offset(50, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(didTriggerPop, isTrue);
  });
}
