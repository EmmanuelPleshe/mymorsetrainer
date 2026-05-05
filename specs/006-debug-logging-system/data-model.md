# Data Model: Debug Logging System

## Entities

### LogEntry

Represents a single log event.

| Field | Type | Description |
|-------|------|-------------|
| timestamp | DateTime | When the log was created |
| level | LogLevel | Severity: debug, info, warning, error |
| category | LogCategory | Source: ui, audio, settings, navigation, error |
| message | String | Human-readable description |

**LogLevel enum**:
- debug: Detailed info for development
- info: General operational events
- warning: Unexpected but handled
- error: Failures requiring attention

**LogCategory enum**:
- ui: User interface interactions
- audio: Audio playback and state
- settings: Configuration changes
- navigation: Screen transitions
- error: Exceptions and failures
- general: Miscellaneous

---

### LogConfig

Configuration for the logging system.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| maxFileSizeBytes | int | 5_242_880 (5MB) | Rotation threshold |
| maxArchiveCount | int | 5 | Retention count |
| retentionDays | int | 7 | Time-based retention |
| logDirectoryName | String | "morse_trainer" | App directory |
| logFileName | String | "app.log" | Active log file |

---

### LogFileInfo

Metadata about current log files.

| Field | Type | Description |
|-------|------|-------------|
| path | String | Full file path |
| sizeBytes | int | Current file size |
| lastModified | DateTime | Last write time |
| isActive | bool | Currently being written to |

---

## State Transitions

### Log Rotation State Machine

```
IDLE
  │
  │ file size > maxFileSizeBytes
  ▼
ROTATING
  │
  │ archive created, active cleared
  ▼
IDLE
```

---

## Validation Rules

- LogEntry.message: max 10,000 characters (truncate if longer)
- LogConfig.maxFileSizeBytes: min 1MB, max 50MB
- LogConfig.maxArchiveCount: min 1, max 20
- LogConfig.retentionDays: min 1, max 90

---

## Relationships

- Logger manages LogConfig (singleton)
- LogRotator creates LogFileInfo entries
- LogEntry written to active LogFileInfo path
- Archive files identified by timestamp in filename