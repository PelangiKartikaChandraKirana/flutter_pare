import 'package:flutter_test/flutter_test.dart';
import 'package:pareverse/main.dart';

void main() {
  testWidgets('Onboarding screen shows Create Account and Sign In buttons',
      (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(PareverseApp());

    // Verify onboarding UI elements
    expect(find.text('Temukan tempat kursus yang pas di Pare, tanpa ribet!'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
