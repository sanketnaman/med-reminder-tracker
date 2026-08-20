import 'package:flutter_test/flutter_test.dart';
import 'package:doseza/main.dart';

void main() {
  testWidgets('Splash Screen branding test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediaroApp());

    // Verify that the splash screen title is present.
    expect(find.text('Mediaro'), findsOneWidget);
    expect(find.text('Never miss a dose.'), findsOneWidget);
  });
}
