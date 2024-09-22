import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/api.dart'; // Import API functions
import '../../file/city_data.dart';
import '../../logic/db/db.dart';
import '../db/model.dart'; 

part 'city_event.dart';
part 'city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  CityBloc() : super(CityInitial()) {
    on<FetchCities>((event, emit) async {
      emit(CityLoading());
      try {
        final cities = await fetchCities();
        final cityList = cities.map((city) => City(name: city.cityName, weatherData: city)).toList();
        emit(CityLoaded(cities: cityList));
      } catch (e) {
        emit(CityError(error: e.toString()));
      }
    });

    on<UpdateCityWeather>((event, emit) async {
      emit(CityLoading());
      try {
        final updatedCity = await fetchCityWeather(event.cityName);
        final currentState = state;
        if (currentState is CityLoaded) {
          final updatedCities = currentState.cities.map((city) {
            return city.name == event.cityName ? updatedCity : city;
          }).toList();
          emit(CityLoaded(cities: updatedCities));
        }
      } catch (e) {
        emit(CityError(error: e.toString()));
      }
    });

    on<DeleteCityByName>((event, emit) async {
      final currentState = state;
      if (currentState is CityLoaded) {
        final updatedCities = currentState.cities.where((city) => city.name != event.cityName).toList();
        await _databaseHelper.deleteCityByName(event.cityName);
        emit(CityLoaded(cities: updatedCities));
      }
    });

    on<SaveCityWeather>((event, emit) async {
      try {
        final model = Model(
          event.weatherData.cityName,
          event.weatherData.time,
          event.weatherData.temperature,
          event.weatherData.humidity,
          event.weatherData.windSpeed,
          event.weatherData.rainIntensity,
          event.weatherData.visibility,
          event.weatherData.weatherType,
        );

        await _databaseHelper.insertCity(model);
        final currentState = state;
        if (currentState is CityLoaded) {
          final updatedCities = List<City>.from(currentState.cities)
            ..add(City(name: model.cityName, weatherData: model));
          emit(CityLoaded(cities: updatedCities));
        } else {
          emit(CityLoaded(cities: [City(name: model.cityName, weatherData: model)]));
        }
      } catch (e) {
        emit(CityError(error: e.toString()));
      }
    });
  }

  Future<City> fetchCityWeather(String cityName) async {
    final locations = await getLatLongFromPlace(cityName);
    if (locations.isNotEmpty) {
      final lat = locations[0]['lat'];
      final lng = locations[0]['lng'];
      final city = locations[0]['city'];
      List<WeatherData> weatherDataList = await getWeather(lat, lng, city);
      if (weatherDataList.isNotEmpty) {
        final weatherData = weatherDataList[0];
        final model = Model(
          weatherData.cityName,
          weatherData.time,
          weatherData.temperature,
          weatherData.humidity,
          weatherData.windSpeed,
          weatherData.rainIntensity,
          weatherData.visibility,
          weatherData.weatherType,
        );
        return City(name: cityName, weatherData: model);
      }
    }
    throw Exception('Weather data not found for $cityName');
  }

  Future<List<Model>> fetchCities() async {
    return await _databaseHelper.getCity();
  }
}
