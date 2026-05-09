import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morse_trainer/core/logging/log_config.dart';
import 'package:morse_trainer/core/logging/log_constants.dart';
import 'package:morse_trainer/core/logging/log_entry.dart';
import 'package:morse_trainer/core/logging/log_rotator.dart';
import 'package:morse_trainer/core/logging/logger.dart';

void main() {
  group('LogEntry', () {
    test('toLogLine formats debug entry without stack trace', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 1, 15, 10, 30, 0),
        level: LogLevel.debug,
        category: LogCategory.audio,
        message: 'Audio initialized',
      );

      expect(
        entry.toLogLine(),
        '2024-01-15T10:30:00.000 [DEBUG] [audio] Audio initialized',
      );
    });

    test('toLogLine formats error entry with stack trace', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 1, 15, 10, 30, 0),
        level: LogLevel.error,
        category: LogCategory.general,
        message: 'Database connection failed',
        stackTrace: 'Stack trace line 1\nStack trace line 2',
      );

      expect(
        entry.toLogLine(),
        '2024-01-15T10:30:00.000 [ERROR] [general] Database connection failed\nStack trace line 1\nStack trace line 2',
      );
    });
  });

  group('LogConfig', () {
    test('default values are correct', () {
      const config = LogConfig();
      expect(config.maxFileSizeBytes, 5 * 1024 * 1024);
      expect(config.maxArchiveCount, 5);
      expect(config.retentionDays, 7);
      expect(config.logDirectoryName, 'morse_trainer');
      expect(config.logFileName, 'app.log');
    });

    test('copyWith overrides specific fields', () {
      const config = LogConfig(maxFileSizeBytes: 1024);
      final updated = config.copyWith(retentionDays: 14);
      expect(updated.maxFileSizeBytes, 1024);
      expect(updated.retentionDays, 14);
      expect(updated.maxArchiveCount, 5);
    });
  });

  group('LogRotator', () {
    late Directory tempDir;
    late LogRotator rotator;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('log_rotator_test');
      const config = LogConfig(maxFileSizeBytes: 100, maxArchiveCount: 3);
      rotator = LogRotator(config);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('checkAndRotate does nothing when file does not exist', () async {
      final logPath = '${tempDir.path}/app.log';
      await rotator.checkAndRotate(logPath);
      expect(await File(logPath).exists(), false);
    });

    test('checkAndRotate does nothing when file is below max size', () async {
      final logPath = '${tempDir.path}/app.log';
      final file = File(logPath);
      await file.writeAsString('small');

      await rotator.checkAndRotate(logPath);
      expect(await file.exists(), true);
    });

    test('checkAndRotate rotates when file exceeds max size', () async {
      final logPath = '${tempDir.path}/app.log';
      final file = File(logPath);
      await file.writeAsString('x' * 150); // > 100 bytes

      await rotator.checkAndRotate(logPath);
      expect(await file.exists(), false); // renamed to archive
    });

    test('rotate renames file to archive', () async {
      final logPath = '${tempDir.path}/app.log';
      final file = File(logPath);
      await file.writeAsString('test content');

      await rotator.rotate(logPath);
      expect(await file.exists(), false);

      final dir = Directory(tempDir.path);
      final archives = await dir.list().where((e) => e.path.contains('app_')).toList();
      expect(archives.length, 1);
    });

    test('cleanup deletes old archives beyond max count', () async {
      // Pre-create 5 archive files matching the pattern, max is 3
      for (var i = 0; i < 5; i++) {
        final file = File('${tempDir.path}/app_2024-01-0${i+1}T00-00-00.log');
        await file.writeAsString('content $i');
        await Future.delayed(const Duration(milliseconds: 10)); // stagger modification times
      }

      // Create current log and rotate it (triggers cleanup)
      final logFile = File('${tempDir.path}/app.log');
      await logFile.writeAsString('rotate me');
      await rotator.rotate('${tempDir.path}/app.log');

      final dir = Directory(tempDir.path);
      final archives = await dir.list().where((e) => e.path.contains('app_')).toList();
      expect(archives.length, lessThanOrEqualTo(3));
    });

    test('cleanup deletes archives older than retention period', () async {
      // Create an old archive
      final oldFile = File('${tempDir.path}/app_2024-01-01T00-00-00.log');
      await oldFile.writeAsString('old content');

      // Create current log and rotate with retentionDays = 0
      const zeroRetention = LogConfig(maxFileSizeBytes: 100, maxArchiveCount: 3, retentionDays: 0);
      final zeroRotator = LogRotator(zeroRetention);
      final logFile = File('${tempDir.path}/app.log');
      await logFile.writeAsString('rotate me');
      await zeroRotator.rotate('${tempDir.path}/app.log');

      final dir = Directory(tempDir.path);
      final archives = await dir.list().where((e) => e.path.contains('app_')).toList();
      // Old archive + new archive both should be deleted because retention=0
      // But the newly created archive has current timestamp, so only old one is deleted
      // The new archive might also be deleted if its mtime is considered "before now"
      // since we just created it. Let's verify at least the old one is gone.
      final oldStillExists = archives.any((e) => e.path.contains('2024-01-01'));
      expect(oldStillExists, false);
    });
  });

  group('Logger', () {
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
    const urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');
    late Directory tempDir;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tempDir = await Directory.systemTemp.createTemp('logger_test_');
      pathProviderChannel.setMockMethodCallHandler((call) async {
        if (call.method == 'getApplicationSupportDirectory') {
          return tempDir.path;
        }
        return null;
      });
      urlLauncherChannel.setMockMethodCallHandler((call) async {
        if (call.method == 'canLaunch') {
          return false;
        }
        return null;
      });
      await Logger.instance.initialize(config: const LogConfig(maxFileSizeBytes: 1024 * 1024));
    });

    tearDownAll(() async {
      pathProviderChannel.setMockMethodCallHandler(null);
      urlLauncherChannel.setMockMethodCallHandler(null);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    tearDown(() async {
      final logFile = File('${tempDir.path}/morse_trainer/app.log');
      if (await logFile.exists()) {
        await logFile.delete();
      }
    });

    test('currentLogPath points to app.log', () {
      expect(Logger.instance.currentLogPath, isNotEmpty);
      expect(Logger.instance.currentLogPath, endsWith('app.log'));
    });

    test('log appends entry to file', () async {
      await Logger.instance.log(LogEntry(
        timestamp: DateTime(2024, 6, 1, 12, 0, 0),
        level: LogLevel.info,
        category: LogCategory.general,
        message: 'unit test message',
      ));

      final content = await File('${tempDir.path}/morse_trainer/app.log').readAsString();
      expect(content, contains('[INFO] [general] unit test message'));
    });

    test('debug writes DEBUG level', () async {
      await Logger.instance.debug(LogCategory.audio, 'audio debug');
      final content = await File('${tempDir.path}/morse_trainer/app.log').readAsString();
      expect(content, contains('[DEBUG] [audio] audio debug'));
    });

    test('info writes INFO level', () async {
      await Logger.instance.info(LogCategory.ui, 'ui info');
      final content = await File('${tempDir.path}/morse_trainer/app.log').readAsString();
      expect(content, contains('[INFO] [ui] ui info'));
    });

    test('warning writes WARNING level', () async {
      await Logger.instance.warning(LogCategory.navigation, 'nav warning');
      final content = await File('${tempDir.path}/morse_trainer/app.log').readAsString();
      expect(content, contains('[WARNING] [navigation] nav warning'));
    });

    test('error writes ERROR level with stack trace', () async {
      await Logger.instance.error(LogCategory.general, 'error msg', stackTrace: 'line1\nline2');
      final content = await File('${tempDir.path}/morse_trainer/app.log').readAsString();
      expect(content, contains('[ERROR] [general] error msg'));
      expect(content, contains('line1'));
      expect(content, contains('line2'));
    });

    test('sendLogs returns false when url launcher unavailable', () async {
      final result = await Logger.instance.sendLogs();
      expect(result, false);
    });
  });
}
