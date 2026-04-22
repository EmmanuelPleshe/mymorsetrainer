import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data/repositories/character_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/user_progress_repository.dart';
import 'domain/gamification/gamification_service.dart';
import 'domain/koch/koch_progression_service.dart';
import 'domain/spaced_repetition/spaced_repetition_service.dart';
import 'ui/bloc/practice_session_bloc.dart';
import 'ui/bloc/settings_bloc.dart';
import 'ui/screens/practice_screen.dart';
import 'ui/screens/progress_screen.dart';
import 'ui/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize database with default characters
  final characterRepo = CharacterRepository();
  await characterRepo.initializeCharacters();

  runApp(const MorseTrainerApp());
}

class MorseTrainerApp extends StatelessWidget {
  const MorseTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CharacterRepository()),
        RepositoryProvider(create: (_) => UserProgressRepository()),
        RepositoryProvider(create: (_) => SettingsRepository()),
        RepositoryProvider(
          create: (context) => GamificationService(context.read<UserProgressRepository>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final characterRepo = context.read<CharacterRepository>();
              final userProgressRepo = context.read<UserProgressRepository>();
              return PracticeSessionBloc(
                kochService: KochProgressionService(characterRepo),
                gamificationService: GamificationService(userProgressRepo),
                spacedRepetitionService: SpacedRepetitionService(characterRepo),
              );
            },
          ),
          BlocProvider(
            create: (context) => SettingsBloc(context.read<SettingsRepository>())
              ..add(const LoadSettings()),
          ),
        ],
        child: MaterialApp(
          title: 'Morse Trainer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
          routes: {
            '/practice': (context) => const PracticeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/progress': (context) => const ProgressScreen(),
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PracticeScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
