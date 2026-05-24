import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/domain/koch/qso_service.dart';

void main() {
  late QSOService service;

  setUp(() {
    service = QSOService();
  });

  group('getPhrases', () {
    test('returns all phrases by default', () {
      final phrases = service.getPhrases();
      expect(phrases.length, 15);
    });

    test('filters by category', () {
      final closing = service.getPhrases(category: 'closing');
      expect(closing.length, 2);
      expect(closing.every((p) => p.category == 'closing'), true);
    });

    test('returns empty list for unknown category', () {
      final result = service.getPhrases(category: 'nonexistent');
      expect(result, isEmpty);
    });

    test('limits result count', () {
      final phrases = service.getPhrases(limit: 3);
      expect(phrases.length, 3);
    });

    test('limit does not truncate when list is smaller', () {
      final closing = service.getPhrases(category: 'closing', limit: 10);
      expect(closing.length, 2);
    });
  });

  group('categories', () {
    test('returns unique categories', () {
      final categories = service.categories;
      expect(categories.length, categories.toSet().length);
      expect(categories.contains('calling'), true);
      expect(categories.contains('reply'), true);
      expect(categories.contains('exchange'), true);
      expect(categories.contains('info'), true);
      expect(categories.contains('operational'), true);
      expect(categories.contains('closing'), true);
      expect(categories.contains('request'), true);
    });
  });

  group('getRandomPhrase', () {
    test('returns a phrase from the full list', () {
      final phrase = service.getRandomPhrase();
      expect(phrase.text, isNotEmpty);
      expect(phrase.meaning, isNotEmpty);
      expect(phrase.category, isNotEmpty);
    });

    test('returns a phrase from filtered category', () {
      final phrase = service.getRandomPhrase(category: 'closing');
      expect(phrase.category, 'closing');
    });
  });

  group('phraseToMorse', () {
    test('converts single letter', () {
      expect(service.phraseToMorse('A'), '.-');
    });

    test('converts word with spaces', () {
      final morse = service.phraseToMorse('HI');
      // H = ...., I = .., with intra-char space
      expect(morse, '.... ..');
    });

    test('converts uppercase regardless of input case', () {
      expect(service.phraseToMorse('a'), '.-');
      expect(service.phraseToMorse('A'), '.-');
    });

    test('ignores unknown characters', () {
      expect(service.phraseToMorse('!@#'), '');
    });

    test('preserves spaces between words as spaces in morse', () {
      final morse = service.phraseToMorse('A B');
      // A = .-, space = ' ', B = -...
      expect(morse, '.-  -...');
    });
  });
}
