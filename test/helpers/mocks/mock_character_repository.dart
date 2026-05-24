import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/repositories/character_repository.dart';
import 'package:morse_trainer/data/models/character.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

/// Builds a list of test characters for a given level range.
/// Level 1 = 2 characters (K, M)
/// Level 2 = 4 characters (K, M, R, S)
List<Character> buildTestCharacters(int level, {bool allUnlocked = false}) {
  final symbols = ['K', 'M', 'R', 'S', 'U', 'A', 'P', 'L', 'W', 'I'];
  final morse = {
    'K': '-.-', 'M': '--', 'R': '.-.', 'S': '...', 'U': '..-',
    'A': '.-', 'P': '.--.', 'L': '.-..', 'W': '.--', 'I': '..',
  };
  final count = (level + 1) * 2;
  return List.generate(
    count.clamp(0, symbols.length),
    (i) => Character(
      id: 'char_${symbols[i]}',
      symbol: symbols[i],
      morsePattern: morse[symbols[i]]!,
      kochOrder: i,
      isUnlocked: allUnlocked || i < 2,
      totalAttempts: 0,
      correctAttempts: 0,
      accuracyPercentage: 0.0,
      masteryLevel: 0,
    ),
  );
}
