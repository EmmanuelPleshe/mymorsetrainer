import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/settings.dart';
import 'package:morse_trainer/data/models/user_progress.dart';
import 'package:morse_trainer/data/repositories/user_progress_repository.dart';
import 'package:morse_trainer/domain/gamification/gamification_service.dart';
import 'package:morse_trainer/main.dart';
import 'package:morse_trainer/ui/bloc/practice_session_bloc.dart';
import 'package:morse_trainer/ui/bloc/settings_bloc.dart';
import 'package:morse_trainer/ui/screens/help_screen.dart';
import 'package:morse_trainer/ui/screens/onboarding_screen.dart';
import 'package:morse_trainer/ui/screens/practice_screen.dart';
import 'package:morse_trainer/ui/screens/progress_screen.dart';
import 'package:morse_trainer/ui/screens/settings_screen.dart';

class MockUserProgressRepository extends Mock implements UserProgressRepository {}

class MockGamificationService extends Mock implements GamificationService {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockPracticeSessionBloc
    extends MockBloc<PracticeSessionEvent, PracticeSessionState>
    implements PracticeSessionBloc {}

class FakeSettingsEvent extends Fake implements SettingsEvent {}

class FakePracticeSessionEvent extends Fake implements PracticeSessionEvent {}

void main() {
  late MockUserProgressRepository mockProgressRepo;
  late MockGamificationService mockGamificationService;
  late MockSettingsBloc mockSettingsBloc;
  late MockPracticeSessionBloc mockPracticeBloc;

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

  Widget buildTestWidget({UserProgressRepository? progressRepo}) {
    return MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GamificationService>.value(
            value: mockGamificationService,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<PracticeSessionBloc>.value(value: mockPracticeBloc),
            BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
          ],
          child: HomeScreen(userProgressRepository: progressRepo),
        ),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(FakeSettingsEvent());
    registerFallbackValue(FakePracticeSessionEvent());
  });

  setUp(() {
    mockProgressRepo = MockUserProgressRepository();
    mockGamificationService = MockGamificationService();
    mockSettingsBloc = MockSettingsBloc();
    mockPracticeBloc = MockPracticeSessionBloc();
  });

  group('HomeScreen', () {
    testWidgets('shows loading indicator while checking onboarding',
        (tester) async {
      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(
          hasCompletedOnboarding: false,
          skipIntroOnboarding: false,
        ),
      );
      when(() => mockPracticeBloc.state)
          .thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream)
          .thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state)
          .thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream)
          .thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget(progressRepo: mockProgressRepo));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows onboarding when not completed', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(
          hasCompletedOnboarding: false,
          skipIntroOnboarding: false,
        ),
      );
      when(() => mockPracticeBloc.state)
          .thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream)
          .thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state)
          .thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream)
          .thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget(progressRepo: mockProgressRepo));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('shows main navigation when onboarding complete',
        (tester) async {
      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(
          hasCompletedOnboarding: true,
          skipIntroOnboarding: false,
        ),
      );
      when(() => mockPracticeBloc.state)
          .thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream)
          .thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state)
          .thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream)
          .thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));

      await tester.pumpWidget(buildTestWidget(progressRepo: mockProgressRepo));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Practice'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Progress'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Settings'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Help'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping navigation switches screens', (tester) async {
      when(() => mockProgressRepo.getUserProgress()).thenAnswer(
        (_) async => UserProgress(
          hasCompletedOnboarding: true,
          skipIntroOnboarding: false,
        ),
      );
      when(() => mockPracticeBloc.state)
          .thenReturn(PracticeSessionInitial());
      when(() => mockPracticeBloc.stream)
          .thenAnswer((_) => Stream.value(PracticeSessionInitial()));
      when(() => mockSettingsBloc.state)
          .thenReturn(SettingsLoaded(defaultSettings));
      when(() => mockSettingsBloc.stream)
          .thenAnswer((_) => Stream.value(SettingsLoaded(defaultSettings)));
      when(() => mockGamificationService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'currentLevel': 1,
          'charactersMastered': 0,
          'totalSessionsCompleted': 0,
        },
      );

      await tester.pumpWidget(buildTestWidget(progressRepo: mockProgressRepo));
      await tester.pumpAndSettle();

      // Default index is 0 (Practice)
      expect(find.byType(PracticeScreen), findsOneWidget);

      // Tap Progress
      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();
      expect(find.byType(ProgressScreen), findsOneWidget);

      // Tap Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Tap Help
      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();
      expect(find.byType(HelpScreen), findsOneWidget);

      // Tap Practice
      await tester.tap(find.text('Practice'));
      await tester.pumpAndSettle();
      expect(find.byType(PracticeScreen), findsOneWidget);
    });
  });
}
