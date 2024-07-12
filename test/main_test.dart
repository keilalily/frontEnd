import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('StartPanel widget test', (WidgetTester tester) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: VPM(),
      ),
    ));

    // Verify that the title text is rendered
    expect(find.text('BULSU HC VENDO PRINTING MACHINE'), findsOneWidget);

    // Verify that all buttons are rendered
    expect(find.text('PRINT'), findsOneWidget);
    expect(find.text('SCAN'), findsOneWidget);
    expect(find.text('PHOTOCOPY'), findsOneWidget);

    // Tap the 'PRINT' button and verify it does not crash
    await tester.tap(find.text('PRINT'));
    await tester.pump();

    // Verify that after tapping, some action should occur
    // Replace this with your actual test logic based on button interaction

    // Example: Verify that a dialog or another screen appears after tapping
    // expect(find.byType(YourDialogWidget), findsOneWidget);

    // Tap the 'SCAN' button and verify it does not crash
    await tester.tap(find.text('SCAN'));
    await tester.pump();

    // Verify that after tapping, some action should occur

    // Example: Verify that another widget or screen appears after tapping

    // Tap the 'PHOTOCOPY' button and verify it does not crash
    await tester.tap(find.text('PHOTOCOPY'));
    await tester.pump();

    // Verify that after tapping, some action should occur

    // Example: Verify that another widget or screen appears after tapping
  });
}
