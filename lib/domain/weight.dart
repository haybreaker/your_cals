/// A single manual weigh-in for the Goals weight graph.
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.createdAt,
  });

  final String id;
  final double weightKg;
  final DateTime createdAt;
}
