import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dmd_pro_courier/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DmdProCourierApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
