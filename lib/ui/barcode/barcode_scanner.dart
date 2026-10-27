import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import '../search/add_food_manually_sheet.dart' show openManualFoodEntry;
import '../search/search_sheet.dart' show openPortionEditor;

/// Live barcode scanner (device camera) with manual-entry fallback
/// (simulators have no camera). Found products flow into the portion editor.
///
/// Filter mode: pass [onScanned] to receive the raw barcode instead —
/// the caller (library quick-filter) does its own exact local lookup.
/// The screen pops immediately on first detection, no OFF fetch.
Future<void> openBarcodeScanner(
  BuildContext context, {
  MealType? initialMeal,
  void Function(String code)? onScanned,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, _, _) =>
          BarcodeScannerScreen(initialMeal: initialMeal, onScanned: onScanned),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(
            begin: 0.96,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    ),
  );
}

/// Opens the scanner in filter mode and returns the scanned (or typed)
/// barcode, or null when dismissed.
Future<String?> scanBarcodeForFilter(BuildContext context) async {
  String? code;
  await openBarcodeScanner(context, onScanned: (c) => code = c);
  return code;
}

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key, this.initialMeal, this.onScanned});

  final MealType? initialMeal;

  /// Filter mode: receive the raw code, skip lookup + portion editor.
  final void Function(String code)? onScanned;

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _cameraFailed = false;
  bool _lookingUp = false;
  String? _error;
  final _manualCtrl = TextEditingController();

  /// Filter mode fires once, then the screen is gone.
  bool _done = false;

  // Retry state
  String? _lastScannedBarcode;
  int _lookupAttempts = 0;
  static const _maxLookupAttempts = 3;
  Timer? _retryTimer;

  @override
  void dispose() {
    _controller?.dispose();
    _manualCtrl.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  /// Filter-mode handoff: pop first (the caller may push), then deliver.
  void _deliver(String code) {
    if (_done) return;
    _done = true;
    final cb = widget.onScanned;
    Navigator.of(context).pop();
    cb?.call(code);
  }

  Future<void> _lookup(String barcode) async {
    // Skip if same barcode already exhausted retries
    if (barcode == _lastScannedBarcode &&
        _lookupAttempts >= _maxLookupAttempts) {
      return;
    }

    // Skip if already looking up
    if (_lookingUp) return;

    // Reset attempts for new barcode
    if (barcode != _lastScannedBarcode) {
      _lastScannedBarcode = barcode;
      _lookupAttempts = 0;
    }

    _lookupAttempts++;
    setState(() {
      _lookingUp = true;
      _error = null; // Clear only during active lookup
    });

    try {
      final food = await ref.read(offClientProvider).fetchByBarcode(barcode);
      if (!mounted) return;

      if (food == null) {
        if (_lookupAttempts < _maxLookupAttempts) {
          // Schedule retry
          setState(() => _lookingUp = false);
          _retryTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) _lookup(barcode);
          });
          return;
        }

        // Final failure — show error + manual add button
        setState(() {
          _lookingUp = false;
          _error =
              'Barcode $barcode not found after $_lookupAttempts attempts.';
        });
        return;
      }

      // Success — cache locally and open portion editor
      await ref.read(foodRepoProvider).upsertFood(food);
      if (!mounted) return;
      final nav = Navigator.of(context);
      final meal = widget.initialMeal;
      nav.pop();
      if (!mounted) return;
      openPortionEditor(context, food, initialMeal: meal);
    } catch (_) {
      if (mounted) {
        if (_lookupAttempts < _maxLookupAttempts) {
          setState(() => _lookingUp = false);
          _retryTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) _lookup(barcode);
          });
          return;
        }

        setState(() {
          _lookingUp = false;
          _error = 'Lookup failed — check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (!_cameraFailed)
            MobileScanner(
              controller: _controller ??= MobileScannerController(),
              onDetect: (capture) {
                final code = capture.barcodes.firstOrNull?.rawValue;
                if (code == null || code.isEmpty) return;
                // Filter mode: hand the raw code back immediately.
                if (widget.onScanned != null) {
                  _deliver(code);
                  return;
                }
                if (code != _lastScannedBarcode) {
                  _lookup(code);
                }
              },
              errorBuilder: (context, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _cameraFailed = true);
                });
                return const SizedBox();
              },
            )
          else
            const _ManualEntryHint(),

          if (!_cameraFailed)
            const Positioned.fill(
              child: IgnorePointer(child: ColoredBox(color: Color(0x66000000))),
            ),

          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                if (!_cameraFailed)
                  Center(
                    child: Container(
                      width: 250,
                      height: 150,
                      margin: const EdgeInsets.only(top: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Yc.calories.withValues(alpha: 0.9),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                  child: Glass(
                    radius: 24,
                    opacity: 0.13,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_lookingUp)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Yc.calories,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _lastScannedBarcode != null
                                    ? 'Looking up product (attempt $_lookupAttempts/$_maxLookupAttempts)…'
                                    : 'Looking up product…',
                                style: const TextStyle(fontSize: 13.5),
                              ),
                            ],
                          )
                        else ...[
                          if (_error != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Yc.danger,
                                ),
                              ),
                            ),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  openManualFoodEntry(
                                    context,
                                    initialMeal: widget.initialMeal,
                                    // Carry the dead code through: saving
                                    // stores it so future scans resolve.
                                    initialBarcode: _lastScannedBarcode,
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_rounded,
                                  color: Yc.calories,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Create a custom food',
                                  style: TextStyle(
                                    color: Yc.calories,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_error == null)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: Text(
                                'Point camera at barcode',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Yc.textTertiary,
                                ),
                              ),
                            ),
                          TextField(
                            controller: _manualCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: _cameraFailed
                                  ? 'No camera — enter barcode digits'
                                  : 'Or type a barcode (e.g. 9310632012345)',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: Yc.textTertiary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.07),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Yc.calories,
                                ),
                                onPressed: () {
                                  final code = _manualCtrl.text.trim();
                                  if (code.isEmpty) return;
                                  if (widget.onScanned != null) {
                                    _deliver(code);
                                    return;
                                  }
                                  _lastScannedBarcode = null;
                                  _lookupAttempts = 0;
                                  _lookup(code);
                                },
                              ),
                            ),
                            onSubmitted: (v) {
                              final code = v.trim();
                              if (code.isEmpty) return;
                              if (widget.onScanned != null) {
                                _deliver(code);
                                return;
                              }
                              _lastScannedBarcode = null;
                              _lookupAttempts = 0;
                              _lookup(code);
                            },
                          ),
                        ],
                      ],
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
}

class _ManualEntryHint extends StatelessWidget {
  const _ManualEntryHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_rounded, size: 64, color: Yc.textTertiary),
          SizedBox(height: 14),
          Text(
            'Camera unavailable here.\nType the barcode below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Yc.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
