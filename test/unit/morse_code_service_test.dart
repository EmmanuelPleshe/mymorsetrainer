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
