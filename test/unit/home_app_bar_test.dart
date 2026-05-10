import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/ui/widgets/home_app_bar.dart';

void main() {
  group('HomeAppBar', () {
    testWidgets('shows home button and title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const HomeAppBar(title: 'Test'),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('shows nav icons when showNavIcons=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const HomeAppBar(
              title: 'Practice',
              showNavIcons: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('hides nav icons when showNavIcons=false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const HomeAppBar(
              title: 'Settings',
              showNavIcons: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.school), findsNothing);
      expect(find.byIcon(Icons.bar_chart), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('home button calls onHomePressed callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: HomeAppBar(
              title: 'Test',
              onHomePressed: () async => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('nav icons navigate to routes', (tester) async {
      String? currentRoute;

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/practice',
          routes: {
            '/practice': (context) => Scaffold(
                  appBar: const HomeAppBar(
                    title: 'Practice',
                    showNavIcons: true,
                  ),
                ),
            '/progress': (context) {
              currentRoute = '/progress';
              return const Scaffold(body: Text('Progress'));
            },
            '/settings': (context) {
              currentRoute = '/settings';
              return const Scaffold(body: Text('Settings'));
            },
          },
        ),
      );

      await tester.tap(find.byTooltip('Progress'));
      await tester.pumpAndSettle();
      expect(currentRoute, '/progress');
    });
  });
}
