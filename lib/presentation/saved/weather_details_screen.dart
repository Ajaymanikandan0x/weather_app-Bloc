import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../file/weather_data/weatherdata.dart';

class WeatherDetailsScreen extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailsScreen({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    String formattedDate = '';
    if (weatherData.time.isNotEmpty) {
      try {
        formattedDate =
            '${DateFormat('hh:mm a').format(DateTime.parse(weatherData.time))} ${DateFormat('EEEE').format(DateTime.parse(weatherData.time))}';
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
        title: const Text(
          'Weather',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                      Text(
                        formattedDate,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(weatherData.imagePath,
                          height: 100), // Use the correct image path
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
                      const SizedBox(height: 20),
                      _buildWeatherDetailsRow(weatherData),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHourlyForecast(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetailsRow(WeatherData weatherData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: _buildWeatherDetail('Visibility',
                '${weatherData.visibility}%', 'assets/icons/sun.png')),
        Expanded(
            child: _buildWeatherDetail('Humidity', '${weatherData.humidity}%',
                'assets/icons/humidity.png')),
        Expanded(
            child: _buildWeatherDetail('Wind Speed',
                '${weatherData.windSpeed} km/h', 'assets/icons/wind.png')),
      ],
    );
  }

  Widget _buildWeatherDetail(String title, String value, String iconPath) {
    return Column(
      children: [
        Image.asset(iconPath, scale: 8),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w300)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w300)),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHourlyForecastItem('04:00', '08°', 'assets/icons/night.png'),
          _buildHourlyForecastItem('08:00', '11°', 'assets/icons/sun.png'),
          _buildHourlyForecastItem('12:00', '16°', 'assets/icons/sun.png'),
          _buildHourlyForecastItem('16:00', '18°', 'assets/icons/sun.png'),
          _buildHourlyForecastItem('20:00', '14°', 'assets/icons/night.png'),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastItem(String time, String temp, String iconPath) {
    return Column(
      children: [
        Text(time, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 5),
        Image.asset(iconPath, scale: 8),
        const SizedBox(height: 5),
        Text(temp, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
