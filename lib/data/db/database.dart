import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Foods,
  LogEntries,
  Recipes,
  RecipeItems,
  Profiles,
  Settings,
  Activities,
  ExerciseEntries,
  WeightEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  /// For tests / tools.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: micronutrients + unit + barcode/search indexes.
            await m.addColumn(foods, foods.vitAMcg);
            await m.addColumn(foods, foods.vitB1Mg);
            await m.addColumn(foods, foods.vitB2Mg);
            await m.addColumn(foods, foods.vitB3Mg);
            await m.addColumn(foods, foods.vitB6Mg);
            await m.addColumn(foods, foods.vitB12Ug);
            await m.addColumn(foods, foods.vitCMg);
            await m.addColumn(foods, foods.folateUg);
            await m.addColumn(foods, foods.calciumMg);
            await m.addColumn(foods, foods.ironMg);
            await m.addColumn(foods, foods.magnesiumMg);
            await m.addColumn(foods, foods.potassiumMg);
            await m.addColumn(foods, foods.zincMg);
            await m.addColumn(foods, foods.liquid);
            await m.addColumn(logEntries, logEntries.unit);
            await m.addColumn(logEntries, logEntries.vitCMg);
            await m.addColumn(logEntries, logEntries.calciumMg);
            await m.addColumn(logEntries, logEntries.ironMg);
            await m.addColumn(logEntries, logEntries.potassiumMg);
            await m.createIndex(idxFoodsBarcode);
            await m.createIndex(idxFoodsSearch);
          }
          if (from < 3) {
            // v3: serving metadata (serves on tiles / stepper) + manual
            // ordering within (day, meal).
            await m.addColumn(logEntries, logEntries.servingCount);
            await m.addColumn(logEntries, logEntries.servingGrams);
            await m.addColumn(logEntries, logEntries.servingLabel);
            await m.addColumn(logEntries, logEntries.sortOrder);
            // Backfill sortOrder per (day, meal) by created_at so existing
            // entries keep their current display order.
            await customStatement(
              'UPDATE log_entries SET sort_order = ('
              '  SELECT COUNT(*) FROM log_entries AS e2'
              '  WHERE e2.day = log_entries.day'
              '    AND e2.meal = log_entries.meal'
              '    AND (e2.created_at, e2.id) < (log_entries.created_at, log_entries.id)'
              ')',
            );
          }
          if (from < 4) {
            // v4: recipe ingredient qty + unit (tap-to-edit amounts).
            // grams stays the resolved canonical weight.
            await m.addColumn(recipeItems, recipeItems.qty);
            await m.addColumn(recipeItems, recipeItems.unit);
            await customStatement(
              "UPDATE recipe_items SET qty = grams WHERE qty = 0",
            );
            await customStatement(
              "UPDATE recipe_items SET unit = 'g' WHERE unit = '' OR unit IS NULL",
            );
          }
          if (from < 5) {
            // v5: exercise logging — activity catalog + daily entries.
            // Fresh tables, no backfill needed.
            await m.createTable(activities);
            await m.createTable(exerciseEntries);
          }
          if (from < 6) {
            // v6: weight log for the Goals page graph — fresh table.
            await m.createTable(weightEntries);
          }
        },
      );

  static QueryExecutor _open() => driftDatabase(name: 'your_cals');
}
