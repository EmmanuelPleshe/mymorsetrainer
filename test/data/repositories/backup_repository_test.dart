import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/data/models/user_progress.dart';
import 'package:morse_trainer/data/repositories/backup_repository.dart';
import 'package:morse_trainer/data/repositories/character_repository.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';
import 'package:morse_trainer/data/repositories/user_progress_repository.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockUserProgressRepository extends Mock implements UserProgressRepository {}

class FakeCharacter extends Fake implements Character {}
class FakeAppSettings extends Fake implements AppSettings {}
class FakeUserProgress extends Fake implements UserProgress {}

void main() {
  late MockCharacterRepository mockCharRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockUserProgressRepository mockProgressRepo;
  late BackupRepository repo;

  setUpAll(() {
    registerFallbackValue(FakeCharacter());
    registerFallbackValue(FakeAppSettings());
    registerFallbackValue(FakeUserProgress());
  });

  setUp(() {
    mockCharRepo = MockCharacterRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockProgressRepo = MockUserProgressRepository();
    repo = BackupRepository(
      characterRepo: mockCharRepo,
      settingsRepo: mockSettingsRepo,
      progressRepo: mockProgressRepo,
    );
  });

  group('exportToJson', () {
    test('returns valid JSON with all sections', () async {
      when(() => mockCharRepo.getAllCharacters()).thenAnswer(
        (_) async => [
          Character(
            id: 'char_K',
            symbol: 'K',
            morsePattern: '-.-',
            kochOrder: 0,
            isUnlocked: true,
            masteryLevel: 3,
            totalAttempts: 10,
            correctAttempts: 8,
          ),
        ],
      );
      when(() => mockSettingsRepo.getSettings()).thenAnswer(
        (_) async => AppSettings(
          id: 'current',
          toneFrequency: 600.0,
          wpm: 20.0,
          inputMethod: InputMethod.keyboard,
        ),
      );
      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(
          id: 'current',
          totalPoints: 100,
          currentStreak: 5,
          currentLevel: 3,
        ),
      );

      final json = await repo.exportToJson();
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['version'], 1);
      expect(data['exportDate'], isNotNull);
      expect(data['characters'], isA<List>());
      expect(data['settings'], isA<Map<String, dynamic>>());
      expect(data['userProgress'], isA<Map<String, dynamic>>());

      final chars = data['characters'] as List;
      expect(chars.length, 1);
      expect(chars.first['symbol'], 'K');

      final settings = data['settings'] as Map<String, dynamic>;
      expect(settings['toneFrequency'], 600.0);

      final progress = data['userProgress'] as Map<String, dynamic>;
      expect(progress['totalPoints'], 100);
    });

    test('handles empty character list', () async {
      when(() => mockCharRepo.getAllCharacters()).thenAnswer((_) async => []);
      when(() => mockSettingsRepo.getSettings()).thenAnswer(
        (_) async => AppSettings(),
      );
      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(),
      );

      final json = await repo.exportToJson();
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['characters'], isEmpty);
    });
  });

  group('importFromJson', () {
    test('imports characters, settings, and progress', () async {
      when(() => mockCharRepo.updateCharacter(any())).thenAnswer((_) async {});
      when(() => mockSettingsRepo.updateSettings(any())).thenAnswer((_) async {});
      when(() => mockProgressRepo.updateUserProgress(any())).thenAnswer((_) async {});

      final json = jsonEncode({
        'version': 1,
        'characters': [
          {
            'id': 'char_M',
            'symbol': 'M',
            'morsePattern': '--',
            'masteryLevel': 2,
            'accuracyPercentage': 0.0,
            'totalAttempts': 5,
            'correctAttempts': 4,
            'lastPracticed': null,
            'nextReviewDate': null,
            'isUnlocked': 1,
            'kochOrder': 1,
          }
        ],
        'settings': {
          'id': 'current',
          'toneFrequency': 700.0,
          'wpm': 25.0,
          'effWpm': 10.0,
          'extraWordSpace': 0.0,
          'volume': 0.8,
          'inputMethod': 0,
          'enableGamification': 1,
          'enableSoundEffects': 0,
          'enableScreenFlash': 0,
        },
        'userProgress': {
          'id': 'current',
          'totalPoints': 50,
          'currentStreak': 3,
          'longestStreak': 10,
          'currentLevel': 2,
          'charactersMastered': 5,
          'totalSessionsCompleted': 15,
          'lastSessionDate': null,
          'hasCompletedOnboarding': 1,
          'skipIntroOnboarding': 0,
        },
      });

      await repo.importFromJson(json);

      final charCaptured = verify(() => mockCharRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(charCaptured.symbol, 'M');
      expect(charCaptured.isUnlocked, true);

      final settingsCaptured = verify(() => mockSettingsRepo.updateSettings(captureAny())).captured.single as AppSettings;
      expect(settingsCaptured.toneFrequency, 700.0);

      final progressCaptured = verify(() => mockProgressRepo.updateUserProgress(captureAny())).captured.single as UserProgress;
      expect(progressCaptured.totalPoints, 50);
      expect(progressCaptured.hasCompletedOnboarding, true);
    });

    test('skips missing sections gracefully', () async {
      when(() => mockSettingsRepo.updateSettings(any())).thenAnswer((_) async {});

      final json = jsonEncode({
        'version': 1,
        'settings': {
          'id': 'current',
          'toneFrequency': 500.0,
          'wpm': 15.0,
          'effWpm': 10.0,
          'extraWordSpace': 0.0,
          'volume': 0.5,
          'inputMethod': 0,
          'enableGamification': 1,
          'enableSoundEffects': 0,
          'enableScreenFlash': 0,
        },
      });

      await repo.importFromJson(json);

      verifyNever(() => mockCharRepo.updateCharacter(any()));
      verify(() => mockSettingsRepo.updateSettings(any())).called(1);
      verifyNever(() => mockProgressRepo.updateUserProgress(any()));
    });

    test('roundtrip: export then import preserves data', () async {
      final originalChar = Character(
        id: 'char_R',
        symbol: 'R',
        morsePattern: '.-.',
        kochOrder: 2,
        isUnlocked: true,
        masteryLevel: 1,
        totalAttempts: 3,
        correctAttempts: 2,
      );
      final originalSettings = AppSettings(
        id: 'current',
        toneFrequency: 900.0,
        wpm: 30.0,
        inputMethod: InputMethod.touchscreen,
        enableGamification: false,
      );
      final originalProgress = UserProgress(
        id: 'current',
        totalPoints: 200,
        currentStreak: 10,
        hasCompletedOnboarding: true,
      );

      when(() => mockCharRepo.getAllCharacters()).thenAnswer((_) async => [originalChar]);
      when(() => mockSettingsRepo.getSettings()).thenAnswer((_) async => originalSettings);
      when(() => mockProgressRepo.getUserProgress()).thenAnswer((_) async => originalProgress);

      final exportedJson = await repo.exportToJson();

      // Now set up import mocks
      when(() => mockCharRepo.updateCharacter(any())).thenAnswer((_) async {});
      when(() => mockSettingsRepo.updateSettings(any())).thenAnswer((_) async {});
      when(() => mockProgressRepo.updateUserProgress(any())).thenAnswer((_) async {});

      await repo.importFromJson(exportedJson);

      final charCaptured = verify(() => mockCharRepo.updateCharacter(captureAny())).captured.single as Character;
      expect(charCaptured.id, 'char_R');
      expect(charCaptured.symbol, 'R');
      expect(charCaptured.morsePattern, '.-.');
      expect(charCaptured.kochOrder, 2);
      expect(charCaptured.isUnlocked, true);
      expect(charCaptured.masteryLevel, 1);
      expect(charCaptured.totalAttempts, 3);
      expect(charCaptured.correctAttempts, 2);

      final settingsCaptured = verify(() => mockSettingsRepo.updateSettings(captureAny())).captured.single as AppSettings;
      expect(settingsCaptured.toneFrequency, 900.0);
      expect(settingsCaptured.wpm, 30.0);
      expect(settingsCaptured.inputMethod, InputMethod.touchscreen);
      expect(settingsCaptured.enableGamification, false);

      final progressCaptured = verify(() => mockProgressRepo.updateUserProgress(captureAny())).captured.single as UserProgress;
      expect(progressCaptured.totalPoints, 200);
      expect(progressCaptured.currentStreak, 10);
      expect(progressCaptured.hasCompletedOnboarding, true);
    });
  });

  group('exportToFile', () {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('backup_test_');
      channel.setMockMethodCallHandler((call) async {
        if (call.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      });
    });

    tearDown(() async {
      channel.setMockMethodCallHandler(null);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('writes JSON to file in app documents directory', () async {
      when(() => mockCharRepo.getAllCharacters()).thenAnswer((_) async => []);
      when(() => mockSettingsRepo.getSettings()).thenAnswer((_) async => AppSettings());
      when(() => mockProgressRepo.getUserProgress()).thenAnswer((_) async => UserProgress());

      final file = await repo.exportToFile();

      expect(await file.exists(), true);
      expect(file.path, contains('morse_trainer_backup_'));
      expect(file.parent.path, tempDir.path);

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      expect(data['version'], 1);
    });
  });
}
