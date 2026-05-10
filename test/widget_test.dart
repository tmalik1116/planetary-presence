import 'package:flutter_test/flutter_test.dart';
import 'package:planetary_presence/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlanetaryPresenceApp());
    expect(find.text('Map'), findsOneWidget);
  });
}
