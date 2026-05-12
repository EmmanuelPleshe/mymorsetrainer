/// Immutable Morse timing calculator based on ARRL PARIS standard.
/// All durations and keyer thresholds computed from WPM/effWPM.
class MorseTimingEngine {
  final double wpm;
  final double effWpm;
  final int extraWordSpace;

  MorseTimingEngine({
    required this.wpm,
    required this.effWpm,
    this.extraWordSpace = 0,
  }) : assert(wpm > 0, 'wpm must be positive'),
       assert(effWpm > 0, 'effWpm must be positive');

  int get dotDurationMs => (1200 / wpm).round();
  int get dashDurationMs => dotDurationMs * 3;
  int get intraCharacterSpaceMs => dotDurationMs;

  /// ARRL Farnsworth extra unit time per word in seconds.
  double get _farnsworthUnitTime {
    final c = wpm;
    final s = effWpm;
    return (60 * c - 37.2 * s) / (s * c);
  }

  int get interCharacterSpaceMs {
    if (effWpm >= wpm) return dotDurationMs * 3;
    final tC = (3 * _farnsworthUnitTime) / 19;
    return (tC * 1000).round();
  }

  int get interWordSpaceMs {
    if (effWpm >= wpm) return dotDurationMs * 7 + extraWordSpace;
    final tW = (7 * _farnsworthUnitTime) / 19;
    return (tW * 1000).round() + extraWordSpace;
  }

  int get keyerDotDashThresholdMs => dotDurationMs * 3;

  // Letter boundary = 3 dits, same as dot/dash classification threshold
  int get keyerInterLetterThresholdMs => dotDurationMs * 3;

  int get keyerInterWordThresholdMs => dotDurationMs * 9;
}
