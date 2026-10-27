import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import '../activity/activity_page.dart' show openActivityLog;
import '../barcode/barcode_scanner.dart' show openBarcodeScanner;
import '../photo/photo_flow.dart';
import '../library/library_page.dart' show openSearchSheet;

/// Raised action sheet: food search, barcode, image analysis, text
/// description, or activity logging. When [meal] is provided
/// (meal-section ＋), downstream food sheets pre-select that meal.
Future<void> showCaptureSheet(BuildContext context, {MealType? meal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => CaptureSheet(meal: meal),
  );
}

class CaptureSheet extends StatelessWidget {
  const CaptureSheet({super.key, this.meal});

  final MealType? meal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        border: true,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              meal == null
                  ? 'Log food'
                  : 'Add to ${meal!.label.toLowerCase()}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 18),
            _CaptureOption(
              icon: Icons.search_rounded,
              title: 'Search foods',
              subtitle: '75,000+ products · brands · menus · recipes',
              tint: Yc.carbs.withValues(alpha: 0.18),
              onTap: () {
                Navigator.pop(context);
                openSearchSheet(context, initialMeal: meal);
              },
            ),
            const SizedBox(height: 10),
            _CaptureOption(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scan barcode',
              subtitle: 'Exact product match from the pack',
              tint: Yc.success.withValues(alpha: 0.16),
              onTap: () {
                Navigator.pop(context);
                openBarcodeScanner(context, initialMeal: meal);
              },
            ),
            const SizedBox(height: 10),
            _CaptureOption(
              icon: Icons.image_search_rounded,
              title: 'Analyze image',
              subtitle: 'Take a photo or pick from library',
              tint: Yc.calories.withValues(alpha: 0.18),
              onTap: () {
                Navigator.pop(context);
                showImageSourceSheet(context, meal: meal);
              },
            ),
            const SizedBox(height: 10),
            _CaptureOption(
              icon: Icons.edit_note_rounded,
              title: 'Describe to AI',
              subtitle: 'No photo? Type your meal instead',
              tint: Yc.protein.withValues(alpha: 0.18),
              onTap: () {
                Navigator.pop(context);
                showDescribeSheet(context, meal: meal);
              },
            ),
            const SizedBox(height: 10),
            _CaptureOption(
              icon: Icons.fitness_center_rounded,
              title: 'Log activity',
              subtitle: 'Exercise earns extra calories today',
              tint: Yc.success.withValues(alpha: 0.18),
              onTap: () {
                Navigator.pop(context);
                openActivityLog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Second tray (identical style): choose camera vs gallery for [meal].
Future<void> showImageSourceSheet(BuildContext context, {MealType? meal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _ImageSourceSheet(meal: meal),
  );
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({this.meal});

  final MealType? meal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        border: true,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Analyze image',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 18),
            _CaptureOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take a photo',
              subtitle: 'AI detects items & estimates portions',
              tint: Yc.calories.withValues(alpha: 0.18),
              onTap: () => _pickImage(context, ImageSource.camera, meal),
            ),
            const SizedBox(height: 10),
            _CaptureOption(
              icon: Icons.photo_library_rounded,
              title: 'Photo from library',
              subtitle: 'Analyse an existing picture',
              tint: Yc.protein.withValues(alpha: 0.18),
              onTap: () => _pickImage(context, ImageSource.gallery, meal),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickImage(
    BuildContext context, ImageSource source, MealType? meal) async {
  // Capture the root navigator BEFORE popping the sheet — the sheet's
  // context dies during the photo-picker await (async gap).
  final nav = Navigator.of(context, rootNavigator: true);
  Navigator.pop(context);

  final picker = ImagePicker();
  XFile? file;
  try {
    file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
  } catch (_) {
    // Camera unavailable (e.g. simulator) — fall back to library.
    try {
      file = await picker.pickImage(source: ImageSource.gallery);
    } catch (_) {}
  }
  if (file != null) {
    nav.push(PhotoFlowRoute(file.path, initialMeal: meal));
  }
}

/// Identical-style sheet with a text field: the user types a meal
/// description ("Big Mac with tomato, medium fries, thickshake") and the
/// AI runs its normal ingredient breakdown on the text. Confirmation reuses
/// the exact photo-flow UI ([PhotoFlowScreen] with an empty image path).
Future<void> showDescribeSheet(BuildContext context, {MealType? meal}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _DescribeSheet(meal: meal),
  );
}

class _DescribeSheet extends ConsumerStatefulWidget {
  const _DescribeSheet({this.meal});

  final MealType? meal;

  @override
  ConsumerState<_DescribeSheet> createState() => _DescribeSheetState();
}

class _DescribeSheetState extends ConsumerState<_DescribeSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    // Capture the root navigator BEFORE popping — the sheet's context
    // dies during the analysis await (async gap).
    final nav = Navigator.of(context, rootNavigator: true);
    Navigator.pop(context);
    // Kicks off analysis (sets Analyzing synchronously); the pushed
    // screen observes the same controller and skips image startup for
    // the empty path.
    ref.read(photoFlowControllerProvider.notifier).analyzeText(text);
    nav.push(PhotoFlowRoute('', initialMeal: widget.meal));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        border: true,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe to AI',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No photo or library match? Type your meal — e.g. “Big Mac with tomato, medium fries, thickshake”.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Yc.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              minLines: 2,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Describe your meal…',
                hintStyle: const TextStyle(color: Yc.textTertiary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              onSubmitted: (_) => _submit(),
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
              onPressed: _ctrl.text.trim().isEmpty ? null : _submit,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Analyze with AI',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureOption extends StatelessWidget {
  const _CaptureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      radius: 22,
      opacity: 0.07,
      tint: tint,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: tint,
            ),
            child: Icon(icon, size: 21, color: Yc.textPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12.5, color: Yc.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Yc.textTertiary),
        ],
      ),
    );
  }
}
