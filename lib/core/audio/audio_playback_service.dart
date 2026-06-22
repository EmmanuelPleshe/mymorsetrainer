import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../timing/morse_timing_engine.dart';
import 'audio_service.dart';

/// Concrete [AudioService] that plays pre-generated WAV tones via `aplay`.
///
/// Sequencing logic (assembling characters/words from dots, dashes, and
/// pauses) lives in [MorseCodeCoordinator]; this class only owns timing
/// configuration, tone generation, keyer control, and feedback sounds.
class AudioPlaybackService implements AudioService {
  AudioPlaybackService();

  // Timing parameters
  double _toneFrequency = 600.0; // Default 600Hz
  double _wpm = 20.0; // Character speed
  double _effWpm = 20.0; // Effective speed (Farnsworth)
  double _volume = 0.5;
  double _extraWordSpace = 0.0; // Extra space between words

  // Pre-generated tone files
  String? _dotWavPath;
  String? _dashWavPath;
  String? _keyerWavPath;
  Process? _keyerProcess;

  MorseTimingEngine _timingEngine = MorseTimingEngine(wpm: 20, effWpm: 20);

  MorseTimingEngine get timingEngine => _timingEngine;

  double get toneFrequency => _toneFrequency;
  double get wpm => _wpm;
  double get effWpm => _effWpm;
  double get volume => _volume;
  double get extraWordSpace => _extraWordSpace;

  int get unitMs => _timingEngine.dotDurationMs;
  int get dotDurationMs => _timingEngine.dotDurationMs;
  int get dashDurationMs => _timingEngine.dashDurationMs;
  int get intraCharacterSpaceMs => _timingEngine.intraCharacterSpaceMs;
  int get interCharacterSpaceMs => _timingEngine.interCharacterSpaceMs;
  int get interWordSpaceMs => _timingEngine.interWordSpaceMs;

  Future<void> initialize() async {
    await _pregenerateTones();
  }

  Future<void> _pregenerateTones() async {
    _dotWavPath = '/tmp/morse_dot.wav';
    _dashWavPath = '/tmp/morse_dash.wav';
    _keyerWavPath = '/tmp/morse_keyer.wav';

    final dotWav = _generateSineWave(dotDurationMs, _toneFrequency, _volume);
    final dashWav = _generateSineWave(dashDurationMs, _toneFrequency, _volume);
    // Generate 1-second tone for keyer - typical max key press duration
    final keyerWav = _generateSineWave(1000, _toneFrequency, _volume);

    await File(_dotWavPath!).writeAsBytes(dotWav);
    await File(_dashWavPath!).writeAsBytes(dashWav);
    await File(_keyerWavPath!).writeAsBytes(keyerWav);
  }

  void setToneFrequency(double frequency) {
    _toneFrequency = frequency.clamp(300.0, 2000.0);
  }

  void setWpm(double wpm) {
    _wpm = wpm.clamp(5.0, 40.0);
    _updateTimingEngine();
  }

  void setEffWpm(double effWpm) {
    _effWpm = effWpm.clamp(5.0, 40.0);
    _updateTimingEngine();
  }

  void setExtraWordSpace(double seconds) {
    _extraWordSpace = seconds.clamp(0.0, 5.0);
    _updateTimingEngine();
  }

