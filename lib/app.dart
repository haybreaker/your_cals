import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/fx.dart';
import 'core/theme.dart';
import 'state/providers.dart';
import 'ui/boot/boot_progress.dart';
import 'ui/onboarding/onboarding.dart';
import 'ui/root_shell.dart';

class YourCalsApp extends StatelessWidget {
  const YourCalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YourCals',
      debugShowCheckedModeBanner: false,
      theme: Yc.theme(context),
      home: const BootGate(),
    );
  }
}

/// Splash while seeding → onboarding for new users → main shell.
class BootGate extends ConsumerWidget {
  const BootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final import = ref.watch(importProvider);
    final profile = ref.watch(profileProvider);

    return Stack(
      children: [
        const AuroraBackground(),
        if (import.working || profile.isLoading)
          BootProgressScreen(error: import.error)
        else if (import.error != null)
          BootProgressScreen(error: import.error)
        else
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutCubic,
            child: (profile.value == null)
                ? const OnboardingScreen(key: ValueKey('onboarding'))
                : const RootShell(key: ValueKey('shell')),
          ),
      ],
    );
  }
}
