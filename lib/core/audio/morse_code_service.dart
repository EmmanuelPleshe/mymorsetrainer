import 'package:audioplayers/audioplayers.dart';

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

class AudioPlaybackService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _toneFrequency = 600.0;
  double _wpm = 20.0;
  double _volume = 1.0;

  double get toneFrequency => _toneFrequency;
  double get wpm => _wpm;
  double get volume => _volume;

  void setToneFrequency(double frequency) {
    _toneFrequency = frequency.clamp(300.0, 2000.0);
  }

  void setWpm(double wpm) {
    _wpm = wpm.clamp(5.0, 40.0);
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  int get dotDurationMs => (1200 / _wpm).round();
  int get dashDurationMs => dotDurationMs * 3;
  int get symbolSpaceMs => dotDurationMs;
  int get letterSpaceMs => dotDurationMs * 3;
  int get wordSpaceMs => dotDurationMs * 7;

  Future<void> playCharacter(String character) async {
    final pattern = MorseCodeService().getMorsePattern(character);
    if (pattern == null) return;

    for (int i = 0; i < pattern.length; i++) {
      final symbol = pattern[i];
      final duration = symbol == '.' ? dotDurationMs : dashDurationMs;

      await _playTone(duration);

      if (i < pattern.length - 1) {
        await Future.delayed(Duration(milliseconds: symbolSpaceMs));
      }
    }
  }

  Future<void> playSequence(List<String> characters) async {
    for (int i = 0; i < characters.length; i++) {
      await playCharacter(characters[i]);
      if (i < characters.length - 1) {
        await Future.delayed(Duration(milliseconds: letterSpaceMs));
      }
    }
  }

  Future<void> _playTone(int durationMs) async {
    // TODO: Implement actual tone generation
    // For now, just delay to simulate timing
    await Future.delayed(Duration(milliseconds: durationMs));
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
