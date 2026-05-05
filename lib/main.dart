import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'core/audio/morse_code_service.dart';
import 'core/logging/logger.dart';
import 'core/logging/log_constants.dart';
import 'data/repositories/user_progress_repository.dart';
import 'ui/screens/onboarding_screen.dart';
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
  await windowManager.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize logger
  await Logger.instance.initialize();
  await Logger.instance.info(LogCategory.general, 'Application starting');

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
                userProgressRepository: userProgressRepo,
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, WindowListener {
  int _currentIndex = 0;
  bool _showOnboarding = true;
  bool _checkedOnboarding = false;
  bool _forceReplayOnboarding = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    _screens = [
      const PracticeScreen(),
      const ProgressScreen(),
      SettingsScreen(onReplayIntro: _replayOnboarding),
    ];
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final repo = UserProgressRepository();
    final progress = await repo.getUserProgress();
    setState(() {
      // Show onboarding if not completed AND not skipping (or force replay)
      _showOnboarding = _forceReplayOnboarding || (!progress.hasCompletedOnboarding && !progress.skipIntroOnboarding);
      _checkedOnboarding = true;
    });
  }

  void _replayOnboarding() {
    setState(() {
      _forceReplayOnboarding = true;
      _showOnboarding = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    AudioPlaybackService().dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Dispose audio BEFORE window closes - critical for avoiding segfault
    await AudioPlaybackService().dispose();
    await windowManager.destroy();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      AudioPlaybackService().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking onboarding status
    if (!_checkedOnboarding) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show onboarding for first-time users
    if (_showOnboarding) {
      return OnboardingScreen(
        onComplete: () => setState(() => _showOnboarding = false),
      );
    }

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
