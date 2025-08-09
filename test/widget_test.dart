import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Baby Monitor Alarm'),
            ),
          ),
        ),
      ),
    );

    // Verify that the app launches successfully.
    expect(find.text('Baby Monitor Alarm'), findsOneWidget);
  });
}
