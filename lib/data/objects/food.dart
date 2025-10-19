import 'package:flutter/foundation.dart';
import 'package:your_cals/data/objects/macros.dart';

@immutable
class Food {
  final String id;
  final String barcode;
  final String name;
  final double caloriesPerHundred;
  final double servingSize; // grams or mL, depending on type
  final Macros macros;
  final String brand;

  const Food({
    required this.id,
    required this.barcode,
    required this.name,
    required this.caloriesPerHundred,
    required this.servingSize,
    required this.macros,
    required this.brand,
  });

  /// Empty constructor for placeholder items
  static const empty = Food(
    id: '',
    barcode: '',
    name: '',
    caloriesPerHundred: 0,
    servingSize: 0,
    macros: Macros.empty,
    brand: '',
  );

  /// Example entry for quick testing
  static const example = Food(
    id: "Grilled Chicken Breast - Generic",
    barcode: '1234567890123',
    name: 'Grilled Chicken Breast',
    caloriesPerHundred: 165,
    servingSize: 100,
    macros: Macros(energyKcal: 165, protein: 31, carbs: 0, fat: 3.6, saturatedFat: 1, unsaturatedFat: 2.6),
    brand: 'Generic',
  );

  /// Convert from JSON or SQLite row
  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'],
    barcode: json['barcode']?.toString() ?? '',
    name: json['name'] ?? '',
    caloriesPerHundred: (json['caloriesPerHundred'] ?? 0).toDouble(),
    servingSize: (json['servingSize'] ?? 0).toDouble(),
    brand: json['brand'] ?? '',
    macros: json['macros'] is Map<String, dynamic> ? Macros.fromJson(json['macros']) : Macros.empty,
  );

  /// Convert to JSON (for SQLite or API)
  Map<String, dynamic> toJson() => {
    'id': id,
    'barcode': barcode,
    'name': name,
    'caloriesPerHundred': caloriesPerHundred,
    'servingSize': servingSize,
    'brand': brand,
    'macros': macros.toJson(),
  };

  /// Helper for SQLite insert (flattens nested macros)
  Map<String, dynamic> toDbMap() => {
    'id': id,
    'barcode': barcode,
    'name': name,
    'brand': brand,
    'calories_per_100': caloriesPerHundred,
    'serving_size': servingSize,
    'energy_kcal': macros.energyKcal,
    'protein': macros.protein,
    'carbs': macros.carbs,
    'sugar': macros.sugar,
    'fiber': macros.fiber,
    'fat': macros.fat,
    'saturated_fat': macros.saturatedFat,
    'unsaturated_fat': macros.unsaturatedFat,
    'sodium': macros.sodium,
    'alcohol': macros.alcohol,
    'water': macros.water,
  };

  /// Create from SQLite query result
  factory Food.fromDb(Map<String, Object?> row) => Food(
    id: (row['id'] ?? '').toString(),
    barcode: (row['barcode'] ?? '').toString(),
    name: (row['name'] ?? '').toString(),
    brand: (row['brand'] ?? '').toString(),
    caloriesPerHundred: (row['calories_per_100'] as num?)?.toDouble() ?? 0,
    servingSize: (row['serving_size'] as num?)?.toDouble() ?? 0,
    macros: Macros(
      energyKcal: (row['energy_kcal'] as num?)?.toDouble() ?? 0,
      protein: (row['protein'] as num?)?.toDouble() ?? 0,
      carbs: (row['carbs'] as num?)?.toDouble() ?? 0,
      sugar: (row['sugar'] as num?)?.toDouble() ?? 0,
      fiber: (row['fiber'] as num?)?.toDouble() ?? 0,
      fat: (row['fat'] as num?)?.toDouble() ?? 0,
      saturatedFat: (row['saturated_fat'] as num?)?.toDouble() ?? 0,
      unsaturatedFat: (row['unsaturated_fat'] as num?)?.toDouble() ?? 0,
      sodium: (row['sodium'] as num?)?.toDouble() ?? 0,
      alcohol: (row['alcohol'] as num?)?.toDouble() ?? 0,
      water: (row['water'] as num?)?.toDouble() ?? 0,
    ),
  );

  @override
  String toString() => 'Food(id: $id, name: $name, kcal/100g: $caloriesPerHundred, protein: ${macros.protein})';
}
