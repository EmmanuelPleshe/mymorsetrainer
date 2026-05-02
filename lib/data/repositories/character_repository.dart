import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/character.dart';

class CharacterRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Character>> getAllCharacters() async {
    final db = await _dbHelper.database;
    final maps = await db.query('characters', orderBy: 'kochOrder ASC');
    return maps.map((map) => Character.fromMap(map)).toList();
  }

  Future<List<Character>> getUnlockedCharacters() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'isUnlocked = ?',
      whereArgs: [1],
      orderBy: 'kochOrder ASC',
    );
    return maps.map((map) => Character.fromMap(map)).toList();
  }

  Future<List<Character>> getCharactersForLevel(int level, {bool requireUnlocked = true}) async {
    final count = (level + 1) * 2;
    final db = await _dbHelper.database;
    String where = 'kochOrder < ?';
    List<dynamic> whereArgs = [count];
    if (requireUnlocked) {
      where += ' AND isUnlocked = ?';
      whereArgs.add(1);
    }
    final maps = await db.query(
      'characters',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'kochOrder ASC',
    );
    return maps.map((map) => Character.fromMap(map)).toList();
  }

  Future<Character?> getCharacter(String symbol) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'characters',
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
    if (maps.isEmpty) return null;
    return Character.fromMap(maps.first);
  }

  Future<void> insertCharacter(Character character) async {
    final db = await _dbHelper.database;
    await db.insert(
      'characters',
      character.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCharacter(Character character) async {
    final db = await _dbHelper.database;
    await db.update(
      'characters',
      character.toMap(),
      where: 'id = ?',
      whereArgs: [character.id],
    );
  }

  Future<void> unlockCharacter(String symbol) async {
    final db = await _dbHelper.database;
    await db.update(
      'characters',
      {'isUnlocked': 1},
      where: 'symbol = ?',
      whereArgs: [symbol],
    );
  }

  Future<void> initializeCharacters() async {
    final existing = await getAllCharacters();
    if (existing.isNotEmpty) return;

    final morseCode = {
      'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
      'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
      'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
      'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
      'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
      'Z': '--..',
    };

    final kochSequence = [
      'K', 'M', 'R', 'S', 'U', 'A', 'P', 'L', 'W', 'I',
      'N', 'J', 'E', 'F', 'O', 'Y', 'V', 'G', 'Q', 'Z',
      'H', 'B', 'D', 'X', 'C',
    ];

    for (int i = 0; i < kochSequence.length; i++) {
      final symbol = kochSequence[i];
      await insertCharacter(Character(
        id: 'char_$symbol',
        symbol: symbol,
        morsePattern: morseCode[symbol] ?? '',
        kochOrder: i,
        isUnlocked: i < 2,
      ));
    }
  }
}
