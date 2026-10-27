import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/activity.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../domain/profile.dart';
import '../../domain/weight.dart';
import '../../state/providers.dart';
import '../activity/activity_editor_sheet.dart' show openActivityEditor;
import '../activity/activity_page.dart' show openActivityLog;
import '../capture/capture_sheet.dart';
import '../common/dialogs.dart';
import '../common/yc_progress_bar.dart';
import '../recipes/recipes_page.dart' show openRecipeEditor;
import '../settings/settings_page.dart';
import 'log_entry_detail.dart';
import '../common/undo_banner.dart';

class DiaryPage extends ConsumerWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final weekly = ref.watch(diaryWeeklyProvider);
    // Day entries stay watched here for the multi-select tray (daily-only
    // interaction, but harmless while the weekly view is shown).
    final entries =
        ref.watch(dayEntriesProvider(date)).value ?? const <LogEntry>[];
    final selection = ref.watch(diarySelectionProvider);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          CustomScrollView(
            scrollCacheExtent: ScrollCacheExtent.pixels(800),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(date: date, weekly: weekly),
                      const SizedBox(height: 16),
                      WeekScrubber(selected: date, inactive: weekly),
                      const SizedBox(height: 12),
                      const _DiaryControls(),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        // Old view exits fast so the two heights never
                        // ghost over each other mid-transition.
                        reverseDuration: const Duration(milliseconds: 130),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        // Top-aligned stack: heights differ, so centering
                        // would shift both views vertically mid-flight.
                        layoutBuilder: (currentChild, previousChildren) =>
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [?currentChild, ...previousChildren],
                            ),
                        transitionBuilder: (child, anim) {
                          // Outgoing plays in reverse — fade only.
                          if (anim.status == AnimationStatus.reverse) {
                            return FadeTransition(opacity: anim, child: child);
                          }
                          // Incoming: fade + settle from 98%.
                          return FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween(begin: 0.98, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: weekly
                            ? DiaryViewWeekly(
                                key: const ValueKey('weekly'),
                                date: date,
                              )
                            : DiaryViewDaily(
                                key: const ValueKey('daily'),
                                date: date,
                              ),
                      ),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Multi-select action bar, kept fully clear of the floating dock.
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: IgnorePointer(
              ignoring: selection.mode == DiaryListMode.normal,
              child: _DiaryActionTray(entries: entries, selection: selection),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.date, this.weekly = false});

  final DateTime date;

  /// When the weekly chip owns the selection, the header names the week.
  final bool weekly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // spaceBetween (not a Spacer) pins the gear right with no middleman;
    // the title takes up to 3/4 of free space before shrinking, so
    // large-text titles stay legible instead of collapsing.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Large-text safe: the title shrinks instead of clipping.
        Flexible(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                weekly ? 'This week' : date.prettyDay,
                key: ValueKey(weekly ? 'week' : date.prettyDay),
                maxLines: 1,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
        // Settings lives here now (dock slot became Goals).
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, _, _) => const SettingsPage(),
              transitionsBuilder: (_, anim, _, child) => SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: child,
              ),
            ),
          ),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Icon(
                Icons.settings_rounded,
                size: 21,
                color: Yc.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Daily diary: calorie hero + meal sections + activity. Extracted so the
/// weekly summary lives in its own widget instead of branching inline.
class DiaryViewDaily extends ConsumerWidget {
  const DiaryViewDaily({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final entries =
        ref.watch(dayEntriesProvider(date)).value ?? const <LogEntry>[];
    final exerciseEntries =
        ref.watch(dayExerciseProvider(date)).value ?? const [];
    final weighIns =
        ref.watch(weightEntriesProvider).value ?? const <WeightEntry>[];

    // Targets in effect on THIS day: weigh-ins move the live target
    // forward without rewriting what past days were judged against.
    final goals = profile == null
        ? null
        : Goals.effectiveForDay(profile, weighIns, date);
    final consumed = Nutriments.sum(entries.map((e) => e.nutr));

    // Exercise bonus: movement already assumed by the activity factor
    // earns nothing; only burn above that budget raises the target.
    final exerciseDay = ActivityMath.resolve(
      kcalTarget: (goals?.kcalTarget ?? 2000).toDouble(),
      bmr: goals?.bmr ?? 0,
      activityFactor: profile?.activity.factor ?? 1.2,
      loggedKcal: exerciseEntries.fold<double>(
        0,
        (a, e) => a + e.effectiveKcal,
      ),
    );

    return Column(
      children: [
        _CalorieHero(
          consumed: consumed.kcal,
          target: exerciseDay.effectiveTarget,
          bonusKcal: exerciseDay.bonusKcal,
          protein: consumed.proteinG,
          proteinTarget: goals?.proteinG ?? 120,
          carbs: consumed.carbsG,
          carbsTarget: goals?.carbsG ?? 200,
          fat: consumed.fatG,
          fatTarget: goals?.fatG ?? 65,
        ),
        const SizedBox(height: 22),
        ...MealType.values.map(
          (meal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MealSection(
              meal: meal,
              entries: entries.where((e) => e.meal == meal).toList(),
              onAdd: () => showCaptureSheet(context, meal: meal),
            ),
          ),
        ),
        // Activity section only appears once used — the
        // food-only diary is untouched otherwise.
        if (exerciseEntries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivitySection(
              entries: exerciseEntries,
              bonusKcal: exerciseDay.bonusKcal,
            ),
          ),
      ],
    );
  }
}

/// Horizontal 7-day picker centered on today. While the weekly chip is
/// active the day chips render deselected + dimmed (the week is the
/// selection); tapping any of them still jumps to that day.
class WeekScrubber extends ConsumerWidget {
  const WeekScrubber({
    super.key,
    required this.selected,
    this.inactive = false,
  });

  final DateTime selected;

  /// True when "This week" owns the selection — chips go quiet.
  final bool inactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final accentFill = Yc.accent.withValues(alpha: 0.18);
    final accentFillEnd = Yc.accent.withValues(alpha: 0.10);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      opacity: inactive ? 0.45 : 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((d) {
          final isSel =
              !inactive &&
              d.day == selected.day &&
              d.month == selected.month &&
              d.year == selected.year;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // A day chip is a daily-view affordance — snap out of weekly.
              ref.read(diaryWeeklyProvider.notifier).state = false;
              ref.read(selectedDateProvider.notifier).state = d;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Yc.radiusSm),
                gradient: isSel
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accentFill, accentFillEnd],
                      )
                    : null,
                border: Border.all(
                  color: isSel
                      ? Yc.accent.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
                    style: TextStyle(
                      fontSize: AppText.caption,
                      color: isSel ? Yc.accent : Yc.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: AppText.headline,
                      fontWeight: FontWeight.w700,
                      color: isSel ? Yc.textPrimary : Yc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Diary controls: date picker + weekly chip ──────────────────────────────

/// Small calendar button + "This week" chip below the day chips. The week
/// chip is select-only (like a day chip): tapping it while active is a
/// no-op — day chips are the way back to daily.
class _DiaryControls extends ConsumerWidget {
  const _DiaryControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(diaryWeeklyProvider);
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _openDatePicker(context, ref),
          child: Glass(
            radius: Yc.radiusSm,
            opacity: 0.09,
            padding: const EdgeInsets.all(11),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 19,
              color: Yc.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: weekly
                ? null
                : () => ref.read(diaryWeeklyProvider.notifier).state = true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Yc.radiusSm),
                gradient: weekly
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Yc.accent.withValues(alpha: 0.22),
                          Yc.accent.withValues(alpha: 0.12),
                        ],
                      )
                    : null,
                color: weekly ? null : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: weekly
                      ? Yc.accent.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                'This week',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppText.subheadline,
                  fontWeight: FontWeight.w700,
                  color: weekly ? Yc.accent : Yc.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openDatePicker(BuildContext context, WidgetRef ref) {
    final selected = ref.read(selectedDateProvider);
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DatePickerDialog(initial: selected),
    );
  }
}

/// Frosted month-grid date picker matching the chip design language.
class _DatePickerDialog extends ConsumerStatefulWidget {
  const _DatePickerDialog({required this.initial});

  final DateTime initial;

  @override
  ConsumerState<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends ConsumerState<_DatePickerDialog> {
  late DateTime _month = DateTime(widget.initial.year, widget.initial.month);

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDateProvider);
    final today = DateTime.now();

    final firstOfMonth = DateTime(_month.year, _month.month);
    // Sunday-first grid: leading blanks before the 1st.
    final leading = firstOfMonth.weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _MonthArrow(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => setState(
                    () => _month = DateTime(_month.year, _month.month - 1),
                  ),
                ),
                Expanded(
                  child: Text(
                    _monthLabel(_month),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _MonthArrow(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => setState(
                    () => _month = DateTime(_month.year, _month.month + 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: weekdays
                  .map(
                    (w) => Expanded(
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: leading + daysInMonth,
              itemBuilder: (context, i) {
                if (i < leading) return const SizedBox.shrink();
                final day = i - leading + 1;
                final d = DateTime(_month.year, _month.month, day);
                final isSel = _sameDay(d, selected);
                final isToday = _sameDay(d, today);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref.read(diaryWeeklyProvider.notifier).state = false;
                    ref.read(selectedDateProvider.notifier).state = d;
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isSel
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Yc.accent.withValues(alpha: 0.25),
                                Yc.accent.withValues(alpha: 0.13),
                              ],
                            )
                          : null,
                      border: Border.all(
                        color: isSel
                            ? Yc.accent.withValues(alpha: 0.6)
                            : isToday
                            ? Yc.accent.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel
                              ? Yc.textPrimary
                              : isToday
                              ? Yc.accent
                              : Yc.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _monthLabel(DateTime m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[m.month - 1]} ${m.year}';
  }
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.06),
        ),
        child: Icon(icon, size: 22, color: Yc.textSecondary),
      ),
    );
  }
}

// ─── Weekly diary view ────────────────────────────────────────────────────────

/// Sun–Sat summary for the week containing [date]: weekly budget ring,
/// per-meal totals with daily averages, and the cheat-day calculator.
class DiaryViewWeekly extends ConsumerWidget {
  const DiaryViewWeekly({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = weekDaysOf(date);
    final entries =
        ref.watch(weekEntriesProvider(date)).value ?? const <LogEntry>[];
    final exercise = ref.watch(weekExerciseProvider(date)).value ?? const [];
    final profile = ref.watch(profileProvider).value;
    final weighIns =
        ref.watch(weightEntriesProvider).value ?? const <WeightEntry>[];

    final factor = profile?.activity.factor ?? 1.2;
    // Forward-planning target: today's live target.
    final liveDailyTarget = profile == null
        ? 2000.0
        : Goals.effectiveForDay(
            profile,
            weighIns,
            DateTime.now(),
          ).kcalTarget.toDouble();

    double consumed = 0, bonus = 0, target = 0;
    final perMeal = {for (final m in MealType.values) m: 0.0};
    final dayKcals = List<double>.filled(7, 0);
    for (var i = 0; i < days.length; i++) {
      final d = days[i];
      final key = d.dayKey;
      final dayEntries = entries.where((e) => e.day == key);
      final dayExercise = exercise.where((e) => e.day == key);
      final dayNutr = Nutriments.sum(dayEntries.map((e) => e.nutr));
      consumed += dayNutr.kcal;
      dayKcals[i] = dayNutr.kcal;
      for (final e in dayEntries) {
        perMeal[e.meal] = perMeal[e.meal]! + e.nutr.kcal;
      }
      // Each day judged against the target live on THAT day, so past
      // weeks never shift when weight changes later.
      final dayGoals = profile == null
          ? null
          : Goals.effectiveForDay(profile, weighIns, d);
      final dayTarget = (dayGoals?.kcalTarget ?? 2000).toDouble();
      target += dayTarget;
      final logged = dayExercise.fold<double>(0, (a, e) => a + e.effectiveKcal);
      bonus += ActivityMath.resolve(
        kcalTarget: dayTarget,
        bmr: dayGoals?.bmr ?? 0,
        activityFactor: factor,
        loggedKcal: logged,
      ).bonusKcal;
    }
    target += bonus;

    final start = days.first;
    final end = days.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sun ${start.day} – Sat ${end.day} ${_monthShort(end.month)}',
          style: const TextStyle(
            fontSize: AppText.subheadline,
            fontWeight: FontWeight.w700,
            color: Yc.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        _WeeklyHero(consumed: consumed, target: target, bonusKcal: bonus),
        const SizedBox(height: 12),
        ...MealType.values.map(
          (meal) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MealWeekCard(
              meal: meal,
              total: perMeal[meal] ?? 0,
              weekTotal: consumed,
            ),
          ),
        ),
        _CheatDayCard(
          consumed: consumed,
          target: target,
          dailyTarget: liveDailyTarget,
          days: days,
          dayKcals: dayKcals,
        ),
        // Breathing room above the floating dock.
        const SizedBox(height: 8),
      ],
    );
  }

  static String _monthShort(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}

class _WeeklyHero extends StatefulWidget {
  const _WeeklyHero({
    required this.consumed,
    required this.target,
    this.bonusKcal = 0,
  });

  final double consumed, target;
  final double bonusKcal;

  @override
  State<_WeeklyHero> createState() => _WeeklyHeroState();
}

class _WeeklyHeroState extends State<_WeeklyHero> {
  bool _showEaten = false;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target - widget.consumed;
    final over = remaining < 0;
    final avg = widget.consumed / 7;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: ProgressRing(
                progress: widget.target <= 0
                    ? 0
                    : widget.consumed / widget.target,
                bonusProgress: widget.target <= 0
                    ? 0
                    : widget.bonusKcal / widget.target,
                bonusColor: Yc.success,
                color: over ? Yc.danger : Yc.accent,
                gradientEnd: over ? Yc.danger : Yc.success,
                size: 190,
                stroke: 13,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _showEaten = !_showEaten),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_showEaten) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.consumed.kcalText} / ${widget.target.kcalText}',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: over ? Yc.danger : null,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          'eaten this week',
                          style: TextStyle(
                            color: over
                                ? Yc.danger.withValues(alpha: 0.85)
                                : Yc.textSecondary,
                            fontSize: AppText.subheadline,
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              over
                                  ? '+${(-remaining).kcalText}'
                                  : remaining.kcalText,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: over ? Yc.danger : null,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          over ? 'kcal over' : 'kcal left this week',
                          style: TextStyle(
                            color: over
                                ? Yc.danger.withValues(alpha: 0.85)
                                : Yc.textSecondary,
                            fontSize: AppText.subheadline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '≈ ${avg.kcalText} kcal / day average',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppText.footnote,
              fontWeight: FontWeight.w600,
              color: Yc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// One meal's week in its own card — same header language as the daily
/// meal sections (label left, total right) plus the daily average and a
/// share-of-week bar so problem meals stand out.
class _MealWeekCard extends StatelessWidget {
  const _MealWeekCard({
    required this.meal,
    required this.total,
    required this.weekTotal,
  });

  final MealType meal;
  final double total;
  final double weekTotal;

  @override
  Widget build(BuildContext context) {
    final share = weekTotal <= 0 ? 0.0 : (total / weekTotal).clamp(0.0, 1.0);
    return Glass(
      radius: Yc.radiusMd,
      opacity: 0.07,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  meal.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppText.headline,
                  ),
                ),
              ),
              const Spacer(),
              if (total > 0)
                Text(
                  '${total.kcalText} kcal',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: AppText.footnote,
                    fontWeight: FontWeight.w600,
                    color: Yc.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            total <= 0
                ? 'Nothing logged'
                : '≈ ${(total / 7).kcalText} / day · ${(share * 100).round()}% of the week',
            style: TextStyle(
              fontSize: AppText.footnote,
              color: total <= 0 ? Yc.textTertiary : Yc.textSecondary,
            ),
          ),
          const SizedBox(height: 7),
          YcProgressBar(
            fraction: share,
            color: Yc.accent.withValues(alpha: 0.75),
            height: 6,
          ),
        ],
      ),
    );
  }
}

