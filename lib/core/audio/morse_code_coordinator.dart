import 'audio_service.dart';
import 'morse_code_mapper.dart';

/// Coordinates sequencing of Morse code playback.
///
/// Given an input string, [MorseCodeCoordinator] splits it into words and
/// characters, looks up each character's pattern via [MorseCodeMapper], and
/// drives an [AudioService] through the primitive `playDot`/`playDash` and
/// pause methods. This keeps the audio service focused on tone generation
/// while all character/word assembly logic lives here.
///
/// Prosigns (multi-character entries such as 'AR' or 'SOS') are detected
/// with a longest-first lookahead and played as a single continuous unit —
/// only intra-character pauses separate their symbols, and no
/// inter-character pause follows them.
class MorseCodeCoordinator {
  final MorseCodeMapper _mapper;
  final AudioService _audioService;
  bool _isPlaying = false;
  bool _isCancelled = false;

  MorseCodeCoordinator(this._mapper, this._audioService);

  /// Whether a [playCharacters] call is currently in progress.
  bool get isPlaying => _isPlaying;

  /// Plays the Morse representation of [input].
  ///
  /// [input] is split into words on spaces. Each word is split into
  /// characters; each character's pattern is looked up via the mapper and
  /// played symbol-by-symbol with appropriate intra-character, inter-character
  /// and inter-word pauses in between.
  ///
  /// [onFlash], if provided, is invoked with `true` immediately before a
  /// dot/dash is played and `false` during the pause that follows it. This
  /// lets the UI drive a screen-flash effect in lockstep with the audio.
  ///
  /// Unknown characters (no pattern in the mapper) are skipped. Spaces are
  /// treated as word separators only, not as characters.
  ///
  /// Call [stop] to cancel playback; the coordinator checks the cancellation
  /// flag between symbols and pauses and breaks out of the loop as soon as
  /// it is set, also calling [AudioService.keyerUp] to kill any in-flight tone.
  Future<void> playCharacters(String input, {void Function(bool)? onFlash}) async {
    _isCancelled = false;
    _isPlaying = true;
    try {
      final words = input.split(' ');
      for (int w = 0; w < words.length; w++) {
        final word = words[w];
        if (word.isEmpty) continue;

        final characters = word.toUpperCase().split('');
        int c = 0;
        while (c < characters.length) {
          // Try to match a 3-char prosign (SOS, CL) then a 2-char prosign
          // (AR, BT, SK, KN, AS, CT, VE) at the current position.
          String? pattern;
          bool isProsignMatch = false;
          int consumed = 1;

          if (c + 3 <= characters.length) {
            final three = characters.sublist(c, c + 3).join();
            if (_mapper.isProsign(three)) {
              final p = _mapper.getMorsePattern(three);
              if (p != null) {
                pattern = p;
                isProsignMatch = true;
                consumed = 3;
              }
            }
          }
          if (pattern == null && c + 2 <= characters.length) {
            final two = characters.sublist(c, c + 2).join();
            if (_mapper.isProsign(two)) {
              final p = _mapper.getMorsePattern(two);
              if (p != null) {
                pattern = p;
                isProsignMatch = true;
                consumed = 2;
              }
            }
          }
          if (pattern == null) {
            final p = _mapper.getMorsePattern(characters[c]);
            if (p == null) {
              c += 1;
              continue;
            }
            pattern = p;
          }

          for (int s = 0; s < pattern.length; s++) {
            if (_isCancelled) {
              await _audioService.keyerUp();
              return;
            }
            final symbol = pattern[s];
            onFlash?.call(true);
            if (symbol == '.') {
              await _audioService.playDot();
            } else if (symbol == '-') {
              await _audioService.playDash();
            }

            // Pause between symbols within a character.
            if (s < pattern.length - 1) {
              if (_isCancelled) {
                await _audioService.keyerUp();
                return;
              }
              onFlash?.call(false);
              await _audioService.intraCharacterPause();
            } else {
              onFlash?.call(false);
            }
          }

          // Inter-character pause after each regular character. Prosigns
          // are a single logical unit and do NOT receive this pause.
          if (!isProsignMatch) {
            if (_isCancelled) {
              await _audioService.keyerUp();
              return;
            }
            await _audioService.interCharacterPause();
          }
          c += consumed;
        }

        // Inter-word pause between words (not after the last word).
        if (w < words.length - 1) {
          if (_isCancelled) {
            await _audioService.keyerUp();
            return;
          }
          await _audioService.interWordPause();
        }
      }
    } finally {
      _isPlaying = false;
    }
  }

  /// Requests cancellation of any in-progress [playCharacters] call.
  ///
  /// The cancellation flag is checked between symbols and pauses; when set,
  /// the coordinator breaks out of its loop and calls
  /// [AudioService.keyerUp] to silence any in-flight tone. The flag is reset
  /// to `false` at the start of the next [playCharacters] call.
  void stop() {
    _isCancelled = true;
  }
}