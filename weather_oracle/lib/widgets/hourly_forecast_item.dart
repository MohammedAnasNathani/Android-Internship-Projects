import 'package:flutter/material.dart';
import 'package:weather_oracle/models/weather_data.dart';
import 'package:weather_oracle/themes/weather_theme.dart';
import 'package:weather_oracle/utils/AppDateUtils.dart';
import 'package:weather_oracle/utils/weather_icon_utils.dart';
import 'package:weather_oracle/models/weather_enums.dart';

class HourlyForecastItem extends StatelessWidget {
  final WeatherData? weatherData;

  HourlyForecastItem({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return Center(child: Text("Loading hourly forecast..."));
    }

    final theme = WeatherTheme.fromType(
        WeatherConditionExtension.fromString(weatherData!.description ?? 'clear'));

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.textColor.withOpacity(0.2))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppDateUtils.formatHourlyTime(weatherData!.date!),
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