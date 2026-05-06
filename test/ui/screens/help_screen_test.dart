import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/ui/screens/help_screen.dart';

void main() {
  group('HelpScreen', () {
    testWidgets('renders app bar with Help title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpScreen()),
      );

      expect(find.text('Help'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders key help sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpScreen()),
      );

      // Check first few sections visible without scrolling
      expect(find.text('What is the Koch Method?'), findsOneWidget);
      expect(find.text('How to Key Input'), findsOneWidget);

      // Scroll to find more sections
      await tester.scrollUntilVisible(find.text('Settings Explained'), 100);
      expect(find.text('Settings Explained'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Progression & Levels'), 100);
      expect(find.text('Progression & Levels'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('What the Colors Mean'), 100);
      expect(find.text('What the Colors Mean'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Why Did It Submit Early?'), 100);
      expect(find.text('Why Did It Submit Early?'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Troubleshooting & FAQ'), 100);
      expect(find.text('Troubleshooting & FAQ'), findsOneWidget);
    });

    testWidgets('renders content text for each section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpScreen()),
      );

      expect(find.textContaining('K and M'), findsOneWidget);
      expect(find.textContaining('Spacebar'), findsOneWidget);

      await tester.scrollUntilVisible(find.textContaining('Farnsworth'), 100);
      expect(find.textContaining('Farnsworth'), findsOneWidget);

      await tester.scrollUntilVisible(find.textContaining('90% accuracy'), 100);
      expect(find.textContaining('90% accuracy'), findsOneWidget);

      await tester.scrollUntilVisible(find.textContaining('Blue'), 100);
      expect(find.textContaining('Blue'), findsOneWidget);

      await tester.scrollUntilVisible(find.textContaining('Input Timeout'), 100);
      expect(find.textContaining('Input Timeout'), findsOneWidget);
    });

    testWidgets('renders cards for visible sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpScreen()),
      );

      expect(find.byType(Card), findsAtLeastNWidgets(2));
    });

    testWidgets('is scrollable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HelpScreen()),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
