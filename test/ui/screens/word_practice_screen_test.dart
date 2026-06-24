import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/audio_service.dart';
import 'package:morse_trainer/data/models/word.dart';
import 'package:morse_trainer/data/repositories/word_familiarity_repository.dart';
import 'package:morse_trainer/ui/screens/word_practice_screen.dart';

import '../../helpers/mocks/mock_audio_service.dart';
import '../../helpers/mocks/mock_morse_code_coordinator.dart';
import '../../helpers/mocks/mock_word_familiarity_repository.dart';

void main() {
  group('WordPracticeScreen', () {
    late MockAudioService mockAudioService;
    late MockMorseCodeCoordinator mockCoordinator;
    late MockWordFamiliarityRepository mockRepo;

    setUp(() {
      mockAudioService = MockAudioService();
      mockCoordinator = MockMorseCodeCoordinator();
      mockRepo = MockWordFamiliarityRepository();
      when(() => mockAudioService.initialize()).thenAnswer((_) async {});
      when(() => mockAudioService.keyerDown()).thenAnswer((_) async {});
      when(() => mockAudioService.keyerUp()).thenAnswer((_) async {});
      when(() => mockAudioService.playCorrectFeedback()).thenAnswer((_) async {});
      when(() => mockCoordinator.playCharacters(any(), onFlash: any(named: 'onFlash')))
          .thenAnswer((_) async {});
      when(() => mockRepo.getWeightedWords(any(), any())).thenAnswer((invocation) async {
        final words = invocation.positionalArguments[0] as List<Word>;
        final limit = invocation.positionalArguments[1] as int;
        return words.take(limit).toList();
      });
      when(() => mockRepo.getScaffoldingLevelForWord(any())).thenAnswer((_) async => ScaffoldingLevel.none);
      when(() => mockRepo.recordCorrect(any())).thenAnswer((_) async {});
      when(() => mockRepo.recordIncorrect(any())).thenAnswer((_) async {});
    });

    testWidgets('renders app bar with Word Practice title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
      );

      expect(find.text('Word Practice'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading then keying phase', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
      );

      // Initially shows loading while words load
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After async init completes, shows keying phase
      await tester.pump();
      expect(find.text('Key the word!'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows keying phase after audio finishes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
      );
      await tester.pump();

      expect(find.text('Key the word!'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows raw pattern while keying', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
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
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
      );
      await tester.pump();

      // Key some pattern and submit
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Word audio should replay on feedback (initial play + replay)
      verify(() => mockCoordinator.playCharacters(any(), onFlash: any(named: 'onFlash'))).called(greaterThan(1));
    });

    testWidgets('refresh button shuffles words', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: WordPracticeScreen(
          audioService: mockAudioService,
          coordinator: mockCoordinator,
          familiarityRepository: mockRepo,
        )),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should still show Word 1 after refresh
      expect(find.text('Word 1 of 20'), findsOneWidget);
    });
  });
}
