import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/nutriments.dart';

/// Result of OCR-based nutritional info extraction.
class NutritionalInfoResult {
  const NutritionalInfoResult({
    this.name,
    this.brand,
    this.servingSize,
    this.servingUnit,
    this.isLiquid,
    this.per100,
    this.barcode,
  });

  final String? name;
  final String? brand;
  final double? servingSize;
  final String? servingUnit; // 'g' or 'ml'
  final bool? isLiquid;
  final Nutriments? per100;
  final String? barcode;
}

/// Scan strategy for different image conditions.
enum ScanStrategy {
  /// Standard scan - best for well-lit, flat labels
  standard,
  /// High contrast - helps with low-light or reflective surfaces
  highContrast,
  /// Crop to table - attempts to isolate the nutrition table region
  cropToTable,
}

/// On-device OCR service for parsing AU/NZ nutrition information labels.
///
/// Uses Google ML Kit text recognition with proper table reconstruction:
/// - Analyzes block/line/element hierarchy to find the nutrition table
/// - Detects column boundaries from header row ("Per 100g" | "Per serve")
/// - Parses rows by aligning elements to detected columns
/// - Handles both per-100g and per-serve values with conversion
class NutritionalInfoScanner {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Scan an image file and extract nutritional information.
  Future<NutritionalInfoResult> scanFromImage(
    String imagePath, {
    ScanStrategy strategy = ScanStrategy.standard,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _textRecognizer.processImage(inputImage);
    return _parseNutritionLabel(recognized, strategy);
  }

  void dispose() => _textRecognizer.close();

  // ─── Main parsing logic ──────────────────────────────────────────────

  NutritionalInfoResult _parseNutritionLabel(
    RecognizedText recognized,
    ScanStrategy strategy,
  ) {
    // Step 1: Extract all text elements with positions
    final elements = <_TextElement>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          if (element.text.trim().isNotEmpty) {
            elements.add(_TextElement(
              text: element.text.trim(),
              rect: element.boundingBox,
              blockRect: block.boundingBox,
            ));
          }
        }
      }
    }

    if (elements.isEmpty) return const NutritionalInfoResult();

    // Step 2: Find serving size (usually near top)
    final servingInfo = _extractServingSize(elements);

    // Step 3: Find barcode
    final barcode = _extractBarcode(elements);

    // Step 4: Find and parse nutrition table
    final table = _findNutritionTable(elements);
    final per100 = table != null ? _parseTable(table, servingInfo.size) : null;

    // Step 5: Try to extract product name/brand from text above table
    final nameBrand = _extractNameBrand(elements, table);

    return NutritionalInfoResult(
      name: nameBrand.$1,
      brand: nameBrand.$2,
      servingSize: servingInfo.size,
      servingUnit: servingInfo.unit,
      isLiquid: servingInfo.isLiquid,
      per100: per100,
      barcode: barcode,
    );
  }

  // ─── Serving size extraction ────────────────────────────────────────

  _ServingInfo _extractServingSize(List<_TextElement> elements) {
    double? size;
    String? unit;
    bool? isLiquid;

    // Sort by vertical position (top to bottom)
    final sorted = [...elements]..sort((a, b) => a.rect.top.compareTo(b.rect.top));

    for (final el in sorted.take(20)) { // Check top 20 elements
      final text = el.text.toLowerCase();

      // "Serving size: 30g" or "Serve: 100ml"
      final serveMatch = RegExp(
        r'(?:serving\s+size|serve(?:s)?\s+(?:size)?)[:\s]+(\d+(?:\.\d+)?)\s*(g|ml|kg|l)',
        caseSensitive: false,
      ).firstMatch(text);
      if (serveMatch != null) {
        size = double.tryParse(serveMatch.group(1)!);
        unit = serveMatch.group(2)!.toLowerCase();
        isLiquid = unit == 'ml' || unit == 'l';
        break;
      }

      // "Servings per pack: 10" - look for this too
      final perPackMatch = RegExp(
        r'servings?\s+per\s+(?:pack|package|serving)[:\s]+(\d+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (perPackMatch != null) {
        // Could use this to validate per-serve values
      }
    }

    return _ServingInfo(size: size, unit: unit, isLiquid: isLiquid);
  }

  String? _extractBarcode(List<_TextElement> elements) {
    for (final el in elements) {
      final match = RegExp(r'\b(\d{12,13})\b').firstMatch(el.text);
      if (match != null) return match.group(1);
    }
    return null;
  }

  // ─── Nutrition table detection & parsing ───────────────────────────

  /// Finds the nutrition table by looking for column headers.
  /// Returns a list of rows, each row is a map of column index -> text.
  _NutritionTable? _findNutritionTable(List<_TextElement> elements) {
    // First, find elements that look like column headers
    int? headerRowY;
    List<_ColumnHeader>? headers;

    // Group elements by approximate Y position (rows)
    final rows = _groupByRows(elements);

    for (final row in rows) {
      final rowText = row.map((e) => e.text.toLowerCase()).join(' ');

      // Look for "per 100g" / "per 100ml" / "per serve" headers
      if (RegExp(r'per\s+100\s*(g|ml)').hasMatch(rowText) ||
          RegExp(r'per\s+serve').hasMatch(rowText)) {
        // This is likely the header row
        headerRowY = row.first.rect.top.round();
        headers = _extractHeaders(row);
        break;
      }
    }

    if (headers == null || headers.isEmpty) {
      // Fallback: try to find table without explicit headers
      return _findTableWithoutHeaders(rows);
    }

    if (headerRowY == null) return null;

    // Now collect all rows below the header row that align with these columns
    final tableRows = <_TableRow>[];
    final columnXs = headers.map((h) => h.xCenter).toList();

    for (final row in rows) {
      final avgY = row.map((e) => e.rect.center.dy).reduce((a, b) => a + b) / row.length;
      if (avgY <= headerRowY + 10) continue; // Skip header row itself

      // Check if this row has elements that align with our columns
      final cells = <int, String>{};
      for (final el in row) {
        final colIdx = _findColumnIndex(el.rect.center.dx, columnXs);
        if (colIdx >= 0) {
          final existing = cells[colIdx];
          cells[colIdx] = existing == null ? el.text : '$existing ${el.text}';
        }
      }

      if (cells.isNotEmpty) {
        tableRows.add(_TableRow(y: avgY, cells: cells));
      }
    }

    if (tableRows.isEmpty) return null;

    return _NutritionTable(headers: headers, rows: tableRows);
  }

  /// Fallback: find table by looking for known nutrient labels in leftmost position
  _NutritionTable? _findTableWithoutHeaders(List<List<_TextElement>> rows) {
    final nutrientLabels = [
      'energy', 'protein', 'fat', 'saturated', 'carb', 'sugar', 'fibre', 'fiber', 'sodium', 'salt'
    ];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      // Check if first element is a nutrient label
      final firstText = row.first.text.toLowerCase();
      final isNutrient = nutrientLabels.any((n) => firstText.contains(n));

      if (isNutrient && i + 1 < rows.length) {
        // Found start of table - extract column positions from this and next few rows
        final allElements = <_TextElement>[];
        for (var j = i; j < math.min(rows.length, i + 10); j++) {
          allElements.addAll(rows[j]);
        }

        // Cluster X positions to find columns
        final xClusters = _clusterXPositions(allElements);
        if (xClusters.length >= 2) {
          // Build headers from cluster positions
          final headers = xClusters.asMap().entries.map((e) => _ColumnHeader(
            text: e.key == 0 ? 'Label' : 'Value',
            xCenter: e.value,
            index: e.key,
          )).toList();

          final tableRows = <_TableRow>[];
          for (var j = i; j < math.min(rows.length, i + 15); j++) {
            final r = rows[j];
            if (r.isEmpty) continue;
            final cells = <int, String>{};
            for (final el in r) {
              final colIdx = _findColumnIndex(el.rect.center.dx, xClusters);
              if (colIdx >= 0) {
                final existing = cells[colIdx];
                cells[colIdx] = existing == null ? el.text : '$existing ${el.text}';
              }
            }
            if (cells.isNotEmpty) {
              tableRows.add(_TableRow(y: r.first.rect.center.dy, cells: cells));
            }
          }

          if (tableRows.isNotEmpty) {
            return _NutritionTable(headers: headers, rows: tableRows);
          }
        }
      }
    }
    return null;
  }

  List<int> _clusterXPositions(List<_TextElement> elements) {
    if (elements.isEmpty) return [];

    final xs = elements.map((e) => e.rect.center.dx).toList()..sort();
    final clusters = <int>[];
    const threshold = 30.0; // pixels

    var currentCluster = xs.first;
    for (final x in xs) {
      if ((x - currentCluster).abs() > threshold) {
        clusters.add(currentCluster.round());
        currentCluster = x;
      }
    }
    clusters.add(currentCluster.round());
    return clusters;
  }

  int _findColumnIndex(double x, List<int> columnXs) {
    if (columnXs.isEmpty) return -1;
    var bestIdx = 0;
    var bestDist = (x - columnXs.first).abs();
    for (var i = 1; i < columnXs.length; i++) {
      final dist = (x - columnXs[i]).abs();
      if (dist < bestDist) {
        bestDist = dist;
        bestIdx = i;
      }
    }
    return bestDist < 50 ? bestIdx : -1; // Must be reasonably close to a column
  }

  List<List<_TextElement>> _groupByRows(List<_TextElement> elements) {
    if (elements.isEmpty) return [];

    // Sort by Y position
    final sorted = [...elements]..sort((a, b) => a.rect.top.compareTo(b.rect.top));

    final rows = <List<_TextElement>>[];
    var currentRow = <_TextElement>[sorted.first];
    var currentY = sorted.first.rect.center.dy;
    const rowThreshold = 15.0; // pixels

    for (var i = 1; i < sorted.length; i++) {
      final el = sorted[i];
      final y = el.rect.center.dy;
      if ((y - currentY).abs() <= rowThreshold) {
        currentRow.add(el);
      } else {
        // Sort current row by X
        currentRow.sort((a, b) => a.rect.left.compareTo(b.rect.left));
        rows.add(currentRow);
        currentRow = [el];
        currentY = y;
      }
    }
    if (currentRow.isNotEmpty) {
      currentRow.sort((a, b) => a.rect.left.compareTo(b.rect.left));
      rows.add(currentRow);
    }
    return rows;
  }

  List<_ColumnHeader> _extractHeaders(List<_TextElement> row) {
    // Sort by X position
    row.sort((a, b) => a.rect.left.compareTo(b.rect.left));

    return row.asMap().entries.map((entry) {
      final idx = entry.key;
      final el = entry.value;
      return _ColumnHeader(
        text: el.text,
        xCenter: el.rect.center.dx.round(),
        index: idx,
      );
    }).toList();
  }

  Nutriments? _parseTable(_NutritionTable table, double? servingSize) {
    double? energy;
    double? protein;
    double? fat;
    double? satFat;
    double? carbs;
    double? sugars;
    double? fibre;
    double? sodium;

    bool foundPerServe = false;

    // Determine which column is per-100g and which is per-serve
    int? per100Col;
    int? perServeCol;

    for (final header in table.headers) {
      final lower = header.text.toLowerCase();
      if (RegExp(r'per\s+100\s*(g|ml)').hasMatch(lower)) {
        per100Col = header.index;
      } else if (RegExp(r'per\s+serve').hasMatch(lower)) {
        perServeCol = header.index;
      }
    }

    // If no explicit headers, assume column 0 = label, column 1 = per-100g
    final usePer100 = per100Col ?? 1;
    final usePerServe = perServeCol ?? -1;
    final isPerServeOnly = per100Col == null && perServeCol != null;

    // Nutrient label patterns (ordered by specificity)
    final patterns = <_NutrientPattern>[
      _NutrientPattern(
        labelPattern: RegExp(r'energy', caseSensitive: false),
        unitPatterns: ['kj', 'kcal', 'cal'],
        setters: (v) => energy = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'protein', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => protein = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'fat[,\s]*(?:total)?|total\s+fat', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => fat = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'saturated|sat[,\s]*(?:fat)?', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => satFat = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'carb(?:ohydrate)?', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => carbs = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'sugars?', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => sugars = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'fibre|fiber|dietary\s+fibre', caseSensitive: false),
        unitPatterns: ['g'],
        setters: (v) => fibre = v,
      ),
      _NutrientPattern(
        labelPattern: RegExp(r'sodium|salt', caseSensitive: false),
        unitPatterns: ['mg', 'g'],
        setters: (v) => sodium = v,
      ),
    ];

    // Parse each row
    for (final row in table.rows) {
      final labelText = (row.cells[0] ?? '').toLowerCase();
      if (labelText.isEmpty) continue;

      for (final pattern in patterns) {
        if (pattern.labelPattern.hasMatch(labelText)) {
          // Try per-100g column first
          double? value;
          if (row.cells.containsKey(usePer100)) {
            value = _extractValueWithUnits(row.cells[usePer100]!, pattern.unitPatterns);
          }
          if (value == null && usePerServe >= 0 && row.cells.containsKey(usePerServe)) {
            value = _extractValueWithUnits(row.cells[usePerServe]!, pattern.unitPatterns);
          }

          if (value != null && value > 0) {
            pattern.setters(value);
            if (isPerServeOnly) {
              foundPerServe = true;
            }
          }
          break;
        }
      }
    }

    // Convert per-serve to per-100g if needed
    if (isPerServeOnly && foundPerServe && servingSize != null && servingSize > 0) {
      final factor = 100.0 / servingSize;
      energy = _scale(energy, factor);
      protein = _scale(protein, factor);
      fat = _scale(fat, factor);
      satFat = _scale(satFat, factor);
      carbs = _scale(carbs, factor);
      sugars = _scale(sugars, factor);
      fibre = _scale(fibre, factor);
      sodium = _scaleSodium(sodium, factor);
    }

    // If we have per-100g values, use those directly
    // (they're already in the variables)

    final kcal = _toKcal(energy);
    if (kcal == null || kcal <= 0) return null;

    return Nutriments(
      kcal: kcal,
      proteinG: protein ?? 0,
      carbsG: carbs ?? 0,
      fatG: fat ?? 0,
      satFatG: satFat ?? 0,
      sugarsG: sugars ?? 0,
      fiberG: fibre ?? 0,
      sodiumMg: sodium ?? 0,
    );
  }

  double? _extractValueWithUnits(String text, List<String> units) {
    for (final unit in units) {
      final regex = RegExp(r'(\d+(?:\.\d+)?)\s*' + RegExp.escape(unit), caseSensitive: false);
      final match = regex.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        if (value != null) {
          if (unit == 'kj') return value / 4.184;
          if (unit == 'g' && units.contains('mg')) return value * 1000; // sodium in g -> mg
          return value;
        }
      }
    }
    return null;
  }

  double? _scale(double? value, double factor) => value != null ? value * factor : null;

  double? _scaleSodium(double? value, double factor) {
    if (value == null) return null;
    // If value is small (< 10), it's likely in grams — convert to mg
    if (value < 10) value *= 1000;
    return value * factor;
  }

  double? _toKcal(double? energy) {
    if (energy == null) return null;
    // If energy is very high (> 2000), it's likely kJ — convert
    if (energy > 2000) return energy / 4.184;
    return energy;
  }

  // ─── Name/brand extraction ────────────────────────────────────────

  (String?, String?) _extractNameBrand(List<_TextElement> elements, _NutritionTable? table) {
    // Look for text above the table that could be product name/brand
    double? tableTop;
    if (table != null && table.rows.isNotEmpty) {
      tableTop = table.rows.first.y;
    } else if (elements.isNotEmpty) {
      // Fallback: use middle of page
      final ys = elements.map((e) => e.rect.center.dy).toList()..sort();
      tableTop = ys[ys.length ~/ 2];
    }

    if (tableTop == null) return (null, null);

    // Get elements above the table
    final threshold = tableTop;
    final above = elements.where((e) => e.rect.bottom < threshold).toList();
    if (above.isEmpty) return (null, null);

    // Sort by Y descending (closest to table first)
    above.sort((a, b) => b.rect.center.dy.compareTo(a.rect.center.dy));

    // Heuristic: first substantial text is name, second might be brand
    String? name, brand;
    for (final el in above.take(5)) {
      final text = el.text.trim();
      if (text.length < 3) continue;
      if (RegExp(r'^\d+$').hasMatch(text)) continue; // Skip numbers
      if (RegExp(r'(nutrition|information|ingredients|allergen)', caseSensitive: false).hasMatch(text)) continue;

      if (name == null) {
        name = text;
      } else if (brand == null && text != name) {
        brand = text;
        break;
      }
    }

    return (name, brand);
  }
}

// ─── Helper classes ───────────────────────────────────────────────────

class _TextElement {
  const _TextElement({required this.text, required this.rect, required this.blockRect});
  final String text;
  final Rect rect;
  final Rect blockRect;
}

class _ServingInfo {
  const _ServingInfo({this.size, this.unit, this.isLiquid});
  final double? size;
  final String? unit;
  final bool? isLiquid;
}

class _ColumnHeader {
  const _ColumnHeader({required this.text, required this.xCenter, required this.index});
  final String text;
  final int xCenter;
  final int index;
}

class _TableRow {
  const _TableRow({required this.y, required this.cells});
  final double y;
  final Map<int, String> cells; // column index -> text
}

class _NutritionTable {
  const _NutritionTable({required this.headers, required this.rows});
  final List<_ColumnHeader> headers;
  final List<_TableRow> rows;
}

class _NutrientPattern {
  const _NutrientPattern({
    required this.labelPattern,
    required this.unitPatterns,
    required this.setters,
  });
  final RegExp labelPattern;
  final List<String> unitPatterns;
  final void Function(double value) setters;
}