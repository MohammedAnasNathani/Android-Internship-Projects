import 'package:flutter/material.dart';
import 'package:weather_oracle/models/weather_enums.dart';

abstract class WeatherTheme {
  Color get backgroundColor;
  Color get textColor;
  Color get accentColor;
  String get backgroundVideoPath;
  IconData get weatherIcon;
  TextTheme get textTheme;

  factory WeatherTheme.fromType(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return SunnyTheme();
      case WeatherCondition.rainy:
        return RainyTheme();
      case WeatherCondition.cloudy:
        return CloudyTheme();
      case WeatherCondition.thunderstorm:
        return ThunderstormTheme();
      case WeatherCondition.snowy:
        return SnowyTheme();
      case WeatherCondition.foggy:
        return FoggyTheme();
      case WeatherCondition.clear:
      default:
        return ClearTheme();
    }
  }
}

class SunnyTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.lightBlueAccent;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.amber;

  @override
  String get backgroundVideoPath => 'assets/videos/sunny_background.mp4';

  @override
  IconData get weatherIcon => Icons.wb_sunny_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
  );
}

class RainyTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.blueGrey;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.blueAccent;

  @override
  String get backgroundVideoPath => 'assets/videos/rainy_background.mp4';

  @override
  IconData get weatherIcon => Icons.water_drop_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
  );
}

class ClearTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.lightBlue;

  @override
  Color get textColor => Colors.black;

  @override
  Color get accentColor => Colors.yellow;

  @override
  String get backgroundVideoPath => 'assets/videos/clear_background.mp4';

  @override
  IconData get weatherIcon => Icons.brightness_high_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
  );
}

class CloudyTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.grey;

  @override
  Color get textColor => Colors.black;

  @override
  Color get accentColor => Colors.blueGrey;

  @override
  String get backgroundVideoPath => 'assets/videos/cloudy_background.mp4';

  @override
  IconData get weatherIcon => Icons.cloud_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
  );
}

class ThunderstormTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.black87;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.yellowAccent;

  @override
  String get backgroundVideoPath => 'assets/videos/thunderstorm_background.mp4';

  @override
  IconData get weatherIcon => Icons.flash_on_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
  );
}

class SnowyTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.white;

  @override
  Color get textColor => Colors.black;

  @override
  Color get accentColor => Colors.lightBlue;

  @override
  String get backgroundVideoPath => 'assets/videos/snowy_background.mp4';

  @override
  IconData get weatherIcon => Icons.ac_unit_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
  );
}

class FoggyTheme implements WeatherTheme {
  @override
  Color get backgroundColor => Colors.blueGrey;

  @override
  Color get textColor => Colors.white;

  @override
  Color get accentColor => Colors.grey;

  @override
  String get backgroundVideoPath => 'assets/videos/foggy_background.mp4';

  @override
  IconData get weatherIcon => Icons.cloud_circle_outlined;

  @override
  TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
        fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: TextStyle(
        fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white),
  );
}