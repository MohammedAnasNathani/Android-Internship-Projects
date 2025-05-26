import 'package:flutter/material.dart';

class WeatherMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          'Weather Map (Coming Soon)',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}