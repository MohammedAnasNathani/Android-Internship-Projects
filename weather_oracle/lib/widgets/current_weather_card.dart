import 'package:flutter/material.dart';
import 'package:weather_oracle/models/weather_data.dart';
import 'package:weather_oracle/themes/weather_theme.dart';
import 'package:weather_oracle/utils/AppDateUtils.dart';
import 'package:weather_oracle/utils/weather_icon_utils.dart';
import 'package:weather_oracle/models/weather_enums.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherData? weatherData;

  CurrentWeatherCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return Center(child: Text("Loading weather data..."));
    }

    final theme = WeatherTheme.fromType(
        WeatherConditionExtension.fromString(weatherData!.description ?? 'clear'));

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.backgroundColor.withOpacity(0.8),
            theme.backgroundColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weatherData!.locationName ?? 'Unknown Location',
            style: theme.textTheme.titleLarge!.copyWith(
              fontFamily:
              'YourCustomFont',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Icon(
            WeatherIconUtils.getIconData(weatherData!.icon ?? '01d'),
            size: 80,
            color: theme.accentColor,
          ),
          SizedBox(height: 10),
          Text(
            '${weatherData!.temperature?.toStringAsFixed(0) ?? '-'}°C',
            style: theme.textTheme.displayLarge!.copyWith(
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            weatherData!.description ?? 'No Description',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 10),
          Text(
            'Feels like ${weatherData!.feelsLike?.toStringAsFixed(0) ?? '-'}°C',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Humidity: ${weatherData!.humidity ?? '-'}%',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(width: 20),
              Text(
                'Wind: ${weatherData!.windSpeed?.toStringAsFixed(1) ?? '-'} m/s',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Updated: ${AppDateUtils.formatDateTime(DateTime.now())}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}