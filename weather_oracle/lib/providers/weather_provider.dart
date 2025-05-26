import 'package:flutter/material.dart';
import 'package:weather_oracle/models/weather_data.dart';
import 'package:weather_oracle/services/api_service.dart';
import 'package:weather_oracle/services/location_service.dart';
import 'package:weather_oracle/models/air_quality_data.dart';
import 'package:weather_oracle/models/weather_enums.dart';
import 'package:weather_oracle/themes/weather_theme.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  WeatherData? _currentWeather;
  List<WeatherData> _hourlyForecast = [];
  List<WeatherData> _dailyForecast = [];
  AirQualityData? _airQuality;
  WeatherCondition _currentCondition = WeatherCondition.clear;
  String? _error;

  WeatherData? get currentWeather => _currentWeather;
  List<WeatherData> get hourlyForecast => _hourlyForecast;
  List<WeatherData> get dailyForecast => _dailyForecast;
  AirQualityData? get airQuality => _airQuality;
  WeatherCondition get currentCondition => _currentCondition;
  String? get error => _error;

  WeatherTheme getWeatherTheme() {
    return WeatherTheme.fromType(currentCondition);
  }

  void setWeatherCondition(WeatherCondition condition) {
    _currentCondition = condition;
    notifyListeners();
  }

  Future<void> fetchWeatherData() async {
    try {
      print("Fetching weather data...");
      final position = await _locationService.getCurrentLocation();
      print("Got position: ${position.latitude}, ${position.longitude}");

      _currentWeather = await _apiService.getCurrentWeather(
          position.latitude, position.longitude);
      print("Got current weather: ${_currentWeather?.locationName}");

      _hourlyForecast = await _apiService.getHourlyForecast(
          position.latitude, position.longitude);
      print("Got hourly forecast");

      _dailyForecast = await _apiService.getDailyForecast(
          position.latitude, position.longitude);
      print("Got daily forecast");

      _airQuality = await _apiService.getAirQuality(
          position.latitude, position.longitude);
      print("Got air quality: ${_airQuality?.aqi}");

      if (_currentWeather?.description != null) {
        _currentCondition =
            _determineWeatherCondition(_currentWeather!.description!);
      }
      _error = null;
    } catch (e) {
      print("Error fetching weather data: $e");
      _error = "Failed to fetch weather data: ${e.toString()}";
    } finally {
      print("Notifying listeners...");
      notifyListeners();
    }
  }

  WeatherCondition _determineWeatherCondition(String description) {
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