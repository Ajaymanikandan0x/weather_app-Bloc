part of 'city_bloc.dart';

@immutable
sealed class CityEvent {}

class FetchCities extends CityEvent {}

class UpdateCityWeather extends CityEvent {
  final String cityName;

  UpdateCityWeather(this.cityName);
}

class DeleteCityByName extends CityEvent {
  final String cityName;

  DeleteCityByName(this.cityName);
}

class SaveCityWeather extends CityEvent {
  final WeatherData weatherData; // Change to WeatherData

  SaveCityWeather(this.weatherData);
}
