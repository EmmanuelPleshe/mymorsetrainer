import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/audio/morse_code_mapper.dart';

void main() {
  late MorseCodeMapper mapper;

  setUp(() {
    mapper = MorseCodeMapper();
  });

  group('getMorsePattern', () {
    test('returns correct pattern for known letters', () {
      expect(mapper.getMorsePattern('A'), '.-');
      expect(mapper.getMorsePattern('K'), '-.-');
      expect(mapper.getMorsePattern('M'), '--');
      expect(mapper.getMorsePattern('E'), '.');
      expect(mapper.getMorsePattern('Z'), '--..');
    });

    test('returns correct pattern for known digits', () {
      expect(mapper.getMorsePattern('0'), '-----');
      expect(mapper.getMorsePattern('5'), '.....');
      expect(mapper.getMorsePattern('9'), '----.');
    });

    test('returns correct pattern for known punctuation', () {
      expect(mapper.getMorsePattern('/'), '-..-.');
      expect(mapper.getMorsePattern('.'), '.-.-.-');
      expect(mapper.getMorsePattern(','), '--..--');
      expect(mapper.getMorsePattern('?'), '..--..');
      expect(mapper.getMorsePattern('='), '-...-');
      expect(mapper.getMorsePattern('+'), '.-.-.');
      expect(mapper.getMorsePattern('@'), '.--.-.');
    });

    test('returns null for unknown characters', () {
      expect(mapper.getMorsePattern('#'), isNull);
      expect(mapper.getMorsePattern('!'), isNull);
      expect(mapper.getMorsePattern(';'), isNull);
    });

    test('is case insensitive', () {
      expect(mapper.getMorsePattern('a'), '.-');
      expect(mapper.getMorsePattern('k'), '-.-');
      expect(mapper.getMorsePattern('M'), '--');
      expect(mapper.getMorsePattern('z'), '--..');
    });
  });

  group('getCharactersForLevel', () {
    test('level 0 returns 2 characters (K, M)', () {
      final chars = mapper.getCharactersForLevel(0);
      expect(chars.length, 2);
      expect(chars[0], 'K');
      expect(chars[1], 'M');
    });

    test('level 1 returns 4 characters', () {
      final chars = mapper.getCharactersForLevel(1);
      expect(chars.length, 4);
      expect(chars[0], 'K');
      expect(chars[1], 'M');
      expect(chars[2], 'U');
      expect(chars[3], 'R');
    });

    test('caps at full sequence length', () {
      final chars = mapper.getCharactersForLevel(1000);
      expect(chars.length, MorseCodeMapper.kochSequence.length);
      expect(chars, MorseCodeMapper.kochSequence);
    });
  });

  group('getTotalLevels', () {
    test('returns ceil of half the sequence length', () {
      final expected = (MorseCodeMapper.kochSequence.length / 2).ceil();
      expect(mapper.getTotalLevels(), expected);
    });
  });

  group('getAllCharacters', () {
    test('returns all keys from the Morse map', () {
      final all = mapper.getAllCharacters();
      expect(all.length, MorseCodeMapper.morseCodeMap.length);
      expect(all.contains('A'), true);
      expect(all.contains('Z'), true);
      expect(all.contains('0'), true);
      expect(all.contains('/'), true);
      expect(all.contains('.'), true);
      expect(all.contains('@'), true);
      expect(all.contains('&'), true);
    });
  });

  group('wordToMorse', () {
    test('converts single word', () {
      expect(mapper.wordToMorse('SOS'), '... --- ...');
      expect(mapper.wordToMorse('HELLO'), '.... . .-.. .-.. ---');
    });

    test('converts single letter', () {
      expect(mapper.wordToMorse('A'), '.-');
      expect(mapper.wordToMorse('E'), '.');
    });

    test('handles numbers', () {
      expect(mapper.wordToMorse('5'), '.....');
      expect(mapper.wordToMorse('0'), '-----');
      expect(mapper.wordToMorse('73'), '--... ...--');
    });

    test('is case insensitive', () {
      expect(mapper.wordToMorse('hello'), '.... . .-.. .-.. ---');
      expect(mapper.wordToMorse('Sos'), '... --- ...');
    });

    test('skips unknown characters', () {
      expect(mapper.wordToMorse('A#B'), '.- -...');
      expect(mapper.wordToMorse('A!B'), '.- -...');
    });

    test('returns empty string for empty input', () {
      expect(mapper.wordToMorse(''), '');
    });

    test('returns empty string when no characters are mappable', () {
      expect(mapper.wordToMorse('#!;'), '');
    });

    test('handles punctuation', () {
      expect(mapper.wordToMorse('A.B'), '.- .-.-.- -...');
    });
  });
}