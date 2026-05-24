import 'package:mocktail/mocktail.dart';
import 'package:morse_trainer/data/models/word.dart';
import 'package:morse_trainer/data/repositories/word_familiarity_repository.dart';

class MockWordFamiliarityRepository extends Mock implements WordFamiliarityRepository {
  @override
  ScaffoldingLevel getScaffoldingLevel(double familiarityScore) {
    if (familiarityScore < 20.0) return ScaffoldingLevel.high;
    if (familiarityScore < 60.0) return ScaffoldingLevel.medium;
    return ScaffoldingLevel.none;
  }
}
