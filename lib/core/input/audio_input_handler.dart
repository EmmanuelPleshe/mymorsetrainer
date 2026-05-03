import 'dart:async';

typedef VoidCallback = void Function();
typedef KeyerCallback = void Function(String morsePattern);

class AudioKeyerHandler {
  final KeyerCallback onPatternComplete;
  final VoidCallback? onKeyDown;
  final VoidCallback? onKeyUp;
  final int dotDurationMs;
  final int dashDurationMs;

  String _pattern = '';
  Timer? _autoSubmitTimer;
  bool _isKeyDown = false;
  int _startTimeMs = 0;

  static final Map<String, String> _morseToChar = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z', '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7', '---..': '8',
    '----.': '9', '.-.-.-': '.', '--..--': ',', '..--..': '?', '-..-.': '/',
  };

  AudioKeyerHandler({
    required this.onPatternComplete,
    this.onKeyDown,
    this.onKeyUp,
    required this.dotDurationMs,
    required this.dashDurationMs,
  });

  void handleToneDetected() {
    if (_isKeyDown) return;
    _isKeyDown = true;
    _startTimeMs = DateTime.now().millisecondsSinceEpoch;
    onKeyDown?.call();
  }

  void handleToneStopped() {
    if (!_isKeyDown) return;
    _isKeyDown = false;
    final durationMs = DateTime.now().millisecondsSinceEpoch - _startTimeMs;
    onKeyUp?.call();

    final threshold = dotDurationMs * 2;
    final symbol = durationMs >= threshold ? '-' : '.';
    _pattern += symbol;

    _scheduleAutoSubmit();
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
        final pattern = _pattern;
        onPatternComplete(pattern);
        _pattern = '';
      }
    });
  }

  void submitNow() {
    _autoSubmitTimer?.cancel();
    if (_pattern.isNotEmpty && _morseToChar.containsKey(_pattern)) {
      final pattern = _pattern;
      onPatternComplete(pattern);
      _pattern = '';
    }
  }

  String get currentPattern => _pattern;

  void clearPattern() {
    _autoSubmitTimer?.cancel();
    _pattern = '';
    _isKeyDown = false;
  }

  void dispose() {
    _autoSubmitTimer?.cancel();
  }
}