import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_oracle/config/api_config.dart';
import 'package:weather_oracle/models/weather_data.dart';
import 'package:weather_oracle/models/air_quality_data.dart';

class ApiService {
  final String _baseUrl = 'http://api.weatherapi.com/v1';
  // final String _airPollutionBaseUrl = 'http://api.openweathermap.org/data/2.5/air_pollution';

  Future<WeatherData> getCurrentWeather(double lat, double lon) async {
    final url =
        '$_baseUrl/current.json?key=${ApiConfig.apiKey}&q=$lat,$lon&aqi=yes';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load current weather');
    }
  }

  Future<List<WeatherData>> getHourlyForecast(double lat, double lon) async {
    final url =
        '$_baseUrl/forecast.json?key=${ApiConfig.apiKey}&q=$lat,$lon&days=1&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['forecast']['forecastday'][0]['hour'] as List;
      print("Hourly forecast data: $data");
      return data.map((item) => WeatherData.fromJson(item)).toList();
    } else {
      print("Failed to load hourly forecast. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Failed to load hourly forecast');
    }
  }

  Future<List<WeatherData>> getDailyForecast(double lat, double lon) async {
    final url =
        '$_baseUrl/forecast.json?key=${ApiConfig.apiKey}&q=$lat,$lon&days=7&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['forecast']['forecastday'] as List;
      return data.map((item) => WeatherData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load daily forecast');
    }
  }

  Future<AirQualityData> getAirQuality(double lat, double lon) async {
    final url =
        '$_baseUrl/current.json?key=${ApiConfig.apiKey}&q=$lat,$lon&aqi=yes';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Air Quality Data: $data');

      if (data.containsKey('current') && data['current'].containsKey('air_quality')) {
        final airQualityData = data['current']['air_quality'];

        return AirQualityData.fromJson(airQualityData);
      } else {
        throw Exception('Air quality data not available in the response');
      }
    } else {
      print('Failed to load air quality data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load air quality data');
    }
  }
}