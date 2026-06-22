import 'dart:async';

import '../timing/morse_timing_engine.dart';

/// Abstract interface for audio playback services.
///
/// The interface exposes primitive dot/dash playback and named pauses so
/// that sequencing logic (character/word assembly, prosigns, etc.) can live
/// in a dedicated coordinator ([MorseCodeCoordinator]) instead of being
/// baked into the audio service itself.
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

  /// Plays a single dot tone.
  Future<void> playDot();

  /// Plays a single dash tone.
  Future<void> playDash();

  /// Pauses for [intraCharacterSpaceMs] — used between symbols within a
  /// character.
  Future<void> intraCharacterPause();

  /// Pauses for [interCharacterSpaceMs] — used after a complete character.
  Future<void> interCharacterPause();

  /// Pauses for [interWordSpaceMs] — used between words.
  Future<void> interWordPause();

  Future<void> keyerDown();
  Future<void> keyerUp();

  Future<void> playCorrectFeedback();

  Future<void> dispose();
}