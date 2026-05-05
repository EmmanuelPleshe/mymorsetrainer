import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/character.dart';
import '../models/settings.dart';
import '../models/user_progress.dart';
import 'character_repository.dart';
import 'settings_repository.dart';
import 'user_progress_repository.dart';

class BackupRepository {
  final CharacterRepository _characterRepo;
  final SettingsRepository _settingsRepo;
  final UserProgressRepository _progressRepo;

  BackupRepository({
    CharacterRepository? characterRepo,
    SettingsRepository? settingsRepo,
    UserProgressRepository? progressRepo,
  })  : _characterRepo = characterRepo ?? CharacterRepository(),
        _settingsRepo = settingsRepo ?? SettingsRepository(),
        _progressRepo = progressRepo ?? UserProgressRepository();

  Future<String> exportToJson() async {
    final characters = await _characterRepo.getAllCharacters();
    final settings = await _settingsRepo.getSettings();
    final progress = await _progressRepo.getUserProgress();

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': 1,
      'characters': characters.map((c) => c.toMap()).toList(),
      'settings': settings.toMap(),
      'userProgress': progress.toMap(),
    };

    return jsonEncode(data);
  }

  Future<File> exportToFile() async {
    final json = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/morse_trainer_backup_$timestamp.json');
    await file.writeAsString(json);
    return file;
  }

  Future<void> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;

    // Import characters
    if (data['characters'] != null) {
      final chars = data['characters'] as List;
      for (final char in chars) {
        await _characterRepo.updateCharacter(Character.fromMap(char));
      }
    }

    // Import settings
    if (data['settings'] != null) {
      await _settingsRepo.updateSettings(AppSettings.fromMap(data['settings']));
    }

    // Import progress
    if (data['userProgress'] != null) {
      await _progressRepo.updateUserProgress(UserProgress.fromMap(data['userProgress']));
    }
  }
}