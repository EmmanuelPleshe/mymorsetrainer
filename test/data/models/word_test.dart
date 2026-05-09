import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/word.dart';

void main() {
  group('Word', () {
    test('textToMorse converts single letter', () {
      expect(Word.textToMorse('A'), '.-');
      expect(Word.textToMorse('B'), '-...');
      expect(Word.textToMorse('E'), '.');
    });

    test('textToMorse converts uppercase regardless of input case', () {
      expect(Word.textToMorse('a'), '.-');
      expect(Word.textToMorse('k'), '-.-');
    });

    test('textToMorse converts word with intra-character spaces', () {
      expect(Word.textToMorse('SOS'), '... --- ...');
      expect(Word.textToMorse('HELLO'), '.... . .-.. .-.. ---');
    });

    test('textToMorse handles numbers', () {
      expect(Word.textToMorse('5'), '.....');
      expect(Word.textToMorse('0'), '-----');
      expect(Word.textToMorse('73'), '--... ...--');
    });

    test('textToMorse preserves word spaces', () {
      // Space char produces one space, plus intra-char space before next letter
      expect(Word.textToMorse('DE K'), '-.. .  -.-');
    });

    test('textToMorse skips unknown characters', () {
      expect(Word.textToMorse('A@B'), '.- -...');
    });

    test('textToMorse returns empty string for empty input', () {
      expect(Word.textToMorse(''), '');
    });

    test('Word constructor stores fields', () {
      const word = Word(
        text: 'HELLO',
        morseCode: '.... . .-.. .-.. ---',
        category: 'basic',
        difficulty: 2,
      );
      expect(word.text, 'HELLO');
      expect(word.morseCode, '.... . .-.. .-.. ---');
      expect(word.category, 'basic');
      expect(word.difficulty, 2);
    });

    test('QSOPhrase constructor stores fields', () {
      const phrase = QSOPhrase(
        text: 'CQ CQ DE',
        meaning: 'Calling anyone',
        category: 'calling',
      );
      expect(phrase.text, 'CQ CQ DE');
      expect(phrase.meaning, 'Calling anyone');
      expect(phrase.category, 'calling');
    });
  });
}
