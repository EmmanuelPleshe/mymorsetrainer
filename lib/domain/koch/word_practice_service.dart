import '../../data/models/word.dart';

class WordPracticeService {
  static const List<Word> _commonWords = [
    Word(text: 'CQ', morseCode: '-.-. --.-', category: 'callsign', difficulty: 1),
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
  ];

  List<Word> getWords({int? maxDifficulty, int? limit}) {
    var words = _commonWords;

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
    var words = _commonWords;
    if (maxDifficulty != null) {
      words = words.where((w) => w.difficulty <= maxDifficulty).toList();
    }
    words.shuffle();
    return words.first;
  }
}