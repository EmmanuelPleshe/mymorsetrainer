import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../timing/morse_timing_engine.dart';
import 'audio_service.dart';

/// Morse code timing based on ARRL PARIS standard (50 units per word)
/// Reference: https://github.com/spasutto/cw-trainer
class MorseCodeService {
  static const Map<String, String> _morseCode = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
    'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
    'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
    'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
    'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
    'Z': '--..', '0': '-----', '1': '.----', '2': '..---', '3': '...--',
    '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
    '9': '----.', '.': '.-.-.-', ',': '--..--', '?': '..--..', '/': '-..-.',
  };

  static const List<String> kochSequence = [
    'K', 'M', 'R', 'S', 'U', 'A', 'P', 'L', 'W', 'I',
    '.', 'N', 'J', 'E', 'F', '0', 'Y', 'V', 'G', '5',
    '/', 'Q', '9', 'Z', 'H', '3', '8', 'B', '?', '4',
    '2', '7', 'C', '1', 'D', '6', 'X', ',',
  ];

  String? getMorsePattern(String character) {
    return _morseCode[character.toUpperCase()];
  }

  List<String> getAllCharacters() {
    return List.unmodifiable(_morseCode.keys.toList());
  }

  List<String> getCharactersForLevel(int level) {
    final count = (level + 1) * 2;
    if (count >= kochSequence.length) return List.unmodifiable(kochSequence);
    return List.unmodifiable(kochSequence.sublist(0, count));
  }

  int getTotalLevels() {
    return (kochSequence.length / 2).ceil();
  }

  /// Convert a word to its Morse pattern string with spaces between letters.
  String wordToMorse(String word) {
    final patterns = <String>[];
    for (final char in word.toUpperCase().split('')) {
      final pattern = _morseCode[char];
      if (pattern != null) {
        patterns.add(pattern);
      }
    }
    return patterns.join(' ');
  }
}

/// Audio playback with proper ARRL timing
class AudioPlaybackService implements AudioService {
  static final AudioPlaybackService _instance = AudioPlaybackService._internal();
  factory AudioPlaybackService() => _instance;
  AudioPlaybackService._internal();

  // Timing parameters
  double _toneFrequency = 600.0;  // Default 600Hz
  double _wpm = 20.0;            // Character speed
  double _effWpm = 20.0;          // Effective speed (Farnsworth)
  double _volume = 0.5;
  double _extraWordSpace = 0.0;   // Extra space between words

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

  Future<void> playCharacter(String character, {bool screenFlash = false, Function(bool)? onFlash}) async {
    final pattern = MorseCodeService().getMorsePattern(character);
    if (pattern == null) return;

    await initialize();

    for (int i = 0; i < pattern.length; i++) {
      final symbol = pattern[i];
      if (symbol == '.') {
        await _playDot();
        if (screenFlash) onFlash?.call(true);
        await Future.delayed(Duration(milliseconds: intraCharacterSpaceMs));
        if (screenFlash) onFlash?.call(false);
      } else {
        await _playDash();
        if (screenFlash) onFlash?.call(true);
        await Future.delayed(Duration(milliseconds: intraCharacterSpaceMs));
        if (screenFlash) onFlash?.call(false);
      }
    }

    // Inter-character space after full character
    await Future.delayed(Duration(milliseconds: interCharacterSpaceMs));
  }

  Future<void> playSequence(List<String> characters) async {
    for (int i = 0; i < characters.length; i++) {
      await playCharacter(characters[i]);
      if (i < characters.length - 1) {
        await Future.delayed(Duration(milliseconds: interWordSpaceMs));
      }
    }
  }

  Future<void> playWord(String word, {void Function(bool)? onFlash}) async {
    final characters = word.toUpperCase().split('');
    for (int i = 0; i < characters.length; i++) {
      await playCharacter(characters[i], screenFlash: onFlash != null, onFlash: onFlash);
      // playCharacter already adds interCharacterSpaceMs at the end
      // No extra delay needed between letters
    }
  }

  Future<void> _ensureFileExists(String? path) async {
    if (path == null || !File(path).existsSync()) {
      await initialize();
    }
  }

  Future<void> _playDot() async {
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

  Future<void> _playDash() async {
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