/// Attribution state for scan/plan targets.
enum AttributionStatus { none, attributed, unknown }

/// JSON helpers for [AttributionStatus].
extension AttributionStatusJson on AttributionStatus {
  /// Serializes enum value as a stable lowercase string.
  String toJsonValue() => name;

  /// Parses [value] produced by [toJsonValue].
  static AttributionStatus fromJsonValue(String value) =>
      AttributionStatus.values.byName(value);
}