/// Ad-hoc cheat-day planner: a concrete "have X on Saturday if you keep
/// Y until then" suggestion (or the even split when the numbers don't
/// allow a real treat), plus a 7-day strip for context. Past/future
/// weeks degrade to average/target summaries.
class _CheatDayCard extends StatelessWidget {
  const _CheatDayCard({
    required this.consumed,
    required this.target,
    required this.dailyTarget,
    required this.days,
    required this.dayKcals,
  });

  final double consumed;
  final double target;
  final double dailyTarget;
  final List<DateTime> days;

  /// Consumed kcal per day, Sun..Sat aligned with [days].
  final List<double> dayKcals;

  @override
  Widget build(BuildContext context) {
    final remaining = target - consumed;
    final today = DateTime.now();
    final todayKey = today.dayKey;
    final isCurrentWeek = days.any((d) => d.dayKey == todayKey);
    final isFutureWeek = days.first.isAfter(
      DateTime(today.year, today.month, today.day),
    );

    late final String headline;
    late final String body;
    late final Color accent;
    late final IconData icon;

    if (isFutureWeek) {
      headline = '${target.kcalText} kcal target';
      body = 'Nothing logged yet — the week hasn\u2019t started.';
      accent = Yc.textSecondary;
      icon = Icons.calendar_view_week_rounded;
    } else if (!isCurrentWeek) {
      headline = '≈ ${(consumed / 7).kcalText} kcal / day';
      body = 'Average across this week.';
      accent = Yc.textSecondary;
      icon = Icons.calendar_view_week_rounded;
    } else {
      // Days left including today (Sun=0 … Sat=6 elapsed).
      final elapsed = (today.weekday % 7) + 1;
      final left = (7 - elapsed + 1).clamp(1, 7);
      final plan = _CheatPlan.suggest(
        remaining: remaining,
        dailyTarget: dailyTarget,
        daysLeft: left,
        lastDayName: _weekdayLong(days.last.weekday),
      );
      headline = plan.headline;
      body = plan.body;
      accent = plan.accent;
      icon = plan.icon;
    }

    final todayIdx = isCurrentWeek
        ? days.indexWhere((d) => d.dayKey == todayKey)
        : -1;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.15),
                ),
                child: Icon(icon, size: 26, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Yc.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WeekStrip(
            dayKcals: dayKcals,
            dailyTarget: dailyTarget,
            todayIndex: todayIdx,
          ),
        ],
      ),
    );
  }

  static String _weekdayLong(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

/// Pure cheat-day math: bank lean days, unlock one big day.
class _CheatPlan {
  const _CheatPlan({
    required this.headline,
    required this.body,
    required this.accent,
    required this.icon,
  });

  final String headline;
  final String body;
  final Color accent;
  final IconData icon;

  /// Round to a human number for display (2,022 → 2,000).
  static double _nice(double v) {
    if (v >= 1000) return (v / 50).round() * 50;
    if (v >= 200) return (v / 10).round() * 10;
    return (v / 5).round() * 5;
  }

  static _CheatPlan suggest({
    required double remaining,
    required double dailyTarget,
    required int daysLeft,
    required String lastDayName,
  }) {
    if (remaining < 0) {
      final recover = dailyTarget + remaining / daysLeft;
      if (recover <= 0) {
        return const _CheatPlan(
          headline: 'Over budget',
          body: 'Bank lighter days to recover — every kcal counts.',
          accent: Yc.danger,
          icon: Icons.trending_down_rounded,
        );
      }
      return _CheatPlan(
        headline: '+${(-remaining).kcalText} kcal over',
        body:
            'Eat ≤ ≈ ${_nice(recover).kcalText} / day for the last $daysLeft day${daysLeft == 1 ? '' : 's'} to finish on target.',
        accent: Yc.danger,
        icon: Icons.trending_down_rounded,
      );
    }
    final even = remaining / daysLeft;
    if (daysLeft == 1) {
      return _CheatPlan(
        headline: '${_nice(remaining).kcalText} kcal left today',
        body: 'Finish the week strong.',
        accent: Yc.calories,
        icon: Icons.savings_rounded,
      );
    }
    // Bank (daysLeft - 1) lean days to unlock the last day as the treat.
    final lean = _nice(dailyTarget * 0.9);
    final cheat = _nice(remaining - lean * (daysLeft - 1));
    if (cheat >= dailyTarget * 1.15) {
      return _CheatPlan(
        headline: 'Have ${cheat.kcalText} on $lastDayName',
        body:
            'Keep ≈ ${lean.kcalText} for the next ${daysLeft - 1} day${daysLeft - 1 == 1 ? '' : 's'} and $lastDayName is yours.',
        accent: Yc.success,
        icon: Icons.celebration_rounded,
      );
    }
    return _CheatPlan(
      headline: '${_nice(remaining).kcalText} kcal left',
      body: '≈ ${_nice(even).kcalText} / day for the last $daysLeft days.',
      accent: Yc.calories,
      icon: Icons.savings_rounded,
    );
  }
}

/// Seven solid day-squares (Sun..Sat): the whole square fills — heavier
/// days read bolder via intensity, over-target days go red, future days
/// stay empty. Today gets the accent ring.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.dayKcals,
    required this.dailyTarget,
    required this.todayIndex,
  });

  final List<double> dayKcals;
  final double dailyTarget;
  final int todayIndex;

  static const _letters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++) ...[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: _fillFor(i),
                    border: i == todayIndex
                        ? Border.all(
                            color: Yc.accent.withValues(alpha: 0.65),
                            width: 1.5,
                          )
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _letters[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: i == todayIndex ? Yc.accent : Yc.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (i < 6) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Color _fillFor(int i) {
    final kcal = dayKcals[i];
    if (kcal <= 0 || dailyTarget <= 0) {
      return Colors.white.withValues(alpha: 0.07);
    }
    if (kcal > dailyTarget * 1.1) {
      return Yc.danger.withValues(alpha: 0.85);
    }
    // Solid square, bolder the heavier the day (0.30 → 0.90).
    final f = (kcal / dailyTarget).clamp(0.0, 1.0);
    return Yc.accent.withValues(alpha: 0.30 + 0.60 * f);
  }
}

class _CalorieHero extends StatefulWidget {
  const _CalorieHero({
    required this.consumed,
    required this.target,
    this.bonusKcal = 0,
    required this.protein,
    required this.proteinTarget,
    required this.carbs,
    required this.carbsTarget,
    required this.fat,
    required this.fatTarget,
  });

  final double consumed, target;

  /// Exercise-earned allowance included in [target]; rendered as the
  /// light-green arc continuing the consumed arc. Zero by default.
  final double bonusKcal;
  final double protein, proteinTarget;
  final double carbs, carbsTarget;
  final double fat, fatTarget;

  @override
  State<_CalorieHero> createState() => _CalorieHeroState();
}

class _CalorieHeroState extends State<_CalorieHero> {
  /// False: remaining view ("743" / "kcal left"). True: eaten view
  /// ("1,178 / 1,921" / "eaten"). Toggled by tapping the ring.
  bool _showEaten = false;

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target - widget.consumed;
    final over = remaining < 0;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: 190,
            height: 190,
            child: ProgressRing(
              progress: widget.target <= 0
                  ? 0
                  : widget.consumed / widget.target,
              bonusProgress: widget.target <= 0
                  ? 0
                  : widget.bonusKcal / widget.target,
              bonusColor: Yc.success,
              color: over ? Yc.danger : Yc.accent,
              gradientEnd: over ? Yc.danger : Yc.success,
              size: 190,
              stroke: 13,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _showEaten = !_showEaten),
                child: Tooltip(
                  message: _showEaten ? 'Show remaining' : 'Show eaten',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_showEaten) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.consumed.kcalText} / ${widget.target.kcalText}',
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: over ? Yc.danger : null,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          'eaten',
                          style: TextStyle(
                            color: over
                                ? Yc.danger.withValues(alpha: 0.85)
                                : Yc.textSecondary,
                            fontSize: AppText.subheadline,
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              over
                                  ? '+${(-remaining).kcalText}'
                                  : remaining.kcalText,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: over ? Yc.danger : null,
                                  ),
                            ),
                          ),
                        ),
                        Text(
                          over ? 'kcal over' : 'kcal left',
                          style: TextStyle(
                            color: over
                                ? Yc.danger.withValues(alpha: 0.85)
                                : Yc.textSecondary,
                            fontSize: AppText.subheadline,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          MacroBar(
            label: 'Protein',
            value: widget.protein,
            target: widget.proteinTarget,
            color: Yc.protein,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Carbs',
            value: widget.carbs,
            target: widget.carbsTarget,
            color: Yc.carbs,
          ),
          const SizedBox(height: 10),
          MacroBar(
            label: 'Fat',
            value: widget.fat,
            target: widget.fatTarget,
            color: Yc.fat,
          ),
        ],
      ),
    );
  }
}

