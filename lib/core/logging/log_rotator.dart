import 'dart:io';
import 'log_config.dart';

/// Handles log file rotation
class LogRotator {
  final LogConfig config;

  LogRotator(this.config);

  /// Check file size and rotate if needed
  Future<void> checkAndRotate(String logPath) async {
    final file = File(logPath);
    if (!await file.exists()) return;

    final stat = await file.stat();
    if (stat.size >= config.maxFileSizeBytes) {
      await rotate(logPath);
    }
  }

  /// Rotate the current log file
  Future<void> rotate(String logPath) async {
    final file = File(logPath);
    if (!await file.exists()) return;

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final archivePath = logPath.replaceAll('.log', '_$timestamp.log');

    // Rename current to archive
    await file.rename(archivePath);

    // Clean up old archives
    await _cleanupArchives(logPath);
  }

  /// Clean up old archive files
  Future<void> _cleanupArchives(String logPath) async {
    final dir = Directory(logPath).parent;
    final baseName = logPath.split('/').last.replaceAll('.log', '');

    if (!await dir.exists()) return;

    final archives = await dir
        .list()
        .where((e) => e is File && e.path.contains(baseName) && e.path.endsWith('.log'))
        .cast<File>()
        .toList();

    // Sort by modified date, newest first
    archives.sort((a, b) {
      final aStat = a.statSync();
      final bStat = b.statSync();
      return bStat.modified.compareTo(aStat.modified);
    });

    // Delete old archives beyond max count
    if (archives.length > config.maxArchiveCount) {
      for (var i = config.maxArchiveCount; i < archives.length; i++) {
        await archives[i].delete();
      }
    }

    // Delete archives older than retention period
    final cutoff = DateTime.now().subtract(Duration(days: config.retentionDays));
    for (final archive in archives) {
      final stat = await archive.stat();
      if (stat.modified.isBefore(cutoff)) {
        await archive.delete();
      }
    }
  }
}