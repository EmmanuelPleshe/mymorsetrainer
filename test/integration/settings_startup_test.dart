import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/core/audio/audio_playback_service.dart';

void main() {
  // Shared instance across tests in this file (replaces the old singleton).
  late AudioPlaybackService audioService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.setTestDbPath(':memory:');
    DatabaseHelper.resetInstance();
    audioService = AudioPlaybackService();
    audioService.setWpm(20.0);
    audioService.setEffWpm(20.0);
    audioService.setToneFrequency(600.0);
    audioService.setVolume(0.5);
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetInstance();
  });

  test('cold start loads persisted settings and initializes audio', () async {
    // Arrange: persist custom settings
    final repo = SettingsRepository();
    await repo.updateWpm(25.0);
    await repo.updateSettings(
      (await repo.getSettings()).copyWith(effWpm: 18.0, toneFrequency: 700.0, volume: 0.3),
    );

    // Act: simulate cold start by creating a new BLoC
    final bloc = SettingsBloc(repo, audioService: audioService);
    bloc.add(const LoadSettings());

    // Assert: state transitions to SettingsLoaded
    final loaded = await bloc.stream.firstWhere((s) => s is SettingsLoaded);
    expect(loaded, isA<SettingsLoaded>());
    final settings = (loaded as SettingsLoaded).settings;
    expect(settings.wpm, 25.0);
    expect(settings.effWpm, 18.0);
    expect(settings.toneFrequency, 700.0);
    expect(settings.volume, 0.3);

    // Assert: audio service is initialized with persisted values
    expect(audioService.wpm, 25.0);
    expect(audioService.effWpm, 18.0);
    expect(audioService.toneFrequency, 700.0);
    expect(audioService.volume, 0.3);

    await bloc.close();
  });
}
