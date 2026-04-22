import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/practice_session_bloc.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
        ],
      ),
      body: BlocConsumer<PracticeSessionBloc, PracticeSessionState>(
        listener: (context, state) {
          if (state is PracticeSessionComplete) {
            _showCompletionDialog(context, state);
          }
        },
        builder: (context, state) {
          if (state is PracticeSessionInitial) {
            return _buildStartScreen(context);
          }

          if (state is PracticeSessionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PracticeSessionActive) {
            return _buildActiveSession(context, state);
          }

          if (state is PracticeSessionComplete) {
            return _buildCompletionSummary(context, state);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.radio, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Morse Code Trainer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Learn morse code with the Koch method',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PracticeSessionBloc>().add(const StartSession(1));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Practice'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, PracticeSessionActive state) {
    final character = state.currentCharacter;
    if (character == null) {
      return const Center(child: Text('No more characters'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: state.currentIndex / state.characters.length,
          ),
          const SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Correct', '${state.correctCount}'),
              _buildStat('Accuracy', '${(state.accuracy * 100).toStringAsFixed(1)}%'),
              _buildStat('Streak', '${state.currentStreak}'),
            ],
          ),
          const SizedBox(height: 32),

          // Character display
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getFeedbackColor(state.lastAnswerCorrect),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    character.symbol,
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character.morsePattern,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Input area
          if (state.lastAnswerCorrect == null)
            _buildInputArea(context, character.symbol)
          else
            _buildFeedbackArea(context, state),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Color _getFeedbackColor(bool? isCorrect) {
    if (isCorrect == null) return Colors.blue;
    return isCorrect ? Colors.green : Colors.red;
  }

  Widget _buildInputArea(BuildContext context, String expectedCharacter) {
    return Column(
      children: [
        const Text(
          'Enter the character you heard:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        TextField(
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32),
          maxLength: 1,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<PracticeSessionBloc>().add(SubmitAnswer(value));
            }
          },
          decoration: const InputDecoration(
            hintText: 'Tap here to type',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackArea(BuildContext context, PracticeSessionActive state) {
    final isCorrect = state.lastAnswerCorrect!;
    return Column(
      children: [
        Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : Colors.red,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          isCorrect ? 'Correct!' : 'Wrong!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isCorrect ? Colors.green : Colors.red,
          ),
        ),
        if (state.showUnlockNotification) ...[
          const SizedBox(height: 16),
          const Icon(Icons.lock_open, color: Colors.orange, size: 48),
          const Text(
            'New character unlocked!',
            style: TextStyle(fontSize: 18, color: Colors.orange),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<PracticeSessionBloc>().add(const NextCharacter());
          },
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildCompletionSummary(BuildContext context, PracticeSessionComplete state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Session Complete!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '${state.correctCount} / ${state.totalQuestions} correct',
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            'Accuracy: ${(state.accuracy * 100).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 18),
          ),
          if (state.unlockedNextLevel)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Next level unlocked!',
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
            ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PracticeSessionBloc>().add(const StartSession(1));
            },
            icon: const Icon(Icons.replay),
            label: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, PracticeSessionComplete state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Text(
          'You got ${state.correctCount} out of ${state.totalQuestions} correct (${(state.accuracy * 100).toStringAsFixed(1)}%)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
