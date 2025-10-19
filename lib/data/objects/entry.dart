/// Represents a food diary entry/log
class Entry {
  final String? id; // Database ID (null for new entries)
  final String foodId;
  final FoodType foodType;
  final DateTime date;
  final MealCategory meal;
  final double amount;
  final MeasurementType measurementType;

  Entry({
    this.id,
    required this.foodId,
    required this.foodType,
    required this.date,
    required this.meal,
    required this.amount,
    required this.measurementType,
  });

  /// Update fromMap to handle snake_case
  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id']?.toString(),
      foodId: map['food_id'] as String,
      foodType: FoodType.fromString(map['food_type'] as String),
      date: DateTime.parse(map['date'] as String),
      meal: MealCategory.fromString(map['meal'] as String),
      amount: (map['amount'] as num).toDouble(),
      measurementType: MeasurementType.fromString(map['measurement_type'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'food_id': foodId,
      'food_type': foodType.value,
      'date': date.toIso8601String(),
      'meal': meal.value,
      'amount': amount,
      'measurement_type': measurementType.value,
    };
  }

  /// Create a copy with modified fields
  Entry copyWith({
    String? id,
    String? foodId,
    FoodType? foodType,
    DateTime? date,
    MealCategory? meal,
    double? amount,
    MeasurementType? measurementType,
  }) {
    return Entry(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodType: foodType ?? this.foodType,
      date: date ?? this.date,
      meal: meal ?? this.meal,
      amount: amount ?? this.amount,
      measurementType: measurementType ?? this.measurementType,
    );
  }

  /// Helper to get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Helper to get formatted amount with unit
  String get formattedAmount {
    return '${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 1)} ${measurementType.abbreviation}';
  }

  @override
  String toString() {
    return 'Entry(id: $id, foodId: $foodId, foodType: ${foodType.value}, '
        'date: ${date.toIso8601String()}, meal: ${meal.value}, '
        'amount: $amount, measurementType: ${measurementType.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Entry &&
        other.id == id &&
        other.foodId == foodId &&
        other.foodType == foodType &&
        other.date == date &&
        other.meal == meal &&
        other.amount == amount &&
        other.measurementType == measurementType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        foodId.hashCode ^
        foodType.hashCode ^
        date.hashCode ^
        meal.hashCode ^
        amount.hashCode ^
        measurementType.hashCode;
  }
}

/// Enum for food source types
enum FoodType {
  openFoodFacts('openfoodfacts'),
  recipe('recipe'),
  meal('meal');

  final String value;
  const FoodType(this.value);

  static FoodType fromString(String value) {
    return FoodType.values.firstWhere((type) => type.value == value, orElse: () => FoodType.openFoodFacts);
  }
}

/// Enum for meal categories
enum MealCategory {
  breakfast('breakfast'),
  lunch('lunch'),
  dinner('dinner'),
  snacks('snacks'),
  uncategorized('uncategorized');

  final String value;
  const MealCategory(this.value);

  static MealCategory fromString(String value) {
    return MealCategory.values.firstWhere((category) => category.value == value, orElse: () => MealCategory.uncategorized);
  }

  /// Helper to get display name with proper capitalization
  String get displayName {
    return value[0].toUpperCase() + value.substring(1);
  }
}

/// Enum for measurement types
enum MeasurementType {
  serving('serving'),
  grams('grams'),
  ounces('ounces'),
  milliliters('milliliters'),
  cups('cups'),
  tablespoons('tablespoons'),
  teaspoons('teaspoons'),
  pounds('pounds'),
  kilograms('kilograms'),
  pieces('pieces'),
  slices('slices');

  final String value;
  const MeasurementType(this.value);

  static MeasurementType fromString(String value) {
    return MeasurementType.values.firstWhere((type) => type.value == value, orElse: () => MeasurementType.grams);
  }

  /// Helper to get display name
  String get displayName {
    return value[0].toUpperCase() + value.substring(1);
  }

  /// Helper to get abbreviated unit
  String get abbreviation {
    switch (this) {
      case MeasurementType.grams:
        return 'g';
      case MeasurementType.ounces:
        return 'oz';
      case MeasurementType.milliliters:
        return 'ml';
      case MeasurementType.cups:
        return 'cup';
      case MeasurementType.tablespoons:
        return 'tbsp';
      case MeasurementType.teaspoons:
        return 'tsp';
      case MeasurementType.pounds:
        return 'lb';
      case MeasurementType.kilograms:
        return 'kg';
      case MeasurementType.serving:
        return 'serving';
      case MeasurementType.pieces:
        return 'pcs';
      case MeasurementType.slices:
        return 'slice';
    }
  }
}
