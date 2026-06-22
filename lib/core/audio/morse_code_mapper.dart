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
    // Prosigns (sent with no inter-character space)
    'AR': '.-.-.',    'BT': '-...-',   'SK': '...-.-',
    'KN': '-.--.',    'AS': '.-...',   'SOS': '...---...',
    'CL': '-.-..-..', 'CT': '-.-.-',   'VE': '...-.',
  };

  /// Prosigns — sent as a single logical unit with no inter-character pause.
  static const Set<String> _prosigns = {
    'AR', 'BT', 'SK', 'KN', 'AS', 'SOS', 'CL', 'CT', 'VE',
  };

  /// Returns true if [entry] is a prosign (sent with no inter-character space).
  bool isProsign(String entry) {
    return _prosigns.contains(entry.toUpperCase());
  }

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
    // Prosigns (sent with no inter-character space)
    'AR', 'BT', 'SK', 'KN', 'AS', 'SOS', 'CL', 'CT', 'VE',
  ];

  /// Returns the Morse pattern for [character], or `null` if the character
  /// is not in the map. Lookup is case-insensitive (uppercase normalization).
  String? getMorsePattern(String character) {
    return morseCodeMap[character.toUpperCase()];
  }

  /// Converts [text] to a Morse pattern string with single spaces between
  /// letter patterns. Unknown characters are skipped. Returns an empty
  /// string if no characters in [text] are mappable.
  ///
  /// Prosigns (multi-character entries such as 'AR' or 'SOS') are matched
  /// with a longest-first lookahead so that 'AR' yields '.-.-.' rather than
  /// '.- .-.'
  String wordToMorse(String text) {
    final upper = text.toUpperCase();
    final patterns = <String>[];
    int i = 0;
    while (i < upper.length) {
      // Try 3-char prosign first (SOS, CL), then 2-char prosigns.
      String? matched;
      int consumed = 0;
      if (i + 3 <= upper.length) {
        final three = upper.substring(i, i + 3);
        if (isProsign(three) && morseCodeMap.containsKey(three)) {
          matched = morseCodeMap[three];
          consumed = 3;
        }
      }
      if (matched == null && i + 2 <= upper.length) {
        final two = upper.substring(i, i + 2);
        if (isProsign(two) && morseCodeMap.containsKey(two)) {
          matched = morseCodeMap[two];
          consumed = 2;
        }
      }
      if (matched == null) {
        final one = upper.substring(i, i + 1);
        final pattern = morseCodeMap[one];
        if (pattern != null) {
          patterns.add(pattern);
        }
        i += 1;
        continue;
      }
      patterns.add(matched);
      i += consumed;
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