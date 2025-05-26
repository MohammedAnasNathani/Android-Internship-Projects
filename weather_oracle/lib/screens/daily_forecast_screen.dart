import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/widgets/daily_forecast_card.dart';

class DailyForecastScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Forecast'),
      ),
      body: weatherProvider.dailyForecast.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: weatherProvider.dailyForecast.length,
        itemBuilder: (context, index) {
          final forecast = weatherProvider.dailyForecast[index];
          return DailyForecastCard(weatherData: forecast);
        },
      ),
    );
  }
}