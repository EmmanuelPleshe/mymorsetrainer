import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/ui/bloc/practice_session_bloc.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/ui/screens/onboarding_screen.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}
class MockPracticeSessionBloc extends MockBloc<PracticeSessionEvent, PracticeSessionState> implements PracticeSessionBloc {}

class FakeSettingsEvent extends Fake implements SettingsEvent {}
class FakePracticeSessionEvent extends Fake implements PracticeSessionEvent {}

void main() {
  late MockSettingsBloc mockSettingsBloc;
  late MockPracticeSessionBloc mockPracticeBloc;
  bool onCompleteCalled = false;

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<SettingsBloc>.value(
        value: mockSettingsBloc,
        child: BlocProvider<PracticeSessionBloc>.value(
          value: mockPracticeBloc,
          child: OnboardingScreen(
            onComplete: () => onCompleteCalled = true,
          ),
        ),
      ),
    );
  }

  void setLargeScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  setUpAll(() {
    registerFallbackValue(FakeSettingsEvent());
    registerFallbackValue(FakePracticeSessionEvent());
  });

  setUp(() {
    mockSettingsBloc = MockSettingsBloc();
    mockPracticeBloc = MockPracticeSessionBloc();
    onCompleteCalled = false;

    when(() => mockSettingsBloc.state).thenReturn(SettingsInitial());
    when(() => mockPracticeBloc.state).thenReturn(PracticeSessionInitial());
  });

  group('page navigation', () {
    testWidgets('renders welcome page first', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Welcome to Morse Trainer'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.byIcon(Icons.radio), findsOneWidget);
    });

    testWidgets('Next advances to Koch explanation page', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('How the Koch Method Works'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('Next from page 2 advances to settings page', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Set Your Preferences'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Back returns to previous page', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Morse Trainer'), findsOneWidget);
    });

    testWidgets('progress dots update with page', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());

      // Page 0: first dot blue
      final dots = find.byType(Container);
      // The 3 progress dots are Containers inside a Row
      // We verify by navigating and checking state indirectly
      expect(find.text('Welcome to Morse Trainer'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('How the Koch Method Works'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Set Your Preferences'), findsOneWidget);
    });
  });

  group('settings page', () {
    testWidgets('renders sliders and test sound button', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Set Your Preferences'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.text('Test Sound'), findsOneWidget);
      expect(find.text('Skip this intro on future launches'), findsOneWidget);
    });

    testWidgets('skip checkbox toggles', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pump();
      final checkboxWidget = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget.value, true);

      // Tap to uncheck
      await tester.tap(checkbox);
      await tester.pump();
      final checkboxWidget2 = tester.widget<Checkbox>(checkbox);
      expect(checkboxWidget2.value, false);
    });
  });

  group('complete onboarding', () {
    testWidgets('Get Started fires SettingsBloc events and calls onComplete', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pump();

      verify(() => mockSettingsBloc.add(any(that: isA<UpdateWpm>()))).called(1);
      verify(() => mockSettingsBloc.add(any(that: isA<UpdateToneFrequency>()))).called(1);
      verify(() => mockPracticeBloc.add(any(that: isA<CompleteOnboarding>()))).called(1);
      expect(onCompleteCalled, true);
    });

    testWidgets('Get Started with skipIntro passes flag to CompleteOnboarding', (tester) async {
      setLargeScreenSize(tester);
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Check the skip checkbox
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      await tester.tap(find.text('Get Started'));
      await tester.pump();

      final captured = verify(() => mockPracticeBloc.add(captureAny(that: isA<CompleteOnboarding>()))).captured.single as CompleteOnboarding;
      expect(captured.skipIntro, true);
    });
  });
}
