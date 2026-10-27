import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../data/ai/gemini_client.dart' show GeminiClient;
import '../../domain/profile.dart';
import '../../state/providers.dart';
import '../common/low_target_note.dart';
import 'tdee_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;

    // Pushed from the diary header (not a dock tab) — carries its own
    // backdrop so the diary doesn't show through while scrolling.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              children: [
                Row(
                  children: [
                    const BackButton(color: Yc.textPrimary),
                    Flexible(
                      child: Text(
                        'Settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (profile != null) _GoalsCard(profile: profile),
                const SizedBox(height: 12),

                const _GeminiCard(),
                const SizedBox(height: 12),

                _AboutCard(),
                const SizedBox(height: 12),

                const _OffCatalogUpdateCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Goals editor ───────────────────────────────────────────────────────────

class _GoalsCard extends ConsumerStatefulWidget {
  const _GoalsCard({required this.profile});

  final Profile profile;

  @override
  ConsumerState<_GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends ConsumerState<_GoalsCard> {
  late int? _custom = widget.profile.customKcalTarget;
  late double _proteinPct = widget.profile.proteinPct;
  late double _carbPct = widget.profile.carbsPct;
  late double _fatPct = widget.profile.fatPct;

  static const _minPct = 0.05;
  static const _maxPct = 0.70;

  @override
  void initState() {
    super.initState();
    _repairSplit();
  }

  /// One-time repair: rescale a stored split that doesn't sum to 100%
  /// (possible before auto-balancing existed) back to a valid split.
  /// Persists on the next Save — never auto-saves.
  void _repairSplit() {
    var vals = [_proteinPct, _carbPct, _fatPct];
    final sum = vals[0] + vals[1] + vals[2];
    if ((sum - 1.0).abs() < 0.001) return;
    if (sum > 0) vals = [for (final v in vals) v / sum];
    for (var i = 0; i < 3; i++) {
      vals[i] = vals[i].clamp(_minPct, _maxPct);
    }
    // Push any residual onto the largest slider (bounded loop).
    for (var k = 0; k < 4; k++) {
      final residual = 1.0 - (vals[0] + vals[1] + vals[2]);
      if (residual.abs() < 0.001) break;
      var idx = 0;
      for (var i = 1; i < 3; i++) {
        if (vals[i] > vals[idx]) idx = i;
      }
      final room = residual > 0 ? _maxPct - vals[idx] : vals[idx] - _minPct;
      if (room <= 0) break;
      vals[idx] += residual.clamp(-room, room);
    }
    _proteinPct = vals[0];
    _carbPct = vals[1];
    _fatPct = vals[2];
  }

  /// Auto-balancing sliders: the split always sums to exactly 100%, so
  /// impossible states (like 41/40/30) can't exist. Dragging one macro
  /// takes from — or gives to — the other two proportionally to their
  /// current shares. Calories never move (sliders only split the fixed
  /// kcal target), so the TDEE link can't break.
  void _rebalance(int dragged, double v) {
    v = v.clamp(_minPct, _maxPct);
    final cur = [_proteinPct, _carbPct, _fatPct];
    final a = (dragged + 1) % 3;
    final b = (dragged + 2) % 3;
    final total = cur[a] + cur[b];
    var ta = total > 0 ? (1.0 - v) * cur[a] / total : (1.0 - v) / 2;
    ta = ta.clamp(_minPct, _maxPct);
    // Closed form: b takes exactly the remainder. Always feasible —
    // v ∈ [5,70]% leaves the pair within [10,140]% of capacity.
    final tb = (1.0 - v - ta).clamp(_minPct, _maxPct);
    ta = 1.0 - v - tb;
    cur[dragged] = v;
    cur[a] = ta;
    cur[b] = tb;
    setState(() {
      _proteinPct = cur[0];
      _carbPct = cur[1];
      _fatPct = cur[2];
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Profile(
      name: widget.profile.name,
      sex: widget.profile.sex,
      ageYears: widget.profile.ageYears,
      heightCm: widget.profile.heightCm,
      weightKg: widget.profile.weightKg,
      activity: widget.profile.activity,
      goal: widget.profile.goal,
      weeklyRateKg: widget.profile.weeklyRateKg,
      customKcalTarget: _custom,
      proteinPct: _proteinPct,
      carbsPct: _carbPct,
      fatPct: _fatPct,
    );
    final g = p.goals;

    return Glass(
      radius: YcRadii.md,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Daily targets',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
              ),
              const Spacer(),
              Text(
                'TDEE ${g.tdee.round()} kcal',
                style: const TextStyle(fontSize: 12, color: Yc.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                foregroundColor: Yc.calories,
              ),
              onPressed: () => Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, _, _) => TdeePage(profile: widget.profile),
                  transitionsBuilder: (_, anim, _, child) => SlideTransition(
                    position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                        .animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                ),
              ),
              icon: const Icon(Icons.local_fire_department_rounded, size: 17),
              label: const Text(
                'Recalculate TDEE (weight, activity…)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${g.kcalTarget}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'kcal target',
                  style: TextStyle(color: Yc.textSecondary),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Yc.textPrimary,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                onPressed: () async {
                  final ctrl = TextEditingController(
                    text: _custom?.toString() ?? '',
                  );
                  final result = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Yc.bgElevated,
                      title: const Text('Custom calorie target'),
                      content: TextField(
                        controller: ctrl,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 2200',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, ''),
                          child: const Text('Auto (from TDEE)'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Yc.calories,
                          ),
                          onPressed: () => Navigator.pop(ctx, ctrl.text),
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                  );
                  if (!mounted) return;
                  setState(() {
                    if (result == null) return;
                    _custom = result.trim().isEmpty
                        ? null
                        : int.tryParse(result.trim());
                  });
                },
                child: const Text('Edit'),
              ),
            ],
          ),
          LowTargetNote(kcalTarget: g.kcalTarget),
          const Divider(height: 26, color: Color(0x1AFFFFFF)),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Split of ${g.kcalTarget} kcal — dragging one macro adjusts the others.',
              style: const TextStyle(
                fontSize: 12,
                color: Yc.textTertiary,
                height: 1.4,
              ),
            ),
          ),
          _MacroSlider(
            label: 'Protein',
            color: Yc.protein,
            value: _proteinPct,
            grams: g.proteinG,
            onChanged: (v) => _rebalance(0, v),
          ),
          _MacroSlider(
            label: 'Carbs',
            color: Yc.carbs,
            value: _carbPct,
            grams: g.carbsG,
            onChanged: (v) => _rebalance(1, v),
          ),
          _MacroSlider(
            label: 'Fat',
            color: Yc.fat,
            value: _fatPct,
            grams: g.fatG,
            onChanged: (v) => _rebalance(2, v),
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.09),
                foregroundColor: Yc.textPrimary,
              ),
              onPressed: () => ref
                  .read(profileRepoProvider)
                  .save(
                    Profile(
                      name: p.name,
                      sex: p.sex,
                      ageYears: p.ageYears,
                      heightCm: p.heightCm,
                      weightKg: p.weightKg,
                      activity: p.activity,
                      goal: p.goal,
                      weeklyRateKg: p.weeklyRateKg,
                      customKcalTarget: _custom,
                      proteinPct: _proteinPct,
                      carbsPct: _carbPct,
                      fatPct: _fatPct,
                    ),
                  ),
              child: const Text('Save targets'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroSlider extends StatelessWidget {
  const _MacroSlider({
    required this.label,
    required this.color,
    required this.value,
    required this.grams,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final double value;
  final double grams;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: Yc.textSecondary),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 3),
            child: Slider(
              value: value.clamp(0.05, 0.7),
              min: 0.05,
              max: 0.7,
              activeColor: color,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 62,
          child: Text(
            '${grams.round()} g · ${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ─── Gemini key ─────────────────────────────────────────────────────────────

class _GeminiCard extends ConsumerWidget {
  const _GeminiCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyState = ref.watch(geminiKeyProvider);

    return Glass(
      radius: YcRadii.md,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 19,
                color: Yc.protein,
              ),
              const SizedBox(width: 8),
              const Text(
                'Gemini API key',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
              ),
              const Spacer(),
              if (keyState.loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Yc.textTertiary,
                  ),
                )
              else
                Icon(
                  keyState.hasKey
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color: keyState.hasKey ? Yc.success : Yc.danger,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            keyState.loading
                ? 'Checking for saved key…'
                : keyState.hasKey
                ? 'Connected — photo & describe logging active.'
                : 'Required for photo scanning. Get a free key at aistudio.google.com/apikey — it stays on this device.',
            style: const TextStyle(
              fontSize: 13,
              color: Yc.textSecondary,
              height: 1.35,
            ),
          ),
          if (keyState.loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Color(0x14FFFFFF),
              valueColor: AlwaysStoppedAnimation(Yc.textTertiary),
            ),
          ] else if (!keyState.hasKey) ...[
            const SizedBox(height: 12),
            _KeyInput(
              onSaved: (k) => ref.read(geminiKeyProvider.notifier).save(k),
            ),
          ] else ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ref.read(geminiKeyProvider.notifier).clear(),
                child: const Text(
                  'Remove key',
                  style: TextStyle(color: Yc.danger),
                ),
              ),
            ),
            const _ModelPicker(),
          ],
        ],
      ),
    );
  }
}

