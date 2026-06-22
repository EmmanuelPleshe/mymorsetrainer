import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/practice_session_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../core/audio/audio_playback_service.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/morse_code_coordinator.dart';
import '../../core/audio/morse_code_mapper.dart';
import '../../core/input/keyboard_input_handler.dart';
import '../../core/input/morse_command_handler.dart';
import '../../core/logging/logger.dart';
import '../../core/logging/log_constants.dart';
import '../../data/repositories/user_progress_repository.dart';
import '../widgets/home_app_bar.dart';

class PracticeScreen extends StatefulWidget {
  final AudioService? audioService;
  final MorseCodeCoordinator? coordinator;

  const PracticeScreen({super.key, this.audioService, this.coordinator});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final AudioService _audioService;
  late final MorseCodeCoordinator _coordinator;
  KeyboardKeyerHandler? _keyerHandler;
  MorseCommandHandler? _commandHandler;
  String _currentPattern = '';
  String _lastDecodedChar = '';
  bool _feedbackHandled = false;
  int _selectedLevel = 1;
  bool _isAudioPlaying = false;
  bool _countdownActive = false;
  int _countdownSeconds = 0;
  bool _screenFlash = false;
  int _userLevel = 1;

  // Event-based key tracking
  DateTime? _keyDownStarted;
  DateTime? _lastUpTime;
  DateTime? _lastKeyDownTime;
  static const _debounceMs = 50;
  static const _minDurationMs = 30;

  @override
  void initState() {
    super.initState();
    _audioService = widget.audioService ?? AudioPlaybackService();
    _coordinator = widget.coordinator ??
        MorseCodeCoordinator(context.read<MorseCodeMapper>(), _audioService);
    _initAudio();
    _loadUserLevel();
  }

