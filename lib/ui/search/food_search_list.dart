import 'package:flutter/material.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import 'search_sheet.dart' show FoodResultTile;

/// Shared search-result widgets used by both the modal search sheet
/// (capture flow) and the Library tab, so the two surfaces stay
/// visually and behaviorally identical.
class SearchSkeletonList extends StatelessWidget {
  const SearchSkeletonList({super.key, this.count = 7});

  final int count;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: List.generate(
      count,
      (_) => const Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Skeleton(height: 64, radius: 20),
      ),
    ),
  );
}

class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.onAddManually});

  final VoidCallback onAddManually;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Yc.textTertiary,
          ),
          const SizedBox(height: 14),
          const Text(
            'No matches yet',
            style: TextStyle(color: Yc.textTertiary, fontSize: 15),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Yc.calories,
              foregroundColor: const Color(0xFF06251B),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onAddManually,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add a custom food',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Results list with the "Add food manually" tail tile.
class FoodResultsList extends StatelessWidget {
  const FoodResultsList({
    super.key,
    required this.results,
    this.meal,
    this.onPick,
    required this.onAddManually,
    this.bottomPadding = 40,
    this.historyCounts = const {},
  });

  final List<Food> results;
  final MealType? meal;
  final void Function(Food)? onPick;
  final VoidCallback onAddManually;

  /// Library needs extra clearance above the dock.
  final double bottomPadding;

  /// foodId → times logged, for the tile "logged N×" markers.
  final Map<String, int> historyCounts;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
    itemCount: results.length + 1,
    itemBuilder: (context, i) {
      if (i == results.length) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: _AddFoodManuallyTile(meal: meal, onAddManually: onAddManually),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FoodResultTile(
          food: results[i],
          meal: meal,
          onPick: onPick,
          historyCount: historyCounts[results[i].id] ?? 0,
        ),
      );
    },
  );
}

class _AddFoodManuallyTile extends StatelessWidget {
  const _AddFoodManuallyTile({this.meal, required this.onAddManually});

  final MealType? meal;
  final VoidCallback onAddManually;

  @override
  Widget build(BuildContext context) {
    return GlassLite(
      radius: 20,
      opacity: 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onAddManually,
      child: const Row(
        children: [
          Icon(Icons.add_rounded, color: Yc.calories),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a custom food',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Yc.calories,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Can't find it? Save your own entry",
                  style: TextStyle(fontSize: 12.5, color: Yc.textTertiary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Yc.calories),
        ],
      ),
    );
  }
}
