enum InputMethod { keyboard, touchscreen, gameController, audioInput }

class AppSettings {
  final String id;
  final double toneFrequency;
  final double wpm;
  final double volume;
  final InputMethod inputMethod;
  final bool enableGamification;
  final bool enableSoundEffects;

  AppSettings({
    this.id = 'current',
    this.toneFrequency = 600.0,
    this.wpm = 20.0,
    this.volume = 1.0,
    this.inputMethod = InputMethod.keyboard,
    this.enableGamification = true,
    this.enableSoundEffects = true,
  });

  AppSettings copyWith({
    String? id,
    double? toneFrequency,
    double? wpm,
    double? volume,
    InputMethod? inputMethod,
    bool? enableGamification,
    bool? enableSoundEffects,
  }) {
    return AppSettings(
      id: id ?? this.id,
      toneFrequency: toneFrequency ?? this.toneFrequency,
      wpm: wpm ?? this.wpm,
      volume: volume ?? this.volume,
      inputMethod: inputMethod ?? this.inputMethod,
      enableGamification: enableGamification ?? this.enableGamification,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toneFrequency': toneFrequency,
      'wpm': wpm,
      'volume': volume,
      'inputMethod': inputMethod.index,
      'enableGamification': enableGamification ? 1 : 0,
      'enableSoundEffects': enableSoundEffects ? 1 : 0,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as String? ?? 'current',
      toneFrequency: map['toneFrequency'] as double? ?? 600.0,
      wpm: map['wpm'] as double? ?? 20.0,
      volume: map['volume'] as double? ?? 1.0,
      inputMethod: InputMethod.values[map['inputMethod'] as int? ?? 0],
      enableGamification: map['enableGamification'] == 1,
      enableSoundEffects: map['enableSoundEffects'] == 1,
    );
  }
}
