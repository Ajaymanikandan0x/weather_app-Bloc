import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temp_tide/presentation/home/home.dart';
import 'package:temp_tide/presentation/saved/saved_screen.dart';

import 'logic/current_weather/weather_bloc.dart';
import 'logic/saved_city_bloc/city_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherBloc>(
          create: (context) => WeatherBloc(),
        ),
        BlocProvider<CityBloc>(
          create: (context) => CityBloc(CityService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          appBarTheme:
              const AppBarTheme(color: Color.fromARGB(235, 235, 235, 255)),
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        // home: Home(),
        routes: {
          '/': (context) => Home(),
          '/saved': (context) => const SavedScreen(),
        },
      ),
    );
  }
}
