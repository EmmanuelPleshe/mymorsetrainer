import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/practice_session_bloc.dart';
import '../../core/audio/morse_code_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _selectedWpm = 18;
  double _selectedTone = 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage ? Colors.blue : Colors.grey.shade300,
                  ),
                )),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(),
                  _buildKochExplanationPage(),
                  _buildSettingsPage(),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: _currentPage < 2
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        : _completeOnboarding,
                    child: Text(_currentPage < 2 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radio, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('Welcome to Morse Trainer',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Text(
            'Learn Morse code using the proven Koch method - start with just 2 characters and progress at your own pace.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text('This app will:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.music_note, 'Play Morse code at your chosen speed'),
          _buildFeatureItem(Icons.keyboard, 'Let you key it back using spacebar'),
          _buildFeatureItem(Icons.trending_up, 'Track your progress and unlock new characters'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildKochExplanationPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text('How the Koch Method Works',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const Text(
            '1. Start with just K and M\n'
            '2. Practice until you get 90% accuracy\n'
            '3. A new character is added\n'
            '4. Repeat until you know the alphabet',
            style: TextStyle(fontSize: 18, height: 1.6),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Text('Pro tip:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                SizedBox(height: 8),
                Text('Listen to the code at a comfortable speed, then key back at YOUR pace. The app adapts to your keying speed.',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text('Set Your Preferences',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('You can change these anytime in Settings',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          // Speed slider
          Text('Listening Speed: ${_selectedWpm.round()} WPM',
              style: const TextStyle(fontSize: 18)),
          const Text('How fast letters play (Farnsworth character speed)',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Slider(
            value: _selectedWpm,
            min: 5, max: 40,
            divisions: 35,
            label: '${_selectedWpm.round()} WPM',
            onChanged: (value) => setState(() => _selectedWpm = value),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              'Farnsworth method: Start listening at 18-20 WPM. Characters play fast, but pauses are longer so you can reply at your own speed.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          // Tone slider
          Text('Tone: ${_selectedTone.round()} Hz',
              style: const TextStyle(fontSize: 18)),
          const Text('Pitch of the morse code sounds (higher = easier to hear)',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Slider(
            value: _selectedTone,
            min: 300, max: 2000,
            divisions: 17,
            label: '${_selectedTone.round()} Hz',
            onChanged: (value) => setState(() => _selectedTone = value),
          ),
          const SizedBox(height: 8),
          const Text('Tip: 600-800 Hz is standard. Older operators often prefer 700-800 Hz.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _testSound,
            icon: const Icon(Icons.volume_up),
            label: const Text('Test Sound'),
          ),
          const SizedBox(height: 24),
          // Skip intro checkbox
          CheckboxListTile(
            value: _skipIntro,
            onChanged: (value) => setState(() => _skipIntro = value ?? false),
            title: const Text('Skip this intro on future launches'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  bool _skipIntro = false;

  void _testSound() async {
    final audio = AudioPlaybackService();
    await audio.initialize();
    audio.setWpm(_selectedWpm);
    audio.setToneFrequency(_selectedTone);
    await audio.playCharacter('K');
  }

  void _completeOnboarding() {
    // Save settings
    context.read<SettingsBloc>().add(UpdateWpm(_selectedWpm));
    context.read<SettingsBloc>().add(UpdateToneFrequency(_selectedTone));

    // Mark onboarding complete and save skip preference
    context.read<PracticeSessionBloc>().add(CompleteOnboarding(skipIntro: _skipIntro));

    widget.onComplete();
  }
}