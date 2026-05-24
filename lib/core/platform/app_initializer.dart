class AppInitializer {
  final Future<void> Function() initializeWindowManager;
  final void Function() initializeSqfliteFfi;
  final Future<void> Function() initializeLogger;
  final Future<void> Function() initializeCharacterRepo;
  final bool isDesktop;

  AppInitializer({
    required this.initializeWindowManager,
    required this.initializeSqfliteFfi,
    required this.initializeLogger,
    required this.initializeCharacterRepo,
    required this.isDesktop,
  });

  Future<void> initialize() async {
    if (isDesktop) {
      await initializeWindowManager();
      initializeSqfliteFfi();
    }
    await initializeLogger();
    await initializeCharacterRepo();
  }
}
