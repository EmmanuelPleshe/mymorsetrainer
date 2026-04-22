import '../database/database_helper.dart';
import '../models/settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<AppSettings> getSettings() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: ['current'],
    );
    if (maps.isEmpty) {
      final defaultSettings = AppSettings();
      await db.insert('settings', defaultSettings.toMap());
      return defaultSettings;
    }
    return AppSettings.fromMap(maps.first);
  }

  Future<void> updateSettings(AppSettings settings) async {
    final db = await _dbHelper.database;
    await db.update(
      'settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  Future<void> updateToneFrequency(double frequency) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(toneFrequency: frequency));
  }

  Future<void> updateWpm(double wpm) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(wpm: wpm));
  }

  Future<void> updateVolume(double volume) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(volume: volume));
  }

  Future<void> updateInputMethod(InputMethod method) async {
    final settings = await getSettings();
    await updateSettings(settings.copyWith(inputMethod: method));
  }
}
