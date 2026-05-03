import '../../data/models/word.dart';

class QSOService {
  static const List<QSOPhrase> _qsoPhrases = [
    QSOPhrase(text: 'CQ CQ CQ DE K1ABC K', meaning: 'Calling any station, this is K1ABC', category: 'calling'),
    QSOPhrase(text: 'K1ABC DE W2XYZ K', meaning: 'W2XYZ replies to K1ABC', category: 'reply'),
    QSOPhrase(text: 'W2XYZ DE K1ABC R TU', meaning: 'K1ABC acknowledges W2XYZ, thank you', category: 'exchange'),
    QSOPhrase(text: 'QTH IS BOSTON MA', meaning: 'My location is Boston, Massachusetts', category: 'info'),
    QSOPhrase(text: 'RST IS 599 599', meaning: 'Readability 5, Strength 9, Tone 9 - excellent', category: 'exchange'),
    QSOPhrase(text: 'QSB?', meaning: 'Are you having trouble copying?', category: 'info'),
    QSOPhrase(text: 'QRM?', meaning: 'Is there interference?', category: 'info'),
    QSOPhrase(text: 'QRN?', meaning: 'Is there static/noise?', category: 'info'),
    QSOPhrase(text: 'HW CPY?', meaning: 'How do you copy?', category: 'info'),
    QSOPhrase(text: 'BK', meaning: 'Break - I want to transmit', category: 'operational'),
    QSOPhrase(text: '73 ES 88', meaning: 'Best regards and love', category: 'closing'),
    QSOPhrase(text: 'CL', meaning: 'Closing station', category: 'closing'),
    QSOPhrase(text: 'PSE QRS', meaning: 'Please send slower', category: 'request'),
    QSOPhrase(text: 'AGN', meaning: 'Again', category: 'operational'),
    QSOPhrase(text: 'DB', meaning: 'Bad', category: 'operational'),
  ];

  List<QSOPhrase> getPhrases({String? category, int? limit}) {
    var phrases = _qsoPhrases;

    if (category != null) {
      phrases = phrases.where((p) => p.category == category).toList();
    }

    if (limit != null && phrases.length > limit) {
      phrases = phrases.take(limit).toList();
    }

    return phrases;
  }

  List<String> get categories => _qsoPhrases.map((p) => p.category).toSet().toList();

  QSOPhrase getRandomPhrase({String? category}) {
    var phrases = _qsoPhrases;
    if (category != null) {
      phrases = phrases.where((p) => p.category == category).toList();
    }
    phrases.shuffle();
    return phrases.first;
  }

  String phraseToMorse(String text) {
    return Word.textToMorse(text);
  }
}