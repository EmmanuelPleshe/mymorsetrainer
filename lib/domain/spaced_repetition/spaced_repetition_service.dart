import '../../data/models/character.dart';
import '../../data/repositories/character_repository.dart';

class SpacedRepetitionService {
  final CharacterRepository _characterRepository;

  // Review intervals in days based on mastery level
  static const List<int> _intervals = [2, 7, 30, 90];

  SpacedRepetitionService(this._characterRepository);

  Future<void> scheduleReview(String symbol, bool wasCorrect) async {
    final character = await _characterRepository.getCharacter(symbol);
    if (character == null) return;

    int newMasteryLevel = character.masteryLevel;
    DateTime? nextReview;

    if (wasCorrect) {
      // Increase mastery level if accuracy is high enough
      if (character.accuracyPercentage >= 0.90) {
        newMasteryLevel = (newMasteryLevel + 1).clamp(0, _intervals.length - 1);
      }
      nextReview = DateTime.now().add(Duration(days: _intervals[newMasteryLevel]));
    } else {
      // Reset mastery slightly on incorrect answer
      newMasteryLevel = (newMasteryLevel - 1).clamp(0, _intervals.length - 1);
      nextReview = DateTime.now().add(Duration(days: _intervals[newMasteryLevel]));
    }

    final updated = character.copyWith(
      masteryLevel: newMasteryLevel,
      nextReviewDate: nextReview,
    );

    await _characterRepository.updateCharacter(updated);
  }

  Future<List<Character>> getDueForReview() async {
    final allCharacters = await _characterRepository.getUnlockedCharacters();
    final now = DateTime.now();

    return allCharacters.where((c) {
      if (c.nextReviewDate == null) return true;
      return c.nextReviewDate!.isBefore(now);
    }).toList();
  }

  Future<List<Character>> getCharactersByPriority() async {
    final unlocked = await _characterRepository.getUnlockedCharacters();
    final now = DateTime.now();

    // Sort by: due for review first, then by lower accuracy, then by mastery level
    unlocked.sort((a, b) {
      final aDue = a.nextReviewDate == null || a.nextReviewDate!.isBefore(now);
      final bDue = b.nextReviewDate == null || b.nextReviewDate!.isBefore(now);

      if (aDue && !bDue) return -1;
      if (!aDue && bDue) return 1;

      final accuracyCompare = a.accuracyPercentage.compareTo(b.accuracyPercentage);
      if (accuracyCompare != 0) return accuracyCompare;

      return a.masteryLevel.compareTo(b.masteryLevel);
    });

    return unlocked;
  }
}
