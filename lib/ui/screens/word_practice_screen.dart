import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/koch/word_practice_service.dart';
import '../../data/models/word.dart';
import '../bloc/practice_session_bloc.dart';

class WordPracticeScreen extends StatefulWidget {
  const WordPracticeScreen({super.key});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  final WordPracticeService _wordService = WordPracticeService();
  late List<Word> _words;
  int _currentIndex = 0;
  String _feedback = '';
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _words = _wordService.getWords(limit: 20);
    _words.shuffle();
  }

  void _nextWord() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _feedback = '';
      _showAnswer = false;
    });
  }

  void _revealAnswer() {
    setState(() {
      _showAnswer = true;
      _feedback = 'Answer: ${_words[_currentIndex].text}';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Word Practice')),
        body: const Center(child: Text('No words available. Complete alphabet first.')),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _words.shuffle();
                _currentIndex = 0;
                _feedback = '';
                _showAnswer = false;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tap to hear the word',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.volume_up, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    _showAnswer ? currentWord.text : '???',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_feedback.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _showAnswer ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _feedback,
                  style: TextStyle(
                    fontSize: 16,
                    color: _showAnswer ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _revealAnswer,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show Answer'),
                ),
                FilledButton.icon(
                  onPressed: _nextWord,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Word ${_currentIndex + 1} of ${_words.length}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}