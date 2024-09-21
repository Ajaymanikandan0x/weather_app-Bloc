import 'package:dio/dio.dart';

final dio = Dio();

Future<List<Map<String, dynamic>>> getLatLongFromPlace(String place) async {
  const String apiKey = '5e8757b129ec4f73b18782ea76a7e8f0';
  final String url =
      'https://api.opencagedata.com/geocode/v1/json?q=$place&key=$apiKey';

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data =
          response.data; // Directly access response data (already decoded)

      if (data['results'].isNotEmpty) {
        // Extract relevant data from each result
        List<Map<String, dynamic>> locations =
            data['results'].map<Map<String, dynamic>>((result) {
          return {
            'formatted': result['formatted'],
            'lat': result['geometry']['lat'],
            'lng': result['geometry']['lng'],
            'city': result['components']['city'],
            'state': result['components']['state'] ?? '',
            'country': result['components']['country'],
          };
        }).toList();

        return locations;
      } else {
        print('Place not found');
      }
    } else {
      print('Failed to get location, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching location data: $e');
  }

  return [];
}

// Weather codes from Tomorrow.io API (examples):
// 1000: Clear, 1100: Mostly Clear, 1101: Partly Cloudy, 1102: Mostly Cloudy,
// 2000: Fog, 2100: Light Fog, 4000: Drizzle, 4001: Rain, 4200: Light Rain,
// 5000: Snow, 6000: Freezing Drizzle, 6001: Freezing Rain

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

String getWeatherType(int weatherCode) {
  return weatherCodes[weatherCode] ??
      'Unknown'; // Return 'Unknown' if code not found
}

Future<List<WeatherData>> getWeather(double lat, double lng) async {
  const String apiKey = 'FPf5H7ASWYlpw3WbZFTe3RYLIUqZNTX7';
  final String url =
      'https://api.tomorrow.io/v4/weather/forecast?location=$lat,$lng&apikey=$apiKey';

  try {
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      final data = response.data;

      // Extract the minutely data
      final List<dynamic> minutelyData = data['timelines']['minutely'];

      // Map the minutely data to WeatherData objects
      return minutelyData.map<WeatherData>((item) {
        final int weatherCode = item['values']['weatherCode'];
        return WeatherData.fromJson(item, weatherCode);
      }).toList();
    } else {
      print('Failed to get weather data, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching weather data: $e');
  }

  return [];
}

//post using retrieve the historical data
Future<Map<String, dynamic>> getHistoricalData(double lat, double lng) async {
  const String apiKey = 'FPf5H7ASWYlpw3WbZFTe3RYLIUqZNTX7';
  const String url = 'https://api.tomorrow.io/v4/historical?apikey=$apiKey';

  final Map<String, dynamic> requestData = {
    "location": [lat, lng],
    "fields": ["temperature", "humidity"], // example fields
    "timesteps": ["1h"], // hourly data as an example
    "startTime": "2019-03-20T14:09:50Z",
    "endTime": "2019-03-28T14:09:50Z",
    "units": "metric",
    "timezone": "America/New_York"
  };

  try {
    final response = await dio.post(
      url,
      data: requestData,
      options: Options(
        headers: {
          'Accept-Encoding': 'gzip',
          'accept': 'application/json',
          'content-type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data; // Return the weather data
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
  return {}; // Return an empty map if there's an error
}

class WeatherData {
  final String time;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainIntensity;
  final String weatherType; 
  final String sunriseTime;
  final String sunsetTime; 
  final double visibilityAvg; 

  WeatherData({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainIntensity,
    
    required this.weatherType,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.visibilityAvg,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, int weatherCode) {
    return WeatherData(
      time: json['time'],
      temperature: json['values']['temperatureAvg'], 
      humidity: json['values']['humidityAvg'], 
      windSpeed: json['values']['windSpeedAvg'], 
      rainIntensity: json['values']['rainIntensityAvg'], 
      weatherType: getWeatherType(weatherCode), 
      sunriseTime: json['values']['sunriseTime'], 
      sunsetTime: json['values']['sunsetTime'], 
      visibilityAvg: json['values']['visibilityAvg'], 
    );
  }
}
