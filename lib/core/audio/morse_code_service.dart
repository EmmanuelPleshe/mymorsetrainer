import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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
}

/// Audio playback with proper ARRL timing
class AudioPlaybackService {
  static final AudioPlaybackService _instance = AudioPlaybackService._internal();
  factory AudioPlaybackService() => _instance;
  AudioPlaybackService._internal();

  // Timing parameters
  double _toneFrequency = 800.0;  // Default 800Hz (from cw-trainer)
  double _wpm = 20.0;            // Character speed
  double _effWpm = 20.0;          // Effective speed (Farnsworth)
  double _volume = 0.5;
  double _extraWordSpace = 0.0;   // Extra space between words

  // Pre-generated tone files
  String? _dotWavPath;
  String? _dashWavPath;
  String? _keyerWavPath;
  Process? _keyerProcess;

  double get toneFrequency => _toneFrequency;
  double get wpm => _wpm;
  double get effWpm => _effWpm;
  double get volume => _volume;
  double get extraWordSpace => _extraWordSpace;

  // Timing calculations based on PARIS standard (50 units per word)
  // 1 unit = 1200 / WPM milliseconds
  int get unitMs => (1200 / _wpm).round();

  int get dotDurationMs => unitMs;
  int get dashDurationMs => unitMs * 3;
  int get intraCharacterSpaceMs => unitMs;
  int get interCharacterSpaceMs => _calcInterCharSpace();
  int get interWordSpaceMs => _calcInterWordSpace();

  int _calcInterCharSpace() {
    // ARRL Farnsworth standard formula
    if (_effWpm >= _wpm) return unitMs * 3;
    final c = _wpm;
    final s = _effWpm;
    final t_a = (60 * c - 37.2 * s) / (s * c);
    final t_c = (3 * t_a) / 19;
    return (3 * unitMs) + (t_c * 1000).round();
  }

  int _calcInterWordSpace() {
    // ARRL Farnsworth standard formula
    if (_effWpm >= _wpm) {
      final base = unitMs * 7;
      final extra = (_extraWordSpace * 1000).round();
      return base + extra;
    }
    final c = _wpm;
    final s = _effWpm;
    final t_a = (60 * c - 37.2 * s) / (s * c);
    final t_w = (7 * t_a) / 19;
    final base = unitMs * 7;
    final extra = (_extraWordSpace * 1000).round();
    return base + (t_w * 1000).round() + extra;
  }

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
  }

  void setEffWpm(double effWpm) {
    _effWpm = effWpm.clamp(5.0, 40.0);
  }

  void setExtraWordSpace(double seconds) {
    _extraWordSpace = seconds.clamp(0.0, 5.0);
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

  Future<void> _playDot() async {
    if (_dotWavPath != null) {
      await Process.run('aplay', ['-q', _dotWavPath!]);
    }
  }

  Future<void> _playDash() async {
    if (_dashWavPath != null) {
      await Process.run('aplay', ['-q', _dashWavPath!]);
    }
  }

  // Start tone when key down
  Future<void> keyerDown() async {
    await keyerUp();
    if (_keyerWavPath != null) {
      _keyerProcess = await Process.start('paplay', [_keyerWavPath!]);
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
    await Process.run('aplay', ['-q', path]);
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