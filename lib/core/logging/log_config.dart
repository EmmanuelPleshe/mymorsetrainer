/// Configuration for the logging system
class LogConfig {
  /// Maximum file size before rotation (5MB default)
  final int maxFileSizeBytes;

  /// Maximum number of archive files to retain
  final int maxArchiveCount;

  /// Number of days to retain logs
  final int retentionDays;

  /// Directory name for app logs
  final String logDirectoryName;

  /// Active log file name
  final String logFileName;

  const LogConfig({
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5MB
    this.maxArchiveCount = 5,
    this.retentionDays = 7,
    this.logDirectoryName = 'morse_trainer',
    this.logFileName = 'app.log',
  });

  LogConfig copyWith({
    int? maxFileSizeBytes,
    int? maxArchiveCount,
    int? retentionDays,
    String? logDirectoryName,
    String? logFileName,
  }) {
    return LogConfig(
      maxFileSizeBytes: maxFileSizeBytes ?? this.maxFileSizeBytes,
      maxArchiveCount: maxArchiveCount ?? this.maxArchiveCount,
      retentionDays: retentionDays ?? this.retentionDays,
      logDirectoryName: logDirectoryName ?? this.logDirectoryName,
      logFileName: logFileName ?? this.logFileName,
    );
  }
}