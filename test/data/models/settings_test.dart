import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/data/models/settings.dart';

void main() {
  group('InputMethod', () {
    test('has four values in expected order', () {
      expect(InputMethod.values.length, 4);
      expect(InputMethod.values, [
        InputMethod.keyboard,
        InputMethod.touchscreen,
        InputMethod.gameController,
        InputMethod.audioInput,
      ]);
    });

    test('index values are stable', () {
      expect(InputMethod.keyboard.index, 0);
      expect(InputMethod.touchscreen.index, 1);
      expect(InputMethod.gameController.index, 2);
      expect(InputMethod.audioInput.index, 3);
    });
  });

  group('AppSettings', () {
    test('default constructor uses correct defaults', () {
      final s = AppSettings();
      expect(s.id, 'current');
      expect(s.toneFrequency, 600.0);
      expect(s.wpm, 20.0);
      expect(s.effWpm, 20.0);
      expect(s.extraWordSpace, 0.0);
      expect(s.volume, 0.5);
      expect(s.inputMethod, InputMethod.keyboard);
      expect(s.enableGamification, true);
      expect(s.enableSoundEffects, false);
      expect(s.enableScreenFlash, false);
    });

    test('copyWith overrides only provided fields', () {
      final s = AppSettings(wpm: 25.0, volume: 0.8);
      final s2 = s.copyWith(toneFrequency: 600.0);

      expect(s2.id, 'current');
      expect(s2.toneFrequency, 600.0);
      expect(s2.wpm, 25.0);
      expect(s2.effWpm, 20.0);
      expect(s2.volume, 0.8);
    });

    test('toMap serializes all fields', () {
      final s = AppSettings(
        id: 'test',
        toneFrequency: 600.0,
        wpm: 20.0,
        effWpm: 15.0,
        extraWordSpace: 1.0,
        volume: 0.75,
        inputMethod: InputMethod.touchscreen,
        enableGamification: false,
        enableSoundEffects: true,
        enableScreenFlash: true,
      );
      final map = s.toMap();

      expect(map['id'], 'test');
      expect(map['toneFrequency'], 600.0);
      expect(map['wpm'], 20.0);
      expect(map['effWpm'], 15.0);
      expect(map['extraWordSpace'], 1.0);
      expect(map['volume'], 0.75);
      expect(map['inputMethod'], 1);
      expect(map['enableGamification'], 0);
      expect(map['enableSoundEffects'], 1);
      expect(map['enableScreenFlash'], 1);
    });

    test('fromMap deserializes all fields', () {
      final map = {
        'id': 'test',
        'toneFrequency': 600.0,
        'wpm': 20.0,
        'effWpm': 15.0,
        'extraWordSpace': 1.0,
        'volume': 0.75,
        'inputMethod': 1,
        'enableGamification': 1,
        'enableSoundEffects': 0,
        'enableScreenFlash': 0,
      };
      final s = AppSettings.fromMap(map);

      expect(s.id, 'test');
      expect(s.toneFrequency, 600.0);
      expect(s.wpm, 20.0);
      expect(s.effWpm, 15.0);
      expect(s.extraWordSpace, 1.0);
      expect(s.volume, 0.75);
      expect(s.inputMethod, InputMethod.touchscreen);
      expect(s.enableGamification, true);
      expect(s.enableSoundEffects, false);
      expect(s.enableScreenFlash, false);
    });

    test('fromMap uses defaults for missing/null fields', () {
      final s = AppSettings.fromMap({});

      expect(s.id, 'current');
      expect(s.toneFrequency, 600.0);
      expect(s.wpm, 20.0);
      expect(s.effWpm, 20.0);
      expect(s.extraWordSpace, 0.0);
      expect(s.volume, 0.5);
      expect(s.inputMethod, InputMethod.keyboard);
      expect(s.enableGamification, true);
      expect(s.enableSoundEffects, false);
      expect(s.enableScreenFlash, false);
    });

    test('fromMap bool deserialization handles 1 and 0', () {
      final on = AppSettings.fromMap({'enableGamification': 1, 'enableSoundEffects': 1, 'enableScreenFlash': 1});
      expect(on.enableGamification, true);
      expect(on.enableSoundEffects, true);
      expect(on.enableScreenFlash, true);

      final off = AppSettings.fromMap({'enableGamification': 0, 'enableSoundEffects': 0, 'enableScreenFlash': 0});
      expect(off.enableGamification, false);
      expect(off.enableSoundEffects, false);
      expect(off.enableScreenFlash, false);
    });
  });
}
