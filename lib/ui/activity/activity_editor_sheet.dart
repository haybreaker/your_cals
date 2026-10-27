import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/activity.dart';
import '../../state/providers.dart';
import '../common/undo_banner.dart' hide DiaryUndo;

const _uuid = Uuid();

/// Log / edit sheet for one activity bout. Minutes drive a live MET
/// estimate; the optional override takes a watch number instead.
Future<void> openActivityEditor(
  BuildContext context,
  Activity activity, {
  ExerciseEntry? entry,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _ActivityEditorSheet(activity: activity, entry: entry),
  );
}

class _ActivityEditorSheet extends ConsumerStatefulWidget {
  const _ActivityEditorSheet({required this.activity, this.entry});

  final Activity activity;
  final ExerciseEntry? entry;

  @override
  ConsumerState<_ActivityEditorSheet> createState() =>
      _ActivityEditorSheetState();
}

class _ActivityEditorSheetState extends ConsumerState<_ActivityEditorSheet> {
  late double _minutes;
  late final TextEditingController _minCtrl;
  late final TextEditingController _overrideCtrl;
  late bool _isFavorite;
  bool _favPending = false;

  static const _quickMinutes = [15.0, 30.0, 45.0, 60.0, 90.0, 120.0, 180.0];

  @override
  void initState() {
    super.initState();
    _minutes = widget.entry?.minutes ?? 30;
    if (_minutes <= 0) _minutes = 30;
    _minCtrl = TextEditingController(text: formatQty(_minutes));
    final manual = widget.entry?.manualKcal;
    _overrideCtrl = TextEditingController(
        text: manual == null ? '' : formatQty(manual));
    _isFavorite = widget.activity.isFavorite;
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _overrideCtrl.dispose();
    super.dispose();
  }

