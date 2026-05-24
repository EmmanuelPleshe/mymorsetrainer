import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/data/repositories/settings_repository.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class FakeAppSettings extends Fake implements AppSettings {}

void main() {
  late MockSettingsRepository mockRepo;
  late SettingsBloc bloc;

  final defaultSettings = AppSettings(
    id: 'current',
    toneFrequency: 800.0,
    wpm: 15.0,
    effWpm: 10.0,
    volume: 0.5,
    inputMethod: InputMethod.keyboard,
    enableGamification: true,
    enableSoundEffects: false,
    enableScreenFlash: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeAppSettings());
    registerFallbackValue(InputMethod.keyboard);
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    bloc = SettingsBloc(mockRepo);
  });

  group('LoadSettings', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits [SettingsLoading, SettingsLoaded] on success',
      build: () {
        when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultSettings);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.toneFrequency, 'toneFrequency', 800.0),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'emits [SettingsLoading, SettingsError] on failure',
      build: () {
        when(() => mockRepo.getSettings()).thenThrow(Exception('db error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadSettings()),
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsError>().having((s) => (s as SettingsError).message, 'message', contains('db error')),
      ],
    );
  });

  group('UpdateToneFrequency', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates frequency and reloads settings',
      build: () {
        when(() => mockRepo.updateToneFrequency(any())).thenAnswer((_) async {});
        when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultSettings.copyWith(toneFrequency: 900.0));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateToneFrequency(900.0)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.toneFrequency, 'toneFrequency', 900.0),
      ],
      verify: (_) {
        verify(() => mockRepo.updateToneFrequency(900.0)).called(1);
      },
    );
  });

  group('UpdateWpm', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates wpm and reloads settings',
      build: () {
        when(() => mockRepo.updateWpm(any())).thenAnswer((_) async {});
        when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultSettings.copyWith(wpm: 25.0));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateWpm(25.0)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.wpm, 'wpm', 25.0),
      ],
      verify: (_) {
        verify(() => mockRepo.updateWpm(25.0)).called(1);
      },
    );
  });

  group('UpdateEffWpm', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates effWpm and reloads settings',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings;
          return defaultSettings.copyWith(effWpm: 12.0);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateEffWpm(12.0)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.effWpm, 'effWpm', 12.0),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.effWpm, 12.0);
      },
    );
  });

  group('UpdateExtraWordSpace', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates extraWordSpace and reloads settings',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings;
          return defaultSettings.copyWith(extraWordSpace: 0.5);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateExtraWordSpace(0.5)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.extraWordSpace, 'extraWordSpace', 0.5),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.extraWordSpace, 0.5);
      },
    );
  });

  group('UpdateVolume', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates volume and reloads settings',
      build: () {
        when(() => mockRepo.updateVolume(any())).thenAnswer((_) async {});
        when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultSettings.copyWith(volume: 0.8));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateVolume(0.8)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.volume, 'volume', 0.8),
      ],
      verify: (_) {
        verify(() => mockRepo.updateVolume(0.8)).called(1);
      },
    );
  });

  group('UpdateInputMethod', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates input method and reloads settings',
      build: () {
        when(() => mockRepo.updateInputMethod(any())).thenAnswer((_) async {});
        when(() => mockRepo.getSettings()).thenAnswer((_) async => defaultSettings.copyWith(inputMethod: InputMethod.touchscreen));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateInputMethod(InputMethod.touchscreen)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.inputMethod, 'inputMethod', InputMethod.touchscreen),
      ],
      verify: (_) {
        verify(() => mockRepo.updateInputMethod(InputMethod.touchscreen)).called(1);
      },
    );
  });

  group('ToggleGamification', () {
    blocTest<SettingsBloc, SettingsState>(
      'toggles gamification off when currently on',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings;
          return defaultSettings.copyWith(enableGamification: false);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleGamification()),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.enableGamification, 'enableGamification', false),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.enableGamification, false);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'toggles gamification on when currently off',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings.copyWith(enableGamification: false);
          return defaultSettings.copyWith(enableGamification: true);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const ToggleGamification()),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.enableGamification, 'enableGamification', true),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.enableGamification, true);
      },
    );
  });

  group('UpdateSoundEffects', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates sound effects and reloads settings',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings;
          return defaultSettings.copyWith(enableSoundEffects: true);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateSoundEffects(true)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.enableSoundEffects, 'enableSoundEffects', true),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.enableSoundEffects, true);
      },
    );
  });

  group('UpdateScreenFlash', () {
    blocTest<SettingsBloc, SettingsState>(
      'updates screen flash and reloads settings',
      build: () {
        int callCount = 0;
        when(() => mockRepo.getSettings()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return defaultSettings;
          return defaultSettings.copyWith(enableScreenFlash: true);
        });
        when(() => mockRepo.updateSettings(any())).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateScreenFlash(true)),
      expect: () => [
        isA<SettingsLoaded>().having((s) => (s as SettingsLoaded).settings.enableScreenFlash, 'enableScreenFlash', true),
      ],
      verify: (_) {
        final captured = verify(() => mockRepo.updateSettings(captureAny())).captured.single as AppSettings;
        expect(captured.enableScreenFlash, true);
      },
    );
  });

  group('error handling', () {
    blocTest<SettingsBloc, SettingsState>(
      'emits SettingsError when updateWpm throws',
      build: () {
        when(() => mockRepo.updateWpm(any())).thenThrow(Exception('write failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateWpm(30.0)),
      expect: () => [
        isA<SettingsError>().having((s) => (s as SettingsError).message, 'message', contains('write failed')),
      ],
    );
  });
}
