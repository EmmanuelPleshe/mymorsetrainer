import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:morse_trainer/core/audio/morse_code_mapper.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/repositories/character_repository.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}
class MockDatabase extends Mock implements Database {}

class FakeCharacter extends Fake implements Character {}

void main() {
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDb;
  late CharacterRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeCharacter());
  });

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockDb = MockDatabase();
    repo = CharacterRepository(dbHelper: mockDbHelper);

    when(() => mockDbHelper.database).thenAnswer((_) async => mockDb);
    when(() => mockDb.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
        .thenAnswer((_) async => 1);
    when(() => mockDb.update(any(), any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
        .thenAnswer((_) async => 1);
  });

  group('getAllCharacters', () {
    test('returns characters ordered by kochOrder', () async {
      when(() => mockDb.query('characters', orderBy: 'kochOrder ASC')).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
          {'id': 'char_M', 'symbol': 'M', 'morsePattern': '--', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 1},
        ],
      );

      final result = await repo.getAllCharacters();

      expect(result.length, 2);
      expect(result[0].symbol, 'K');
      expect(result[1].symbol, 'M');
      expect(result[0].kochOrder, 0);
      expect(result[1].kochOrder, 1);
    });
  });

  group('getUnlockedCharacters', () {
    test('returns only unlocked characters', () async {
      when(() => mockDb.query(
            'characters',
            where: 'isUnlocked = ?',
            whereArgs: [1],
            orderBy: 'kochOrder ASC',
          )).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
        ],
      );

      final result = await repo.getUnlockedCharacters();

      expect(result.length, 1);
      expect(result[0].symbol, 'K');
      expect(result[0].isUnlocked, true);
    });
  });

  group('getCharactersForLevel', () {
    test('returns characters up to level count with unlocked filter', () async {
      when(() => mockDb.query(
            'characters',
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: 'kochOrder ASC',
          )).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
          {'id': 'char_M', 'symbol': 'M', 'morsePattern': '--', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 1},
        ],
      );

      final result = await repo.getCharactersForLevel(1);

      expect(result.length, 2);
      final captured = verify(() => mockDb.query(
            'characters',
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
            orderBy: 'kochOrder ASC',
          )).captured;
      expect(captured[0], 'kochOrder < ? AND isUnlocked = ?');
      expect(captured[1], [4, 1]);
    });

    test('returns characters without unlocked filter when requireUnlocked is false', () async {
      when(() => mockDb.query(
            'characters',
            where: any(named: 'where'),
            whereArgs: any(named: 'whereArgs'),
            orderBy: 'kochOrder ASC',
          )).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
          {'id': 'char_M', 'symbol': 'M', 'morsePattern': '--', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 1},
          {'id': 'char_R', 'symbol': 'R', 'morsePattern': '.-.', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 0, 'kochOrder': 2},
        ],
      );

      final result = await repo.getCharactersForLevel(1, requireUnlocked: false);

      expect(result.length, 3);
      final captured = verify(() => mockDb.query(
            'characters',
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
            orderBy: 'kochOrder ASC',
          )).captured;
      expect(captured[0], 'kochOrder < ?');
      expect(captured[1], [4]);
    });
  });

  group('getCharacter', () {
    test('returns character when found', () async {
      when(() => mockDb.query(
            'characters',
            where: 'symbol = ?',
            whereArgs: ['K'],
          )).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
        ],
      );

      final result = await repo.getCharacter('K');

      expect(result, isNotNull);
      expect(result!.symbol, 'K');
      expect(result.morsePattern, '-.-');
    });

    test('returns null when not found', () async {
      when(() => mockDb.query(
            'characters',
            where: 'symbol = ?',
            whereArgs: ['Z'],
          )).thenAnswer((_) async => []);

      final result = await repo.getCharacter('Z');

      expect(result, isNull);
    });
  });

  group('insertCharacter', () {
    test('inserts with replace conflict algorithm', () async {
      final character = Character(
        id: 'char_X',
        symbol: 'X',
        morsePattern: '-..-',
        kochOrder: 10,
        isUnlocked: false,
      );

      await repo.insertCharacter(character);

      final captured = verify(() => mockDb.insert(
            'characters',
            captureAny(),
            conflictAlgorithm: captureAny(named: 'conflictAlgorithm'),
          )).captured;
      final map = captured[0] as Map<String, dynamic>;
      expect(map['symbol'], 'X');
      expect(captured[1], ConflictAlgorithm.replace);
    });
  });

  group('updateCharacter', () {
    test('updates with correct where clause', () async {
      final character = Character(
        id: 'char_K',
        symbol: 'K',
        morsePattern: '-.-',
        kochOrder: 0,
        isUnlocked: true,
        masteryLevel: 3,
      );

      await repo.updateCharacter(character);

      final captured = verify(() => mockDb.update(
            'characters',
            captureAny(),
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
          )).captured;
      expect(captured[1], 'id = ?');
      expect(captured[2], ['char_K']);
      final map = captured[0] as Map<String, dynamic>;
      expect(map['masteryLevel'], 3);
    });
  });

  group('unlockCharacter', () {
    test('updates isUnlocked for given symbol', () async {
      await repo.unlockCharacter('R');

      final captured = verify(() => mockDb.update(
            'characters',
            captureAny(),
            where: captureAny(named: 'where'),
            whereArgs: captureAny(named: 'whereArgs'),
          )).captured;
      final map = captured[0] as Map<String, dynamic>;
      expect(map['isUnlocked'], 1);
      expect(captured[1], 'symbol = ?');
      expect(captured[2], ['R']);
    });
  });

  group('initializeCharacters', () {
    test('does nothing when characters already exist', () async {
      when(() => mockDb.query('characters', orderBy: 'kochOrder ASC')).thenAnswer(
        (_) async => [
          {'id': 'char_K', 'symbol': 'K', 'morsePattern': '-.-', 'masteryLevel': 0, 'accuracyPercentage': 0.0, 'totalAttempts': 0, 'correctAttempts': 0, 'lastPracticed': null, 'nextReviewDate': null, 'isUnlocked': 1, 'kochOrder': 0},
        ],
      );

      await repo.initializeCharacters();

      verifyNever(() => mockDb.insert('characters', any(), conflictAlgorithm: any(named: 'conflictAlgorithm')));
    });

    test('inserts all characters when table is empty', () async {
      when(() => mockDb.query('characters', orderBy: 'kochOrder ASC')).thenAnswer((_) async => []);

      await repo.initializeCharacters();

      final calls = verify(() => mockDb.insert('characters', captureAny(), conflictAlgorithm: any(named: 'conflictAlgorithm'))).captured;
      expect(calls.length, MorseCodeMapper.kochSequence.length);

      // Verify first two are unlocked
      final firstMap = calls[0] as Map<String, dynamic>;
      final secondMap = calls[1] as Map<String, dynamic>;
      expect(firstMap['symbol'], 'K');
      expect(firstMap['isUnlocked'], 1);
      expect(secondMap['symbol'], 'M');
      expect(secondMap['isUnlocked'], 1);

      // Verify third is locked
      final thirdMap = calls[2] as Map<String, dynamic>;
      expect(thirdMap['symbol'], 'U');
      expect(thirdMap['isUnlocked'], 0);
    });
  });
}
