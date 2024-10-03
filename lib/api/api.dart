import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../file/city_data.dart';
import '../file/weather_data/weatherdata.dart';
import 'api_key.dart';

final dio = Dio();

Future<List<Map<String, dynamic>>> getLatLongFromPlace(String place) async {
  const String apiKey = apiKeyGeoLocate; // Add 'const' here
  final String url =
      'https://api.opencagedata.com/geocode/v1/json?q=$place&key=$apiKey';

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;

      if (data['results'].isNotEmpty) {
        List<Map<String, dynamic>> locations =
            data['results'].map<Map<String, dynamic>>((result) {
          final components = result['components'];
          return {
            'formatted': result['formatted'],
            'lat': result['geometry']['lat'],
            'lng': result['geometry']['lng'],
            'city': components['city'] ?? components['_normalized_city'] ?? '',
            'state': components['state'] ?? '',
            'country': components['country'] ?? '',
          };
        }).toList();

        return locations;
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching location data: $e');
    }
  }

  return [];
}

final Map<int, String> weatherCodes = {
  1000: 'Clear, Sunny',
  1100: 'Mostly Clear',
  1101: 'Partly Cloudy',
  1102: 'Mostly Cloudy',
  1001: 'Cloudy',
  2000: 'Fog',
  2100: 'Light Fog',
  4000: 'Drizzle',
  4001: 'Rain',
  4200: 'Light Rain',
  4201: 'Heavy Rain',
  5000: 'Snow',
  5001: 'Flurries',
  5100: 'Light Snow',
  5101: 'Heavy Snow',
  6000: 'Freezing Drizzle',
  6001: 'Freezing Rain',
  6200: 'Light Freezing Rain',
  6201: 'Heavy Freezing Rain',
  7000: 'Ice Pellets',
  7101: 'Heavy Ice Pellets',
  7102: 'Light Ice Pellets',
  8000: 'Thunderstorm',
};

final Map<int, String> weatherImages = {
  1000: 'assets/icons/clear-sky.png',
  1100: 'assets/icons/sunny.png',
  1101: 'assets/icons/cloud.png',
  1102: 'assets/icons/cloudy.png',
  1001: 'assets/icons/cloudy.png',
  2000: 'assets/icons/fog.png',
  2100: 'assets/icons/fog.png',
  4000: 'assets/icons/drizzle.png',
  4001: 'assets/icons/rain.png',
  4200: 'assets/icons/heavy-rain.png',
  4201: 'assets/icons/heavy-rain1.png',
  5000: 'assets/icons/snow.png',
  5001: 'assets/icons/flurries.png',
  5100: 'assets/icons/snowflakes.png',
  5101: 'assets/icons/snow.png',
  6000: 'assets/icons/drizzle.png',
  6001: 'assets/icons/freezing-rain.png',
  6200: 'assets/icons/freezing-rain.png',
  6201: 'assets/icons/freezing.png',
  7000: 'assets/icons/winter.png',
  7101: 'assets/icons/winter.png',
  7102: 'assets/icons/winter.png',
  8000: 'assets/icons/thunderstorm.png',
};

String getWeatherType(int weatherCode) {
  return weatherCodes[weatherCode] ?? 'Unknown';
}

Future<List<WeatherData>> getWeather(
    double lat, double lng, String cityname) async {
  const String apiKey = apiKeyTomorrow; 
  final String url =
      'https://api.tomorrow.io/v4/weather/forecast?location=$lat,$lng&apikey=$apiKey';

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;

      final List<dynamic> minutelyData = data['timelines']['minutely'];

      return minutelyData.map<WeatherData>((item) {
        final int weatherCode = item['values']['weatherCode'];
        return WeatherData.fromJson(item, weatherCode, cityname);
      }).toList();
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching weather data: $e');
    }
  }

  return [];
}

const String baseUrl = 'http://10.0.2.2:50768';

Future<void> saveCity(
    String name,
    String datetime,
    double temperature,
    double humidity,
    double windSpeed,
    double visibility,
    String weatherType,
    String imagePath) async {
  final String url = '$baseUrl/addCity';

  try {
    final response = await dio.post(url, data: {
      'name': name,
      'datetime': datetime,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'visibility': visibility,
      'weatherType': weatherType,
      'imagePath': imagePath,
    });

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('City saved successfully');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error saving city: $e');
    }
  }
}

Future<List<City>> fetchCitiesFromAPI() async {
  const String url = '$baseUrl/getCities'; // Change 'final' to 'const'

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final List<dynamic>? data = response.data;
      if (data != null) {
        return data.map<City>((item) {
          return City(
            name: item['name'] ?? '',
            weatherData: WeatherData(
              cityName: item['name'] ?? '',
              temperature: (item['temperature'] as num?)?.toDouble() ?? 0.0,
              weatherType: item['weatherType'] ?? '',
              time: item['datetime'] ?? '',
              visibility: (item['visibility'] as num?)?.toDouble() ?? 0.0,
              windSpeed: (item['windSpeed'] as num?)?.toDouble() ?? 0.0,
              humidity: (item['humidity'] as num?)?.toDouble() ?? 0.0,
              imagePath: item['imagePath'] ?? '',
            ),
          );
        }).toList();
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching cities: $e');
    }
  }

  return [];
}

Future<void> deleteCityFromAPI(String cityName) async {
  final String url = '$baseUrl/deleteCity/$cityName';

  try {
    final response = await dio.delete(url);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('City deleted successfully');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error deleting city: $e');
    }
  }
}
