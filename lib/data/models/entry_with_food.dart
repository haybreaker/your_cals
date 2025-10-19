import 'package:your_cals/data/objects/entry.dart';
import 'package:your_cals/data/objects/food.dart';
import 'package:your_cals/data/objects/macros.dart';

/// A helper class to bundle an Entry with its corresponding Food details.
class EntryWithFood {
  final Entry entry;
  final Food food;

  EntryWithFood({required this.entry, required this.food});
}

/// A utility class to calculate nutrition based on an entry and food data.
///
/// Assumes all data in the `Food` object (calories, macros) is 'per 100g'.
class NutritionCalculator {
  /// Default guesses for liquid densities (g/ml)
  static const Map<String, double> _defaultLiquidDensity = {
    'milk': 1.03,
    'juice': 0.98,
    'milkshake': 0.9,
    'water': 1.0,
    'oil': 0.91,
    'default': 1.0,
  };

  /// Default guesses for piece/slice weights (grams)
  static const double _defaultPieceWeight = 50.0; // e.g., apple, small fruit
  static const double _defaultSliceWeight = 30.0; // e.g., bread slice

  /// Converts a measurement entry to grams using best guesses
  static double _getGramWeight(Entry entry, Food food) {
    switch (entry.measurementType) {
      case MeasurementType.grams:
        return entry.amount;
      case MeasurementType.kilograms:
        return entry.amount * 1000.0;
      case MeasurementType.ounces:
        return entry.amount * 28.3495;
      case MeasurementType.pounds:
        return entry.amount * 453.592;
      case MeasurementType.serving:
        // Use servingSize if available, otherwise default 100g
        return entry.amount * (food.servingSize ?? 100.0);
      case MeasurementType.milliliters:
        // Use type-based density guess if possible, otherwise 1.0 g/ml
        final density = 1.0;
        return entry.amount * density;
      case MeasurementType.cups:
        final ml = entry.amount * 240.0;
        final density = 1.0;
        return ml * density;
      case MeasurementType.tablespoons:
        final ml = entry.amount * 15.0;
        final density = 1.0;
        return ml * density;
      case MeasurementType.teaspoons:
        final ml = entry.amount * 5.0;
        final density = 1.0;
        return ml * density;
      case MeasurementType.pieces:
        return entry.amount * _defaultPieceWeight;
      case MeasurementType.slices:
        return entry.amount * _defaultSliceWeight;
      default:
        return 0.0;
    }
  }

  /// Calculates calories based on grams
  static double getCalories(Entry entry, Food food) {
    final grams = _getGramWeight(entry, food);
    return (grams / 100.0) * food.caloriesPerHundred;
  }

  /// Calculates macros based on grams
  static Macros getMacros(Entry entry, Food food) {
    final grams = _getGramWeight(entry, food);
    final factor = grams / 100.0;

    return food.macros.copyWith(
      energyKcal: food.macros.energyKcal * factor,
      protein: food.macros.protein * factor,
      carbs: food.macros.carbs * factor,
      sugar: food.macros.sugar * factor,
      fiber: food.macros.fiber * factor,
      fat: food.macros.fat * factor,
      saturatedFat: food.macros.saturatedFat * factor,
      unsaturatedFat: food.macros.unsaturatedFat * factor,
      sodium: food.macros.sodium * factor,
      alcohol: food.macros.alcohol * factor,
      water: food.macros.water * factor,
    );
  }
}
