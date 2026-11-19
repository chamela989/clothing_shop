import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_shop/main.dart';

void main() {
  testWidgets('Welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClothingShopApp());

    // Verify that the welcome text and log button appear.
    expect(find.text('CLOTHING SHOP'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);
  });
}