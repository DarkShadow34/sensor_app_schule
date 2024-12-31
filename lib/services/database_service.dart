import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  // Initialize database
  static Future<void> initializeDatabase() async {
    if (_database != null) return;

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'sensor_data.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE sensor_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            speed REAL,
            gForce REAL,
            lapTime TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  // Save data to the database using named parameters
  static Future<void> saveData({
    required double speed,
    required double gForce,
    required String lapTime,
  }) async {
    await _database?.insert('sensor_data', {
      'speed': speed,
      'gForce': gForce,
      'lapTime': lapTime,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Retrieve all data
  static Future<List<Map<String, dynamic>>> getAllData() async {
    return await _database?.query('sensor_data', orderBy: 'timestamp DESC') ?? [];
  }
}
