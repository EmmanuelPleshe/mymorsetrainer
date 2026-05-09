import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/settings.dart';

void main() {
  group('AppSettings constructor defaults', () {
    test('default WPM is 20.0', () {
      final settings = AppSettings();
      expect(settings.wpm, 20.0);
    });

    test('default effective WPM is 20.0', () {
      final settings = AppSettings();
      expect(settings.effWpm, 20.0);
    });

    test('default tone frequency is 600.0', () {
      final settings = AppSettings();
      expect(settings.toneFrequency, 600.0);
    });

    test('default volume is 0.5', () {
      final settings = AppSettings();
      expect(settings.volume, 0.5);
    });
  });

  group('AppSettings.fromMap defaults', () {
    test('empty map returns WPM 20.0', () {
      final settings = AppSettings.fromMap({});
      expect(settings.wpm, 20.0);
    });

    test('empty map returns effective WPM 20.0', () {
      final settings = AppSettings.fromMap({});
      expect(settings.effWpm, 20.0);
    });

    test('empty map returns tone frequency 600.0', () {
      final settings = AppSettings.fromMap({});
      expect(settings.toneFrequency, 600.0);
    });

    test('empty map returns volume 0.5', () {
      final settings = AppSettings.fromMap({});
      expect(settings.volume, 0.5);
    });
  });
}
