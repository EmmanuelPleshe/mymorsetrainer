import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/ui/screens/qso_practice_screen.dart';

void main() {
  group('QSOPracticeScreen', () {
    testWidgets('renders app bar with QSO Phrases title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      expect(find.text('QSO Phrases'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows ??? initially and hides phrase text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      expect(find.text('???'), findsOneWidget);
    });

    testWidgets('tapping Show Meaning reveals phrase and category', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      await tester.tap(find.text('Show Meaning'));
      await tester.pump();

      expect(find.text('???'), findsNothing);
      expect(find.textContaining('Category:'), findsOneWidget);
    });

    testWidgets('tapping Next updates phrase counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      expect(find.text('Phrase 1 of 15'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Phrase 2 of 15'), findsOneWidget);
    });

    testWidgets('tapping refresh resets counter to 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Phrase 2 of 15'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(find.text('Phrase 1 of 15'), findsOneWidget);
    });

    testWidgets('category popup menu exists and shows options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QSOPracticeScreen()),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('All Phrases'), findsOneWidget);
      expect(find.textContaining('Calling'), findsAtLeastNWidgets(1));
    });
  });
}
