import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/morse_code_service.dart';

class MockAudioPlaybackService extends Mock implements AudioPlaybackService {
  @override
  int get dotDurationMs => 60;

  @override
  int get dashDurationMs => 180;

  @override
  int get unitMs => 60;

  @override
  int get interCharacterSpaceMs => 180;

  @override
  int get interWordSpaceMs => 420;

  @override
  double get toneFrequency => 800;

  @override
  double get wpm => 20;

  @override
  double get effWpm => 20;

  @override
  double get volume => 0.5;
}