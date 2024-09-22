import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:temp_tide/logic/db/model.dart';

class DatabaseHelper {
  static const _databaseName = 'student.db';
  static const _databaseVersion = 1;
  static const table = 'weather_data'; // Updated table name
  static const columnId = '_id';
  static const columnCityName = 'cityName'; // Added column for city name
  static const columnTime = 'time'; // Added column for time
  static const columnTemperature = 'temperature'; // Added column for temperature
  static const columnHumidity = 'humidity'; // Added column for humidity
  static const columnWindSpeed = 'windSpeed'; // Added column for wind speed
  static const columnRainIntensity = 'rainIntensity'; // Added column for rain intensity
  static const columnVisibility = 'visibility'; // Added column for visibility
  static const columnWeatherType = 'weatherType'; // Added column for weather type

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCityName TEXT NOT NULL,
        $columnTime TEXT NOT NULL,
        $columnTemperature REAL NOT NULL,
        $columnHumidity REAL NOT NULL,
        $columnWindSpeed REAL NOT NULL,
        $columnRainIntensity REAL NOT NULL,
        $columnVisibility REAL NOT NULL,
        $columnWeatherType TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCity(Model model) async { // Parameter remains 'model'
    try {
      final db = await database;
      int id = await db.insert(table, model.toMap()); // Use model.toMap()
      print("Weather data inserted successfully with id: $id"); // Updated message
      return id;
    } catch (e) {
      print("Error inserting weather data: $e"); // Updated message
      return -1; // or any other error code you prefer
    }
  }

  Future<List<Model>> getCity() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(table);

      print("Fetched ${maps.length} cities from the database"); // Updated message

      List<Model> cities = List.generate( // Changed variable name to 'cities'
        maps.length,
        (index) => Model.fromMap(maps[index]), // Use Model.fromMap()
      );

      print("Generated list of cities:");
      for (var city in cities) { // Changed variable name to 'city'
        print(city);
      }

      return cities; // Return 'cities'
    } catch (e) {
      print("Error fetching cities: $e"); // Updated message
      return [];
    }
  }

  Future<int> deleteCity(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId=?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCityByName(String cityName) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnCityName=?',
      whereArgs: [cityName],
    );
  }
}
