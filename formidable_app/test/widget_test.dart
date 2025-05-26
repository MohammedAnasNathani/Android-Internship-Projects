import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formidable_app/main.dart';
import 'package:formidable_app/screens/home_screen.dart';

void main() {
  testWidgets('App starts and navigates to home screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    expect(find.byType(HomeScreen), findsOneWidget);

    expect(find.text('Formidable'), findsOneWidget);
  });

}