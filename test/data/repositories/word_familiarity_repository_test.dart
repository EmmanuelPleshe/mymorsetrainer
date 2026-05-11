import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/models/word.dart';
import 'package:morse_trainer/data/repositories/word_familiarity_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() {
    databaseFactory = null;
  });

  setUp(() async {
    DatabaseHelper.setTestDbPath(':memory:');
    DatabaseHelper.resetInstance();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetInstance();
  });

  group('WordFamiliarityRepository', () {
    test('getFamiliarity returns default for unknown word', () async {
      final repo = WordFamiliarityRepository();
      final result = await repo.getFamiliarity('UNKNOWN');

      expect(result.wordText, 'UNKNOWN');
      expect(result.familiarityScore, 0.0);
      expect(result.totalAttempts, 0);
    });

    test('recordCorrect increases score by 10', () async {
      final repo = WordFamiliarityRepository();
      await repo.recordCorrect('CQ');

      final result = await repo.getFamiliarity('CQ');
      expect(result.familiarityScore, 10.0);
      expect(result.totalAttempts, 1);
      expect(result.correctCount, 1);
      expect(result.lastReviewed, isNotNull);
    });

    test('recordCorrect caps at 100', () async {
      final repo = WordFamiliarityRepository();
      for (var i = 0; i < 15; i++) {
        await repo.recordCorrect('CQ');
      }

      final result = await repo.getFamiliarity('CQ');
      expect(result.familiarityScore, 100.0);
      expect(result.totalAttempts, 15);
    });

    test('recordIncorrect decreases score by 20', () async {
      final repo = WordFamiliarityRepository();
      await repo.recordCorrect('CQ'); // 10
      await repo.recordCorrect('CQ'); // 20
      await repo.recordIncorrect('CQ'); // 0

      final result = await repo.getFamiliarity('CQ');
      expect(result.familiarityScore, 0.0);
      expect(result.totalAttempts, 3);
      expect(result.correctCount, 2);
    });

    test('recordIncorrect floors at 0', () async {
      final repo = WordFamiliarityRepository();
      await repo.recordIncorrect('CQ');
      await repo.recordIncorrect('CQ');

      final result = await repo.getFamiliarity('CQ');
      expect(result.familiarityScore, 0.0);
      expect(result.totalAttempts, 2);
    });

    test('getScaffoldingLevel returns high for score < 20', () {
      final repo = WordFamiliarityRepository();
      expect(repo.getScaffoldingLevel(0.0), ScaffoldingLevel.high);
      expect(repo.getScaffoldingLevel(19.9), ScaffoldingLevel.high);
    });

    test('getScaffoldingLevel returns medium for score 20-60', () {
      final repo = WordFamiliarityRepository();
      expect(repo.getScaffoldingLevel(20.0), ScaffoldingLevel.medium);
      expect(repo.getScaffoldingLevel(59.9), ScaffoldingLevel.medium);
    });

    test('getScaffoldingLevel returns none for score >= 60', () {
      final repo = WordFamiliarityRepository();
      expect(repo.getScaffoldingLevel(60.0), ScaffoldingLevel.none);
      expect(repo.getScaffoldingLevel(100.0), ScaffoldingLevel.none);
    });

    test('getWeightedWords prioritizes low familiarity', () async {
      final repo = WordFamiliarityRepository();
      final words = [
        const Word(text: 'A', morseCode: '.-', category: 'test'),
        const Word(text: 'B', morseCode: '-...', category: 'test'),
        const Word(text: 'C', morseCode: '-.-.', category: 'test'),
      ];

      // Make B high familiarity, A medium, C low
      for (var i = 0; i < 10; i++) await repo.recordCorrect('B');
      for (var i = 0; i < 5; i++) await repo.recordCorrect('A');

      final selected = await repo.getWeightedWords(words, 2);
      expect(selected.length, 2);

      // C should be first (0 familiarity), then A (50), then B (100)
      // With shuffle, we verify C is always included since it has highest weight
      final texts = selected.map((w) => w.text).toList();
      expect(texts, contains('C'));
    });
  });
}
