import 'package:flutter/material.dart';
import 'package:weather_oracle/themes/weather_theme.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/models/weather_enums.dart';

class ContextualRecommendationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final theme = WeatherTheme.fromType(weatherProvider.currentCondition);

    String recommendation = generateRecommendation(weatherProvider);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Recommendation",
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text(
            recommendation,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String generateRecommendation(WeatherProvider weatherProvider) {
    if (weatherProvider.currentWeather == null) {
      return "Loading weather data...";
    }

    switch (weatherProvider.currentCondition) {
      case WeatherCondition.sunny:
        return "Perfect weather for outdoor activities! Don't forget your sunscreen.";
      case WeatherCondition.rainy:
        return "It's raining outside. Remember to take your umbrella!";
      case WeatherCondition.cloudy:
        return "A good day for a walk in the park.";
      case WeatherCondition.thunderstorm:
        return "Stay indoors and avoid going out during the thunderstorm.";
      case WeatherCondition.snowy:
        return "It's snowing! Be careful on the roads and enjoy the snow.";
      case WeatherCondition.foggy:
        return "Visibility is low due to fog. Drive safely!";
      case WeatherCondition.clear:
      default:
        return "Enjoy the clear weather today!";
    }
  }
}