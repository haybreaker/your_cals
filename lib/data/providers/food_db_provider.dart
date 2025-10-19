import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:csv/csv.dart';

class FoodDatabaseProvider extends ChangeNotifier {
  static const _dataUrl = 'https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz';
  static const _refreshInterval = Duration(days: 7);

  late Database _db;
  bool isPullingLatest = false;
  double percentageOfDownload = 0.0;
  DateTime? lastUpdated;

  Database get db => _db;

  /// Initialize the shared SQLite database and refresh data if outdated.
  Future<void> initialize(Database existingDb) async {
    _db = existingDb;

    // Ensure the Foods table exists
    _db.execute('''
      CREATE TABLE IF NOT EXISTS Foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        product_name TEXT,
        energy_100g REAL,
        proteins_100g REAL,
        fat_100g REAL,
        carbohydrates_100g REAL
      );
    ''');

    final dir = await getApplicationDocumentsDirectory();
    final lastFile = File('${dir.path}/last_update.txt');

    if (await lastFile.exists()) {
      lastUpdated = DateTime.tryParse(await lastFile.readAsString());
    }

    final needsUpdate = lastUpdated == null || DateTime.now().difference(lastUpdated!) > _refreshInterval;

    if (needsUpdate) {
      unawaited(_refreshData(lastFile));
    }
  }

  Future<void> _refreshData(File lastFile) async {
    isPullingLatest = true;
    percentageOfDownload = 0;
    notifyListeners();

    try {
      final tempDir = await getTemporaryDirectory();
      final gzPath = '${tempDir.path}/openfoodfacts.csv.gz';
      final csvPath = '${tempDir.path}/openfoodfacts.csv';

      // Download gzipped CSV
      final request = http.Request('GET', Uri.parse(_dataUrl));
      final response = await http.Client().send(request);

      final total = response.contentLength ?? 0;
      int received = 0;
      final sink = File(gzPath).openWrite();

      await for (final chunk in response.stream) {
        received += chunk.length;
        if (total > 0) percentageOfDownload = received / total;
        sink.add(chunk);
        notifyListeners();
      }
      await sink.close();

      // Decompress
      final bytes = await File(gzPath).readAsBytes();
      final decompressed = GZipDecoder().decodeBytes(bytes);
      await File(csvPath).writeAsBytes(decompressed);

      // Parse and import
      final csvContent = await File(csvPath).readAsString();
      final rows = const CsvToListConverter(eol: '\n', fieldDelimiter: '\t').convert(csvContent, shouldParseNumbers: false);

      _db.execute('DELETE FROM Foods;');
      final insertStmt = _db.prepare('''
        INSERT INTO Foods (code, product_name, energy_100g, proteins_100g, fat_100g, carbohydrates_100g)
        VALUES (?, ?, ?, ?, ?, ?);
      ''');

      final totalRows = rows.length;
      for (int i = 1; i < totalRows; i++) {
        final r = rows[i];
        if (r.length < 10) continue;

        insertStmt.execute([
          r[0]?.toString(),
          r[1]?.toString(),
          double.tryParse(r[5]?.toString() ?? '') ?? 0,
          double.tryParse(r[6]?.toString() ?? '') ?? 0,
          double.tryParse(r[7]?.toString() ?? '') ?? 0,
          double.tryParse(r[8]?.toString() ?? '') ?? 0,
        ]);

        if (i % 1000 == 0) {
          percentageOfDownload = i / totalRows;
          notifyListeners();
        }
      }

      insertStmt.dispose();

      await lastFile.writeAsString(DateTime.now().toIso8601String());
      lastUpdated = DateTime.now();
    } catch (e, st) {
      debugPrint('Error updating food DB: $e\n$st');
    } finally {
      isPullingLatest = false;
      percentageOfDownload = 0;
      notifyListeners();
    }
  }
}
