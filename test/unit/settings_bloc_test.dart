import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:morse_trainer/data/database/database_helper.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/core/audio/morse_code_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseHelper.setTestDbPath(':memory:');
    DatabaseHelper.resetInstance();
    // Reset audio service to known defaults
    AudioPlaybackService().setWpm(20.0);
    AudioPlaybackService().setEffWpm(20.0);
    AudioPlaybackService().setToneFrequency(600.0);
    AudioPlaybackService().setVolume(0.5);
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.resetInstance();
  });

  group('SettingsBloc audio sync on LoadSettings', () {
    test('calls setWpm with persisted WPM', () async {
      final repo = SettingsRepository();
      await repo.updateWpm(25.0);
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);
      expect(AudioPlaybackService().wpm, 25.0);
      await bloc.close();
    });

    test('calls setEffWpm with persisted effWPM', () async {
      final repo = SettingsRepository();
      final current = await repo.getSettings();
      await repo.updateSettings(current.copyWith(effWpm: 18.0));
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);
      expect(AudioPlaybackService().effWpm, 18.0);
      await bloc.close();
    });
  });

  group('SettingsBloc audio sync on update', () {
    test('calls setWpm on UpdateWpm', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateWpm(30.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().wpm, 30.0);
      await bloc.close();
    });

    test('calls setEffWpm on UpdateEffWpm', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateEffWpm(12.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().effWpm, 12.0);
      await bloc.close();
    });

    test('calls setToneFrequency on UpdateToneFrequency', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateToneFrequency(700.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().toneFrequency, 700.0);
      await bloc.close();
    });

    test('calls setVolume on UpdateVolume', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateVolume(0.3));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().volume, 0.3);
      await bloc.close();
    });
  });

  group('SettingsBloc validation', () {
    test('clamps WPM below 5.0 to 5.0', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateWpm(2.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().wpm, 5.0);
      await bloc.close();
    });

    test('clamps WPM above 40.0 to 40.0', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateWpm(50.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().wpm, 40.0);
      await bloc.close();
    });

    test('clamps tone frequency below 300 to 300', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateToneFrequency(100.0));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().toneFrequency, 300.0);
      await bloc.close();
    });

    test('clamps volume above 1.0 to 1.0', () async {
      final repo = SettingsRepository();
      final bloc = SettingsBloc(repo, audioService: AudioPlaybackService());
      bloc.add(const LoadSettings());
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      bloc.add(const UpdateVolume(1.5));
      await bloc.stream.firstWhere((s) => s is SettingsLoaded);

      expect(AudioPlaybackService().volume, 1.0);
      await bloc.close();
    });
  });
}
