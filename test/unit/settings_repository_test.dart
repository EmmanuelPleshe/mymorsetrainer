import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';
import 'package:morse_trainer/data/models/settings.dart';

void main() {
  // Initialize sqflite FFI for desktop tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.setTestDbPath(':memory:');
    DatabaseHelper.resetInstance();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetInstance();
  });

  group('SettingsRepository round-trip', () {
    test('persists and restores WPM', () async {
      final repo = SettingsRepository();
      await repo.updateWpm(25.0);
      final settings = await repo.getSettings();
      expect(settings.wpm, 25.0);
    });

    test('persists and restores effective WPM', () async {
      final repo = SettingsRepository();
      final current = await repo.getSettings();
      await repo.updateSettings(current.copyWith(effWpm: 18.0));
      final settings = await repo.getSettings();
      expect(settings.effWpm, 18.0);
    });

    test('defaults WPM to 20.0 on fresh DB', () async {
      final repo = SettingsRepository();
      final settings = await repo.getSettings();
      expect(settings.wpm, 20.0);
    });

    test('defaults effective WPM to 20.0 on fresh DB', () async {
      final repo = SettingsRepository();
      final settings = await repo.getSettings();
      expect(settings.effWpm, 20.0);
    });

    test('persists and restores tone frequency', () async {
      final repo = SettingsRepository();
      await repo.updateToneFrequency(700.0);
      final settings = await repo.getSettings();
      expect(settings.toneFrequency, 700.0);
    });

    test('persists and restores volume', () async {
      final repo = SettingsRepository();
      await repo.updateVolume(0.3);
      final settings = await repo.getSettings();
      expect(settings.volume, 0.3);
    });

    test('defaults tone frequency to 600.0 on fresh DB', () async {
      final repo = SettingsRepository();
      final settings = await repo.getSettings();
      expect(settings.toneFrequency, 600.0);
    });

    test('defaults volume to 0.5 on fresh DB', () async {
      final repo = SettingsRepository();
      final settings = await repo.getSettings();
      expect(settings.volume, 0.5);
    });
  });
}