class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppText.footnote,
                  fontWeight: FontWeight.w600,
                  color: Yc.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${value.gText} / ${target.gText} g',
              maxLines: 1,
              style: const TextStyle(
                fontSize: AppText.footnote,
                fontWeight: FontWeight.w500,
                color: Yc.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        YcProgressBar.of(value: value, target: target, color: color),
      ],
    );
  }
}

class _MealSection extends ConsumerStatefulWidget {
  const _MealSection({
    required this.meal,
    required this.entries,
    required this.onAdd,
  });

  final MealType meal;
  final List<LogEntry> entries;
  final VoidCallback onAdd;

  @override
  ConsumerState<_MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends ConsumerState<_MealSection> {
  bool _dragOver = false;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final meal = widget.meal;
    final entries = widget.entries;
    final onAdd = widget.onAdd;
    final total = Nutriments.sum(entries.map((e) => e.nutr)).kcal;

    return DragTarget<LogEntry>(
      onWillAcceptWithDetails: (d) => d.data.meal != meal,
      onMove: (_) => setState(() => _dragOver = true),
      onLeave: (_) => setState(() => _dragOver = false),
      onAcceptWithDetails: (d) {
        setState(() => _dragOver = false);
        // Drop onto another section: move to the end of that section.
        ref
            .read(diaryRepoProvider)
            .reorder(d.data, meal: meal, newIndex: 1 << 30);
      },
      builder: (context, candidates, _) {
        final highlight = _dragOver || candidates.isNotEmpty;
        return Glass(
          radius: Yc.radiusMd,
          opacity: highlight ? 0.16 : 0.07,
          tint: highlight ? Yc.accent : null,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    meal.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppText.headline,
                    ),
                  ),
                  const Spacer(),
                  if (total > 0) ...[
                    Text(
                      '${total.kcalText} kcal',
                      style: const TextStyle(
                        fontSize: AppText.footnote,
                        fontWeight: FontWeight.w600,
                        color: Yc.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  _AddPill(onTap: onAdd),
                ],
              ),
              const SizedBox(height: 6),
              if (entries.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: Text(
                      highlight ? 'Drop to move here' : 'Nothing logged',
                      style: TextStyle(
                        fontSize: AppText.footnote,
                        color: highlight ? Yc.accent : Yc.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                for (var i = 0; i < entries.length; i++) ...[
                  EntryTile(
                    key: ValueKey(entries[i].id),
                    entry: entries[i],
                    listIndex: i,
                    sectionEntries: entries,
                  ),
                  // Intra-section drop zone between tiles (and at the end).
                  _InsertGap(
                    meal: meal,
                    entry: entries[i],
                    sectionEntries: entries,
                    isLast: i == entries.length - 1,
                  ),
                ],
            ],
          ),
        );
      },
    );
  }
}

