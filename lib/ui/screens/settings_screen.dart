import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            return _buildSettingsForm(context, state.settings);
          }

          if (state is SettingsError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('Audio Settings'),
        _buildSliderSetting(
          label: 'Tone Frequency',
          value: settings.toneFrequency,
          min: 300,
          max: 2000,
          unit: 'Hz',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateToneFrequency(value));
          },
        ),
        _buildSliderSetting(
          label: 'Speed (WPM)',
          value: settings.wpm,
          min: 5,
          max: 40,
          unit: 'WPM',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateWpm(value));
          },
        ),
        _buildSliderSetting(
          label: 'Volume',
          value: settings.volume,
          min: 0,
          max: 1,
          unit: '',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateVolume(value));
          },
        ),
        const Divider(),
        _buildSectionHeader('Input Method'),
        _buildInputMethodSelector(context, settings),
        const Divider(),
        _buildSectionHeader('Preferences'),
        SwitchListTile(
          title: const Text('Enable Gamification'),
          subtitle: const Text('Points, streaks, and achievements'),
          value: settings.enableGamification,
          onChanged: (_) {
            context.read<SettingsBloc>().add(const ToggleGamification());
          },
        ),
        SwitchListTile(
          title: const Text('Sound Effects'),
          subtitle: const Text('Feedback sounds for correct/incorrect answers'),
          value: settings.enableSoundEffects,
          onChanged: (value) {
            // TODO: Implement sound effects toggle
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              '${value.toStringAsFixed(0)} $unit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) / (unit == 'WPM' ? 1 : 100)).round(),
          label: '${value.toStringAsFixed(0)} $unit',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInputMethodSelector(BuildContext context, AppSettings settings) {
    return Column(
      children: InputMethod.values.map((method) {
        final icon = _getInputMethodIcon(method);
        final label = _getInputMethodLabel(method);

        return RadioListTile<InputMethod>(
          title: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
          value: method,
          groupValue: settings.inputMethod,
          onChanged: (value) {
            if (value != null) {
              context.read<SettingsBloc>().add(UpdateInputMethod(value));
            }
          },
        );
      }).toList(),
    );
  }

  IconData _getInputMethodIcon(InputMethod method) {
    switch (method) {
      case InputMethod.keyboard:
        return Icons.keyboard;
      case InputMethod.touchscreen:
        return Icons.touch_app;
      case InputMethod.gameController:
        return Icons.gamepad;
      case InputMethod.audioInput:
        return Icons.mic;
    }
  }

  String _getInputMethodLabel(InputMethod method) {
    switch (method) {
      case InputMethod.keyboard:
        return 'Keyboard';
      case InputMethod.touchscreen:
        return 'Touchscreen';
      case InputMethod.gameController:
        return 'Game Controller';
      case InputMethod.audioInput:
        return 'Audio Input (Mic)';
    }
  }
}
