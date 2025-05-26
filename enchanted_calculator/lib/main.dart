import 'package:flutter/material.dart';
import 'package:enchanted_calculator/screens/calculator_screen.dart';
import 'package:enchanted_calculator/themes/theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.dark);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'Enchanted Calculator',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: CalculatorScreen(themeModeNotifier: _themeMode),
        );
      },
    );
  }
}