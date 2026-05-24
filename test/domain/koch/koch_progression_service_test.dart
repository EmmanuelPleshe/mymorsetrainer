import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/repositories/character_repository.dart';
import 'package:morse_trainer/domain/koch/koch_progression_service.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

class FakeCharacter extends Fake implements Character {}

void main() {
  late MockCharacterRepository mockRepo;
  late KochProgressionService service;

  setUpAll(() {
    registerFallbackValue(FakeCharacter());
  });

  setUp(() {
    mockRepo = MockCharacterRepository();
    service = KochProgressionService(mockRepo);
  });

  group('canAdvanceLevel', () {
    test('returns true when all characters meet minAttempts and accuracy threshold', () async {
      final chars = [
        _char('K', totalAttempts: 5, correctAttempts: 4, accuracy: 0.80),
        _char('M', totalAttempts: 5, correctAttempts: 4, accuracy: 0.80),
      ];
      when(() => mockRepo.getCharactersForLevel(1)).thenAnswer((_) async => chars);

      final result = await service.canAdvanceLevel(1);
      expect(result, true);
    });

    test('returns false when some characters have fewer than minAttempts', () async {
      final chars = [
        _char('K', totalAttempts: 5, correctAttempts: 5, accuracy: 1.0),
        _char('M', totalAttempts: 3, correctAttempts: 3, accuracy: 1.0),
      ];
      when(() => mockRepo.getCharactersForLevel(1)).thenAnswer((_) async => chars);

      final result = await service.canAdvanceLevel(1);
      expect(result, false);
    });

    test('returns false when average accuracy is below threshold', () async {
      final chars = [
        _char('K', totalAttempts: 5, correctAttempts: 3, accuracy: 0.60),
        _char('M', totalAttempts: 5, correctAttempts: 3, accuracy: 0.60),
      ];
      when(() => mockRepo.getCharactersForLevel(1)).thenAnswer((_) async => chars);

      final result = await service.canAdvanceLevel(1);
      expect(result, false);
    });

    test('returns false when fewer than 2 characters exist', () async {
      when(() => mockRepo.getCharactersForLevel(1)).thenAnswer((_) async => [_char('K')]);

      final result = await service.canAdvanceLevel(1);
      expect(result, false);
    });

    test('edge case: exactly 80% average with enough attempts passes', () async {
      final chars = [
        _char('K', totalAttempts: 5, correctAttempts: 4, accuracy: 0.80),
        _char('M', totalAttempts: 5, correctAttempts: 4, accuracy: 0.80),
      ];
      when(() => mockRepo.getCharactersForLevel(1)).thenAnswer((_) async => chars);

      final result = await service.canAdvanceLevel(1);
      expect(result, true);
    });
  });

  group('recordAttempt', () {
    test('increments totalAttempts and correctAttempts on correct answer', () async {
      final char = _char('K', totalAttempts: 3, correctAttempts: 2, accuracy: 2 / 3);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.recordAttempt('K', true);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.totalAttempts, 4);
      expect(captured.correctAttempts, 3);
      expect(captured.accuracyPercentage, 3 / 4);
    });

    test('increments totalAttempts but not correctAttempts on wrong answer', () async {
      final char = _char('K', totalAttempts: 3, correctAttempts: 2, accuracy: 2 / 3);
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.recordAttempt('K', false);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.totalAttempts, 4);
      expect(captured.correctAttempts, 2);
      expect(captured.accuracyPercentage, 2 / 4);
    });

    test('handles accuracyPercentage from 0 attempts', () async {
      final char = _char('K');
      when(() => mockRepo.getCharacter('K')).thenAnswer((_) async => char);
      when(() => mockRepo.updateCharacter(any())).thenAnswer((_) async {});

      await service.recordAttempt('K', true);

      final captured = verify(() => mockRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(captured.totalAttempts, 1);
      expect(captured.correctAttempts, 1);
      expect(captured.accuracyPercentage, 1.0);
    });

    test('does nothing when character not found', () async {
      when(() => mockRepo.getCharacter('Z')).thenAnswer((_) async => null);

      await service.recordAttempt('Z', true);

      verifyNever(() => mockRepo.updateCharacter(any()));
    });
  });

  group('getPracticeCharacters', () {
    test('returns requested count of characters', () async {
      final chars = [
        _char('K', kochOrder: 0),
        _char('M', kochOrder: 1),
      ];
      when(() => mockRepo.getCharactersForLevel(1, requireUnlocked: false))
          .thenAnswer((_) async => chars);

      final result = await service.getPracticeCharacters(1, count: 5);
      expect(result.length, 5);
    });

    test('returns empty list when no characters available', () async {
      when(() => mockRepo.getCharactersForLevel(1, requireUnlocked: false))
          .thenAnswer((_) async => []);

      final result = await service.getPracticeCharacters(1);
      expect(result, isEmpty);
    });

    test('weighted selection favors lower accuracy characters', () async {
      final chars = [
        _char('K', accuracy: 1.0, kochOrder: 0),
        _char('M', accuracy: 0.0, kochOrder: 1),
      ];
      when(() => mockRepo.getCharactersForLevel(1, requireUnlocked: false))
          .thenAnswer((_) async => chars);

      // Run many times to check weighting
      final counts = <String, int>{};
      for (var i = 0; i < 100; i++) {
        final result = await service.getPracticeCharacters(1, count: 1);
        final symbol = result.first.symbol;
        counts[symbol] = (counts[symbol] ?? 0) + 1;
      }

      // M (0% accuracy) should appear significantly more than K (100% accuracy)
      expect(counts['M']! > counts['K']!, true,
          reason: 'M (low accuracy) should be selected more often than K (high accuracy)');
    });
  });

  group('unlockNextCharacters', () {
    test('unlocks characters up to next level count', () async {
      final allChars = List.generate(10, (i) => _char('C$i', kochOrder: i, isUnlocked: i < 2));
      when(() => mockRepo.getAllCharacters()).thenAnswer((_) async => allChars);
      when(() => mockRepo.unlockCharacter(any())).thenAnswer((_) async {});

      await service.unlockNextCharacters(1); // level 1 -> next level = 2, count = 4

      verify(() => mockRepo.unlockCharacter('C2')).called(1);
      verify(() => mockRepo.unlockCharacter('C3')).called(1);
      verifyNever(() => mockRepo.unlockCharacter('C0'));
      verifyNever(() => mockRepo.unlockCharacter('C1'));
    });

    test('skips already unlocked characters', () async {
      final allChars = [
        _char('K', kochOrder: 0, isUnlocked: true),
        _char('M', kochOrder: 1, isUnlocked: true),
        _char('R', kochOrder: 2, isUnlocked: false),
      ];
      when(() => mockRepo.getAllCharacters()).thenAnswer((_) async => allChars);
      when(() => mockRepo.unlockCharacter(any())).thenAnswer((_) async {});

      await service.unlockNextCharacters(1);

      verify(() => mockRepo.unlockCharacter('R')).called(1);
      verifyNever(() => mockRepo.unlockCharacter('K'));
      verifyNever(() => mockRepo.unlockCharacter('M'));
    });
  });
}

Character _char(
  String symbol, {
  int totalAttempts = 0,
  int correctAttempts = 0,
  double accuracy = 0.0,
  int kochOrder = 0,
  bool isUnlocked = true,
}) {
  return Character(
    id: 'char_$symbol',
    symbol: symbol,
    morsePattern: '',
    totalAttempts: totalAttempts,
    correctAttempts: correctAttempts,
    accuracyPercentage: accuracy,
    kochOrder: kochOrder,
    isUnlocked: isUnlocked,
  );
}