  Future<void> _loadUserLevel() async {
    final level = await UserProgressRepository().getCurrentLevel();
    if (mounted) {
      setState(() {
        _userLevel = level;
      });
    }
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
      timingEngine: _audioService.timingEngine,
      onPatternComplete: (pattern) {
        final decoded = _decodePattern(pattern);
        Logger().debug(LogCategory.ui, 'Submitting "$pattern" = "$decoded"');
        _keyerHandler?.clearPattern();  // Clear handler pattern on submit
        context.read<PracticeSessionBloc>().add(SubmitMorsePattern(pattern));
        setState(() {
          _currentPattern = '';
          _lastDecodedChar = decoded;
        });
      },
      onKeyDown: () async {
        Logger().debug(LogCategory.audio, 'keyerDown');
        await _audioService.keyerDown();
        // Screen flash on key down
        final settingsState = context.read<SettingsBloc>().state;
        if (settingsState is SettingsLoaded && settingsState.settings.enableScreenFlash) {
          setState(() => _screenFlash = true);
        }
      },
      onKeyUp: () async {
        Logger().debug(LogCategory.audio, 'keyerUp');
        await _audioService.keyerUp();
        // Screen flash off on key up
        setState(() => _screenFlash = false);
      },
    );
    _commandHandler = MorseCommandHandler(
      timingEngine: _audioService.timingEngine,
      onCommand: (cmd) => _handleCommand(cmd),
    );
  }

  void _handleCommand(String cmd) {
    Logger().info(LogCategory.ui, 'Morse command: $cmd');
    final state = context.read<PracticeSessionBloc>().state;
    if (state is PracticeSessionInitial) {
      switch (cmd) {
        case 'sp':
          context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel));
          break;
        case 'up':
          if (_selectedLevel < 20) setState(() => _selectedLevel++);
          break;
        case 'do':
          if (_selectedLevel > 1) setState(() => _selectedLevel--);
          break;
      }
    } else if (state is PracticeSessionComplete) {
      switch (cmd) {
        case 're':
          context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel));
          break;
        case 'ne':
          if (_selectedLevel < 20) {
            context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel + 1));
          }
          break;
        case 'ex':
          context.read<PracticeSessionBloc>().add(const EndSession());
          break;
      }
    }
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

    // Ignore key input while audio is playing
    if (_isAudioPlaying) return true;

    // Debug: log all space key events
    debugPrint('KEY EVENT: ${event.runtimeType}');

    // Ignore repeat events entirely - we only care about first down and final up
    if (event is KeyRepeatEvent) {
      debugPrint('  -> REPEAT (ignored)');
      return true;
    }

    final now = DateTime.now();

    // Determine which handler to use based on bloc state
    final blocState = context.read<PracticeSessionBloc>().state;
    final useCommandHandler = blocState is! PracticeSessionActive;

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
      if (useCommandHandler) {
        _commandHandler?.handleKeyDown();
      } else {
        _keyerHandler?.handleKeyDown();
      }
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
          if (useCommandHandler) {
            _commandHandler?.handleKeyUp(duration);
          } else {
            _keyerHandler?.handleKeyUp(duration);
            setState(() {
              _currentPattern = _keyerHandler?.currentPattern ?? '';
            });
          }
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
    setState(() => _isAudioPlaying = true);

    // Get settings for screen flash
    final settingsState = context.read<SettingsBloc>().state;
    bool enableFlash = false;
    if (settingsState is SettingsLoaded) {
      enableFlash = settingsState.settings.enableScreenFlash;
    }

    void Function(bool)? flashCallback;
    if (enableFlash) {
      flashCallback = (on) {
        if (mounted) setState(() => _screenFlash = on);
      };
    }

    _coordinator.playCharacters(character, onFlash: flashCallback).then((_) {
      if (mounted) {
        setState(() {
          _isAudioPlaying = false;
          _countdownActive = false;
        });
      }
    });

    // Start countdown immediately - user can key during playback
    if (mounted) {
      setState(() {
        _countdownActive = false; // No delay - key immediately
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        title: 'Practice',
        showNavIcons: true,
        onHomePressed: () async {
          await _audioService.keyerUp();
          _keyerHandler?.clearPattern();
        },
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
              // New character or retry - clear feedback and keyer pattern
              setState(() {
                _lastDecodedChar = '';
                _feedbackHandled = false;
              });
              _keyerHandler?.clearPattern();
              _commandHandler?.flush();
              final char = state.currentCharacter;
              if (char != null && !state.isRetrying) {
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Icon(Icons.radio, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Morse Code Trainer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Learn morse code fast with Koch method', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          const Text('Select Level', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _selectedLevel > 1 ? () => setState(() => _selectedLevel--) : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(8)),
                child: Text('Level $_selectedLevel', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _selectedLevel < 20 ? () => setState(() => _selectedLevel++) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Characters: ${_selectedLevel * 2}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel)),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Practice'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _userLevel >= 2
                ? () => Navigator.pushNamed(context, '/word-practice')
                : null,
            icon: const Icon(Icons.format_quote),
            label: const Text('Common Words'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: _userLevel >= 2 ? null : Colors.grey.shade300,
            ),
          ),
          if (_userLevel < 2)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Unlock at Level 2',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, PracticeSessionActive state) {
    final character = state.currentCharacter;
    if (character == null) return const Center(child: Text('No more characters'));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 50),
      color: _screenFlash ? Colors.white : null,
      child: SingleChildScrollView(
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
            const SizedBox(height: 16),
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isAudioPlaying ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAudioPlaying ? Icons.volume_up : Icons.keyboard,
                    size: 18,
                    color: _isAudioPlaying ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAudioPlaying ? 'Listen...' : 'Ready to key!',
                    style: TextStyle(
                      color: _isAudioPlaying ? Colors.orange.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.lastAnswerCorrect == null)
              _buildKeyerInputArea(context)
            else
              _buildFeedbackArea(context, state),
          ],
        ),
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
              style: TextStyle(fontSize: 32, fontFamily: 'monospace', color: _currentPattern.isEmpty ? Colors.grey : Colors.white),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
            const SizedBox(height: 16),
            const Text('Hold for dash, tap for dot', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _playCharacterAudio(
              (context.read<PracticeSessionBloc>().state as PracticeSessionActive).currentCharacter?.symbol ?? '',
            ),
            icon: const Icon(Icons.volume_up),
            label: const Text('Replay'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await _audioService.keyerUp();
              _keyerHandler?.clearPattern();
              if (mounted) {
                context.read<PracticeSessionBloc>().add(const EndSession());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.stop),
            label: const Text('End'),
          ),
        ],
      ),
    ],
  );

  Widget _buildFeedbackArea(BuildContext context, PracticeSessionActive state) {
    final isCorrect = state.lastAnswerCorrect!;

    // Only play feedback sound once per state (if sound effects enabled)
    if (!_feedbackHandled) {
      _feedbackHandled = true;
      if (isCorrect) {
        final settingsState = context.read<SettingsBloc>().state;
        if (settingsState is SettingsLoaded && settingsState.settings.enableSoundEffects) {
          _audioService.playCorrectFeedback();
        }
      }
    }

    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.error,
          size: 64,
          color: isCorrect ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          isCorrect ? 'Correct!' : 'Try again',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Answer: ${state.currentCharacter?.symbol ?? ''}',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel)),
              icon: const Icon(Icons.replay),
              label: const Text('Repeat'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _selectedLevel < 20
                ? () => context.read<PracticeSessionBloc>().add(StartSession(_selectedLevel + 1))
                : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Keep Going'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<PracticeSessionBloc>().add(const EndSession()),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Exit'),
            ),
          ],
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