import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/activity.dart';
import '../../domain/profile.dart';
import '../../state/providers.dart';
import '../common/low_target_note.dart';

/// Edit body stats / activity / goal and re-run the TDEE calculation.
/// Opened from Settings → Daily targets → Recalculate.
class TdeePage extends ConsumerStatefulWidget {
  const TdeePage({super.key, required this.profile});

  final Profile profile;

  @override
  ConsumerState<TdeePage> createState() => _TdeePageState();
}

class _TdeePageState extends ConsumerState<TdeePage> {
  late Sex _sex = widget.profile.sex;
  late int _age = widget.profile.ageYears;
  late double _height = widget.profile.heightCm;
  late double _weight = widget.profile.weightKg;
  late ActivityLevel _activity = widget.profile.activity;
  late GoalType _goal = widget.profile.goal;
  late double _rate = widget.profile.weeklyRateKg;
  bool _saving = false;

  Profile get _draft => Profile(
    name: widget.profile.name,
    sex: _sex,
    ageYears: _age,
    heightCm: _height,
    weightKg: _weight,
    activity: _activity,
    goal: _goal,
    weeklyRateKg: _rate,
    // Preserve the user's macro split and any custom target override;
    // the preview shows the computed TDEE either way.
    customKcalTarget: widget.profile.customKcalTarget,
    proteinPct: widget.profile.proteinPct,
    carbsPct: widget.profile.carbsPct,
    fatPct: widget.profile.fatPct,
  );

  @override
  Widget build(BuildContext context) {
    final g = _draft.goals;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 16, 0),
                  child: Row(
                    children: [
                      const BackButton(),
                      Text(
                        'Recalculate TDEE',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      // Live preview
                      Glass(
                        radius: 20,
                        opacity: 0.09,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Yc.calories,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${g.tdee.round()} kcal TDEE',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  '${g.kcalTarget} target · BMR ${g.bmr.round()}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Yc.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            LowTargetNote(kcalTarget: g.kcalTarget),
                            if (widget.profile.customKcalTarget != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Custom target of ${widget.profile.customKcalTarget} kcal is active — it stays until you clear it in Settings.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Yc.textTertiary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              '≈ ${ActivityMath.assumedActivityKcal(bmr: g.bmr, activityFactor: _activity.factor).kcalText} kcal of daily movement is already in this target — log more exercise than that to earn extra.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Yc.textTertiary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      _label('Body stats'),
                      SegmentedButton<Sex>(
                        segments: const [
                          ButtonSegment(value: Sex.male, label: Text('Male')),
                          ButtonSegment(
                            value: Sex.female,
                            label: Text('Female'),
                          ),
                        ],
                        selected: {_sex},
                        onSelectionChanged: (s) =>
                            setState(() => _sex = s.first),
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedBackgroundColor: Yc.calories.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _numRow(
                        'Age',
                        '$_age',
                        (v) => setState(() => _age = int.tryParse(v) ?? _age),
                      ),
                      const SizedBox(height: 14),
                      _sliderRow(
                        'Height',
                        '${_height.round()} cm',
                        _height,
                        120,
                        220,
                        (v) => setState(() => _height = v),
                      ),
                      _sliderRow(
                        'Weight',
                        '${_weight.toStringAsFixed(0)} kg',
                        _weight,
                        35,
                        200,
                        (v) => setState(() => _weight = v),
                      ),

                      const SizedBox(height: 10),
                      _label('Activity level'),
                      ...ActivityLevel.values.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: LiquidCard(
                            radius: 20,
                            opacity: _activity == a ? 0.14 : 0.07,
                            tint: _activity == a ? Yc.calories : null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            onTap: () => setState(() => _activity = a),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('${a.label}  ·  ×${a.factor}'),
                                ),
                                if (_activity == a)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Yc.calories,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),
                      _label('Goal'),
                      SegmentedButton<GoalType>(
                        segments: const [
                          ButtonSegment(
                            value: GoalType.lose,
                            label: Text('Lose'),
                          ),
                          ButtonSegment(
                            value: GoalType.maintain,
                            label: Text('Maintain'),
                          ),
                          ButtonSegment(
                            value: GoalType.gain,
                            label: Text('Gain'),
                          ),
                        ],
                        selected: {_goal},
                        onSelectionChanged: (s) =>
                            setState(() => _goal = s.first),
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedBackgroundColor: Yc.calories.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      if (_goal != GoalType.maintain) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_goal == GoalType.lose ? 'Lose' : 'Gain'),
                            Text(
                              '${_rate.toStringAsFixed(2)} kg / week'
                              '  ·  ${(_rate * 7700 / 7).round()} kcal/day',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _rate,
                          min: 0.25,
                          max: 1.0,
                          divisions: 3,
                          activeColor: Yc.calories,
                          onChanged: (v) => setState(() => _rate = v),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Yc.calories,
                      foregroundColor: const Color(0xFF06251B),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _saving
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            setState(() => _saving = true);
                            await ref.read(profileRepoProvider).save(_draft);
                            // A changed weight becomes a weigh-in dated now
                            // so the graph and per-day targets agree with
                            // the recalculation (skipped when unchanged).
                            final weighIns = await ref.read(
                              weightEntriesProvider.future,
                            );
                            final latest = weighIns.isEmpty
                                ? null
                                : weighIns.reduce(
                                    (a, b) => a.createdAt.isAfter(b.createdAt)
                                        ? a
                                        : b,
                                  );
                            if (latest == null ||
                                (latest.weightKg - _weight).abs() > 0.049) {
                              await logWeight(ref, _weight);
                            }
                            nav.pop();
                          },
                    child: const Text(
                      'Save & recalculate',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Yc.textSecondary,
      ),
    ),
  );

  InputDecoration _input(String hint) => InputDecoration(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.06),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    hintText: hint,
  );

  Widget _numRow(String label, String initial, ValueChanged<String> onChanged) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: initial)
              ..selection = TextSelection.collapsed(offset: initial.length),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: _input(label),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _sliderRow(
    String label,
    String valueText,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(valueText)],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: Yc.calories,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
