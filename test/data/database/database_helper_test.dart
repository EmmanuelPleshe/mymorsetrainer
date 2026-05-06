import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:morse_trainer/data/database/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDownAll(() {
    databaseFactory = null;
  });

  setUp(() {
    DatabaseHelper.reset();
    DatabaseHelper.setTestDbPath(':memory:');
  });

  tearDown(() async {
    DatabaseHelper.reset();
  });

  group('schema creation', () {
    test('creates characters table with correct columns', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='characters'",
      );
      final sql = result.first['sql'] as String;
      expect(sql, contains('id TEXT PRIMARY KEY'));
      expect(sql, contains('symbol TEXT NOT NULL UNIQUE'));
      expect(sql, contains('morsePattern TEXT NOT NULL'));
      expect(sql, contains('masteryLevel INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('accuracyPercentage REAL NOT NULL DEFAULT 0.0'));
      expect(sql, contains('totalAttempts INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('correctAttempts INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('lastPracticed TEXT'));
      expect(sql, contains('nextReviewDate TEXT'));
      expect(sql, contains('isUnlocked INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('kochOrder INTEGER NOT NULL'));
    });

    test('creates user_progress table with correct columns', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='user_progress'",
      );
      final sql = result.first['sql'] as String;
      expect(sql, contains('id TEXT PRIMARY KEY'));
      expect(sql, contains('totalPoints INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('currentStreak INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('longestStreak INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('currentLevel INTEGER NOT NULL DEFAULT 1'));
      expect(sql, contains('charactersMastered INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('totalSessionsCompleted INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('lastSessionDate TEXT'));
      expect(sql, contains('hasCompletedOnboarding INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('skipIntroOnboarding INTEGER NOT NULL DEFAULT 0'));
    });

    test('creates sessions table with correct columns', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='sessions'",
      );
      final sql = result.first['sql'] as String;
      expect(sql, contains('id TEXT PRIMARY KEY'));
      expect(sql, contains('charactersPracticed TEXT NOT NULL'));
      expect(sql, contains('accuracy REAL NOT NULL'));
      expect(sql, contains('duration INTEGER NOT NULL'));
      expect(sql, contains('inputMethod INTEGER NOT NULL'));
      expect(sql, contains('timestamp TEXT NOT NULL'));
    });

    test('creates settings table with correct columns', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='settings'",
      );
      final sql = result.first['sql'] as String;
      expect(sql, contains('id TEXT PRIMARY KEY'));
      expect(sql, contains('toneFrequency REAL NOT NULL DEFAULT 600.0'));
      expect(sql, contains('wpm REAL NOT NULL DEFAULT 20.0'));
      expect(sql, contains('effWpm REAL NOT NULL DEFAULT 10.0'));
      expect(sql, contains('extraWordSpace REAL NOT NULL DEFAULT 0.0'));
      expect(sql, contains('volume REAL NOT NULL DEFAULT 1.0'));
      expect(sql, contains('inputMethod INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('enableGamification INTEGER NOT NULL DEFAULT 1'));
      expect(sql, contains('enableSoundEffects INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('enableScreenFlash INTEGER NOT NULL DEFAULT 0'));
    });
  });

  group('default data', () {
    test('inserts default settings row', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('settings');

      expect(result.length, 1);
      expect(result.first['id'], 'current');
      expect(result.first['toneFrequency'], 600.0);
      expect(result.first['wpm'], 20.0);
      expect(result.first['effWpm'], 10.0);
      expect(result.first['extraWordSpace'], 0.0);
      expect(result.first['volume'], 1.0);
      expect(result.first['inputMethod'], 0);
      expect(result.first['enableGamification'], 1);
      expect(result.first['enableSoundEffects'], 0);
      expect(result.first['enableScreenFlash'], 0);
    });

    test('inserts default user_progress row', () async {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('user_progress');

      expect(result.length, 1);
      expect(result.first['id'], 'current');
      expect(result.first['totalPoints'], 0);
      expect(result.first['currentStreak'], 0);
      expect(result.first['longestStreak'], 0);
      expect(result.first['currentLevel'], 1);
      expect(result.first['charactersMastered'], 0);
      expect(result.first['totalSessionsCompleted'], 0);
    });
  });

  group('migration v1->v5', () {
    test('in-place migration adds all missing columns', () async {
      final tempFile = File(
        '${Directory.systemTemp.path}/morse_migration_test_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      final migrationDb = await openDatabase(
        tempFile.path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE settings (
              id TEXT PRIMARY KEY,
              toneFrequency REAL NOT NULL DEFAULT 600.0,
              wpm REAL NOT NULL DEFAULT 20.0,
              volume REAL NOT NULL DEFAULT 1.0,
              inputMethod INTEGER NOT NULL DEFAULT 0,
              enableGamification INTEGER NOT NULL DEFAULT 1,
              enableSoundEffects INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE user_progress (
              id TEXT PRIMARY KEY,
              totalPoints INTEGER NOT NULL DEFAULT 0,
              currentStreak INTEGER NOT NULL DEFAULT 0,
              longestStreak INTEGER NOT NULL DEFAULT 0,
              currentLevel INTEGER NOT NULL DEFAULT 1,
              charactersMastered INTEGER NOT NULL DEFAULT 0,
              totalSessionsCompleted INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      );

      // Run the same upgrade logic that DatabaseHelper uses
      await migrationDb.execute("ALTER TABLE settings ADD COLUMN effWpm REAL NOT NULL DEFAULT 10.0");
      await migrationDb.execute("ALTER TABLE settings ADD COLUMN extraWordSpace REAL NOT NULL DEFAULT 0.0");
      await migrationDb.execute("ALTER TABLE settings ADD COLUMN enableScreenFlash INTEGER NOT NULL DEFAULT 0");
      await migrationDb.execute("ALTER TABLE user_progress ADD COLUMN hasCompletedOnboarding INTEGER NOT NULL DEFAULT 0");
      await migrationDb.execute("ALTER TABLE user_progress ADD COLUMN skipIntroOnboarding INTEGER NOT NULL DEFAULT 0");

      final settingsCols = await migrationDb.rawQuery('PRAGMA table_info(settings)');
      final settingsColNames = settingsCols.map((c) => c['name']).toList();
      expect(settingsColNames, containsAll(['effWpm', 'extraWordSpace', 'enableScreenFlash']));

      final progressCols = await migrationDb.rawQuery('PRAGMA table_info(user_progress)');
      final progressColNames = progressCols.map((c) => c['name']).toList();
      expect(progressColNames, containsAll(['hasCompletedOnboarding', 'skipIntroOnboarding']));

      await migrationDb.close();
    });

    test('close-then-reopen migration via DatabaseHelper with temp file', () async {
      final tempFile = File(
        '${Directory.systemTemp.path}/morse_test_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      addTearDown(() {
        if (tempFile.existsSync()) tempFile.deleteSync();
      });

      // Create v1 database on disk
      final v1Db = await openDatabase(
        tempFile.path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE settings (
              id TEXT PRIMARY KEY,
              toneFrequency REAL NOT NULL DEFAULT 600.0,
              wpm REAL NOT NULL DEFAULT 20.0,
              volume REAL NOT NULL DEFAULT 1.0,
              inputMethod INTEGER NOT NULL DEFAULT 0,
              enableGamification INTEGER NOT NULL DEFAULT 1,
              enableSoundEffects INTEGER NOT NULL DEFAULT 0
            )
          ''');
          await db.execute('''
            CREATE TABLE user_progress (
              id TEXT PRIMARY KEY,
              totalPoints INTEGER NOT NULL DEFAULT 0,
              currentStreak INTEGER NOT NULL DEFAULT 0,
              longestStreak INTEGER NOT NULL DEFAULT 0,
              currentLevel INTEGER NOT NULL DEFAULT 1,
              charactersMastered INTEGER NOT NULL DEFAULT 0,
              totalSessionsCompleted INTEGER NOT NULL DEFAULT 0
            )
          ''');
        },
      );
      await v1Db.close();

      // Reopen via DatabaseHelper at version 5 — triggers onUpgrade
      DatabaseHelper.reset();
      DatabaseHelper.setTestDbPath(tempFile.path);
      final db = await DatabaseHelper.instance.database;

      // Verify all v5 columns exist after upgrade
      final settingsCols = await db.rawQuery('PRAGMA table_info(settings)');
      final settingsColNames = settingsCols.map((c) => c['name']).toList();
      expect(settingsColNames, containsAll(['effWpm', 'extraWordSpace', 'enableScreenFlash']));

      final progressCols = await db.rawQuery('PRAGMA table_info(user_progress)');
      final progressColNames = progressCols.map((c) => c['name']).toList();
      expect(progressColNames, containsAll(['hasCompletedOnboarding', 'skipIntroOnboarding']));

      // Verify default data was NOT inserted (onUpgrade doesn't call onCreate)
      final settingsRows = await db.query('settings');
      expect(settingsRows, isEmpty);

      final progressRows = await db.query('user_progress');
      expect(progressRows, isEmpty);
    });
  });

  group('singleton behavior', () {
    test('returns same database instance on subsequent calls', () async {
      final db1 = await DatabaseHelper.instance.database;
      final db2 = await DatabaseHelper.instance.database;
      expect(db1, same(db2));
    });

    test('reset creates new instance', () async {
      final db1 = await DatabaseHelper.instance.database;
      await db1.close();
      DatabaseHelper.reset();
      DatabaseHelper.setTestDbPath(':memory:');
      final db2 = await DatabaseHelper.instance.database;
      expect(db2, isNot(same(db1)));
    });
  });
}
