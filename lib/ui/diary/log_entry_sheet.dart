import 'package:flutter/material.dart';

import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../search/search_sheet.dart' show openPortionEditor;

/// Edit an existing diary entry: opens the unified portion editor in
/// edit mode (serves/grams/ml + meal), exactly like the log-food screen.
Future<void> showLogEntryEditor(BuildContext context, LogEntry entry) {
  // A placeholder food is passed for immediate render; the sheet reloads
  // the real food by id (or rebuilds from the entry snapshot if deleted).
  return openPortionEditor(
    context,
    Food(
      id: entry.foodId,
      name: entry.name,
      brand: entry.brand,
      source: entry.source,
      per100:
          entry.grams > 0 ? entry.nutr.forGrams(100 / entry.grams) : entry.nutr,
      defaultGrams: entry.servingGrams ?? 100,
      servings: [
        if (entry.servingLabel != null && entry.servingGrams != null)
          ServingOption(label: entry.servingLabel!, grams: entry.servingGrams!),
      ],
    ),
    entry: entry,
  );
}
