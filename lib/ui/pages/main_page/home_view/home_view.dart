import 'package:flutter/material.dart';
import 'package:your_cals/ui/pages/main_page/home_view/macro_card.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    const caloriesEaten = 1450;
    const calorieGoal = 2500;
    final caloriesRemaining = calorieGoal - caloriesEaten;
    final progress = caloriesEaten / calorieGoal;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text('Sunday, October 19', style: theme.textTheme.bodyLarge?.copyWith(color: color.onSurfaceVariant)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Total Calorie Card
          Card(
            elevation: 0,
            color: color.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.local_fire_department_rounded, color: color.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Calories",
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: color.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$caloriesEaten',
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color.onPrimaryContainer,
                                height: 1,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'kcal eaten',
                              style: theme.textTheme.bodyLarge?.copyWith(color: color.onPrimaryContainer.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$caloriesRemaining',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: color.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'remaining',
                              style: theme.textTheme.bodySmall?.copyWith(color: color.onPrimaryContainer.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: color.surface.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation(color.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0',
                        style: theme.textTheme.bodySmall?.copyWith(color: color.onPrimaryContainer.withOpacity(0.6)),
                      ),
                      Text(
                        'Goal: $calorieGoal kcal',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.onPrimaryContainer.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Macronutrients Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text('Macronutrients', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 12),

          // Macronutrient Cards
          const MacroCard(label: 'Protein', grams: 120, target: 180, color: Color(0xFF4285F4), icon: Icons.egg_outlined),
          const SizedBox(height: 12),
          const MacroCard(label: 'Fat', grams: 55, target: 80, color: Color(0xFFEA4335), icon: Icons.water_drop_outlined),
          const SizedBox(height: 12),
          const MacroCard(label: 'Carbs', grams: 180, target: 250, color: Color(0xFFFBAC04), icon: Icons.grain_outlined),
        ],
      ),
    );
  }
}
