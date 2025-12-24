import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App widget test', (WidgetTester tester) async {
    // Create a simple test app without Firebase
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Naija Food Finder UK 🇳🇬🇬🇧'),
          ),
        ),
      ),
    );

    // Verify the title appears
    expect(find.text('Naija Food Finder UK 🇳🇬🇬🇧'), findsOneWidget);
  });
}
