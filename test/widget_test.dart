import 'package:flutter_test/flutter_test.dart';
import 'package:frank_the_local_llm/main.dart';

void main() {
  testWidgets('App builds and shows text', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Responsive Demo'), findsOneWidget);
  });
}
