import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:your_cals/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_cals/data/databases/sqlite3/sqlite.dart';
import 'package:your_cals/data/objects/entry.dart';
import 'package:your_cals/data/objects/food.dart';
import 'package:your_cals/data/providers/food_db_provider.dart';
import 'package:your_cals/data/providers/food_entries_provider.dart';

class LogFoodPage extends StatefulWidget {
  final DateTime? selectedDate;
  final MealCategory? selectedMeal;

  const LogFoodPage({super.key, this.selectedDate, this.selectedMeal});

  @override
  State<LogFoodPage> createState() => _LogFoodPageState();
}

class _LogFoodPageState extends State<LogFoodPage> {
  final TextEditingController _controller = TextEditingController();
  List<Food> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  Future<void> _search(String query) async {
    // 1. Handle empty query immediately
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false; // Ensure loading is reset if active
      });
      // Cancel the timer if the user clears the text field
      _debounceTimer?.cancel();
      return;
    }

    // 2. Cancel the previous timer if it exists (debounce!)
    _debounceTimer?.cancel();

    // Set loading state immediately (optional, but good UX)
    setState(() => _isLoading = true);

    // 3. Start a new timer that executes the search after 2 seconds
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      // This block runs ONLY if no new keypress happens for 2 seconds

      final provider = context.read<FoodDatabaseProvider>();
      // Wait for the search to complete
      final results = await provider.searchFoods(query);

      // 4. Update state with results
      // We check `mounted` to ensure the widget is still on the screen
      if (mounted) {
        setState(() {
          _results = results.take(50).toList();
          _isLoading = false;
        });
      }
    });
  }

  void _showFoodDetailsDialog(Food food) {
    showDialog(
      context: context,
      builder: (context) => _FoodDetailsDialog(
        food: food,
        initialDate: widget.selectedDate ?? DateTime.now(),
        initialMeal: widget.selectedMeal ?? MealCategory.uncategorized,
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Log Food'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _controller,
                onChanged: (val) => _search(val),
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
              ),
            ),

            // Loading Indicator
            if (_isLoading) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),

            // Results List
            Expanded(
              child: _results.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            _controller.text.isEmpty ? 'Start typing to search for food' : 'No results found',
                            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final food = _results[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Icon(Icons.restaurant, color: colorScheme.onPrimaryContainer, size: 20),
                            ),
                            title: Text(
                              food.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "${food.brand.isNotEmpty ? '${food.brand} • ' : ''}"
                                "${food.caloriesPerHundred.toStringAsFixed(0)} kcal / 100g\n"
                                "P: ${food.macros.protein.toStringAsFixed(1)}g | "
                                "C: ${food.macros.carbs.toStringAsFixed(1)}g | "
                                "F: ${food.macros.fat.toStringAsFixed(1)}g",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurfaceVariant),
                            onTap: () => _showFoodDetailsDialog(food),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodDetailsDialog extends StatefulWidget {
  final Food food;
  final DateTime initialDate;
  final MealCategory initialMeal;

  const _FoodDetailsDialog({required this.food, required this.initialDate, required this.initialMeal});

  @override
  State<_FoodDetailsDialog> createState() => _FoodDetailsDialogState();
}

class _FoodDetailsDialogState extends State<_FoodDetailsDialog> {
  late TextEditingController _amountController;
  late MeasurementType _measurementType;
  late MealCategory _mealCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '100');
    _measurementType = MeasurementType.grams;
    _mealCategory = widget.initialMeal;
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  // Calculate nutritional values based on amount and measurement type
  double _calculateValue(double per100g) {
    double gramsAmount = _amount;

    // Convert to grams if needed (simplified conversions)
    switch (_measurementType) {
      case MeasurementType.ounces:
        gramsAmount = _amount * 28.35;
        break;
      case MeasurementType.pounds:
        gramsAmount = _amount * 453.592;
        break;
      case MeasurementType.kilograms:
        gramsAmount = _amount * 1000;
        break;
      case MeasurementType.serving:
        gramsAmount = _amount * widget.food.servingSize;
        break;
      case MeasurementType.cups:
        gramsAmount = _amount * 240; // Approximate
        break;
      case MeasurementType.tablespoons:
        gramsAmount = _amount * 15; // Approximate
        break;
      case MeasurementType.teaspoons:
        gramsAmount = _amount * 5; // Approximate
        break;
      case MeasurementType.milliliters:
        gramsAmount = _amount; // Assume 1ml = 1g (water equivalent)
        break;
      case MeasurementType.pieces:
      case MeasurementType.slices:
        gramsAmount = _amount * 50; // Approximate
        break;
      case MeasurementType.grams:
      default:
        gramsAmount = _amount;
    }

    return (gramsAmount / 100) * per100g;
  }

  void _logFood() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final entry = Entry(
      foodId: widget.food.id,
      foodType: FoodType.openFoodFacts,
      date: _selectedDate,
      meal: _mealCategory,
      amount: _amount,
      measurementType: _measurementType,
    );

    context.read<FoodEntriesProvider>().insertEntry(entry);

    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Also close the search page

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${widget.food.name} logged successfully'), behavior: SnackBarBehavior.floating));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) return 'Today';
    if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (selected == today.add(const Duration(days: 1))) return 'Tomorrow';

    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final calories = _calculateValue(widget.food.macros.energyKcal);
    final protein = _calculateValue(widget.food.macros.protein);
    final carbs = _calculateValue(widget.food.macros.carbs);
    final fat = _calculateValue(widget.food.macros.fat);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.food.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          if (widget.food.brand.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.food.brand,
                                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount Input
                Text('Amount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<MeasurementType>(
                        value: _measurementType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: MeasurementType.values.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type.displayName));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _measurementType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nutritional Preview
                Text('Nutritional Information', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildNutrientRow(
                        theme,
                        'Calories',
                        '${calories.toStringAsFixed(0)} kcal',
                        Icons.local_fire_department,
                        colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMacroChip(theme, 'Protein', '${protein.toStringAsFixed(1)}g', Colors.orange),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMacroChip(theme, 'Carbs', '${carbs.toStringAsFixed(1)}g', Colors.blue)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMacroChip(theme, 'Fat', '${fat.toStringAsFixed(1)}g', Colors.amber)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Meal Category
                Text('Meal', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<MealCategory>(
                  value: _mealCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: MealCategory.values.map((meal) {
                    return DropdownMenuItem(value: meal, child: Text(meal.displayName));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _mealCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date Selection
                Text('Date', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Text(_getDateLabel(), style: theme.textTheme.bodyLarge),
                        const Spacer(),
                        Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _logFood,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Log Food'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMacroChip(ThemeData theme, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
