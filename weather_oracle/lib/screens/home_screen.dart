import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_oracle/animations/rain_animation.dart';
import 'package:weather_oracle/animations/sun_animation.dart';
import 'package:weather_oracle/providers/weather_provider.dart';
import 'package:weather_oracle/screens/daily_forecast_screen.dart';
import 'package:weather_oracle/screens/hourly_forecast_screen.dart';
import 'package:weather_oracle/widgets/air_quality_card.dart';
import 'package:weather_oracle/widgets/current_weather_card.dart';
import 'package:weather_oracle/widgets/contextual_recommendation.dart';
import 'package:weather_oracle/widgets/weather_map.dart';
import 'package:weather_oracle/models/weather_enums.dart';
import 'package:weather_oracle/widgets/video_background.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.error != null) {
            return Center(
              child: Text(weatherProvider.error!),
            );
          } else if (weatherProvider.currentWeather == null) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Stack(
              children: [
                Positioned.fill(
                  child: VideoBackground(
                    videoPath: weatherProvider.getWeatherTheme().backgroundVideoPath,
                  ),
                ),

                if (weatherProvider.currentCondition == WeatherCondition.rainy)
                  Positioned.fill(
                    child: RainAnimation(),
                  ),
                if (weatherProvider.currentCondition == WeatherCondition.sunny)
                  Positioned.fill(
                    child: SunAnimation(),
                  ),

                RefreshIndicator(
                  onRefresh: () => weatherProvider.fetchWeatherData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        CurrentWeatherCard(
                            weatherData: weatherProvider.currentWeather!),
                        SizedBox(height: 20),
                        AirQualityCard(
                            airQualityData: weatherProvider.airQuality),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HourlyForecastScreen(),
                                ),
                              );
                            },
                            child: Text("Hourly Forecast"),
                          ),
                        ),

                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyForecastScreen(),
                                ),
                              );
                            },
                            child: Text("Daily Forecast"),
                          ),
                        ),
                        SizedBox(height: 20),
                        ContextualRecommendationCard(),
                        SizedBox(height: 20),
                        WeatherMap(),
                        SizedBox(height: 20),
                        Center( child: Text("(For Testing Purposes Only)")),
                        Wrap(
                          spacing: 8.0,
                          children: [
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.sunny),
                              child: Text('Sunny'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.rainy),
                              child: Text('Rainy'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.cloudy),
                              child: Text('Cloudy'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.snowy),
                              child: Text('Snowy'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.thunderstorm),
                              child: Text('Thunderstorm'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.foggy),
                              child: Text('Foggy'),
                            ),
                            ElevatedButton(
                              onPressed: () => weatherProvider.setWeatherCondition(WeatherCondition.clear),
                              child: Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}