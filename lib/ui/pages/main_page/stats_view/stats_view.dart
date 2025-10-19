import 'package:flutter/material.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Stats', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
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
