import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/screens/home_screen.dart';
import 'package:weather_oracle/themes/weather_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: WeatherOracleApp(),
    ),
  );
}

class WeatherOracleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final theme = WeatherTheme.fromType(weatherProvider.currentCondition);
        return MaterialApp(
          title: 'Weather Oracle',
          theme: ThemeData(
            scaffoldBackgroundColor: theme.backgroundColor,
            colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: theme.accentColor),
            textTheme: theme.textTheme,
          ),
          home: HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}