import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/domain/gamification/gamification_service.dart';
import 'package:morse_trainer/ui/screens/progress_screen.dart';

class MockGamificationService extends Mock implements GamificationService {}

void main() {
  late MockGamificationService mockService;

  Widget buildTestWidget() {
    return MaterialApp(
      home: RepositoryProvider<GamificationService>.value(
        value: mockService,
        child: const ProgressScreen(),
      ),
    );
  }

  setUp(() {
    mockService = MockGamificationService();
  });

  group('ProgressScreen', () {
    testWidgets('renders app bar with Progress title', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'currentLevel': 1,
          'charactersMastered': 0,
          'totalSessionsCompleted': 0,
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Progress'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows loading indicator while fetching stats', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => {}),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump past the delayed future to avoid pending timers
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('renders stat cards with values', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 150,
          'currentStreak': 5,
          'longestStreak': 10,
          'currentLevel': 3,
          'charactersMastered': 8,
          'totalSessionsCompleted': 20,
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Total Points'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('Characters Mastered'), findsOneWidget);
      expect(find.text('8 / 26'), findsAtLeastNWidgets(1));
      expect(find.text('Sessions Completed'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(GridView), matching: find.text('20')),
        findsOneWidget,
      );
    });

    testWidgets('renders streak card with current and best', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 0,
          'currentStreak': 7,
          'longestStreak': 15,
          'currentLevel': 1,
          'charactersMastered': 0,
          'totalSessionsCompleted': 0,
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Best'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('renders level progress card', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'currentLevel': 5,
          'charactersMastered': 13,
          'totalSessionsCompleted': 0,
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Level Progress'), findsOneWidget);
      expect(find.text('Level 5'), findsOneWidget);
      expect(find.textContaining('% complete'), findsOneWidget);
    });

    testWidgets('renders session history card', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => {
          'totalPoints': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'currentLevel': 1,
          'charactersMastered': 0,
          'totalSessionsCompleted': 42,
        },
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('Session History'), findsOneWidget);
      expect(find.text('Sessions completed'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(() => mockService.getStats()).thenAnswer(
        (_) async => throw Exception('db error'),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('db error'), findsOneWidget);
    });

    testWidgets('handles empty stats gracefully', (tester) async {
      when(() => mockService.getStats()).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.text('0'), findsAtLeastNWidgets(1));
    });
  });
}
