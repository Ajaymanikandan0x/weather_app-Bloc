

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:temp_tide/logic/saved_city_bloc/city_bloc.dart';

import '../../logic/saved_city_bloc/city_event.dart';
import '../../logic/saved_city_bloc/city_state.dart';
import 'weather_details_screen.dart'; // Import the new weather details screen

class SavedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // FetchCities event to load the saved cities
    BlocProvider.of<CityBloc>(context).add(FetchCities());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Saved Cities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Improved search bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        hintText: 'Search cities',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<CityBloc, CityState>(
                    builder: (context, state) {
                      if (state is CityLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is CityLoaded) {
                        if (state.cities.isEmpty) {
                          return const Center(
                            child: Text(
                              'No saved cities',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.cities.length,
                          itemBuilder: (context, index) {
                            final city = state.cities[index];
                            String formattedDate = '';
                            if (city.weatherData.time.isNotEmpty) {
                              try {
                                formattedDate = DateFormat('EEEE dd •')
                                    .add_jm()
                                    .format(
                                        DateTime.parse(city.weatherData.time));
                              } catch (e) {
                                formattedDate = 'Invalid date';
                              }
                            }

                            // Get the correct weather icon path
                            String weatherIcon = city.weatherData.imagePath;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WeatherDetailsScreen(
                                      weatherData: city.weatherData,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.transparent,
                                elevation: 0,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        weatherIcon,
                                        height: 80,
                                        width: 80,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${city.weatherData.temperature}°',
                                              style: const TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              city.weatherData.weatherType,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              city.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is CityError) {
                        return Center(
                            child: Text(state.error,
                                style: const TextStyle(color: Colors.red)));
                      }
                      return Container(); // Fallback widget if no state matches
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
