import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temp_tide/presentation/home/home.dart';

import 'logic/weather_bloc.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme:
              const AppBarTheme(color: Color.fromARGB(235, 235, 235, 255)),
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        home: Home(),
      ),
    );
  }
}