  void _syncMinText() {
    final text = formatQty(_minutes);
    if (_minCtrl.text != text) {
      _minCtrl.text = text;
      _minCtrl.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  double? get _override {
    final t = _overrideCtrl.text.trim();
    if (t.isEmpty) return null;
    final v = parseQty(t);
    return (v == null || v <= 0) ? null : v;
  }

  double _estimate(double weightKg, int ageYears) =>
      ActivityMath.burnKcal(
        met: widget.activity.met,
        metOlderAdult: widget.activity.metOlderAdult,
        weightKg: weightKg,
        minutes: _minutes,
        ageYears: ageYears,
      );

  Future<void> _toggleFavorite() async {
    if (_favPending) return;
    final next = !_isFavorite;
    setState(() {
      _favPending = true;
      _isFavorite = next;
    });
    try {
      await ref
          .read(activityRepoProvider)
          .setFavorite(widget.activity.id, next);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !next);
    } finally {
      if (mounted) {
        setState(() => _favPending = false);
      } else {
        _favPending = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final weightKg = profile?.weightKg ?? 70;
    final ageYears = profile?.ageYears ?? 30;
    final estimate = _estimate(weightKg, ageYears);
    final override = _override;
    final effective = override ?? estimate;
    final isEdit = widget.entry != null;
    final a = widget.activity;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(a.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: _favPending ? null : _toggleFavorite,
                  icon: Icon(
                    _isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color:
                        _isFavorite ? Yc.carbs : Yc.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: Yc.success.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    '${_trimMet(a.met)} MET · ${a.intensity}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Yc.success,
                    ),
                  ),
                ),
                if (ageYears >= olderAdultAge) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Text('60+ adjusted',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Yc.textTertiary)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Yc.calories.withValues(alpha: 0.10),
                border: Border.all(
                    color: Yc.calories.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  Text(effective.kcalText,
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w800)),
                  Text(
                    override != null
                        ? 'kcal (watch override)'
                        : 'kcal estimated · ${formatQty(_minutes)} min',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Yc.calories.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _minutes <= 0
                      ? null
                      : () => setState(() {
                            _minutes =
                                (_minutes - 5).clamp(0, 1440).toDouble();
                            _syncMinText();
                          }),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                SizedBox(
                  width: 84,
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor:
                          Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 6),
                      suffixText: 'min',
                      suffixStyle: const TextStyle(
                          fontSize: 11, color: Yc.textTertiary),
                    ),
                    onChanged: (v) {
                      final parsed = parseQty(v);
                      if (parsed != null) {
                        setState(() => _minutes = parsed);
                      }
                    },
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() {
                    _minutes =
                        (_minutes + 5).clamp(0, 1440).toDouble();
                    _syncMinText();
                  }),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '≈ ${ActivityMath.burnKcal(met: a.met, metOlderAdult: a.metOlderAdult, weightKg: weightKg, minutes: 60, ageYears: ageYears).kcalText} kcal/h',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Yc.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickMinutes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final m = _quickMinutes[i];
                  return ActionChip(
                    label: Text('${formatQty(m)} min',
                        style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.06),
                    side: BorderSide(
                        color:
                            Colors.white.withValues(alpha: 0.12)),
                    onPressed: () => setState(() {
                      _minutes = m;
                      _syncMinText();
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _overrideCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Watch says…? Override kcal (optional)',
                hintStyle:
                    const TextStyle(color: Yc.textTertiary),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _overrideCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Yc.textSecondary),
                        onPressed: () => setState(
                            () => _overrideCtrl.clear()),
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yc.calories,
                foregroundColor: const Color(0xFF06251B),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _minutes <= 0
                  ? null
                  : () async {
                      final repo = ref.read(exerciseRepoProvider);
                      final nav = Navigator.of(context);
                      if (isEdit) {
                        final e = widget.entry!;
                        await repo.updateMinutes(e, _minutes);
                        await repo.setOverride(e, _override);
                        nav.pop();
                        return;
                      }
                      final date = ref.read(selectedDateProvider);
                      final dayKey =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                      final entry = await repo.add(
                        day: dayKey,
                        activity: a,
                        minutes: _minutes,
                        weightKg: weightKg,
                        ageYears: ageYears,
                        manualKcal: _override,
                      );
                      if (!context.mounted) return;
                      final host =
                          UndoBannerHostState.of(context);
                      host?.show(UndoRequest(
                        text:
                            '${entry.name} · ${entry.effectiveKcal.round()} kcal burned',
                        onUndo: () => ref
                            .read(exerciseRepoProvider)
                            .delete(entry.id),
                      ));
                      nav.pop();
                    },
              icon: const Icon(Icons.check_rounded),
              label: Text(
                isEdit
                    ? 'Update · ${effective.kcalText} kcal'
                    : 'Log · ${effective.kcalText} kcal',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _trimMet(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

/// Manual entry for routines missing from the catalog (physio, Wii Fit
/// variants, …): name plus a MET value or an hourly burn rate.
Future<void> openCustomActivity(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => const _CustomActivitySheet(),
  );
}

class _CustomActivitySheet extends ConsumerStatefulWidget {
  const _CustomActivitySheet();

  @override
  ConsumerState<_CustomActivitySheet> createState() =>
      _CustomActivitySheetState();
}

class _CustomActivitySheetState extends ConsumerState<_CustomActivitySheet> {
  final _nameCtrl = TextEditingController();
  final _metCtrl = TextEditingController();
  final _kcalHrCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _metCtrl.dispose();
    _kcalHrCtrl.dispose();
    super.dispose();
  }

  double? get _met {
    // Explicit MET wins; otherwise derive from kcal/hr at a 70 kg
    // reference so estimates still scale with body weight.
    final m = parseQty(_metCtrl.text);
    if (m != null && m > 0) return m;
    final k = parseQty(_kcalHrCtrl.text);
    if (k != null && k > 0) return k / 70.0;
    return null;
  }

  bool get _valid => _nameCtrl.text.trim().isNotEmpty && _met != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add activity manually',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _field(_nameCtrl, 'Name (e.g. Physio routine)',
                textInputAction: TextInputAction.next),
            const SizedBox(height: 10),
            _field(_metCtrl, 'Effort (MET, e.g. 4.0)',
                numeric: true,
                textInputAction: TextInputAction.next),
            const SizedBox(height: 10),
            _field(_kcalHrCtrl, 'Or burn rate (kcal/hour, e.g. 280)',
                numeric: true,
                textInputAction: TextInputAction.done),
            if (_met != null) ...[
              const SizedBox(height: 8),
              Text('≈ ${_trimMet(_met!)} MET',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5, color: Yc.textSecondary)),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yc.calories,
                foregroundColor: const Color(0xFF06251B),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: !_valid
                  ? null
                  : () async {
                      final activity = Activity(
                        id: 'custom_${_uuid.v4()}',
                        name: _nameCtrl.text.trim(),
                        category: 'Custom',
                        met: _met!,
                        isCustom: true,
                      );
                      await ref
                          .read(activityRepoProvider)
                          .upsertActivity(activity);
                      if (!context.mounted) return;
                      final nav = Navigator.of(context);
                      nav.pop();
                      openActivityEditor(context, activity);
                    },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save activity',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint,
      {bool numeric = false, TextInputAction? textInputAction}) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      textInputAction: textInputAction,
      textCapitalization:
          numeric ? TextCapitalization.none : TextCapitalization.words,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Yc.textTertiary),
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  static String _trimMet(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}
