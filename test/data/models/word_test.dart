import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/word.dart';

void main() {
  group('Word', () {
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

    test('Word default difficulty is 1', () {
      const word = Word(
        text: 'TEST',
        morseCode: '- . ... -',
        category: 'basic',
      );
      expect(word.difficulty, 1);
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