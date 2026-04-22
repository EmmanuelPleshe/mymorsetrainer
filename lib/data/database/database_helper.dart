import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('morse_trainer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
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
        lastSessionDate TEXT
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
        volume REAL NOT NULL DEFAULT 1.0,
        inputMethod INTEGER NOT NULL DEFAULT 0,
        enableGamification INTEGER NOT NULL DEFAULT 1,
        enableSoundEffects INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'id': 'current',
      'toneFrequency': 600.0,
      'wpm': 20.0,
      'volume': 1.0,
      'inputMethod': 0,
      'enableGamification': 1,
      'enableSoundEffects': 1,
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
