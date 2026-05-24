import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/core/audio/audio_service.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

class MockAudioService extends Mock implements AudioService {
  @override
  int get dotDurationMs => 60;

  @override
  int get dashDurationMs => 180;

  @override
  int get unitMs => 60;

  @override
  int get intraCharacterSpaceMs => 60;

  @override
  int get interCharacterSpaceMs => 180;

  @override
  int get interWordSpaceMs => 420;

  @override
  MorseTimingEngine get timingEngine => MorseTimingEngine(wpm: 20, effWpm: 20);

  @override
  double get toneFrequency => 800;

  @override
  double get wpm => 20;

  @override
  double get effWpm => 20;

  @override
  double get volume => 0.5;

  @override
  double get extraWordSpace => 0;
}