/// Exercise section: logged bouts for the day with total burn and the
/// earned bonus. Only rendered once used — the food-only diary is
/// otherwise untouched.
class _ActivitySection extends ConsumerWidget {
  const _ActivitySection({required this.entries, required this.bonusKcal});

  final List<ExerciseEntry> entries;
  final double bonusKcal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final burned = entries.fold<double>(0, (a, e) => a + e.effectiveKcal);
    return Glass(
      radius: Yc.radiusMd,
      opacity: 0.07,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Activity',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppText.headline,
                ),
              ),
              const Spacer(),
              Text(
                '−${burned.kcalText} kcal',
                style: const TextStyle(
                  fontSize: AppText.footnote,
                  fontWeight: FontWeight.w600,
                  color: Yc.textSecondary,
                ),
              ),
              if (bonusKcal > 0.5) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: Yc.success.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    '+${bonusKcal.kcalText} bonus',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Yc.success,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              _AddPill(onTap: () => openActivityLog(context)),
            ],
          ),
          const SizedBox(height: 6),
          for (final e in entries) _ExerciseTile(key: ValueKey(e.id), entry: e),
        ],
      ),
    );
  }
}

class _ExerciseTile extends ConsumerWidget {
  const _ExerciseTile({super.key, required this.entry});

