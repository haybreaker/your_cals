import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/activity.dart';
import '../../state/activity_search_controller.dart';
import '../../state/providers.dart';
import 'activity_editor_sheet.dart' show openActivityEditor, openCustomActivity;

/// Full-height activity search, hosted in a slide-up modal from the
/// capture sheet: search bar on top, Favourites / History tabs below,
/// live catalog results while typing. Mirrors the food Library.
Future<void> openActivityLog(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => const Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AuroraBackground(),
            ActivityLibraryPage(),
          ],
        ),
      ),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

class ActivityLibraryPage extends ConsumerStatefulWidget {
  const ActivityLibraryPage({super.key});

  @override
  ConsumerState<ActivityLibraryPage> createState() =>
      _ActivityLibraryPageState();
}

class _ActivityLibraryPageState extends ConsumerState<ActivityLibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 2, vsync: this, initialIndex: 1);
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activitySearchControllerProvider.notifier).reset();
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activitySearchControllerProvider);
    final ctrl = ref.read(activitySearchControllerProvider.notifier);
    final searching = state.query.trim().length >= 2;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Glass(
              radius: 24,
              opacity: 0.12,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  BackButton(
                      onPressed: () => Navigator.of(context).pop(),
                      color: Yc.textPrimary),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      style: const TextStyle(fontSize: 16.5),
                      decoration: const InputDecoration(
                        hintText: 'Search activities…',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Yc.textTertiary),
                      ),
                      onChanged: ctrl.onQueryChanged,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Yc.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        ctrl.onQueryChanged('');
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ),
          if (searching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '${state.results.length} activities',
                    style: const TextStyle(
                        fontSize: 12.5, color: Yc.textTertiary),
                  ),
                  const Spacer(),
                  if (state.searching)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Yc.calories),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Yc.calories.withValues(alpha: 0.22),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Yc.textPrimary,
                  unselectedLabelColor: Yc.textTertiary,
                  labelStyle: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Favourites'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
            ),
          Expanded(
            child: searching
                ? _ActivityResults(state: state)
                : _ActivityTabsView(controller: _tabs),
          ),
        ],
      ),
    );
  }
}

class _ActivityTabsView extends StatelessWidget {
  const _ActivityTabsView({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) => TabBarView(
        controller: controller,
        children: const [
          _ActivityFavoritesTab(),
          _ActivityHistoryTab(),
        ],
      );
}

class _ActivityResults extends StatelessWidget {
  const _ActivityResults({required this.state});

  final ActivitySearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.searching && state.results.isEmpty) {
      return const _SkeletonList();
    }
    if (state.results.isEmpty) {
      return _EmptyState(
        onAddManually: () => openCustomActivity(context),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: state.results.length + 1,
      itemBuilder: (context, i) {
        if (i == state.results.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: _AddActivityManuallyTile(
              onTap: () => openCustomActivity(context),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ActivityTile(activity: state.results[i]),
        );
      },
    );
  }
}

class _ActivityFavoritesTab extends ConsumerWidget {
  const _ActivityFavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(activityFavoritesProvider);
    final favs = favAsync.value ?? const [];
    if (favAsync.isLoading) return const _SkeletonList(count: 5);
    if (favs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'No favourites yet — star activities from the log sheet to pin them here.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Yc.textTertiary, fontSize: 13, height: 1.5),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: favs.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ActivityTile(activity: favs[i]),
      ),
    );
  }
}

class _ActivityHistoryTab extends ConsumerWidget {
  const _ActivityHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(activityHistoryProvider);
    final items = historyAsync.value ?? const [];
    if (historyAsync.isLoading) return const _SkeletonList();
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Nothing logged yet — search above to begin',
            textAlign: TextAlign.center,
            style: TextStyle(color: Yc.textTertiary, fontSize: 13),
          ),
        ),
      );
    }
    final groups = <String, List<(Activity, DateTime)>>{};
    final order = <String>[];
    for (final item in items) {
      final d = item.lastLogged;
      final key =
          DateTime(d.year, d.month, d.day).dayKey;
      if (!groups.containsKey(key)) {
        groups[key] = [];
        order.add(key);
      }
      groups[key]!.add((item.activity, item.lastLogged));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: order.length,
      itemBuilder: (context, gi) {
        final group = groups[order[gi]]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6, top: 4),
              child: Text(
                _dayGroupLabel(group.first.$2),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Yc.textTertiary),
              ),
            ),
            ...group.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ActivityTile(activity: e.$1),
                )),
          ],
        );
      },
    );
  }

  String _dayGroupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(day).inDays;
    if (diffDays <= 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 7) return '$diffDays days ago';
    return dt.prettyDay;
  }
}

/// One activity row: name, category, MET chip, and an hourly burn preview
/// at the user's current weight/age. Taps open the log editor.
class ActivityTile extends ConsumerWidget {
  const ActivityTile({super.key, required this.activity});

  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final perHour = profile == null
        ? null
        : ActivityMath.burnKcal(
            met: activity.met,
            metOlderAdult: activity.metOlderAdult,
            weightKg: profile.weightKg,
            minutes: 60,
            ageYears: profile.ageYears,
          );
    return GlassLite(
      radius: 20,
      opacity: 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => openActivityEditor(context, activity),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Icon(_intensityIcon,
                size: 19, color: Yc.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (activity.category.isNotEmpty)
                      Flexible(
                        child: Text(
                          activity.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, color: Yc.textTertiary),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color:
                            Colors.white.withValues(alpha: 0.07),
                      ),
                      child: Text(
                        '${_trimMet(activity.met)} MET · ${activity.intensity}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (perHour != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(perHour.kcalText,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700)),
                const Text('kcal / h',
                    style: TextStyle(
                        fontSize: 10.5, color: Yc.textTertiary)),
              ],
            ),
        ],
      ),
    );
  }

  static String _trimMet(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  IconData get _intensityIcon => switch (activity.category) {
        'Running' => Icons.directions_run_rounded,
        'Walking' => Icons.directions_walk_rounded,
        'Cycling' => Icons.directions_bike_rounded,
        'Swimming' => Icons.pool_rounded,
        'Garden & Lawn' => Icons.yard_rounded,
        'Housework' => Icons.cleaning_services_rounded,
        'Sports' => Icons.sports_soccer_rounded,
        'Dancing' => Icons.music_note_rounded,
        'Exergaming' => Icons.sports_esports_rounded,
        _ => Icons.fitness_center_rounded,
      };
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList({this.count = 7});

  final int count;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(
            count,
            (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Skeleton(height: 64, radius: 20),
                )),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddManually});

  final VoidCallback onAddManually;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded,
                  size: 48, color: Yc.textTertiary),
              const SizedBox(height: 14),
              const Text('No matches yet',
                  style: TextStyle(color: Yc.textTertiary, fontSize: 15)),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Yc.calories,
                  foregroundColor: const Color(0xFF06251B),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onAddManually,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add activity manually',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
}

class _AddActivityManuallyTile extends StatelessWidget {
  const _AddActivityManuallyTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassLite(
      radius: 20,
      opacity: 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: const Row(
        children: [
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add activity manually',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Yc.calories)),
                SizedBox(height: 3),
                Text('Custom routine? Enter its burn rate',
                    style: TextStyle(
                        fontSize: 12.5, color: Yc.textTertiary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Yc.calories),
        ],
      ),
    );
  }
}
