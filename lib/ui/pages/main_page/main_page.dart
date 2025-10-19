import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_cals/data/providers/food_db_provider.dart';
import 'package:your_cals/ui/pages/log_food.dart';
import 'package:your_cals/ui/pages/main_page/calendar_view/calendar_view.dart';
import 'package:your_cals/ui/pages/main_page/main_page_navbar.dart';
import 'package:your_cals/ui/pages/main_page/stats_view/stats_view.dart';
import 'home_view/home_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomeDashboard(), CalendarView(), StatsView(), _BodyWeightPage()];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _onLogFood(context) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => LogFoodPage()));

  void _onAddPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Quick Add', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.restaurant, color: Theme.of(context).colorScheme.primary),
                title: const Text('Log Food'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.pop(context);
                  _onLogFood(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
                title: const Text('Log Exercise'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.water_drop, color: Theme.of(context).colorScheme.primary),
                title: const Text('Log Water'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _pages[_currentIndex],
            MainPageNavbar(selectedInt: _currentIndex, onNavigationChange: _onItemTapped, onAddPressed: _onAddPressed),
            // Food DB Update Progress Overlay
            Consumer<FoodDatabaseProvider>(
              builder: (context, provider, _) {
                if (!provider.isPullingLatest) return const SizedBox.shrink();

                return _FoodDatabaseUpdateOverlay(progress: provider.percentageOfDownload);
              },
            ),
          ],
        ),
      ),
      extendBody: true,
    );
  }
}

class _FoodDatabaseUpdateOverlay extends StatelessWidget {
  final double progress;

  const _FoodDatabaseUpdateOverlay({required this.progress});

  String _getStatusText() {
    if (progress < 0.3) return 'Downloading food database...';
    if (progress < 0.4) return 'Decompressing data...';
    return 'Processing food items...';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (progress * 100).toInt();

    return Container(
      color: colorScheme.surface.withOpacity(0.95),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primaryContainer),
                      child: Icon(Icons.download_rounded, size: 48, color: colorScheme.onPrimaryContainer),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Updating Food Database',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Status text
              Text(
                _getStatusText(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Percentage
              Text(
                '$percentage%',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const SizedBox(height: 16),

              // Info text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20, color: colorScheme.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This happens once a week to keep your food database fresh',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyWeightPage extends StatelessWidget {
  const _BodyWeightPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_weight_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Body Weight', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
