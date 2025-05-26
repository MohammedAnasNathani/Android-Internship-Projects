import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/themes/weather_theme.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final theme = WeatherTheme.fromType(weatherProvider.currentCondition);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: theme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperature Unit', style: theme.textTheme.titleLarge),
            SizedBox(height: 10),
            ListTile(
              title: Text('Celsius (°C)', style: theme.textTheme.bodyMedium),
              leading: Radio<bool>(
                value: true,
                groupValue: true,
                onChanged: (bool? value) {
                },
              ),
            ),
            ListTile(
              title: Text('Fahrenheit (°F)', style: theme.textTheme.bodyMedium),
              leading: Radio<bool>(
                value: false,
                groupValue: true,
                onChanged: (bool? value) {
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}