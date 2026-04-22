import '../../data/models/character.dart';
import '../../data/repositories/character_repository.dart';

class KochProgressionService {
  final CharacterRepository _characterRepository;
  static const double accuracyThreshold = 0.90;
  static const int minAttempts = 10;

  KochProgressionService(this._characterRepository);

  Future<bool> canAdvanceLevel(int currentLevel) async {
    final characters = await _characterRepository.getCharactersForLevel(currentLevel);
    if (characters.length < 2) return false;

    final practicedCharacters = characters.where((c) => c.totalAttempts >= minAttempts);
    if (practicedCharacters.length < characters.length) return false;

    final averageAccuracy = practicedCharacters.fold<double>(
          0.0,
          (sum, c) => sum + c.accuracyPercentage,
        ) /
        practicedCharacters.length;

    return averageAccuracy >= accuracyThreshold;
  }

  Future<int> getCurrentLevel() async {
    final allCharacters = await _characterRepository.getAllCharacters();
    int level = 1;

    while (await canAdvanceLevel(level)) {
      level++;
      final nextCharacters = await _characterRepository.getCharactersForLevel(level);
      if (nextCharacters.isEmpty || nextCharacters.length >= allCharacters.length) break;
    }

    return level;
  }

  Future<void> unlockNextCharacters(int currentLevel) async {
    final nextLevel = currentLevel + 1;
    final count = nextLevel * 2;
    final allCharacters = await _characterRepository.getAllCharacters();

    for (int i = 0; i < count && i < allCharacters.length; i++) {
      if (!allCharacters[i].isUnlocked) {
        await _characterRepository.unlockCharacter(allCharacters[i].symbol);
      }
    }
  }

  Future<void> recordAttempt(String symbol, bool isCorrect) async {
    final character = await _characterRepository.getCharacter(symbol);
    if (character == null) return;

    final updated = character.copyWith(
      totalAttempts: character.totalAttempts + 1,
      correctAttempts: character.correctAttempts + (isCorrect ? 1 : 0),
      accuracyPercentage: (character.correctAttempts + (isCorrect ? 1 : 0)) /
          (character.totalAttempts + 1),
      lastPracticed: DateTime.now(),
    );

    await _characterRepository.updateCharacter(updated);
  }

  Future<List<Character>> getPracticeCharacters(int level, {int count = 10}) async {
    final characters = await _characterRepository.getCharactersForLevel(level);
    if (characters.isEmpty) return [];

    // Weight characters by lower accuracy
    final weighted = characters.map((c) {
      final weight = (1.0 - c.accuracyPercentage) * 100 + 10;
      return MapEntry(c, weight);
    }).toList();

    // Simple weighted random selection
    final result = <Character>[];
    for (int i = 0; i < count; i++) {
      final totalWeight = weighted.fold<double>(0, (sum, e) => sum + e.value);
      final random = DateTime.now().millisecondsSinceEpoch % totalWeight;
      double current = 0;
      for (final entry in weighted) {
        current += entry.value;
        if (random <= current) {
          result.add(entry.key);
          break;
        }
      }
    }

    return result;
  }
}
