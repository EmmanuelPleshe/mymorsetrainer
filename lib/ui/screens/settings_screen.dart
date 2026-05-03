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
          label: 'Effective Speed (Farnsworth)',
          value: settings.effWpm,
          min: 5,
          max: 40,
          unit: 'WPM',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateEffWpm(value));
          },
        ),
        _buildSliderSetting(
          label: 'Extra Word Space',
          value: settings.extraWordSpace,
          min: 0,
          max: 2,
          unit: 's',
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateExtraWordSpace(value));
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
            context.read<SettingsBloc>().add(UpdateSoundEffects(value));
          },
        ),
        SwitchListTile(
          title: const Text('Screen Flash'),
          subtitle: const Text('Flash screen with Morse for visual learners'),
          value: settings.enableScreenFlash,
          onChanged: (value) {
            context.read<SettingsBloc>().add(UpdateScreenFlash(value));
          },
        ),
        const Divider(),
        _buildSectionHeader('Timing Info'),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ARRL PARIS Standard (50 units/word):', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Dit: 1 unit'),
                Text('• Dah: 3 units'),
                Text('• Intra-character space: 1 unit'),
                Text('• Inter-character space: 3 units'),
                Text('• Inter-word space: 7 units'),
                SizedBox(height: 8),
                Text('Farnsworth method sends characters faster but increases spacing for slower effective speed.',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
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

  int _calculateDivisions(double min, double max, String unit) {
    int divs;
    if (unit == 'WPM' || unit == 's') {
      divs = (max - min).round();
    } else {
      divs = ((max - min) * 100).round();
    }
    return divs.clamp(1, 1000);
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
              unit.isEmpty ? '${value.toStringAsFixed(0)}' : '${value.toStringAsFixed(0)} $unit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: _calculateDivisions(min, max, unit),
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