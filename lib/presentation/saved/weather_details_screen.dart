import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../file/weather_data/weatherdata.dart';

class WeatherDetailsScreen extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailsScreen({Key? key, required this.weatherData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (weatherData.time.isNotEmpty) {
      try {
        formattedDate = '${DateFormat('hh:mm a').format(DateTime.parse(weatherData.time))} ${DateFormat('dd/MM/yyyy').format(DateTime.parse(weatherData.time))}';
      } catch (e) {
        formattedDate = 'Invalid date';
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
        ),
        title: Text(
          weatherData.cityName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.white.withOpacity(0.1),
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        weatherData.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(weatherData.imagePath, height: 100), // Use the correct image path
                      Text(
                        '${weatherData.temperature} °C',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        weatherData.weatherType,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formattedDate,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildWeatherDetailsRow(weatherData),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(WeatherData weatherData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeatherDetail('Visibility', '${weatherData.visibility}',
                'assets/icons/sun.png'),
            _buildWeatherDetail('Wind Speed', '${weatherData.windSpeed}',
                'assets/icons/night.png'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeatherDetail(
                'Max Temp', '12 °C', 'assets/icons/high-temperature.png'),
            _buildWeatherDetail(
                'Min Temp', '5 °C', 'assets/icons/temperature.png'),
          ],
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
