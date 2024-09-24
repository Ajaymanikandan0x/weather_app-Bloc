class Model {
  final String cityName; // City name
  final String time; // Time of the weather data
  final double temperature; // Current temperature
  final double humidity; // Current humidity
  final double windSpeed; // Wind speed
  final double visibility; // Visibility
  final String weatherType; // Weather type
  final String imagePath; // Image path

  Model(this.cityName, this.time, this.temperature, this.humidity, this.windSpeed,
       this.visibility, this.weatherType, this.imagePath);

  factory Model.fromMap(Map<String, dynamic> map) => Model(
      map['name'],
      map['datetime'],
      map['temperature'],
      map['humidity'],
      map['windSpeed'],
      map['visibility'],
      map['weatherType'],
      map['imagePath']);

  Map<String, dynamic> toMap() => {
        'name': cityName,
        'datetime': time,
        'temperature': temperature,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'visibility': visibility,
        'weatherType': weatherType,
        'imagePath': imagePath,
      };
}
