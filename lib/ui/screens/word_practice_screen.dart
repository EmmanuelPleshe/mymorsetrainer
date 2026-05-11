import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/morse_code_service.dart';
import '../../core/input/keyboard_input_handler.dart';
import '../../data/models/word.dart';
import '../../domain/koch/word_practice_service.dart';
import '../widgets/home_app_bar.dart';

enum WordPhase { listening, keying, feedback }

class WordPracticeScreen extends StatefulWidget {
  final AudioService? audioService;

  const WordPracticeScreen({super.key, this.audioService});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  final WordPracticeService _wordService = WordPracticeService();
  late final AudioService _audioService;
  late List<Word> _words;
  int _currentIndex = 0;
  WordPhase _phase = WordPhase.listening;
  bool _isAudioPlaying = false;
  String _currentPattern = '';
  bool _isCorrect = false;
  bool _isReplaying = false;
  KeyboardKeyerHandler? _keyerHandler;
  DateTime? _keyDownTime;
  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();
    _audioService = widget.audioService ?? AudioPlaybackService();
    _words = _wordService.getWords(limit: 20);
    _words.shuffle();
    _initKeyer();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _playCurrentWord();
  }

  void _initKeyer() {
    _keyerHandler = KeyboardKeyerHandler(
      dotDurationMs: _audioService.dotDurationMs,
      dashDurationMs: _audioService.dashDurationMs,
      interWordThresholdMs: _audioService.dotDurationMs * 9,
      onPatternComplete: (pattern) {
        // Auto-submit on word boundary (long pause)
        _submitPattern();
      },
      onKeyDown: () async {
        if (_phase != WordPhase.keying || _isAudioPlaying) return;
        await _audioService.keyerDown();
      },
      onKeyUp: () async {
        await _audioService.keyerUp();
      },
    );
  }

  Future<void> _playCurrentWord() async {
    if (_currentIndex >= _words.length) return;
    final word = _words[_currentIndex];

    setState(() {
      _phase = WordPhase.listening;
      _isAudioPlaying = true;
      _currentPattern = '';
    });

    await _audioService.initialize();
    await _audioService.playWord(word.text);

    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
        _phase = WordPhase.keying;
      });
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (_phase != WordPhase.keying || _isAudioPlaying) return false;
    if (event.physicalKey != PhysicalKeyboardKey.space) return false;
    if (event is KeyRepeatEvent) return true;

    if (event is KeyDownEvent) {
      _keyDownTime = DateTime.now();
      _keyerHandler?.handleKeyDown();
      return true;
    } else if (event is KeyUpEvent) {
      if (_keyDownTime != null) {
        final duration = DateTime.now().difference(_keyDownTime!).inMilliseconds;
        _keyDownTime = null;
        _keyerHandler?.handleKeyUp(duration);
        setState(() {
          _currentPattern = _keyerHandler?.currentPattern ?? '';
        });
      }
      return true;
    }
    return false;
  }

  void _submitPattern() {
    if (_phase != WordPhase.keying) return;
    final word = _words[_currentIndex];
    final targetPattern = word.morseCode.replaceAll(' ', '');
    final submittedPattern = _keyerHandler?.currentPattern ?? '';

    setState(() {
      _isCorrect = submittedPattern == targetPattern;
      _phase = WordPhase.feedback;
      _isReplaying = true;
    });

    _keyerHandler?.clearPattern();

    if (_isCorrect) {
      _audioService.playCorrectFeedback();
    }

    _replayFeedback(word);
  }

  Future<void> _replayFeedback(Word word) async {
    final originalWpm = _audioService.wpm;

    if (_isCorrect) {
      _audioService.setWpm(originalWpm * 0.8);
    }

    await _audioService.playWord(word.text);

    if (_isCorrect) {
      _audioService.setWpm(originalWpm);
    }

    if (mounted) {
      setState(() => _isReplaying = false);
    }

    if (_isCorrect) {
      _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _phase == WordPhase.feedback) {
          _nextWord();
        }
      });
    } else {
      if (mounted) {
        _nextWord();
      }
    }
  }

  void _nextWord() {
    _autoAdvanceTimer?.cancel();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _currentPattern = '';
      _isCorrect = false;
    });
    _playCurrentWord();
  }

  void _replayWord() {
    _autoAdvanceTimer?.cancel();
    _playCurrentWord();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _keyerHandler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: const HomeAppBar(title: 'Word Practice'),
        body: const Center(child: Text('No words available. Complete alphabet first.')),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: HomeAppBar(
        title: 'Word Practice',
        showNavIcons: true,
        onHomePressed: () async {
          _autoAdvanceTimer?.cancel();
          await _audioService.keyerUp();
          _keyerHandler?.clearPattern();
        },
        extraActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _words.shuffle();
                _currentIndex = 0;
                _phase = WordPhase.listening;
                _currentPattern = '';
              });
              _playCurrentWord();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPhaseIndicator(),
            const SizedBox(height: 32),
            _buildMainContent(currentWord),
            const SizedBox(height: 24),
            _buildPatternDisplay(),
            const Spacer(),
            _buildControls(currentWord),
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

  Widget _buildPhaseIndicator() {
    switch (_phase) {
      case WordPhase.listening:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Listen...',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      case WordPhase.keying:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Key the word!',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      case WordPhase.feedback:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _isCorrect ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.error,
                color: _isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct!' : 'Try again',
                style: TextStyle(
                  color: _isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildMainContent(Word word) {
    if (_phase == WordPhase.feedback) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              word.text,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              word.morseCode,
              style: const TextStyle(fontSize: 20, color: Colors.grey, fontFamily: 'monospace'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.volume_up, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            '???',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternDisplay() {
    if (_phase == WordPhase.listening) return const SizedBox.shrink();

    final display = _currentPattern.isEmpty
        ? (_phase == WordPhase.keying ? 'Hold SPACE to key' : '')
        : _currentPattern;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 32,
          fontFamily: 'monospace',
          color: _currentPattern.isEmpty ? Colors.grey : Colors.white,
        ),
      ),
    );
  }

  Widget _buildControls(Word word) {
    switch (_phase) {
      case WordPhase.listening:
        return const SizedBox.shrink();
      case WordPhase.keying:
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: _submitPattern,
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hold SPACE for dash, tap for dot',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        );
      case WordPhase.feedback:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _isReplaying ? null : _replayWord,
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
            ),
            FilledButton.icon(
              onPressed: _isReplaying ? null : _nextWord,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
            ),
          ],
        );
    }
  }
}
