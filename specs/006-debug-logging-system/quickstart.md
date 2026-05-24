# Quickstart: Debug Logging System

## Getting Started

### 1. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  path_provider: ^2.1.0
  url_launcher: ^6.2.0
```

### 2. Initialize Logger

```dart
// main.dart
import 'package:morse_trainer/core/logging/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  await Logger.instance.initialize();
  
  // Log app start
  Logger.instance.info('general', 'Application starting');
  
  runApp(const MyApp());
}
```

### 3. Log from Services

```dart
// Audio service example
class AudioService {
  final _logger = Logger.instance;
  
  Future<void> playCharacter(String char) async {
    _logger.debug('audio', 'Playing character: $char');
    // ... playback logic
  }
  
  Future<void> setVolume(double volume) async {
    _logger.info('settings', 'Volume changed to: $volume');
  }
}
```

### 4. Add Send Logs Button

```dart
// settings_screen.dart
import 'package:url_launcher/url_launcher.dart';

ElevatedButton(
  onPressed: () async {
    final logPath = Logger.instance.currentLogPath;
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@morsetrainer.app',
      query: 'subject=Bug Report&body=Please attach log file: $logPath',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  },
  child: const Text('Send Logs'),
)
```

### 5. Handle Uncaught Errors

```dart
// main.dart - wrap runApp
void main() async {
  // ... initialization
  
  runAppWithLogging();
}

void runAppWithLogging() {
  runApp(
    Builder(
      builder: (context) {
        // Set up error handling
        FlutterError.onError = (details) {
          Logger.instance.error(
            'error',
            'Uncaught exception: ${details.exception}',
            stackTrace: details.stack,
          );
        };
        return const MyApp();
      },
    ),
  );
}
```

## Configuration

Default locations:
- Linux: `~/.config/morse_trainer/app.log`
- macOS: `~/Library/Application Support/morse_trainer/app.log`
- Windows: `%LOCALAPPDATA%\morse_trainer\app.log`

To customize:
```dart
Logger.instance.initialize(
  config: LogConfig(
    maxFileSizeBytes: 10_485_760, // 10MB
    logDirectoryName: 'my_custom_dir',
  ),
);
```

## Troubleshooting

**No logs appearing**:
- Check app has write permission to log directory
- Verify logger initialized before other services

**Send Logs button not working**:
- Ensure email client is default on system
- Fallback: Show dialog with log path for manual attachment

**Log file too large**:
- Automatic rotation should trigger at 5MB
- Check retention settings