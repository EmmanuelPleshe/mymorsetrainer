# Research: Debug Logging System

## Decision 1: Cross-Platform Path Storage

**Chosen**: `path_provider` package

**Rationale**:
- Official Flutter package with stable API
- Provides platform-specific directories:
  - Linux: `~/.config/<app_name>/`
  - macOS: `~/Library/Application Support/<app_name>/`
  - Windows: `%LOCALAPPDATA%/<app_name>/`
  - Android: App-specific sandbox directory

**Alternatives considered**:
- Manual platform detection: Rejected - too much boilerplate
- `platform_directory` package: Less popular, less maintained

---

## Decision 2: Email Log Sharing

**Chosen**: `url_launcher` package with `mailto:` scheme

**Rationale**:
- Simpler than share_plus - just opens email client
- Works across all desktop platforms
- Attaching file via URI parameters supported by most email clients

**Alternatives considered**:
- `share_plus`: Requires additional platform setup for desktop
- Custom SMTP: Rejected - too complex, requires credentials

**Note**: If `mailto:` with attachments doesn't work on all platforms, fallback to showing log file path in dialog for user to attach manually.

---

## Decision 3: Log Rotation Strategy

**Chosen**: Size-based rotation with timestamped archives

**Rationale**:
- Simple to implement - check file size before each write
- Maintains history for debugging across sessions
- Timestamp in filename helps identify relevant logs

**Archive naming**: `morse_trainer_YYYY-MM-DD_N.log` where N is rotation index

---

## Decision 4: Log Format

**Chosen**: Human-readable line-based format

**Format**:
```
2026-05-04T10:30:45.123Z [INFO] [audio] Playing character: K
2026-05-04T10:30:46.456Z [DEBUG] [ui] Button tapped: settings
2026-05-04T10:30:47.789Z [ERROR] [audio] AudioPlayer exception: ...
```

**Rationale**:
- Easy to read in any text editor
- Easy to parse with simple scripts if needed
- Timestamp first for chronological ordering

---

## Decision 5: Integration Points

**To log**:
- UI: Wrap Navigator for navigation events, add logging to button handlers
- Audio: Add logging to AudioService methods
- Settings: Log in SettingsBloc before emitting new state
- Errors: Wrap main() with try-catch, log unhandled exceptions

**Implementation approach**:
- Singleton logger instance accessible globally
- Inject into services that need logging
- Use zone specifier for error capture

---

## Summary

All technical decisions resolved through research. No outstanding clarifications needed. Implementation can proceed with:
- `path_provider` for paths
- `url_launcher` for email
- Size-based rotation with timestamped archives
- Human-readable log format