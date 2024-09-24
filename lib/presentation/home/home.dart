import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../file/weather_data/weatherdata.dart';
import '../../logic/current_weather/weather_bloc.dart';
import '../../logic/saved_city_bloc/city_bloc.dart';
import '../../logic/saved_city_bloc/city_event.dart';
import '../../logic/saved_city_bloc/city_state.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    context.read<CityBloc>().add(FetchCities());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackgroundDecoration(), // Now this will wrap the background in a Container
          BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is WeatherFailure) {
                return const Center(
                    child: Text('Failed to fetch weather data.',
                        style: TextStyle(color: Colors.white)));
              } else if (state is WeatherSuccess) {
                if (state.weatherDataList.isEmpty) {
                  return const Center(
                      child: Text('No weather data available.',
                          style: TextStyle(color: Colors.white)));
                }
                final weatherData = state.weatherDataList.first;
                return _buildWeatherContent(context, weatherData);
              }
              return const Center(
                  child: Text('Enter a place to get weather.',
                      style: TextStyle(color: Colors.white)));
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      title: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Search place...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white54),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: (place) {
          if (place.isNotEmpty) {
            context.read<WeatherBloc>().add(FetchWeather(place));
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite, size: 30), // Ensure it's big enough
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0), // Added padding
          onPressed: () {
            Navigator.pushNamed(context, '/saved');
          },
        ),
      ],
    );
  }

  /// Wrap the background decoration in a Container
  Widget _buildBackgroundDecoration() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[900]!, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weatherData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 80, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // City Name and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weatherData.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildFavoriteIcon(context, weatherData), // Added favorite icon
              ],
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('hh:mm a').format(DateTime.parse(weatherData.time)),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            // Weather Icon and Temperature
            Image.asset(
              weatherData.imagePath,
              height: 120,
            ),
            Text(
              '${weatherData.temperature}°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              weatherData.weatherType,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 40),
            // Hourly Weather Details (Scrollable)
            _buildHourlyWeather(),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon(BuildContext context, WeatherData weatherData) {
    return BlocBuilder<CityBloc, CityState>(
      builder: (context, cityState) {
        print('CityState: $cityState'); // Debug print
        if (cityState is CityLoaded) {
          final isSaved = cityState.cities
              .any((city) => city.weatherData.cityName == weatherData.cityName);
          return Padding(
            padding: const EdgeInsets.all(8.0), // Added padding
            child: IconButton(
              icon: Icon(
                isSaved ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 30, // Ensure the size is noticeable
              ),
              onPressed: () {
                if (isSaved) {
                  context
                      .read<CityBloc>()
                      .add(DeleteCityByName(weatherData.cityName));
                } else {
                  context.read<CityBloc>().add(AddCity(weatherData.cityName));
                }
              },
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildHourlyWeather() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Hourly Forecast',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(6, (index) {
                // Sample hourly data, replace with actual data
                final time =
                    ['9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM'][index];
                final temp = [18, 19, 24, 25, 26, 27][index];
                final icon = Icons.wb_sunny;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Icon(icon, color: Colors.white, size: 40),
                      const SizedBox(height: 5),
                      Text(
                        '$temp°',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
