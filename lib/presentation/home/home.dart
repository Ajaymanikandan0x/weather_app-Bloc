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
      body: Container(
        decoration: _buildBackgroundDecoration(),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: BlocBuilder<WeatherBloc, WeatherState>(
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
        ),
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

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blueGrey[900]!, Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherData weatherData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 80, 8, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCityRow(context, weatherData),
                        _buildFavoriteIcon(context, weatherData),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.asset(weatherData.imagePath, height: 100),
                    Text(
                      '${weatherData.temperature} °C',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      weatherData.weatherType,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${DateFormat('hh:mm a').format(DateTime.parse(weatherData.time))} ${DateFormat('dd/MM/yyyy').format(DateTime.parse(weatherData.time))}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _buildWeatherDetailsRow(weatherData),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRow(BuildContext context, WeatherData weatherData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          weatherData.cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  Widget _buildWeatherDetailsRow(WeatherData weatherData) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail('Visibility', '${weatherData.visibility}',
                  'assets/icons/sun.png'),
              _buildWeatherDetail('Wind Speed', '${weatherData.windSpeed}',
                  'assets/icons/night.png'),
              // _buildWeatherDetail('Humidity', '${weatherData.humidity}%', 'assets/icons/humidity.png'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherDetail(
                  'Max Temp', '12 °C', 'assets/icons/high-temperature.png'),
              _buildWeatherDetail(
                  'Min Temp', '5 °C', 'assets/icons/temperature.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String title, String value, String iconPath) {
    return Row(
      children: [
        Image.asset(iconPath, scale: 8),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w300)),
          ],
        ),
      ],
    );
  }
}
