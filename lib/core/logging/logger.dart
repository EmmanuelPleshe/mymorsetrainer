import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'log_constants.dart';
import 'log_entry.dart';
import 'log_config.dart';
import 'log_rotator.dart';

/// Main logging service - singleton
class Logger {
  static final Logger instance = Logger._internal();

  factory Logger() => instance;

  Logger._internal();

  bool _initialized = false;
  late LogConfig _config;
  late LogRotator _rotator;
  String? _currentLogPath;

  /// Initialize the logger
  Future<void> initialize({LogConfig? config}) async {
    if (_initialized) return;

    _config = config ?? const LogConfig();
    _rotator = LogRotator(_config);

    final dir = await getLogDirectory();
    _currentLogPath = '${dir.path}/${_config.logFileName}';

    // Ensure directory exists
    await dir.create(recursive: true);

    _initialized = true;
    await log(
      LogEntry(
        timestamp: DateTime.now(),
        level: LogLevel.info,
        category: LogCategory.general,
        message: 'Logger initialized. Log file: $_currentLogPath',
      ),
    );
  }

  /// Get the platform-appropriate log directory
  Future<Directory> getLogDirectory() async {
    final baseDir = await getApplicationSupportDirectory();
    return Directory('${baseDir.path}/${_config.logDirectoryName}');
  }

  /// Current log file path
  String get currentLogPath => _currentLogPath ?? '';

  /// Log a message
  Future<void> log(LogEntry entry) async {
    if (!_initialized) return;

    // Check for rotation
    await _rotator.checkAndRotate(_currentLogPath!);

    final file = File(_currentLogPath!);
    final line = '${entry.toLogLine()}\n';
    await file.writeAsString(line, mode: FileMode.append);
  }

  /// Debug level log
  Future<void> debug(LogCategory category, String message) => log(
        LogEntry(
          timestamp: DateTime.now(),
          level: LogLevel.debug,
          category: category,
          message: message,
        ),
      );

  /// Info level log
  Future<void> info(LogCategory category, String message) => log(
        LogEntry(
          timestamp: DateTime.now(),
          level: LogLevel.info,
          category: category,
          message: message,
        ),
      );

  /// Warning level log
  Future<void> warning(LogCategory category, String message) => log(
        LogEntry(
          timestamp: DateTime.now(),
          level: LogLevel.warning,
          category: category,
          message: message,
        ),
      );

  /// Error level log
  Future<void> error(LogCategory category, String message, {String? stackTrace}) =>
      log(
        LogEntry(
          timestamp: DateTime.now(),
          level: LogLevel.error,
          category: category,
          message: message,
          stackTrace: stackTrace,
        ),
      );

  /// Open email client with log file path
  Future<bool> sendLogs({String? to}) async {
    if (_currentLogPath == null || _currentLogPath!.isEmpty) {
      return false;
    }

    final subject = Uri.encodeComponent('Morse Trainer Bug Report');
    final body = Uri.encodeComponent(
        'Please attach the following log file:\n$_currentLogPath\n\nDescribe the issue:');
    final email = to ?? 'support@morsetrainer.app';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject&body=$body',
    );

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}