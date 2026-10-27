/// Shared quantity formatting/parsing: 2dp max, trailing zeros trimmed.
///
/// `1.50` → `1.5`, `2.00` → `2`, `0.125` → `0.13`. Used by the portion
/// editor, recipe ingredient cards, and AI confirmation inputs so decimal
/// serving counts (e.g. 1.5 serves) behave identically everywhere.
String formatQty(double v) {
  if (!v.isFinite) return '0';
  final clamped = v.clamp(0, 5000).toDouble();
  if (clamped == clamped.roundToDouble()) return clamped.round().toString();
  var s = clamped.toStringAsFixed(2);
  // Trim trailing zeros: "1.50" -> "1.5", "2.00" handled above.
  while (s.contains('.') && s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  return s;
}

/// Parses user-entered quantities, accepting both `.` and `,` decimals.
/// Returns null when unparseable or negative.
double? parseQty(String raw) {
  final parsed = double.tryParse(raw.trim().replaceAll(',', '.'));
  if (parsed == null || !parsed.isFinite || parsed < 0) return null;
  return parsed.clamp(0, 5000).toDouble();
}
