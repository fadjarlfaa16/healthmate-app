import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LogDatabase {
  static final LogDatabase instance = LogDatabase._init();
  static Database? _db;

  LogDatabase._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('activity_logs.db');
    return _db!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        userId    TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        action    TEXT NOT NULL
      );
    ''');
  }

  Future<void> insertLog(String userId, String action) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();
    await db.insert('logs', {
      'userId': userId,
      'timestamp': now,
      'action': action,
    });
  }

  Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await instance.database;
    return db.query('logs', orderBy: 'timestamp DESC');
  }
}
