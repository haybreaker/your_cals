import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:your_cals/data/objects/entry.dart';
import 'package:your_cals/data/objects/food.dart';
import 'package:your_cals/data/objects/macros.dart';
import 'package:your_cals/data/providers/food_entries_provider.dart';
// Import your new helper classes
import 'package:your_cals/data/models/entry_with_food.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selectedDate = DateTime.now();

  // Store the combined Entry and Food data
  List<EntryWithFood> _entriesWithFood = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final provider = context.read<FoodEntriesProvider>();

    // 1. Get all entries for the selected date
    // TODO: Update getTodaysEntries to take _selectedDate
    // For now, it just gets 'today' as per your original code
    final entries = await provider.getEntriesByDate(_selectedDate);

    if (entries.isEmpty) {
      setState(() {
        _entriesWithFood = [];
        _isLoading = false;
      });
      return;
    }

    // 2. Get all unique food IDs from the entries
    final foodIds = entries.map((e) => e.foodId).toSet().toList();

    // 3. Fetch all corresponding Food objects in one batch
    final foodMap = await provider.getFoodsByIds(foodIds);

    // 4. Combine Entries and Foods into a new list
    final combinedList = <EntryWithFood>[];
    for (final entry in entries) {
      final food = foodMap[entry.foodId];
      if (food != null) {
        combinedList.add(EntryWithFood(entry: entry, food: food));
      } else {
        // Handle missing food data gracefully
        combinedList.add(EntryWithFood(entry: entry, food: Food.empty));
      }
    }

    setState(() {
      _entriesWithFood = combinedList;
      _isLoading = false;
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadEntries();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadEntries();
    }
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMMM d').format(_selectedDate);
    }
  }

  Map<MealCategory, List<EntryWithFood>> _groupEntriesByMeal() {
    final grouped = <MealCategory, List<EntryWithFood>>{};

    for (final meal in MealCategory.values) {
      grouped[meal] = _entriesWithFood.where((ewf) => ewf.entry.meal == meal).toList();
    }

    return grouped;
  }

  // Calculate total calories from the combined list
  double _getTotalCalories() {
    if (_entriesWithFood.isEmpty) return 0.0;
    return _entriesWithFood.fold(0.0, (sum, ewf) => sum + NutritionCalculator.getCalories(ewf.entry, ewf.food));
  }

  // Calculate total macros from the combined list
  Macros _getTotalMacros() {
    if (_entriesWithFood.isEmpty) return Macros.empty;

    return _entriesWithFood.fold(Macros.empty, (sum, ewf) {
      final entryMacros = NutritionCalculator.getMacros(ewf.entry, ewf.food);
      return sum.copyWith(
        protein: sum.protein + entryMacros.protein,
        carbs: sum.carbs + entryMacros.carbs,
        fat: sum.fat + entryMacros.fat,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupedEntries = _groupEntriesByMeal();
    final totalMacros = _getTotalMacros();

    return Scaffold(
      body: Column(
        children: [
          // Date selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _changeDate(-1),
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous day',
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              _getDateLabel(),
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            if (_getDateLabel() == 'Today' ||
                                _getDateLabel() == 'Yesterday' ||
                                _getDateLabel() == 'Tomorrow')
                              Text(
                                DateFormat('MMM d, yyyy').format(_selectedDate),
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: DateTime.now().isAfter(_selectedDate) ? () => _changeDate(1) : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next day',
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entriesWithFood.isEmpty
                ? _buildEmptyState(theme)
                : _buildEntriesList(theme, groupedEntries, totalMacros),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add food screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text('No meals logged', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _getDateLabel() == 'Today' ? 'Start tracking your meals for today' : 'No meals were logged on this day',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to add food screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Food'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntriesList(ThemeData theme, Map<MealCategory, List<EntryWithFood>> groupedEntries, Macros totalMacros) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), // Padding for FAB
      children: [
        // Daily summary card
        Card(
          color: theme.colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  theme,
                  'Calories',
                  _getTotalCalories().toStringAsFixed(0),
                  'kcal',
                  Icons.local_fire_department,
                  theme.colorScheme.primary,
                ),
                _buildSummaryItem(
                  theme,
                  'Protein',
                  totalMacros.protein.toStringAsFixed(0),
                  'g',
                  Icons.egg_outlined,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  theme,
                  'Carbs',
                  totalMacros.carbs.toStringAsFixed(0),
                  'g',
                  Icons.bakery_dining_outlined,
                  Colors.blue,
                ),
                _buildSummaryItem(
                  theme,
                  'Fat',
                  totalMacros.fat.toStringAsFixed(0),
                  'g',
                  Icons.opacity_outlined,
                  Colors.amber,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Meals
        for (final meal in MealCategory.values)
          if (groupedEntries[meal]?.isNotEmpty ?? false) _buildMealSection(theme, meal, groupedEntries[meal]!),
      ],
    );
  }

  Widget _buildSummaryItem(ThemeData theme, String label, String value, String unit, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              TextSpan(
                text: ' $unit',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildMealSection(ThemeData theme, MealCategory meal, List<EntryWithFood> entriesWithFood) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(meal.displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Card.filled(
          // Using Card.filled gives it the M3 container look
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              for (int i = 0; i < entriesWithFood.length; i++) ...[
                _buildEntryTile(theme, entriesWithFood[i]),
                if (i < entriesWithFood.length - 1)
                  Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryTile(ThemeData theme, EntryWithFood ewf) {
    final entry = ewf.entry;
    final food = ewf.food;

    // Get calculated nutrition for this specific entry
    final calories = NutritionCalculator.getCalories(entry, food);
    final macros = NutritionCalculator.getMacros(entry, food);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.restaurant, color: theme.colorScheme.onPrimaryContainer, size: 20),
      ),
      title: Text(
        food.name.isNotEmpty ? food.name : 'Unknown Food',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${entry.formattedAmount}${food.brand.isNotEmpty ? ' • ${food.brand}' : ''}',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${calories.toStringAsFixed(0)} kcal',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // Make calories expressive
            ),
          ),
          Text(
            'P:${macros.protein.toStringAsFixed(0)} C:${macros.carbs.toStringAsFixed(0)} F:${macros.fat.toStringAsFixed(0)}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      onTap: () {
        // TODO: Show entry details or edit
      },
      onLongPress: () {
        context.read<FoodEntriesProvider>().removeEntry(entry);
        setState(() {});
      },
    );
  }
}