/// AI model preference: Auto (newest flash) or a concrete model fetched live
/// from Google's models endpoint — new releases appear without app updates.
class _ModelPicker extends ConsumerWidget {
  const _ModelPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(geminiModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 26, color: Color(0x1AFFFFFF)),
        Row(
          children: [
            const Icon(
              Icons.psychology_alt_rounded,
              size: 16,
              color: Yc.textSecondary,
            ),
            const SizedBox(width: 8),
            const Text(
              'AI model',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            ),
            const Spacer(),
            if (model.loadingModels)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Yc.calories,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: Yc.bgElevated,
              value:
                  model.available.contains(model.preference) ||
                      model.preference == GeminiClient.autoModel
                  ? model.preference
                  : GeminiClient.autoModel,
              items: [
                const DropdownMenuItem(
                  value: GeminiClient.autoModel,
                  child: Text(
                    'Auto · newest flash model',
                    style: TextStyle(fontSize: 13.5),
                  ),
                ),
                ...model.available.map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(m, style: const TextStyle(fontSize: 13.5)),
                  ),
                ),
              ],
              onChanged: (v) => ref
                  .read(geminiModelProvider.notifier)
                  .setPreference(v ?? GeminiClient.autoModel),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                model.error ??
                    (model.available.isEmpty
                        ? 'Auto picks the newest flash model available to your key.'
                        : 'Listed live from Google — refresh to see new releases.'),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Yc.textTertiary,
                  height: 1.3,
                ),
              ),
            ),
            TextButton(
              onPressed: model.loadingModels
                  ? null
                  : () =>
                        ref.read(geminiModelProvider.notifier).refreshModels(),
              child: const Text(
                'Refresh',
                style: TextStyle(fontSize: 12.5, color: Yc.calories),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyInput extends StatefulWidget {
  const _KeyInput({required this.onSaved});

  final void Function(String) onSaved;

  @override
  State<_KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<_KeyInput> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            obscureText: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              hintText: 'AIza…',
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Yc.protein,
            foregroundColor: const Color(0xFF10122B),
          ),
          onPressed: () {
            if (_ctrl.text.trim().isNotEmpty) {
              widget.onSaved(_ctrl.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _AboutCard extends ConsumerWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(catalogStatsProvider);
    final total = stats.value?.total;
    final off = stats.value?.bySource['off'];

    return Glass(
      radius: YcRadii.md,
      opacity: 0.06,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Food data',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
          ),
          const SizedBox(height: 10),
          _bullet(
            'Open Food Facts AU/NZ catalog — ${off == null ? '…' : off.toString()} products',
          ),
          _bullet('FSANZ Australian Food Composition Database R3'),
          _bullet('AUSNUT 2023 survey foods & measures'),
          _bullet('FSANZ Nutrition Panel Calculator dataset'),
          _bullet('Curated AU takeaway menu pack'),
          _bullet('Live OFF lookups & barcode scan, cached on device'),
          const SizedBox(height: 6),
          Text(
            total == null
                ? 'Counting local catalog…'
                : '${NumberFormat.decimalPattern().format(total)} foods on this device',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Yc.calories,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All processing local-first. No accounts, no tracking.',
            style: TextStyle(
              fontSize: 11.5,
              color: Yc.textTertiary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Row(
      children: [
        Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.only(right: 10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Yc.calories,
          ),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    ),
  );
}

// ─── OFF catalog update ─────────────────────────────────────────────────────

class _OffCatalogUpdateCard extends ConsumerWidget {
  const _OffCatalogUpdateCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offCatalogUpdateProvider);
    final nf = NumberFormat.decimalPattern();

    return Glass(
      radius: YcRadii.md,
      opacity: 0.08,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_download_rounded,
                size: 19,
                color: Yc.calories,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Food catalog',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                ),
              ),
              if (state.running)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Yc.calories,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            state.lastUpdate == null
                ? 'Catalog last updated: unknown'
                : 'Last updated: ${DateFormat.yMMMd().add_jm().format(state.lastUpdate!)}',
            style: const TextStyle(fontSize: 13, color: Yc.textSecondary),
          ),
          if (state.running && state.total > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: state.done / state.total,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation(Yc.calories),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${nf.format(state.done)} / ${nf.format(state.total)} products',
              style: const TextStyle(fontSize: 11.5, color: Yc.textTertiary),
            ),
          ],
          if (!state.running &&
              state.inserted != null &&
              state.updatedCount != null) ...[
            const SizedBox(height: 8),
            Text(
              state.fetched != null
                  ? 'Checked ${nf.format(state.fetched)} · '
                        '${nf.format(state.inserted)} new · '
                        '${nf.format(state.updatedCount)} changed'
                        '${(state.unchanged ?? 0) > 0 && (state.inserted ?? 0) == 0 && (state.updatedCount ?? 0) == 0 ? ' · up to date' : ''}'
                  : '${nf.format(state.inserted)} new · ${nf.format(state.updatedCount)} updated',
              style: const TextStyle(fontSize: 12.5, color: Yc.calories),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(fontSize: 12, color: Yc.danger),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.09),
                foregroundColor: Yc.textPrimary,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
                disabledForegroundColor: Yc.textTertiary,
              ),
              onPressed: state.running
                  ? null
                  : () =>
                        ref.read(offCatalogUpdateProvider.notifier).runUpdate(),
              child: Text(state.running ? 'Updating…' : 'Update now'),
            ),
          ),
        ],
      ),
    );
  }
}
