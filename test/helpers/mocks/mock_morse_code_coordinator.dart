import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/morse_code_coordinator.dart';

class MockMorseCodeCoordinator extends Mock implements MorseCodeCoordinator {
  @override
  bool get isPlaying => false;
}
