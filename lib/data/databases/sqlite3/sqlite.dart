import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:universal_html/html.dart' as html;
import 'package:your_cals/data/objects/entry.dart';

import 'package:your_cals/data/objects/food.dart';
import 'package:your_cals/data/databases/interfaces/database_helper_interface.dart';

// Platform-specific connection logic (web vs native)
import 'native_stubs/connection_stub.dart'
    if (dart.library.io) 'native_stubs/connection_native.dart'
    if (dart.library.html) 'native_stubs/connection_web.dart';

class SqliteDatabaseHelper implements DatabaseHelperInterface {
  late CommonDatabase _db;
  bool _isDbInitialized = false;

  static const String _dbName = 'your_cals.db';

  // --- Table Creation ---
  static const String _createFoodsTable = '''
    CREATE TABLE IF NOT EXISTS Foods (
      id TEXT PRIMARY KEY,
      barcode TEXT,   
      name TEXT,
      brand TEXT,
      calories_per_100 REAL,
      serving_size REAL,
      energy_kcal REAL,
      protein REAL,
      carbs REAL,
      sugar REAL,
      fiber REAL,
      fat REAL,
      saturated_fat REAL,
      unsaturated_fat REAL,
      sodium REAL,
      alcohol REAL,
      water REAL,
      created_at TEXT,
      updated_at TEXT
    );
  ''';

  static const String _createEntriesTable = '''
  CREATE TABLE IF NOT EXISTS Entries (
    id TEXT PRIMARY KEY,
    food_id TEXT NOT NULL,
    food_type TEXT NOT NULL,
    date TEXT NOT NULL,
    meal TEXT NOT NULL,
    amount REAL NOT NULL,
    measurement_type TEXT NOT NULL,
    created_at TEXT,
    updated_at TEXT
    );
  ''';

  // Add index for faster date queries
  static const String _createEntriesDateIndex = '''
    CREATE INDEX IF NOT EXISTS idx_entries_date ON Entries(date);
  ''';

  // --- Initialization ---
  @override
  Future<void> init() async {
    if (_isDbInitialized) return;
    _db = await openConnection();
    _db.execute('PRAGMA foreign_keys = ON;');
    _db.execute(_createFoodsTable);
    _db.execute(_createEntriesTable);
    _db.execute(_createEntriesDateIndex);
    _isDbInitialized = true;
  }

  // --- Import / Export / Delete ---
  @override
  Future<void> importDb(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) throw Exception('File bytes are null');

