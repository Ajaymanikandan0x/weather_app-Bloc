import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:temp_tide/api/api_key.dart';
import 'package:temp_tide/main.dart';
import 'package:temp_tide/logic/current_weather/weather_bloc.dart';
import 'package:temp_tide/logic/saved_city_bloc/city_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockDio extends Mock implements Dio {}
class MockCityService extends Mock implements CityService {}

void main() {
  testWidgets('Weather app displays city name', (WidgetTester tester) async {
    // Create a mock Dio and CityService
    final mockDio = MockDio();
    final mockCityService = MockCityService();

    // Define the URL used in the API call
    const String url = 'https://api.opencagedata.com/geocode/v1/json?q=Kochi&key=$apiKeyGeoLocate';
    const String url2 = 'https://api.tomorrow.io/v4/weather/forecast?location=9.9312,76.2673&apikey=$apiKeyTomorrow';

    // Set up the mock response for location
    when(mockDio.get(url)).thenAnswer((_) async => Response(
      data: {
        'results': [
          {
            'formatted': 'Kochi, India',
            'geometry': {'lat': 9.9312, 'lng': 76.2673},
            'components': {'city': 'Kochi', 'country': 'India'}
          }
        ]
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: url),
    ));

    // Set up the mock response for weather
    when(mockDio.get(url2)).thenAnswer((_) async => Response(
      data: {
        'timelines': {
          'minutely': [
            {
              'values': {
                'weatherCode': 1000,
              }
            }
          ]
        }
      },
      statusCode: 200,
      requestOptions: RequestOptions(path: url2),
    ));

    // Mock any other necessary methods on mockCityService
    when(mockCityService.getCities()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WeatherBloc>(
            create: (context) => WeatherBloc(),
          ),
          BlocProvider<CityBloc>(
            create: (context) => CityBloc(mockCityService),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Wait for any asynchronous operations to complete.
    await tester.pumpAndSettle();

    // Check if the city name 'Kochi' is displayed
    expect(find.text('Kochi'), findsOneWidget);
  });
}
