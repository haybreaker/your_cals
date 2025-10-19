import 'package:flutter/foundation.dart';

/// Represents the macronutrient and calorie composition of a food item
/// or a user's daily total. Compatible with SQLite and serialization.
@immutable
class Macros {
  final double energyKcal;
  final double protein;
  final double carbs;
  final double sugar;
  final double fiber;
  final double fat;
  final double saturatedFat;
  final double unsaturatedFat;
  final double sodium;
  final double alcohol;
  final double water;

  const Macros({
    this.energyKcal = 0,
    this.protein = 0,
    this.carbs = 0,
    this.sugar = 0,
    this.fiber = 0,
    this.fat = 0,
    this.saturatedFat = 0,
    this.unsaturatedFat = 0,
    this.sodium = 0,
    this.alcohol = 0,
    this.water = 0,
  });

  // --- ADD THIS METHOD ---

  /// Creates a copy of this Macros object with the given fields replaced.
  Macros copyWith({
    double? energyKcal,
    double? protein,
    double? carbs,
    double? sugar,
    double? fiber,
    double? fat,
    double? saturatedFat,
    double? unsaturatedFat,
    double? sodium,
    double? alcohol,
    double? water,
  }) {
    return Macros(
      energyKcal: energyKcal ?? this.energyKcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      unsaturatedFat: unsaturatedFat ?? this.unsaturatedFat,
      sodium: sodium ?? this.sodium,
      alcohol: alcohol ?? this.alcohol,
      water: water ?? this.water,
    );
  }

  // -------------------------

  /// Factory to create from JSON
  factory Macros.fromJson(Map<String, dynamic> json) => Macros(
    energyKcal: (json['energyKcal'] ?? 0).toDouble(),
    protein: (json['protein'] ?? 0).toDouble(),
    carbs: (json['carbs'] ?? 0).toDouble(),
    sugar: (json['sugar'] ?? 0).toDouble(),
    fiber: (json['fiber'] ?? 0).toDouble(),
    fat: (json['fat'] ?? 0).toDouble(),
    saturatedFat: (json['saturatedFat'] ?? 0).toDouble(),
    unsaturatedFat: (json['unsaturatedFat'] ?? 0).toDouble(),
    sodium: (json['sodium'] ?? 0).toDouble(),
    alcohol: (json['alcohol'] ?? 0).toDouble(),
    water: (json['water'] ?? 0).toDouble(),
  );

  /// Convert to JSON (for saving to DB or API)
  Map<String, dynamic> toJson() => {
    'energyKcal': energyKcal,
    'protein': protein,
    'carbs': carbs,
    'sugar': sugar,
    'fiber': fiber,
    'fat': fat,
    'saturatedFat': saturatedFat,
    'unsaturatedFat': unsaturatedFat,
    'sodium': sodium,
    'alcohol': alcohol,
    'water': water,
  };

  /// Merge / add two macro sets (e.g., total meals in a day)
  Macros operator +(Macros other) => copyWith(
    energyKcal: energyKcal + other.energyKcal,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    sugar: sugar + other.sugar,
    fiber: fiber + other.fiber,
    fat: fat + other.fat,
    saturatedFat: saturatedFat + other.saturatedFat,
    unsaturatedFat: unsaturatedFat + other.unsaturatedFat,
    sodium: sodium + other.sodium,
    alcohol: alcohol + other.alcohol,
    water: water + other.water,
  );

  /// Scale macros by serving size (e.g., half a portion)
  Macros scale(double factor) => copyWith(
    energyKcal: energyKcal * factor,
    protein: protein * factor,
    carbs: carbs * factor,
    sugar: sugar * factor,
    fiber: fiber * factor,
    fat: fat * factor,
    saturatedFat: saturatedFat * factor,
    unsaturatedFat: unsaturatedFat * factor,
    sodium: sodium * factor,
    alcohol: alcohol * factor,
    water: water * factor,
  );

  /// Derived getter: total energy if not given
  double get calculatedKcal => energyKcal > 0 ? energyKcal : (protein * 4 + carbs * 4 + fat * 9 + alcohol * 7);

  /// Derived getter: % of calories from each macro
  double get proteinPct => calculatedKcal > 0 ? (protein * 4) / calculatedKcal : 0;
  double get carbPct => calculatedKcal > 0 ? (carbs * 4) / calculatedKcal : 0;
  double get fatPct => calculatedKcal > 0 ? (fat * 9) / calculatedKcal : 0;

  @override
  String toString() => 'Macros(kcal: ${calculatedKcal.toStringAsFixed(1)}, P: $protein, C: $carbs, F: $fat)';

  /// Useful defaults
  static const empty = Macros();
  static const example = Macros(
    energyKcal: 2000,
    protein: 150,
    carbs: 250,
    fat: 70,
    saturatedFat: 20,
    unsaturatedFat: 50,
    sugar: 40,
    fiber: 25,
    sodium: 2.3,
  );

  // Also needed for @immutable
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Macros &&
        other.energyKcal == energyKcal &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.sugar == sugar &&
        other.fiber == fiber &&
        other.fat == fat &&
        other.saturatedFat == saturatedFat &&
        other.unsaturatedFat == unsaturatedFat &&
        other.sodium == sodium &&
        other.alcohol == alcohol &&
        other.water == water;
  }

  @override
  int get hashCode {
    return energyKcal.hashCode ^
        protein.hashCode ^
        carbs.hashCode ^
        sugar.hashCode ^
        fiber.hashCode ^
        fat.hashCode ^
        saturatedFat.hashCode ^
        unsaturatedFat.hashCode ^
        sodium.hashCode ^
        alcohol.hashCode ^
        water.hashCode;
  }
}