    if (kIsWeb) {
      writeDbBytes(_dbName, bytes);
      await init();
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, _dbName);
      final dbFile = File(dbPath);
      if (await dbFile.exists()) await dbFile.delete();
      await dbFile.writeAsBytes(bytes);
      await init();
    }
  }

  @override
  Future<void> exportDb(String? exportPath) async {
    final fileName = 'your_cals_export_${DateTime.now().toIso8601String()}.db';
    if (kIsWeb) {
      final bytes = await readDbBytes(_dbName);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none'
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      if (exportPath == null) throw Exception('Export path required');
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = join(dir.path, _dbName);
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) throw Exception('Database file missing');
      await dbFile.copy(exportPath);
    }
  }

  @override
  Future<void> deleteDb() async {
    if (!_isDbInitialized) return;
    _db.dispose();
    _isDbInitialized = false;
    if (kIsWeb) {
      deleteDbBytes(_dbName);
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(join(dir.path, _dbName));
      if (await file.exists()) await file.delete();
    }
    await init();
  }

  // --- Internal Helpers ---
  Future<int> _insert(String table, Map<String, dynamic> data) async {
    data['created_at'] = DateTime.now().toIso8601String();
    final keys = data.keys.toList();
    final values = data.values.toList();
    final placeholders = List.filled(keys.length, '?').join(',');
    final sql = 'INSERT INTO $table (${keys.join(',')}) VALUES ($placeholders)';
    final stmt = _db.prepare(sql);
    stmt.execute(values);
    final id = _db.lastInsertRowId;
    stmt.dispose();
    return id;
  }

  Future<int> _update(String table, Map<String, dynamic> data, String whereField, dynamic whereValue) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final keys = data.keys.toList();
    final values = [...keys.map((k) => data[k]), whereValue];
    final setClause = keys.map((k) => '$k = ?').join(', ');
    final sql = 'UPDATE $table SET $setClause WHERE $whereField = ?';
    final stmt = _db.prepare(sql);
    stmt.execute(values);
    final updatedRows = _db.updatedRows;
    stmt.dispose();
    return updatedRows;
  }

  Future<int> _delete(String table, String whereField, dynamic whereValue) async {
    final stmt = _db.prepare('DELETE FROM $table WHERE $whereField = ?');
    stmt.execute([whereValue]);
    final deleted = _db.updatedRows;
    stmt.dispose();
    return deleted;
  }

  // --- FOOD CRUD ---
  @override
  Future<int> insertFood(Food food) async => await _insert('Foods', food.toDbMap());

  @override
  Future<int> insertAllFoods(List<Food> foods) async {
    _db.execute('BEGIN TRANSACTION;');
    for (final f in foods) {
      _insert('Foods', f.toDbMap());
    }
    _db.execute('COMMIT;');
    return foods.length;
  }

  @override
  Future<int> updateFood(Food food) async {
    return await _update('Foods', food.toDbMap(), 'barcode', food.barcode);
  }

  @override
  Future<int> deleteFood(Food food) async {
    return await _delete('Foods', 'barcode', food.barcode);
  }

  @override
  Future<List<Food>> findFoods(String? name, String? barcode) async {
    String query = 'SELECT * FROM Foods WHERE 1=1';
    final params = <dynamic>[];
    if (name != null && name.isNotEmpty) {
      query += ' AND name LIKE ?';
      params.add('%$name%');
    }
    if (barcode != null && barcode.isNotEmpty) {
      query += ' AND barcode = ?';
      params.add(barcode);
    }

    final results = _db.select(query, params);
    return results.map((row) => Food.fromDb(row)).toList();
  }

  @override
  Future<Map<String, Food>> findFoodsById(List<String> ids) async {
    final placeholders = List.filled(ids.length, '?').join(', ');
    final query = 'SELECT * FROM Foods WHERE id IN ($placeholders)';

    final results = await _db.select(query, ids);
    final foodMap = <String, Food>{};
    for (final row in results) {
      final food = Food.fromDb(row);
      foodMap[food.id] = food;
    }
    return foodMap;
  }

  Future<List<Food>> getAllFoods() async {
    final results = _db.select('SELECT * FROM Foods');
    return results.map((row) => Food.fromDb(row)).toList();
  }

  // ENTRIES CRUD
  @override
  Future<String> insertEntry(Entry entry) async {
    // Generate ID if not provided
    final id = entry.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final entryWithId = entry.copyWith(id: id);
    await _insert('Entries', entryWithId.toMap());
    return id;
  }

  @override
  Future<int> updateEntry(Entry entry) async {
    if (entry.id == null) throw Exception('Entry ID is required for update');
    return await _update('Entries', entry.toMap(), 'id', entry.id);
  }

  @override
  Future<int> deleteEntry(Entry entry) async {
    if (entry.id == null) throw Exception('Entry ID is required for delete');
    return await _delete('Entries', 'id', entry.id);
  }

  @override
  Future<List<Entry>> getTodaysEntries() async {
    final today = DateTime.now();
    return await getEntriesByDate(today);
  }

  @override
  Future<List<Entry>> getEntriesByDate(DateTime date) async {
    // Get start and end of day
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = '''
    SELECT * FROM Entries 
    WHERE date >= ? AND date < ?
    ORDER BY date ASC
  ''';

    final results = _db.select(query, [startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    return results.map((row) => Entry.fromMap(row)).toList();
  }

  // Optional: Get entries for a date range
  Future<List<Entry>> getEntriesByDateRange(DateTime startDate, DateTime endDate) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day).add(const Duration(days: 1));

    final query = '''
    SELECT * FROM Entries 
    WHERE date >= ? AND date < ?
    ORDER BY date ASC
  ''';

    final results = _db.select(query, [start.toIso8601String(), end.toIso8601String()]);

    return results.map((row) => Entry.fromMap(row)).toList();
  }

  // Optional: Get entries by meal category
  Future<List<Entry>> getEntriesByMeal(DateTime date, MealCategory meal) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = '''
    SELECT * FROM Entries 
    WHERE date >= ? AND date < ? AND meal = ?
    ORDER BY date ASC
  ''';

    final results = _db.select(query, [startOfDay.toIso8601String(), endOfDay.toIso8601String(), meal.value]);

    return results.map((row) => Entry.fromMap(row)).toList();
  }

  // Optional: Delete all entries for a specific date
  Future<int> deleteEntriesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final stmt = _db.prepare('''
    DELETE FROM Entries 
    WHERE date >= ? AND date < ?
  ''');

    stmt.execute([startOfDay.toIso8601String(), endOfDay.toIso8601String()]);

    final deleted = _db.updatedRows;
    stmt.dispose();
    return deleted;
  }
}
