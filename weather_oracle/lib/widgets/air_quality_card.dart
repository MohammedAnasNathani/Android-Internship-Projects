import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/models/air_quality_data.dart';
import 'package:weather_oracle/themes/weather_theme.dart';
import 'package:weather_oracle/providers/weather_provider.dart';

class AirQualityCard extends StatelessWidget {
  final AirQualityData? airQualityData;

  AirQualityCard({required this.airQualityData});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final theme = weatherProvider.getWeatherTheme();

    String aqiLevel = "Unknown";
    String aqiDescription = "Data not available";
    Color cardColor = Colors.grey;

    if (airQualityData != null) {
      switch (airQualityData!.aqi) {
        case 1:
          aqiLevel = "Good";
          aqiDescription = "Air quality is good. Enjoy outdoor activities.";
          cardColor = Colors.green;
          break;
        case 2:
          aqiLevel = "Fair";
          aqiDescription = "Air quality is fair. Sensitive individuals should consider reducing intense outdoor activities.";
          cardColor = Colors.lightGreen;
          break;
        case 3:
          aqiLevel = "Moderate";
          aqiDescription = "Air quality is moderate. Unusually sensitive people should consider reducing prolonged outdoor exertion.";
          cardColor = Colors.yellow;
          break;
        case 4:
          aqiLevel = "Poor";
          aqiDescription = "Air quality is poor. Reduce outdoor activities if you experience symptoms like coughing or throat irritation.";
          cardColor = Colors.orange;
          break;
        case 5:
          aqiLevel = "Very Poor";
          aqiDescription = "Air quality is very poor. Avoid prolonged outdoor exertion. Indoor activities are recommended.";
          cardColor = Colors.red;
          break;
        default:
          aqiLevel = "Unknown";
          aqiDescription = "Air quality data is currently unavailable.";
          cardColor = Colors.grey;
      }
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
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
            "Air Quality",
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white) ??
                TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            aqiLevel,
            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white) ??
                TextStyle(fontSize: 36, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            aqiDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white) ??
                TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}