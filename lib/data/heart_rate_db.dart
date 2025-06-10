import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/heart_rate_model.dart';

class HeartRateDb {
  static Database? _db;

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'heart_rate.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE heart_rate(id INTEGER PRIMARY KEY AUTOINCREMENT, bpm INTEGER, timestamp TEXT)',
        );
      },
      version: 1,
    );
    return _db!;
  }

  static Future<void> insert(HeartRateModel model) async {
    final db = await getDb();
    await db.insert('heart_rate', {
      'bpm': model.bpm,
      'timestamp': model.timestamp.toIso8601String(),
    });
  }

  static Future<List<HeartRateModel>> getByDate(DateTime date) async {
    final db = await getDb();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));
    final maps = await db.query(
      'heart_rate',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'timestamp ASC',
    );
    return maps
        .map(
          (m) => HeartRateModel(
            bpm: m['bpm'] as int,
            timestamp: DateTime.parse(m['timestamp'] as String),
          ),
        )
        .toList();
  }

  static Future<void> clearAll() async {
    final db = await getDb();
    await db.delete('heart_rate');
  }
}
