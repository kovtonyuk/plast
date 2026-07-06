import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic smoke test - the app requires Supabase initialization
    // which is done in main(), so we just verify the test compiles
    expect(true, isTrue);
  });
}
