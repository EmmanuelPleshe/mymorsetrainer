import 'dart:async';

import '../timing/morse_timing_engine.dart';

/// Abstract interface for audio playback services.
/// Allows injecting real [AudioPlaybackService] or fakes in tests.
abstract class AudioService {
  double get toneFrequency;
  double get wpm;
  double get effWpm;
  double get volume;
  double get extraWordSpace;

  int get unitMs;
  int get dotDurationMs;
  int get dashDurationMs;
  int get intraCharacterSpaceMs;
  int get interCharacterSpaceMs;
  int get interWordSpaceMs;

  MorseTimingEngine get timingEngine;

  Future<void> initialize();

  void setToneFrequency(double frequency);
  void setWpm(double wpm);
  void setEffWpm(double effWpm);
  void setExtraWordSpace(double seconds);
  void setVolume(double volume);

  Future<void> playCharacter(
    String character, {
    bool screenFlash = false,
    void Function(bool)? onFlash,
  });

  Future<void> playSequence(List<String> characters);

  Future<void> playWord(String word, {void Function(bool)? onFlash});

  Future<void> keyerDown();
  Future<void> keyerUp();

  Future<void> playCorrectFeedback();

  Future<void> dispose();
}
