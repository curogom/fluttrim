/// Deletion strategy used during cleanup execution.
enum DeleteMode { trash, permanent }

/// JSON helpers for [DeleteMode].
extension DeleteModeJson on DeleteMode {
  /// Serializes enum value as a stable lowercase string.
  String toJsonValue() => name;

  /// Parses [value] produced by [toJsonValue].
  static DeleteMode fromJsonValue(String value) =>
      DeleteMode.values.byName(value);
}