  final ExerciseEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Yc.radiusRow),
          color: Yc.danger.withValues(alpha: 0.25),
        ),
        child: const Icon(Icons.delete_rounded, color: Yc.danger),
      ),
      confirmDismiss: (_) async {
        final ok = await confirmGlassDialog(
          context,
          title: 'Delete ${entry.name}?',
          body: 'You can undo for a few seconds after.',
        );
        return ok;
      },
      onDismissed: (_) async {
        // Capture the undo host BEFORE the await (context dies on pop).
        final host = context.mounted ? UndoBannerHostState.of(context) : null;
        await ref.read(exerciseRepoProvider).delete(entry.id);
        host?.show(
          UndoRequest(
            text: '${entry.name} removed',
            onUndo: () => ref.read(exerciseRepoProvider).restore(entry),
          ),
        );
      },
      child: _PressableTile(
        onTap: () async {
          final activity = await ref
              .read(activityRepoProvider)
              .byId(entry.activityId);
          if (activity != null && context.mounted) {
            openActivityEditor(context, activity, entry: entry);
          }
        },
        // Plain row mirroring food tiles: no inner card, greyscale thumb.
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 20,
                  color: Yc.textTertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatQty(entry.minutes)} min · ${entry.effectiveKcal.kcalText} kcal burned'
                      '${entry.isOverride ? ' · watch' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppText.footnote,
                        color: Yc.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: '−${entry.effectiveKcal.kcalText}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  children: const [
                    TextSpan(
                      text: ' kcal',
                      style: TextStyle(
                        fontSize: AppText.caption,
                        color: Yc.textSecondary,
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

/// Thin DragTarget between tiles that reorders within the section.
class _InsertGap extends ConsumerStatefulWidget {
  const _InsertGap({
    required this.meal,
    required this.entry,
    required this.sectionEntries,
    required this.isLast,
  });

  /// Section this gap belongs to (cross-section drops land here).
  final MealType meal;

  /// Tile above the gap; dropped entries land directly below it.
  final LogEntry entry;
  final List<LogEntry> sectionEntries;
  final bool isLast;

  @override
  ConsumerState<_InsertGap> createState() => _InsertGapState();
}

class _InsertGapState extends ConsumerState<_InsertGap> {
  bool _hover = false;

  static const _h = 6.0;

  @override
  Widget build(BuildContext context) {
    return DragTarget<LogEntry>(
      onWillAcceptWithDetails: (d) => true,
      onMove: (_) => setState(() => _hover = true),
      onLeave: (_) => setState(() => _hover = false),
      onAcceptWithDetails: (d) {
        setState(() => _hover = false);
        final dragged = d.data;
        final sectionEntries = widget.sectionEntries;
        final sameSection =
            dragged.meal == widget.meal &&
            sectionEntries.any((e) => e.id == dragged.id);
        // Target index within the siblings (dragged entry excluded).
        final siblings = sectionEntries
            .where((e) => e.id != dragged.id)
            .toList();
        final belowIdx =
            siblings.indexWhere((e) => e.id == widget.entry.id) + 1;
        var targetIdx = belowIdx;
        if (sameSection) {
          // Same section — account for removal shift: if the dragged entry
          // was above the gap's entry, inserting "after" lands one slot
          // higher than naive index math suggests.
          final dragIdx = sectionEntries.indexWhere((e) => e.id == dragged.id);
          final entryIdx = sectionEntries.indexWhere(
            (e) => e.id == widget.entry.id,
          );
          if (dragIdx < entryIdx) targetIdx = entryIdx;
        }
        ref
            .read(diaryRepoProvider)
            .reorder(
              dragged,
              // Cross-section gap drops must land in THIS section.
              meal: widget.meal,
              newIndex: targetIdx,
            );
      },
      builder: (context, _, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        height: _hover ? 22 : _h,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: _hover
              ? Yc.accent.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
      ),
    );
  }
}

class _AddPill extends StatelessWidget {
  const _AddPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = Yc.accent.withValues(alpha: 0.15);
    return GestureDetector(
      // 44pt hit target wrapping a 36pt visual (Apple minimum-touch rule).
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fill),
            child: const Icon(Icons.add_rounded, size: 20, color: Yc.accent),
          ),
        ),
      ),
    );
  }
}

