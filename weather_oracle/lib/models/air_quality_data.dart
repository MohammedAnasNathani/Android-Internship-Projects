class AirQualityData {
  final int aqi;

  AirQualityData({required this.aqi});

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      aqi: json['us-epa-index'] ?? 0,
    );
  }
}