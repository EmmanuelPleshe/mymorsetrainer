/// Pure data module that consolidates the ITU-R M.1677 Morse code character
/// map and the expanded Koch character sequence.
///
/// This class has no audio imports, no async, and no side effects. It is
/// intended to be injected via the provider tree and consumed by services
/// that need to translate characters to Morse patterns or walk the Koch
/// progression.
class MorseCodeMapper {
  /// Full ITU-R M.1677 Morse code character map.
  ///
  /// Keys are uppercase single-character strings. Includes the 26 letters
  /// (A-Z), the 10 digits (0-9), and the 14 standard punctuation marks.
  static const Map<String, String> morseCodeMap = {
    // Letters
    'A': '.-',    'B': '-...',  'C': '-.-.',  'D': '-..',   'E': '.',
    'F': '..-.',  'G': '--.',   'H': '....',  'I': '..',    'J': '.---',
    'K': '-.-',   'L': '.-..',  'M': '--',    'N': '-.',    'O': '---',
    'P': '.--.',  'Q': '--.-',  'R': '.-.',   'S': '...',   'T': '-',
    'U': '..-',   'V': '...-',  'W': '.--',   'X': '-..-',  'Y': '-.--',
    'Z': '--..',
    // Digits
    '0': '-----', '1': '.----', '2': '..---', '3': '...--', '4': '....-',
    '5': '.....', '6': '-....', '7': '--...', '8': '---..', '9': '----.',
    // ITU punctuation
    '.': '.-.-.-', ',': '--..--', '?': '..--..', '/': '-..-.',
    '=': '-...-',  '+': '.-.-.',  '"': '.-..-.',  "'": '.----.',
    '@': '.--.-.', '(': '-.--.',  ')': '-.--.-', ':': '---...',
    '-': '-....-', '&': '.-...',
  };

  /// Expanded Koch sequence based on the LCWO/DF2OK ordering.
  ///
  /// Includes letters, digits, and punctuation in the order they are
  /// introduced by the Koch method as implemented on LCWO and DF2OK.
  static const List<String> kochSequence = [
    'K', 'M', 'U', 'R', 'E', 'S', 'N', 'A', 'P', 'T',
    'L', 'W', 'I', '.', 'J', 'Z', '=', 'F', 'O', 'Y',
    ',', 'V', 'G', '5', '/', 'Q', '9', '2', 'H', '3',
    '8', 'B', '?', '4', '7', 'C', '1', 'D', '6', '0',
    'X', '+', '"', "'", '@', '(', ')', ':', '-', '&',
  ];

  /// Returns the Morse pattern for [character], or `null` if the character
  /// is not in the map. Lookup is case-insensitive (uppercase normalization).
  String? getMorsePattern(String character) {
    return morseCodeMap[character.toUpperCase()];
  }

  /// Converts [text] to a Morse pattern string with single spaces between
  /// letter patterns. Unknown characters are skipped. Returns an empty
  /// string if no characters in [text] are mappable.
  String wordToMorse(String text) {
    final patterns = <String>[];
    for (final char in text.toUpperCase().split('')) {
      final pattern = morseCodeMap[char];
      if (pattern != null) {
        patterns.add(pattern);
      }
    }
    return patterns.join(' ');
  }

  /// Returns the list of characters introduced at Koch [level].
  ///
  /// Level 0 returns the first 2 characters, level 1 the first 4, and so on.
  /// Results are capped at the full sequence length.
  List<String> getCharactersForLevel(int level) {
    final count = (level + 1) * 2;
    if (count >= kochSequence.length) {
      return List.unmodifiable(kochSequence);
    }
    return List.unmodifiable(kochSequence.sublist(0, count));
  }

  /// Returns the total number of Koch levels, computed as
  /// `(kochSequence.length / 2).ceil()`.
  int getTotalLevels() {
    return (kochSequence.length / 2).ceil();
  }

  /// Returns all keys (characters) from the Morse code map.
  List<String> getAllCharacters() {
    return List.unmodifiable(morseCodeMap.keys.toList());
  }
}