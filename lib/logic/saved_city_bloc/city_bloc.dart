import 'package:bloc/bloc.dart';

import '../../api/api.dart'; // Import the API functions
import '../../file/city_data.dart';
import 'city_event.dart';
import 'city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final CityService cityService;

  CityBloc(this.cityService) : super(CityInitial()) {
    on<AddCity>((event, emit) async {
      try {
        emit(CityLoading());
        await cityService.addCity(event.name);
        final cities = await cityService.getCities();
        emit(CityLoaded(cities));
      } catch (error) {
        emit(CityError(error.toString()));
      }
    });

    on<FetchCities>((event, emit) async {
      try {
        emit(CityLoading());
        final cities = await cityService.getCities();
        emit(CityLoaded(cities));
      } catch (error) {
        emit(CityError(error.toString()));
      }
    });

    on<DeleteCityByName>((event, emit) async {
      try {
        await cityService.deleteCityByName(event.cityName);
        final cities = await cityService.getCities();
        emit(CityLoaded(cities));
      } catch (e) {
        emit(CityError(e.toString()));
      }
    });
  }
}

class CityService {
  Future<void> addCity(String name) async {
    final latLong = await getLatLongFromPlace(name);
    if (latLong.isNotEmpty) {
      final weatherData =
          await getWeather(latLong[0]['lat'], latLong[0]['lng'], name);
      if (weatherData.isNotEmpty) {
        final latestWeather = weatherData.first;
        print('Latest weather data: $latestWeather'); // Debug print
        await saveCity(
          name,
          latestWeather.time,
          latestWeather.temperature,
          latestWeather.humidity,
          latestWeather.windSpeed,
          latestWeather.visibility,
          latestWeather.weatherType,
          latestWeather.imagePath,
        );
      }
    }
  }

  Future<List<City>> getCities() async {
    final cities = await fetchCitiesFromAPI();
    print('Fetched cities: $cities'); // Debug print
    return cities;
  }

  Future<void> deleteCityByName(String cityName) async {
    await deleteCityFromAPI(cityName);
  }
}
