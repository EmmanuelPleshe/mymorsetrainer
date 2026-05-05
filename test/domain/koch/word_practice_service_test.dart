import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/domain/koch/word_practice_service.dart';

void main() {
  late WordPracticeService service;

  setUp(() {
    service = WordPracticeService();
  });

  group('getWords', () {
    test('returns all words by default', () {
      final words = service.getWords();
      expect(words.length, 20);
    });

    test('filters by maxDifficulty', () {
      final easy = service.getWords(maxDifficulty: 1);
      expect(easy.every((w) => w.difficulty <= 1), true);
      expect(easy.length, greaterThan(0));
    });

    test('returns empty when maxDifficulty below all words', () {
      final result = service.getWords(maxDifficulty: 0);
      expect(result, isEmpty);
    });

    test('limits result count', () {
      final words = service.getWords(limit: 5);
      expect(words.length, 5);
    });

    test('limit does not truncate when list is smaller', () {
      final hard = service.getWords(maxDifficulty: 3, limit: 50);
      expect(hard.length, lessThanOrEqualTo(20));
    });

    test('combines maxDifficulty and limit', () {
      final words = service.getWords(maxDifficulty: 1, limit: 3);
      expect(words.length, 3);
      expect(words.every((w) => w.difficulty <= 1), true);
    });
  });

  group('getWordsByCategory', () {
    test('returns words matching category', () {
      final qso = service.getWordsByCategory('qso');
      expect(qso.length, greaterThan(0));
      expect(qso.every((w) => w.category == 'qso'), true);
    });

    test('returns empty for unknown category', () {
      final result = service.getWordsByCategory('nonexistent');
      expect(result, isEmpty);
    });
  });

  group('categories', () {
    test('returns unique categories', () {
      final categories = service.categories;
      expect(categories.length, categories.toSet().length);
      expect(categories.contains('qso'), true);
      expect(categories.contains('callsign'), true);
    });
  });

  group('getRandomWord', () {
    test('returns a word from the full list', () {
      final word = service.getRandomWord();
      expect(word.text, isNotEmpty);
      expect(word.morseCode, isNotEmpty);
      expect(word.category, isNotEmpty);
    });

    test('returns a word within maxDifficulty', () {
      final word = service.getRandomWord(maxDifficulty: 1);
      expect(word.difficulty, lessThanOrEqualTo(1));
    });

    test('throws when no words match maxDifficulty', () {
      expect(() => service.getRandomWord(maxDifficulty: 0), throwsA(isA<StateError>()));
    });
  });
}
