// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sensor_data.dart';

class DatabaseHelper {
  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'sensor_data.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE data(id INTEGER PRIMARY KEY, speed REAL, gForce REAL, timestamp TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertData(SensorData data) async {
    final db = await initializeDB();
    await db.insert('data', data.toMap());
  }

  static Future<List<SensorData>> fetchData() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> maps = await db.query('data');
    return List.generate(maps.length, (i) => SensorData.fromMap(maps[i]));
  }
}
