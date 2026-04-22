import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/gamification/gamification_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: context.read<GamificationService>().getStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(stats),
                const SizedBox(height: 24),
                _buildSectionHeader('Current Streak'),
                _buildStreakCard(stats['currentStreak'] ?? 0, stats['longestStreak'] ?? 0),
                const SizedBox(height: 24),
                _buildSectionHeader('Level Progress'),
                _buildLevelCard(stats['currentLevel'] ?? 1, stats['charactersMastered'] ?? 0),
                const SizedBox(height: 24),
                _buildSectionHeader('Session History'),
                _buildSessionCard(stats['totalSessionsCompleted'] ?? 0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Points',
          '${stats['totalPoints'] ?? 0}',
          Icons.star,
          Colors.amber,
        ),
        _buildStatCard(
          'Current Streak',
          '${stats['currentStreak'] ?? 0}',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Characters Mastered',
          '${stats['charactersMastered'] ?? 0} / 26',
          Icons.text_fields,
          Colors.blue,
        ),
        _buildStatCard(
          'Sessions Completed',
          '${stats['totalSessionsCompleted'] ?? 0}',
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildStreakCard(int currentStreak, int longestStreak) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text('Current'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$longestStreak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Best'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentStreak > 0)
              LinearProgressIndicator(
                value: (currentStreak % 5) / 5,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            if (currentStreak > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${5 - (currentStreak % 5)} more for next bonus',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(int currentLevel, int charactersMastered) {
    final progress = charactersMastered / 26;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $currentLevel',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$charactersMastered / 26',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% complete',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(int totalSessions) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.history, size: 40, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              '$totalSessions',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text('Sessions completed'),
          ],
        ),
      ),
    );
  }
}
