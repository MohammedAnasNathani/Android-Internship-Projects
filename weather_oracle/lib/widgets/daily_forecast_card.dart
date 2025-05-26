import 'package:flutter/material.dart';
import 'package:weather_oracle/models/weather_data.dart';
import 'package:weather_oracle/themes/weather_theme.dart';
import 'package:weather_oracle/utils/AppDateUtils.dart';
import 'package:weather_oracle/utils/weather_icon_utils.dart';
import 'package:weather_oracle/models/weather_enums.dart';

class DailyForecastCard extends StatelessWidget {
  final WeatherData? weatherData;

  DailyForecastCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return Center(child: Text("Loading daily forecast..."));
    }

    final theme = WeatherTheme.fromType(
        WeatherConditionExtension.fromString(weatherData!.description ?? 'clear'));

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppDateUtils.formatDailyDate(weatherData!.date!),
            style: theme.textTheme.bodyMedium,
          ),
          Icon(
            WeatherIconUtils.getIconData(weatherData!.icon ?? '01d'),
            size: 32,
            color: theme.accentColor,
          ),
          Text(
            '${weatherData!.temperature?.toStringAsFixed(0) ?? '-'}°C',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            weatherData!.description ?? 'No Description',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}