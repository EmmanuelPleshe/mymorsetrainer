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