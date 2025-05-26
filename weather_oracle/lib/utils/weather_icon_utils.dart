import 'package:flutter/material.dart';

class WeatherIconUtils {
  static IconData getIconData(String? iconCode) {
    switch (iconCode) {
      case '01d':
        return Icons.wb_sunny_outlined;
      case '01n':
        return Icons.nightlight_round;
      case '02d':
      case '03d':
        return Icons.wb_cloudy_outlined;
      case '02n':
      case '03n':
        return Icons.cloud_outlined;
      case '04d':
      case '04n':
        return Icons.cloud_queue_outlined;
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.water_drop_outlined;
      case '11d':
      case '11n':
        return Icons.flash_on_outlined;
      case '13d':
      case '13n':
        return Icons.ac_unit_outlined;
      case '50d':
      case '50n':
        return Icons.foggy;
      default:
        return Icons.help_outline;
    }
  }
}