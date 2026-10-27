import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../domain/profile.dart';
import '../../state/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();

  String _name = '';
  Sex _sex = Sex.male;
  int _age = 28;
  double _height = 178;
  double _weight = 80;
  ActivityLevel _activity = ActivityLevel.light;
  GoalType _goal = GoalType.lose;
  double _rate = 0.5;
  int _page = 0;

  static const _pageCount = 4;

  Profile get _profile => Profile(
    name: _name,
    sex: _sex,
    ageYears: _age,
    heightCm: _height,
    weightKg: _weight,
    activity: _activity,
    goal: _goal,
    weeklyRateKg: _rate,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                // Progress dots
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pageCount, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 26 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: i == _page
                              ? Yc.calories
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      _welcome(),
                      _stats(),
                      _activityPage(),
                      _goalPage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _next() => _controller.nextPage(
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
  );

  Future<void> _finish() async {
    await ref.read(profileRepoProvider).save(_profile);
    // Seed the weight graph with the setup weight so history has an
    // anchor from day one (also keeps the profile in sync).
    await logWeight(ref, _weight);
  }

  Widget _shell({
    required String title,
    required String subtitle,
    required List<Widget> children,
    required VoidCallback onNext,
    String nextLabel = 'Continue',
  }) {
    final profile = _profile;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Yc.textSecondary,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
          if (_page == _pageCount - 1) ...[
            Glass(
              radius: 20,
              opacity: 0.09,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Yc.calories,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.goals.kcalTarget} kcal / day',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'P ${profile.goals.proteinG.round()}g · C ${profile.goals.carbsG.round()}g · F ${profile.goals.fatG.round()}g',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Yc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Yc.calories,
              foregroundColor: const Color(0xFF06251B),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              if (_page < _pageCount - 1) {
                _next();
              } else {
                _finish();
              }
            },
            child: Text(
              nextLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcome() => _shell(
    title: 'YourCals 🇦🇺',
    subtitle:
        'Hyper-fast calorie tracking on real Australian food data — '
        'home cooking, supermarkets and every takeaway chain.',
    nextLabel: "Let's go",
    children: [
      const SizedBox(height: 12),
      LiquidCard(
        radius: 22,
        opacity: 0.08,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _feature(
              Icons.camera_alt_rounded,
              'Snap your meal',
              'AI identifies items & portions in seconds',
            ),
            const SizedBox(height: 14),
            _feature(
              Icons.search_rounded,
              'Search anything',
              'FSANZ science data + OFF brands + AU menus',
            ),
            const SizedBox(height: 14),
            _feature(
              Icons.lock_rounded,
              'Private by design',
              'Everything stays on your device',
            ),
          ],
        ),
      ),
    ],
    onNext: _next,
  );

  static Widget _feature(IconData icon, String title, String sub) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Yc.calories.withValues(alpha: 0.13),
        ),
        child: Icon(icon, size: 19, color: Yc.calories),
      ),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              sub,
              style: const TextStyle(fontSize: 12.5, color: Yc.textSecondary),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _stats() => _shell(
    title: 'About you',
    subtitle: 'Used to calculate your energy needs (Mifflin-St Jeor).',
    children: [
      TextField(
        decoration: _input('Name (optional)'),
        onChanged: (v) => _name = v,
      ),
      const SizedBox(height: 14),
      SegmentedButton<Sex>(
        segments: const [
          ButtonSegment(value: Sex.male, label: Text('Male')),
          ButtonSegment(value: Sex.female, label: Text('Female')),
        ],
        selected: {_sex},
        onSelectionChanged: (s) => setState(() => _sex = s.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          selectedBackgroundColor: Yc.calories.withValues(alpha: 0.25),
        ),
      ),
      const SizedBox(height: 14),
      _numField(
        'Age',
        _age.round().toString(),
        (v) => _age = int.tryParse(v) ?? _age,
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
    ],
    onNext: _next,
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

  Widget _numField(
    String label,
    String initial,
    ValueChanged<String> onChanged,
  ) {
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

  Widget _activityPage() => _shell(
    title: 'How active are you?',
    subtitle: 'Be honest — you can change this later in Settings.',
    children: ActivityLevel.values
        .map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LiquidCard(
              radius: 20,
              opacity: _activity == a ? 0.14 : 0.07,
              tint: _activity == a ? Yc.calories : null,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              onTap: () => setState(() => _activity = a),
              child: Row(
                children: [
                  Expanded(child: Text(a.label)),
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
        )
        .toList(),
    onNext: _next,
  );

  Widget _goalPage() {
    return _shell(
      title: 'What\'s the goal?',
      subtitle: _goal == GoalType.maintain
          ? 'We\'ll target your maintenance calories.'
          : 'Choose a sustainable pace.',
      children: [
        SegmentedButton<GoalType>(
          segments: const [
            ButtonSegment(value: GoalType.lose, label: Text('Lose')),
            ButtonSegment(value: GoalType.maintain, label: Text('Maintain')),
            ButtonSegment(value: GoalType.gain, label: Text('Gain')),
          ],
          selected: {_goal},
          onSelectionChanged: (s) => setState(() => _goal = s.first),
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            selectedBackgroundColor: Yc.calories.withValues(alpha: 0.25),
          ),
        ),
        if (_goal != GoalType.maintain)
          Column(
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_goal == GoalType.lose ? 'Lose' : 'Gain'),
                  Text(
                    '${_rate.toStringAsFixed(2)} kg / week',
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '0.5 kg/week is the sweet spot for keeping muscle.',
                  style: TextStyle(fontSize: 12.5, color: Yc.textTertiary),
                ),
              ),
            ],
          ),
      ],
      nextLabel: 'Start tracking',
      onNext: _finish,
    );
  }
}
