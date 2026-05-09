/// Log severity levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

extension LogLevelExtension on LogLevel {
  String get name {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}

/// Log source categories
enum LogCategory {
  ui,
  audio,
  settings,
  navigation,
  error,
  general,
}

extension LogCategoryExtension on LogCategory {
  String get name {
    switch (this) {
      case LogCategory.ui:
        return 'ui';
      case LogCategory.audio:
        return 'audio';
      case LogCategory.settings:
        return 'settings';
      case LogCategory.navigation:
        return 'navigation';
      case LogCategory.error:
        return 'error';
      case LogCategory.general:
        return 'general';
    }
  }
}