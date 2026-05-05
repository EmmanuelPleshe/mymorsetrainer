import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockDatabase extends Mock implements Database {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;
  late SettingsRepository repo;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    repo = SettingsRepository(dbHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);
    when(() => mockDb.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
        .thenAnswer((_) async => 1);
    when(() => mockDb.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
        .thenAnswer((_) async => 1);
  });

  group('getSettings', () {
    test('returns default settings when no record exists', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => []);

      final result = await repo.getSettings();

      expect(result.id, 'current');
      expect(result.toneFrequency, 800.0);
      expect(result.wpm, 15.0);
      expect(result.effWpm, 10.0);
      expect(result.volume, 0.5);
      expect(result.inputMethod, InputMethod.keyboard);
      expect(result.enableGamification, true);
      expect(result.enableSoundEffects, false);
      expect(result.enableScreenFlash, false);
      verify(() => mockDb.insert('settings', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .called(1);
    });

    test('returns existing settings from database', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'toneFrequency': 600.0,
                  'wpm': 20.0,
                  'effWpm': 10.0,
                  'extraWordSpace': 0.5,
                  'volume': 0.8,
                  'inputMethod': 1,
                  'enableGamification': 0,
                  'enableSoundEffects': 1,
                  'enableScreenFlash': 1,
                }
              ]);

      final result = await repo.getSettings();

      expect(result.toneFrequency, 600.0);
      expect(result.wpm, 20.0);
      expect(result.volume, 0.8);
      expect(result.inputMethod, InputMethod.touchscreen);
      expect(result.enableGamification, false);
      expect(result.enableSoundEffects, true);
      expect(result.enableScreenFlash, true);
      verifyNever(() => mockDb.insert('settings', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')));
    });
  });

  group('updateSettings', () {
    test('calls update with correct where clause', () async {
      final settings = AppSettings(
        id: 'current',
        toneFrequency: 700.0,
        wpm: 25.0,
      );

      await repo.updateSettings(settings);

      final captured = verify(() => mockDb.update(
            'settings',
            captureAny(),
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
          )).captured;

      expect(captured[1], 'id = ?');
      expect(captured[2], ['current']);
    });
  });

  group('convenience updaters', () {
    test('updateToneFrequency updates frequency', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'toneFrequency': 600.0,
                  'wpm': 20.0,
                  'effWpm': 10.0,
                  'extraWordSpace': 0.0,
                  'volume': 0.5,
                  'inputMethod': 0,
                  'enableGamification': 1,
                  'enableSoundEffects': 0,
                  'enableScreenFlash': 0,
                }
              ]);

      await repo.updateToneFrequency(900.0);

      final captured = verify(() => mockDb.update('settings', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['toneFrequency'], 900.0);
    });

    test('updateWpm updates wpm', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'toneFrequency': 600.0,
                  'wpm': 20.0,
                  'effWpm': 10.0,
                  'extraWordSpace': 0.0,
                  'volume': 0.5,
                  'inputMethod': 0,
                  'enableGamification': 1,
                  'enableSoundEffects': 0,
                  'enableScreenFlash': 0,
                }
              ]);

      await repo.updateWpm(30.0);

      final captured = verify(() => mockDb.update('settings', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['wpm'], 30.0);
    });

    test('updateVolume updates volume', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'toneFrequency': 600.0,
                  'wpm': 20.0,
                  'effWpm': 10.0,
                  'extraWordSpace': 0.0,
                  'volume': 0.5,
                  'inputMethod': 0,
                  'enableGamification': 1,
                  'enableSoundEffects': 0,
                  'enableScreenFlash': 0,
                }
              ]);

      await repo.updateVolume(0.9);

      final captured = verify(() => mockDb.update('settings', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['volume'], 0.9);
    });

    test('updateInputMethod updates inputMethod', () async {
      when(() => mockDb.query('settings', where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => [
                {
                  'id': 'current',
                  'toneFrequency': 600.0,
                  'wpm': 20.0,
                  'effWpm': 10.0,
                  'extraWordSpace': 0.0,
                  'volume': 0.5,
                  'inputMethod': 0,
                  'enableGamification': 1,
                  'enableSoundEffects': 0,
                  'enableScreenFlash': 0,
                }
              ]);

      await repo.updateInputMethod(InputMethod.gameController);

      final captured = verify(() => mockDb.update('settings', captureAny(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs'))).captured;
      final map = captured.first as Map<String, dynamic>;
      expect(map['inputMethod'], InputMethod.gameController.index);
    });
  });
}
