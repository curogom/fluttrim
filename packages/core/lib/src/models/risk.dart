/// User-facing risk level for cleanup targets.
enum Risk { low, medium, high }

/// JSON helpers for [Risk].
extension RiskJson on Risk {
  /// Serializes enum value as a stable lowercase string.
  String toJsonValue() => name;

  /// Parses [value] produced by [toJsonValue].
  static Risk fromJsonValue(String value) => Risk.values.byName(value);
}
