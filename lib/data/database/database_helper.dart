import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String? _testDbPath;

  DatabaseHelper._init();

  /// Set a custom database path for testing (e.g., ':memory:').
  /// Call [resetInstance] after setting to ensure the next [database]
  /// call uses the new path.
  static void setTestDbPath(String path) {
    _testDbPath = path;
  }

  /// Reset the singleton so the next [database] call re-initializes.
  static void resetInstance() {
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = _testDbPath ?? join(
      (await getApplicationDocumentsDirectory()).path,
      'morse_trainer.db',
    );
    _database = await _initDB(path);
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          try {
            await db.execute("ALTER TABLE settings ADD COLUMN effWpm REAL NOT NULL DEFAULT 10.0");
            await db.execute("ALTER TABLE settings ADD COLUMN extraWordSpace REAL NOT NULL DEFAULT 0.0");
          } catch (_) {}
        }
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE settings ADD COLUMN enableScreenFlash INTEGER NOT NULL DEFAULT 0");
          } catch (_) {}
        }
        if (oldVersion < 4) {
          try {
            await db.execute("ALTER TABLE user_progress ADD COLUMN hasCompletedOnboarding INTEGER NOT NULL DEFAULT 0");
          } catch (_) {}
        }
        if (oldVersion < 5) {
          try {
            await db.execute("ALTER TABLE user_progress ADD COLUMN skipIntroOnboarding INTEGER NOT NULL DEFAULT 0");
          } catch (_) {}
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE characters (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL UNIQUE,
        morsePattern TEXT NOT NULL,
        masteryLevel INTEGER NOT NULL DEFAULT 0,
        accuracyPercentage REAL NOT NULL DEFAULT 0.0,
        totalAttempts INTEGER NOT NULL DEFAULT 0,
        correctAttempts INTEGER NOT NULL DEFAULT 0,
        lastPracticed TEXT,
        nextReviewDate TEXT,
        isUnlocked INTEGER NOT NULL DEFAULT 0,
        kochOrder INTEGER NOT NULL
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
        totalSessionsCompleted INTEGER NOT NULL DEFAULT 0,
        lastSessionDate TEXT,
        hasCompletedOnboarding INTEGER NOT NULL DEFAULT 0,
        skipIntroOnboarding INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        charactersPracticed TEXT NOT NULL,
        accuracy REAL NOT NULL,
        duration INTEGER NOT NULL,
        inputMethod INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY,
        toneFrequency REAL NOT NULL DEFAULT 600.0,
        wpm REAL NOT NULL DEFAULT 20.0,
        effWpm REAL NOT NULL DEFAULT 20.0,
        extraWordSpace REAL NOT NULL DEFAULT 0.0,
        volume REAL NOT NULL DEFAULT 0.5,
        inputMethod INTEGER NOT NULL DEFAULT 0,
        enableGamification INTEGER NOT NULL DEFAULT 1,
        enableSoundEffects INTEGER NOT NULL DEFAULT 0,
        enableScreenFlash INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'id': 'current',
      'toneFrequency': 600.0,
      'wpm': 20.0,
      'effWpm': 20.0,
      'extraWordSpace': 0.0,
      'volume': 0.5,
      'inputMethod': 0,
      'enableGamification': 1,
      'enableSoundEffects': 0,
      'enableScreenFlash': 0,
    });

    // Insert default user progress
    await db.insert('user_progress', {
      'id': 'current',
      'totalPoints': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'currentLevel': 1,
      'charactersMastered': 0,
      'totalSessionsCompleted': 0,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
