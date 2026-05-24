import '../../data/models/word.dart';

class WordPracticeService {
  static const List<Word> _commonWords = [
    // QSO / Prosign terms (20)
    Word(text: 'CQ', morseCode: '-.-. --.-', category: 'qso', difficulty: 1),
    Word(text: 'DE', morseCode: '-.. .', category: 'qso', difficulty: 1),
    Word(text: 'K', morseCode: '-.-', category: 'qso', difficulty: 1),
    Word(text: 'R', morseCode: '.-.', category: 'qso', difficulty: 1),
    Word(text: '73', morseCode: '--... ...--', category: 'qso', difficulty: 1),
    Word(text: '88', morseCode: '---.. ---..', category: 'qso', difficulty: 1),
    Word(text: 'QTH', morseCode: '--.- -.... ....', category: 'qso', difficulty: 2),
    Word(text: 'QRM', morseCode: '--.- .-. --', category: 'qso', difficulty: 2),
    Word(text: 'QRN', morseCode: '--.- .-. -.', category: 'qso', difficulty: 2),
    Word(text: 'QSB', morseCode: '--.- ... -...', category: 'qso', difficulty: 2),
    Word(text: 'PSE', morseCode: '.--. ... .', category: 'qso', difficulty: 2),
    Word(text: 'TNX', morseCode: '- .... -...-..', category: 'qso', difficulty: 2),
    Word(text: 'TU', morseCode: '- ..-', category: 'qso', difficulty: 1),
    Word(text: 'OM', morseCode: '--- --', category: 'qso', difficulty: 1),
    Word(text: 'YL', morseCode: '-.-- .-..', category: 'qso', difficulty: 1),
    Word(text: 'XYL', morseCode: '-..- -.-- .-..', category: 'qso', difficulty: 2),
    Word(text: 'HW', morseCode: '.... .--', category: 'qso', difficulty: 2),
    Word(text: 'CPI', morseCode: '-.-. .--. ..', category: 'qso', difficulty: 3),
    Word(text: 'BK', morseCode: '-... -.-', category: 'qso', difficulty: 2),
    Word(text: 'CL', morseCode: '-.-. .-..', category: 'qso', difficulty: 1),
    // Common English words (60)
    Word(text: 'THE', morseCode: '- .... .', category: 'english', difficulty: 2),
    Word(text: 'AND', morseCode: '.- -. -..', category: 'english', difficulty: 2),
    Word(text: 'FOR', morseCode: '..-. --- .-.', category: 'english', difficulty: 2),
    Word(text: 'ARE', morseCode: '.- .-. .', category: 'english', difficulty: 2),
    Word(text: 'BUT', morseCode: '-... ..- -', category: 'english', difficulty: 2),
    Word(text: 'NOT', morseCode: '-. --- -', category: 'english', difficulty: 2),
    Word(text: 'YOU', morseCode: '-.-- --- ..-', category: 'english', difficulty: 2),
    Word(text: 'ALL', morseCode: '.- .-.. .-..', category: 'english', difficulty: 2),
    Word(text: 'ANY', morseCode: '.- -. -.--', category: 'english', difficulty: 2),
    Word(text: 'CAN', morseCode: '-.-. .- -.', category: 'english', difficulty: 2),
    Word(text: 'HAD', morseCode: '.... .- -..', category: 'english', difficulty: 2),
    Word(text: 'HER', morseCode: '.... . .-.', category: 'english', difficulty: 2),
    Word(text: 'WAS', morseCode: '.-- .- ...', category: 'english', difficulty: 2),
    Word(text: 'ONE', morseCode: '--- -. .', category: 'english', difficulty: 2),
    Word(text: 'OUR', morseCode: '--- ..- .-.', category: 'english', difficulty: 2),
    Word(text: 'OUT', morseCode: '--- ..- -', category: 'english', difficulty: 2),
    Word(text: 'DAY', morseCode: '-.. .- -.--', category: 'english', difficulty: 2),
    Word(text: 'GET', morseCode: '--. . -', category: 'english', difficulty: 2),
    Word(text: 'HAS', morseCode: '.... .- ...', category: 'english', difficulty: 2),
    Word(text: 'HIM', morseCode: '.... .. --', category: 'english', difficulty: 2),
    Word(text: 'HIS', morseCode: '.... .. ...', category: 'english', difficulty: 2),
    Word(text: 'HOW', morseCode: '.... --- .--', category: 'english', difficulty: 2),
    Word(text: 'MAN', morseCode: '-- .- -.', category: 'english', difficulty: 2),
    Word(text: 'NEW', morseCode: '-. . .--', category: 'english', difficulty: 2),
    Word(text: 'NOW', morseCode: '-. --- .--', category: 'english', difficulty: 2),
    Word(text: 'OLD', morseCode: '--- .-.. -..', category: 'english', difficulty: 2),
    Word(text: 'SEE', morseCode: '... . .', category: 'english', difficulty: 2),
    Word(text: 'TWO', morseCode: '- .-- ---', category: 'english', difficulty: 2),
    Word(text: 'WAY', morseCode: '.-- .- -.--', category: 'english', difficulty: 2),
    Word(text: 'WHO', morseCode: '.-- .... ---', category: 'english', difficulty: 2),
    Word(text: 'BOY', morseCode: '-... --- -.--', category: 'english', difficulty: 2),
    Word(text: 'DID', morseCode: '-.. .. -..', category: 'english', difficulty: 2),
    Word(text: 'ITS', morseCode: '.. - ...', category: 'english', difficulty: 2),
    Word(text: 'LET', morseCode: '.-.. . -', category: 'english', difficulty: 2),
    Word(text: 'PUT', morseCode: '.--. ..- -', category: 'english', difficulty: 2),
    Word(text: 'SAY', morseCode: '... .- -.--', category: 'english', difficulty: 2),
    Word(text: 'SHE', morseCode: '... .... .', category: 'english', difficulty: 2),
    Word(text: 'TOO', morseCode: '- --- ---', category: 'english', difficulty: 2),
    Word(text: 'USE', morseCode: '..- ... .', category: 'english', difficulty: 2),
    Word(text: 'DAD', morseCode: '-.. .- -..', category: 'english', difficulty: 2),
    Word(text: 'MOM', morseCode: '-- --- --', category: 'english', difficulty: 2),
    Word(text: 'CAR', morseCode: '-.-. .- .-.', category: 'english', difficulty: 2),
    Word(text: 'DOG', morseCode: '-.. --- --.', category: 'english', difficulty: 2),
    Word(text: 'CAT', morseCode: '-.-. .- -', category: 'english', difficulty: 2),
    Word(text: 'SUN', morseCode: '... ..- -.', category: 'english', difficulty: 2),
    Word(text: 'RUN', morseCode: '.-. ..- -.', category: 'english', difficulty: 2),
    Word(text: 'EAT', morseCode: '. .- -', category: 'english', difficulty: 2),
    Word(text: 'FAR', morseCode: '..-. .- .-.', category: 'english', difficulty: 2),
    Word(text: 'BIG', morseCode: '-... .. --.', category: 'english', difficulty: 2),
    Word(text: 'RED', morseCode: '.-. . -..', category: 'english', difficulty: 2),
    Word(text: 'TOP', morseCode: '- --- .--.', category: 'english', difficulty: 2),
    Word(text: 'COW', morseCode: '-.-. --- .--', category: 'english', difficulty: 2),
    Word(text: 'PEN', morseCode: '.--. . -.', category: 'english', difficulty: 2),
    Word(text: 'CUP', morseCode: '-.-. ..- .--.', category: 'english', difficulty: 2),
    Word(text: 'BUS', morseCode: '-... ..- ...', category: 'english', difficulty: 2),
    Word(text: 'BED', morseCode: '-... . -..', category: 'english', difficulty: 2),
    Word(text: 'FAN', morseCode: '..-. .- -.', category: 'english', difficulty: 2),
    Word(text: 'MAP', morseCode: '-- .- .--.', category: 'english', difficulty: 2),
    Word(text: 'HAT', morseCode: '.... .- -', category: 'english', difficulty: 2),
    Word(text: 'LEG', morseCode: '.-.. . --.', category: 'english', difficulty: 2),
    Word(text: 'ARM', morseCode: '.- .-. --', category: 'english', difficulty: 2),
    Word(text: 'EYE', morseCode: '. -.-- .', category: 'english', difficulty: 2),
    Word(text: 'EAR', morseCode: '. .- .-.', category: 'english', difficulty: 2),
    // Numbers (10)
    Word(text: '1', morseCode: '.----', category: 'number', difficulty: 1),
    Word(text: '2', morseCode: '..---', category: 'number', difficulty: 1),
    Word(text: '3', morseCode: '...--', category: 'number', difficulty: 1),
    Word(text: '4', morseCode: '....-', category: 'number', difficulty: 1),
    Word(text: '5', morseCode: '.....', category: 'number', difficulty: 1),
    Word(text: '6', morseCode: '-....', category: 'number', difficulty: 1),
    Word(text: '7', morseCode: '--...', category: 'number', difficulty: 1),
    Word(text: '8', morseCode: '---..', category: 'number', difficulty: 1),
    Word(text: '9', morseCode: '----.', category: 'number', difficulty: 1),
    Word(text: '0', morseCode: '-----', category: 'number', difficulty: 1),
    // Common abbreviations (10)
    Word(text: 'SOS', morseCode: '... --- ...', category: 'abbrev', difficulty: 2),
    Word(text: 'RPT', morseCode: '.-. .--. -', category: 'abbrev', difficulty: 2),
    Word(text: 'MSG', morseCode: '-- ... --.', category: 'abbrev', difficulty: 2),
    Word(text: 'RST', morseCode: '.-. ... -', category: 'abbrev', difficulty: 2),
    Word(text: 'ANT', morseCode: '.- -. -', category: 'abbrev', difficulty: 2),
    Word(text: 'PWR', morseCode: '.--. .-- .-.', category: 'abbrev', difficulty: 2),
    Word(text: 'SIG', morseCode: '... .. --.', category: 'abbrev', difficulty: 2),
    Word(text: 'QSY', morseCode: '--.- ... -.--', category: 'abbrev', difficulty: 3),
    Word(text: 'QRX', morseCode: '--.- .-. -..-', category: 'abbrev', difficulty: 3),
    Word(text: 'QSL', morseCode: '--.- ... .-..', category: 'abbrev', difficulty: 3),
  ];

  List<Word> getWords({int? maxDifficulty, int? limit}) {
    var words = List<Word>.from(_commonWords);

    if (maxDifficulty != null) {
      words = words.where((w) => w.difficulty <= maxDifficulty).toList();
    }

    if (limit != null && words.length > limit) {
      words = words.take(limit).toList();
    }

    return words;
  }

  List<Word> getWordsByCategory(String category) {
    return _commonWords.where((w) => w.category == category).toList();
  }

  List<String> get categories => _commonWords.map((w) => w.category).toSet().toList();

  Word getRandomWord({int? maxDifficulty}) {
    var words = List<Word>.from(_commonWords);
    if (maxDifficulty != null) {
      words = words.where((w) => w.difficulty <= maxDifficulty).toList();
    }
    words.shuffle();
    return words.first;
  }
}
