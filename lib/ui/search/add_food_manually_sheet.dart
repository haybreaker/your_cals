import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/ai/gemini_client.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import '../../data/services/nutritional_info_scanner.dart';
import 'search_sheet.dart' show openPortionEditor;

/// Full-height bottom sheet for manually adding a food item.
/// Includes OCR scan button in top-right corner for auto-filling from label photo.
///
/// - Create: default, saves a new `custom:` food.
/// - Edit (`existingFood`): rewrites that custom food in place (same id,
///   keeps favourite flag) — for fixing your own entries.
/// - Clone (`cloneSource`): pre-fills from an OFF/chain row but saves as a
///   NEW `custom:` food (keeping the barcode), so your correction shadows
///   the wrong catalog row in future search/barcode lookups instead of
///   being overwritten by the next catalog update.
/// - Pick mode (`openPortionEditorOnSave: false`): pops with the saved Food
///   instead of opening the portion editor (recipe ingredient picker).
Future<Food?> openManualFoodEntry(
  BuildContext context, {
  MealType? initialMeal,
  String? initialName,
  String? initialBrand,
  Food? existingFood,
  Food? cloneSource,
  String? initialBarcode,
  bool openPortionEditorOnSave = true,
}) {
  return Navigator.of(context, rootNavigator: true).push<Food>(
    PageRouteBuilder<Food>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => _ManualFoodEntryScreen(
        initialMeal: initialMeal,
        initialName: initialName,
        initialBrand: initialBrand,
        existingFood: existingFood,
        cloneSource: cloneSource,
        initialBarcode: initialBarcode,
        openPortionEditorOnSave: openPortionEditorOnSave,
      ),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

/// Convenience for the "Fix this product" flow: clone any catalog row
/// into a personal custom copy the user can correct.
Future<Food?> openFixProductSheet(
  BuildContext context,
  Food source, {
  MealType? initialMeal,
}) {
  return openManualFoodEntry(
    context,
    initialMeal: initialMeal,
    cloneSource: source,
  );
}

class _ManualFoodEntryScreen extends ConsumerStatefulWidget {
  const _ManualFoodEntryScreen({
    this.initialMeal,
    this.initialName,
    this.initialBrand,
    this.existingFood,
    this.cloneSource,
    this.initialBarcode,
    this.openPortionEditorOnSave = true,
  });

  final MealType? initialMeal;
  final String? initialName;
  final String? initialBrand;
  final Food? existingFood;
  final Food? cloneSource;
  final String? initialBarcode;

  /// Pick mode: pop with the saved Food instead of pushing the portion editor.
  final bool openPortionEditorOnSave;

  @override
  ConsumerState<_ManualFoodEntryScreen> createState() =>
      _ManualFoodEntryScreenState();
}

class _ManualFoodEntryScreenState
    extends ConsumerState<_ManualFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _servingSizeCtrl = TextEditingController(text: '100');
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _satFatCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _sugarsCtrl = TextEditingController();
  final _fibreCtrl = TextEditingController();
  final _sodiumCtrl = TextEditingController();

  // State
  String _servingUnit = 'g';
  bool _isLiquid = false;
  bool _scanning = false;
  bool _scanningAi = false;
  String? _lastLabelPath;

  /// The catalog row being corrected (clone flow). Null for create/edit.
  Food? get _cloneSource => widget.cloneSource;
  bool get _isEdit => widget.existingFood != null;
  bool get _isClone => widget.cloneSource != null;

  String get _saveLabel {
    if (_isEdit) return 'Save changes';
    if (_isClone) return 'Save my corrected copy';
    return 'Save & add to diary';
  }

  String get _title => _isEdit
      ? 'Edit custom food'
      : _isClone
      ? 'Fix product — save as my food'
      : 'Add custom food';

  @override
  void initState() {
    super.initState();
    final edit = widget.existingFood;
    final clone = widget.cloneSource;
    final src = edit ?? clone;
    if (src != null) {
      _nameCtrl.text = src.name;
      _brandCtrl.text = src.brand;
      _barcodeCtrl.text = src.barcode ?? widget.initialBarcode ?? '';
      _servingSizeCtrl.text = src.defaultGrams > 0
          ? (src.defaultGrams == src.defaultGrams.roundToDouble()
                ? src.defaultGrams.round().toString()
                : src.defaultGrams.toString())
          : '100';
      _servingUnit = src.liquid ? 'ml' : 'g';
      _isLiquid = src.liquid;
      final n = src.per100;
      if (n.kcal > 0) _kcalCtrl.text = n.kcal.toStringAsFixed(0);
      if (n.proteinG > 0) _proteinCtrl.text = n.proteinG.gText;
      if (n.fatG > 0) _fatCtrl.text = n.fatG.gText;
      if (n.satFatG > 0) _satFatCtrl.text = n.satFatG.gText;
      if (n.carbsG > 0) _carbsCtrl.text = n.carbsG.gText;
      if (n.sugarsG > 0) _sugarsCtrl.text = n.sugarsG.gText;
      if (n.fiberG > 0) _fibreCtrl.text = n.fiberG.gText;
      if (n.sodiumMg > 0) _sodiumCtrl.text = n.sodiumMg.round().toString();
    } else {
      if (widget.initialName != null) _nameCtrl.text = widget.initialName!;
      if (widget.initialBrand != null) _brandCtrl.text = widget.initialBrand!;
      if (widget.initialBarcode != null) {
        _barcodeCtrl.text = widget.initialBarcode!;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _barcodeCtrl.dispose();
    _servingSizeCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _satFatCtrl.dispose();
    _carbsCtrl.dispose();
    _sugarsCtrl.dispose();
    _fibreCtrl.dispose();
    _sodiumCtrl.dispose();
    super.dispose();
  }

  Future<XFile?> _pickLabelPhoto() async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        imageQuality: 90,
      );
      if (file != null) return file;
    } catch (_) {
      // Camera unavailable — fall through to gallery.
    }
    try {
      return await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _scanLabel() async {
    final file = await _pickLabelPhoto();

    if (file == null) return;

    setState(() {
      _scanning = true;
      _lastLabelPath = file.path;
    });

    NutritionalInfoResult best;
    try {
      // Single sequential OCR pass. The scanner ignores `strategy`
      // (kept for future image pre-processing), so the old
      // `Future.wait` of 3 identical passes was 3x cost on one shared
      // MLKit recognizer — a concurrency hazard for no benefit.
      final scanner = NutritionalInfoScanner();
      try {
        best = await scanner.scanFromImage(file.path);
      } finally {
        scanner.dispose();
      }

      if (!mounted) return;

      if (best.per100 == null || best.per100!.kcal <= 0) {
        setState(() => _scanning = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not read label on-device — try better lighting, or scan with AI.',
            ),
            backgroundColor: Yc.danger,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Try AI scan',
              textColor: Yc.calories,
              onPressed: () => _scanLabelWithAi(file.path),
            ),
          ),
        );
        return;
      }

      _applyOcrResult(best);

      if (mounted) {
        final n = best.per100!;
        final filled = [
          if (n.kcal > 0) 'Energy',
          if (n.proteinG > 0) 'Protein',
          if (n.fatG > 0) 'Fat',
          if (n.satFatG > 0) 'Sat fat',
          if (n.carbsG > 0) 'Carbs',
          if (n.sugarsG > 0) 'Sugars',
          if (n.fiberG > 0) 'Fibre',
          if (n.sodiumMg > 0) 'Sodium',
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              filled.isEmpty
                  ? 'Label scanned but no nutrition data found — fill manually'
                  : 'Auto-filled: ${filled.join(', ')}',
            ),
            backgroundColor: filled.isEmpty ? Yc.textTertiary : Yc.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _scanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e — fill manually'),
            backgroundColor: Yc.danger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _applyOcrResult(NutritionalInfoResult best) {
    setState(() {
      if (best.servingSize != null) {
        _servingSizeCtrl.text = best.servingSize!.toStringAsFixed(
          best.servingSize! == best.servingSize!.roundToDouble() ? 0 : 1,
        );
      }
      if (best.servingUnit != null) {
        _servingUnit = best.servingUnit!;
        _isLiquid = best.isLiquid ?? false;
      }
      if (best.per100 != null) {
        final n = best.per100!;
        if (n.kcal > 0) _kcalCtrl.text = n.kcal.toStringAsFixed(0);
        if (n.proteinG > 0) _proteinCtrl.text = n.proteinG.gText;
        if (n.fatG > 0) _fatCtrl.text = n.fatG.gText;
        if (n.satFatG > 0) _satFatCtrl.text = n.satFatG.gText;
        if (n.carbsG > 0) _carbsCtrl.text = n.carbsG.gText;
        if (n.sugarsG > 0) _sugarsCtrl.text = n.sugarsG.gText;
        if (n.fiberG > 0) _fibreCtrl.text = n.fiberG.gText;
        if (n.sodiumMg > 0) _sodiumCtrl.text = n.sodiumMg.round().toString();
      }
      if (best.barcode != null && best.barcode!.isNotEmpty) {
        _barcodeCtrl.text = best.barcode!;
      }
      _scanning = false;
    });
  }

  void _applyLabelNutrition(LabelNutrition label) {
    setState(() {
      if ((label.productName ?? '').isNotEmpty && _nameCtrl.text.trim().isEmpty) {
        _nameCtrl.text = label.productName!.trim();
      }
      if ((label.brand ?? '').isNotEmpty && _brandCtrl.text.trim().isEmpty) {
        _brandCtrl.text = label.brand!.trim();
      }
      if (label.barcode != null && label.barcode!.isNotEmpty) {
        _barcodeCtrl.text = label.barcode!;
      }
      if (label.servingSize != null && label.servingSize! > 0) {
        _servingSizeCtrl.text = label.servingSize! == label.servingSize!.roundToDouble()
            ? label.servingSize!.round().toString()
            : label.servingSize!.toStringAsFixed(1);
      }
      if (label.servingUnit != null) {
        _servingUnit = label.servingUnit!;
        _isLiquid = label.isLiquid ?? label.servingUnit == 'ml';
      } else if (label.isLiquid != null) {
        _isLiquid = label.isLiquid!;
        if (label.isLiquid! && _servingUnit == 'g') _servingUnit = 'ml';
      }
      final n = label.per100;
      if (n.kcal > 0) _kcalCtrl.text = n.kcal.toStringAsFixed(0);
      if (n.proteinG > 0) _proteinCtrl.text = n.proteinG.gText;
      if (n.fatG > 0) _fatCtrl.text = n.fatG.gText;
      if (n.satFatG > 0) _satFatCtrl.text = n.satFatG.gText;
      if (n.carbsG > 0) _carbsCtrl.text = n.carbsG.gText;
      if (n.sugarsG > 0) _sugarsCtrl.text = n.sugarsG.gText;
      if (n.fiberG > 0) _fibreCtrl.text = n.fiberG.gText;
      if (n.sodiumMg > 0) _sodiumCtrl.text = n.sodiumMg.round().toString();
      _scanningAi = false;
      _scanning = false;
    });
  }

  /// AI fallback for label photos the on-device OCR can't read
  /// (glare, angle, low light). Uses the saved Gemini key; no-ops with a
  /// message when the key is missing so manual entry still works offline.
  Future<void> _scanLabelWithAi(String imagePath) async {
    setState(() {
      _scanningAi = true;
      _scanning = true;
    });
    try {
      final apiKey = await ref.read(geminiKeyProvider.notifier).ensureKey();
      if (!mounted) return;
      if (apiKey == null) {
        setState(() {
          _scanningAi = false;
          _scanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add your Gemini API key in Settings for AI label scan.'),
            backgroundColor: Yc.danger,
          ),
        );
        return;
      }
      final bytes = await File(imagePath).readAsBytes();
      final mime = imagePath.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';
      final label = await ref
          .read(geminiClientProvider)
          .analyzeNutritionLabel(bytes: bytes, mimeType: mime, apiKey: apiKey);
      if (!mounted) return;
      _applyLabelNutrition(label);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI label scan complete — check the values.'),
          backgroundColor: Yc.success,
          duration: Duration(seconds: 3),
        ),
      );
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() {
        _scanningAi = false;
        _scanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Yc.danger),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _scanningAi = false;
        _scanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI scan failed — fill manually'),
          backgroundColor: Yc.danger,
        ),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final kcal = double.tryParse(_kcalCtrl.text) ?? 0;
    if (kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Energy (kcal) is required'),
          backgroundColor: Yc.danger,
        ),
      );
      return;
    }

    final servingSize = double.tryParse(_servingSizeCtrl.text) ?? 100;
    final barcode = _barcodeCtrl.text.trim();

    final per100 = Nutriments(
      kcal: kcal,
      proteinG: double.tryParse(_proteinCtrl.text) ?? 0,
      carbsG: double.tryParse(_carbsCtrl.text) ?? 0,
      fatG: double.tryParse(_fatCtrl.text) ?? 0,
      satFatG: double.tryParse(_satFatCtrl.text) ?? 0,
      sugarsG: double.tryParse(_sugarsCtrl.text) ?? 0,
      fiberG: double.tryParse(_fibreCtrl.text) ?? 0,
      sodiumMg: double.tryParse(_sodiumCtrl.text) ?? 0,
    );

    final Food food;
    if (_isEdit && widget.existingFood != null) {
      final prev = widget.existingFood!;
      food = Food(
        id: prev.id,
        name: name,
        brand: _brandCtrl.text.trim(),
        source: FoodSource.custom,
        per100: per100,
        defaultGrams: servingSize,
        servings: prev.servings,
        isFavorite: prev.isFavorite,
        barcode: barcode.isEmpty ? null : barcode,
        liquid: _isLiquid,
      );
    } else {
      food = Food(
        id: 'custom:${const Uuid().v4()}',
        name: name,
        brand: _brandCtrl.text.trim(),
        source: FoodSource.custom,
        per100: per100,
        defaultGrams: servingSize,
        servings: const [],
        isFavorite: false,
        barcode: barcode.isEmpty ? null : barcode,
        liquid: _isLiquid,
      );
    }

    // Save to database (custom ids never collide with OFF catalog rows,
    // so the next OFF refresh can't overwrite this correction).
    ref.read(foodRepoProvider).upsertFood(food);

    final nav = Navigator.of(context);
    if (!widget.openPortionEditorOnSave) {
      nav.pop(food);
      return;
    }
    // Close this screen and open portion editor
    nav.pop();
    openPortionEditor(context, food, initialMeal: widget.initialMeal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header with scan button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: Glass(
                    radius: 24,
                    opacity: 0.12,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded,
                              color: Yc.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (_lastLabelPath != null && !_scanningAi)
                          IconButton(
                            onPressed: _scanning
                                ? null
                                : () => _scanLabelWithAi(_lastLabelPath!),
                            icon: const Icon(Icons.auto_awesome_rounded,
                                color: Yc.protein),
                            tooltip: 'Retry label with AI',
                          ),
                        IconButton(
                          onPressed: (_scanning || _scanningAi)
                              ? null
                              : _scanLabel,
                          icon: (_scanning || _scanningAi)
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Yc.calories),
                                )
                              : const Icon(Icons.document_scanner_rounded,
                                  color: Yc.calories),
                          tooltip: 'Scan nutrition label',
                        ),
                      ],
                    ),
                  ),
                ),

                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ─── Name & Brand ─────────────────────────────
                          _SectionLabel('Food details'),
                          if (_isClone && _cloneSource != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Yc.calories.withValues(alpha: 0.10),
                                border: Border.all(
                                    color:
                                        Yc.calories.withValues(alpha: 0.30)),
                              ),
                              child: Text(
                                'Correcting "${_cloneSource!.displayName}" (${_cloneSource!.source.label}). Saves as your own food — future searches & barcode scans will prefer it over the catalog row.',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Yc.textSecondary,
                                    height: 1.35),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _nameCtrl,
                            label: 'Food name *',
                            hint: 'e.g. Chicken breast',
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _brandCtrl,
                            label: 'Brand (optional)',
                            hint: 'e.g. Coles, Woolworths',
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _barcodeCtrl,
                            label: 'Barcode (optional)',
                            hint: 'e.g. 9310632012345',
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 20),

                          // ─── Serving ──────────────────────────────────
                          _SectionLabel('Serving size'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _servingSizeCtrl,
                                  label: 'Size',
                                  hint: '100',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'g', label: Text('g')),
                                  ButtonSegment(value: 'ml', label: Text('ml')),
                                ],
                                selected: {_servingUnit},
                                onSelectionChanged: (s) =>
                                    setState(() => _servingUnit = s.first),
                                showSelectedIcon: false,
                                style: SegmentedButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.05),
                                  selectedBackgroundColor:
                                      Yc.calories.withValues(alpha: 0.25),
                                  side: BorderSide(
                                      color: Colors.white
                                          .withValues(alpha: 0.12)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Liquid',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Yc.textSecondary)),
                              Switch(
                                value: _isLiquid,
                                onChanged: (v) =>
                                    setState(() => _isLiquid = v),
                                activeThumbColor: Yc.calories,
                              ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ─── Nutrition per 100g ─────────────────────
                          _SectionLabel('Nutrition per 100g'),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _kcalCtrl,
                            label: 'Energy (kcal) *',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              final n = double.tryParse(v ?? '');
                              if (n == null || n <= 0) return 'Required';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _proteinCtrl,
                                  label: 'Protein (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _fatCtrl,
                                  label: 'Fat (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _satFatCtrl,
                                  label: 'Sat fat (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _carbsCtrl,
                                  label: 'Carbs (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _sugarsCtrl,
                                  label: 'Sugars (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  controller: _fibreCtrl,
                                  label: 'Fibre (g)',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _sodiumCtrl,
                            label: 'Sodium (mg)',
                            hint: '0',
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 24),

                          // ─── Save button ─────────────────────────────
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Yc.calories,
                              foregroundColor: const Color(0xFF06251B),
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _save,
                            icon: const Icon(Icons.check_rounded),
                            label: Text(_saveLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5)),
                          ),
                        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Yc.textTertiary, fontSize: 13),
        hintStyle: const TextStyle(color: Yc.textTertiary, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Yc.calories, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Yc.danger, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Yc.textTertiary,
          ),
        ),
      );
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Yc.bg,
            Yc.bg.withValues(alpha: 0.98),
          ],
        ),
      ),
    );
  }
}
