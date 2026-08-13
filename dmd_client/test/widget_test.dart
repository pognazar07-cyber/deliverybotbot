import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dmd_client/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DmdApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
