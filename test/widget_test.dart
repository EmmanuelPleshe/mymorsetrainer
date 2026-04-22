import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:morse_trainer/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MorseTrainerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
