import '../database/database_helper.dart';
import '../models/word.dart';
import '../models/word_familiarity.dart';

enum ScaffoldingLevel { high, medium, none }

class WordFamiliarityRepository {
  final DatabaseHelper _dbHelper;

  WordFamiliarityRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<WordFamiliarity> getFamiliarity(String wordText) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'word_familiarity',
      where: 'wordText = ?',
      whereArgs: [wordText],
    );
    if (maps.isEmpty) {
      return WordFamiliarity(wordText: wordText);
    }
    return WordFamiliarity.fromMap(maps.first);
  }

  Future<void> _ensureFamiliarityRow(String wordText) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'word_familiarity',
      where: 'wordText = ?',
      whereArgs: [wordText],
    );
    if (existing.isEmpty) {
      await db.insert('word_familiarity', WordFamiliarity(wordText: wordText).toMap());
    }
  }

  Future<void> recordCorrect(String wordText) async {
    await _ensureFamiliarityRow(wordText);
    final db = await _dbHelper.database;
    final current = await getFamiliarity(wordText);
    final updated = current.copyWith(
      familiarityScore: (current.familiarityScore + 10.0).clamp(0.0, 100.0),
      totalAttempts: current.totalAttempts + 1,
      correctCount: current.correctCount + 1,
      lastReviewed: DateTime.now(),
    );
    await db.update(
      'word_familiarity',
      updated.toMap(),
      where: 'wordText = ?',
      whereArgs: [wordText],
    );
  }

  Future<void> recordIncorrect(String wordText) async {
    await _ensureFamiliarityRow(wordText);
    final db = await _dbHelper.database;
    final current = await getFamiliarity(wordText);
    final updated = current.copyWith(
      familiarityScore: (current.familiarityScore - 20.0).clamp(0.0, 100.0),
      totalAttempts: current.totalAttempts + 1,
      lastReviewed: DateTime.now(),
    );
    await db.update(
      'word_familiarity',
      updated.toMap(),
      where: 'wordText = ?',
      whereArgs: [wordText],
    );
  }

  ScaffoldingLevel getScaffoldingLevel(double familiarityScore) {
    if (familiarityScore < 20.0) return ScaffoldingLevel.high;
    if (familiarityScore < 60.0) return ScaffoldingLevel.medium;
    return ScaffoldingLevel.none;
  }

  Future<ScaffoldingLevel> getScaffoldingLevelForWord(String wordText) async {
    final familiarity = await getFamiliarity(wordText);
    return getScaffoldingLevel(familiarity.familiarityScore);
  }

  /// Return a weighted selection of words prioritizing low familiarity.
  Future<List<Word>> getWeightedWords(List<Word> words, int count) async {
    final scored = <(Word, double)>[];
    for (final word in words) {
      final familiarity = await getFamiliarity(word.text);
      // Weight: lower familiarity = higher priority
      final weight = 100.0 - familiarity.familiarityScore;
      scored.add((word, weight));
    }

    // Sort by weight descending (low familiarity first)
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    // Take requested count
    final selected = scored.take(count).map((s) => s.$1).toList();

    // Shuffle so same-low-familiarity words don't always appear in same order
    selected.shuffle();

    return selected;
  }
}
