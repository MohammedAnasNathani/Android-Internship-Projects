import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: "Caveat",
    primaryColor: const Color(0xFF3B2912),
    scaffoldBackgroundColor: const Color(0xFFE7D1B4),
    colorScheme: ColorScheme.light(
      secondary: const Color(0xFF80623D),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor:  Color(0xFF3B2912),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF3B2912),
      textTheme: ButtonTextTheme.primary,
    ),

  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: "Caveat",
    primaryColor: const Color(0xFFE7D1B4),
    scaffoldBackgroundColor: const Color(0xFF18120A),
    colorScheme: ColorScheme.dark(
      secondary: const Color(0xFFBFA16D),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor:  Color(0xFF18120A),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF18120A),
      textTheme: ButtonTextTheme.primary,
    ),
  );
}