import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/audio_service.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/ui/bloc/practice_session_bloc.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/ui/screens/practice_screen.dart';

import '../helpers/mocks/mock_audio_service.dart';

class MockPracticeSessionBloc extends MockBloc<PracticeSessionEvent, PracticeSessionState>
    implements PracticeSessionBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

class FakePracticeSessionEvent extends Fake implements PracticeSessionEvent {}
class FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late MockPracticeSessionBloc mockPracticeBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockAudioService mockAudioService;

  Widget buildTestWidget() {
    return MaterialApp(
      initialRoute: '/practice',
      routes: {
        '/': (context) => const Scaffold(body: Text('Home')),
        '/practice': (context) => MultiBlocProvider(
          providers: [
            BlocProvider<PracticeSessionBloc>.value(value: mockPracticeBloc),
            BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
          ],
          child: PracticeScreen(audioService: mockAudioService),
        ),
      },
    );
  }

  final defaultSettings = AppSettings(
    toneFrequency: 600.0,
    wpm: 20.0,
    effWpm: 10.0,
    volume: 0.5,
    inputMethod: InputMethod.keyboard,
    enableGamification: true,
    enableSoundEffects: false,
    enableScreenFlash: false,
  );

  setUpAll(() {
    registerFallbackValue(FakePracticeSessionEvent());
    registerFallbackValue(FakeSettingsEvent());
  });

  setUp(() {
    mockPracticeBloc = MockPracticeSessionBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockAudioService = MockAudioService();

    when(() => mockAudioService.initialize()).thenAnswer((_) async {});
    when(() => mockAudioService.playCharacter(any(), screenFlash: any(named: 'screenFlash'), onFlash: any(named: 'onFlash')))
        .thenAnswer((_) async {});
    when(() => mockAudioService.keyerDown()).thenAnswer((_) async {});
    when(() => mockAudioService.keyerUp()).thenAnswer((_) async {});
    when(() => mockAudioService.playCorrectFeedback()).thenAnswer((_) async {});
    when(() => mockAudioService.dispose()).thenAnswer((_) async {});
  });

  group('Navigation Flow', () {
    testWidgets('audio stops when home button tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final character = Character(
        id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1,
      );
      final activeState = PracticeSessionActive(
        characters: [character],
        currentIndex: 0,
        correctCount: 0,
        totalAnswered: 0,
        currentStreak: 0,
        lastAnswerCorrect: null,
      );

      when(() => mockPracticeBloc.state).thenReturn(activeState);
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(activeState));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap home button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Verify audio was stopped
      verify(() => mockAudioService.keyerUp()).called(1);
    });

    testWidgets('navigates to home when home button tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final character = Character(
        id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1,
      );
      final activeState = PracticeSessionActive(
        characters: [character],
        currentIndex: 0,
        correctCount: 0,
        totalAnswered: 0,
        currentStreak: 0,
        lastAnswerCorrect: null,
      );

      when(() => mockPracticeBloc.state).thenReturn(activeState);
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(activeState));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Tap home button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify home route is shown
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
