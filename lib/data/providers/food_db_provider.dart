import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:your_cals/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_cals/data/objects/food.dart';
import 'package:your_cals/data/objects/macros.dart';
import 'package:your_cals/data/objects/open_food_facts_lookup.dart'; // Import the enum

/// Provider that manages syncing and loading foods from OpenFoodFacts
/// into the local SQLite database.
class FoodDatabaseProvider extends ChangeNotifier {
  final DatabaseHelperInterface dbHelper;
  static const _dataUrl = 'https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz';
  static const _refreshInterval = Duration(days: 7);
  static const _batchSize = 500; // Insert in batches

  bool isPullingLatest = false;
  double percentageOfDownload = 0.0;
  DateTime? lastUpdated;

  FoodDatabaseProvider({required this.dbHelper});

  /// Initializes the DB (creates table if needed and refreshes if outdated)
  Future<void> initialize() async {
    await dbHelper.init();

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

  /// Refreshes data by downloading, decompressing, and importing.
  Future<void> _refreshData(File lastFile) async {
    isPullingLatest = true;
    percentageOfDownload = 0;
    notifyListeners();

    try {
      final tempDir = await getTemporaryDirectory();
      final gzPath = '${tempDir.path}/openfoodfacts.csv.gz';

      // --- Download CSV ---
      final request = http.Request('GET', Uri.parse(_dataUrl));
      final response = await http.Client().send(request);

      final total = response.contentLength ?? 0;
      int received = 0;
      final sink = File(gzPath).openWrite();

      await for (final chunk in response.stream) {
        received += chunk.length;
        if (total > 0) percentageOfDownload = (received / total) * 0.3; // 30% for download
        sink.add(chunk);
        notifyListeners();
      }
      await sink.close();

      percentageOfDownload = 0.3;
      notifyListeners();

      // --- Stream decompress and parse directly ---
      await _streamDecompressAndParse(gzPath);

      // Clean up gz file
      await File(gzPath).delete();

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

  /// Stream decompress the gzip file and parse CSV line by line
  Future<void> _streamDecompressAndParse(String gzPath) async {
    final file = File(gzPath);

    // Stream decompress the gzip file directly
    final stream = file.openRead().transform(gzip.decoder).transform(utf8.decoder).transform(const LineSplitter());

    bool isFirstLine = true;
    List<Food> batch = [];
    int lineCount = 0;

    percentageOfDownload = 0.4;
    notifyListeners();

    await for (final line in stream) {
      if (isFirstLine) {
        isFirstLine = false;
        continue; // Skip header
      }

      lineCount++;

      try {
        // Parse tab-delimited line
        final fields = line.split('\t');

        // Need at least enough fields to access the highest index we use
        if (fields.length <= OpenFoodFactsCsv.proteins100g.index) continue;

        // Extract fields using the enum
        final barcode = OpenFoodFactsCsv.code.getField(fields);
        final name = OpenFoodFactsCsv.productName.getField(fields);
        final brand = OpenFoodFactsCsv.brands.getField(fields);

        // Parse nutritional values safely using enum helper methods
        final energyKcal = OpenFoodFactsCsv.energyKcal100g.getDouble(fields) ?? 0;
        final fat = OpenFoodFactsCsv.fat100g.getDouble(fields) ?? 0;
        final carbs = OpenFoodFactsCsv.carbohydrates100g.getDouble(fields) ?? 0;
        final protein = OpenFoodFactsCsv.proteins100g.getDouble(fields) ?? 0;

        // Skip items with no nutritional data
        if (energyKcal == 0 && fat == 0 && carbs == 0 && protein == 0) continue;

        // Skip items without name
        if (name.isEmpty) continue;

        // Generate ID if barcode is empty
        // Use a hash of name + brand to create a unique, deterministic ID
        final foodId = Uuid().v4().toString();

        final food = Food(
          id: foodId,
          barcode: barcode, // Now stores either barcode or generated ID
          name: name,
          caloriesPerHundred: energyKcal,
          servingSize: 100,
          brand: brand,
          macros: Macros(energyKcal: energyKcal, protein: protein, fat: fat, carbs: carbs),
        );

        batch.add(food);

        // Insert in batches
        if (batch.length >= _batchSize) {
          await dbHelper.insertAllFoods(batch);
          batch.clear();

          // Update progress (40% to 100%)
          // Estimate based on line count - OpenFoodFacts has ~3M products
          percentageOfDownload = 0.4 + (lineCount / 3000000) * 0.6;
          if (percentageOfDownload > 0.99) percentageOfDownload = 0.99;

          if (lineCount % 5000 == 0) {
            notifyListeners();
          }
        }
      } catch (e) {
        // Skip malformed lines
        if (kDebugMode && lineCount < 100) {
          debugPrint('Error parsing line $lineCount: $e');
        }
      }
    }

    // Insert remaining batch
    if (batch.isNotEmpty) {
      await dbHelper.insertAllFoods(batch);
    }

    percentageOfDownload = 1.0;
    notifyListeners();
  }

  // --- API for UI / Logic ---
  Future<List<Food>> getFoods() async {
    return await dbHelper.findFoods(null, null);
  }

  Future<List<Food>> searchFoods(String query) async {
    return await dbHelper.findFoods(query, null);
  }
}
