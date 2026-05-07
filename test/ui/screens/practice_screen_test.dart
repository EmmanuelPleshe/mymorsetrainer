import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/character.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/ui/bloc/practice_session_bloc.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/ui/screens/practice_screen.dart';

class MockPracticeSessionBloc extends MockBloc<PracticeSessionEvent, PracticeSessionState>
    implements PracticeSessionBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

class FakePracticeSessionEvent extends Fake implements PracticeSessionEvent {}
class FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late MockPracticeSessionBloc mockPracticeBloc;
  late MockSettingsBloc mockSettingsBloc;

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PracticeSessionBloc>.value(value: mockPracticeBloc),
          BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
        ],
        child: const PracticeScreen(),
      ),
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
  });

  group('PracticeScreen', () {
    testWidgets('renders app bar with Practice title', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Practice'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders start screen with title and subtitle', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Morse Code Trainer'), findsOneWidget);
      expect(find.text('Learn morse code fast with Koch method'), findsOneWidget);
      expect(find.text('Select Level'), findsOneWidget);
      expect(find.text('Start Practice'), findsOneWidget);
    });

    testWidgets('level selector starts at level 1', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Characters: 2'), findsOneWidget);
    });

    testWidgets('tapping + increments level', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('Characters: 4'), findsOneWidget);
    });

    testWidgets('tapping - decrements level', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      // Increment first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(find.text('Level 2'), findsOneWidget);

      // Then decrement
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Characters: 2'), findsOneWidget);
    });

    testWidgets('tapping Start Practice dispatches StartSession', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Start Practice'));
      await tester.pump();

      verify(() => mockPracticeBloc.add(any(that: isA<StartSession>()))).called(1);
    });

    testWidgets('shows loading indicator when state is PracticeSessionLoading', (tester) async {
      when(() => mockPracticeBloc.state).thenReturn(PracticeSessionLoading());
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(PracticeSessionLoading()));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows correct feedback when lastAnswerCorrect is true', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final character = Character(
        id: 'k', symbol: 'K', morsePattern: '-.-', kochOrder: 1,
      );
      final activeState = PracticeSessionActive(
        characters: [character],
        currentIndex: 0,
        correctCount: 1,
        totalAnswered: 1,
        currentStreak: 1,
        lastAnswerCorrect: true,
      );

      when(() => mockPracticeBloc.state).thenReturn(activeState);
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(activeState));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Correct!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows wrong feedback when lastAnswerCorrect is false', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final character = Character(
        id: 'm', symbol: 'M', morsePattern: '--', kochOrder: 1,
      );
      final activeState = PracticeSessionActive(
        characters: [character],
        currentIndex: 0,
        correctCount: 0,
        totalAnswered: 1,
        currentStreak: 0,
        lastAnswerCorrect: false,
      );

      when(() => mockPracticeBloc.state).thenReturn(activeState);
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(activeState));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Try again'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders completion summary when state is PracticeSessionComplete', (tester) async {
      final completeState = PracticeSessionComplete(
        correctCount: 18,
        totalQuestions: 20,
        accuracy: 0.9,
        unlockedNextLevel: true,
      );

      when(() => mockPracticeBloc.state).thenReturn(completeState);
      when(() => mockPracticeBloc.stream).thenAnswer((_) => Stream.value(completeState));
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Session Complete!'), findsOneWidget);
      expect(find.text('18 / 20 correct'), findsOneWidget);
      expect(find.text('Accuracy: 90.0%'), findsOneWidget);
      expect(find.text('Next level unlocked!'), findsOneWidget);
    });
  });
}
