import '../logic/db/model.dart';

class City {
  final String name;
  final Model weatherData; // Use Model instead of WeatherData

  City({required this.name, required this.weatherData}); // Ensure Model is used
}