import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/audio/morse_code_service.dart';
import 'package:morse_trainer/core/timing/wpm_calculator.dart';

void main() {
  group('MorseCodeService', () {
    late MorseCodeService service;

    setUp(() {
      service = MorseCodeService();
    });

    test('getMorsePattern returns correct pattern for A', () {
      expect(service.getMorsePattern('A'), '.-');
    });

    test('getMorsePattern returns correct pattern for K', () {
      expect(service.getMorsePattern('K'), '-.-');
    });

    test('getMorsePattern returns correct pattern for M', () {
      expect(service.getMorsePattern('M'), '--');
    });

    test('getMorsePattern returns null for unknown character', () {
      expect(service.getMorsePattern('@'), isNull);
    });

    test('getCharactersForLevel returns 2 characters for level 0', () {
      final characters = service.getCharactersForLevel(0);
      expect(characters.length, 2);
      expect(characters[0], 'K');
      expect(characters[1], 'M');
    });

    test('getCharactersForLevel returns 4 characters for level 1', () {
      final characters = service.getCharactersForLevel(1);
      expect(characters.length, 4);
    });

    test('getCharactersForLevel caps at max sequence length', () {
      final characters = service.getCharactersForLevel(100);
      expect(characters.length, MorseCodeService.kochSequence.length);
    });

    test('getTotalLevels returns ceil of half sequence length', () {
      expect(service.getTotalLevels(), (MorseCodeService.kochSequence.length / 2).ceil());
    });

    test('getAllCharacters returns all keys', () {
      final all = service.getAllCharacters();
      expect(all.length, 39);
      expect(all.contains('A'), true);
      expect(all.contains('Z'), true);
      expect(all.contains('0'), true);
      expect(all.contains('/'), true);
    });

    test('getMorsePattern is case insensitive', () {
      expect(service.getMorsePattern('a'), '.-');
      expect(service.getMorsePattern('k'), '-.-');
      expect(service.getMorsePattern('M'), '--');
    });
  });

  group('WpmCalculator', () {
    test('dotDurationMs calculates correctly for 20 WPM', () {
      expect(WpmCalculator.dotDurationMs(20), 60);
    });

    test('dotDurationMs calculates correctly for 10 WPM', () {
      expect(WpmCalculator.dotDurationMs(10), 120);
    });
  });
}
