import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/ui/screens/settings_screen.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}
class FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late MockSettingsBloc mockSettingsBloc;
  bool replayIntroCalled = false;

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SettingsBloc>.value(
        value: mockSettingsBloc,
        child: SettingsScreen(
          onReplayIntro: () => replayIntroCalled = true,
        ),
      ),
    );
  }

  final loadedSettings = AppSettings(
    toneFrequency: 600.0,
    wpm: 20.0,
    effWpm: 10.0,
    extraWordSpace: 0.5,
    volume: 0.75,
    inputMethod: InputMethod.keyboard,
    enableGamification: true,
    enableSoundEffects: true,
    enableScreenFlash: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeSettingsEvent());
  });

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    replayIntroCalled = false;
  });

  group('SettingsScreen', () {
    testWidgets('renders app bar with Settings title', (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator when state is SettingsLoading', (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(SettingsLoading());
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoading()));

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when state is SettingsError', (tester) async {
      when(() => mockSettingsBloc.state).thenReturn(const SettingsError('db fail'));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(const SettingsError('db fail')));

      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('db fail'), findsOneWidget);
    });

    testWidgets('renders slider values when loaded', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Tone Frequency'), findsOneWidget);
      expect(find.text('600 Hz'), findsOneWidget);
      expect(find.text('Speed (WPM)'), findsOneWidget);
      expect(find.text('20 WPM'), findsOneWidget);
      expect(find.text('Effective Speed (Farnsworth)'), findsOneWidget);
      expect(find.text('10 WPM'), findsOneWidget);
      expect(find.text('Extra Word Space'), findsOneWidget);
      expect(find.text('1 s'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('renders input method radio buttons when loaded', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Input Method'), findsOneWidget);
      expect(find.text('Keyboard'), findsOneWidget);
      expect(find.text('Touchscreen'), findsOneWidget);
      expect(find.text('Game Controller'), findsOneWidget);
      expect(find.text('Audio Input (Mic)'), findsOneWidget);
    });

    testWidgets('renders preference switches when loaded', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Enable Gamification'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Screen Flash'), findsOneWidget);
    });

    testWidgets('tapping gamification switch dispatches ToggleGamification', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Enable Gamification'));
      await tester.pump();

      verify(() => mockSettingsBloc.add(any(that: isA<ToggleGamification>()))).called(1);
    });

    testWidgets('tapping sound effects switch dispatches UpdateSoundEffects', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Sound Effects'));
      await tester.pump();

      verify(() => mockSettingsBloc.add(any(that: isA<UpdateSoundEffects>()))).called(1);
    });

    testWidgets('tapping screen flash switch dispatches UpdateScreenFlash', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Screen Flash'));
      await tester.pump();

      verify(() => mockSettingsBloc.add(any(that: isA<UpdateScreenFlash>()))).called(1);
    });

    testWidgets('selecting touchscreen radio dispatches UpdateInputMethod', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Touchscreen'));
      await tester.pump();

      verify(() => mockSettingsBloc.add(any(that: isA<UpdateInputMethod>()))).called(1);
    });

    testWidgets('tapping Replay Intro calls onReplayIntro callback', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockSettingsBloc.state).thenReturn(SettingsLoaded(loadedSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => Stream.value(SettingsLoaded(loadedSettings)));

      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Replay Intro'));
      await tester.pump();

      expect(replayIntroCalled, isTrue);
    });
  });
}
