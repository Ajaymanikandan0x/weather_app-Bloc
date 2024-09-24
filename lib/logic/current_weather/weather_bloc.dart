import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:temp_tide/api/api.dart';

import '../../file/weather_data/weatherdata.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        final locations = await getLatLongFromPlace(event.place);
        if (locations.isNotEmpty) {
          final weatherDataList = await getWeather(
              locations[0]['lat'], locations[0]['lng'], locations[0]['city']);
          print('Weather data list: $weatherDataList'); // Debug print
          emit(WeatherSuccess(weatherDataList));
        } else {
          emit(WeatherFailure());
        }
      } catch (e) {
        print('Error in WeatherBloc: $e'); // Debug print
        emit(WeatherFailure());
      }
    });
  }
}
