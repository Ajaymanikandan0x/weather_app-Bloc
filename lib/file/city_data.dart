import 'weather_data/weatherdata.dart';

class City {
  final String name;
  final WeatherData weatherData;

  City({
    required this.name,
    required this.weatherData,
  });
}