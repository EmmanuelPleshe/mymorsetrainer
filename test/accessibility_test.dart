import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/ui/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen meets text contrast guidelines', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onComplete: () {},
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}