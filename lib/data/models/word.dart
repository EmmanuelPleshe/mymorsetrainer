class Word {
  final String text;
  final String morseCode;
  final String category;
  final int difficulty;

  const Word({
    required this.text,
    required this.morseCode,
    required this.category,
    this.difficulty = 1,
  });

  static String textToMorse(String text) {
    final morseMap = {
      'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
      'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
      'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
      'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
      'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
      'Z': '--..', '0': '-----', '1': '.----', '2': '..---', '3': '...--',
      '4': '....-', '5': '.....', '6': '-....', '7': '--...', '8': '---..',
      '9': '----.', ' ': ' ',
    };

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final char = text[i].toUpperCase();
      final morse = morseMap[char];
      if (morse != null) {
        buffer.write(morse);
        if (i < text.length - 1 && text[i + 1] != ' ') {
          buffer.write(' '); // intra-character space
        }
      }
    }
    return buffer.toString();
  }
}

class QSOPhrase {
  final String text;
  final String meaning;
  final String category;

  const QSOPhrase({
    required this.text,
    required this.meaning,
    required this.category,
  });
}