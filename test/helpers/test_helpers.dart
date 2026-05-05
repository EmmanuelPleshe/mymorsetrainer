export 'mocks/mock_audio_service.dart';
export 'mocks/mock_file_system.dart';
export 'mocks/mock_keyboard.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

/// Registers all fallback values for mocktail
void registerTestFallbacks() {
  registerFallbackValue(const Duration(milliseconds: 100));
  registerFallbackValue(BlocEvent());
  registerFallbackValue(BlocState());
}

/// Runs a bloc test with automatic fallback registration
void runBlocTest<B extends Bloc<E, S>, E, S>(
  String description, {
  required B bloc,
  required E event,
  required S expect,
  Future<void> Function()? act,
  Future<void> Function()? wait,
  List<void Function()> verify = const [],
}) {
  setUpAll(() {
    registerTestFallbacks();
  });

  blocTest<B, S>(
    description,
    bloc: () => bloc,
    act: act ?? () => bloc.add(event),
    expect: () => expect,
  );
}

/// Creates a fake event for testing
class TestEvent extends Fake implements BlocEvent {}

/// Creates a fake state for testing
class TestState extends Fake implements BlocState {}