import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

/// One-time setup screen: explains the wait, shows live import counts.
class BootProgressScreen extends ConsumerWidget {
  const BootProgressScreen({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(importProvider);
    final nf = NumberFormat.decimalPattern();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x337CF5C8), Color(0x1A7CF5C8)],
                  ),
                  border: Border.all(color: Yc.calories.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.restaurant_menu_rounded,
                    size: 40, color: Yc.calories),
              ),
              const SizedBox(height: 26),
              Text(
                error != null ? 'Something went wrong' : 'Preparing your food catalog',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                error != null
                    ? "Couldn't load the bundled food data.\n$error"
                    : 'One-time setup — copying 73,000+ Australian foods\n'
                        '(science data, supermarket products & menus)\n'
                        'onto this device so search works offline.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5, color: Yc.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 30),
              if (error == null)
                Glass(
                  radius: 20,
                  opacity: 0.09,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: state.total > 0
                              ? (state.done / state.total).clamp(0.0, 1.0)
                              : null,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor:
                              const AlwaysStoppedAnimation(Yc.calories),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.total > 0
                            ? '${state.stage} · ${nf.format(state.done)} / ${nf.format(state.total)}'
                            : 'Starting up…',
                        style: const TextStyle(
                            fontSize: 12.5, color: Yc.textSecondary),
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
