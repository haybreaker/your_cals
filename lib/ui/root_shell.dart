import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/fx.dart';
import '../core/glass.dart';
import '../core/theme.dart';
import '../state/providers.dart';
import 'common/undo_banner.dart';
import 'diary/diary_page.dart';
import 'goals/goals_page.dart';
import 'library/library_page.dart';
import 'recipes/recipes_page.dart';
import 'capture/capture_sheet.dart';

/// Dock item ids.
enum _DockId { diary, recipes, capture, library, goals }

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> with WidgetsBindingObserver {
  int _tab = 0; // 0 diary · 1 recipes · 2 library · 3 goals
  DateTime _lastDay = DateTime.now();

  static final _pages = <Widget>[
    const DiaryPage(),
    const RecipesPage(),
    LibraryPage(),
    const GoalsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDayChange();
    }
  }

  void _checkDayChange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(_lastDay.year, _lastDay.month, _lastDay.day);

    if (today.isAfter(lastDay)) {
      // Day has changed — if user was looking at the old "today", move to new today
      final selected = ProviderScope.containerOf(context)
          .read(selectedDateProvider);
      final selectedDay = DateTime(selected.year, selected.month, selected.day);

      if (selectedDay == lastDay) {
        ProviderScope.containerOf(context)
            .read(selectedDateProvider.notifier)
            .state = now;
      }

      _lastDay = now;
      setState(() {});
    }
  }

  void _onDock(_DockId id) {
    switch (id) {
      case _DockId.diary:
        setState(() => _tab = 0);
        break;
      case _DockId.recipes:
        setState(() => _tab = 1);
        break;
      case _DockId.capture:
        showCaptureSheet(context);
        break;
      case _DockId.library:
        setState(() => _tab = 2);
        break;
      case _DockId.goals:
        setState(() => _tab = 3);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: UndoBannerHost(
        child: Stack(
        children: [
          const AuroraBackground(),
          // IndexedStack keeps pages alive — glass stays warm, no remount
          // flicker on tab switches.
          Positioned.fill(
            child: Offstage(
              offstage: false,
              child: IndexedStack(
                index: _tab,
                children: _pages,
              ),
            ),
          ),
        ],
      ),
      ),
      // Floating liquid-glass dock: Diary · Recipes · ＋ · Library · Goals
      bottomNavigationBar: _Dock(
        tab: _tab,
        onTap: _onDock,
        onCapture: () => showCaptureSheet(context),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  const _Dock({required this.tab, required this.onTap, required this.onCapture});

  final int tab;
  final void Function(_DockId) onTap;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Glass(
          radius: 34,
          blur: 26,
          opacity: 0.12,
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
          child: Row(
            children: [
              Expanded(
                child: _DockIcon(
                  icon: Icons.restaurant_rounded,
                  label: 'Diary',
                  active: tab == 0,
                  onTap: () => onTap(_DockId.diary),
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.soup_kitchen_rounded,
                  label: 'Recipes',
                  active: tab == 1,
                  onTap: () => onTap(_DockId.recipes),
                ),
              ),
              _CaptureButton(onTap: onCapture),
              Expanded(
                child: _DockIcon(
                  icon: Icons.library_books_rounded,
                  label: 'Library',
                  active: tab == 2,
                  onTap: () => onTap(_DockId.library),
                ),
              ),
              Expanded(
                child: _DockIcon(
                  icon: Icons.emoji_events_rounded,
                  label: 'Goals',
                  active: tab == 3,
                  onTap: () => onTap(_DockId.goals),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Yc.calories.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 21,
                color: active ? Yc.calories : Yc.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: active ? Yc.calories : Yc.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF9CF7D3), Color(0xFF34D399)],
            ),
            boxShadow: [
              BoxShadow(
                color: Yc.calories.withValues(alpha: 0.45),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded,
              color: Color(0xFF06251B), size: 30),
        ),
      ),
    );
  }
}
