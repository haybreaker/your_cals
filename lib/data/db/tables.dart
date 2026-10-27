import 'package:drift/drift.dart';

/// Every food the app has ever seen lives here: bundled seed (FSANZ/OFF/
/// USDA/chains), cached OFF results, AI estimates saved by the user, custom
/// foods, and recipes (as computed foods). One table → one search index.
@DataClassName('FoodRow')
@TableIndex(name: 'idx_foods_barcode', columns: {#barcode})
@TableIndex(name: 'idx_foods_search', columns: {#searchText})
class Foods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get source => text()(); // FoodSource.name
  RealColumn get defaultGrams => real().withDefault(const Constant(100.0))();
  TextColumn get servingsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get liquid => boolean().withDefault(const Constant(false))();

  // Per-100g nutriments
  RealColumn get kcal => real().withDefault(const Constant(0))();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();
  RealColumn get satFatG => real().withDefault(const Constant(0))();
  RealColumn get sugarsG => real().withDefault(const Constant(0))();
  RealColumn get fiberG => real().withDefault(const Constant(0))();
  RealColumn get sodiumMg => real().withDefault(const Constant(0))();

  // Micronutrients per-100g (v2)
  RealColumn get vitAMcg => real().withDefault(const Constant(0))();
  RealColumn get vitB1Mg => real().withDefault(const Constant(0))();
  RealColumn get vitB2Mg => real().withDefault(const Constant(0))();
  RealColumn get vitB3Mg => real().withDefault(const Constant(0))();
  RealColumn get vitB6Mg => real().withDefault(const Constant(0))();
  RealColumn get vitB12Ug => real().withDefault(const Constant(0))();
  RealColumn get vitCMg => real().withDefault(const Constant(0))();
  RealColumn get folateUg => real().withDefault(const Constant(0))();
  RealColumn get calciumMg => real().withDefault(const Constant(0))();
  RealColumn get ironMg => real().withDefault(const Constant(0))();
  RealColumn get magnesiumMg => real().withDefault(const Constant(0))();
  RealColumn get potassiumMg => real().withDefault(const Constant(0))();
  RealColumn get zincMg => real().withDefault(const Constant(0))();

  /// Lowercased "name brand" for substring search.
  TextColumn get searchText => text()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LogEntryRow')
class LogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()(); // yyyy-MM-dd
  TextColumn get meal => text()(); // MealType.name
  TextColumn get foodId => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  TextColumn get source => text()();

  /// Amount consumed. [unit] interprets grams: 'g' | 'ml' | 'serving'.
  /// [grams] always stores the resolved gram weight.
  RealColumn get grams => real()();
  TextColumn get unit => text().withDefault(const Constant('g'))();

  // Serving metadata (v3): preserved when logged in serves so tiles can
  // show "2 × long black (332 g)" and quick steppers can adjust by serve.
  RealColumn get servingCount => real().nullable()();
  RealColumn get servingGrams => real().nullable()();
  TextColumn get servingLabel => text().nullable()();

  // Snapshot totals at log time
  RealColumn get kcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get carbsG => real()();
  RealColumn get fatG => real()();
  RealColumn get satFatG => real().withDefault(const Constant(0))();
  RealColumn get sugarsG => real().withDefault(const Constant(0))();
  RealColumn get fiberG => real().withDefault(const Constant(0))();
  RealColumn get sodiumMg => real().withDefault(const Constant(0))();

  // Micro snapshot (v2)
  RealColumn get vitCMg => real().withDefault(const Constant(0))();
  RealColumn get calciumMg => real().withDefault(const Constant(0))();
  RealColumn get ironMg => real().withDefault(const Constant(0))();
  RealColumn get potassiumMg => real().withDefault(const Constant(0))();

  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  /// Manual ordering within (day, meal) (v3). Legacy rows backfilled by
  /// created_at.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RecipeRow')
class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get foodId => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().withDefault(const Constant(''))();
  RealColumn get grams => real()();

  /// User-entered amount + unit (v4). [grams] stays the resolved canonical
  /// weight; [qty]/[unit] preserve display intent (e.g. 1.5 tbsp).
  RealColumn get qty => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('g'))();

  // Ingredient per-100g snapshot for stability
  RealColumn get kcal => real().withDefault(const Constant(0))();
  RealColumn get proteinG => real().withDefault(const Constant(0))();
  RealColumn get carbsG => real().withDefault(const Constant(0))();
  RealColumn get fatG => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityRow')
@TableIndex(name: 'idx_activities_search', columns: {#searchText})
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant(''))();

  /// Compendium MET intensity (× kg × h = kcal).
  RealColumn get met => real().withDefault(const Constant(0))();

  /// 2024 Older-Adult MET60+ value; null → approximate with met × 0.810.
  RealColumn get metOlderAdult => real().nullable()();

  /// Lowercased "name category" for substring search.
  TextColumn get searchText => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExerciseEntryRow')
class ExerciseEntries extends Table {
  TextColumn get id => text()();
  TextColumn get day => text()(); // yyyy-MM-dd
  TextColumn get activityId => text()();
  TextColumn get name => text()();
  RealColumn get minutes => real().withDefault(const Constant(0))();
  RealColumn get weightKg => real().withDefault(const Constant(0))();

  /// Snapshot burn at log time (MET estimate with that day's weight/age).
  RealColumn get kcal => real().withDefault(const Constant(0))();

  /// Watch override; null = use the estimate.
  RealColumn get manualKcal => real().nullable()();
  RealColumn get metUsed => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get sex => text()(); // male | female
  IntColumn get ageYears => integer()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  TextColumn get activity => text()(); // ActivityLevel.name
  TextColumn get goal => text()(); // GoalType.name
  RealColumn get weeklyRateKg => real().withDefault(const Constant(0.5))();
  IntColumn get customKcalTarget => integer().nullable()();
  RealColumn get proteinPct => real().withDefault(const Constant(0.30))();
  RealColumn get carbsPct => real().withDefault(const Constant(0.40))();
  RealColumn get fatPct => real().withDefault(const Constant(0.30))();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Weigh-in log for the Goals weight graph. One row per manual entry;
/// entries are timestamped so the graph can show any window.
@DataClassName('WeightEntryRow')
class WeightEntries extends Table {
  TextColumn get id => text()();
  RealColumn get weightKg => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
