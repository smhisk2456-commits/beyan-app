import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