  void _updateTimingEngine() {
    _timingEngine = MorseTimingEngine(
      wpm: _wpm,
      effWpm: _effWpm,
      extraWordSpace: (_extraWordSpace * 1000).round(),
    );
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  Future<void> _ensureFileExists(String? path) async {
    if (path == null || !File(path).existsSync()) {
      await initialize();
    }
  }

  Future<void> playDot() async {
    if (_dotWavPath != null) {
      await _ensureFileExists(_dotWavPath);
      final result = await Process.run('aplay', ['-q', _dotWavPath!]);
      if (result.exitCode != 0) {
        throw StateError(
          'Audio playback failed for dot ($_dotWavPath): ${result.stderr}',
        );
      }
    }
  }

  Future<void> playDash() async {
    if (_dashWavPath != null) {
      await _ensureFileExists(_dashWavPath);
      final result = await Process.run('aplay', ['-q', _dashWavPath!]);
      if (result.exitCode != 0) {
        throw StateError(
          'Audio playback failed for dash ($_dashWavPath): ${result.stderr}',
        );
      }
    }
  }

  Future<void> intraCharacterPause() async {
    await Future.delayed(Duration(milliseconds: intraCharacterSpaceMs));
  }

  Future<void> interCharacterPause() async {
    await Future.delayed(Duration(milliseconds: interCharacterSpaceMs));
  }

  Future<void> interWordPause() async {
    await Future.delayed(Duration(milliseconds: interWordSpaceMs));
  }

  // Start tone when key down - optimized for low latency
  Future<void> keyerDown() async {
    // Kill any existing first to avoid overlapping (adds ~10ms but prevents audio glitches)
    await keyerUp();
    if (_keyerWavPath != null) {
      await _ensureFileExists(_keyerWavPath);
      // Use aplay with -d for duration-based (no need to kill on key up)
      // Also use -q for quiet, -v for volume
      _keyerProcess = await Process.start('aplay', ['-q', '-d', '5', _keyerWavPath!]);
    }
  }

  // Stop tone when key up
  Future<void> keyerUp() async {
    if (_keyerProcess != null) {
      _keyerProcess!.kill();
      _keyerProcess = null;
    }
  }

  Future<void> playCorrectFeedback() async {
    final wav = _generateSineWave(150, 880, _volume);
    final path = '/tmp/morse_correct.wav';
    await File(path).writeAsBytes(wav);
    final result = await Process.run('aplay', ['-q', path]);
    if (result.exitCode != 0) {
      throw StateError(
        'Audio playback failed for correct feedback ($path): ${result.stderr}',
      );
    }
  }

  Future<void> dispose() async {
    // Kill running audio process FIRST - critical for avoiding segfault
    if (_keyerProcess != null) {
      _keyerProcess!.kill(ProcessSignal.sigkill);
      _keyerProcess = null;
    }
    // Also stop any playing sound
    await keyerUp();

    try {
      if (_dotWavPath != null) await File(_dotWavPath!).delete();
      if (_dashWavPath != null) await File(_dashWavPath!).delete();
      if (_keyerWavPath != null) await File(_keyerWavPath!).delete();
    } catch (_) {}
  }

  Uint8List _generateSineWave(int durationMs, double frequency, double volume) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final samples = Uint8List(44 + numSamples * 2);

    final header = ByteData.view(samples.buffer, 0, 44);
    samples[0] = 0x52; samples[1] = 0x49; samples[2] = 0x46; samples[3] = 0x46;
    header.setUint32(4, 36 + numSamples * 2, Endian.little);
    samples[8] = 0x57; samples[9] = 0x41; samples[10] = 0x56; samples[11] = 0x45;
    samples[12] = 0x66; samples[13] = 0x6D; samples[14] = 0x74; samples[15] = 0x20;
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, 1, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * 2, Endian.little);
    header.setUint16(32, 2, Endian.little);
    header.setUint16(34, 16, Endian.little);
    samples[36] = 0x64; samples[37] = 0x61; samples[38] = 0x74; samples[39] = 0x61;
    header.setUint32(40, numSamples * 2, Endian.little);

    final amplitude = (volume * 32767).round();
    final phaseStep = 2 * pi * frequency / sampleRate;
    final fadeSamples = (sampleRate * 0.005).round();

    for (int i = 0; i < numSamples; i++) {
      double envelope = 1.0;
      if (i < fadeSamples) {
        envelope = i / fadeSamples;
      }
      if (i > numSamples - fadeSamples) {
        envelope = (numSamples - i) / fadeSamples;
      }

      final sample = (amplitude * envelope * sin(i * phaseStep)).round();
      samples[44 + i * 2] = sample & 0xFF;
      samples[44 + i * 2 + 1] = (sample >> 8) & 0xFF;
    }

    return samples;
  }
}