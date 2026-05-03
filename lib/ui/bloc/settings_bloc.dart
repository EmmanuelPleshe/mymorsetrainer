import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/settings.dart';
import '../../data/repositories/settings_repository.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateToneFrequency extends SettingsEvent {
  final double frequency;
  const UpdateToneFrequency(this.frequency);
}

class UpdateWpm extends SettingsEvent {
  final double wpm;
  const UpdateWpm(this.wpm);
}

class UpdateEffWpm extends SettingsEvent {
  final double effWpm;
  const UpdateEffWpm(this.effWpm);
}

class UpdateExtraWordSpace extends SettingsEvent {
  final double extraWordSpace;
  const UpdateExtraWordSpace(this.extraWordSpace);
}

class UpdateVolume extends SettingsEvent {
  final double volume;
  const UpdateVolume(this.volume);
}

class UpdateInputMethod extends SettingsEvent {
  final InputMethod method;
  const UpdateInputMethod(this.method);
}

class ToggleGamification extends SettingsEvent {
  const ToggleGamification();
}

class UpdateSoundEffects extends SettingsEvent {
  final bool enabled;
  const UpdateSoundEffects(this.enabled);
}

class UpdateScreenFlash extends SettingsEvent {
  final bool enabled;
  const UpdateScreenFlash(this.enabled);
}

// States
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;
  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc(this._settingsRepository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateToneFrequency>(_onUpdateToneFrequency);
    on<UpdateWpm>(_onUpdateWpm);
    on<UpdateEffWpm>(_onUpdateEffWpm);
    on<UpdateExtraWordSpace>(_onUpdateExtraWordSpace);
    on<UpdateVolume>(_onUpdateVolume);
    on<UpdateInputMethod>(_onUpdateInputMethod);
    on<ToggleGamification>(_onToggleGamification);
    on<UpdateSoundEffects>(_onUpdateSoundEffects);
    on<UpdateScreenFlash>(_onUpdateScreenFlash);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());
    try {
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onUpdateToneFrequency(
    UpdateToneFrequency event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateToneFrequency(event.frequency);
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update tone frequency: $e'));
    }
  }

  Future<void> _onUpdateWpm(
    UpdateWpm event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateWpm(event.wpm);
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update WPM: $e'));
    }
  }

  Future<void> _onUpdateEffWpm(
    UpdateEffWpm event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final current = await _settingsRepository.getSettings();
      await _settingsRepository.updateSettings(current.copyWith(effWpm: event.effWpm));
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update effective WPM: $e'));
    }
  }

  Future<void> _onUpdateExtraWordSpace(
    UpdateExtraWordSpace event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final current = await _settingsRepository.getSettings();
      await _settingsRepository.updateSettings(current.copyWith(extraWordSpace: event.extraWordSpace));
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update extra word space: $e'));
    }
  }

  Future<void> _onUpdateVolume(
    UpdateVolume event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateVolume(event.volume);
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update volume: $e'));
    }
  }

  Future<void> _onUpdateInputMethod(
    UpdateInputMethod event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _settingsRepository.updateInputMethod(event.method);
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update input method: $e'));
    }
  }

  Future<void> _onToggleGamification(
    ToggleGamification event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final currentSettings = await _settingsRepository.getSettings();
      await _settingsRepository.updateSettings(
        currentSettings.copyWith(enableGamification: !currentSettings.enableGamification),
      );
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to toggle gamification: $e'));
    }
  }

  Future<void> _onUpdateSoundEffects(
    UpdateSoundEffects event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final currentSettings = await _settingsRepository.getSettings();
      await _settingsRepository.updateSettings(
        currentSettings.copyWith(enableSoundEffects: event.enabled),
      );
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update sound effects: $e'));
    }
  }

  Future<void> _onUpdateScreenFlash(
    UpdateScreenFlash event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final currentSettings = await _settingsRepository.getSettings();
      await _settingsRepository.updateSettings(
        currentSettings.copyWith(enableScreenFlash: event.enabled),
      );
      final settings = await _settingsRepository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update screen flash: $e'));
    }
  }
}