class EntryTile extends ConsumerStatefulWidget {
  const EntryTile({
    super.key,
    required this.entry,
    this.listIndex,
    this.sectionEntries,
  });

  final LogEntry entry;

  /// Position within its meal section (for reorder drops) — may be null in
  /// other embeds.
  final int? listIndex;
  final List<LogEntry>? sectionEntries;

  @override
  ConsumerState<EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends ConsumerState<EntryTile> {
  /// Cumulative pointer travel during the current long-press drag.
  double _dragTravel = 0;

  static const _selectMaxTravel = 24.0;

  LogEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(diarySelectionProvider);
    final multi = selection.isMultiSelect;
    final selected = multi && selection.selectedIds.contains(entry.id);

    // Dragging stays armed in BOTH modes (iOS "jiggle mode"): during
    // multi-select a long-press drag still moves tiles; a deliberate drag
    // (real finger travel) cancels the selection instead of selecting.
    return Dismissible(
      key: ValueKey(entry.id),
      // No swipe-delete while selecting — taps toggle checkmarks instead.
      direction: multi ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Yc.radiusRow),
          color: Yc.danger.withValues(alpha: 0.25),
        ),
        child: const Icon(Icons.delete_rounded, color: Yc.danger),
      ),
      confirmDismiss: (_) async {
        final ok = await confirmGlassDialog(
          context,
          title: 'Delete ${entry.name}?',
          body: 'You can undo for a few seconds after.',
        );
        return ok;
      },
      onDismissed: (_) async {
        await ref.read(diaryRepoProvider).delete(entry.id);
        if (context.mounted) DiaryUndo.deleted(context, ref, entry);
      },
      child: LongPressDraggable<LogEntry>(
        data: entry,
        hapticFeedbackOnStart: true,
        onDragStarted: () => _dragTravel = 0,
        onDragUpdate: (details) => _dragTravel += details.delta.distance,
        onDragEnd: (details) {
          // Lifted without really moving → this was a "hold" → select.
          // Deliberate drag → pure move; cancel any selection.
          // NOTE: onDraggableCanceled fires first (missed drops) — travel
          // must survive it so a missed drag still reads as a drag.
          final sel = ref.read(diarySelectionProvider.notifier);
          if (_dragTravel <= _selectMaxTravel) {
            sel.toggleAndEnter(entry.id);
          } else {
            sel.exitIfMultiSelect();
          }
          _dragTravel = 0;
        },
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Yc.radiusRow),
                color: Yc.chipBg,
                border: Border.all(color: Yc.accent.withValues(alpha: 0.5)),
              ),
              child: Text(
                '${entry.name} · ${entry.amountLabel}',
                style: const TextStyle(
                  fontSize: AppText.footnote,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: _tileBody(selected: selected),
        ),
        child: _PressableTile(
          onTap: () {
            if (multi) {
              ref.read(diarySelectionProvider.notifier).toggle(entry.id);
            } else {
              openLogEntryDetail(context, ref, entry);
            }
          },
          child: _tileBody(selected: selected),
        ),
      ),
    );
  }

  Widget _tileBody({required bool selected}) {
    final multi = ref.watch(diarySelectionProvider).isMultiSelect;
    return Padding(
      // Vertical breathing room sits OUTSIDE the highlight so the tint
      // never hugs the row's top/bottom edges (Apple list-row pattern).
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        // Horizontal inset ONLY in multi-select (selection tint inset);
        // normal mode stays flush so icon/kcal hug the section edges.
        padding: EdgeInsets.symmetric(horizontal: multi ? 10 : 0, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Yc.radiusRow),
          color: selected
              ? Yc.accent.withValues(alpha: 0.10)
              : Colors.transparent,
          border: selected
              ? Border.all(color: Yc.accent.withValues(alpha: 0.45))
              : null,
        ),
        child: Row(
          children: [
            // Apple edit-mode selection control: open circle → filled
            // accent circle with check. Slides in; content follows.
            _SelectionCircle(selected: selected, visible: multi),
            if (multi) const SizedBox(width: 10),
            if (entry.photoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(entry.photoPath!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _thumbFallback(),
                ),
              )
            else
              _thumbFallback(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // Serves-first when logged that way; grams in brackets.
                    entry.hasServings
                        ? '${entry.servesLabel} ${entry.gramsLabel} · ${entry.source.label}'
                        : '${entry.grams.round()} ${entry.unit == 'ml' ? 'ml' : 'g'}'
                              ' · ${entry.source.label}',
                    style: const TextStyle(
                      fontSize: AppText.footnote,
                      color: Yc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Value + unit as one baseline-aligned rich text (no drift).
            Text.rich(
              TextSpan(
                text: entry.nutr.kcal.kcalText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(
                    text: ' kcal',
                    style: TextStyle(
                      fontSize: AppText.caption,
                      color: Yc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbFallback() => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white.withValues(alpha: 0.07),
    ),
    child: Icon(
      _iconFor(widget.entry.source),
      size: 20,
      color: Yc.textTertiary,
    ),
  );

  IconData _iconFor(FoodSource s) => switch (s) {
    FoodSource.chain => Icons.storefront_rounded,
    FoodSource.off => Icons.local_drink_rounded,
    FoodSource.recipe => Icons.soup_kitchen_rounded,
    FoodSource.ai => Icons.auto_awesome_rounded,
    FoodSource.custom => Icons.edit_note_rounded,
    _ => Icons.eco_rounded,
  };
}

/// Adds an Apple-style tap-down highlight (subtle dim) to the tile.
class _PressableTile extends StatefulWidget {
  const _PressableTile({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressableTile> createState() => _PressableTileState();
}

class _PressableTileState extends State<_PressableTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 90),
        opacity: _pressed ? 0.6 : 1,
        child: widget.child,
      ),
    );
  }
}

/// Apple-style edit-mode selection control (checkmark.circle /
/// checkmark.circle.fill): 24pt open circle at rest, filled accent circle
/// with onAccent checkmark when selected. Fades/scales in when the list
/// enters edit mode.
class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.selected, required this.visible});

  final bool selected;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: !visible
            ? const SizedBox.shrink(key: ValueKey('sel-hidden'))
            : Container(
                key: ValueKey(selected ? 'sel-on' : 'sel-off'),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? Yc.accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? Yc.accent : Yc.textTertiary,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Yc.onAccent,
                      )
                    : null,
              ),
      ),
    );
  }
}

