import 'package:intl/intl.dart';

extension DateX on DateTime {
  String get dayKey => DateFormat('yyyy-MM-dd').format(this);

  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime? parseKey(String key) {
    try {
      return DateFormat('yyyy-MM-dd').parse(key);
    } catch (_) {
      return null;
    }
  }

  String get prettyDay {
    final now = DateX.today();
    if (dayKey == now.dayKey) return 'Today';
    final y = now.subtract(const Duration(days: 1));
    if (dayKey == y.dayKey) return 'Yesterday';
    final t = now.add(const Duration(days: 1));
    if (dayKey == t.dayKey) return 'Tomorrow';
    return DateFormat('EEE, d MMM').format(this);
  }
}

extension NumX on num {
  String get kcalText => NumberFormat.decimalPattern().format(round());
  String get gText => this >= 100
      ? round().toString()
      : (this % 1 == 0 ? toStringAsFixed(0) : toStringAsFixed(1));
}
