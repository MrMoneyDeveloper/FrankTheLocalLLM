import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frank_the_local_llm/dashboard.dart';

void main() {
  testWidgets('App builds and shows text', (tester) async {
    await tester.pumpWidget(const FrankApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
