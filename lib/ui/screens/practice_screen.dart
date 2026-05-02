import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../core/audio/morse_code_service.dart';
import '../../core/input/keyboard_input_handler.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final AudioPlaybackService _audioService = AudioPlaybackService();
  KeyboardKeyerHandler? _keyerHandler;
  String _currentPattern = '';
  String _lastDecodedChar = '';

  // Event-based key tracking
  DateTime? _keyDownStarted;
  DateTime? _lastUpTime;
  DateTime? _lastKeyDownTime;
  static const _debounceMs = 50;
  static const _minDurationMs = 30;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioService.initialize();
    _applySettings();
    _initKeyer();
    if (mounted) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _audioService.dispose();
    super.dispose();
  }

  void _applySettings() {
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsLoaded) {
      final s = settingsState.settings;
      _audioService.setToneFrequency(s.toneFrequency);
      _audioService.setWpm(s.wpm);
      _audioService.setEffWpm(s.effWpm);
      _audioService.setExtraWordSpace(s.extraWordSpace);
      _audioService.setVolume(s.volume);
    }
  }

  void _initKeyer() {
    _keyerHandler = KeyboardKeyerHandler(
      dotDurationMs: _audioService.dotDurationMs,
      dashDurationMs: _audioService.dashDurationMs,
      onPatternComplete: (pattern) {
        final decoded = _decodePattern(pattern);
        print('SCREEN: Submitting "$pattern" = "$decoded"');
        context.read<PracticeSessionBloc>().add(SubmitMorsePattern(pattern));
        setState(() {
          _currentPattern = '';
          _lastDecodedChar = decoded;
        });
      },
      onKeyDown: () async {
        print('AUDIO: keyerDown');
        await _audioService.keyerDown();
      },
      onKeyUp: () async {
        print('AUDIO: keyerUp');
        await _audioService.keyerUp();
      },
    );
  }

  String _decodePattern(String pattern) {
    const _morseToChar = {
      '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
      '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
      '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
      '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
      '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
      '--..': 'Z', '-----': '0', '.----': '1', '..---': '2', '...--': '3',
      '....-': '4', '.....': '5', '-....': '6', '--...': '7', '---..': '8',
      '----.': '9', '.-.-.-': '.', '--..--': ',', '..--..': '?', '-..-.': '/',
    };
    return _morseToChar[pattern] ?? '?';
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Only handle space key
    if (event.physicalKey != PhysicalKeyboardKey.space) return false;

    // Debug: log all space key events
    debugPrint('KEY EVENT: ${event.runtimeType}');

    // Ignore repeat events entirely - we only care about first down and final up
    if (event is KeyRepeatEvent) {
      debugPrint('  -> REPEAT (ignored)');
      return true;
    }

    final now = DateTime.now();

    if (event is KeyDownEvent) {
      // Debounce: ignore if too soon after last key down (Linux ghost key bug)
      if (_lastKeyDownTime != null &&
          now.difference(_lastKeyDownTime!).inMilliseconds < _debounceMs) {
        debugPrint('  -> DEBOUNCED (ghost key down)');
        return true;
      }
      // Debounce: ignore second down that comes too soon after an up (Linux duplicate bug)
      if (_lastUpTime != null &&
          now.difference(_lastUpTime!).inMilliseconds < _debounceMs) {
        debugPrint('  -> DEBOUNCED (too soon after up)');
        return true;
      }
      _lastKeyDownTime = now;
      _keyDownStarted = now;
      debugPrint('  -> KEY DOWN, starting timer');
      _keyerHandler?.handleKeyDown();
      return true;
    }

    if (event is KeyUpEvent) {
      // Debounce: ignore an up that comes too soon after previous up
      if (_lastUpTime != null &&
          now.difference(_lastUpTime!).inMilliseconds < _debounceMs) {
        debugPrint('  -> DEBOUNCED (dup up)');
        return true;
      }
      _lastUpTime = now;

      if (_keyDownStarted != null) {
        final duration = now.difference(_keyDownStarted!).inMilliseconds;
        debugPrint('  -> KEY UP after $duration ms');
        // Sanity check: ignore glitches shorter than 30ms
        if (duration >= _minDurationMs) {
          _keyerHandler?.handleKeyUp(duration);
          setState(() {
            _currentPattern = _keyerHandler?.currentPattern ?? '';
          });
        } else {
          debugPrint('  -> IGNORED (too short: $duration ms)');
        }
      }
      _keyDownStarted = null;
      return true;
    }

    return false;
  }

  Future<void> _playCharacterAudio(String character) async {
    await _audioService.playCharacter(character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
        ],
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            _applySettings();
          }
        },
        child: BlocConsumer<PracticeSessionBloc, PracticeSessionState>(
          listener: (context, state) {
            if (state is PracticeSessionActive && state.lastAnswerCorrect == null) {
              // New character - clear feedback and play audio
              setState(() => _lastDecodedChar = '');
              final char = state.currentCharacter;
              if (char != null) {
                _playCharacterAudio(char.symbol);
              }
            }
            if (state is PracticeSessionComplete) {
              _showCompletionDialog(context, state);
            }
          },
          builder: (context, state) {
            if (state is PracticeSessionInitial) {
              return _buildStartScreen(context);
            }
            if (state is PracticeSessionLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PracticeSessionActive) {
              return _buildActiveSession(context, state);
            }
            if (state is PracticeSessionComplete) {
              return _buildCompletionSummary(context, state);
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radio, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Morse Code Trainer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Learn morse code with the Koch method', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<PracticeSessionBloc>().add(const StartSession(1)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Practice'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, PracticeSessionActive state) {
    final character = state.currentCharacter;
    if (character == null) return const Center(child: Text('No more characters'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(value: state.currentIndex / state.characters.length),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Correct', '${state.correctCount}'),
              _buildStat('Accuracy', '${(state.accuracy * 100).toStringAsFixed(1)}%'),
              _buildStat('Streak', '${state.currentStreak}'),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getFeedbackColor(state.lastAnswerCorrect),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(character.symbol, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (state.lastAnswerCorrect != null) ...[
                    const SizedBox(height: 8),
                    Text(character.morsePattern, style: const TextStyle(fontSize: 24, color: Colors.white70)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (state.lastAnswerCorrect == null)
            _buildKeyerInputArea(context)
          else
            _buildFeedbackArea(context, state),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );

  Color _getFeedbackColor(bool? isCorrect) {
    if (isCorrect == null) return Colors.blue;
    return isCorrect ? Colors.green : Colors.red;
  }

  Widget _buildKeyerInputArea(BuildContext context) => Column(
    children: [
      const Text('Key the character you heard:', style: TextStyle(fontSize: 18)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(
              _currentPattern.isEmpty ? (_lastDecodedChar.isEmpty ? 'Hold SPACE to key' : 'Submitted: $_lastDecodedChar') : _currentPattern,
              style: TextStyle(fontSize: 32, fontFamily: 'monospace', color: _currentPattern.isEmpty ? Colors.grey : Colors.black),
            ),
            const SizedBox(height: 16),
            const Text('Hold for dash, tap for dot', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () => _playCharacterAudio(
          (context.read<PracticeSessionBloc>().state as PracticeSessionActive).currentCharacter?.symbol ?? '',
        ),
        icon: const Icon(Icons.volume_up),
        label: const Text('Replay Sound'),
      ),
    ],
  );

  Widget _buildFeedbackArea(BuildContext context, PracticeSessionActive state) {
    final isCorrect = state.lastAnswerCorrect!;
    if (isCorrect) _audioService.playCorrectFeedback();
    if (!isCorrect) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _playCharacterAudio(state.currentCharacter?.symbol ?? '');
      });
    }
    return Column(
      children: [
        Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red, size: 64),
        const SizedBox(height: 16),
        Text(isCorrect ? 'Correct!' : 'Wrong!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
        if (state.showUnlockNotification) ...[
          const SizedBox(height: 16),
          const Icon(Icons.lock_open, color: Colors.orange, size: 48),
          const Text('New character unlocked!', style: TextStyle(fontSize: 18, color: Colors.orange)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.read<PracticeSessionBloc>().add(const NextCharacter()),
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildCompletionSummary(BuildContext context, PracticeSessionComplete state) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.celebration, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text('Session Complete!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('${state.correctCount} / ${state.totalQuestions} correct', style: const TextStyle(fontSize: 20)),
        Text('Accuracy: ${(state.accuracy * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18)),
        if (state.unlockedNextLevel) const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text('Next level unlocked!', style: TextStyle(fontSize: 18, color: Colors.orange)),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => context.read<PracticeSessionBloc>().add(const StartSession(1)),
          icon: const Icon(Icons.replay),
          label: const Text('Practice Again'),
        ),
      ],
    ),
  );

  void _showCompletionDialog(BuildContext context, PracticeSessionComplete state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text('You got ${state.correctCount} out of ${state.totalQuestions} correct (${(state.accuracy * 100).toStringAsFixed(1)}%)'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}