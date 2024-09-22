class Model {
  final String cityName; // City name
  final String time; // Time of the weather data
  final double temperature; // Current temperature
  final double humidity; // Current humidity
  final double windSpeed; // Wind speed
  final double rainIntensity; // Rain intensity
  final double visibility; // Visibility
  final String weatherType;

  Model(this.cityName, this.time, this.temperature, this.humidity, this.windSpeed,
      this.rainIntensity, this.visibility, this.weatherType);

  factory Model.fromMap(Map<String, dynamic> map) => Model(
      map['cityName'],
      map['time'],
      map['temperature'],
      map['humidity'],
      map['windSpeed'],
      map['rainIntensity'],
      map['visibility'],
      map['weatherType']);

  Map<String, dynamic> toMap() => {
        'cityName': cityName,
        'time': time,
        'temperature': temperature,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'rainIntensity': rainIntensity,
        'visibility': visibility,
        'weatherType': weatherType,
      };
}
