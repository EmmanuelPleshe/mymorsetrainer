import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/audio_service.dart';
import 'package:morse_trainer/ui/screens/word_practice_screen.dart';

import '../../helpers/mocks/mock_audio_service.dart';

void main() {
  group('WordPracticeScreen', () {
    late MockAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockAudioService();
      when(() => mockAudioService.initialize()).thenAnswer((_) async {});
      when(() => mockAudioService.playWord(any(), onFlash: any(named: 'onFlash')))
          .thenAnswer((_) async {});
      when(() => mockAudioService.keyerDown()).thenAnswer((_) async {});
      when(() => mockAudioService.keyerUp()).thenAnswer((_) async {});
      when(() => mockAudioService.playCorrectFeedback()).thenAnswer((_) async {});
    });

    testWidgets('renders app bar with Word Practice title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );

      expect(find.text('Word Practice'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows listen phase initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );

      expect(find.text('Listen...'), findsOneWidget);
      expect(find.text('???'), findsOneWidget);
    });

    testWidgets('shows keying phase after audio finishes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );
      await tester.pump();

      expect(find.text('Key the word!'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows raw pattern while keying', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );
      await tester.pump();

      // Simulate keying a dot
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(find.text('.'), findsOneWidget);
    });

    testWidgets('submit replays word audio on feedback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );
      await tester.pump();

      // Key some pattern and submit
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Word audio should replay on feedback (initial play + replay)
      verify(() => mockAudioService.playWord(any(), onFlash: any(named: 'onFlash'))).called(greaterThan(1));
    });

    testWidgets('refresh button shuffles words', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(audioService: mockAudioService)),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should still show Word 1 after refresh
      expect(find.text('Word 1 of 20'), findsOneWidget);
    });
  });
}
