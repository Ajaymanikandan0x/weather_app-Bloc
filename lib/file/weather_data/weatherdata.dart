import '../../api/api.dart';

class WeatherData {
  final String cityName;
  final double temperature;
  final String weatherType;
  final String time;
  final double visibility;
  final double windSpeed;
  final double humidity;
  final String imagePath;

  WeatherData({
    required this.cityName,
    required this.temperature,
    required this.weatherType,
    required this.time,
    required this.visibility,
    required this.windSpeed,
    required this.humidity,
    required this.imagePath,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, int weatherCode, String cityName) {
    String time = json['time'] ?? '';
    try {
      DateTime.parse(time); // Validate the date format
    } catch (e) {
      time = ''; // Set to empty string if invalid
    }

    return WeatherData(
      cityName: cityName,
      temperature: (json['values']?['temperature'] ?? 0).toDouble(),
      weatherType: getWeatherType(weatherCode),
      time: time,
      visibility: (json['values']?['visibility'] ?? 0).toDouble(),
      windSpeed: (json['values']?['windSpeed'] ?? 0).toDouble(),
      humidity: (json['values']?['humidity'] ?? 0).toDouble(),
      imagePath: weatherImages[weatherCode] ?? 'assets/icons/sunny.png',
    );
  }
}
