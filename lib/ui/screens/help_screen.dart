import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            icon: Icons.school,
            title: 'What is the Koch Method?',
            content:
                'The Koch method is a proven technique for learning Morse code efficiently. '
                'Instead of learning the alphabet in order (A, B, C...), you start with just '
                'two characters (K and M) and add one new character only after you can copy them '
                'at 90% accuracy.\n\n'
                'Why it works:\n'
                '• Starts at real-world speeds from day one\n'
                '• Builds muscle memory before cognitive load overwhelms\n'
                '• New characters are added to existing pool — never replace known ones',
          ),
          _buildSection(
            context,
            icon: Icons.keyboard,
            title: 'How to Key Input',
            content:
                'Use your keyboard Spacebar as a Morse keyer:\n\n'
                '• Hold SPACE briefly → dit (dot)\n'
                '• Hold SPACE longer → dah (dash)\n'
                '• Release SPACE → submit the pattern\n\n'
                'If you pause too long between elements, the pattern will auto-submit. '
                'You can adjust this timeout in Settings → Input Timeout.',
          ),
          _buildSection(
            context,
            icon: Icons.settings,
            title: 'Settings Explained',
            content:
                'Speed (WPM): How fast individual dits and dahs play (5–40 WPM).\n\n'
                'Effective Speed (Farnsworth): Overall words-per-minute including pauses. '
                'When this is lower than Character Speed, extra silence is inserted between '
                'letters and words. This lets you hear characters at full speed without '
                'pressure to reply that fast.\n\n'
                'Extra Word Space: Adds additional silence between words.\n\n'
                'Tone Frequency: Pitch of the Morse tone in Hz (300–2000). '
                '600–800 Hz is standard.',
          ),
          _buildSection(
            context,
            icon: Icons.trending_up,
            title: 'Progression & Levels',
            content:
                'To unlock the next character you need ≥90% accuracy on ALL currently '
                'unlocked characters over the last 20 attempts.\n\n'
                'New characters are added to your practice pool — they never replace '
                'existing ones. The app checks if you are ready to advance after every '
                'session, not mid-session.',
          ),
          _buildSection(
            context,
            icon: Icons.color_lens,
            title: 'What the Colors Mean',
            content:
                'During practice the large circle changes color to show state:\n\n'
                '• Blue → Waiting for your input\n'
                '• Green → Your last answer was correct\n'
                '• Red → Your last answer was wrong\n\n'
                'After feedback, the next character will play automatically.',
          ),
          _buildSection(
            context,
            icon: Icons.timer,
            title: 'Why Did It Submit Early?',
            content:
                'Morse code has built-in timing: a short pause means "next element in '
                'same character" and a longer pause means "character complete."\n\n'
                'The app uses an Input Timeout to decide when you are done keying a '
                'character. If you release the key and wait longer than this timeout, '
                'the pattern submits automatically.\n\n'
                'If it submits too early, increase the Input Timeout in Settings.',
          ),
          _buildSection(
            context,
            icon: Icons.bug_report,
            title: 'Troubleshooting & FAQ',
            content:
                'Stuck on feedback screen (colors stay forever)?\n'
                '→ This is a known rendering issue. Tap the screen or press any key '
                'to force the next character. It will be fixed in an upcoming release.\n\n'
                'Audio does not play?\n'
                '→ Check your device volume and that Sound Effects are enabled in Settings.\n\n'
                'Keyboard not responding?\n'
                '→ Make sure the practice screen is focused (tap the blue circle) and '
                'you are using the Spacebar.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
