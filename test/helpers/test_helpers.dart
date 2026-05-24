export 'mocks/mock_audio_service.dart';
export 'mocks/mock_file_system.dart';
export 'mocks/mock_keyboard.dart';

import 'package:mocktail/mocktail.dart';

/// Registers all fallback values for mocktail.
/// Call this in setUpAll() of any test file that uses mocktail with
/// classes that have no default constructor.
void registerTestFallbacks() {
  registerFallbackValue(const Duration(milliseconds: 100));
}
