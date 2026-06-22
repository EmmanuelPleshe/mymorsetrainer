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

    test('returns correct pattern for prosigns', () {
      expect(mapper.getMorsePattern('AR'), '.-.-.');
      expect(mapper.getMorsePattern('BT'), '-...-');
      expect(mapper.getMorsePattern('SK'), '...-.-');
      expect(mapper.getMorsePattern('KN'), '-.--.');
      expect(mapper.getMorsePattern('AS'), '.-...');
      expect(mapper.getMorsePattern('SOS'), '...---...');
      expect(mapper.getMorsePattern('CL'), '-.-..-..');
      expect(mapper.getMorsePattern('CT'), '-.-.-');
      expect(mapper.getMorsePattern('VE'), '...-.');
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

  group('isProsign', () {
    test('returns true for all known prosigns', () {
      expect(mapper.isProsign('AR'), isTrue);
      expect(mapper.isProsign('BT'), isTrue);
      expect(mapper.isProsign('SK'), isTrue);
      expect(mapper.isProsign('KN'), isTrue);
      expect(mapper.isProsign('AS'), isTrue);
      expect(mapper.isProsign('SOS'), isTrue);
      expect(mapper.isProsign('CL'), isTrue);
      expect(mapper.isProsign('CT'), isTrue);
      expect(mapper.isProsign('VE'), isTrue);
    });

    test('returns false for non-prosign entries', () {
      expect(mapper.isProsign('A'), isFalse);
      expect(mapper.isProsign('K'), isFalse);
      expect(mapper.isProsign('0'), isFalse);
      expect(mapper.isProsign('.'), isFalse);
      expect(mapper.isProsign('/'), isFalse);
      expect(mapper.isProsign('Z'), isFalse);
    });

    test('is case insensitive', () {
      expect(mapper.isProsign('ar'), isTrue);
      expect(mapper.isProsign('Sos'), isTrue);
      expect(mapper.isProsign('bT'), isTrue);
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

    test('kochSequence ends with prosigns in correct order', () {
      const expectedProsigns = [
        'AR', 'BT', 'SK', 'KN', 'AS', 'SOS', 'CL', 'CT', 'VE',
      ];
      final tail = MorseCodeMapper.kochSequence.sublist(
        MorseCodeMapper.kochSequence.length - expectedProsigns.length,
      );
      expect(tail, expectedProsigns);
    });

    test('kochSequence length is 59 (50 base + 9 prosigns)', () {
      expect(MorseCodeMapper.kochSequence.length, 59);
    });
  });

  group('getTotalLevels', () {
    test('returns ceil of half the sequence length', () {
      final expected = (MorseCodeMapper.kochSequence.length / 2).ceil();
      expect(mapper.getTotalLevels(), expected);
    });

    test('returns 30 for the extended 59-character sequence', () {
      expect(mapper.getTotalLevels(), 30);
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
      expect(mapper.wordToMorse('ar'), '.-.-.');
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

    test('treats SOS as a prosign (no inter-character spaces)', () {
      // SOS is a prosign -> single continuous pattern, not three letters.
      expect(mapper.wordToMorse('SOS'), '...---...');
    });

    test('treats AR as a prosign (not two letters)', () {
      // AR is a prosign -> '.-.-.', not '.- .-.'
      expect(mapper.wordToMorse('AR'), '.-.-.');
    });

    test('treats CL as a 3-char prosign', () {
      expect(mapper.wordToMorse('CL'), '-.-..-..');
    });

    test('handles mixed words with prosigns', () {
      // HI gets inter-character space between H and I; AR is a prosign.
      expect(mapper.wordToMorse('HI AR'), '.... .. .-.-.');
    });

    test('does not misinterpret regular sequences as prosigns', () {
      // 'SO' should not be matched as a prosign prefix; only the full 3-char
      // 'SOS' is a prosign. 'SO' -> two letters.
      expect(mapper.wordToMorse('SO'), '... ---');
      // 'AR' at the end of a word should still be matched.
      expect(mapper.wordToMorse('BAR'), '-... .-.-.');
    });
  });
}