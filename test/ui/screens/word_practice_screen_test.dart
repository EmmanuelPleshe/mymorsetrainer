import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/ui/screens/word_practice_screen.dart';

void main() {
  group('WordPracticeScreen', () {
    testWidgets('renders app bar with Word Practice title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WordPracticeScreen()),
      );

      expect(find.text('Word Practice'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows ??? initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WordPracticeScreen()),
      );

      expect(find.text('???'), findsOneWidget);
    });

    testWidgets('tapping Show Answer reveals word and feedback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WordPracticeScreen()),
      );

      await tester.tap(find.text('Show Answer'));
      await tester.pump();

      expect(find.text('???'), findsNothing);
      expect(find.textContaining('Answer:'), findsOneWidget);
    });

    testWidgets('tapping Next updates word counter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WordPracticeScreen()),
      );

      expect(find.text('Word 1 of 20'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Word 2 of 20'), findsOneWidget);
    });

    testWidgets('tapping refresh resets counter to 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: WordPracticeScreen()),
      );

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Word 2 of 20'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(find.text('Word 1 of 20'), findsOneWidget);
    });
  });
}
