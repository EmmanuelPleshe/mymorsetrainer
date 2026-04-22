class WpmCalculator {
  static const int _standardWordLength = 50; // PARIS in morse = 50 units

  static int dotDurationMs(double wpm) {
    return (1200 / wpm).round();
  }

  static int dashDurationMs(double wpm) {
    return dotDurationMs(wpm) * 3;
  }

  static int symbolSpaceMs(double wpm) {
    return dotDurationMs(wpm);
  }

  static int letterSpaceMs(double wpm) {
    return dotDurationMs(wpm) * 3;
  }

  static int wordSpaceMs(double wpm) {
    return dotDurationMs(wpm) * 7;
  }

  static double wpmFromDuration(double durationMs, int dotsAndDashes) {
    if (durationMs <= 0 || dotsAndDashes <= 0) return 0;
    return (_standardWordLength * 60 * 1000) / (durationMs * dotsAndDashes);
  }

  static int characterDurationMs(String morsePattern, double wpm) {
    final dotMs = dotDurationMs(wpm);
    int duration = 0;

    for (int i = 0; i < morsePattern.length; i++) {
      duration += morsePattern[i] == '.' ? dotMs : dotMs * 3;
      if (i < morsePattern.length - 1) {
        duration += dotMs; // symbol space
      }
    }

    return duration;
  }
}
