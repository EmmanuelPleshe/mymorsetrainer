import 'package:flutter/material.dart';
import '../../domain/koch/qso_service.dart';
import '../../data/models/word.dart';

class QSOPracticeScreen extends StatefulWidget {
  const QSOPracticeScreen({super.key});

  @override
  State<QSOPracticeScreen> createState() => _QSOPracticeScreenState();
}

class _QSOPracticeScreenState extends State<QSOPracticeScreen> {
  final QSOService _qsoService = QSOService();
  late List<QSOPhrase> _phrases;
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _phrases = _qsoService.getPhrases(limit: 20);
    _phrases.shuffle();
  }

  void _nextPhrase() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _phrases.length;
      _showAnswer = false;
    });
  }

  void _revealAnswer() {
    setState(() {
      _showAnswer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phrases.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('QSO Practice')),
        body: const Center(child: Text('No phrases available.')),
      );
    }

    final currentPhrase = _phrases[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QSO Phrases'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (category) {
              setState(() {
                _phrases = _qsoService.getPhrases(category: category, limit: 20);
                _phrases.shuffle();
                _currentIndex = 0;
                _showAnswer = false;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Phrases')),
              const PopupMenuDivider(),
              ..._qsoService.categories.map((c) => PopupMenuItem(
                value: c,
                child: Text(c[0].toUpperCase() + c.substring(1)),
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _phrases.shuffle();
                _currentIndex = 0;
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
              'Tap to hear the QSO phrase',
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
                  const Icon(Icons.record_voice_over, size: 64, color: Colors.purple),
                  const SizedBox(height: 16),
                  Text(
                    _showAnswer ? currentPhrase.text : '???',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_showAnswer)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      currentPhrase.meaning,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${currentPhrase.category}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _revealAnswer,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show Meaning'),
                ),
                FilledButton.icon(
                  onPressed: _nextPhrase,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Phrase ${_currentIndex + 1} of ${_phrases.length}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}