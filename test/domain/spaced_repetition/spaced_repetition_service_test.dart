import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/repositories/character_repository.dart';
import 'package:morse_trainer/domain/spaced_repetition/spaced_repetition_service.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

class FakeCharacter extends Fake implements Character {}

void main() {
  late MockCharacterRepository mockRepo;
  late SpacedRepetitionService service;

  setUpAll(() {
    registerFallbackValue(FakeCharacter());
  });

  setUp(() {
    mockRepo = MockCharacterRepository();
    service = SpacedRepetitionService(mockRepo);
    when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => []);
  });

  group('scheduleReview', () {
    test('correct answer with high accuracy increases mastery and schedules far review', () async {
      final char = _char('K', masteryLevel: 0, accuracyPercentage: 0.95, totalAttempts: 10);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.scheduleReview('K', true);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.masteryLevel, 1);
      expect(captured.nextReviewDate, isNotNull);
      // Interval for mastery 1 is 7 days
      final expected = DateTime.now().add(const Duration(days: 7));
      expect(
        captured.nextReviewDate!.difference(expected).inMinutes.abs(),
        lessThan(1),
        reason: 'next review should be ~7 days from now',
      );
    });

    test('correct answer with low accuracy keeps mastery level', () async {
      final char = _char('K', masteryLevel: 2, accuracyPercentage: 0.50, totalAttempts: 10);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.scheduleReview('K', true);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.masteryLevel, 2); // no change, accuracy < 90%
    });

    test('wrong answer decreases mastery and schedules near review', () async {
      final char = _char('K', masteryLevel: 2, accuracyPercentage: 0.80, totalAttempts: 10);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.scheduleReview('K', false);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.masteryLevel, 1);
      // Interval for mastery 1 is 7 days (wrong answer still schedules using new mastery)
      final expected = DateTime.now().add(const Duration(days: 7));
      expect(
        captured.nextReviewDate!.difference(expected).inMinutes.abs(),
        lessThan(1),
      );
    });

    test('mastery level clamps at 0 on wrong answer', () async {
      final char = _char('K', masteryLevel: 0, accuracyPercentage: 0.50, totalAttempts: 5);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.scheduleReview('K', false);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.masteryLevel, 0);
    });

    test('mastery level clamps at max index on correct answer', () async {
      final char = _char('K', masteryLevel: 3, accuracyPercentage: 1.0, totalAttempts: 20);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.scheduleReview('K', true);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.masteryLevel, 3); // max index is 3 (length 4 - 1)
    });

    test('does nothing when character not found', () async {
      when(() => mockRepo.getCharacter('Z')).thenAnswer((_) async => null);

      await service.scheduleReview('Z', true);

      verifyNever(() => mockRepo.updateCharacter(any()));
    });
  });

  group('getDueForReview', () {
    test('returns characters with null nextReviewDate', () async {
      final chars = [
        _char('K', nextReviewDate: null),
        _char('M', nextReviewDate: DateTime.now().add(const Duration(days: 1))),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getDueForReview();
      expect(result.length, 1);
      expect(result.first.symbol, 'K');
    });

    test('returns characters with past nextReviewDate', () async {
      final chars = [
        _char('K', nextReviewDate: DateTime.now().subtract(const Duration(days: 1))),
        _char('M', nextReviewDate: DateTime.now().add(const Duration(days: 1))),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getDueForReview();
      expect(result.length, 1);
      expect(result.first.symbol, 'K');
    });

    test('does not return characters with future nextReviewDate', () async {
      final chars = [
        _char('K', nextReviewDate: DateTime.now().add(const Duration(days: 7))),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getDueForReview();
      expect(result, isEmpty);
    });
  });

  group('getCharactersByPriority', () {
    test('sorts due characters before non-due', () async {
      final chars = [
        _char('K', nextReviewDate: DateTime.now().add(const Duration(days: 1))),
        _char('M', nextReviewDate: null),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getCharactersByPriority();
      expect(result.first.symbol, 'M'); // due (null date) comes first
    });

    test('sorts by lower accuracy when both due', () async {
      final chars = [
        _char('K', accuracyPercentage: 0.90, nextReviewDate: DateTime.now().subtract(const Duration(days: 1))),
        _char('M', accuracyPercentage: 0.50, nextReviewDate: DateTime.now().subtract(const Duration(days: 1))),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getCharactersByPriority();
      expect(result.first.symbol, 'M'); // lower accuracy first
    });

    test('sorts by lower mastery when accuracy is equal', () async {
      final chars = [
        _char('K', masteryLevel: 2, accuracyPercentage: 0.80),
        _char('M', masteryLevel: 1, accuracyPercentage: 0.80),
      ];
      when(() => mockRepo.getUnlockedCharacters()).thenAnswer((_) async => chars);

      final result = await service.getCharactersByPriority();
      // Both are due (null dates), same accuracy, lower mastery first
      expect(result.first.symbol, 'M');
    });
  });
}

Character _char(
  String symbol, {
  int masteryLevel = 0,
  double accuracyPercentage = 0.0,
  int totalAttempts = 0,
  DateTime? nextReviewDate,
  int kochOrder = 0,
}) {
  return Character(
    id: 'char_$symbol',
    symbol: symbol,
    morsePattern: '',
    masteryLevel: masteryLevel,
    accuracyPercentage: accuracyPercentage,
    totalAttempts: totalAttempts,
    kochOrder: kochOrder,
    isUnlocked: true,
    nextReviewDate: nextReviewDate,
  );
}
