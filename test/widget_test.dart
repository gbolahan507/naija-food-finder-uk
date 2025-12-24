import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:naija_food_finder_uk/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app title appears.
    expect(find.text('Naija Food Finder UK 🇳🇬🇬🇧'), findsOneWidget);
    
    // Verify we don't have the old counter text
    expect(find.text('0'), findsNothing);
  });
}