import 'log_constants.dart';

/// Represents a single log event
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final LogCategory category;
  final String message;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.category,
    required this.message,
    this.stackTrace,
  });

  /// Format log entry as line for file
  String toLogLine() {
    final timestampStr = timestamp.toIso8601String();
    final stackPart = stackTrace != null ? '\n$stackTrace' : '';
    return '$timestampStr [${level.name}] [${category.name}] $message$stackPart';
  }
}