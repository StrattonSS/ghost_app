import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghost_app/main.dart'; // Import where GhostApp is defined

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GhostApp());

    // Add more test expectations if needed
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
