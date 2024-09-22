part of 'city_bloc.dart';

@immutable
sealed class CityState {}

final class CityInitial extends CityState {}

final class CityLoading extends CityState {}

final class CityLoaded extends CityState {
  final List<City> cities;

  CityLoaded({required this.cities});
}

final class CityError extends CityState {
  final String error;

  CityError({required this.error});
}

final class CitySaved extends CityState {} // Define CitySaved state

