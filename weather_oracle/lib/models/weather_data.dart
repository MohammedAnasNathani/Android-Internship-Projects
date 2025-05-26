import 'package:weather_oracle/models/weather_enums.dart';

class WeatherData {
  final String? locationName;
  final double? temperature;
  final String? description;
  final double? feelsLike;
  final int? humidity;
  final double? windSpeed;
  final String? icon;
  final DateTime? date;

  WeatherData({
    this.locationName,
    this.temperature,
    this.description,
    this.feelsLike,
    this.humidity,
    this.windSpeed,
    this.icon,
    this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    print("Parsing JSON: $json");

    // Handle current weather data
    if (json.containsKey('current')) {
      final location = json['location'];
      final current = json['current'];
      final condition = current['condition'];

      return WeatherData(
        locationName: location['name'],
        temperature: current['temp_c']?.toDouble(),
        description: condition['text'],
        feelsLike: current['feelslike_c']?.toDouble(),
        humidity: current['humidity'],
        windSpeed: current['wind_kph']?.toDouble(),
        icon: condition['icon'],
        date: DateTime.parse(current['last_updated']),
      );
    } else if (json.containsKey('time_epoch')) {
      final condition = json['condition'];

      return WeatherData(
        temperature: json['temp_c']?.toDouble(),
        description: condition?['text'],
        feelsLike: json['feelslike_c']?.toDouble(),
        humidity: json['humidity'],
        windSpeed: json['wind_kph']?.toDouble(),
        icon: condition?['icon'],
        date: DateTime.fromMillisecondsSinceEpoch(json['time_epoch'] * 1000),
      );
    } else {
      return WeatherData(
        date: DateTime.parse(json['date']),
        temperature: json['day']['avgtemp_c']?.toDouble(),
        icon: json['day']['condition']['icon'],
        description: json['day']['condition']['text'],
      );
    }
  }
}

extension WeatherConditionExtension on WeatherCondition {
  static WeatherCondition fromString(String? description) {
    if (description == null) return WeatherCondition.clear;

    final lowerCaseDescription = description.toLowerCase();
    if (lowerCaseDescription.contains("rain")) {
      return WeatherCondition.rainy;
    } else if (lowerCaseDescription.contains("cloud")) {
      return WeatherCondition.cloudy;
    } else if (lowerCaseDescription.contains("clear")) {
      return WeatherCondition.sunny;
    } else if (lowerCaseDescription.contains("snow")) {
      return WeatherCondition.snowy;
    } else if (lowerCaseDescription.contains("thunderstorm")) {
      return WeatherCondition.thunderstorm;
    } else if (lowerCaseDescription.contains("fog")) {
      return WeatherCondition.foggy;
    }
    return WeatherCondition.clear;
  }
}