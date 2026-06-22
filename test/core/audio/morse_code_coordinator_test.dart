import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/audio/audio_service.dart';
import 'package:morse_trainer/core/audio/morse_code_coordinator.dart';
import 'package:morse_trainer/core/audio/morse_code_mapper.dart';
import 'package:morse_trainer/core/timing/morse_timing_engine.dart';

/// Records every call made to it so tests can assert on the sequence of
/// primitives the coordinator drives.
class _RecordingAudioService implements AudioService {
  final List<String> calls = [];

  @override
  Future<void> playDot() async => calls.add('playDot');

  @override
  Future<void> playDash() async => calls.add('playDash');

  @override
  Future<void> intraCharacterPause() async => calls.add('intraCharacterPause');

  @override
  Future<void> interCharacterPause() async => calls.add('interCharacterPause');

  @override
  Future<void> interWordPause() async => calls.add('interWordPause');

  @override
  Future<void> keyerDown() async => calls.add('keyerDown');

  @override
  Future<void> keyerUp() async => calls.add('keyerUp');

  @override
  Future<void> playCorrectFeedback() async => calls.add('playCorrectFeedback');

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  // --- configuration / timing stubs (not exercised by coordinator tests) ---

  @override
  double get toneFrequency => 600.0;

  @override
  double get wpm => 20.0;

  @override
  double get effWpm => 20.0;

  @override
  double get volume => 0.5;

  @override
  double get extraWordSpace => 0.0;

  @override
  int get unitMs => 60;

  @override
  int get dotDurationMs => 60;

  @override
  int get dashDurationMs => 180;

  @override
  int get intraCharacterSpaceMs => 60;

  @override
  int get interCharacterSpaceMs => 180;

  @override
  int get interWordSpaceMs => 420;

  @override
  MorseTimingEngine get timingEngine =>
      MorseTimingEngine(wpm: 20, effWpm: 20);

  @override
  void setToneFrequency(double frequency) {}

  @override
  void setWpm(double wpm) {}

  @override
  void setEffWpm(double effWpm) {}

  @override
  void setExtraWordSpace(double seconds) {}

  @override
  void setVolume(double volume) {}
}

void main() {
  late MorseCodeMapper mapper;
  late _RecordingAudioService audio;
  late MorseCodeCoordinator coordinator;

  setUp(() {
    mapper = MorseCodeMapper();
    audio = _RecordingAudioService();
    coordinator = MorseCodeCoordinator(mapper, audio);
  });

  group('MorseCodeCoordinator', () {
    test('single character A produces dot, intra pause, dash, inter pause',
        () async {
      // A = '.-'
      await coordinator.playCharacters('A');

      expect(audio.calls, [
        'playDot',
        'intraCharacterPause',
        'playDash',
        'interCharacterPause',
      ]);
    });

    test('single character E (just dot) produces dot then inter pause',
        () async {
      // E = '.'
      await coordinator.playCharacters('E');

      expect(audio.calls, ['playDot', 'interCharacterPause']);
    });

    test('multi-character word HELLO produces correct sequence', () async {
      // H = '....', E = '.', L = '.-..', L = '.-..', O = '---'
      await coordinator.playCharacters('HELLO');

      // Build expected call list programmatically.
      final expected = <String>[];
      for (final entry in [
        ('....',), ('.',), ('.-..',), ('.-..',), ('---',),
      ]) {
        final pattern = entry.$1;
        for (int i = 0; i < pattern.length; i++) {
          if (pattern[i] == '.') {
            expected.add('playDot');
          } else {
            expected.add('playDash');
          }
          if (i < pattern.length - 1) {
            expected.add('intraCharacterPause');
          }
        }
        expected.add('interCharacterPause');
      }

      expect(audio.calls, expected);
      // No interWordPause within a single word.
      expect(audio.calls.contains('interWordPause'), isFalse);
    });

    test('multi-word string inserts interWordPause between words', () async {
      // HI WORLD
      // H = '....', I = '..', space, W = '.--', O = '---', R = '.-.', L = '.-..', D = '-..'
      await coordinator.playCharacters('HI WORLD');

      // There must be exactly one interWordPause between the two words and
      // no interWordPause after the last word.
      final interWordCount =
          audio.calls.where((c) => c == 'interWordPause').length;
      expect(interWordCount, 1);

      // The interWordPause must occur after the interCharacterPause that
      // closes 'I' (the last char of the first word) and before 'playDot'
      // (the first symbol of 'W').
      final idx = audio.calls.indexOf('interWordPause');
      expect(idx, greaterThan(0));
      expect(audio.calls[idx - 1], 'interCharacterPause');
      expect(audio.calls[idx + 1], 'playDot');
    });

    test('isPlaying is true during playback and false after', () async {
      final duringPlayback = <bool>[];
      // Use a word long enough that we can sample isPlaying mid-flight.
      final fut = coordinator.playCharacters('HELLO').then((_) {
        duringPlayback.add(coordinator.isPlaying);
      });

      // Sample immediately after starting (before the future completes).
      duringPlayback.add(coordinator.isPlaying);
      await fut;

      // While the call was in flight, isPlaying was true; after it resolves,
      // it is false.
      expect(duringPlayback.first, isTrue);
      expect(duringPlayback.last, isFalse);
      expect(coordinator.isPlaying, isFalse);
    });

    test('stop() breaks the loop and calls keyerUp', () async {
      // Use a long multi-word input so there are many checkpoints.
      coordinator.stop(); // pre-set cancellation flag
      // playCharacters resets _isCancelled at start, so we need to stop
      // mid-flight. Schedule stop() on the next microtask.
      final future = coordinator.playCharacters('HELLO WORLD');
      coordinator.stop();
      await future;

      // The coordinator should have broken out and called keyerUp at least
      // once (the cancellation path).
      expect(audio.calls.contains('keyerUp'), isTrue);
      // It should not have completed the full sequence.
      expect(audio.calls.length, lessThan(50));
      expect(coordinator.isPlaying, isFalse);
    });

    test('unknown characters are skipped', () async {
      // '#' is not in the morse map; surrounding known chars should still play.
      await coordinator.playCharacters('A#B');

      // A = '.-' then interCharacterPause, # skipped (no calls), B = '-...'
      // then interCharacterPause.
      expect(audio.calls, [
        'playDot',
        'intraCharacterPause',
        'playDash',
        'interCharacterPause',
        'playDash',
        'intraCharacterPause',
        'playDot',
        'intraCharacterPause',
        'playDot',
        'intraCharacterPause',
        'playDot',
        'interCharacterPause',
      ]);
    });

    test('onFlash callback fires true before and false after each symbol',
        () async {
      final flashes = <bool>[];
      // A = '.-' -> two symbols.
      await coordinator.playCharacters('A', onFlash: flashes.add);

      // For each symbol we get true (before) then false (after the symbol,
      // emitted before the following pause or at end of character).
      expect(flashes, [true, false, true, false]);
    });

    test('onFlash not required — null callback works', () async {
      // Should not throw.
      await coordinator.playCharacters('A');
      expect(audio.calls, isNotEmpty);
    });

    test('extra spaces between words do not produce empty-word calls',
        () async {
      // Double space should not create phantom interWordPauses beyond the
      // single separator between actual words.
      await coordinator.playCharacters('A  B');

      final interWordCount =
          audio.calls.where((c) => c == 'interWordPause').length;
      expect(interWordCount, 1);
    });
  });
}