import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/widgets/hourly_forecast_item.dart';

class HourlyForecastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hourly Forecast'),
      ),
      body: weatherProvider.hourlyForecast.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: weatherProvider.hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = weatherProvider.hourlyForecast[index];
          return HourlyForecastItem(weatherData: forecast);
        },
      ),
    );
  }
}