// ─── Multi-select action tray ────────────────────────────────────────────────

class _DiaryActionTray extends ConsumerWidget {
  const _DiaryActionTray({required this.entries, required this.selection});

  final List<LogEntry> entries;
  final DiarySelectionState selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = selection.isMultiSelect;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => SizeTransition(
        sizeFactor: anim,
        alignment: Alignment.bottomCenter,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: !visible
          ? const SizedBox.shrink(key: ValueKey('tray-hidden'))
          : _multiSelectTray(context, ref, entries),
    );
  }

  Widget _multiSelectTray(
    BuildContext context,
    WidgetRef ref,
    List<LogEntry> entries,
  ) {
    final sel = ref.read(diarySelectionProvider.notifier);
    final repo = ref.read(diaryRepoProvider);
    final selected = entries
        .where((e) => selection.selectedIds.contains(e.id))
        .toList();
    final n = selected.length;

    return _TrayShell(
      key: const ValueKey('tray-multiselect'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  n == 0
                      ? 'Select items'
                      : n == 1
                      ? '1 Selected'
                      : '$n Selected',
                  style: const TextStyle(
                    fontSize: AppText.subheadline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(44, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => sel.selectAll(entries.map((e) => e.id)),
                child: const Text(
                  'All',
                  style: TextStyle(
                    fontSize: AppText.subheadline,
                    fontWeight: FontWeight.w600,
                    color: Yc.accent,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(44, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: sel.exit,
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: AppText.subheadline,
                    fontWeight: FontWeight.w600,
                    color: Yc.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TrayAction(
                  icon: Icons.copy_rounded,
                  label: n == 1 ? 'Copy to today' : 'Copy ($n) to today',
                  onTap: n == 0
                      ? null
                      : () async {
                          final copies = await repo.copyToDay(
                            selected,
                            todayKey(),
                          );
                          sel.exit();
                          if (!context.mounted) return;
                          final host = UndoBannerHostState.of(context);
                          host?.show(
                            UndoRequest(
                              text: '${copies.length} copied to today',
                              onUndo: () =>
                                  repo.deleteMany(copies.map((c) => c.id)),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrayAction(
                  icon: Icons.soup_kitchen_rounded,
                  label: 'Create recipe',
                  onTap: n == 0
                      ? null
                      : () {
                          final ingredients = selected
                              .map(
                                (e) => RecipeIngredient(
                                  foodId: e.foodId,
                                  name: e.name,
                                  brand: e.brand,
                                  grams: e.grams,
                                  per100: e.grams > 0
                                      ? e.nutr.forGrams(100 / e.grams)
                                      : e.nutr,
                                  qty: e.hasServings
                                      ? e.servingCount!
                                      : e.grams,
                                  unit: e.hasServings ? 'serving' : e.unit,
                                  source: e.source,
                                ),
                              )
                              .toList();
                          sel.exit();
                          openRecipeEditor(
                            context,
                            initialIngredients: ingredients,
                          );
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrayAction(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete ($n)',
                  danger: true,
                  onTap: n == 0
                      ? null
                      : () async {
                          await repo.deleteMany(selected.map((e) => e.id));
                          sel.exit();
                          if (!context.mounted) return;
                          final host = UndoBannerHostState.of(context);
                          host?.show(
                            UndoRequest(
                              text: '${selected.length} deleted',
                              onUndo: () =>
                                  Future.wait(selected.map(repo.restore)),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrayShell extends StatelessWidget {
  const _TrayShell({required super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: Yc.radiusMd,
      blur: 30,
      opacity: 0.16,
      border: true,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: child,
    );
  }
}

class _TrayAction extends StatelessWidget {
  const _TrayAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = danger ? Yc.danger : Yc.textPrimary;
    final disabledColor = Yc.textTertiary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.45,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Yc.radiusSm),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: enabled ? color : disabledColor),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppText.footnote,
                  fontWeight: FontWeight.w600,
                  color: enabled ? color : disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
