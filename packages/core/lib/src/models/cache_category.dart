/// High-level cache ownership domain.
enum CacheCategory { project, xcode, fvm, global }

/// JSON helpers for [CacheCategory].
extension CacheCategoryJson on CacheCategory {
  /// Serializes enum value as a stable lowercase string.
  String toJsonValue() => name;

  /// Parses [value] produced by [toJsonValue].
  static CacheCategory fromJsonValue(String value) =>
      CacheCategory.values.byName(value);
}
