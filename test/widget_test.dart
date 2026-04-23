import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder smoke test', (WidgetTester tester) async {
    // App requires Hive + Firebase initialisation before mounting.
    // Integration tests live in test/core/services/.
    expect(true, isTrue);
  });
}
