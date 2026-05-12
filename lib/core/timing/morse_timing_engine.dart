/// Immutable Morse timing calculator based on ARRL PARIS standard.
/// All durations and keyer thresholds computed from WPM/effWPM.
class MorseTimingEngine {
  final double wpm;
  final double effWpm;
  final int extraWordSpace;

  const MorseTimingEngine({
    required this.wpm,
    required this.effWpm,
    this.extraWordSpace = 0,
  });

  int get dotDurationMs => (1200 / wpm).round();
  int get dashDurationMs => dotDurationMs * 3;
  int get intraCharacterSpaceMs => dotDurationMs;

  int get interCharacterSpaceMs {
    if (effWpm >= wpm) return dotDurationMs * 3;
    final c = wpm;
    final s = effWpm;
    final tA = (60 * c - 37.2 * s) / (s * c);
    final tC = (3 * tA) / 19;
    return (tC * 1000).round();
  }

  int get interWordSpaceMs {
    if (effWpm >= wpm) return dotDurationMs * 7 + extraWordSpace;
    final c = wpm;
    final s = effWpm;
    final tA = (60 * c - 37.2 * s) / (s * c);
    final tW = (7 * tA) / 19;
    return (tW * 1000).round() + extraWordSpace;
  }

  int get keyerDotDashThresholdMs => dotDurationMs * 3;
  int get keyerInterLetterThresholdMs => dotDurationMs * 3;
  int get keyerInterWordThresholdMs => dotDurationMs * 9;
}
